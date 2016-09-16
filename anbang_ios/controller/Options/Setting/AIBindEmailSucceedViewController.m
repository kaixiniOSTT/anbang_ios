//
//  AIBindEmailSucceedViewController.m
//  anbang_ios
//
//  Created by rooter on 15-4-2.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBindEmailSucceedViewController.h"

@interface AIBindEmailSucceedViewController ()

@end

@implementation AIBindEmailSucceedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupController];
    
    [self setupInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupController {
    
    self.title = @"绑定邮箱";
    mUserInfo = [UserInfo loadArchive];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake(5, 80, 30, 30);
    [button setImage:[UIImage imageNamed:@"header_button_back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backMove:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    item.title = @"";
    self.navigationItem.leftBarButtonItem = item;
}

- (void)backMove:(UIButton *)sender {
    
    UIViewController *controller = self.navigationController.viewControllers[2];
    [self.navigationController popToViewController:controller animated:YES];
}

- (void)setupInterface {
    
    UIView *view = [self contentView];
    view.center = self.view.center;
    [self.view addSubview:view];
}

- (UIView *)contentView {
    
    CGFloat view_w = Screen_Width - MARGIN_LEFT_RIGHT * 2;
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [view addSubview:imageView];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame), view_w, 35)];
    headerLabel.textColor = AB_Gray_Color;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.textColor = AB_Red_Color;
    headerLabel.text = [self headerTip];
    [view addSubview:headerLabel];
    
    UILabel *label_row_2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerLabel.frame), view_w, 35)];
    label_row_2.textColor = AB_Gray_Color;
    label_row_2.textAlignment = NSTextAlignmentCenter;
    label_row_2.text = [NSString stringWithFormat:@"您的邮箱：%@", self.email];
    [view addSubview:label_row_2];
    
    CGFloat dt_lb_w = view_w - MARGIN_LEFT_RIGHT * 6;
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT * 3, CGRectGetMaxY(label_row_2.frame), dt_lb_w, 40)];
    detailLabel.font = [UIFont systemFontOfSize:13.5];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.textColor = AB_Gray_Color;
    detailLabel.numberOfLines = 0;
    detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    detailLabel.text = @"邮箱作为用户名可登录邦邦社区，也可以用来找回密码";
    [view addSubview:detailLabel];

    UILabel *label_row_4 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(detailLabel.frame), view_w, 35)];
    label_row_4.textColor = AB_Gray_Color;
    label_row_4.textAlignment = NSTextAlignmentCenter;
    label_row_4.text = [self bottomTip];
    [view addSubview:label_row_4];
    
    view.frame = CGRectMake(0, 0, view_w, CGRectGetMaxY(label_row_4.frame));
    return view;
}

- (NSString *)headerTip {
    
    return mUserInfo.accountType == 2 ? [NSString stringWithFormat:@"我是安邦人：%@", mUserInfo.employeeName] : @"绑定成功";
}

- (NSString *)bottomTip {
    
    return mUserInfo.accountType == 2 ? @"你不能解绑此邮箱" : @"";
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
