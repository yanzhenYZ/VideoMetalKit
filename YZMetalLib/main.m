//
//  main.m
//  YZMetalLib
//
//  Created by yanzhen on 2020/12/8.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
/**
 git push origin --delete xxx 删除xxx分之
 1. 输入3个平面 y,u,v数据做渲染PixelBuffer
 2. 输入裸数据BGRA, YUV做渲染
 3. 支持裁剪等
 
 */
int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
