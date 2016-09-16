//
//  InvitationFriendsViewControllerNew.h
//  anbang_ios
//
//  Created by silenceSky  on 14-8-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseCircleViewController.h"

@interface InvitationFriendsViewControllerNew : UIViewController<UITableViewDataSource,UITableViewDelegate,ChooseCircleViewDelegate>
@property (retain,nonatomic) UITableView *tableView;
@property (retain,nonatomic) NSString *countryCode;
@property (retain,nonatomic) NSString *countryName;
@end
