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
    _videoCapture = [[YZVideoCapture alloc] initWithSize:CGSizeMake(360, 640) front:NO];
    _videoCapture.player = self.showView;
    _videoCapture.fillMode = YZVideoFillModeScaleAspectFit;
    _videoCapture.delegate = self;
    [_videoCapture startRunning];
}

- (IBAction)reset:(UISwitch *)sender {
    if (sender.isOn) {
        [self.videoCapture startRunning];
    } else {
        [self.videoCapture stopRunning];
    }
}

- (IBAction)back:(id)sender {
    //直接释放capture
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchShowView:(UISwitch *)sender {
    if (sender.isOn) {
        self.videoCapture.player = _player;
    } else {
        self.videoCapture.player = self.showView;
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.videoCapture.player = self.showView;
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
