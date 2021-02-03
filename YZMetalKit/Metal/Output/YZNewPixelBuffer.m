//
//  YZNewPixelBuffer.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/1/8.
//

#import "YZNewPixelBuffer.h"
#import <CoreVideo/CVMetalTextureCache.h>
#import "YZMetalOrientation.h"
#import "YZMetalDevice.h"
#import "YZShaderTypes.h"

@interface YZNewPixelBuffer ()
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic) CGSize size;
@end

@implementation YZNewPixelBuffer {
    CVPixelBufferRef _pixelBuffer;
}

- (void)dealloc {
    if (_pixelBuffer) {
        CVPixelBufferRelease(_pixelBuffer);
        _pixelBuffer = nil;
    }
    
    if (_textureCache) {
        CVMetalTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, YZMetalDevice.defaultDevice.device, NULL, &_textureCache);
    }
    return self;
}

-(void)newTextureAvailable:(id<MTLTexture>)texture commandBuffer:(id<MTLCommandBuffer>)commandBuffer {
    [self newDealTextureSize:texture];
    if (!_pixelBuffer) { return; }
    
    [self nnnBuffer:texture];
}

- (void)nnnBuffer:(id<MTLTexture>)texture {
    MTLRenderPassDescriptor *desc = [YZMetalDevice newRenderPassDescriptor:_texture];
    id<MTLCommandBuffer> commandBuffer = [YZMetalDevice.defaultDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZVideoCamera render endcoder Fail");
        return;
    }

    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.pipelineState];
    simd_float8 vertices = [YZMetalOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:YZVertexIndexPosition];
    
    simd_float8 textureCoordinates = [YZMetalOrientation defaultTextureCoordinates];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:YZVertexIndexTextureCoordinate];
    [encoder setFragmentTexture:texture atIndex:YZFragmentTextureIndexNormal];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    
    if ([_delegate respondsToSelector:@selector(outputPixelBuffer:)]) {
        [_delegate outputPixelBuffer:_pixelBuffer];
    }
    [super newTextureAvailable:texture commandBuffer:commandBuffer];
}

#pragma mark - output texture size
- (void)newDealTextureSize:(id<MTLTexture>)texture {
    CGFloat width = texture.width;
    CGFloat height = texture.height;
    if (!CGSizeEqualToSize(_size, CGSizeMake(width, height))) {
        if (_pixelBuffer) {
            CVPixelBufferRelease(_pixelBuffer);
            _pixelBuffer = nil;
        }
        _size = CGSizeMake(width, height);
    }
    
    if (_pixelBuffer) { return; }
    NSDictionary *pixelAttributes = @{(NSString *)kCVPixelBufferIOSurfacePropertiesKey:@{}};
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                            _size.width,
                                            _size.height,
                                            kCVPixelFormatType_32BGRA,
                                            (__bridge CFDictionaryRef)(pixelAttributes),
                                            &_pixelBuffer);
    if (result != kCVReturnSuccess) {
        NSLog(@"YZNewPixelBuffer to create cvpixelbuffer %d", result);
        return;
    }
    
    CVMetalTextureRef textureRef = NULL;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, _pixelBuffer, nil, MTLPixelFormatBGRA8Unorm, width, height, 0, &textureRef);
    if (kCVReturnSuccess != status) {
        return;
    }
    _texture = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    NSLog(@"bb009:%@:%@",_texture, self.pipelineState);
}
@end
