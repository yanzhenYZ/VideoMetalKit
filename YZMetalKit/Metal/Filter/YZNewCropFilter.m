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

//可以绑定到任何Metal Filter

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
    MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm width:_size.width height:_size.height mipmapped:NO];
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
    
    simd_float8 textureCoordinates = [self getTextureCoordinates];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:YZVertexIndexTextureCoordinate];
    [encoder setFragmentTexture:texture atIndex:YZFragmentTextureIndexNormal];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    
    [super newTextureAvailable:outputTexture];
}

-(void)changeSize:(CGSize)size {
    [YZMetalDevice semaphoreWaitForever];
    self.size = size;
    [YZMetalDevice semaphoreSignal];
}

#pragma mark - private
- (BOOL)needCutTexture:(CGSize)size {
    if (!_scaleSize) { return NO; }
    if ([self scaleCropSize:size]) {
        return NO;
    }
    CGFloat width = size.width - self.size.width;
    CGFloat x = width / 2 / size.width;
    CGFloat w = 1 - 2 * x;
    
    CGFloat height = size.height - self.size.height;
    CGFloat y = height / 2 / size.height;
    CGFloat h = 1 - 2 * y;
    _cropRegion = CGRectMake(x, y, w, h);
    return YES;
}

#if 0 //输出指定size
- (BOOL)scaleCropSize:(CGSize)size {
    if (CGSizeEqualToSize(size, _size)) {
        return YES;
    }
    if (size.width > size.height && self.size.width < self.size.height) {//横屏
        self.size = CGSizeMake(self.size.height, self.size.width);
    } else if (size.width < size.height && self.size.height < self.size.width)
        self.size = CGSizeMake(self.size.height, self.size.width);
    }
    if (CGSizeEqualToSize(size, _size)) {
        return YES;
    }
    return NO;
}

//keep this
/**                     //use this
 120x120  =  480x480
 160x120  =  640x480
 180x180  =  480x480
 240x180  =  640x480
 240x240  =  480x480
 320x240  =  640x480
 
 424x240  =  640x362
 
 360x360  =  480x480
 480x360  =  640x480
 640x360  =  640x360
 480x480  =  480x480
 640x480  =  640x480
 
 840x480  =  1260x720
 
 960x720  =  960x720
 1280x720 = 1280x720
 */
#else //输出scale size
- (BOOL)scaleCropSize:(CGSize)size {
    if (CGSizeEqualToSize(size, _size)) {
        return YES;
    }
    if (size.width > size.height && self.size.width < self.size.height) {//横屏
        self.size = CGSizeMake(self.size.height, self.size.width);
    } else if (size.width < size.height && self.size.height < self.size.width) {
        self.size = CGSizeMake(self.size.height, self.size.width);
    }
    if (CGSizeEqualToSize(size, _size)) {
        return YES;
    }
    
    
    CGFloat sizeRatio = _size.width / _size.height;
    CGFloat textureRatio = size.width / size.height;
    if (textureRatio == sizeRatio) {
        return YES;
    }
#if 1 //use this
    if (sizeRatio > (textureRatio * 1.1) || sizeRatio < (textureRatio * 0.9)) {
        if (textureRatio > sizeRatio) {
            CGFloat outputW = size.width * sizeRatio / textureRatio;
            if (_size.height > size.height) {
                _size = CGSizeMake(outputW / (_size.height / size.height), size.height);
            } else {
                _size = CGSizeMake(outputW, size.height);
            }
        } else {
            CGFloat outoutH = size.height * textureRatio / sizeRatio;
            if (_size.width > size.width) {
                _size = CGSizeMake(size.width, outoutH / (_size.width / size.width));
            } else {
                _size = CGSizeMake(size.width, outoutH);
            }
        }
        return NO;
    }
    return YES;
#else
    //生成新的size最大缩放接近size
    if (textureRatio > sizeRatio) {
        CGFloat outputW = size.width * sizeRatio / textureRatio;
        if (_size.height > size.height) {
            _size = CGSizeMake(outputW / (_size.height / size.height), size.height);
        } else {
            _size = CGSizeMake(outputW, size.height);
        }
    } else {
        CGFloat outoutH = size.height * textureRatio / sizeRatio;
        if (_size.width > size.width) {
            _size = CGSizeMake(size.width, outoutH / (_size.width / size.width));
        } else {
            _size = CGSizeMake(size.width, outoutH);
        }
    }
    return NO;
#endif
}
#endif

- (simd_float8)getTextureCoordinates {
    CGFloat minX = _cropRegion.origin.x;
    CGFloat minY = _cropRegion.origin.y;
    CGFloat maxX = CGRectGetMaxX(_cropRegion);
    CGFloat maxY = CGRectGetMaxY(_cropRegion);
    simd_float8 textureCoordinates = {minX, minY, maxX, minY, minX, maxY, maxX, maxY};
    return textureCoordinates;
}
@end
