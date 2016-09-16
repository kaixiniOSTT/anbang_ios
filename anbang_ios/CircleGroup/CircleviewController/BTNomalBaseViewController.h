//
//  BTNomalBaseViewController.h
//  BTMoveWorkCompany
//
//  Created by baiteng06 on 14-8-8.
//  Copyright (c) 2014年 baiteng06. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTNomalBaseViewController : UIViewController

@property (strong, nonatomic) UIButton *navLeft;                    // 返回按钮
@property (strong, nonatomic) UIButton *navRight;                   // 导航右侧按钮
@property (nonatomic, strong) UILabel * rightTitle;                 // 右导航标题
@property (strong, nonatomic) UILabel *navTitle;                    // 类标题
@property (strong, nonatomic) UIImageView *customBar;               // 导航视图view

- (void)navLeftBtnAction:(UIButton *)btn;
- (void)navRightBtnAction:(UIButton *)btn;

@end
