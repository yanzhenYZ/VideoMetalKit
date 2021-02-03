//
//  ThirdViewController.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/1/16.
//

#import "ThirdViewController.h"
#import <YZMetalKit/YZMetalKit.h>

@interface ThirdViewController ()<YZVideoCaptureDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *showView;
@property (weak, nonatomic) IBOutlet UIImageView *player;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayout;

@property (nonatomic, strong) YZVideoCapture *videoCapture;
@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed:@"test3"];
    NSLog(@"99:%@", image);
    _videoCapture = [[YZVideoCapture alloc] initWithSize:CGSizeMake(360, 640) front:NO];
    _videoCapture.player = self.showView;
    _videoCapture.fillMode = YZVideoFillModeScaleAspectFit;
    _videoCapture.delegate = self;
    
//    [_videoCapture setWatermark:image frame:CGRectMake(0, 0, 100, 71)];
    
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

//
- (IBAction)bottomStepper:(UIStepper *)sender {
    _bottomLayout.constant = sender.value;
}

- (IBAction)rightStepper:(UIStepper *)sender {
    _leftLayout.constant = sender.value;
}

- (IBAction)addNewPicture:(UIButton *)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];

    imagePickerController.delegate=self;

    //imagePickerController.allowsEditing=YES;

    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:imagePickerController animated:YES completion:nil];
   
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSLog(@"cc:%@:%d", image, image.imageOrientation);
    [_videoCapture setWatermark:image frame:CGRectMake(0, 0, image.size.width / 10, image.size.height / 10)];
    [picker dismissViewControllerAnimated:YES completion:nil];
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
