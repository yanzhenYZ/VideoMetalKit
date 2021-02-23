//
//  YZCameraSize.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/22.
//

#import "YZCameraSize.h"

@interface YZCameraSize ()
@property (nonatomic, assign) CGSize size;
@end

@implementation YZCameraSize

-(instancetype)initWithSize:(CGSize)size {
    self = [super init];
    if (self) {
        _size = size;
    }
    return self;
}

- (void)changeSize:(CGSize)size {
    _size = size;
}
@end
