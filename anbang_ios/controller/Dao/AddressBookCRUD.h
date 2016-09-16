//
//  AddressBookCRUD.h
//  anbang_ios
//
//  Created by seeko on 14-5-16.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface AddressBookCRUD : NSObject

+(void)creatAddressBookTable;
+(void)insertServerAddressBookMyJid:(NSString *)myJid name:(NSString *)name phoneNum:    (NSString *)PhoneNum jid:(NSString *)jid ver:(NSString *)ver;
+(void)insertLocilAddressBookmyJid:(NSString *)myJid name:(NSString *)name phoneNum:    (NSString *)PhoneNum;

+(void)deleteAddressBookMyJid:(NSString *)myJid;
+(void)deleteAddressBookPhoneNum:(NSString *)phoneNum;
+(NSMutableArray *)selectAddressBookJid;
+(NSMutableArray *)selectAddressBookPhoneNum:(NSString *)myJid;


+(NSMutableArray *)queryAddressBook:(NSString *)myJID;

//群组添加成员服务端通讯录列表
+(NSMutableArray *)queryAddressBookList:(NSString *)myJID groupMembers:(NSMutableArray *)groupMembers;
    
@end
