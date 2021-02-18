//
//  YZTestBeautyFilter.h
//  YZMetalLib
//
//  Created by yanzhen on 2021/2/4.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CVPixelBuffer.h>
#import <MetalKit/MetalKit.h>

@interface YZTestBeautyFilter : NSObject

-(instancetype)initWithDevice:(id<MTLDevice>)device;
- (void)dealPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end


