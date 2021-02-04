//
//  YZCropSizeFilter.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/4.
//

#import "YZCropSizeFilter.h"
#import "YZMetalOrientation.h"

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

#pragma mark - super
- (BOOL)dealTextureSize:(CGSize)size {
    if (size.width > size.height && self.size.width < self.size.height) {//横屏
        self.size = CGSizeMake(self.size.height, self.size.width);
        return YES;
    } else if (size.width < size.height && self.size.height < self.size.width) {
        self.size = CGSizeMake(self.size.height, self.size.width);
        return YES;
    }
    return NO;
}

- (simd_float8)getTextureCoordinates {
    return [YZMetalOrientation defaultTextureCoordinates];
}
@end
