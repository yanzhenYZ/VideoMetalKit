//
//  YZImageInput.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/1/25.
//

#import "YZImageInput.h"
#import <MetalKit/MetalKit.h>
#import "YZMetalDevice.h"

//todo 带有方向的图片

@interface YZImageInput ()
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) id<MTLTexture> texture;
@end

@implementation YZImageInput
- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}

- (void)processImage {
    if (_texture) {
        [self filter:self.texture];
    } else {
        MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:YZMetalDevice.defaultDevice.device];
        NSDictionary *options = @{
            MTKTextureLoaderOptionSRGB : @(NO)
        };
        __weak YZImageInput *weakSlef = self;
        [loader newTextureWithCGImage:_image.CGImage options:options completionHandler:^(id<MTLTexture>  _Nullable texture, NSError * _Nullable error) {
            weakSlef.texture = texture;
            [weakSlef filter:texture];
        }];
        
    }
}

- (void)filter:(id<MTLTexture>)texture {
    [self.allFilters enumerateObjectsUsingBlock:^(id<YZFilterProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj newTextureAvailable:texture commandBuffer:nil];
    }];
}
@end
