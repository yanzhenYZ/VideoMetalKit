//
//  TPMTKView.m
//  YZMetalKit
//
//  Created by yanzhen on 2022/7/4.
//

#import "TPMTKView.h"
#import "YZMetalDevice.h"
#import "YZMetalOrientation.h"
#import "YZShaderTypes.h"

#define PIXELBUFFER 0

@interface TPMTKView ()<MTKViewDelegate>
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic) CGRect currentBounds;
@property (nonatomic) double red;
@property (nonatomic) double green;
@property (nonatomic) double blue;
@property (nonatomic) double alpha;
#if PIXELBUFFER
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
#endif
@end

@implementation TPMTKView

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
        _how = 1;
        _wow = 1;
        _rect = CGRectMake(0, 0, 1, 1);
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.currentBounds = self.bounds;
}

- (void)setFillMode:(TPMTKViewFillMode)fillMode {
    self.contentMode = (UIViewContentMode)fillMode;
//    _fillMode = fillMode;
//    if (fillMode == TPMTKViewFillModeScaleAspectFill) {
//        self.contentMode = (UIViewContentMode)fillMode;
//    } else {
//        self.contentMode = UIViewContentModeScaleToFill;
//    }
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
    
#warning mark - doing
    //display height/2
    CGSize size = CGSizeMake(texture.width / _wow, texture.height / _how);
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

    /*CGFloat w = 1;
    CGFloat h = 1;
    if (_fillMode == TPMTKViewFillModeScaleAspectFit) {//for background color
        CGRect bounds = self.currentBounds;
        CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(self.drawableSize, bounds);
        w = insetRect.size.width / bounds.size.width;
        h = insetRect.size.height / bounds.size.height;
    }
    
    simd_float8 vertices = {-w, h, w, h, -w, -h, w, -h};*/
    
    static const simd_float8 vertices = {-1, 1, 1, 1, -1, -1, 1, -1};
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:YZVertexIndexPosition];
    
    //static const simd_float8 textureCoordinates = {0, 0, 1, 0, 0, 1, 1, 1};
    //static const simd_float8 textureCoordinates = {0, 0, 1, 0, 0, 0.5, 1, 0.5};
    simd_float8 textureCoordinates = [YZMetalOrientation getTextureCoordinatesCrop:_rect];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:YZVertexIndexTextureCoordinate];
    [encoder setFragmentTexture:_texture atIndex:YZFragmentTextureIndexNormal];
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
#if PIXELBUFFER
    CVMetalTextureCacheCreate(NULL, NULL, self.device, NULL, &_textureCache);
#endif
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _currentBounds = self.bounds;
}
@end
