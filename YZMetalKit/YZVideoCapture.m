//
//  YZVideoCapture.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/1/9.
//

#import "YZVideoCapture.h"
#import "YZVideoCamera.h"
#import "YZNewPixelBuffer.h"
#import "YZMTKView.h"
#import "YZBrightness.h"

@interface YZVideoCapture ()<YZVideoCameraOutputDelegate, YZNewPixelBufferDelegate>
@property (nonatomic, strong) YZVideoCamera *camera;
@property (nonatomic, strong) YZBrightness *beautyFilter;
@property (nonatomic, strong) YZMTKView *mtkView;
@property (nonatomic, strong) YZNewPixelBuffer *pixelBuffer;
@end

@implementation YZVideoCapture
- (instancetype)initWithSize:(CGSize)size {
    return [self initWithSize:size front:YES];
}

- (instancetype)initWithSize:(CGSize)size front:(BOOL)front {
    self = [super init];
    if (self) {
        _size = size;
        _frameRate = 15;
        _front = front;
        AVCaptureSessionPreset preset = [self getSessionPreset:size];
        _camera = [[YZVideoCamera alloc] initWithSessionPreset:preset position:_front ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack];
        _camera.delegate = self;
        _beautyFilter = [[YZBrightness alloc] init];
        _pixelBuffer = [[YZNewPixelBuffer alloc] initWithSize:_size];
        _pixelBuffer.delegate = self;
        
        [_camera addFilter:_beautyFilter];
        [_beautyFilter addFilter:_pixelBuffer];
    }
    return self;
}

- (YZMTKView *)mtkView {
    if (!_mtkView) {
        _mtkView = [[YZMTKView alloc] initWithFrame:CGRectZero];
        _mtkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _mtkView;
}
#pragma mark - property
- (void)setPlayer:(UIView *)player {
    if (_player == player) { return; }
    [self mainThreadAction:^{
        if (player) {
            [self.mtkView removeFromSuperview];
            self.mtkView.frame = player.bounds;
            [player addSubview:self.mtkView];
            [self.beautyFilter addFilter:self.mtkView];
        } else {
            [self.mtkView removeFromSuperview];
            [self.beautyFilter removeFilter:self.mtkView];
        }
    }];
}

-(void)setFillMode:(YZVideoFillMode)fillMode {
    _fillMode = fillMode;
    _mtkView.fillMode = (YZMTKViewFillMode)fillMode;
}

- (void)setSize:(CGSize)size {
    if (!CGSizeEqualToSize(size, _size)) {
        _size = size;
        AVCaptureSessionPreset preset = [self getSessionPreset:size];
        _camera.preset = preset;
    }
}

- (void)setFront:(BOOL)front {
    if (front != _front) {
        _front = front;
        [_camera switchCamera];
    }
}
#pragma mark - camera
- (void)startRunning {
    [_camera startRunning];
}

- (void)stopRunning {
    [_camera stopRunning];
}


#pragma mark - YZVideoCameraOutputDelegate

#pragma mark - YZNewPixelBufferDelegate
- (void)outputPixelBuffer:(CVPixelBufferRef)buffer {
    if ([_delegate respondsToSelector:@selector(videoCapture:outputPixelBuffer:)]) {
        [_delegate videoCapture:self outputPixelBuffer:buffer];
    }
}

#pragma mark - private
- (AVCaptureSessionPreset)getSessionPreset:(CGSize)size {
    CGFloat maxWH = MAX(size.width, size.height);
    CGFloat minWH = MIN(size.width, size.height);
    if (maxWH <= 640 && minWH < 480) {
        return AVCaptureSessionPreset640x480;
    } else if (maxWH <= 960 && maxWH <= 540) {
        return AVCaptureSessionPresetiFrame960x540;
    } else if (maxWH <= 1280 && maxWH <= 720) {
        return AVCaptureSessionPreset1280x720;
    } 
    return AVCaptureSessionPreset1920x1080;
}

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
