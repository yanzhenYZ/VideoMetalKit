//
//  YZNewCropFilter.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/18.
//

#import "YZMetalFilter.h"
#import <CoreVideo/CVPixelBuffer.h>
#import <Metal/Metal.h>

@protocol YZNewCropFilterDelegate <NSObject>
@optional
- (void)outputPixelBuffer:(CVPixelBufferRef)buffer;

@end

@interface YZNewCropFilter : YZMetalFilter
@property (nonatomic, weak) id<YZNewCropFilterDelegate> delegate;
@property (nonatomic) CGSize size;

-(instancetype)initWithSize:(CGSize)size;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithVertexFunctionName:(NSString *)vertex fragmentFunctionName:(NSString *)fragment NS_UNAVAILABLE;


- (void)changeSize:(CGSize)size;

@end

