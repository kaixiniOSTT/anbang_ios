//
//  AIFriendPrivilegeCRUD.m
//  anbang_ios
//
//  Created by rooter on 15-8-3.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIFriendPrivilegeCRUD.h"
#import "FMDatabaseQueue.h"

@implementation AIFriendPrivilegeCRUD

+ (void)setValue:(NSString *)value withColumnKey:(NSString *)columnKey whose:(NSString *)jid
{
    // Open database and create
    // the FMDB operation queue
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES)[0];
    FMDatabaseQueue *queue = [[FMDatabaseQueue alloc] initWithPath:path];
    
    // Prepare the SQL centense,
    // Argument 'columnKey' defined in file '.h'
    // means that column name which is going to be updated
    
    NSString *sql = [NSString stringWithFormat:
                     @"update PrivilegeSetting set %@ = ? where jid = ?", columnKey];
    
    // Excuete the update SQL operation.
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, value, jid];
    }];
    
    [queue close];
}

+ (NSString *)valueWithColumnKey:(NSString *)columnKey whose:(NSString *)jid
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES)[0];
    FMDatabaseQueue *queue = [[FMDatabaseQueue alloc] initWithPath:path];
    
    // Prepare the SQL centense
    // Argument 'columnKey' defined in file '.h'
    // means that column name which is going to be selcted
    
    NSString *sql = [NSString stringWithFormat:
                     @"select %@ from PrivilegeSetting where jid = ?", columnKey];
    
    
    __block NSString *value = nil;
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql, jid];
        while ([rs next]) {
            value = [rs stringForColumn:columnKey];
        }
        [rs close];
    }];
    
    return value;
}


@end
