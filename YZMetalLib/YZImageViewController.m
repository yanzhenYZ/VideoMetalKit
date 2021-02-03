//
//  YZImageViewController.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/1/25.
//

#import "YZImageViewController.h"
#import <YZMetalKit/YZImage.h>

@interface YZImageViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) YZImage *image;
@end

@implementation YZImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed:@"123"];
//    NSLog(@"123:%@", image);
//    _image = [[YZImage alloc] initWithImage:image];
//    _image.player = self.view;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [_image processImage];
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];

    imagePickerController.delegate=self;

    //imagePickerController.allowsEditing=YES;

    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
//    NSLog(@"cc:%@:%d", image, image.imageOrientation);
//    [_videoCapture setWatermark:image frame:CGRectMake(0, 0, image.size.width / 10, image.size.height / 10)];
    
    _image = [[YZImage alloc] initWithImage:image];
        _image.player = self.view;
    [_image processImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
