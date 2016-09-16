//
//  CHNewFeatureController.m
//  anbang_ios
//
//  Created by rooter on 15-3-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "CHNewFeatureController.h"
#import "CHAppDelegate.h"
#import "PhoneNumRegisteredViewController.h"
#import "AINavigationController.h"

#define IWNewfeatureImageCount 3

#define Ratio_Vertical   Screen_Height/667
#define Ratio_Horizontal Screen_Width/375

@interface CHNewFeatureController () <UIScrollViewDelegate>

@property (nonatomic, weak) UIPageControl *pageControl;

@end

@implementation CHNewFeatureController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    JLLog_D("Loaing new feature controller");
    
    // 设置Controller Preference
    [self setupController];
    
    // 1.添加UISrollView
    [self setupInterface];
}

- (void)setupController {
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 20)];
    view.backgroundColor = AB_Red_Color;
    [self.view addSubview:view];
    
    self.view.backgroundColor = Controller_View_Color;
}

/**
 *  添加pageControl
 */
- (void)setupPageControl:(UIScrollView *)scrollView
{
    // 1.添加
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = IWNewfeatureImageCount;
    CGFloat centerX = self.view.frame.size.width * 0.5;
    CGFloat centerY = CGRectGetMaxY(scrollView.frame) + 40 * Ratio_Vertical;
    pageControl.center = CGPointMake(centerX, centerY);
    pageControl.bounds = CGRectMake(0, 0, 100, 30);
    pageControl.userInteractionEnabled = NO;
    [self.view addSubview:pageControl];
    self.pageControl = pageControl;
    
    // 2.设置圆点的颜色
    pageControl.currentPageIndicatorTintColor = IWColor(253, 98, 42);
    pageControl.pageIndicatorTintColor = IWColor(189, 189, 189);
    
    [self setupButtons:pageControl];
}

- (void)setupButtons:(UIPageControl *)pageControl {
    
    CGFloat btn_w = (Screen_Width - 16 * 2 - 16 * Ratio_Horizontal) / 2;
    CGFloat btn_h = 40;
    CGFloat btn_y = CGRectGetMaxY(pageControl.frame) + 30 * Ratio_Vertical;
    
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLogin.frame = CGRectMake(16, btn_y, btn_w, btn_h);
    btnLogin.layer.cornerRadius = 6.0;
    btnLogin.backgroundColor = AB_Red_Color;
    [btnLogin setTitleColor:AB_White_Color forState:UIControlStateNormal];
    [btnLogin setTitle:@"登录" forState:UIControlStateNormal];
    [btnLogin addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLogin];
    
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRegister.frame = CGRectMake(CGRectGetMaxX(btnLogin.frame) + 16 * Ratio_Horizontal, btn_y, btn_w, btn_h);
    btnRegister.layer.cornerRadius = 6.0;
    btnRegister.layer.borderColor = Normal_Border_Color.CGColor;
    btnRegister.layer.borderWidth = 0.5;
    [btnRegister setTitleColor:AB_Gray_Color forState:UIControlStateNormal];
    [btnRegister setTitle:@"注册" forState:UIControlStateNormal];
    btnRegister.backgroundColor = AB_White_Color;
    [btnRegister addTarget:self action:@selector(register:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnRegister];
}

/**
 *  添加UISrollView
 */
- (void)setupInterface
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    // 2.添加图片
    CGFloat view_w = Screen_Width;
    CGFloat view_h = Screen_Width * 0.8 * (7  / 5.9);
    for (int index = 0; index<IWNewfeatureImageCount; index++) {
        
        UIView *view = [[UIView alloc] init];
        CGFloat view_x = index * view_w;
        view.frame = CGRectMake(view_x, 0, view_w, view_h);
        [scrollView addSubview:view];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.layer.cornerRadius = 12.0;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = [UIColor greenColor];
        
        // 设置图片
        NSString *name = [NSString stringWithFormat:@"feature_0%d",index+1];
        imageView.image = [UIImage imageNamed:name];
        
        // 设置frame
        CGFloat image_w = view_h * (5.9 / 7);
        CGFloat image_h = view_h;
        imageView.frame = CGRectMake((view_w - image_w) / 2, 0, image_w, image_h);
        [view addSubview:imageView];
    }
    
    // 3.设置滚动的内容尺寸
    scrollView.frame = CGRectMake(0, 90 * Ratio_Vertical, Screen_Width, view_h);
    scrollView.contentSize = CGSizeMake(view_w * IWNewfeatureImageCount, 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    
    [self setupPageControl:scrollView];
}

/**
 *  开始体验
 */
- (void)login:(UIButton *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:YES] forKey:kNew_Feature_Hide];
    [defaults synchronize];
    
    // 显示状态栏
    [UIApplication sharedApplication].statusBarHidden = NO;
    // 切换窗口的根控制器
    [(CHAppDelegate *)[[UIApplication sharedApplication] delegate] loadAppConfiguration];
}

- (void)register:(UIButton *)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:YES] forKey:kNew_Feature_Hide];
    [defaults synchronize];
    
    PhoneNumRegisteredViewController *controller = [[PhoneNumRegisteredViewController alloc] init];
    controller.navigationItem.hidesBackButton = YES;
    AINavigationController *navi = [[AINavigationController alloc] initWithRootViewController:controller];
    self.view.window.rootViewController = navi;
}

/**
 *  只要UIScrollView滚动了,就会调用
 *
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 1.取出水平方向上滚动的距离
    CGFloat offsetX = scrollView.contentOffset.x;
    
    // 2.求出页码
    double pageDouble = offsetX / scrollView.frame.size.width;
    int pageInt = (int)(pageDouble + 0.5);
    self.pageControl.currentPage = pageInt;
}


@end
