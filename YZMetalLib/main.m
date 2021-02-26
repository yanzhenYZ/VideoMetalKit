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
 
 //do
 2.2.1 VideoRange FullRange渲染
 
 
 2.2.2 VideoRange FullRange带有旋转角度渲染
 
 2.2.3 输入3个平面 y,u,v数据做渲染PixelBuffer渲染 研究
 
 2.2.4带有裁剪范围BGRA
 2.2.5带有裁剪范围Range
 
 2.3.0 裸数据 
 */

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
