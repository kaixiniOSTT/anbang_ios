//
//  ToAnswerViewController.h
//  anbang_ios
//
//  Created by seeko on 14-3-29.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToAnswerViewController :UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>{
    UIButton *btnLogin;
}
@property (retain,nonatomic) UITableView *tableView;

@end
