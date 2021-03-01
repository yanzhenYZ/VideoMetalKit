//
//  YZEVideoPixelBuffer.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/26.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CVPixelBuffer.h>
#import <Metal/Metal.h>

@class YZEVideoView;
@protocol YZEVideoPixelBufferDelegate;
@interface YZEVideoPixelBuffer : NSObject
@property (nonatomic, weak) id<YZEVideoPixelBufferDelegate> delegate;
@property (nonatomic, strong) YZEVideoView *videoView;
//default is yes
@property (nonatomic, assign) BOOL renderFirst;//先渲染，后输出

- (void)newTextureAvailable:(id<MTLTexture>)texture;
- (void)inputBGRAPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)inputYUVPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end

@protocol YZEVideoPixelBufferDelegate <NSObject>

- (void)buffer:(YZEVideoPixelBuffer *)buffer pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
