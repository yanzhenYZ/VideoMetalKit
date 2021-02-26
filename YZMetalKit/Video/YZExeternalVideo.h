//
//  YZExeternalVideo.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YZExeternalVideoFillMode) {
    YZExeternalVideoFillModeScaleToFill,       // Same as UIViewContentModeScaleToFill
    YZExeternalVideoFillModeScaleAspectFit,    // Same as UIViewContentModeScaleAspectFit
    YZExeternalVideoFillModeScaleAspectFill,   // Same as UIViewContentModeScaleAspectFill
};

@class YZVideoData;
@protocol YZExeternalVideoDelegate;
@interface YZExeternalVideo : NSObject

@property (nonatomic, weak) id<YZExeternalVideoDelegate> delegate;
@property (nonatomic) YZExeternalVideoFillMode fillMode;

@property (nonatomic, weak) UIView *player;

- (void)inputVideo:(YZVideoData *)videoData;

@end

@protocol YZExeternalVideoDelegate <NSObject>

- (void)video:(YZExeternalVideo *)video pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

