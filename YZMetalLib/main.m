//
//  main.m
//  YZMetalLib
//
//  Created by yanzhen on 2020/12/8.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

/**
 4.0.1 帧率
 4.0.2 显示模式
 4.0.3 镜像
 
 4.0.4 美颜参数
 
 4.0.5 旋转屏幕
 
 4.0.6 切换显示视图， 调整显示视图大小
 
 4.0.7 直接释放VideoCapture
 */

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
