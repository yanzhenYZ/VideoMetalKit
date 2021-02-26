//
//  YZEVideoView.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/26.
//

#import <MetalKit/MetalKit.h>

typedef NS_ENUM(NSInteger, YZEVideoViewFillMode) {
    YZEVideoViewFillModeScaleToFill,       // Same as UIViewContentModeScaleToFill
    YZEVideoViewFillModeScaleAspectFit,    // Same as UIViewContentModeScaleAspectFit
    YZEVideoViewFillModeScaleAspectFill,   // Same as UIViewContentModeScaleAspectFill
};

@interface YZEVideoView : MTKView
@property (nonatomic) YZEVideoViewFillMode fillMode;

- (void)showPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end


