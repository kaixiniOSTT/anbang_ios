//
//  PhoneNumValidationViewController.h
//  anbang_ios
//
//  Created by seeko on 14-3-29.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneNumValidationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UITextField *textFieldVerificationCode;
    UIButton *btnLogin;
}
@property (retain,nonatomic) UITableView *tableView;
@property (retain,nonatomic) NSString *countryCode;
@end
