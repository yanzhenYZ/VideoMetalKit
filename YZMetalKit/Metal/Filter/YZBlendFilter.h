//
//  YZBlendFilter.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/1/26.
//

#import <UIKit/UIKit.h>
#import "YZMetalFilter.h"

@interface YZBlendFilter : YZMetalFilter
- (void)setWatermark:(UIImage *)image frame:(CGRect)frame;
- (void)processImage;
@end

