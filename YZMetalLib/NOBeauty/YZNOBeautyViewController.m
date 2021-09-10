//
//  YZNOBeautyViewController.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/2/4.
//

#import "YZNOBeautyViewController.h"
#import <YZMetalKit/YZMetalKit.h>
#import "YZTestBeautyManager.h"

@interface YZNOBeautyViewController ()<YZNOBeautyCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIView *player;
@property (weak, nonatomic) IBOutlet UIImageView *smallPlayer;

@property (nonatomic, strong) YZNOBeautyCapture *videoCapture;
@property (nonatomic, strong) CIContext *context;

@property (nonatomic, strong) YZTestBeautyManager *manager;
@end

@implementation YZNOBeautyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _context = [CIContext contextWithOptions:nil];
    _videoCapture = [[YZNOBeautyCapture alloc] initWithSize:CGSizeMake(480, 480)];
    _videoCapture.player = self.player;
//    _videoCapture.fillMode = YZVideoFillModeScaleAspectFit;
    _videoCapture.delegate = self;
    [_videoCapture startRunning];
    
    _manager = [[YZTestBeautyManager alloc] init];
}

- (IBAction)switchNo:(UISwitch *)sender {
    
}

- (IBAction)backTo:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - YZNOBeautyCaptureDelegate
-(void)videoCapture:(YZNOBeautyCapture *)videoCapture outputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
//    [_manager dealPixelBuffer:pixelBuffer];
//    [self showPixelBuffer:pixelBuffer];
}

- (void)videoCapture:(YZNOBeautyCapture *)videoCapture snapImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.smallPlayer.image = image;
    });
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
