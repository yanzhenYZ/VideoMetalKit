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
@property (weak, nonatomic) IBOutlet UISegmentedControl *waterMarkSegment;


@property (nonatomic, strong) YZFilterCapture *capture;
@property (nonatomic, strong) CIContext *context;
@end

@implementation FiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _waterMarkSegment.selectedSegmentIndex = 2;
    
    _context = [CIContext contextWithOptions:nil];
    //1280x720
    //840x480 7x4  180x7=1260
    _capture = [[YZFilterCapture alloc] initWithSize:CGSizeMake(360, 640) front:NO];
    _capture.fillMode = YZFilterFillModeScaleAspectFit;
    _capture.player = self.player;
    _capture.delegate = self;
    _capture.scale = YES;
    _capture.videoMirrored = NO;
    [_capture startRunning];
}

- (IBAction)segmentAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        UIImage *image = [UIImage imageNamed:@"test3"];
        [_capture setWatermark:image frame:CGRectMake(0, 0, 100, 71)];
    } else if (sender.selectedSegmentIndex == 1) {
        UIImage *image = [UIImage imageNamed:@"123"];
        [_capture setWatermark:image frame:CGRectMake(190, 0, 200, 200)];
    } else if (sender.selectedSegmentIndex == 2) {
        [_capture clearWatermark];
    }
}

- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _capture.size = CGSizeMake(960, 540);
    //_capture.player = self.player;
    
}

#pragma mark - YZFilterCaptureDelegate
-(void)videoCapture:(YZFilterCapture *)videoCapture outputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
//    [self showPixelBuffer:pixelBuffer];
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
