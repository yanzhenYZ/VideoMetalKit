//
//  YZEYUVBuffer.h
//  YZMetalKit
//
//  Created by yanzhen on 2021/3/1.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CVPixelBuffer.h>
#import <Metal/Metal.h>

@interface YZEYUVBuffer : NSObject

- (id<MTLTexture>)inputYUVPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end


