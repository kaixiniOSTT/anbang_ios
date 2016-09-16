//
//  AIUnbindPhoneViewController.m
//  anbang_ios
//
//  Created by rooter on 15-3-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIUnbindPhoneViewController.h"
#import "AIBindPhoneViewController.h"
#import "UserInfo.h"
#import "DejalActivityView.h"
#import "AIPasswordAuthentiateViewController.h"
#import "AIPhoneContactViewController.h"

@interface AIUnbindPhoneViewController () <UIAlertViewDelegate>

@end

@implementation AIUnbindPhoneViewController

- (void)dealloc {
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_Unbind_Phone" object:nil];
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
    
    self.title = @"绑定手机";
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"target:self action:@selector(pop)]];
}

- (void)setupInterface {
    
    UIView *view = [self contentView];
    CGPoint center = [[UIApplication sharedApplication] keyWindow].center;
//    center.y -= 100;
    view.center = center;
    
    CGFloat centerY = center.y < 285 ? 40 : 90;
    UIImage *img = [UIImage imageNamed:@"my_icon_boundPhone"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((Screen_Width - img.size.width )/ 2, centerY, img.size.width, img.size.height)];
    imageView.image = img;

    [self.view addSubview:imageView];
    
    [self.view addSubview:view];
}

- (void)notificationInitailize {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(unbindPhoneSuccess:) name:@"AI_Unbind_Phone" object:nil];
}

- (UIView *)contentView {
    
    UserInfo *userInfo = [UserInfo loadArchive];
    
    CGFloat view_w = Screen_Width - MARGIN_LEFT_RIGHT * 2;
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
//    view.layer.borderWidth = 1;
//    view.layer.borderColor = [UIColor redColor].CGColor;//my_icon_boundPhone
    
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view_w, 35)];
    headerLabel.textColor = AB_Black_Color;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = AB_FONT_18;
    headerLabel.text = [NSString stringWithFormat:@"您的手机：%@", userInfo.phone];
    [view addSubview:headerLabel];
    
    CGFloat dt_lb_w = view_w - MARGIN_LEFT_RIGHT * 6;
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT * 3, CGRectGetMaxY(headerLabel.frame), dt_lb_w, 40)];
    detailLabel.font = AB_FONT_14;
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.textColor = AB_Gray_Color;
    detailLabel.numberOfLines = 0;
    detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    detailLabel.text = @"手机作为用户名可登录邦邦社区，也可以用来找回密码";
    [view addSubview:detailLabel];
    
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    changeButton.frame = CGRectMake(0, CGRectGetMaxY(detailLabel.frame) + 45,view_w, 40);
    changeButton.backgroundColor = AB_Red_Color;
    [changeButton setTitle:@"更改手机" forState:UIControlStateNormal];
    [changeButton setTitleColor:AB_White_Color forState:UIControlStateNormal];
    changeButton.layer.cornerRadius = 3.0;
    [changeButton addTarget:self action:@selector(changePhone:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:changeButton];
    
    UIButton *unBindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    unBindButton.frame = CGRectMake(0, CGRectGetMaxY(changeButton.frame) + MARGIN_TOP_BOTTOM,view_w, 40);
    unBindButton.backgroundColor = AB_Color_e7e2dd;
    [unBindButton setTitle:@"解除绑定" forState:UIControlStateNormal];
    [unBindButton setTitleColor:AB_Black_Color forState:UIControlStateNormal];
    unBindButton.layer.cornerRadius = 3.0;
    unBindButton.layer.borderWidth = 0.5;
    unBindButton.layer.borderColor = Normal_Border_Color.CGColor;
    [unBindButton addTarget:self action:@selector(unbindPhone:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:unBindButton];
    
    UIButton *phoneContactButton = [UIButton buttonWithType:UIButtonTypeCustom];
    phoneContactButton.frame = CGRectMake(0, CGRectGetMaxY(unBindButton.frame) + MARGIN_TOP_BOTTOM,view_w, 40);
    phoneContactButton.backgroundColor = AB_Color_e7e2dd;
    [phoneContactButton setTitle:@"查看手机通讯录" forState:UIControlStateNormal];
    [phoneContactButton setTitleColor:AB_Black_Color forState:UIControlStateNormal];
    phoneContactButton.layer.cornerRadius = 3.0;
    phoneContactButton.layer.borderWidth = 0.5;
    phoneContactButton.layer.borderColor = Normal_Border_Color.CGColor;
    [phoneContactButton addTarget:self action:@selector(viewPhoneContact:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:phoneContactButton];
    
    view.bounds = CGRectMake(0, 0, view_w, CGRectGetMaxY(phoneContactButton.frame));
    return view;
}

- (void)changePhone:(UIButton *)sender {
    
    AIPasswordAuthentiateViewController *controller = [[AIPasswordAuthentiateViewController alloc] init];
    controller.operationType = 2;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)unbindPhone:(UIButton *)sender {
    BOOL flag = [self accessible];
    if (!flag) {
        if (!flag) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"你确定要解绑唯一的手机/邮箱吗？解绑后您将不能找回密码"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
            [alertView show];
            return;
        }
    }
    
    [self unbind];
}

- (void)unbind {
    AIPasswordAuthentiateViewController *controller = [[AIPasswordAuthentiateViewController alloc] init];
    controller.operationType = 1;
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)accessible {
    UserInfo *info = [UserInfo loadArchive];
    return info.secondEmail != nil && ![info.secondEmail isEqualToString:@""];
}

- (void)viewPhoneContact:(UIButton *)sender {
    AIPhoneContactViewController *controller = [[AIPhoneContactViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)tipViewShow:(NSString *)tip {
    JLTipsView *tipView = [[JLTipsView alloc] initWithTip:tip];
    [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

- (void)loadViewShow {
    [self.view endEditing:YES];
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)loadViewHide {
    [self.view endEditing:NO];
    [DejalKeyboardActivityView removeViewAnimated:YES];
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
