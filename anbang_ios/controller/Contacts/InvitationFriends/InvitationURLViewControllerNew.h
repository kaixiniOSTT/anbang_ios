//
//  InvitationURLViewController2.h
//  anbang_ios
//
//  Created by silenceSky  on 14-8-18.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseCircleViewController.h"

@interface InvitationURLViewControllerNew : UIViewController<UITableViewDataSource,UITableViewDelegate,ChooseCircleViewDelegate>
{
    
}
@property (retain,nonatomic) UITableView *tableView;
@property(nonatomic ,retain)NSString *strGroupJID;
@end
