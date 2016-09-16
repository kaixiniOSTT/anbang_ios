//
//  CallContactsViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 14-11-20.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallContactsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (retain,nonatomic) UITableView *tableView;
@property(nonatomic,retain) NSMutableArray *callContactsArray;
@end
