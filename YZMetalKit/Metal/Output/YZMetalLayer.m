//
//  YZMetalLayer.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/24.
//

#import "YZMetalLayer.h"

@implementation YZMetalLayer
-(void)layoutSublayers {
    [super layoutSublayers];
    NSLog(@"123456:%@", NSThread.mainThread);
}
@end
