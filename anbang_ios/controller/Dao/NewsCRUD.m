//
//  NewsCRUD.m
//  anbang_ios
//
//  Created by seeko on 14-5-15.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "NewsCRUD.h"
#import "PublicCURD.h"

@implementation NewsCRUD
sqlite3 *database;
FMDatabase *db;
+(void)creatNews{
    char *errorMsg;
    const char *createSql="create table if not exists News (userName varchar(20) primary key ,readmark int DEFAULT 0)";
    
    //    const char *createSql="create table if not exists IDtable (id integer primary key autoincrement, ID varchar(20))";
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
//        NSLog(@"News create ok.");
    }
    else
    {
//        NSLog( @"can not create News" );
    }
}

+(void)insert:(NSString *)username readMark:(int)mark{
    
    char *errorMsg;
    NSString *insertSqlStr=[NSString stringWithFormat:@"insert or replace into News (userName,readmark) values (\"%@\",\"%d\")",username,mark];
    
    
    const char *insertSql = [insertSqlStr UTF8String];
    
    if (sqlite3_exec(database, insertSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"insert ok.");
    }
    else
    {
        NSLog( @"can not insert it to table" );
    }

    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        if (![db executeUpdate:insertSqlStr]) {
            NSLog(@"error when delete ");
            [self ErrorReport: (NSString *)insertSqlStr];
        } else {
            NSLog(@"success ");
        }
    }
    [db close];
}


+(void)updata:(int) mark userName:(NSString *)username{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE News SET readmark = \"%d\" WHERE userName=\"%@\"",mark,username];
    const char *updateSql = [updateSqlStr UTF8String];
    
    if (sqlite3_exec(database, updateSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
//        NSLog(@"update ok.");
    }
    else
    {
//        NSLog( @"can not update it" );
    }
    [PublicCURD closeDataBaseSQLite];
}


//查询未读取消息
+(NSInteger)quearReadMark:(NSString *)username{
    NSString *selectSqlStr=[NSString stringWithFormat:@"select * from News where  userName=\"%@\" ",username];
//    const char *selectSql = [selectSqlStr UTF8String];
//    sqlite3_stmt *statement;
    NSInteger readmark=0;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        
        while ([rs next])//SQLITE_OK SQLITE_ROW
        {
            NSString *strmark=[rs stringForColumn:@"readmark"];
            
            readmark=[strmark intValue];
        }
        [rs close];
    }
    [db close];
    return readmark;
}

//error
+ (void)ErrorReport: (NSString *)item
{
    char *errorMsg;
    
    const char *itemChar = [item UTF8String];
    
    
    if (sqlite3_exec(database, (const char *)itemChar, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
//        NSLog(@"%@ ok.",item);
    }
    else
    {
//        NSLog(@"error: %s",errorMsg);
        sqlite3_free(errorMsg);
    }
}
@end
