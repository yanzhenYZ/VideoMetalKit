//
//  OutputViewController.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/1/25.
//

#import "OutputViewController.h"
#import <YZMetalKit/YZOutputCapture.h>

@interface OutputViewController ()<YZOutputCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIView *showView;
@property (weak, nonatomic) IBOutlet UIImageView *palyer;
@property (nonatomic, strong) CIContext *context;

@property (nonatomic, strong) YZOutputCapture *capture;
@end

@implementation OutputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"output";
    _context = [CIContext contextWithOptions:nil];
    
    
    _capture = [[YZOutputCapture alloc] initWithSize:CGSizeMake(360, 640) front:YES];
    _capture.player = self.showView;
    _capture.fillMode = YZOutputFillModeScaleAspectFit;
    _capture.delegate = self;
    [_capture startRunning];
}

- (IBAction)backT:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchCamera:(UISwitch *)sender {
    _capture.front = sender.isOn;
}

#pragma mark - YZOutputCaptureDelegate
- (void)videoCapture:(YZOutputCapture *)videoCapture decodePixelBuffer:(CVPixelBufferRef)pixelBuffer {
    //[self showPixelBuffer:pixelBuffer];
}

- (void)videoCapture:(YZOutputCapture *)videoCapture outputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    //[self showPixelBuffer:pixelBuffer];
}


- (void)videoCapture:(YZOutputCapture *)videoCapture dropFrames:(int)frames {
    
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
        self.palyer.image = image;
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
