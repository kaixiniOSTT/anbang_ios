//
//  MultiplayerTalkCRUD.h
//  anbang_ios
//
//  Created by silenceSky  on 14-8-8.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface MultiplayerTalkCRUD : NSObject
//创建 MultiplayerTalk
+ (void)createMultiplayerTalkTable;

//insert MultiplayerTalk table(fmdb)
+ (void)insertMultiplayerTable:(NSString *)jid thread:(NSString *)thread nickName:(NSString *)nickName role:(int)role;

//多线程写入
+(void) updateMultiplayerTalkMultithread:(NSMutableArray *)transactionSql;

//upd MultiplayerTalk table(fmdb)
+ (void)updateMultiplayerTalk:(NSString *)sql;

//查询群组成员名字拼接成对话标题（fmdb)
+(NSString *)queryMultiplayerTalkMembersNickName:(NSString *)threadId;

//查询群组成员，根据userInfo 表 myJID 查询(fmdb)
+(NSMutableArray *)queryMultiplayerTalkMembers:(NSString *)threadId myJID:(NSString *)myJID;
@end
