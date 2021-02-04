//
//  YZCropFilter.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/4.
//

#import "YZMetalFilter.h"
#import <CoreVideo/CVPixelBuffer.h>
#import <Metal/Metal.h>

@protocol YZCropFilterDelegate <NSObject>
@optional
- (void)outputPixelBuffer:(CVPixelBufferRef)buffer;

@end

@interface YZCropFilter : YZMetalFilter
@property (nonatomic, weak) id<YZCropFilterDelegate> delegate;
@property (nonatomic) CGSize size;

-(instancetype)initWithSize:(CGSize)size;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithVertexFunctionName:(NSString *)vertex fragmentFunctionName:(NSString *)fragment NS_UNAVAILABLE;


- (void)changeSize:(CGSize)size;

- (void)createNewTexture;

@end

