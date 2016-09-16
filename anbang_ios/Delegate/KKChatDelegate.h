//
//  KKChatDelegate.h
//  anbang_ios
//
//  Created by silenceSky  on 14-4-18.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatGroup.h"
#import "GroupMembers.h"


@protocol KKChatDelegate <NSObject>


-(void)newBuddyOnline:(NSString *)jid buddyName:(NSString *)nickName;
//-(void)newBuddyOffline:(NSString *)buddyName;
//-(void)buddyWentOffline:(NSString *)buddyName;
//用户头像
-(void)avatarReceived:(NSString *)avatarURL;
//订阅关系用户信息
//-(void)userInfoReceived:(NSString *)jid nickName:(NSString *)nickName remarkName:(NSString *)remarkName phone:(NSString *)phone avatar:(NSString *)avatar  queryVer:(NSString *)queryVer remove:(NSString *)remove;


//展示好友列表
//-(void)showBuddyList;

@end
