//
//  BuddyListCRUD.h
//  anbang_ios
//
//  Created by silenceSky  on 14-3-29.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface ContactsCRUD : NSObject
+ (void)createBuddyListTable;

+ (void)insertContactsTable:(NSString *)jid name:(NSString *)name myJID:(NSString *)myJID;

+ (void)replaceContactsTable:(NSString *)jid name:(NSString *)name myJID:(NSString *)myJID;

//多线程写入(fmdb)
+ (void) replaceContactsTable:(NSMutableArray *)transactionSql ver:(NSString *)ver;

+ (void)insertContactsTable2:(NSString *)jid nickName:(NSString *)nickName name:(NSString *)name phone:(NSString *)phone avatar:(NSString *)avatar  myJID:(NSString *)myJID;


//查询contats count(fmdb)
+ (int)queryContactsCountId:(NSString *)jid myJID:(NSString *)myJID;
+ (BOOL) hasFriends;

+ (BOOL)isFriend:(NSString *)aJID;

+ (void)updateContactsRemarkName:(NSString *)jid remarkName:(NSString *)name myJID:(NSString *)myJID;

//已废弃
+(NSMutableArray *)queryBuddyList:(NSString *)myJID;

//根据UserInfo 表 联合查询(fmdb)
+(NSMutableArray *)queryContactsList:(NSString *)myJID;

//根据UserInfo 表 联合查询(fmdb)
+(NSMutableArray *)queryContactsListTwo:(NSString *)myJID;
    

//根据UserInfo 表 联合查询,并记录是否是圈子成员
+(NSMutableArray *)queryContactsListForAddGroupMembers:(NSString *)myJID groupMembers:(NSMutableArray *)groupMembers;
    
+(void)dropBuddyListTable;

+ (void)updateBuddyListFromUserInfo:(NSString *)jid nickName:(NSString *)nickName remarkName:(NSString *)remarkName phone:(NSString *)phone avatar:(NSString *)avatar myJID:(NSString *)myJID;

//多线程
+ (void)updateContactsFromUserInfoThread:(NSMutableArray *)transactionSql;

+(NSString *)queryContactsAvatar:(NSString *)contactsUserJID;

//查询备注名
+(NSString *)queryContactsRemarkName:(NSString *)contactsUserJID;

//删除联系人
+ (void)deleteContactsByChatUserName:(NSString *)contactsUserName;

//删除所有联系人
+(void)deleteAllContacts;

+(void)dropSubscriptionUserInfoTable;


@end
