//
//  YZBlendFilter.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/1/26.
//

#import "YZBlendFilter.h"
#import <MetalKit/MetalKit.h>
#import "YZMetalDevice.h"
#import "YZMetalOrientation.h"
#import "YZShaderTypes.h"

@interface YZBlendFilter ()
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) id<MTLTexture> imageTexture;
@end

@implementation YZBlendFilter
- (instancetype)init
{
    self = [super initWithVertexFunctionName:@"YZBlendVertex" fragmentFunctionName:@"YZBlendFragment"];
    if (self) {
        
    }
    return self;
}
- (void)newTextureAvailable:(id<MTLTexture>)texture commandBuffer:(id<MTLCommandBuffer>)commandBuffer {
    if (_imageTexture) {
        MTLTextureDescriptor *textureDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm width:texture.width height:texture.height mipmapped:NO];
        textureDesc.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget;
        id<MTLTexture> outputTexture = [YZMetalDevice.defaultDevice.device newTextureWithDescriptor:textureDesc];
        
        MTLRenderPassDescriptor *desc = [YZMetalDevice newRenderPassDescriptor:outputTexture];
        id<MTLCommandBuffer> commandBuffer = [YZMetalDevice.defaultDevice commandBuffer];
        id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
        if (!encoder) {
            NSLog(@"YZBlendFilter render endcoder Fail");
            return;
        }
        [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
        [encoder setRenderPipelineState:self.pipelineState];
        
        simd_float8 vertices = [YZMetalOrientation defaultVertices];
        [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:YZBlendVertexIndexPosition];
        
        simd_float8 textureCoordinates = [YZMetalOrientation defaultTextureCoordinates];
        [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:YZBlendVertexIndexY];
        [encoder setFragmentTexture:_imageTexture atIndex:YZBlendFragmentIndexY];
        [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:YZBlendVertexIndexUV];
        [encoder setFragmentTexture:texture atIndex:YZBlendFragmentIndexUV];
        
        [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
        [encoder endEncoding];
        
        [commandBuffer commit];
        
        [super newTextureAvailable:outputTexture commandBuffer:commandBuffer];
    } else {
        [super newTextureAvailable:texture commandBuffer:commandBuffer];
    }
}

- (void)setWatermark:(UIImage *)image {
    _image = image;
}

- (void)processImage {
    if (_imageTexture) { return; }
    MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:YZMetalDevice.defaultDevice.device];
    NSDictionary *options = @{
        MTKTextureLoaderOptionSRGB : @(NO)
    };
    __weak YZBlendFilter *weakSlef = self;
    [loader newTextureWithCGImage:_image.CGImage options:options completionHandler:^(id<MTLTexture>  _Nullable texture, NSError * _Nullable error) {
        weakSlef.imageTexture = texture;
    }];
}
@end
