//
//  YZNewMTKView.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/19.
//

#import <MetalKit/MetalKit.h>
#import "YZFilterProtocol.h"

typedef NS_ENUM(NSInteger, YZNewMTKViewFillMode) {
    YZNewMTKViewFillModeScaleToFill,       // Same as UIViewContentModeScaleToFill
    YZNewMTKViewFillModeScaleAspectFit,    // Same as UIViewContentModeScaleAspectFit
    YZNewMTKViewFillModeScaleAspectFill,   // Same as UIViewContentModeScaleAspectFill
};

@interface YZNewMTKView : MTKView
@property (nonatomic) YZNewMTKViewFillMode fillMode;

- (void)showPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)setBackgroundColorRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha;
@end


