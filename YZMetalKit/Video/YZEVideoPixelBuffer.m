//
//  YZEVideoPixelBuffer.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/26.
//

#import "YZEVideoPixelBuffer.h"
#import "YZEVideoView.h"

@implementation YZEVideoPixelBuffer

- (void)inputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if ([_delegate respondsToSelector:@selector(buffer:pixelBuffer:)]) {
        [_delegate buffer:self pixelBuffer:pixelBuffer];
    }
    [_videoView showPixelBuffer:pixelBuffer];
}

@end
