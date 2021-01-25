//
//  YZImage.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/1/25.
//

#import <UIKit/UIKit.h>

@interface YZImage : NSObject

- (instancetype)initWithImage:(UIImage *)image;
- (void)processImage;

/** video player */
@property (nonatomic, strong) UIView *player;
@end


