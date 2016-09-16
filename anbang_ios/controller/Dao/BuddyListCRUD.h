//
//  BuddyListCRUD.h
//  Icircall_ios
//
//  Created by silenceSky  on 14-3-29.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
@interface BuddyListCRUD : NSObject
+ (void)createBuddyListTable;
+ (void)insertBuddyListTable:(NSString *)jid name:(NSString *)name myJID:(NSString *)myJID;
+ (void)insertBuddyListTable2:(NSString *)jid nickName:(NSString *)nickName name:(NSString *)name phone:(NSString *)phone avatar:(NSString *)avatar  myJID:(NSString *)myJID;
+ (int)queryBuddyListTableCountId:(NSString *)jid myJID:(NSString *)myJID;
+ (void)updateBuddyListTable:(NSString *)jid buddyName:(NSString *)name myJID:(NSString *)myJID;
+(NSMutableArray *)queryBuddyList:(NSString *)myJID;
+(void)dropBuddyListTable;
+ (void)updateBuddyListFromUserInfo:(NSString *)jid nickName:(NSString *)nickName phone:(NSString *)phone avatar:(NSString *)avatar myJID:(NSString *)myJID;
+(NSString *)queryContactsAvatar:(NSString *)contactsUserJID;
+ (void)deleteChatBuddyByChatUserName:(NSString *)contactsUserName;
+(void)dropSubscriptionUserInfoTable;
+ (void)openDataBase;

@end
