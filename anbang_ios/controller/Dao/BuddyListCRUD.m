//
//  BuddyListCRUD.m
//  Icircall_ios
//
//  Created by silenceSky  on 14-3-29.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "BuddyListCRUD.h"
#import "Utility.h"

@implementation BuddyListCRUD
sqlite3 *database;

//好友列表数据库操作
//create BuddyList  table
+ (void)createBuddyListTable
{
    
    
    char *errorMsg;
    NSString *createSqlStr=@"create table if not exists BuddyList (id integer primary key autoincrement, jid varchar(50), name varchar(50),nickName varchar(50),avatar varchar, phone varchar(15),myJID varchar(50), addTime varchar(20)";
    
    const char *createSql="create table if not exists BuddyList (id integer primary key autoincrement, jid varchar(50), name varchar(50) DEFAULT('') ,nickName varchar(50),avatar varchar, phone varchar(15),myJID varchar(50),addTime varchar(20))";
    
    
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"BuddyList create ok.");
    }
    else
    {
        NSLog( @"can not create table" );
        [self ErrorReport:(NSString *)createSqlStr];
    }
}

//insert buddyListTable
+ (void)insertBuddyListTable:(NSString *)jid name:(NSString *)name myJID:(NSString *)myJID
{
    
    char *errorMsg;
    NSString *nickName = @"";
    NSString *annotationName = @"";
    NSString *phone = @"";
    NSString *avatar = @"";
    
    
    NSString *addTime = Utility.getCurrentDate;
    NSString *insertSqlStr=[NSString stringWithFormat:@"insert into BuddyList (jid,name,nickName,phone,avatar,myJID,addTime) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",jid,annotationName, nickName,phone,avatar,myJID,addTime];
    
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
}



//insert buddyListTable
+ (void)insertBuddyListTable2:(NSString *)jid nickName:(NSString *)nickName name:(NSString *)name phone:(NSString *)phone avatar:(NSString *)avatar  myJID:(NSString *)myJID
{
    char *errorMsg;
    NSString *addTime = Utility.getCurrentDate;
 
    NSString *insertSqlStr=[NSString stringWithFormat:@"insert into BuddyList (jid,name,nickName,phone,avatar,myJID,addTime) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",jid,name, nickName,phone,avatar,myJID,addTime];
    
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
}


//query table
+ (int)queryBuddyListTableCountId:(NSString *)jid myJID:(NSString *)myJID
{
    [self openDataBase];
    NSString *selectSqlStr=[NSString stringWithFormat:@"select count(id) from BuddyList where  jid=\"%@\" and myJID =\"%@\" ",jid,myJID];
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
    
    return count;
}


+(NSMutableArray *)queryBuddyList:(NSString *)myJID{
    
    NSMutableArray *contactsArray =[[[NSMutableArray alloc]init]autorelease];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select id,jid,name,nickName,phone,avatar,addTime from BuddyList where myJID = \"%@\"",myJID];
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    
    
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            //int _id=sqlite3_column_int(statement, 0);
            
            NSString *jid=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            
            NSString *name=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            
            NSString *nickName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            
            NSString *phone=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            
            NSString *avatar=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            
            NSString *addTime=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 6) encoding:NSUTF8StringEncoding];
            
            NSLog(@"%@,%@,%@",nickName,phone,avatar);
            [contactsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"userName",name, @"name",nickName,@"nickName",phone,@"phone",avatar,@"avatar", addTime, @"addTime", nil]];
            
        }
    }
    return contactsArray;
}


+(NSString *)queryContactsAvatar:(NSString *)contactsUserJID{
    
    NSMutableArray *contactsArray =[[[NSMutableArray alloc]init]autorelease];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select avatar from BuddyList where jid = \"%@\"",contactsUserJID];
    
    NSString *avatar = @"";
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    
    
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
       
            avatar=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
        
        }
    }
    return avatar;
}


+ (void)updateBuddyListTable:(NSString *)jid buddyName:(NSString *)name myJID:(NSString *)myJID
{
    
    char *errorMsg;
    NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE BuddyList SET name = \"%@\" WHERE jid=\"%@\" and myJID=\"%@\"",name,jid,myJID
                            ];
    const char *updateSql = [updateSqlStr UTF8String];
    
    if (sqlite3_exec(database, updateSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"update ok.");
    }
    else
    {
        NSLog( @"can not update it" );
        [self ErrorReport: (NSString *)updateSqlStr];
    }
    
}



+(void)dropBuddyListTable
{
    //DROP TABLE ChatMessage;
    
    char *errorMsg;
    //[self openDataBase];
    NSString *sqlStr = @"DROP TABLE BuddyList";
    const char *sql = "DROP TABLE BuddyList";
    if (sqlite3_exec(database, sql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"drop ok.");
    }
    else
    {
        NSLog( @"can not drop it" );
        [self ErrorReport: (NSString *)sqlStr];
    }
    
}



/*获取userInfo 更新好友列表------------------------------------------------------------------------------------------------------------------*/


+ (void)updateBuddyListFromUserInfo:(NSString *)jid nickName:(NSString *)nickName phone:(NSString *)phone avatar:(NSString *)avatar myJID:(NSString *)myJID
{
    
    char *errorMsg;
    NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE BuddyList SET nickName = \"%@\",phone = \"%@\",avatar = \"%@\" WHERE jid=\"%@\" and myJID = \"%@\" ",nickName,phone,avatar,jid,myJID];
    const char *updateSql = [updateSqlStr UTF8String];
    
    if (sqlite3_exec(database, updateSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"update ok.");
    }
    else
    {
        NSLog( @"can not update it" );
        [self ErrorReport: (NSString *)updateSqlStr];
    }
    
}

//删除聊天好友
+ (void)deleteChatBuddyByChatUserName:(NSString *)contactsUserName{
    char *errorMsg;
    NSString *deleteSqlStr=[NSString stringWithFormat:@"DELETE FROM BuddyList where jid=\"%@\"",contactsUserName];
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
}






+(void)dropSubscriptionUserInfoTable
{
    //DROP TABLE ChatMessage;
    
    char *errorMsg;
    [self openDataBase];
    NSString *sqlStr = @"DROP TABLE SubscriptionUserInfo";
    const char *sql = "DROP TABLE BuddyList";
    if (sqlite3_exec(database, sql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"drop ok.");
    }
    else
    {
        NSLog( @"can not drop it" );
        [self ErrorReport: (NSString *)sqlStr];
    }
}

//open database
+ (void)openDataBase
{
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                , NSUserDomainMask
                                                                , YES);
    NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"db.sql"];
    
    if (sqlite3_open([databaseFilePath UTF8String], &database)==SQLITE_OK)
    {
        NSLog(@"open sqlite db ok.");
    }
    else
    {
        NSLog( @"can not open sqlite db " );
        
        //close database
        sqlite3_close(database);
    }
}


//error
+(void)ErrorReport: (NSString *)item
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
        // sqlite3_free(errorMsg);
    }
}



@end
