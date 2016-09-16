//
//  ChangePasswordViewController.h
//  anbang_ios
//
//  Created by seeko on 14-3-31.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UITextFieldDelegate>
{
    IBOutlet UITextField *oldPas;
    IBOutlet UITextField *newPas1;
    IBOutlet UITextField *newPas2;
     UIButton *btnLogin;
}
@property (retain,nonatomic) UITableView *tableView;
@end
