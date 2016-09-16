//
//  GroupMembersCRUD.h
//  anbang_ios
//
//  Created by silenceSky  on 14-3-28.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "ChatGroup.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
@interface GroupMembersCRUD : NSObject
@property(nonatomic,retain) NSMutableArray *onlineUsers;

//多线程写入
+(void) replaceGroupMembersTable:(NSMutableArray *)insertGroupMembersSqlArray;


// 更新圈子成员名称
+ (void)updateGroupMemberName:(NSString *)jid nickName:(NSString *)nickName groupJID:(NSString *)groupJID;

//查询群组成员，根据userInfo 表 myJID 查询
+(NSMutableArray *)queryChatRoomByGroupJID:(NSString *)groupJID myJID:(NSString *)myJID;

//模糊查询群成员
+(NSMutableArray *)queryMembersByKeyword:(NSString *)keyword groupJID:(NSString *)groupJID myJID:(NSString *)myJID;

//查询群组成员，根据userInfo 表 myJID 查询(fmdb)
+(NSMutableArray *)queryChatRoomByGroupJID2:(NSString *)groupJID myJID:(NSString *)myJID;

//查询某个圈子某个成员的名称(fmdb)
+(NSMutableDictionary *)queryMemberNameByMemberJID:(NSString *)groupJID memberJID:(NSString *)memberJID myJID:(NSString *)myJID;

//删除某个群组成员(fmdb)
+(void)deleteGroupMember:(NSString *)groupJID memberJID:(NSString *)memberJID myJID:(NSString *)myJID;

//删除某个群组成员
+(void)deleteGroupMember2:(NSString *)groupJID memberJID:(NSString *)memberJID myJID:(NSString *)myJID;

//删除某个群组的所有成员(fmdb)
+(void)deleteAllGroupMemberByGroupId:(NSString *)groupJID  myJID:(NSString *)myJID;

//删除全部群组成员(fmdb)
+(void)deleteAllGroupMember:(NSString *)myJID;

//查询某一个群成员的在群的昵称
+ (NSString *)queryNickNameWithGroupJID:(NSString *)groupJID memberJID:(NSString *)memberJID;

+ (BOOL)group:(NSString *)groupJID existsMember:(NSString *)jid;

@end
