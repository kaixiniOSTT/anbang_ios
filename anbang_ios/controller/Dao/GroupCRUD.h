//
//  RoomCRUD.h
//  anbang_ios
//
//  Created by silenceSky  on 14-3-26.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "ChatGroup.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface GroupCRUD : NSObject{

    
}
@property(nonatomic,retain) NSMutableArray *onlineUsers;



+ (void)createChatRoomTable;

//多线程写入
+(void) replaceGroup:(NSMutableArray *)insertGroupSqlArray version:(NSString*)ver;

//单线程批量写入
+(void) replaceGroup2:(NSMutableArray *)insertGroupSqlArray;

//查询groupJID version
+(NSMutableArray *)queryGroupInfo:(NSString *)myJID;
    
//根据版本号更新群信息（圈子）
+ (void)updateGroupInfo:(NSString *)groupJID name:(NSString *)name  myJID:(NSString *)myJID version:(NSString *)version modificationDate:(NSString *)modificationDate;

//查询是否有更新
+ (BOOL)queryGroupInfoVersionUpd:(NSString *)groupJID myJID:(NSString *)myJID ver:(NSString *)ver;

//查询圈子类型
+ (NSString *)queryGroupTypeWithJID:(NSString *)groupJID;

+ (int)queryChatRoomTableCountId:(NSString *)jid myJID:(NSString *)myJID;

+(ChatGroup *)queryChatGroupByJID:(NSString *)groupMucId myJID:(NSString *)myJID;

//查询所有圈子
+(NSMutableArray *)queryAllChatGroupByMyJID:(NSString *)myJID;

+(NSMutableArray *)queryMyChatGroupByMyJID:(NSString *)myJID;

//查询自己的圈子个数(fmdb)
+(int)queryCountGroupByMyJID:(NSString *)myJID;

//查询自己的某一个圈子(fmdb)
+(ChatGroup *)queryOneMyChatGroup2:(NSString *)groupJID myJID:(NSString *)myJID;
+(NSDictionary *)queryOneMyChatGroup:(NSString *)groupJID myJID:(NSString *)myJID;

//查询某一个圈子的所有成员
+ (NSMutableArray *)queryGroupMembersByGroupJID:(NSString *)groupJID myJID:(NSString *)myJID;

+ (NSString*) fetchGroupTempName:(NSArray*)groupMembersArray inGroup:(NSString *)groupJID;

//查询某一圈子的创建者 

+ (void)deleteMyGroup:(NSString *)groupJID myJID:(NSString *)myJID;

+ (void)deleteAllMyGroup;

+ (void)dropChatRoomTable;

+ (void)closeDataBase;

// 置顶聊天
+ (void)addStickieTime:(NSString *)stickieTime withJID:(NSString *)groupMucId;
+ (NSString *)queryStickieTimeWithJID:(NSString *)groupMucId;



@end
