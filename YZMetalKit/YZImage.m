//
//  YZImage.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/1/25.
//

#import "YZImage.h"
#import "YZImageInput.h"
#import "YZMTKView.h"

@interface YZImage ()
@property (nonatomic, strong) YZImageInput *input;
@property (nonatomic, strong) YZMTKView *mtkView;
@end

@implementation YZImage
- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _input = [[YZImageInput alloc] initWithImage:image];
    }
    return self;
}

- (void)processImage {
    [_input processImage];
}

- (void)setPlayer:(UIView *)player {
    if (_player == player) { return; }
    _player = player;
    [self mainThreadAction:^{
        if (player) {
            [self.mtkView removeFromSuperview];
            self.mtkView.frame = player.bounds;
            [player addSubview:self.mtkView];
            [self.input addFilter:self.mtkView];
        } else {
            [self.mtkView removeFromSuperview];
            [self.input removeFilter:self.mtkView];
        }
    }];
}

- (YZMTKView *)mtkView {
    if (!_mtkView) {
        _mtkView = [[YZMTKView alloc] initWithFrame:CGRectZero];
        _mtkView.fillMode = YZMTKViewFillModeScaleAspectFit;
        _mtkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _mtkView;
}

- (void)mainThreadAction:(void(^)(void))block {
    if (NSThread.isMainThread) {
        if (block) {
            block();
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
@end
