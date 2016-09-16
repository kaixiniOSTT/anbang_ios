//
//  MessageListViewController.h
//  FriendQuanPro
//
//  Created by MyLove on 15/7/10.
//  Copyright (c) 2015年 Double_yang. All rights reserved.
//

#import "BTNomalBaseViewController.h"

@interface MessageListViewController : BTNomalBaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) UITableView * userTableView;
@property (nonatomic, retain) NSArray * userArray;


@end
