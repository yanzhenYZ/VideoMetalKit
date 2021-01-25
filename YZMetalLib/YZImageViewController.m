//
//  YZImageViewController.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/1/25.
//

#import "YZImageViewController.h"
#import <YZMetalKit/YZMetalKit.h>

@interface YZImageViewController ()
@property (nonatomic, strong) YZImageInput *input;
@end

@implementation YZImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed:@"123"];
//    NSLog(@"123:%@", image);
    _input = [[YZImageInput alloc] initWithImage:image];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_input processImage];
}
@end
