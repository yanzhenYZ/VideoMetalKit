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
- (instancetype)initWithSize:(CGSize)size
{
    return [self initWithSize:size front:YES];
}

- (instancetype)initWithSize:(CGSize)size front:(BOOL)front {
    self = [super init];
    if (self) {
        _size = size;
        _frameRate = 15;
        _front = front;
        _camera = [[YZVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 position:_front ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack];
        _camera.delegate = self;
        _beautyFilter = [[YZBrightness alloc] init];
        _pixelBuffer = [[YZNewPixelBuffer alloc] initWithSize:_size];
        _pixelBuffer.delegate = self;
        
        [_camera addFilter:_beautyFilter];
        [_beautyFilter addFilter:_pixelBuffer];
    }
    return self;
}
#pragma mark - property
- (void)setSize:(CGSize)size {
    if (CGSizeEqualToSize(size, _size)) {
        return;
    }
    _size = size;
    
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
@end
