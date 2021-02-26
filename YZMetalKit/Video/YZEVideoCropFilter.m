//
//  YZEVideoCropFilter.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/26.
//

#import "YZEVideoCropFilter.h"
#import "YZEVideoPixelBuffer.h"

@implementation YZEVideoCropFilter
- (void)inputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [_pixelBuffer inputPixelBuffer:pixelBuffer];
}
@end
