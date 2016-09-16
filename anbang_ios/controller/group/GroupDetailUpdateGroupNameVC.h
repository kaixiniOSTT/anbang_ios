//
//  GroupDetailUpdateGroupNameVC.h
//  anbang_ios
//
//  Created by yangsai on 15/3/30.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupDetailUpdateGroupNameVC;
@protocol GroupDetailUpdateNameDelegate <NSObject>

-(void) groupDetailUpdateNameVC:(GroupDetailUpdateGroupNameVC*) viewController UpdateSuccess:(NSString*)newGroupName;

@end
@interface GroupDetailUpdateGroupNameVC : UIViewController
@property (nonatomic, copy)NSString* groupName;
@property (nonatomic, copy)NSString* groupJid;
@property (nonatomic, copy)NSString* groupMucId;
@property (nonatomic, assign)id<GroupDetailUpdateNameDelegate> delegate ;

@end



