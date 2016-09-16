//
//  SettingViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 15-3-24.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController :  UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>{
}
@property (retain,nonatomic) UITableView *myTableView;
@end
