//
//  SqliteCRUD.h
//  anbang_ios
//
//  Created by silenceSky  on 14-3-25.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "Contacts.h"


@interface ChatBuddyCRUD : NSObject{
    
}


+ (void)createChatBuddyTable;

//更新通用(fmdb)
+ (void)updateCommonChatBuddy:(NSString *)fieldStr value:(NSString *)str;
//写入 chatBuddy
+ (void)insertChatBuddyTable:(NSString *)chatUserName jid:(NSString *)jid name:(NSString *)name nickName:(NSString *)nickName phone:(NSString *)phone avatar:(NSString *)avatar myUserName:(NSString *)myUserName type:(NSString *)type lastMsg:(NSString *)lastMsg msgType:(NSString *)msgType msgSubject:(NSString *)msgSubject lastMsgTime:(NSString *)lastMsgTime tag:(NSString *)tag;

+ (int)queryChatBuddyTableCountId:(NSString *)chatUserName myUserName:(NSString *)myUserName;

//更新聊天历史列表
+ (void)updateChatBuddy:(NSString *)chatUserName name:(NSString *)name nickName:(NSString *)nickName lastMsg:(NSString *)lastMsg msgType:(NSString *)msgType msgSubject:(NSString *)msgSubject lastMsgTime:(NSString *)lastMsgTime;

//更新聊天历史列表，需更新头像和电话
+ (void)updateChatBuddyTwo:(NSString *)chatUserName name:(NSString *)name nickName:(NSString *)nickName phone:(NSString *)phone avatar:(NSString *)avatar lastMsg:(NSString *)lastMsg msgType:(NSString *)msgType msgSubject:(NSString *)msgSubject lastMsgTime:(NSString *)lastMsgTime;

//删除聊天好友
+ (void)deleteChatBuddyByChatUserName:(NSString *)chatUserName myUserName:(NSString *)myUserName;

+ (void)dropBuddyListTable;

//获取聊天列表
+(NSMutableArray *)queryChatContactsList:(NSString *)userName;

+ (Contacts *)queryBuddyByJID:(NSString *)jid myJID:(NSString *)myJID;

//来消息时查询用户信息，在UserInfo表查询
+(Contacts *)queryUserInfoByJID:(NSString *)jid myJID:(NSString *)myJID;

//查询聊天列表所有未读消息
+ (int)queryAllMsgTotal;

//更新聊天列表的群组名称
+ (void)updateChatBuddyName:(NSString *)newName chatUserName:(NSString *)chatUserName;

+ (void)deleteChatBuddy;

+ (NSArray *)incorrectContacts;

@end
