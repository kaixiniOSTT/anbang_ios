//
//  PhoneNumViewController.h
//  anbang_ios
//
//  Created by seeko on 14-3-20.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
//绑定手机
@interface PhoneNumViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (retain,nonatomic) UITableView *tableView;
@property (retain,nonatomic) NSString *countryCode;
@property (retain,nonatomic) NSString *countryName;
@end
