//
//  YZEYUVBuffer.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/3/1.
//

#import "YZEYUVBuffer.h"
#import <MetalKit/MetalKit.h>
#import "YZMetalOrientation.h"
#import "YZMetalDevice.h"

@interface YZEYUVBuffer ()
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@end

@implementation YZEYUVBuffer {
    const float *_colorConversion; //4x3
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        CVMetalTextureCacheCreate(NULL, NULL, YZMetalDevice.defaultDevice.device, NULL, &_textureCache);
        _pipelineState = [YZMetalDevice.defaultDevice newRenderPipeline:@"YZYUVToRGBVertex" fragment:@"YZYUVConversionVideoRangeFragment"];
//        if (_fullYUVRange) {
//            [self generatePipelineVertexFunctionName:@"YZYUVToRGBVertex" fragmentFunctionName:@"YZYUVConversionFullRangeFragment"];
//            NSDictionary *dict = @{
//                (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
//            };
//            _output.videoSettings = dict;
//        } else {
//            [self generatePipelineVertexFunctionName:@"YZYUVToRGBVertex" fragmentFunctionName:@"YZYUVConversionVideoRangeFragment"];
//            NSDictionary *dict = @{
//                (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
//            };
//            _output.videoSettings = dict;
//        }
    }
    return self;
}

- (id<MTLTexture>)inputYUVPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    return [self showYUVPixelBuffer:pixelBuffer fullYUV:YES];
}

- (id<MTLTexture>)showYUVPixelBuffer:(CVPixelBufferRef)pixelBuffer fullYUV:(BOOL)fullYUVRange {
    CVMetalTextureRef textureRef = NULL;
    id<MTLTexture> textureY = NULL;
    //y
    size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, NULL, MTLPixelFormatR8Unorm, width, height, 0, &textureRef);
    if(status != kCVReturnSuccess) {
        return nil;
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
        return nil;
    }
    textureUV = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    
    height = CVPixelBufferGetHeight(pixelBuffer);
    width = CVPixelBufferGetWidth(pixelBuffer);
    MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm width:width height:height mipmapped:NO];
    desc.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget;
    id<MTLTexture> outputTexture = [YZMetalDevice.defaultDevice.device newTextureWithDescriptor:desc];
    CFTypeRef attachment = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
    if (attachment != NULL) {
        if(CFStringCompare(attachment, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo) {
            if (fullYUVRange) {
                _colorConversion = kYZColorConversion601FullRange;
            } else {
                _colorConversion = kYZColorConversion601;
            }
        } else {
            _colorConversion = kYZColorConversion709;
        }
    } else {
        if (fullYUVRange) {
            _colorConversion = kYZColorConversion601FullRange;
        } else {
            _colorConversion = kYZColorConversion601;
        }
    }
    
    return [self convertYUVToRGB:textureY textureUV:textureUV outputTexture:outputTexture];
}

- (id<MTLTexture>)convertYUVToRGB:(id<MTLTexture>)textureY textureUV:(id<MTLTexture>)textureUV outputTexture:(id<MTLTexture>)texture {
    MTLRenderPassDescriptor *desc = [YZMetalDevice newRenderPassDescriptor:texture];
    id<MTLCommandBuffer> commandBuffer = [YZMetalDevice.defaultDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZVideoCamera render endcoder Fail");
    }
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.pipelineState];
    
    simd_float8 vertices = [YZMetalOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    //yuv
    simd_float8 textureCoordinates = [YZMetalOrientation defaultTextureCoordinates];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:textureY atIndex:0];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:2];
    [encoder setFragmentTexture:textureUV atIndex:1];

    //coversion
    id<MTLBuffer> uniformBuffer = [YZMetalDevice.defaultDevice.device newBufferWithBytes:_colorConversion length:sizeof(float) * 12 options:MTLResourceCPUCacheModeDefaultCache];
    [encoder setFragmentBuffer:uniformBuffer offset:0 atIndex:0];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    return texture;
}

@end
