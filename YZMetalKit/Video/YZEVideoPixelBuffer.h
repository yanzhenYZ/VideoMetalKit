//
//  YZEVideoPixelBuffer.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/2/26.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CVPixelBuffer.h>

@protocol YZEVideoPixelBufferDelegate;
@interface YZEVideoPixelBuffer : NSObject
@property (nonatomic, weak) id<YZEVideoPixelBufferDelegate> delegate;
@end

@protocol YZEVideoPixelBufferDelegate <NSObject>

- (void)buffer:(YZEVideoPixelBuffer *)buffer pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
