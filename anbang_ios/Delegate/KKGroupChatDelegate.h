//
//  GroupChatDelegate.h
//  anbang_ios
//
//  Created by silenceSky  on 14-4-18.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupMembers.h"
#import "ChatGroup.h"

@protocol KKGroupChatDelegate <NSObject>
//圈子信息
-(void)chatGroupReceived:(ChatGroup*)chatGroup;

//圈子成员信息
-(void)groupMembersReceived:(GroupMembers*)groupMembers;
@end
