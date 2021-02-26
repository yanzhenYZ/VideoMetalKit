//
//  YZEVideoCropFilter.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/26.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@class YZVideoData;
@class YZEVideoPixelBuffer;
@interface YZEVideoCropFilter : NSObject

@property (nonatomic, strong) YZEVideoPixelBuffer *pixelBuffer;

- (void)inputVideo:(YZVideoData *)videoData;
@end


