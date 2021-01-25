//
//  YZImageViewController.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/1/25.
//

#import "YZImageViewController.h"
#import <YZMetalKit/YZImage.h>

@interface YZImageViewController ()
@property (nonatomic, strong) YZImage *image;
@end

@implementation YZImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed:@"123"];
//    NSLog(@"123:%@", image);
    _image = [[YZImage alloc] initWithImage:image];
    _image.player = self.view;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_image processImage];
}
@end
