//
//  MDNomalQuanViewController.h
//  DecorationPro
//
//  Created by MyLove on 15-6-24.
//  Copyright (c) 2015年 Doule_Yang. All rights reserved.
//

#import "BTNomalBaseViewController.h"
#import "MJRefresh.h"
#import "MWPhotoBrowser.h"
#import "MWPhoto.h"
#import "DXMessageToolBar.h"

@interface MDNomalQuanViewController : BTNomalBaseViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,MJRefreshBaseViewDelegate,UIGestureRecognizerDelegate,MWPhotoBrowserDelegate,DXMessageToolBarDelegate,DXChatBarMoreViewDelegate,UIAlertViewDelegate>
{
    UIView *mainView;
}

@property (nonatomic,retain) UITableView *trendsTab;
@property (nonatomic, retain) MJRefreshHeaderView * header;
@property (nonatomic, retain) MJRefreshFooterView * footer;

@end
