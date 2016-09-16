//
//  GroupDetailViewController.h
//  anbang_ios
//
//  Created by yangsai on 15/3/29.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ChatGroup.h"

@class GroupDetailViewController2;

@protocol GroupDetailViewControllerDelegate <NSObject>

-(void)groupDetailViewController:(GroupDetailViewController2*)controllerView    SuccessWithDeteleGroupChatMsg:(NSString*)success;

-(void)groupDetailViewController:(GroupDetailViewController2*)controllerView    SuccessWithUpdateTitleGroupChatMsg:(NSString*)success;

@end

@interface GroupDetailViewController2 : UITableViewController

@property (nonatomic, retain)ChatGroup* group;
@property (nonatomic, assign)id<GroupDetailViewControllerDelegate>delegate;
@end
