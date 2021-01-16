//
//  ThirdViewController.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/1/16.
//

#import "ThirdViewController.h"
#import <YZMetalKit/YZMetalKit.h>

@interface ThirdViewController ()<YZVideoCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIView *showView;
@property (weak, nonatomic) IBOutlet UIImageView *player;

@property (nonatomic, strong) YZVideoCapture *videoCapture;
@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _videoCapture = [[YZVideoCapture alloc] initWithSize:CGSizeMake(360, 640)];
    _videoCapture.player = self.showView;
    _videoCapture.fillMode = YZVideoFillModeScaleAspectFit;
    _videoCapture.delegate = self;
    [_videoCapture startRunning];
}

- (IBAction)reset:(UISwitch *)sender {
    
}

- (IBAction)back:(id)sender {
    [self.videoCapture stopRunning];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - YZVideoCaptureDelegate
-(void)videoCapture:(YZVideoCapture *)videoCapture outputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    //[self showPixelBuffer:pixelBuffer];
}

-(void)videoCapture:(YZVideoCapture *)videoCapture dropFrames:(int)frames {
    NSLog(@"12344____%d", frames);
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
