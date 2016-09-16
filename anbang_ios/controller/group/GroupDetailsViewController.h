//
//  GroupDetailsViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 14-3-28.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatGroup.h"

@interface GroupDetailsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate >
{
    
}

@property (retain, nonatomic) NSMutableArray *groupMembers;
@property (retain, nonatomic) ChatGroup *chatGroups;
@property (retain, nonatomic) NSString *groupJID;
@property (retain, nonatomic) NSString *creator;
@property (retain, nonatomic) NSString *deleteGroupMemberJID;


@property (retain,nonatomic) UITableView *myTableView;

@end
