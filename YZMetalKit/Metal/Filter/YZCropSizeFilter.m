//
//  YZCropSizeFilter.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/4.
//

#import "YZCropSizeFilter.h"

@interface YZCropSizeFilter ()
@property (nonatomic) CGSize lastTextureSize;
@end

@implementation YZCropSizeFilter

- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        [self createNewTexture];
    }
    return self;
}

- (void)changeSize {
    NSLog(@"xxx:%f:%f", self.size.width, self.size.height);
    self.size = CGSizeMake(self.size.height, self.size.width);
    [self createNewTexture];
}

#pragma mark - super
- (void)dealTextureSize:(CGSize)size {
    if (size.width > size.height && self.size.width < self.size.height) {//横屏
        [self changeSize];
    } else if (size.width < size.height && self.size.height < self.size.width) {
        [self changeSize];
    }
}
@end
