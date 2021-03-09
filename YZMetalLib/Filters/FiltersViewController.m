//
//  FiltersViewController.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/2/18.
//

#import "FiltersViewController.h"
#import <YZMetalKit/YZMetalKit.h>

@interface FiltersViewController ()<YZFilterCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIView *player;
@property (weak, nonatomic) IBOutlet UIImageView *smallPlayer;


@property (nonatomic, strong) YZFilterCapture *capture;
@property (nonatomic, strong) CIContext *context;
@end

@implementation FiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _context = [CIContext contextWithOptions:nil];
    //1280x720
    //840x480 7x4  180x7=1260
    _capture = [[YZFilterCapture alloc] initWithSize:CGSizeMake(960, 720) front:YES];
    _capture.fillMode = YZFilterFillModeScaleAspectFit;
    _capture.player = self.player;
    _capture.delegate = self;
    [_capture startRunning];
}

- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark - YZFilterCaptureDelegate
-(void)videoCapture:(YZFilterCapture *)videoCapture outputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [self showPixelBuffer:pixelBuffer];
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
    NSLog(@"width:%d:%d", width, height);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.smallPlayer.image = image;
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
