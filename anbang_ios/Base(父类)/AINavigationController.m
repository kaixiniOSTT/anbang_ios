//
//  AINavigationController.m
//  anbang_ios
//
//  Created by rooter on 15-3-24.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AINavigationController.h"

@implementation AINavigationController

+ (void)initialize {
    
    // 设置导航栏按钮主题
    [self setupNavBarTheme];
}

/**
 *  设置导航栏主题
 */
+ (void)setupNavBarTheme
{
    // 取出appearance对象
    UINavigationBar *navBar = [UINavigationBar appearance];
    
    // 设置背景
    
    [navBar setBackgroundImage:[UIImage imageWithName:@"header_bg"] forBarMetrics:UIBarMetricsDefault];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    
    // 设置标题属性
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttrs[UITextAttributeTextShadowOffset] = [NSValue valueWithUIOffset:UIOffsetZero];
   //修改字体加粗
    textAttrs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:19];
    [navBar setTitleTextAttributes:textAttrs];
}

- (void)viewDidLoad

{
    [super viewDidLoad];
    
    __weak AINavigationController *weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
}



// Hijack the push method to disable the gesture

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated

{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]&&animated==YES)
        self.interactivePopGestureRecognizer.enabled = NO;
    [super pushViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated

{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]&&animated==YES)
        self.interactivePopGestureRecognizer.enabled = NO;
    
    return  [super popToRootViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
        self.interactivePopGestureRecognizer.enabled = NO;
    return [super popToViewController:viewController animated:animated];
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animate
{
    // Enable the gesture again once the new controller is shown
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.interactivePopGestureRecognizer.enabled = YES;
    }
    
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer==self.interactivePopGestureRecognizer) {
        if (self.viewControllers.count<2||self.visibleViewController==[self.viewControllers objectAtIndex:0]) {
            return NO;
        }
    }
    return YES;
}

@end
