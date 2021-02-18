//
//  YZFilterCapture.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/18.
//

#import "YZFilterCapture.h"
#import "YZVideoCamera.h"
#import "YZNewCropFilter.h"
#import "YZNewPixelBuffer.h"
#import "YZMTKView.h"
#import "YZBrightness.h"
#import "YZBlendFilter.h"

/**
 //now
 camera --> beauty --> MTKView and Crop
 
 //to do
 2.1.1 camera --> Crop --> beauty --> MTKView
 2.1.2 camera --> Crop --> beauty --> PixelBuffer --> new MTKView
 2.1.3 camera --> Crop --> beauty --> water ? -->  PixelBuffer --> new MTKView
 */


@interface YZFilterCapture ()<YZVideoCameraOutputDelegate>
@property (nonatomic, strong) YZVideoCamera *camera;

@property (nonatomic, strong) YZBrightness *beautyFilter;
@property (nonatomic, strong) YZBlendFilter *blendFilter;
@property (nonatomic, strong) YZMTKView *mtkView;
@property (nonatomic, strong) YZNewCropFilter *cropFilter;
@property (nonatomic, strong) YZNewPixelBuffer *pixelBuffer;
@end

@implementation YZFilterCapture
- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self stopRunning];
}

- (instancetype)initWithSize:(CGSize)size {
    return [self initWithSize:size front:YES];
}

- (instancetype)initWithSize:(CGSize)size front:(BOOL)front {
    self = [super init];
    if (self) {
        _size = size;
        _front = front;
        AVCaptureSessionPreset preset = [self getSessionPreset:size];
        _camera = [[YZVideoCamera alloc] initWithSessionPreset:preset position:_front ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack];
        UIInterfaceOrientation statusBar = [[UIApplication sharedApplication] statusBarOrientation];
        _camera.outputOrientation = statusBar;
        _camera.delegate = self;
        
        _beautyFilter = [[YZBrightness alloc] init];
        [_camera addFilter:_beautyFilter];
        
        _cropFilter = [[YZNewCropFilter alloc] initWithSize:size];
        [_beautyFilter addFilter:_cropFilter];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarDidChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (YZMTKView *)mtkView {
    if (!_mtkView) {
        _mtkView = [[YZMTKView alloc] initWithFrame:CGRectZero];
        _mtkView.fillMode = (YZMTKViewFillMode)_fillMode;
        _mtkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _mtkView;
}
#pragma mark - property
- (void)setPlayer:(UIView *)player {
    if (_player == player) { return; }
    _player = player;
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

-(void)setFillMode:(YZFilterFillMode)fillMode {
    _fillMode = fillMode;
    _mtkView.fillMode = (YZMTKViewFillMode)fillMode;
}

- (void)setSize:(CGSize)size {
    if (!CGSizeEqualToSize(size, _size)) {
        _size = size;
        AVCaptureSessionPreset preset = [self getSessionPreset:size];
        _camera.preset = preset;
        [_cropFilter changeSize:size];
    }
}

- (void)setFront:(BOOL)front {
    if (front != _front) {
        _front = front;
        [_camera switchCamera];
    }
}

- (void)setFrameRate:(int32_t)frameRate {
    _camera.frameRate = frameRate;
}

- (int32_t)frameRate {
    return _camera.frameRate;
}

- (void)setVideoMirrored:(BOOL)videoMirrored {
    _camera.videoMirrored = videoMirrored;
}

- (BOOL)videoMirrored {
    return _camera.videoMirrored;
}

- (void)setBeautyEnable:(BOOL)beautyEnable {
    _beautyFilter.enable = beautyEnable;
}

- (BOOL)beautyEnable {
    return _beautyFilter.enable;
}

- (void)setBeautyLevel:(float)beautyLevel {
    _beautyFilter.beautyLevel = beautyLevel;
}

- (float)beautyLevel {
    return _beautyFilter.beautyLevel;
}

- (void)setBrightLevel:(float)brightLevel {
    _beautyFilter.brightLevel = brightLevel;
}

- (float)brightLevel {
    return _beautyFilter.brightLevel;
}
#pragma mark - camera
- (void)startRunning {
    [_camera startRunning];
}

- (void)stopRunning {
    [_camera stopRunning];
}

-(void)setWatermark:(UIImage *)image frame:(CGRect)frame {
    [_blendFilter setWatermark:image frame:frame];
    [_blendFilter processImage];
}
#pragma mark - YZVideoCameraOutputDelegate
- (void)videoCamera:(YZVideoCamera *)camera dropFrames:(int)frams {
    if ([_delegate respondsToSelector:@selector(videoCapture:dropFrames:)]) {
        [_delegate videoCapture:self dropFrames:frams];
    }
}

//- (void)videoCamera:(YZVideoCamera *)camera output:(CMSampleBufferRef)sampleBuffer {
//
//}

#pragma mark - YZNewPixelBufferDelegate || YZCropFilterDelegate
//- (void)outputPixelBuffer:(CVPixelBufferRef)buffer {
//    if ([_delegate respondsToSelector:@selector(videoCapture:outputPixelBuffer:)]) {
//        [_delegate videoCapture:self outputPixelBuffer:buffer];
//    }
//}

#pragma mark - system note
- (void)statusBarDidChanged:(NSNotification *)note {
    //NSLog(@"UIApplicationDidChangeStatusBarOrientationNotification UserInfo: %@", note.userInfo);
    UIInterfaceOrientation statusBar = [[UIApplication sharedApplication] statusBarOrientation];
    _camera.outputOrientation = statusBar;
}
#pragma mark - private
- (AVCaptureSessionPreset)getSessionPreset:(CGSize)size {
    CGFloat maxWH = MAX(size.width, size.height);
    CGFloat minWH = MIN(size.width, size.height);
    if (maxWH <= 640 && minWH <= 480) {
        return AVCaptureSessionPreset640x480;
    } else if (maxWH <= 960 && minWH <= 540) {
        return AVCaptureSessionPresetiFrame960x540;
    } else if (maxWH <= 1280 && minWH <= 720) {
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
