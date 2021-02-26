//
//  YZExeternalVideo.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/26.
//

#import "YZExeternalVideo.h"
#import "YZEVideoPixelBuffer.h"
#import "YZEVideoCropFilter.h"
#import "YZEVideoView.h"
#import "YZVideoData.h"

@interface YZExeternalVideo ()<YZEVideoPixelBufferDelegate>
@property (nonatomic, strong) YZEVideoCropFilter *cropFilter;
@property (nonatomic, strong) YZEVideoPixelBuffer *pixelBuffer;
@property (nonatomic, strong) YZEVideoView *videoView;
@end

@implementation YZExeternalVideo

- (YZEVideoView *)videoView {
    if (!_videoView) {
        _videoView = [[YZEVideoView alloc] initWithFrame:CGRectZero];
        //_mtkView.fillMode = (YZNewMTKViewFillMode)_fillMode;
        _videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _videoView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cropFilter = [[YZEVideoCropFilter alloc] init];
        _pixelBuffer = [[YZEVideoPixelBuffer alloc] init];
        _pixelBuffer.delegate = self;
        _cropFilter.pixelBuffer = _pixelBuffer;
        //_videoView = [[YZEVideoView alloc] init];
    }
    return self;
}

- (void)inputVideo:(YZVideoData *)videoData {
    if (videoData.pixelBuffer) {
        [_cropFilter inputPixelBuffer:videoData.pixelBuffer];
    } else {
        
    }
}

- (void)setPlayer:(UIView *)player {
    if (_player == player) { return; }
    _player = player;
    [self mainThreadAction:^{
        if (player) {
            [self.videoView removeFromSuperview];
            self.videoView.frame = player.bounds;
            [player addSubview:self.videoView];
            self.cropFilter.videoView = self.videoView;
        } else {
            [self.videoView removeFromSuperview];
            self.cropFilter.videoView = nil;
        }
    }];
}

#pragma mark - YZEVideoPixelBufferDelegate
- (void)buffer:(YZEVideoPixelBuffer *)buffer pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if ([_delegate respondsToSelector:@selector(video:pixelBuffer:)]) {
        [_delegate video:self pixelBuffer:pixelBuffer];
    }
}

#pragma mark - helper
- (void)mainThreadAction:(void(^)(void))block {
    if (NSThread.isMainThread) {
        if (block) {
            block();
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
@end