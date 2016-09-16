//
//  QuanDetailViewController.h
//  FriendQuanPro
//
//  Created by MyLove on 15/7/16.
//  Copyright (c) 2015年 Double_yang. All rights reserved.
//

#import "BTNomalBaseViewController.h"
#import "FQButtonWithNum.h"
#import "DXMessageToolBar.h"
#import "UIViewController+HUD.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "DXChatBarMoreView.h"
#import <AVFoundation/AVFoundation.h>
#import "MWPhotoBrowser.h"
#import "MWPhoto.h"

@interface QuanDetailViewController : BTNomalBaseViewController<UITableViewDataSource,UITableViewDelegate,DXMessageToolBarDelegate,DXChatBarMoreViewDelegate,MWPhotoBrowserDelegate,UIActionSheetDelegate>
{
    UIView *mainView;
}
@property (assign) int curDicIndex;
@property (nonatomic,retain) UITableView *trendsTab;
@property (nonatomic, retain) NSDictionary * detailDic;
@property (nonatomic, retain) NSString * comeStr;

@end
