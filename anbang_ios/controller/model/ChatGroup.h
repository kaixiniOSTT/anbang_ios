//
//  ChatRoom.h
//  anbang_ios
//
//  Created by silenceSky  on 14-3-27.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatGroup : NSObject
@property (retain,nonatomic)  NSString *jid;
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *creator;
@property (retain, nonatomic) NSString *groupMucId;
@property (retain, nonatomic) NSString *myJID;
@property (retain, nonatomic) NSString *version;
@property (retain, nonatomic) NSString *inviteUrl;
@property (retain, nonatomic) NSString *createDate;
@property (retain, nonatomic) NSString *modificationDate;
@property (retain, nonatomic) NSString *removeStr;
@property (retain, nonatomic) NSArray *groupMembersArray;
@property (retain, nonatomic) NSString *groupType;
@end
