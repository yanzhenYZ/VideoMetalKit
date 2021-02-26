//
//  VideoRangeCapture.h
//  YZMetalLib
//
//  Created by yanzhen on 2021/2/26.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

@protocol VideoRangeCaptureDelegate;
@interface VideoRangeCapture : NSObject
@property (nonatomic, weak) id<VideoRangeCaptureDelegate> delegate;

- (instancetype)initWithPlayer:(UIView *)player;

- (void)startRunning;
- (void)stopRunning;
@end

@protocol VideoRangeCaptureDelegate <NSObject>

- (void)capture:(VideoRangeCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end


