//
//  TwoPicturesCapture.h
//  YZMetalKit
//
//  Created by yanzhen on 2022/7/4.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>

typedef NS_ENUM(NSInteger, YZTPVideoFillMode) {
    YZTPVideoFillModeScaleToFill,       // Same as UIViewContentModeScaleToFill
    YZTPVideoFillModeScaleAspectFit,    // Same as UIViewContentModeScaleAspectFit
    YZTPVideoFillModeScaleAspectFill,   // Same as UIViewContentModeScaleAspectFill
};

@protocol TwoPicturesCaptureDelegate;
@interface TwoPicturesCapture : NSObject
/**
 set out size, front is YES
 */
- (instancetype)initWithSize:(CGSize)size;
- (instancetype)initWithSize:(CGSize)size front:(BOOL)front;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, weak) id<TwoPicturesCaptureDelegate> delegate;

/** video player */
@property (nonatomic, strong) UIView *player;
@property (nonatomic, strong) UIView *player2;
/** video player fillMode*/
@property (nonatomic) YZTPVideoFillMode fillMode;

/** output size */
@property (nonatomic, assign) CGSize size;
/** YES: AVCaptureDevicePositionFront, NO: AVCaptureDevicePositionBack */
@property (nonatomic, assign) BOOL front;
/** default is 15, you can set (0,60), some device not support 60 */
@property (nonatomic, assign) int32_t frameRate;
/**
 default is YES.
 Only use for AVCaptureDevicePositionFront
 */
@property (nonatomic) BOOL videoMirrored;

/** default is YES */
@property (nonatomic, assign) BOOL beautyEnable;
/** default is 0.5 */
@property (nonatomic, assign) float beautyLevel;
/** default is 0.5 */
@property (nonatomic, assign) float brightLevel;

/** start video capture */
- (void)startRunning;
/** stop video capture */
- (void)stopRunning;

- (void)setWatermark:(UIImage *)image frame:(CGRect)frame;

@end


@protocol TwoPicturesCaptureDelegate <NSObject>

@optional
- (void)videoCapture:(TwoPicturesCapture *)videoCapture outputPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)videoCapture:(TwoPicturesCapture *)videoCapture dropFrames:(int)frames;

@end


