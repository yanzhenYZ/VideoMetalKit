//
//  YZNewPixelBuffer.h
//  YZMetalLib
//
//  Created by yanzhen on 2021/1/8.
//

#import "YZMetalFilter.h"
#import <CoreVideo/CVPixelBuffer.h>
#import <Metal/Metal.h>

@protocol YZNewPixelBufferDelegate <NSObject>
@optional
- (void)outputPixelBuffer:(CVPixelBufferRef)buffer;

@end

@interface YZNewPixelBuffer : YZMetalFilter
@property (nonatomic, weak) id<YZNewPixelBufferDelegate> delegate;

- (instancetype)initWithVertexFunctionName:(NSString *)vertex fragmentFunctionName:(NSString *)fragment NS_UNAVAILABLE;

@end

