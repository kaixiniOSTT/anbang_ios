//
//  EmailBindingViewController.h
//  anbang_ios
//
//  Created by seeko on 14-3-31.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailBindingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UITextFieldDelegate>
@property (retain,nonatomic) UITableView *tableView;
@end
