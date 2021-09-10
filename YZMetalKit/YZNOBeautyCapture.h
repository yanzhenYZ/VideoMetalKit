//
//  YZNOBeautyCapture.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/4.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIView.h>

@protocol YZNOBeautyCaptureDelegate;
@interface YZNOBeautyCapture : NSObject
/**
 set out size, front is YES
 */
- (instancetype)initWithSize:(CGSize)size;
- (instancetype)initWithSize:(CGSize)size front:(BOOL)front;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, weak) id<YZNOBeautyCaptureDelegate> delegate;

/** video player */
@property (nonatomic, strong) UIView *player;
/** video player fillMode*/
//@property (nonatomic) YZVideoFillMode fillMode;

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

/** start video capture */
- (void)startRunning;
/** stop video capture */
- (void)stopRunning;

@end


@protocol YZNOBeautyCaptureDelegate <NSObject>

@optional
- (void)videoCapture:(YZNOBeautyCapture *)videoCapture outputPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)videoCapture:(YZNOBeautyCapture *)videoCapture dropFrames:(int)frames;
- (void)videoCapture:(YZNOBeautyCapture *)videoCapture snapImage:(UIImage *)image;
@end



