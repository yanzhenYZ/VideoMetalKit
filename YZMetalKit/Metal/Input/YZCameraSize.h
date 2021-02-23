//
//  YZCameraSize.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/22.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

@interface YZCameraSize : NSObject

-(instancetype)initWithSize:(CGSize)size;
- (void)changeSize:(CGSize)size;

@end

