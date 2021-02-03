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
@property (nonatomic) CGRect frame;
@end

@implementation YZBlendFilter
- (instancetype)init
{
    self = [super initWithVertexFunctionName:@"YZBlendVertex" fragmentFunctionName:@"YZBlendFragment"];
    if (self) {
        
    }
    return self;
}

#pragma mark - YZFilterProtocol
- (void)newTextureAvailable:(id<MTLTexture>)texture{
    if (_imageTexture && _frame.size.width > 0 && _frame.size.height > 0) {
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
        [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:YZBlendVertexIndexVideo];
        [encoder setFragmentTexture:texture atIndex:YZBlendFragmentIndexVideo];
        [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:YZBlendVertexIndexImage];
        [encoder setFragmentTexture:_imageTexture atIndex:YZBlendFragmentIndexImage];
        
        simd_float4 frame = [self getRenderFrame:texture];
        [encoder setFragmentBytes:&frame length:sizeof(simd_float4) atIndex:YZUniformIndexNormal];
        
        [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
        [encoder endEncoding];
        
        [commandBuffer commit];
        
        [super newTextureAvailable:outputTexture];
    } else {
        [super newTextureAvailable:texture];
    }
}

#pragma mark - out
- (void)setWatermark:(UIImage *)image frame:(CGRect)frame {
    _image = image;
    _frame = frame;
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

#pragma mark - private
- (simd_float4)getRenderFrame:(id<MTLTexture>)texture {
    NSUInteger width = texture.width;
    NSUInteger height = texture.height;
    if (_frame.origin.x >= width || _frame.origin.y >= height) {
        simd_float4 frame = {0, 0, 0, 0};
        return frame;
    }
    
    if (_frame.origin.x + _frame.size.width > width) {
        _frame = CGRectMake(_frame.origin.x, _frame.origin.y, width - _frame.origin.x, _frame.size.height);
    }
    
    if (_frame.origin.y + _frame.size.height > height) {
        _frame = CGRectMake(_frame.origin.x, _frame.origin.y, _frame.size.width, height - _frame.origin.y);
    }
    float x = _frame.origin.x / width;
    float y = _frame.origin.y / height;
    float w = _frame.size.width / width;
    float h = _frame.size.height / height;
    simd_float4 frame = {x, y, w, h};
    //simd_float4 frame = {0.5, 0, 0.5, 0.5};
    return frame;
}

@end
