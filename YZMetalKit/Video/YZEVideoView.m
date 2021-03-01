//
//  YZEVideoView.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/26.
//

#import "YZEVideoView.h"
#import "YZMetalDevice.h"
#import <AVFoundation/AVFoundation.h>
#import "YZMetalOrientation.h"

@interface YZEVideoView ()<MTKViewDelegate>
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic) CGRect currentBounds;
@property (nonatomic) double red;
@property (nonatomic) double green;
@property (nonatomic) double blue;
@property (nonatomic) double alpha;
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@end

@implementation YZEVideoView

- (void)dealloc
{
    if (_textureCache) {
        CVMetalTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
        _textureCache = nil;
    }
}

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

- (void)setFillMode:(YZEVideoViewFillMode)fillMode {
    _fillMode = fillMode;
    if (fillMode == YZEVideoViewFillModeScaleAspectFill) {
        self.contentMode = (UIViewContentMode)fillMode;
    } else {
        self.contentMode = UIViewContentModeScaleToFill;
    }
}

- (void)setBackgroundColorRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha {
    _red = red;
    _green = green;
    _blue = blue;
    _alpha = alpha;
}

- (void)showPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
    if (type == kCVPixelFormatType_32BGRA) {
        [self showBGRAPixelBuffer:pixelBuffer];
    } else if (type == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        //[self showYUVPixelBuffer:pixelBuffer fullYUV:NO];
    }
}

- (void)newTextureAvailable:(id<MTLTexture>)texture {
    self.texture = texture;
    self.drawableSize = CGSizeMake(texture.width, texture.height);
    [self draw];
}
#pragma mark - helper

- (void)showBGRAPixelBuffer:(CVPixelBufferRef)pixelBuffer {
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
    if (_fillMode == YZEVideoViewFillModeScaleAspectFit) {//for background color
        CGRect bounds = self.currentBounds;
        CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(self.drawableSize, bounds);
        w = insetRect.size.width / bounds.size.width;
        h = insetRect.size.height / bounds.size.height;
    }
    
    simd_float8 vertices = {-w, h, w, h, -w, -h, w, -h};
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    simd_float8 textureCoordinates = [YZMetalOrientation defaultTextureCoordinates];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:_texture atIndex:0];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
    _texture = nil;
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
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
    CVMetalTextureCacheCreate(NULL, NULL, self.device, NULL, &_textureCache);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _currentBounds = self.bounds;
}

@end
