//
//  YZNewCropFilter.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/18.
//

#import "YZNewCropFilter.h"

@interface YZNewCropFilter ()
@property (nonatomic) CGSize size;
@end

@implementation YZNewCropFilter
- (instancetype)initWithSize:(CGSize)size {
    self = [super init];
    if (self) {
        _size = size;
    }
    return self;
}

-(void)newTextureAvailable:(id<MTLTexture>)texture {
    [super newTextureAvailable:texture];
}

-(void)changeSize:(CGSize)size {
    
}
@end
