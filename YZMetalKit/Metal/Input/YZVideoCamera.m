//
//  YZVideoCamera.m
//  YZMetalLib
//
//  Created by yanzhen on 2020/12/9.
//

#import "YZVideoCamera.h"
#import <Metal/Metal.h>
#import "YZMetalDevice.h"
#import "YZVideoCamera.h"
#import "YZShaderTypes.h"
#import "YZMetalOrientation.h"

@interface YZVideoCamera ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *camera;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;
@property (nonatomic, assign) AVCaptureDevicePosition position;
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@property (nonatomic, strong) YZMetalOrientation *orientation;
@property (nonatomic, assign) BOOL userBGRA;
@property (nonatomic, assign) BOOL fullYUVRange;
@property (nonatomic, assign) BOOL pause;
@property (nonatomic, assign) int dropFrames;
@end

@implementation YZVideoCamera {
    dispatch_queue_t _cameraQueue;
    dispatch_queue_t _cameraRenderQueue;
    const float *_colorConversion; //4x3
}

- (void)dealloc {
    [self stopRunning];
    [NSNotificationCenter.defaultCenter removeObserver:self];
    if (_textureCache) {
        CVMetalTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
    }
}

-(instancetype)initWithSessionPreset:(AVCaptureSessionPreset)preset {
    return [self initWithSessionPreset:preset position:AVCaptureDevicePositionFront];
}

- (instancetype)initWithSessionPreset:(AVCaptureSessionPreset)preset position:(AVCaptureDevicePosition)position
{
    self = [super init];
    if (self) {
        _position = position;
        _orientation = [[YZMetalOrientation alloc] init];
        _cameraQueue = dispatch_queue_create("com.yanzhen.video.camera.queue", 0);
        _cameraRenderQueue = dispatch_queue_create("com.yanzhen.video.camera.render.queue", 0);
        _frameRate = 15;
        _userBGRA = YES;
        _preset = preset;
        [self _configVideoSession];
        [self _configMetal];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

#pragma mark - property
-(void)setVideoMirrored:(BOOL)videoMirrored {
    [YZMetalDevice semaphoreWaitForever];
    _orientation.mirror = videoMirrored;
    [YZMetalDevice semaphoreSignal];
}

-(BOOL)videoMirrored {
    return _orientation.mirror;
}

- (void)setOutputOrientation:(UIInterfaceOrientation)outputOrientation {
    [YZMetalDevice semaphoreWaitForever];
    if (_position == AVCaptureDevicePositionBack) {//why
        if (outputOrientation == YZOrientationRight) {
            _orientation.outputOrientation = YZOrientationLeft;
        } else if (outputOrientation == YZOrientationLeft) {
            _orientation.outputOrientation = YZOrientationRight;
        } else {
            _orientation.outputOrientation = (YZOrientation)outputOrientation;
        }
    } else {
        _orientation.outputOrientation = (YZOrientation)outputOrientation;
    }
    [YZMetalDevice semaphoreSignal];
}

- (UIInterfaceOrientation)outputOrientation {
    return (UIInterfaceOrientation)_orientation.outputOrientation;
}

- (void)startRunning {
    [YZMetalDevice semaphoreWaitForever];
    if (!_session.isRunning) {
        [_session startRunning];
    }
    [YZMetalDevice semaphoreSignal];
}

- (void)stopRunning
{
    [YZMetalDevice semaphoreWaitForever];
    if (_session.isRunning) {
        [_session stopRunning];
    }
    [YZMetalDevice semaphoreSignal];
}

- (void)switchCamera {
    [YZMetalDevice semaphoreWaitForever];
    if (_position == AVCaptureDevicePositionBack) {
        _position = AVCaptureDevicePositionFront;
    } else {
        _position = AVCaptureDevicePositionBack;
    }
    
    
    _camera = [YZVideoCamera getDevice:_position];
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:_camera error:nil];
    if (input) {
        [_session beginConfiguration];
        [_session removeInput:_input];
        if ([_session canAddInput:input]) {
            [_session addInput:input];
        }
        
        _camera.activeVideoMinFrameDuration = CMTimeMake(1, self.frameRate);
        _camera.activeVideoMaxFrameDuration = CMTimeMake(1, self.frameRate);
        [_session commitConfiguration];
        _input = input;
    }
    [_orientation switchCamera];
    [YZMetalDevice semaphoreSignal];
}

- (void)setFrameRate:(int32_t)frameRate {
    if (frameRate <= 0) {
        _frameRate = 15;
    } else if (frameRate > 60) {
        _frameRate = 60;
    }
    if (_frameRate == frameRate) { return; }
    _frameRate = frameRate;
    [YZMetalDevice semaphoreWaitForever];
    [_session beginConfiguration];
    _camera.activeVideoMinFrameDuration = CMTimeMake(1, frameRate);
    _camera.activeVideoMaxFrameDuration = CMTimeMake(1, frameRate);
    [_session commitConfiguration];
    [YZMetalDevice semaphoreSignal];
}

- (void)setPreset:(AVCaptureSessionPreset)preset {
    if ([_preset isEqualToString:preset]) {
        return;
    }
    _preset = preset;
    [YZMetalDevice semaphoreWaitForever];
    [_session beginConfiguration];
    if ([_session canSetSessionPreset:preset]) {
        _session.sessionPreset = preset;
    } else if ([preset isEqualToString:AVCaptureSessionPreset1920x1080]) {
        if ([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            _preset = AVCaptureSessionPreset1280x720;
            _session.sessionPreset = AVCaptureSessionPreset1280x720;
        }
    }
    _camera.activeVideoMinFrameDuration = CMTimeMake(1, self.frameRate);
    _camera.activeVideoMaxFrameDuration = CMTimeMake(1, self.frameRate);
    [_session commitConfiguration];
    [YZMetalDevice semaphoreSignal];
}
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate and metal frame
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (!_session.isRunning || _pause) { return; }
    if (_output != output) { return; }
    if ([YZMetalDevice semaphoreWaitNow] != 0) {
        _dropFrames++;
        if ([_delegate respondsToSelector:@selector(videoCamera:dropFrames:)]) {
            [_delegate videoCamera:self dropFrames:_dropFrames];
        }
        return;
    }
    CFRetain(sampleBuffer);
    dispatch_async(_cameraRenderQueue, ^{
        if ([self.delegate respondsToSelector:@selector(videoCamera:output:)]) {
            [self.delegate videoCamera:self output:sampleBuffer];
        }
        if (self.userBGRA) {
            [self processBGRAVideoSampleBuffer:sampleBuffer];
        } else {
            [self processYUVVideoSampleBuffer:sampleBuffer];
        }
        CFRelease(sampleBuffer);
        [YZMetalDevice semaphoreSignal];
    });
}

- (void)processBGRAVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    CVMetalTextureRef textureRef = NULL;
    id<MTLTexture> texture = NULL;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, nil, MTLPixelFormatBGRA8Unorm, width, height, 0, &textureRef);
    if (kCVReturnSuccess != status) {
        return;
    }
    texture = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    
    NSUInteger outputW = width;
    NSUInteger outputH = height;
    if ([_orientation switchWithHeight]) {
        outputW = height;
        outputH = width;
    }
    
    //output texture
    MTLTextureDescriptor *textureDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm width:outputW height:outputH mipmapped:NO];
    textureDesc.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget;
    id<MTLTexture> outputTexture = [YZMetalDevice.defaultDevice.device newTextureWithDescriptor:textureDesc];
    
    //[self converWH:texture outputTexture:outputTexture];
    MTLRenderPassDescriptor *desc = [YZMetalDevice newRenderPassDescriptor:outputTexture];
    id<MTLCommandBuffer> commandBuffer = [YZMetalDevice.defaultDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZVideoCamera render endcoder Fail");
        return;
    }
    
    //表示对顺时针顺序的三角形进行剔除。
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.pipelineState];
    simd_float8 vertices = [YZMetalOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:YZVertexIndexPosition];
    
    simd_float8 textureCoordinates = [_orientation getTextureCoordinates:_position];
    /**
     https://developer.apple.com/documentation/metal/mtlrendercommandencoder/1515846-setvertexbytes
     Use this method for single-use data smaller than 4 KB. Create a MTLBuffer object if your data exceeds 4 KB in length or persists for multiple uses.
     */
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:YZVertexIndexTextureCoordinate];
    [encoder setFragmentTexture:texture atIndex:YZFragmentTextureIndexNormal];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    [self.allFilters enumerateObjectsUsingBlock:^(id<YZFilterProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj newTextureAvailable:outputTexture commandBuffer:commandBuffer];
    }];
}


- (void)processYUVVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVMetalTextureRef textureRef = NULL;
    id<MTLTexture> textureY = NULL;
    //y
    size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, NULL, MTLPixelFormatR8Unorm, width, height, 0, &textureRef);
    if(status != kCVReturnSuccess) {
        return;
    }
    textureY = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    
    //uv
    id<MTLTexture> textureUV = NULL;
    width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
    height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, NULL, MTLPixelFormatRG8Unorm, width, height, 1, &textureRef);
    if(status != kCVReturnSuccess) {
        return;
    }
    textureUV = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    
    height = CVPixelBufferGetHeight(pixelBuffer);
    width = CVPixelBufferGetWidth(pixelBuffer);
    NSUInteger outputW = width;
    NSUInteger outputH = height;
    if ([_orientation switchWithHeight]) {
        outputW = height;
        outputH = width;
    }
    MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm width:outputW height:outputH mipmapped:NO];
    desc.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget;
    id<MTLTexture> outputTexture = [YZMetalDevice.defaultDevice.device newTextureWithDescriptor:desc];
    CFTypeRef attachment = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
    if (attachment != NULL) {
        if(CFStringCompare(attachment, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo) {
            if (_fullYUVRange) {
                _colorConversion = kYZColorConversion601FullRange;
            } else {
                _colorConversion = kYZColorConversion601;
            }
        } else {
            _colorConversion = kYZColorConversion709;
        }
    } else {
        if (_fullYUVRange) {
            _colorConversion = kYZColorConversion601FullRange;
        } else {
            _colorConversion = kYZColorConversion601;
        }
    }
    
    [self convertYUVToRGB:textureY textureUV:textureUV outputTexture:outputTexture];
}

- (void)convertYUVToRGB:(id<MTLTexture>)textureY textureUV:(id<MTLTexture>)textureUV outputTexture:(id<MTLTexture>)texture {
    MTLRenderPassDescriptor *desc = [YZMetalDevice newRenderPassDescriptor:texture];
    id<MTLCommandBuffer> commandBuffer = [YZMetalDevice.defaultDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZVideoCamera render endcoder Fail");
    }
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.pipelineState];
    
    simd_float8 vertices = [YZMetalOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:YZFullRangeVertexIndexPosition];
    
    //yuv
    simd_float8 textureCoordinates = [_orientation getTextureCoordinates:_position];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:YZFullRangeVertexIndexY];
    [encoder setFragmentTexture:textureY atIndex:YZFullRangeFragmentIndexY];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:YZFullRangeVertexIndexUV];
    [encoder setFragmentTexture:textureUV atIndex:YZFullRangeFragmentIndexUV];

    //coversion
    
    id<MTLBuffer> uniformBuffer = [YZMetalDevice.defaultDevice.device newBufferWithBytes:_colorConversion length:sizeof(float) * 12 options:MTLResourceCPUCacheModeDefaultCache];
    [encoder setFragmentBuffer:uniformBuffer offset:0 atIndex:YZUniformIndexNormal];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    [self.allFilters enumerateObjectsUsingBlock:^(id<YZFilterProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj newTextureAvailable:texture commandBuffer:commandBuffer];
    }];
}

#pragma mark - private
- (void)_configMetal {
    CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, YZMetalDevice.defaultDevice.device, NULL, &_textureCache);
}

- (void)_configVideoSession {
    _session = [[AVCaptureSession alloc] init];
    _camera = [YZVideoCamera getDevice:_position];
    
    NSError *error = nil;
    _input = [[AVCaptureDeviceInput alloc] initWithDevice:_camera error:&error];
    if (error) {
        NSLog(@"YZVideoCamera error:%@", error);
        return;
    }
    [_session beginConfiguration];
    
    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    }
    
    _output = [[AVCaptureVideoDataOutput alloc] init];
    _output.alwaysDiscardsLateVideoFrames = NO;
    [_output setSampleBufferDelegate:self queue:_cameraQueue];
        
    if (_userBGRA) {
        [self generatePipelineVertexFunctionName:@"YZInputVertex" fragmentFunctionName:@"YZFragment"];
        NSDictionary *dict = @{
            (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)
        };
        _output.videoSettings = dict;
    } else {
        NSArray<NSNumber *> *availableVideoCVPixelFormatTypes = _output.availableVideoCVPixelFormatTypes;
        [availableVideoCVPixelFormatTypes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.longLongValue == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
                self.fullYUVRange = YES;
            }
        }];
        
        if (_fullYUVRange) {
            [self generatePipelineVertexFunctionName:@"YZYUVToRGBVertex" fragmentFunctionName:@"YZYUVConversionFullRangeFragment"];
            NSDictionary *dict = @{
                (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            };
            _output.videoSettings = dict;
        } else {
            [self generatePipelineVertexFunctionName:@"YZYUVToRGBVertex" fragmentFunctionName:@"YZYUVConversionVideoRangeFragment"];
            NSDictionary *dict = @{
                (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
            };
            _output.videoSettings = dict;
        }
    }
    
    if ([_session canAddOutput:_output]) {
        [_session addOutput:_output];
    }
    
    if ([_session canSetSessionPreset:_preset]) {
        _session.sessionPreset = _preset;
    }
    
    _camera.activeVideoMinFrameDuration = CMTimeMake(1, _frameRate);
    _camera.activeVideoMaxFrameDuration = CMTimeMake(1, _frameRate);
    [_session commitConfiguration];
}

#pragma mark - observer

- (void)willResignActive:(NSNotification *)notification {
    _pause = YES;
}

- (void)didBecomeActive:(NSNotification *)notification {
    _pause = NO;
}

#pragma mark - class
+ (AVCaptureDevice *)getDevice:(AVCaptureDevicePosition)position {
    if (@available(iOS 10.0, *)) {
        return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:position];
    } else {
        NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        __block AVCaptureDevice *device = nil;
        [devices enumerateObjectsUsingBlock:^(AVCaptureDevice * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.position == position) {
                device = obj;
                *stop = YES;
            }
        }];
        return device;
    }
    return nil;
}
@end
