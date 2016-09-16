//
//  ToPhoneNumViewController.h
//  anbang_ios
//
//  Created by seeko on 14-3-28.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToPhoneNumViewController :  UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UITextField *txtFieldName;
    UIButton *btnLogin;
}
@property (retain,nonatomic) UITableView *tableView;
@property (retain,nonatomic) NSString *countryCode;
@property (retain,nonatomic) NSString *countryName;

@end
