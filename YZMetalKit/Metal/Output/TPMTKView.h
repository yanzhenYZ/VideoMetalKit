//
//  TPMTKView.h
//  YZMetalKit
//
//  Created by yanzhen on 2022/7/4.
//

#import <MetalKit/MetalKit.h>
#import "YZFilterProtocol.h"

typedef NS_ENUM(NSInteger, TPMTKViewFillMode) {
    TPMTKViewFillModeScaleToFill,       // Same as UIViewContentModeScaleToFill
    TPMTKViewFillModeScaleAspectFit,    // Same as UIViewContentModeScaleAspectFit
    TPMTKViewFillModeScaleAspectFill,   // Same as UIViewContentModeScaleAspectFill
};

@class YZTexture;
@interface TPMTKView : MTKView<YZFilterProtocol>
@property (nonatomic) TPMTKViewFillMode fillMode;

@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) int how;//height/how

- (void)showPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)setBackgroundColorRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha;
@end
