//
//  YZEVideoCropFilter.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/26.
//

#import "YZEVideoCropFilter.h"
#import "YZEVideoPixelBuffer.h"
#import "YZMetalOrientation.h"
#import "YZMetalDevice.h"
#import "YZVideoData.h"

@interface YZEVideoCropFilter ()
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@end

@implementation YZEVideoCropFilter
- (void)dealloc
{
    if (_textureCache) {
        CVMetalTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
        _textureCache = nil;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        CVMetalTextureCacheCreate(NULL, NULL, YZMetalDevice.defaultDevice.device, NULL, &_textureCache);
        _pipelineState = [YZMetalDevice.defaultDevice newRenderPipeline:@"YZInputVertex" fragment:@"YZFragment"];
    }
    return self;
}

- (void)inputVideo:(YZVideoData *)videoData {
    if (videoData.pixelBuffer) {
        [self inputPixelBuffer:videoData];
    } else {
        [self inputVideoData:videoData];
    }
}

#pragma mark - helper
//pixelBuffer
- (void)inputPixelBuffer:(YZVideoData *)videoData {
    if (videoData.rotation == 0) {
        [_pixelBuffer inputPixelBuffer:videoData.pixelBuffer];
    } else {
        [self rotationPixelBuffer:videoData.pixelBuffer rotation:videoData.rotation];
    }
}

- (void)rotationPixelBuffer:(CVPixelBufferRef)pixelBuffer rotation:(int)rotation {
    OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
    if (type == kCVPixelFormatType_32BGRA) {
        [self rotation32BGRA:pixelBuffer rotation:rotation];
    } else if (type == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        [self rotationPixelBuffer:pixelBuffer rotation:rotation];
    }
}

- (void)rotationYUV:(CVPixelBufferRef)pixelBuffer rotation:(int)rotation {
#warning mark - todo
}

- (void)rotation32BGRA:(CVPixelBufferRef)pixelBuffer rotation:(int)rotation {
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    CVMetalTextureRef tmpTexture = NULL;
    CVReturn status =  CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, width, height, 0, &tmpTexture);
    if (status != kCVReturnSuccess) {
        CVPixelBufferRelease(pixelBuffer);
        return;
    }
    
    id<MTLTexture> texture = CVMetalTextureGetTexture(tmpTexture);
    CFRelease(tmpTexture);

    NSUInteger outputW = width;
    NSUInteger outputH = height;
    if (rotation == 90 || rotation == 270) {
        outputW = height;
        outputH = width;
    }
    
    //output texture
    MTLTextureDescriptor *textureDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm width:outputW height:outputH mipmapped:NO];
    textureDesc.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget;
    id<MTLTexture> outputTexture = [YZMetalDevice.defaultDevice.device newTextureWithDescriptor:textureDesc];
    
    MTLRenderPassDescriptor *desc = [YZMetalDevice newRenderPassDescriptor:outputTexture];
    id<MTLCommandBuffer> commandBuffer = [YZMetalDevice.defaultDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZEVideoCropFilter render endcoder Fail");
        return;
    }
    
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.pipelineState];
    simd_float8 vertices = [YZMetalOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    simd_float8 textureCoordinates = [YZMetalOrientation getRotationTextureCoordinates:rotation];
   
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:texture atIndex:0];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    [_pixelBuffer newTextureAvailable:outputTexture];
}

//data
- (void)inputVideoData:(YZVideoData *)videoData {
    
}

//- (void)inputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
//    [_pixelBuffer inputPixelBuffer:pixelBuffer];
//}
@end
