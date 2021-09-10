//
//  YZMTKView.h
//  YZMetalLib
//
//  Created by yanzhen on 2020/12/10.
//

#import <MetalKit/MetalKit.h>
#import "YZFilterProtocol.h"

typedef NS_ENUM(NSInteger, YZMTKViewFillMode) {
    YZMTKViewFillModeScaleToFill,       // Same as UIViewContentModeScaleToFill
    YZMTKViewFillModeScaleAspectFit,    // Same as UIViewContentModeScaleAspectFit
    YZMTKViewFillModeScaleAspectFill,   // Same as UIViewContentModeScaleAspectFill
};

@class YZTexture;
@protocol YZMTKViewDelegate;
@interface YZMTKView : MTKView<YZFilterProtocol>
@property (nonatomic, weak) id<YZMTKViewDelegate> mtkDelegate;
@property (nonatomic) YZMTKViewFillMode fillMode;

- (void)showPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)setBackgroundColorRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha;
@end


@protocol YZMTKViewDelegate <NSObject>

- (void)mtkView:(YZMTKView *)view snapImage:(UIImage *)image;

@end
