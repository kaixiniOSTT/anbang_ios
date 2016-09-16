//
//  GroupCreatViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 15-3-29.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "sqlite3.h"
#import "JSBadgeView.h"
@interface GroupCreateViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,MFMessageComposeViewControllerDelegate>
{
    sqlite3 *database;
    //判断来自哪个view
    
    // NSMutableArray *dataArray;
    NSMutableArray *searchResults;
    NSMutableArray *selectedResults;
    UISearchBar *mySearchBar;
    UISearchDisplayController *searchDisplayController;
    UISegmentedControl *segmentedControl;
    
    
    
}

@property(nonatomic,retain)NSString *  fromViewFlag;

@property (retain, nonatomic) NSMutableArray *groupMembers;

@property(nonatomic,retain)NSString * groupMucId;
@property(nonatomic,retain)NSString * groupName;
@property(nonatomic,retain)NSString * groupJID;
@property(nonatomic,retain) UIImageView *imageView;
@property(nonatomic,retain)NSString * avtarURL;

@property(nonatomic,retain)NSIndexPath * lastIndexPath;
@property(nonatomic,retain)NSString * selectedAddressBookResults;
//如果有JID，说明此手机号已经注册
@property(nonatomic,retain)NSString * selectedAddressBookJIDResults;
//通讯录名字
@property(nonatomic,retain)NSString * selectedAddressBookNickNameResults;

@end
