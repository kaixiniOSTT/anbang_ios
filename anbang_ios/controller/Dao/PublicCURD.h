//
//  PublicCURD.h
//  anbang_ios
//
//  Created by silenceSky  on 14-6-11.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface PublicCURD : NSObject
//创建表(fmdb)
+ (void)createAllTable;
//升级
+(void)updateTable;
+ (void)updateDatabase;

//创建公共数据库表(fmdb)
+ (void)createPublicTable;

//清除所有消息(fmdb)
+ (void)deleteAllMsg;

//create database(fmdb)
+ (void)createDataBase;

+ (void)createPublicDataBase;

//Open database(fmdb)
+ (void)openDataBase;

//Close database(fmdb)
+ (void)closeDataBase;

+(void)openDataBaseSQLite;

+ (void)closeDataBaseSQLite;

//Open public database(fmdb)
+ (void)openPublicDataBase;

//Close public database(fmdb)
+ (void)closePublicDataBase;

+ (NSArray *) didSearchContactWithKeyword:(NSString *)keyword;

+ (NSArray *)searchFriendsWithKeyword:(NSString *)keyword;

+ (NSArray *)searchGroupsWithKeyword:(NSString *)keyword;

@end
