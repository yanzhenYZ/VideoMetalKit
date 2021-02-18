//
//  YZTestBeautyManager.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/2/4.
//

#import "YZTestBeautyManager.h"
#import <MetalKit/MetalKit.h>
#import "YZTestBeautyFilter.h"

@interface YZTestBeautyManager ()
@property (nonatomic, strong) id<MTLDevice> device;


@property (nonatomic, strong) YZTestBeautyFilter *filter;
@end

@implementation YZTestBeautyManager
- (instancetype)init
{
    self = [super init];
    if (self) {
        _device = MTLCreateSystemDefaultDevice();
        
        _filter = [[YZTestBeautyFilter alloc] initWithDevice:self.device];
        

    }
    return self;
}

-(void)dealPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [_filter dealPixelBuffer:pixelBuffer];
}
@end
