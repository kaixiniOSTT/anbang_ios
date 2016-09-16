//
//  DndInfoCRUD.h
//  anbang_ios
//
//  Created by yangsai on 15/4/7.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface DndInfoCRUD : NSObject

+ (void)createOfRosterExtTable;

//写入群组信息
+ (void)insertOfRosterExtTableWithUserName:(NSString *)userName Jid:(NSString *)jid Dnd:(NSString*) dnd;

//查询jid
+(BOOL)queryOfRosterExtWithJid:(NSString *)Jid;

+(NSInteger)queryOfRosterExtNumberWithJid:(NSString *)Jid;

+(void)updateOfRosterExtWithJid:(NSString *)Jid Dnd:(NSString*)dnd;

+(NSArray*) queryDNDList;
+(NSArray*) queryGroupDNDList;
 
@end
