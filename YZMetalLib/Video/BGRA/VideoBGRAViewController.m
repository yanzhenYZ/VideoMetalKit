//
//  VideoBGRAViewController.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/2/26.
//

#import "VideoBGRAViewController.h"
#import <YZMetalKit/YZExeternalVideo.h>
#import <YZMetalKit/YZVideoData.h>
#import "VideoBGRACapture.h"

@interface VideoBGRAViewController ()<VideoBGRACaptureDelegate, YZExeternalVideoDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *player;
@property (weak, nonatomic) IBOutlet UIImageView *showView;

@property (nonatomic, strong) VideoBGRACapture *capture;
@property (nonatomic, strong) YZExeternalVideo *externalVideo;

@property (nonatomic, strong) CIContext *context;
@end

@implementation VideoBGRAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _context = [CIContext contextWithOptions:nil];
    
    _externalVideo = [[YZExeternalVideo alloc] init];
    _externalVideo.delegate = self;
    _externalVideo.player = self.showView;
    
    _capture = [[VideoBGRACapture alloc] initWithPlayer:_player];
    _capture.delegate = self;
    [_capture startRunning];
    
}

- (IBAction)exitCapture:(id)sender {
    [_capture stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - YZExeternalVideoDelegate
- (void)video:(YZExeternalVideo *)video pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    //[self showPixelBuffer:pixelBuffer];
}

#pragma mark - VideoBGRACaptureDelegate
-(void)capture:(VideoBGRACapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    //[self showPixelBuffer:pixelBuffer];
    YZVideoData *data = [[YZVideoData alloc] init];
    data.pixelBuffer = pixelBuffer;
#pragma mark - ROTATION__TEST && RRR11
#if 1//不设置AVCaptureConnection视频方向需要设置
    data.rotation = [self getOutputRotation];
#endif
    [_externalVideo inputVideo:data];
}


- (void)showPixelBuffer:(CVPixelBufferRef)pixel {
    CVPixelBufferRetain(pixel);
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:pixel];
    size_t width = CVPixelBufferGetWidth(pixel);
    size_t height = CVPixelBufferGetHeight(pixel);
    CGImageRef videoImageRef = [_context createCGImage:ciImage fromRect:CGRectMake(0, 0, width, height)];
    UIImage *image = [UIImage imageWithCGImage:videoImageRef];
    CGImageRelease(videoImageRef);
    CVPixelBufferRelease(pixel);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.showView.image = image;
    });
}

- (int)getOutputRotation {//test code
    int ratation = 0;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return 90;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return 270;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return 0;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return 180;
            break;
        default:
            break;
    }
    return ratation;
    
}
@end
