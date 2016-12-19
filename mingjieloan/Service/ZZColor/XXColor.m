//
//  XXColor.m
//  mingjieloan
//
//  Created by mac on 2016/12/19.
//  Copyright © 2016年 mingjie. All rights reserved.
//
//  OC设置颜色的帮助类

#import "XXColor.h"

@implementation XXColor
/**
 *橙色
 */
+ (UIColor *)goldenColor{
    
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"BJXX"]];
}


/**
 * lableView的文字橙色
 */
+ (UIColor *)labGoldenColor{
    
    return [[UIColor alloc] initWithRed:(251.0 / 255.0) green:(142.0 / 255.0) blue:(2.0 / 255.0) alpha:1.0];
}

/**
 * UILalbel文字的橙色
 */

+ (UIColor *)labelGoldenColor{
    
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"BJXX"]];
}

/**
 *购买按钮的颜色
 */
+ (UIColor *)purchaseBtnBgrdColor{
    
    return [[UIColor alloc] initWithRed:(128.0 / 255.0) green: (90.0 / 255.0)  blue: (15.0 / 255.0) alpha:1.0];
    
}

/**
 *总资产界面的土豪金
 */
+ (UIColor *)assetsSum{
    
    return [[UIColor alloc] initWithRed:(247.0 / 255.0) green: (150.0 / 255.0)  blue: (26.0 / 255.0) alpha:1.0];
    
}

/**
 * 用图片的土豪金(中间的颜色不一样)
 */
+ (UIColor *)imagasAsetsSum{
    
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"assetsSum"]];
    
}


/**
 * 点击按钮的土豪金颜色
 */
+ (UIColor *)btnGoldenColor{
    
    return [[UIColor alloc] initWithRed:(128.0 / 255.0) green: (90.0 / 255.0)  blue: (15.0 / 255.0) alpha:1.0];
    
}

/**
 * 按钮边框的土豪金
 */
+ (UIColor *)borderAllColor{
    
    return [[UIColor alloc] initWithRed:(128.0 / 255.0) green: (90.0 / 255.0)  blue: (15.0 / 255.0) alpha:1.0];
    
}
/**
 * 什么什么活动的背景色
 */
+ (UIColor *)huodongColor{
    
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"huodong"]];
    
}
/**
 * 发送验证码的按钮的背景橙色
 */
+ (UIColor *)sendCodeBtnColor{
    
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"BJXX"]];
}
/**
 * 发送验证码的按钮的XX背景橙色
 */
+ (UIColor *)sendCodeBtnDisColor{
    
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"BJXX"]];
}
/**
 *按钮的橙色
 */
+ (UIColor *)seBtnGoldenColor{
    
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"BJXX"]];
}

/**
 * 全部的东北银
 */

+ (UIColor *)grayAllColor{
    
    return [[UIColor alloc] initWithRed:(145.0 / 255.0) green: (145.0 / 255.0)  blue: (145.0 / 255.0) alpha:1.0];
    
}


/**
 * 会员中心的电话号码的文字颜色
 */
+ (UIColor *)phoneNumberColor{
    
    return [[UIColor alloc] initWithRed:(76.0 / 255.0) green: (51.0 / 255.0)  blue: (1.0 / 255.0) alpha:1.0];
    
}






@end
