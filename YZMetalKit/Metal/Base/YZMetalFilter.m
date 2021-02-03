//
//  YZMetalFilter.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/1/8.
//

#import "YZMetalFilter.h"

@interface YZMetalFilter ()

@end

@implementation YZMetalFilter

-(instancetype)init {
    return [super initWithVertexFunctionName:@"YZInputVertex" fragmentFunctionName:@"YZFragment"];
}

#pragma mark - YZFilterProtocol
-(void)newTextureAvailable:(id<MTLTexture>)texture {
    [self.allFilters enumerateObjectsUsingBlock:^(id<YZFilterProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj newTextureAvailable:texture];
    }];
}
@end
