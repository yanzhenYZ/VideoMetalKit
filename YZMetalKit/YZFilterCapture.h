//
//  YZFilterCapture.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>

typedef NS_ENUM(NSInteger, YZFilterFillMode) {
    YZFilterFillModeScaleToFill,       // Same as UIViewContentModeScaleToFill
    YZFilterFillModeScaleAspectFit,    // Same as UIViewContentModeScaleAspectFit
    YZFilterFillModeScaleAspectFill,   // Same as UIViewContentModeScaleAspectFill
};

@protocol YZFilterCaptureDelegate;
@interface YZFilterCapture : NSObject
/**
 set out size, front is YES
 */
- (instancetype)initWithSize:(CGSize)size front:(BOOL)front;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, weak) id<YZFilterCaptureDelegate> delegate;

/** video player */
@property (nonatomic, strong) UIView *player;
/** video player fillMode*/
@property (nonatomic) YZFilterFillMode fillMode;

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


@protocol YZFilterCaptureDelegate <NSObject>

@optional
- (void)videoCapture:(YZFilterCapture *)videoCapture outputPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)videoCapture:(YZFilterCapture *)videoCapture dropFrames:(int)frames;

@end

