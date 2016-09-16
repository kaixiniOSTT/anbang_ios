//
//  RoomCRUD.m
//  Icircall_ios
//
//  Created by silenceSky  on 14-3-26.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "RoomCRUD.h"
#import "Utility.h"
#import "ChatRoom.h"


@implementation RoomCRUD

sqlite3 *database;
@synthesize onlineUsers;

//群组数据库操作
+(void)createChatRoomTable
{
      // [self openDataBase];
       char *errorMsg;
        NSString *createSqlStr=@"create table if not exists ChatRoom (id integer primary key autoincrement, jid varchar(50), name varchar(50),creator varchar(50),room varchar(50),myJID varchar(50),createDate varchar(30),modificationDate varchar(30))";
    
          const char *createSql="create table if not exists ChatRoom (id integer primary key autoincrement, jid varchar(50), name varchar(50),creator varchar(50),room varchar(50),myJID varchar(50),createDate varchar(30),modificationDate varchar(30))";
    
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"ChatRoom create ok.");
    }
    else
    {
        NSLog( @"can not create ChatRoom" );
        [self ErrorReport:(NSString *)createSqlStr];
    }
}

//insert buddyListTable
+ (void)insertChatRoomTable:(NSString *)jid name:(NSString *)name creator:(NSString *)creator room:(NSString *)room myJID:(NSString *)myJID createDate:(NSString *)createDate modificationDate:(NSString *)modificationDate
{
    //[self openDataBase];

    char *errorMsg;
    // NSString *addTime = Utility.getCurrentDate;
    NSString *insertSqlStr=[NSString stringWithFormat:@"insert into ChatRoom (jid,name,creator,room,myJID,createDate,modificationDate) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",jid,name,creator,room,myJID,createDate,modificationDate];
    
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
+ (int)queryChatRoomTableCountId:(NSString *)jid myJID:(NSString *)myJID
{
    //[self openDataBase];
    NSString *selectSqlStr=[NSString stringWithFormat:@"select count(id) from ChatRoom where  jid=\"%@\" and myJID = \"%@\" ",jid,myJID];
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



+ (void)updateChatRoomTable:(NSString *)jid name:(NSString *)name myJID:(NSString *)myJID
{
    //[self openDataBase];

    char *errorMsg;
    NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE ChatRoom SET name = \"%@\" WHERE jid=\"%@\" and myJID = \"%@\"",name,jid
                            ,myJID];
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


+ (void)deleteMyGroup:(NSString *)groupJID myJID:(NSString *)myJID
{
    
    NSLog(@"*****%@",groupJID);
    char *errorMsg;
    [self openDataBase];
    NSString *deleteSqlStr=[NSString stringWithFormat:@"DELETE FROM ChatRoom where jid=\"%@\" and myJID=\"%@\"",groupJID,myJID];
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



+(void)dropChatRoomTable
{
    //DROP TABLE ChatMessage;
    [self openDataBase];
    char *errorMsg;
    
    NSString *sqlStr = @"DROP TABLE ChatRoom";
    const char *sql = "DROP TABLE ChatRoom";
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


+(ChatRoom *)queryChatRoomByJID:(NSString *)jid myJID:(NSString *)myJID
{
    //[self openDataBase];
    NSLog(@"###############%@",jid);
    ChatRoom * chatRoom = [[[ChatRoom alloc]init]autorelease];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select id,jid,name,creator,room,createDate,modificationDate from ChatRoom where room=\"%@\" and myJID=\"%@\"",jid,myJID];
    
    NSLog(@"###############%@",selectSqlStr);
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    
    
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            // int _id=sqlite3_column_int(statement, 0);
            
            NSString *jid=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            
            NSString *name=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            
            NSString *creator=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            
            NSString *room=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            
            NSString *createDate=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            
            NSString *modificationDate=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 6) encoding:NSUTF8StringEncoding];
            
            
            
            NSLog(@"%@,%@,%@",name,creator,createDate);
            
            chatRoom.jid = jid;
            chatRoom.name = name;
            chatRoom.creator = creator;
            chatRoom.room = room;
            chatRoom.createDate = createDate;
            chatRoom.modificationDate = modificationDate;
            
        }
    }
    
    return chatRoom;
}



+(NSMutableArray *)queryAllChatRoomByMyJID:(NSString *)myJID
{
   // [self openDataBase];
    
    NSMutableArray *onlineUsers =[[[NSMutableArray alloc]init]autorelease];

    NSString *selectSqlStr=[NSString stringWithFormat:@"select id,jid,name,creator,room,createDate,modificationDate from ChatRoom where myJID = \"%@\" ",myJID];
    
    NSLog(@"###############%@",selectSqlStr);
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    
    
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            // int _id=sqlite3_column_int(statement, 0);
            
            NSString *jid=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            
            NSString *name=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            
            NSString *creator=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            
            NSString *room=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            
            NSString *createDate=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            
            NSString *modificationDate=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 6) encoding:NSUTF8StringEncoding];
            
            
            
            NSLog(@"%@,%@,%@",name,creator,createDate);
            
           [onlineUsers addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",name, @"name",creator,@"creator",room,@"room",createDate,@"createDate", modificationDate, @"modificationDate", nil]];
            
        }
        NSLog(@"*****%d",onlineUsers.count);
    }
    
    return onlineUsers;
}




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


+ (void)closeDataBase{
    sqlite3_close(database);
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
        sqlite3_free(errorMsg);
    }
}



- (void)dealloc
{
        [super dealloc];
}
@end
