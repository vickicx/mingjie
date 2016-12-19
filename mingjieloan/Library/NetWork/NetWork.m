//
//  NetWork.m
//  UI_AFN二次封装
//
//  Created by lulu on 15/8/31.
//  Copyright (c) 2015年 lulu. All rights reserved.
//

#import "NetWork.h"
#import "AFNetworking.h"
#import "Reachability.h"

@implementation NetWork

// get网络请求
+ (void)networkGETRequestWithURL:(NSString *)url Paramater:(NSDictionary *)dic ResultBlock:(void (^)(id))block
{
    
    // 判断是否有网
    if ([self isNetWorkConnectAVailable]) {
        
        
        /**  如果有汉字先转码   **/
        // 利用AFHTTPRequestOperation 先获取到字符串形式的数据，然后转换成json格式，将NSString格式的数据转换成json数据
        NSString *url_string = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
        
        // 创建请求对象
       
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        // 请求https
        manager.securityPolicy.allowInvalidCertificates = YES;
        // 设置请求格式
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // 设置响应的类型
        [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css", @"text/plain", nil]];
        
        
        // 如果Response显示的内容在线JSON没有显示的话, 就用下面的方法
        // 特别屌的方法: 把抓包工具中的Request下面的:User-Agent给复制到参数二上  ,  把User-Agent对应的给赋值到参数1上
        [manager.requestSerializer setValue:@"BreadTrip/6.0.0/zh (iPhone7,2; iPhone OS8.3; zh-Hans zh_CN) Paros/3.2.13" forHTTPHeaderField:@"User-Agent"];
        
        // 加载指示器
        [HUDManager showStatusWithString:@"加载中"];

        
        // GET请求
        // 参数1: url
        // 参数2: 拼接的body
        // 参数3: 成功块
        // 参数4: 失败块
        [manager GET:url_string parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
            // 转成JSON
            // NSJSONReadingMutableContainers 请求回的数据
            id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            
            block(result);
            
            // 取消MBProgress的指示器
            [HUDManager closeHUD];
            
            
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            ////NSLog(@"%@", error);
            
        }];
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}




// post网络请求
+ (void)networkPOSTRequestWithURL:(NSString *)url Paramater:(NSMutableDictionary *)dic ResultBlock:(void (^)(id))block
{

    // 判断是否有网
    if ([self isNetWorkConnectAVailable]) {
        
        
        /**  如果有汉字先转码   **/
        // 利用AFHTTPRequestOperation 先获取到字符串形式的数据，然后转换成json格式，将NSString格式的数据转换成json数据
        NSString *url_string = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *newurl = [NSURL URLWithString:url_string];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:newurl];
        [request setHTTPMethod:@"POST"];
        
    
        // 管理器 首先需要实例化一个请求管理器AFHTTPRequestOperationManager
        AFHTTPSessionManager *netManager = [AFHTTPSessionManager manager];
        netManager.requestSerializer = [AFJSONRequestSerializer serializer];
        [netManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        //[NSSet setWithObjects:@"text/plain",@"text/json",@"application/json",@"text/javascript",@"text/html",nil];  代表支持所有的接口类型
        netManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json",@"application/json",@"text/javascript",@"text/html",nil];
        
        [HUDManager showStatusWithString:@"加载中"];
        
        
        
        // 如果Response显示的内容在线JSON没有显示的话, 就用下面的方法
        // 特别屌的方法: 把抓包工具中的Request下面的:User-Agent给复制到参数二上  ,  把User-Agent对应的给赋值到参数1上
        [netManager.requestSerializer setValue:@"BreadTrip/6.0.0/zh (iPhone7,2; iPhone OS8.3; zh-Hans zh_CN) Paros/3.2.13" forHTTPHeaderField:@"User-Agent"];
        
        
        
        // 请求数据
        [netManager POST:url parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
            
            block(responseObject);
            [HUDManager closeHUD];
            
            
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            //NSLog(@"%@", error);
            
        }];
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }

    
}


/**
 
 
 * @brief 判断网络状态
 * @reture YES/有网 NO/无网
 */

// 检测网络状态 网络是否可用
+ (BOOL)isNetWorkConnectAVailable
{
    BOOL isNet = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
        {
            isNet = NO;
            //NSLog(@"无网络连接");
            break;
        }
        case ReachableViaWiFi:
        {
            isNet = YES;
            //NSLog(@"WIFI连接");
            break;
        }
        case ReachableViaWWAN:
        {
            isNet = YES;
            //NSLog(@"3G连接");
            break;
        }
       
    }
    
    return isNet;
}



#pragma mark -- 缓存带浏览记录的实现方法
+ (void)networkGETRequesWithURL:(NSString *)url
                      Paramater:(NSDictionary *)dic
       pageUniquenessIdentifier:(NSString *)pageUniquenessIdentifier
                         result:(void (^)(id))block
{
    // 转码
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    /* 开始缓存 */
    // 获取Caches路径
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject];
    
    /*创建缓存文件*/
    NSString *BeautyTravelCachesFolderName = [NSString stringWithFormat:@"%@/LDY",cachesPath];
    NSFileManager *filemanger = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL existed = [filemanger fileExistsAtPath:BeautyTravelCachesFolderName isDirectory:&isDirectory];
    if (!(isDirectory == YES && existed == YES)) {
        [filemanger createDirectoryAtPath:BeautyTravelCachesFolderName withIntermediateDirectories:YES attributes:nil error:nil];
    }
    /* 缓存文件名*/
    NSString *cachesFileString = [NSString stringWithFormat:@"resultDataCacheFile_%@.plist",pageUniquenessIdentifier];
    
    /* 拼接路径 */
    NSString *cacheExistPath = [BeautyTravelCachesFolderName stringByAppendingFormat:@"/%@",cachesFileString];
    //    //NSLog(@"Caches: %@",cacheExistPath);
    /* 缓存创建文件名结束 */
    
    // 判断是否有网
    if ([self LTYisNetworkConnectionAvailable]) {
        // 创建请求对象
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        // 请求HTTPS(若不添加, 无法解析HTTPS)
        manager.securityPolicy.allowInvalidCertificates = YES;
        // 设置请求格式
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        // 响应格式
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        // 设置响应的类型
        [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/css", nil]];
        
        // 加载指示器
        [HUDManager showStatusWithString:@"加载中"];
        
        // GET请求
        /**
         * 参数1: url
         * 参数2: 拼接的body
         * 参数3: 成功块
         * 参数4: 失败块
         */
        [manager GET:url parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
            // 转成JSON
            // operation.responseObject请求回的数据(请求回来的真正二进制文件)
            id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            [HUDManager closeHUD];
            
            /* 开始缓存 */
            [NSKeyedArchiver archiveRootObject:result toFile:cacheExistPath];
            /* 开始缓存 */
            
            block(result);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            // 输出错误信息
            //NSLog(@"%@", error);
        }];
        
    } else {
        
        /*  判断有网没网进行数据的缓存和缓存后的数据读取工作 */
        NSDictionary *takeOutCachesDataDic = [NSKeyedUnarchiver unarchiveObjectWithFile:cacheExistPath];
        if (takeOutCachesDataDic != nil) {
            
            //NSLog(@"无网 ----- 有缓存数据");
            block(takeOutCachesDataDic);
        } else
        {
            //            //NSLog(@"无网 ----- 无缓存数据");
            /* 进行提示 */
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

+ (void)networkPOSTRequestWithURL:(NSString *)url body:(NSString *)body result:(void (^)(id))block
{
    if ([self LTYisNetworkConnectionAvailable]) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.securityPolicy.allowInvalidCertificates = YES;
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/css", @"text/plain", nil]];
        
        NSArray *bodyArr = [body componentsSeparatedByString:@"&"];
        NSMutableDictionary *bodyDic = [NSMutableDictionary dictionary];
        for (NSString *string in bodyArr) {
            NSArray *tempArr = [string componentsSeparatedByString:@"="];
            [bodyDic setObject:tempArr[1] forKey:tempArr	[0]];
        }
        
        [manager POST:url parameters:bodyDic success:^(NSURLSessionDataTask *task, id responseObject) {
            id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            block(result);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            //NSLog(@"%@", error);
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark -- 带缓存浏览的判断网络状态
+ (BOOL)LTYisNetworkConnectionAvailable
{
    BOOL WithTheNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
        {
            WithTheNetwork = NO;
            //NSLog(@"无网络连接");
            [HUDManager closeHUD];
        }
            break;
        case ReachableViaWiFi:
        {
            WithTheNetwork = YES;
            //NSLog(@"通过WiFi连接");
        }
            break;
        case ReachableViaWWAN:
        {
            WithTheNetwork = YES;
            //NSLog(@"通过GPRS网络连接");
        }
            break;
        default:
            break;
    }
    return WithTheNetwork;
}



@end
