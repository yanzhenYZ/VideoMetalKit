//
//  VideoAllViewController.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/2/26.
//

#import "VideoAllViewController.h"

@interface VideoAllViewController ()

@end

@implementation VideoAllViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self performSegueWithIdentifier:@"VideoSSS" sender:nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

@end
