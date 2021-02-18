//
//  YZNewCropFilter.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/18.
//

#import "YZNewCropFilter.h"
#import "YZMetalDevice.h"
#import "YZMetalOrientation.h"
#import "YZShaderTypes.h"
#import <simd/simd.h>

@interface YZNewCropFilter ()
@property (nonatomic) CGSize size;
@property (nonatomic) CGRect cropRegion;
@end

@implementation YZNewCropFilter
- (instancetype)initWithSize:(CGSize)size {
    self = [super init];
    if (self) {
        _size = size;
        _cropRegion = CGRectMake(0, 0, 1, 1);
    }
    return self;
}

-(void)newTextureAvailable:(id<MTLTexture>)texture {
    if ([self needCutTexture:CGSizeMake(texture.width, texture.height)]) {
        [self dealTexture:texture];
        return;
    }
    [super newTextureAvailable:texture];
}
//CPU %2
- (void)dealTexture:(id<MTLTexture>)texture {
    MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm width:texture.width height:texture.height mipmapped:NO];
    desc.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget;
    id<MTLTexture> outputTexture = [YZMetalDevice.defaultDevice.device newTextureWithDescriptor:desc];
    id<MTLCommandBuffer> commandBuffer = [YZMetalDevice.defaultDevice commandBuffer];
    MTLRenderPassDescriptor *textureDesc = [YZMetalDevice newRenderPassDescriptor:outputTexture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:textureDesc];
    if (!encoder) {
        NSLog(@"YZNewPixelBuffer render endcoder Fail");
        return;
    }

    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.pipelineState];
    simd_float8 vertices = [YZMetalOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:YZVertexIndexPosition];
    
    //simd_float8 textureCoordinates = [self getTextureCoordinates];
    simd_float8 textureCoordinates = [YZMetalOrientation defaultTextureCoordinates];
    //simd_float8 textureCoordinates = {0.125, 0, 0.875, 0, 0.125, 1, 0.875, 1};
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:YZVertexIndexTextureCoordinate];
    [encoder setFragmentTexture:texture atIndex:YZFragmentTextureIndexNormal];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    
    [super newTextureAvailable:outputTexture];
}

-(void)changeSize:(CGSize)size {
    
}

#pragma mark - private
#warning mark - YZ

- (BOOL)needCutTexture:(CGSize)size {
    return NO;
//    if (size.width > size.height && self.size.width < self.size.height) {//横屏
//        [self switchSize:size];
//        return YES;
//    } else if (size.width < size.height && self.size.height < self.size.width) {
//        [self switchSize:size];
//        return YES;
//    }
//    [self calculateCropTextureCoordinates:size];
//    return NO;
}

- (void)switchSize:(CGSize)size {
    self.size = CGSizeMake(self.size.height, self.size.width);
    [self calculateCropTextureCoordinates:size];
}

- (void)calculateCropTextureCoordinates:(CGSize)size {
    if (CGSizeEqualToSize(self.size, size)) {
        _cropRegion = CGRectMake(0, 0, 1, 1);
        return;
    }
    CGFloat width = size.width - self.size.width;
    CGFloat x = width / 2 / size.width;
    CGFloat w = 1 - 2 * x;
    
    CGFloat height = size.height - self.size.height;
    CGFloat y = height / 2 / size.height;
    CGFloat h = 1 - 2 * y;
    _cropRegion = CGRectMake(x, y, w, h);
}
@end
