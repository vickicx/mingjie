//
//  HUDManager.h
//  UI18_AFNetWork二次封装
//
//  Created by dllo on 15/8/31.
//  Copyright (c) 2015年 lulu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface HUDManager : NSObject

+ (void)showStatusWithString:(NSString *)string;

+ (void)closeHUD;


@end
