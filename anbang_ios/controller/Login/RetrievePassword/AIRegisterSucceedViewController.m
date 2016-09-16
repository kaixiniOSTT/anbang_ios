//
//  AIRegisterSucceedViewController.m
//  anbang_ios
//
//  Created by rooter on 15-3-18.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIRegisterSucceedViewController.h"

@interface AIRegisterSucceedViewController ()

@end

@implementation AIRegisterSucceedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupController];
}

- (void)setupController {
    
    UIView *view = [self interfaceView];
    CGPoint center = CGPointMake(Screen_Width / 2, 200);
    view.center = center;
    [self.view addSubview:view];
}

- (UIView *)interfaceView {
    
    CGFloat view_w = Screen_Width - MARGIN_LEFT_RIGHT * 2;
    UIView *view = [[UIView alloc] init];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, view_w, 90);
    imageView.image = [UIImage imageWithName:@"regist_icon_success"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:imageView];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame), view_w, 50);
    tipLabel.text = @"重设密码成功，请重新登录";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:tipLabel];
    
    UILabel *actionLabel = [[UILabel alloc] init];
    actionLabel.frame = CGRectMake(0, CGRectGetMaxY(tipLabel.frame), view_w, 30);
    actionLabel.text = @"页面将在3秒后跳转到登录页面";
    actionLabel.font = [UIFont systemFontOfSize:10.0];
    actionLabel.textAlignment = NSTextAlignmentCenter;
    actionLabel.textColor = [UIColor lightGrayColor];
    [view addSubview:actionLabel];
    
    UIButton *reloginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reloginBtn.bounds = CGRectMake(0, 0, 90, 40);
    CGPoint center = CGPointMake(view_w / 2, CGRectGetMaxY(actionLabel.frame) + 100);
    reloginBtn.center = center;
    [reloginBtn setTitle:@"重新登录" forState:UIControlStateNormal];
    [reloginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    reloginBtn.layer.masksToBounds = YES;
    reloginBtn.layer.cornerRadius = 5.0;
    reloginBtn.layer.borderWidth = 1.0;
    reloginBtn.layer.borderColor = [[UIColor brownColor] CGColor];
    [reloginBtn addTarget:self action:@selector(relogin:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:reloginBtn];
    
    CGFloat view_h = CGRectGetMaxY(reloginBtn.frame);
    view.bounds = CGRectMake(0, 0, view_w, view_h);
    
    return view;
}

- (void)relogin:(UIButton *)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}



@end
