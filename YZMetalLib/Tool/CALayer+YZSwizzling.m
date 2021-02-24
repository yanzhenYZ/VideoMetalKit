//
//  CALayer+YZSwizzling.m
//  YZMetalLib
//
//  Created by yanzhen on 2021/2/24.
//

#import "CALayer+YZSwizzling.h"
#import <objc/runtime.h>

@implementation CALayer (YZSwizzling)
+ (void)load {
    if (@available(iOS 13.0, *)) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class selfClass = [self class];
            SEL oriSEL = @selector(layoutSublayers);
            Method oriMethod = class_getInstanceMethod(selfClass, oriSEL);
            SEL swizzlingSEL = @selector(yz_layoutSublayers);
            Method swizzlingMethod = class_getInstanceMethod(selfClass, swizzlingSEL);
            
            BOOL addSucc = class_addMethod(selfClass, oriSEL, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
            
            if(addSucc) {//成功，将原方法的实现替换到替换方法的实现
                class_replaceMethod(selfClass, swizzlingSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
            } else {//失败，说明原方法已经实现，直接交换方法
                method_exchangeImplementations(oriMethod, swizzlingMethod);
            }
        });
    }
}

- (void)yz_layoutSublayers {
    if (NSThread.isMainThread) {
        [self yz_layoutSublayers];
    } else {
        NSLog(@"Layer:%@", self);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self yz_layoutSublayers];
        });
    }
}
@end
