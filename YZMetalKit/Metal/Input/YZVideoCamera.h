//
//  YZVideoCamera.h
//  YZMetalLib
//
//  Created by yanzhen on 2020/12/9.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "YZMetalOutput.h"

@class YZVideoCamera;
@protocol YZVideoCameraOutputDelegate <NSObject>
@optional
- (void)videoCamera:(YZVideoCamera *)camera output:(CMSampleBufferRef)sampleBuffer;
- (void)videoCamera:(YZVideoCamera *)camera dropFrames:(int)frams;
@end

@interface YZVideoCamera : YZMetalOutput//use filter
@property (nonatomic, weak) id<YZVideoCameraOutputDelegate> delegate;
/** default is 15, you can set (0,60), some device not support 60 */
@property (nonatomic, assign) int32_t frameRate;
@property (nonatomic, copy) AVCaptureSessionPreset preset;

/** default is UIInterfaceOrientationPortrait */
@property (nonatomic) UIInterfaceOrientation outputOrientation;

/**
 default is YES.
 Only use for AVCaptureDevicePositionFront
 */
@property (nonatomic) BOOL videoMirrored;

- (instancetype)initWithSessionPreset:(AVCaptureSessionPreset)preset;
- (instancetype)initWithSessionPreset:(AVCaptureSessionPreset)preset position:(AVCaptureDevicePosition)position;

- (instancetype)initWithVertexFunctionName:(NSString *)vertex fragmentFunctionName:(NSString *)fragment NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;


- (void)startRunning;
- (void)stopRunning;

- (void)switchCamera;

- (void)scale:(BOOL)scale size:(CGSize)size;
- (void)changeScaleSize:(CGSize)size;
@end

