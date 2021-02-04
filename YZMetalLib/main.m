//
//  main.m
//  YZMetalLib
//
//  Created by yanzhen on 2020/12/8.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


/**
 //done
 0. MTLTexture绑定PixelBuffer
 1.
   001. PixelBuffer输出尺寸问题 -- 001：直接修改MTLTexture尺寸
   002. PixelBuffer输出尺寸问题 -- 002：CropFilter
 
 
 2. PixelBuffer输出buffer做美颜，然后做渲染可行性方案
   001: 输出buffer,接着还是Texture做渲染
   002: 用输出PixelBuffer做渲染
 
 3. 新流程
 camera --->(Crop) --> water --> beauty --> MTKView and PixelBuffer
 
 */
int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
