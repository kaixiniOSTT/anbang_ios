//
//  BlackListCRUD.m
//  anbang_ios
//
//  Created by silenceSky  on 14-5-10.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "BlackListCRUD.h"
#import "Utility.h"
#import "PublicCURD.h"

@implementation BlackListCRUD
sqlite3 *database;

//黑名单列表数据库操作
+(void)createBlacklistTable
{
    
    char *errorMsg;
    const char *createSql="create table if not exists Blacklist (id integer primary key autoincrement, contactsUserName varchar(20),myUserName varchar(20),addTime varchar(20))";
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"BlackList create ok.");
    }
    else
    {
        NSLog( @"can not create BlackList" );
       // [self ErrorReport:(NSString *)createSql];
    }
}


//insert BlackListTable
+ (void)insertBlackListTable:(NSString *)contactsUserName myUserName:(NSString *)myUserName{
    
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *addTime =[Utility getCurrentTime:@"YY-MM-dd hh:mm"];
    NSString *insertSqlStr=[NSString stringWithFormat:@"insert into Blacklist (contactsUserName,myUserName,addTime) values (\"%@\",\"%@\",\"%@\")",contactsUserName,myUserName,addTime];
    
    NSLog(@"%@",insertSqlStr);
    
    const char *insertSql = [insertSqlStr UTF8String];
    
    if (sqlite3_exec(database, insertSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"insert ok.");
    }
    else
    {
        NSLog( @"can not insert it to table" );
        [self ErrorReport: (NSString *)insertSqlStr];
    }
    [PublicCURD closeDataBaseSQLite];
}

//查询是否存在黑名单
+ (int)queryBlacklistTableCountId:(NSString *)contactsUserName myUserName:(NSString *)myUserName
{
    [PublicCURD openDataBaseSQLite];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select count(id) from Blacklist where  contactsUserName=\"%@\" and myUserName=\"%@\" ",contactsUserName,myUserName];
    const char *selectSql = [selectSqlStr UTF8String];
    int count = 0;
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            count = sqlite3_column_int(statement, 0);
        }
        
    }
    else
    {
        //error
        [self ErrorReport: (NSString *)selectSqlStr];
    }
    
    sqlite3_finalize(statement);
    
    NSLog(@"count %d",count);
    
    [PublicCURD closeDataBaseSQLite];
    return count;
}



//查询我的黑名单
+(NSMutableArray *)queryMyBlackListByMyUserName:(NSString *)myUserName
{
    [PublicCURD openDataBaseSQLite];
    
    NSMutableArray *blackListArray =[[NSMutableArray alloc]init];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select contactsUserName from Blacklist where  myUserName=\"%@\" ",myUserName];
    const char *selectSql = [selectSqlStr UTF8String];
    
    NSLog(@"###############%@",selectSqlStr);
    
    sqlite3_stmt *statement;
    
    
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            // int _id=sqlite3_column_int(statement, 0);
            
            NSString *contactsUserName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            
            [blackListArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:contactsUserName,@"contactsUserName", nil]];
            
            
        }
        NSLog(@"*****%d",blackListArray.count);
    }
    
    [PublicCURD closeDataBaseSQLite];
    return blackListArray;
}


//删除黑名单解绑
+ (void)deleteBlackList:(NSString *)contactsUserName myUserName:(NSString *)myUserName{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *deleteSqlStr=[NSString stringWithFormat:@"DELETE FROM Blacklist where contactsUserName=\"%@\" and myUserName=\"%@\"",contactsUserName,myUserName];
    const char *deleteSql = [deleteSqlStr UTF8String];
    
    if (sqlite3_exec(database, deleteSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"delete ok.");
    }
    else
    {
        NSLog( @"can not delete it" );
        [self ErrorReport: (NSString *)deleteSqlStr];
    }
    [PublicCURD closeDataBaseSQLite];
}

//error
+ (void)ErrorReport: (NSString *)item
{
    [PublicCURD closeDataBaseSQLite];
    char *errorMsg;
    
    const char *itemChar = [item UTF8String];
    
    
    if (sqlite3_exec(database, (const char *)itemChar, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"%@ ok.",item);
    }
    else
    {
        NSLog(@"error: %s",errorMsg);
        sqlite3_free(errorMsg);
    }
    [PublicCURD closeDataBaseSQLite];
}

@end
