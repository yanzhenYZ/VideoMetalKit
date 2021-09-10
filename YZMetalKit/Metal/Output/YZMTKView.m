//
//  YZMTKView.m
//  YZMetalLib
//
//  Created by yanzhen on 2020/12/10.
//

#import "YZMTKView.h"
#import "YZMetalDevice.h"
#import "YZMetalOrientation.h"
#import "YZShaderTypes.h"

#define PIXELBUFFER 0

@interface YZMTKView ()<MTKViewDelegate>
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic) CGRect currentBounds;
@property (nonatomic) double red;
@property (nonatomic) double green;
@property (nonatomic) double blue;
@property (nonatomic) double alpha;

@property (nonatomic, strong) CIContext *context;
#if PIXELBUFFER
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
#endif
@end

@implementation YZMTKView

#if PIXELBUFFER
- (void)dealloc
{
    if (_textureCache) {
        CVMetalTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
        _textureCache = nil;
    }
}
#endif

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _configSelf];
        self.currentBounds = self.bounds;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.currentBounds = self.bounds;
}

- (void)setFillMode:(YZMTKViewFillMode)fillMode {
    _fillMode = fillMode;
//    if (fillMode == YZMTKViewFillModeScaleAspectFill) {
//        self.contentMode = (UIViewContentMode)fillMode;
//    } else {
//        self.contentMode = UIViewContentModeScaleToFill;
//    }
    
    self.contentMode = (UIViewContentMode)fillMode;
}

- (void)setBackgroundColorRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha {
    _red = red;
    _green = green;
    _blue = blue;
    _alpha = alpha;
}

- (void)showPixelBuffer:(CVPixelBufferRef)pixelBuffer {
#if PIXELBUFFER
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    CVMetalTextureRef tmpTexture = NULL;
    CVReturn status =  CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, width, height, 0, &tmpTexture);
    if (status != kCVReturnSuccess) {
        CVPixelBufferRelease(pixelBuffer);
        return;
    }
    
    self.drawableSize = CGSizeMake(width, height);
    self.texture = CVMetalTextureGetTexture(tmpTexture);
    CFRelease(tmpTexture);
    [self draw];
#endif
}

-(void)newTextureAvailable:(id<MTLTexture>)texture{
    _texture = texture;
    /**
     0    libobjc.A.dylib _objc_msgSend + 20
     1    UIKitCore -[UIWindow convertRect:toCoordinateSpace:] + 540
     2    UIKitCore -[UIView convertRect:toCoordinateSpace:] + 364
     3    MetalKit -[MTKView setContentScaleFactor:] + 372
     4    MetalKit -[MTKView setDrawableSize:] + 100
     */
    CGSize size = CGSizeMake(texture.width, texture.height);
    if (!CGSizeEqualToSize(self.drawableSize, size)) {
        self.drawableSize = size;
    }
    [self draw];
}

#pragma mark - MTKViewDelegate
- (void)drawInMTKView:(MTKView *)view {
    if (!view.currentDrawable || !_texture) { return; }
    id<MTLTexture> outTexture = view.currentDrawable.texture;
    
    MTLRenderPassDescriptor *desc = [YZMetalDevice newRenderPassDescriptor:outTexture];
    desc.colorAttachments[0].clearColor = MTLClearColorMake(_red, _green, _blue, _alpha);
    
    id<MTLCommandBuffer> commandBuffer = [YZMetalDevice.defaultDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZMTKView render endcoder Fail");
        return;
    }
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:_pipelineState];

    CGFloat w = 1;
    CGFloat h = 1;
//    if (_fillMode == YZMTKViewFillModeScaleAspectFit) {//for background color
//        CGRect bounds = self.currentBounds;
//        CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(self.drawableSize, bounds);
//        w = insetRect.size.width / bounds.size.width;
//        h = insetRect.size.height / bounds.size.height;
//    }
    
    simd_float8 vertices = {-w, h, w, h, -w, -h, w, -h};
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:YZVertexIndexPosition];
    
    simd_float8 textureCoordinates = [YZMetalOrientation defaultTextureCoordinates];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:YZVertexIndexTextureCoordinate];
    [encoder setFragmentTexture:_texture atIndex:YZFragmentTextureIndexNormal];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
    
    [self getImage:view.currentDrawable.texture];
    //[self makeImage:view.currentDrawable.texture];
    
    _texture = nil;
}



- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

#warning mark - doing
- (void)getImage:(id<MTLTexture>)texture {//UIViewContentMode

    CIImage *ci = [CIImage imageWithMTLTexture:texture options:@{kCIImageColorSpace : (__bridge id _Nullable)(CGColorSpaceCreateDeviceRGB())}];
    ci = [ci imageByApplyingOrientation:4];//kCGImagePropertyOrientationDownMirrored
#if 1//19% 31.1
    CGRect rect = CGRectMake(0, 0, texture.width, texture.height);
    CGImageRef videoImageRef = [self.context createCGImage:ci fromRect:rect];
    if (!videoImageRef) { return; }
    UIImage *image = [UIImage imageWithCGImage:videoImageRef];
    CGImageRelease(videoImageRef);
#else//17% 32.5MB
    UIImage *image = [UIImage imageWithCIImage:ci];
#endif
    if (image && [_mtkDelegate respondsToSelector:@selector(mtkView:snapImage:)]) {
        [_mtkDelegate mtkView:self snapImage:image];
    }
}

- (void)makeImage:(id<MTLTexture>)texture {//26% 31.1MB
    CVPixelBufferRef imageBuffer = [self makePixelBuffer:CGSizeMake(texture.width, texture.height)];
    if (!imageBuffer) { return; }
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    void *bytes = CVPixelBufferGetBaseAddress(imageBuffer);
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [texture getBytes:bytes bytesPerRow:bytesPerRow fromRegion:region mipmapLevel:0];
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:imageBuffer];
    CGImageRef videoImageRef = [self.context createCGImage:ciImage fromRect:CGRectMake(0, 0, width, height)];
    CVPixelBufferRelease(imageBuffer);
    imageBuffer = nil;
    if (!videoImageRef) { return; }
    UIImage *image = [UIImage imageWithCGImage:videoImageRef];
    CGImageRelease(videoImageRef);
    if (image && [_mtkDelegate respondsToSelector:@selector(mtkView:snapImage:)]) {
        [_mtkDelegate mtkView:self snapImage:image];
    }
}



- (CIContext *)context {
    if (!_context) {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}
#pragma mark - private config
- (void)_configSelf {
    _alpha = 1.0;
    
    self.paused = YES;
    self.delegate = self;
    self.framebufferOnly = NO;
    self.enableSetNeedsDisplay = NO;
    self.device = YZMetalDevice.defaultDevice.device;
    self.contentMode = UIViewContentModeScaleToFill;
    _pipelineState = [YZMetalDevice.defaultDevice newRenderPipeline:@"YZInputVertex" fragment:@"YZFragment"];
#if PIXELBUFFER
    CVMetalTextureCacheCreate(NULL, NULL, self.device, NULL, &_textureCache);
#endif
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _currentBounds = self.bounds;
}

- (CVPixelBufferRef)makePixelBuffer:(CGSize)size {
    CVPixelBufferRef pixelBuffer;
    NSDictionary *pixelAttributes = @{(NSString *)kCVPixelBufferIOSurfacePropertiesKey:@{}};
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                            size.width,
                                            size.height,
                                            kCVPixelFormatType_32BGRA,
                                            (__bridge CFDictionaryRef)(pixelAttributes),
                                            &pixelBuffer);
    if (result != kCVReturnSuccess) {
        NSLog(@"Failed to Create CVPixelbuffer %d", result);
        return nil;
    }
    return pixelBuffer;
}
@end
