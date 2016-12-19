//
//  VVNavigationController.m
//  mingjieloan
//
//  Created by mac on 2016/12/19.
//  Copyright © 2016年 mingjie. All rights reserved.
//

#import "VVNavigationController.h"

@interface VVNavigationController ()

@end

@implementation VVNavigationController



- (void)viewDidLoad {
    [super viewDidLoad];
     //背景颜色
    UINavigationBar *navBar = [[UINavigationBar alloc] init];
    navBar.backIndicatorImage = [UIImage imageNamed:@"BJXX"];
    navBar.shadowImage = [[UIImage alloc] init];
    self.navigationBar.barTintColor = [XXColor goldenColor];

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //背景颜色
    UINavigationBar *navBar = [[UINavigationBar alloc] init];
    navBar.backIndicatorImage = [UIImage imageNamed:@"BJXX"];
    navBar.shadowImage = [[UIImage alloc] init];
    self.navigationBar.barTintColor = [XXColor goldenColor];
    
}
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [super pushViewController:viewController animated:animated];
    //背景颜色
    UINavigationBar *navBar = [[UINavigationBar alloc] init];
    navBar.backIndicatorImage = [UIImage imageNamed:@"BJXX"];
    navBar.shadowImage = [[UIImage alloc] init];
   
}

-(void)showViewController:(UIViewController *)vc sender:(id)sender{
    [super showViewController:vc sender:sender];
    //背景颜色
    UINavigationBar *navBar = [[UINavigationBar alloc] init];
    navBar.backIndicatorImage = [UIImage imageNamed:@"BJXX"];
    navBar.shadowImage = [[UIImage alloc] init];
   
}

/**
 *设置状态栏的颜色
 */
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
