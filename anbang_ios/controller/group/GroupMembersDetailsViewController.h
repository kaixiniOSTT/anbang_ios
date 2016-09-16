//
//  GroupMembersDetailsViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 14-5-16.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupMembersDetailsViewController :UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate >{
    UIImage *contactsAvatar;
    NSString *loadData;
    NSURLConnection *connection;
    
}

@property (retain,nonatomic) UITableView *tableView;
@property (retain,nonatomic) NSString *contactsUserName;

@property (retain,nonatomic) NSString *groupJID;
@property (retain,nonatomic) NSString *groupMucJID;
@property (retain,nonatomic) NSString *groupCreator;

@property (retain,nonatomic) NSString *contactsNickName;
@property (retain,nonatomic) NSString *circleNickName;

@property (retain,nonatomic) NSString *contactsAvatarURL;
@property (retain,nonatomic) NSString *contactsJID;

@property (nonatomic, retain) NSString *blackListStatus;

@property (nonatomic, retain) NSString *fileName;

@end
