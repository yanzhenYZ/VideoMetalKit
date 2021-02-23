//
//  YZCameraSize.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/22.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#import <simd/simd.h>

@interface YZCameraSize : NSObject

- (instancetype)initWithSize:(CGSize)size;
- (void)changeSize:(CGSize)size;

- (CGSize)getTextureSizeWithBufferSize:(CGSize)size;
- (CGRect)getCropRegion;
//- (simd_float8)getTextureCoordinates:(simd_float8)textureCoordinates;
@end

