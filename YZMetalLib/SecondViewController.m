//
//  SecondViewController.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/1/9.
//

#import "SecondViewController.h"
#import <YZMetalKit/YZMetalKit.h>

@interface SecondViewController ()<YZVideoCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIView *showView;
@property (weak, nonatomic) IBOutlet UIImageView *player;
@property (nonatomic, strong) YZVideoCapture *videoCapture;
@property (nonatomic, strong) CIContext *context;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _context = [CIContext contextWithOptions:nil];
    _videoCapture = [[YZVideoCapture alloc] initWithSize:CGSizeMake(360, 640)];
    _videoCapture.player = self.showView;
    _videoCapture.fillMode = YZVideoFillModeScaleAspectFit;
    _videoCapture.delegate = self;
    [_videoCapture startRunning];
    
    //[self.view bringSubviewToFront:self.player];
    
}

- (IBAction)sizeChange:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        _videoCapture.size = CGSizeMake(480, 640);
    } else if (sender.selectedSegmentIndex == 1) {
        _videoCapture.size = CGSizeMake(960, 540);
    } else if (sender.selectedSegmentIndex == 2) {
        _videoCapture.size = CGSizeMake(720, 1280);
    } else if (sender.selectedSegmentIndex == 3) {
        _videoCapture.size = CGSizeMake(1080, 1920);
        //_videoCapture.size = CGSizeMake(360, 640);
    }
}


#pragma mark - YZVideoCaptureDelegate
-(void)videoCapture:(YZVideoCapture *)videoCapture outputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [self showPixelBuffer:pixelBuffer];
}

- (void)showPixelBuffer:(CVPixelBufferRef)pixel {
    CVPixelBufferRetain(pixel);
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:pixel];
    size_t width = CVPixelBufferGetWidth(pixel);
    size_t height = CVPixelBufferGetHeight(pixel);
//    NSLog(@"XX___%d:%d", width, height);
    CGImageRef videoImageRef = [_context createCGImage:ciImage fromRect:CGRectMake(0, 0, width, height)];
    UIImage *image = [UIImage imageWithCGImage:videoImageRef];
    CGImageRelease(videoImageRef);
    CVPixelBufferRelease(pixel);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.player.image = image;
    });
}

#pragma mark - system
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}
@end
