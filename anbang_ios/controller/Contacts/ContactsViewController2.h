//
//  ContactsViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 14-4-26.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsViewController2 :  UITableViewController <UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate, UIActionSheetDelegate,UIGestureRecognizerDelegate> {
    UITableView *_tableView;
    UISearchBar *mySearchBar;
    
    UISearchDisplayController *searchDisplayController;
    
    //控制组织架构请求
    NSTimer *mTimer;
    NSInteger mTimeout;
    BOOL mIsSendOrganizationIQ;
}
@property(nonatomic,retain)NSString * myJID;

@property(nonatomic,retain)NSString *clickGroupFlag;  //标识
@property(nonatomic,retain)NSMutableArray *groupArray;
@property(nonatomic,retain)NSArray *contactOtherArray;
@property(nonatomic,retain)NSString *groupName;
@property (nonatomic, retain) NSMutableArray *dataArr;
@property (nonatomic, retain) NSMutableArray *sortedArrForArrays;
@property (nonatomic, retain) NSMutableArray *sectionHeadsKeys;
@property (nonatomic, retain) NSMutableArray *sectionHeadsKeysAll;
@property (strong, nonatomic) IBOutlet UIButton *defaultButton;


@property (nonatomic, strong) UISearchController* searchC;


@end
