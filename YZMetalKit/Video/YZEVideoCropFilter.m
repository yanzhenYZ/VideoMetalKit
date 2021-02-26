//
//  YZEVideoCropFilter.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/26.
//

#import "YZEVideoCropFilter.h"
#import "YZEVideoPixelBuffer.h"
#import "YZEVideoView.h"

@implementation YZEVideoCropFilter
- (void)inputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [self.videoView showPixelBuffer:pixelBuffer];
    if ([_pixelBuffer.delegate respondsToSelector:@selector(buffer:pixelBuffer:)]) {
        [_pixelBuffer.delegate buffer:_pixelBuffer pixelBuffer:pixelBuffer];
    }
}
@end
