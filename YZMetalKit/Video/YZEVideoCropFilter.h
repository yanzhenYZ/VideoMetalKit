//
//  YZEVideoCropFilter.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/26.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@class YZEVideoView;
@class YZEVideoPixelBuffer;
@interface YZEVideoCropFilter : NSObject

@property (nonatomic, strong) YZEVideoPixelBuffer *pixelBuffer;
@property (nonatomic, strong) YZEVideoView *videoView;

- (void)inputPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end


