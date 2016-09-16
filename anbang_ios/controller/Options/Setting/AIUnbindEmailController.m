//
//  AIUnbindEmailController.m
//  anbang_ios
//
//  Created by rooter on 15-3-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIUnbindEmailController.h"
#import "AIBindEmailViewController.h"
#import "UserInfo.h"
#import "AIPasswordAuthentiateViewController.h"

@interface AIUnbindEmailController () <UIAlertViewDelegate>

@end

@implementation AIUnbindEmailController {
    
    UIButton *mUnBindButton;
}

- (void)dealloc {
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_Unbind_Email" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupController];
    [self setupInterface];
//    [self notificationInitailize];
}
- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setupController {
    
    self.title = @"绑定邮箱";
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(pop)]];
}

- (void)setupInterface {
    
    UIView *view = [self contentView];
    CGPoint center = [[UIApplication sharedApplication] keyWindow].center;
    center.y -= 100;
    view.center = center;
    [self.view addSubview:view];
}

- (void)notificationInitailize {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(unbindSuccess:) name:@"AI_Unbind_Email" object:nil];
}

- (UIView *)contentView {
    
    UserInfo *userInfo = [UserInfo loadArchive];
    
    CGFloat view_w = Screen_Width - MARGIN_LEFT_RIGHT * 2;
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [view addSubview:imageView];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame), view_w, 35)];
    headerLabel.textColor = AB_Gray_Color;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = [NSString stringWithFormat:@"您的邮箱：%@", userInfo.secondEmail];
    [view addSubview:headerLabel];
    
    CGFloat dt_lb_w = view_w - MARGIN_LEFT_RIGHT * 6;
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT * 3, CGRectGetMaxY(headerLabel.frame), dt_lb_w, 40)];
    detailLabel.font = [UIFont systemFontOfSize:12.0];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.textColor = AB_Gray_Color;
    detailLabel.numberOfLines = 0;
    detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    detailLabel.text = @"邮箱作为用户名可登录邦邦社区，也可以用来找回密码";
    [view addSubview:detailLabel];
    
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    changeButton.frame = CGRectMake(0, CGRectGetMaxY(detailLabel.frame) + MARGIN_TOP_BOTTOM,view_w, 40);
    changeButton.backgroundColor = AB_Red_Color;
    [changeButton setTitle:@"更换邮箱" forState:UIControlStateNormal];
    [changeButton setTitleColor:AB_White_Color forState:UIControlStateNormal];
    changeButton.layer.cornerRadius = 6.0;
    [changeButton addTarget:self action:@selector(changeEmail:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:changeButton];
    
    UIButton *unBindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    unBindButton.frame = CGRectMake(0, CGRectGetMaxY(changeButton.frame) + MARGIN_TOP_BOTTOM,view_w, 40);
    unBindButton.backgroundColor = AB_White_Color;
    [unBindButton setTitle:@"解除绑定" forState:UIControlStateNormal];
    [unBindButton setTitleColor:AB_Gray_Color forState:UIControlStateNormal];
    unBindButton.layer.cornerRadius = 6.0;
    unBindButton.layer.borderWidth = 0.5;
    unBindButton.layer.borderColor = Normal_Border_Color.CGColor;
    [unBindButton addTarget:self action:@selector(unbindEmail:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:unBindButton];
    mUnBindButton = unBindButton;
    
    view.bounds = CGRectMake(0, 0, view_w, CGRectGetMaxY(unBindButton.frame));
    return view;
}

- (void)changeEmail:(UIButton *)sender
{
    AIPasswordAuthentiateViewController *controller = [[AIPasswordAuthentiateViewController alloc] init];
    controller.operationType = 4;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)unbindEmail:(UIButton *)sender
{
    BOOL flag = [self accessible];
    if (!flag) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"你确定要解绑唯一的手机/邮箱吗？解绑后您将不能找回密码"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        [alertView show];
        return;
    }
    
    [self unbind];
}

- (void)unbind {
    AIPasswordAuthentiateViewController *controller = [[AIPasswordAuthentiateViewController alloc] init];
    controller.operationType = 3;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)tipViewShow:(NSString *)tip {
    JLTipsView *tipView = [[JLTipsView alloc] initWithTip:tip];
    [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

- (BOOL)accessible {
    UserInfo *info = [UserInfo loadArchive];
    return info.phone != nil && ![info.phone isEqualToString:@""];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
            [self unbind];
            break;
            
        default:
            break;
    }
}

@end
