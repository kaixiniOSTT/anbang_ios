//
//  MDPersonCenterViewController.h
//  FriendQuanPro
//
//  Created by MyLove on 15/7/14.
//  Copyright (c) 2015年 Double_yang. All rights reserved.
//

#import "BTNomalBaseViewController.h"
#import "MJRefresh.h"

@interface MDPersonCenterViewController : BTNomalBaseViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,MJRefreshBaseViewDelegate,UIGestureRecognizerDelegate>
{
    UIView *mainView;
}

@property (nonatomic,retain) UITableView *trendsTab;
@property (nonatomic, retain) MJRefreshHeaderView * header;
@property (nonatomic, retain) MJRefreshFooterView * footer;
@property (nonatomic, retain) NSDictionary * userDic;

@end
