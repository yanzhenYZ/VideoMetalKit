//
//  YZOutputCapture.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/1/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>

typedef NS_ENUM(NSInteger, YZOutputFillMode) {
    YZOutputFillModeScaleToFill,       // Same as UIViewContentModeScaleToFill
    YZOutputFillModeScaleAspectFit,    // Same as UIViewContentModeScaleAspectFit
    YZOutputFillModeScaleAspectFill,   // Same as UIViewContentModeScaleAspectFill
};

@protocol YZOutputCaptureDelegate;
@interface YZOutputCapture : NSObject
/**
 set out size, front is YES
 */
- (instancetype)initWithSize:(CGSize)size;
- (instancetype)initWithSize:(CGSize)size front:(BOOL)front;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, weak) id<YZOutputCaptureDelegate> delegate;

/** video player */
@property (nonatomic, strong) UIView *player;
/** video player fillMode*/
@property (nonatomic) YZOutputFillMode fillMode;

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


@protocol YZOutputCaptureDelegate <NSObject>

@optional
- (void)videoCapture:(YZOutputCapture *)videoCapture outputPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)videoCapture:(YZOutputCapture *)videoCapture decodePixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)videoCapture:(YZOutputCapture *)videoCapture dropFrames:(int)frames;

@end


