//
//  TwoPicturesViewController.m
//  YZMetalLib
//
//  Created by yanzhen on 2022/7/4.
//

#import "TwoPicturesViewController.h"
#import "TwoPicturesCapture.h"

@interface TwoPicturesViewController ()<TwoPicturesCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIView *player;
@property (weak, nonatomic) IBOutlet UIImageView *smallPlayer;

@property (nonatomic, strong) TwoPicturesCapture *videoCapture;
@property (nonatomic, strong) CIContext *context;
@end

@implementation TwoPicturesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _context = [CIContext contextWithOptions:nil];
    _videoCapture = [[TwoPicturesCapture alloc] initWithSize:CGSizeMake(640, 480)];
    _videoCapture.player = self.player;
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
