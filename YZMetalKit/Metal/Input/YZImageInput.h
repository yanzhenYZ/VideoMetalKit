//
//  YZImageInput.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/1/25.
//

#import <UIKit/UIKit.h>
#import "YZMetalOutput.h"

@interface YZImageInput : YZMetalOutput

- (instancetype)initWithImage:(UIImage *)image;
- (void)processImage;
@end


