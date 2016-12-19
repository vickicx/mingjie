//
//  HUDManager.m
//  UI18_AFNetWork二次封装
//
//  Created by dllo on 15/8/31.
//  Copyright (c) 2015年 lulu All rights reserved.
//

#import "HUDManager.h"
#import "MBProgressHUD.h"


static MBProgressHUD *progressHUD;


@implementation HUDManager

+ (void)showStatusWithString:(NSString *)string
{
    // 获取当前的window
    UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    
    // 显示在当前的window上
    progressHUD = [MBProgressHUD showHUDAddedTo:window animated:YES];
    // 显示的标题
    progressHUD.labelText = string;
    // HUD 类型
    progressHUD.mode = MBProgressHUDModeIndeterminate;
    // 背景
    progressHUD.dimBackground = NO;
    
    progressHUD.alpha = 0.3;
    
//    [progressHUD hide:YES afterDelay:1.0];
 
}

+ (void)closeHUD
{
    [progressHUD hide:YES];
}

@end
