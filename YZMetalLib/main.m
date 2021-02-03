//
//  main.m
//  YZMetalLib
//
//  Created by yanzhen on 2020/12/8.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


/**
 
 0. MTLTexture绑定PixelBuffer
 
 
 
 1. PixelBuffer输出尺寸问题 -- 001：MTLTexture
 2. PixelBuffer输出尺寸问题 -- 002：CropFilter
 
 */
int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
