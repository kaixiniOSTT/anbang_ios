//
//  GroupDetailUpdateMemNameVC.h
//  anbang_ios
//
//  Created by yangsai on 15/3/30.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GroupDetailUpdateMemNameVC;
@protocol GroupDetailUpdateMemNameDelegate <NSObject>

-(void) groupDetailUpdateMemNameVC:(GroupDetailUpdateMemNameVC*) viewController UpdateSuccess:(NSString*)newGroupMembName;

@end
@interface GroupDetailUpdateMemNameVC : UIViewController
@property (nonatomic, copy)NSString* groupMembName;
@property (nonatomic, copy)NSString* groupJid;
@property (nonatomic, copy)NSString* groupMembJid;
@property (nonatomic, assign)id<GroupDetailUpdateMemNameDelegate> delegate ;
@end
