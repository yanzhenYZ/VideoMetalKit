//
//  YZCropSizeFilter.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/4.
//

#import "YZCropSizeFilter.h"
#import "YZMetalOrientation.h"
#import "YZMetalDevice.h"

@interface YZCropSizeFilter ()
@property (nonatomic) CGRect cropRegion;

@end

@implementation YZCropSizeFilter

- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        _cropRegion = CGRectMake(0, 0, 1, 1);
        [self createNewTexture];
    }
    return self;
}

- (void)changeSize:(CGSize)size {
    [YZMetalDevice semaphoreWaitForever];
    self.size = size;
    [self createNewTexture];
    [YZMetalDevice semaphoreSignal];
}

- (void)switchSize:(CGSize)size {
    self.size = CGSizeMake(self.size.height, self.size.width);
    [self calculateCropTextureCoordinates:size];
}

- (void)calculateCropTextureCoordinates:(CGSize)size {
    if (CGSizeEqualToSize(self.size, size)) {
        _cropRegion = CGRectMake(0, 0, 1, 1);
        return;
    }
    CGFloat width = size.width - self.size.width;
    CGFloat x = width / 2 / size.width;
    CGFloat w = 1 - 2 * x;
    
    CGFloat height = size.height - self.size.height;
    CGFloat y = height / 2 / size.height;
    CGFloat h = 1 - 2 * y;
    _cropRegion = CGRectMake(x, y, w, h);
}
#pragma mark - super
- (BOOL)dealTextureSize:(CGSize)size {
    if (size.width > size.height && self.size.width < self.size.height) {//横屏
        [self switchSize:size];
        return YES;
    } else if (size.width < size.height && self.size.height < self.size.width) {
        [self switchSize:size];
        return YES;
    }
    [self calculateCropTextureCoordinates:size];
    return NO;
}

//get rect, 主动改变size
- (simd_float8)getTextureCoordinates {
    if (CGRectEqualToRect(_cropRegion, CGRectMake(0, 0, 1, 1))) {
        return [YZMetalOrientation defaultTextureCoordinates];
    }
    CGFloat minX = _cropRegion.origin.x;
    CGFloat minY = _cropRegion.origin.y;
    CGFloat maxX = CGRectGetMaxX(_cropRegion);
    CGFloat maxY = CGRectGetMaxY(_cropRegion);
    simd_float8 textureCoordinates = {minX, minY, maxX, minY, minX, maxY, maxX, maxY};
    return textureCoordinates;
}
@end
