//
//  SystemMessageCRUD.m
//  anbang_ios
//
//  Created by seeko on 14-6-9.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "SystemMessageCRUD.h"
#import "PublicCURD.h"


@implementation SystemMessageCRUD
sqlite3 *database;
FMDatabase *db;

+(void)creatSystemMessageTable{
    char *errorMsg;
    const char *createSql="create table if not exists SystemMessageTable (sendName varchar(20),myUserName varchar(20),readMark varchar(10),msg TEXT,time varchar(20))";
    
    //    const char *createSql="create table if not exists IDtable (id integer primary key autoincrement, ID varchar(20))";
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"C1");
    }
    else
    {
        NSLog(@"C0");
    }
}
+(void)insertSytemMessageSendName:(NSString *)sendName myUserName:(NSString *)myUserName readMark:(NSString *)readMark msg:(NSString *)msg msgType:(NSString *)msgType time:(NSString *)time{

    NSString *insertSqlStr= @"insert into SystemMessageTable(sendName,myUserName,readMark,msg,msgType,time) values (?,?,?,?,?,?)";
    
    NSLog(@"****%@",insertSqlStr);

    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
            
            if (![db executeUpdate:insertSqlStr,sendName,myUserName,readMark,msg,msgType,time]) {
                NSLog(@"insert SystemMessage error");
               // [self ErrorReport: (NSString *)insertSqlStr];
            } else {
                
                NSLog(@"insert SystemMessage success");
            }
    }
    [db close];
    
}


+(NSMutableArray *)selectSytemMessage:(NSString *)sendName myUserName:(NSString *)myUserName start:(int)start total:(int)total
{
    NSMutableArray *arr=[[NSMutableArray alloc]init];

    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        NSString *selectSqlStr= [NSString stringWithFormat:@"select msg,time,msgType from SystemMessageTable where sendName=? and myUserName=? order by time desc limit %d,%d", start, total];
        FMResultSet * rs = [db executeQuery:selectSqlStr,sendName,myUserName];
        
        while ([rs next])//SQLITE_OK SQLITE_ROW
        {
            NSString *msg= [rs stringForColumn:@"msg"];
            
            NSString *time= [rs stringForColumn:@"time"];

            NSString *msgType= [rs stringForColumn:@"msgType"];

            [arr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:msg,@"msg",time, @"time",msgType,@"msgType", nil]];
        }
        [rs close];
    }
    
    [db close];
    return arr;

}


+ (int)queryCountUnread:(NSString *)sendName myUserName:(NSString *)myUserName
{

    NSInteger count=0;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select count(*) from SystemMessageTable where sendName=? and myUserName=? and readMark=?";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,sendName,myUserName,@"0"];
        
        while ([rs next])//SQLITE_OK SQLITE_ROW
        {
            count = [rs intForColumnIndex:0];
        }
        [rs close];
    }
    
    [db close];
    return count;

}



//更新表 readmark （已读取）
+(void)updataSytemMessageSendName:(NSString *)sendName myUserName:(NSString *)myUserName readMark:(NSString *)readMark{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"update SystemMessageTable SET readMark='1' WHERE sendName= ? and myUserName= ? and readMark= ? ";
        
        ;
        if (![db executeUpdate:selectSqlStr,sendName,myUserName,@"0"]) {
            NSLog(@"update SystemMessage read failed");
            // [self ErrorReport: (NSString *)insertSqlStr];
        } else {
            
            NSLog(@"update SystemMessage read success");
        }
    }
    
    [db close];
    
}


//更新表 readmark （已读取）
+(void)deleteAllSytemMessage{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"delete from SystemMessageTable";
   
        if (![db executeUpdate:selectSqlStr]) {
            NSLog(@"update SystemMessage read failed");
            // [self ErrorReport: (NSString *)insertSqlStr];
        } else {
            
            NSLog(@"update SystemMessage read success");
        }
    }
    
    [db close];
    
}

//error
+ (void)ErrorReport: (NSString *)item
{

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
}
@end
