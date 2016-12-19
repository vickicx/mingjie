//
//  NetWork.h
//  UI_AFN二次封装
//
//  Created by lulu on 15/8/31.
//  Copyright (c) 2015年 lulu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HUDManager.h"

@interface NetWork : NSObject


/**
 
 * @brief GET网络请求
 * @param url 请求网址
 * @param dic 拼接的body
 * @param block 返回请求结果
 
 */
+ (void)networkGETRequestWithURL:(NSString *)url Paramater:(NSDictionary *)dic ResultBlock:(void(^)(id result))block;


// post网络请求
+ (void)networkPOSTRequestWithURL:(NSString *)url Paramater:(NSMutableDictionary *)dic ResultBlock:(void(^)(id result))block;



#pragma mark -- 带浏览缓存的网络请求
/**
 * @brief GET网络请求
 *
 * @param url 请求网址
 * @param dic 拼接的body
 * @param block 返回请求结果
 */
+ (void)networkGETRequesWithURL:(NSString *)url
                      Paramater:(NSDictionary *)dic
       pageUniquenessIdentifier:(NSString *)pageUniquenessIdentifier
                         result:(void (^)(id result))block;
/**
 * @brief POST网络请求
 *
 * @param url 请求网址
 * @param body 拼接的body
 * @param block 返回请求结果
 */
+ (void)networkPOSTRequestWithURL:(NSString *)url
                             body:(NSString *)body
                           result:(void(^)(id result))block;

/**
 * @brief 判断网络状态
 *
 * @return YES 有网 NO 无网
 */
+ (BOOL)LTYisNetworkConnectionAvailable;

@end
