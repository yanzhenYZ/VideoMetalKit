//
//  YZCameraSize.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/22.
//

#import "YZCameraSize.h"

@interface YZCameraSize ()
@property (nonatomic, assign) CGSize size;
@property (nonatomic) CGRect cropRegion;
@end

@implementation YZCameraSize

-(instancetype)initWithSize:(CGSize)size {
    self = [super init];
    if (self) {
        _size = size;
        _cropRegion = CGRectMake(0, 0, 1, 1);
    }
    return self;
}

- (void)changeSize:(CGSize)size {
    _size = size;
}

- (CGSize)getTextureSizeWithBufferSize:(CGSize)size {
    CGSize calSize = [self getOutputSize:size];
    
    CGFloat width = size.width - self.size.width;
    CGFloat x = width / 2 / size.width;
    CGFloat w = 1 - 2 * x;
    
    CGFloat height = size.height - self.size.height;
    CGFloat y = height / 2 / size.height;
    CGFloat h = 1 - 2 * y;
    _cropRegion = CGRectMake(x, y, w, h);
    
    return calSize;
}

- (simd_float8)getTextureCoordinates:(simd_float8)textureCoordinates {
    return textureCoordinates;
}

#pragma mark - private
- (CGSize)getOutputSize:(CGSize)size {
    if (CGSizeEqualToSize(size, _size)) {
        return size;
    }
    
    if (size.width > size.height && self.size.width < self.size.height) {//横屏
        self.size = CGSizeMake(self.size.height, self.size.width);
    } else if (size.width < size.height && self.size.height < self.size.width) {
        self.size = CGSizeMake(self.size.height, self.size.width);
    }
    if (CGSizeEqualToSize(size, _size)) {
        return size;
    }
    
    CGFloat sizeRatio = _size.width / _size.height;
    CGFloat textureRatio = size.width / size.height;
    if (textureRatio == sizeRatio) {
        return size;
    }
    
    if (sizeRatio > (textureRatio * 1.1) || sizeRatio < (textureRatio * 0.9)) {
        if (textureRatio > sizeRatio) {
            CGFloat outputW = size.width * sizeRatio / textureRatio;
            if (_size.height > size.height) {
                _size = CGSizeMake(outputW / (_size.height / size.height), size.height);
            } else {
                _size = CGSizeMake(outputW, size.height);
            }
        } else {
            CGFloat outoutH = size.height * textureRatio / sizeRatio;
            if (_size.width > size.width) {
                _size = CGSizeMake(size.width, outoutH / (_size.width / size.width));
            } else {
                _size = CGSizeMake(size.width, outoutH);
            }
        }
        return _size;
    }
    return size;
}
@end
