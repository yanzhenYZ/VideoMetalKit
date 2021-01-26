//
//  YZBlendFilter.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/1/26.
//

#import "YZBlendFilter.h"
#import <MetalKit/MetalKit.h>
#import "YZMetalDevice.h"

@interface YZBlendFilter ()
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) id<MTLTexture> imageTexture;
@end

@implementation YZBlendFilter
- (instancetype)init
{
    self = [super initWithVertexFunctionName:@"YZBlendVertex" fragmentFunctionName:@"YZBlendFragment"];
    if (self) {
        
    }
    return self;
}
- (void)newTextureAvailable:(id<MTLTexture>)texture commandBuffer:(id<MTLCommandBuffer>)commandBuffer {
    if (_imageTexture) {
        
    }
    [super newTextureAvailable:texture commandBuffer:commandBuffer];
}

- (void)setWatermark:(UIImage *)image {
    _image = image;
}

- (void)processImage {
    if (_imageTexture) { return; }
    MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:YZMetalDevice.defaultDevice.device];
    NSDictionary *options = @{
        MTKTextureLoaderOptionSRGB : @(NO)
    };
    __weak YZBlendFilter *weakSlef = self;
    [loader newTextureWithCGImage:_image.CGImage options:options completionHandler:^(id<MTLTexture>  _Nullable texture, NSError * _Nullable error) {
        weakSlef.imageTexture = texture;
    }];
}
@end
