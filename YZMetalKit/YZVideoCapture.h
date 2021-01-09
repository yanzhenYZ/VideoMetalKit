//
//  YZVideoCapture.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/1/9.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@class YZVideoCapture;
@protocol YZVideoCaptureDelegate <NSObject>

@optional
- (void)videoCapture:(YZVideoCapture *)videoCapture outputPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

@interface YZVideoCapture : NSObject
/**
 set out size, front is YES
 */
- (instancetype)initWithSize:(CGSize)size;
- (instancetype)initWithSize:(CGSize)size front:(BOOL)front;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, weak) id<YZVideoCaptureDelegate> delegate;
@property (nonatomic, weak) UIView *player;
/** output size */
@property (nonatomic, assign) CGSize size;
/** YES: AVCaptureDevicePositionFront, NO: AVCaptureDevicePositionBack */
@property (nonatomic, assign) BOOL front;
/** default is 15 */
@property (nonatomic, assign) int32_t frameRate;
/**
 default is YES.
 Only use for AVCaptureDevicePositionFront
 */
@property (nonatomic) BOOL videoMirrored;

/** default is YES */
@property (nonatomic, assign) BOOL enable;
/** default is 0.5 */
@property (nonatomic, assign) float beautyLevel;
/** default is 0.5 */
@property (nonatomic, assign) float brightLevel;

/** start video capture */
- (void)startRunning;
/** stop video capture */
- (void)stopRunning;

@end


