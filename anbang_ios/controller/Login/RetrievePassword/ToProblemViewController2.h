//
//  ToProblemViewController2.h
//  anbang_ios
//
//  Created by silenceSky  on 14-7-17.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToProblemViewController2 : UIViewController<UITableViewDataSource,UITableViewDelegate>{

IBOutlet UIView *phoneNumView;
IBOutlet UISegmentedControl *segmentedRetrievePassword;
IBOutlet UIButton *btnCode;
IBOutlet UIButton *btnCountries;
    
    UITextField *textFieldName;
    UIButton *btnLogin;

}

@property (retain,nonatomic) UITableView *tableView;
@property (retain,nonatomic) NSString *countryCode;
@property (retain,nonatomic) NSString *countryName;
@end
