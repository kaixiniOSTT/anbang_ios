//
//  UserInfoCRUD.h
//  anbang_ios
//
//  Created by silenceSky  on 14-5-16.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "UserInfo.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface UserInfoCRUD : NSObject

//创建UserInfo
+ (void)createUserInfoTable;

//insert UserInfo table
+ (void)insertUserInfoTable:(NSString *)jid remarkName:(NSString *)remarkName nickName:(NSString *)nickName phone:(NSString *)phone avatar:(NSString *)avatar ver:(NSString *)ver myJID:(NSString *)myJID;

+ (BOOL)addAnUserInfo:(UserInfo *)userInfo;

//多线程
+(void) insertUserInfoTableMultithread:(NSMutableArray *)transactionSql;

//事务写入
+ (void)insertUserInfoTable2:(NSMutableArray *)transactionSql;

//查询是否已经存在此用户
+ (int)queryUserInfoTableCountId:(NSString *)jid myJID:(NSString *)myJID;

//查询是否有更新
+ (BOOL)queryUserInfoVersionUpd:(NSString *)jid myJID:(NSString *)myJID ver:(NSString *)ver;

//更新UserInfo
+ (void)updateUserInfo:(NSString *)jid remarkName:(NSString *)remarkName nickName:(NSString *)nickName phone:(NSString *)phone avatar:(NSString *)avatar version:(NSString *)version myJID:(NSString *)myJID;

//查询某个用户userInfo 信息
+ (UserInfo *)queryUserInfo:(NSString *)jid myJID:(NSString *)myJID;
    
//多线程更新
+(void) updateUserInfoMultithread:(NSMutableArray *)transactionSql;

//删除用户
+ (void)deleteUserInfoByJIDAndMyJID:(NSString *)jid myJID:(NSString *)myJID;

//查询用户头像
+(NSString *)queryUserInfoAvatar:(NSString *)userJID;

//查询用户的accountType
+ (int)queryUserInfoAccountTypeWith:(NSString *)userJID;

// select name
+ (NSString *)employeeNameWithJID:(NSString *)aJID;
+ (NSString *)nickNameWithJID:(NSString *)aJID;

//查询用户是否有订阅关系用户
+ (int)queryUserInfoTableTotal:(NSString *)myJID;

//删除所有用户数据
+(void)deleteAllUserInfo;



+(NSString *)selectUserInfoAvatarWithJID:(NSString *)jid myJID:(NSString *)myJID;

// 置顶聊天
+ (void)addStickieTime:(NSString *)stickieTime withJID:(NSString *)memberJID;
+ (NSString *)queryStickieTimeWithJID:(NSString *)memberJID;


+ (NSArray*)queryUserInfoForJid;

// Save signature
+ (void)saveSignature:(NSString *)aValue targetJID:(NSString *)aJID;
+ (NSString *)signatureWithJID:(NSString *)aJID;

// Save area
+ (void) saveAreaId:(NSString *)aValue targetJID:(NSString *)aJID;

@end
