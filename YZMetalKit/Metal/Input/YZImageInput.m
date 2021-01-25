//
//  YZImageInput.m
//  YZMetalKit
//
//  Created by yanzhen on 2021/1/25.
//

#import "YZImageInput.h"
#import <MetalKit/MetalKit.h>
#import "YZMetalDevice.h"

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
        
    } else {
        MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:YZMetalDevice.defaultDevice.device];
        NSDictionary *options = @{
            MTKTextureLoaderOptionSRGB : @(NO)
        };
        __weak YZImageInput *weakSlef = self;
        [loader newTextureWithCGImage:_image.CGImage options:options completionHandler:^(id<MTLTexture>  _Nullable texture, NSError * _Nullable error) {
            weakSlef.texture = texture;
        }];
        
    }
}
@end
