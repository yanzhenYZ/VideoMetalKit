//
//  YZNewCropFilter.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/18.
//

#import "YZMetalFilter.h"
#import <CoreVideo/CVPixelBuffer.h>
#import <Metal/Metal.h>

@interface YZNewCropFilter : YZMetalFilter

-(instancetype)initWithSize:(CGSize)size;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithVertexFunctionName:(NSString *)vertex fragmentFunctionName:(NSString *)fragment NS_UNAVAILABLE;


- (void)changeSize:(CGSize)size;

@end

