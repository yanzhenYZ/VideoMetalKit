//
//  TwoPicturesViewController.m
//  YZMetalLib
//
//  Created by yanzhen on 2022/7/4.
//

#import "TwoPicturesViewController.h"
#import "TwoPicturesCapture.h"

@interface TwoPicturesViewController ()<TwoPicturesCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *player;
@property (weak, nonatomic) IBOutlet UIImageView *smallPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *smallPlayer2;

@property (nonatomic, strong) TwoPicturesCapture *videoCapture;
@property (nonatomic, strong) CIContext *context;
@end

@implementation TwoPicturesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _context = [CIContext contextWithOptions:nil];
    _videoCapture = [[TwoPicturesCapture alloc] initWithSize:CGSizeMake(640, 480)];
    _videoCapture.player = self.smallPlayer;
    _videoCapture.player2 = self.smallPlayer2;
    _videoCapture.fillMode = YZTPVideoFillModeScaleAspectFit;
    _videoCapture.delegate = self;
    [_videoCapture startRunning];
    
}

- (IBAction)backTo:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchAction:(UISwitch *)sender {
}




#pragma mark - TwoPicturesCaptureDelegate
- (void)videoCapture:(TwoPicturesCapture *)videoCapture outputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
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
