//
//  ChatMessage.m
//  anbang_ios
//
//  Created by silenceSky  on 14-4-14.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "ChatMessageCRUD.h"
#import "PublicCURD.h"
#import "sqlite3.h"
#import "MyFMDatabaseQueue.h"
#import "ChatBuddyCRUD.h"

@implementation ChatMessageCRUD
sqlite3 *database;
FMDatabase *db;

//－－－－－－－－sqlite3 数据库操作－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－

//create message  table
+ (void)createChatMessage
{
    //flag 0/未读 1/已读
    char *errorMsg;
    NSString *createSqlStr=@"create table if not exists ChatMessage (id integer primary key autoincrement, sendUser text(50), receiveUser text(50),message text,readMark int DEFAULT 0, msgType text(10),subject text(20),sendStatus text(20),msgRandomId text(50), sendTime text(20))";
    
    const char *createSql="create table if not exists ChatMessage (id integer primary key autoincrement, sendUser text(50), receiveUser text(50),message text,readMark int DEFAULT 0, msgType text(10),subject text(20),sendStatus text(20),msgRandomId text(50),sendTime text(20))";
    //    const char *alterSql="ALTER table ChatMessage ADD ";
    //    const char *alterSql2="ALTER table ChatMessage ADD ";
    //    const char *alterSql3="ALTER table ChatMessage ADD message text";
    //    const char *alterSql4="ALTER table ChatMessage ADD flag int DEFAULT 0";
    //    const char *alterSql5="ALTER table ChatMessage ADD sendTime text(20)";

    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"ChatMessage create ok.");
    }
    else
    {
        NSLog( @"can not create table" );
        [self ErrorReport:(NSString *)createSqlStr];
    }
}

/*
//写入聊天纪录
+ (void)insertChatMessage:(NSString *)senderUserName msg:(NSString *)message receiveUser:(NSString *)receiveUser msgType:(NSString*)msgType subject:(NSString*)subjectStr sendTime:(NSString*)sendTime receiveTime:(NSString*)receiveTime readMark:(int)readMark sendStatus:(NSString *)sendStatus msgRandomId:(NSString *)msgRandomId
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    
    NSLog(@"*************%@",msgRandomId);
    
    NSString *insertSqlStr=[NSString stringWithFormat:@"insert into ChatMessage (sendUser,message,receiveUser,msgType,subject,sendTime,receiveTime,sendStatus,msgRandomId,readMark) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",%d)",senderUserName,message,receiveUser,msgType,subjectStr,sendTime,receiveTime,sendStatus,msgRandomId,readMark];
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
*/


//写入聊天纪录
+ (void)insertChatMessage:(NSString *)senderUserName msg:(NSString *)message receiveUser:(NSString *)receiveUser msgType:(NSString*)msgType subject:(NSString*)subjectStr sendTime:(NSString*)sendTime receiveTime:(NSString*)receiveTime readMark:(int)readMark sendStatus:(NSString *)sendStatus msgRandomId:(NSString *)msgRandomId myJID:(NSString *)myJID
{
 
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        
        NSString *insertSqlStr = @"replace into ChatMessage (sendUser,message,receiveUser,msgType,subject,sendTime,receiveTime,sendStatus,msgRandomId,myJID,readMark) values (?,?,?,?,?,?,?,?,?,?,?)";
        
        if (![db executeUpdate:insertSqlStr,senderUserName,message,receiveUser,msgType,subjectStr,sendTime,receiveTime,sendStatus,msgRandomId,myJID,[NSNumber numberWithInt:readMark]]) {
            NSLog(@"error when insertSql ChatMessage");
            
        } else {
            NSLog(@"success to insertSql ChatMessage");
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


//查询某个好友消息总条数
+ (int)queryCountByUserName:(NSString *)userName chatWithUser:(NSString *)chatWithUser
{
    
    int count = 0;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select count(id) from ChatMessage where ((sendUser=\"%@\" and receiveUser=\"%@\") or (sendUser=\"%@\" and receiveUser=\"%@\")) and myJID=\"%@\"",chatWithUser,userName,userName,chatWithUser,MY_JID];
        
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
            
        }
        [rs close];
    }
    [db close];
    return count;
}

+(BOOL)isDuplicatedMessage:(NSString*)message sendTime:(NSString*)sendTime sender:(NSString*)sender
{
    int count = 0;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select count(1) from ChatMessage where sendUser= ? and myJID= ? and message = ? and sendTime = ?";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,sender,MY_JID,message, sendTime];
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
            
        }
        [rs close];
    }
    [db close];
    return count > 0;
}


//查询某个好友未读消息条数
+ (int)queryCountUnread:(NSString *)userName chatWithUser:(NSString *)chatWithUser
{
    int count = 0;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select count(*) from ChatMessage where sendUser=\"%@\" and receiveUser=\"%@\" and myJID=\"%@\" and readMark=%d ",chatWithUser,userName,MY_JID, 0];
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
            
        }
        [rs close];
    }
    [db close];
    return count;
}


//查询当前数据ID(自己是发送者）
+ (NSString*)queryIdByUserName:(NSString *)userName chatWithUser:(NSString *)chatWithUser
{
    NSString* msgId = 0;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select id, sendUser,message,readMark,receiveUser,msgType ,sendTime from ChatMessage where  sendUser=\"%@\" and receiveUser=\"%@\" and myJID=\"%@\" order by id desc limit \"%d\",\"%d\"",userName,chatWithUser,MY_JID,0,1];
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            msgId = [rs stringForColumnIndex:0];
            
        }
        [rs close];
    }
    [db close];
    return msgId;
}



//查询某条消息,返回消息
+ (NSString*)queryMsgByMsgId:(int)msgId
{
    [PublicCURD openDataBaseSQLite];
    
    NSString *message = @"";
        NSString *selectSqlStr=[NSString stringWithFormat:@"select  message,sendUser,readMark,receiveUser,msgType ,sendTime from ChatMessage where  id=%d ",msgId];
        
        const char *selectSql = [selectSqlStr UTF8String];
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
        {
            NSLog(@"select ok.");
            while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
            {
                //message=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
                message = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0) ];
            }
        }else{
            //error
            [self ErrorReport: (NSString *)selectSqlStr];
        }
    
    message =  [message stringByReplacingOccurrencesOfString:@"'" withString:@"\""];

    [PublicCURD closeDataBaseSQLite];
    return message;
}

+ (NSDictionary *)queryMessageWithRandomId:(NSString *)aRandomId {
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select message, subject, id, sendStatus from ChatMessage where msgRandomId = ?", aRandomId];
        while ([rs next]) {
            [md setObject:[rs stringForColumn:@"message"] forKey:@"message"];
            [md setObject:[rs stringForColumn:@"subject"] forKey:@"subject"];
            [md setObject:[rs stringForColumn:@"id"] forKey:@"messageId"];
            [md setObject:[rs stringForColumn:@"sendStatus"] forKey:@"sendStatus"];
        }
    }
    [db close];
    return md;
}


//查询某条消息，返回消息发送人
+ (NSString*)querySenderByMsgId:(int)msgId
{
    [PublicCURD openDataBaseSQLite];
    
    NSString *sendUser = @"";
    NSString *selectSqlStr=[NSString stringWithFormat:@"select  sendUser,readMark,receiveUser,msgType ,sendTime from ChatMessage where  id=%d ",msgId];
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            //sendUser=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            sendUser = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            
        }
    }else{
        //error
        [self ErrorReport: (NSString *)selectSqlStr];
    }
    
    [PublicCURD closeDataBaseSQLite];
    
    return sendUser;
}



//delete table
+ (void)deleteChatMessage:(NSString *)msgId
{
    
    [PublicCURD openDataBaseSQLite];
    
    NSLog(@"*****%@",msgId);
    char *errorMsg;

    NSString *deleteSqlStr=[NSString stringWithFormat:@"DELETE FROM ChatMessage where id=\"%@\"",msgId];
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

//delete table
+ (void)deleteChatMessageByRandomId:(NSString *)msgRandomId
{
    
    [PublicCURD openDataBaseSQLite];
    char *errorMsg;
    
    NSString *deleteSqlStr=[NSString stringWithFormat:@"DELETE FROM ChatMessage where msgRandomId=\"%@\"",msgRandomId];
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


+ (void)updateFlagByUserName:(NSString *)chatWithUser userName:(NSString *)userName
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    //[self openDataBase];
    NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE ChatMessage SET readMark = 1 WHERE sendUser=\"%@\" and receiveUser=\"%@\" and myJID=\"%@\" and readMark=%d",chatWithUser,userName,MY_JID, 0];
    const char *updateSql = [updateSqlStr UTF8String];
    
    if (sqlite3_exec(database, updateSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"update chatMessage readMark ok.");
    }
    else
    {
        NSLog( @"can not update it" );
        [self ErrorReport: (NSString *)updateSqlStr];
    }
    
    [PublicCURD closeDataBaseSQLite];
    
}


//更新消息状态（主要用于voip)
+ (void)updateMsgByMsgRandomId:(NSString *)msgRandomId msg:(NSString *)msg{
//    [PublicCURD openDataBaseSQLite];
//    
//    char *errorMsg;
//    //[self openDataBase];
//    NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE ChatMessage SET message = \"%@\" WHERE msgRandomId=\"%@\"",msg,msgRandomId];
//    const char *updateSql = [updateSqlStr UTF8String];
//    
//    if (sqlite3_exec(database, updateSql, NULL, NULL, &errorMsg)==SQLITE_OK)
//    {
//        NSLog(@"update ok.");
//    }
//    else
//    {
//        NSLog( @"can not update it" );
//        [self ErrorReport: (NSString *)updateSqlStr];
//    }
//    [PublicCURD closeDataBaseSQLite];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        BOOL flag = [db executeUpdate:@"update ChatMessage set message = ? where msgRandomId = ?", msg, msgRandomId];
        if (!flag) {
            JLLog_I(@"Ops! update ChatMessage error.");
        }else {
            JLLog_I(@"Yeah! update ChatMessage Succeed.");
        }
    }
    [db close];
}


//更新消息发送状态（消息回执)
+ (void)updateMsgByMsgReceipt:(NSString *)msgRandomId sendStatus:(NSString *)sendStatus{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    //[self openDataBase];
    NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE ChatMessage SET sendStatus = \"%@\" WHERE msgRandomId=\"%@\"",sendStatus,msgRandomId];
    NSLog(@"*****%@",updateSqlStr);
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
    [PublicCURD closeDataBaseSQLite];
}



//删除与某个联系的聊天纪录
+(void)deleteChatWithUserMessage:(NSString *)myUserName chatWithUserName:(NSString *)chatWithUserName
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    
    NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM ChatMessage where (sendUser=\"%@\" and receiveUser=\"%@\") or (sendUser=\"%@\" and receiveUser=\"%@\")",chatWithUserName,myUserName,myUserName,chatWithUserName];
    const char *sql =  [sqlStr UTF8String];
    
    if (sqlite3_exec(database, sql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"delete ChatWithUserMessage ok.");
    }
    else
    {
        NSLog( @"can not delete ChatWithUserMessage" );
        [self ErrorReport: (NSString *)sqlStr];
    }
    
    [PublicCURD closeDataBaseSQLite];
}



//delete table
+(void)deleteAllChatMessage:(NSString *)myUserName
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;

    NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM ChatMessage where sendUser=\"%@\" or receiveUser=\"%@\"",myUserName,myUserName];
    const char *sql =  [sqlStr UTF8String];

    if (sqlite3_exec(database, sql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"delete ChatMessage ok.");
    }
    else
    {
        NSLog( @"can not delete ChatMessage" );
        [self ErrorReport: (NSString *)sqlStr];
    }
    
    [PublicCURD closeDataBaseSQLite];
}


+(void)dropTable
{
    //DROP TABLE ChatMessage;
}


//通话记录 －－
+(NSMutableArray *)selectChatMessageCallRecords{
    
    [PublicCURD openDataBaseSQLite];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select  sendUser,receiveUser,message,subject,sendTime ,id from ChatMessage where  sendUser=\"%@\" or receiveUser=\"%@\" and myJID=\"%@\" ",MY_USER_NAME,MY_USER_NAME,MY_JID];
    NSMutableArray *collRecordsArr=[NSMutableArray arrayWithObjects:nil, nil];
    NSMutableArray *collRecordsArr1=[NSMutableArray arrayWithObjects:nil, nil];
   // NSMutableArray *collRecordsArr2=[NSMutableArray arrayWithObjects:nil, nil];

    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            NSString *subject=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            if ([subject isEqualToString:@"phone"]||[subject isEqualToString:@"video"]) {
               
                NSString *sendUser=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
                NSString *receiveUser=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
                NSString *message=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
                NSString *sendTime=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
                NSString *id=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];

                if (![sendUser isEqualToString:MY_USER_NAME]) {
                    
                }
                [collRecordsArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:sendUser, @"sendUser",receiveUser,@"receiveUser",message,@"message",subject,@"subject",sendTime,@"sendTime",id,@"msgRandomId",nil]];
              
            }

        }
        
        for (int i=([collRecordsArr count]-1); i>(-1); i--) {
            [collRecordsArr1 addObject:[collRecordsArr objectAtIndex:i]];
        }
        

    }
    
    [PublicCURD closeDataBaseSQLite];
    
    return collRecordsArr1;
}



//通话记录 －－
+(NSMutableArray *)selectChatMessageCallRecords2{
    
    [PublicCURD openDataBaseSQLite];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select  c.sendUser,receiveUser,message,subject,sendTime from ChatMessage c,UserInfo u where  sendUser=\"%@\" or receiveUser=\"%@\" ",MY_USER_NAME,MY_USER_NAME];
    NSMutableArray *collRecordsArr=[NSMutableArray arrayWithObjects:nil, nil];
    NSMutableArray *collRecordsArr1=[NSMutableArray arrayWithObjects:nil, nil];
    // NSMutableArray *collRecordsArr2=[NSMutableArray arrayWithObjects:nil, nil];
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            NSString *subject=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            if ([subject isEqualToString:@"phone"]||[subject isEqualToString:@"video"]) {
                
                NSString *sendUser=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
                NSString *receiveUser=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
                NSString *message=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
                NSString *sendTime=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
                if (![sendUser isEqualToString:MY_USER_NAME]) {
                    
                }
                [collRecordsArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:sendUser, @"sendUser",receiveUser,@"receiveUser",message,@"message",subject,@"subject",sendTime,@"sendTime",nil]];
                
            }
            
        }
        
        for (int i=([collRecordsArr count]-1); i>(-1); i--) {
            [collRecordsArr1 addObject:[collRecordsArr objectAtIndex:i]];
        }
        
        
    }
    
    [PublicCURD closeDataBaseSQLite];
    
    return collRecordsArr1;
}


//所有图片
+(NSMutableArray *)queryChatPictureMessage:(NSString *)chatWithUser{
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select id,sendUser,receiveUser,message,sendTime,subject,msgType from ChatMessage  where  ((sendUser=\"%@\" and receiveUser=\"%@\") or (sendUser=\"%@\" and receiveUser=\"%@\")) and subject = \"%@\" and myJID=\"%@\" ",chatWithUser,MY_USER_NAME,MY_USER_NAME,chatWithUser,@"image",MY_JID];

    NSMutableArray *imageArray=[[NSMutableArray alloc]init];
    NSMutableArray *msgIdArray = [[NSMutableArray alloc]init];

    // NSMutableArray *collRecordsArr2=[NSMutableArray arrayWithObjects:nil, nil];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            NSString * msgId = [rs stringForColumn:@"id"];
            NSString *sendUser=[rs stringForColumn:@"sendUser"];
            NSString *receiveUser=[rs stringForColumn:@"receiveUser"];
            NSString *message=[rs stringForColumn:@"message"];
            NSString *sendTime=[rs stringForColumn:@"sendTime"];
            NSString *subject = [rs stringForColumn:@"subject"];
            NSString *type = [rs stringForColumn:@"msgType"];
           message =  [message stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
            
            [msgIdArray addObject:msgId];
            
            [imageArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:sendUser, @"sendUser",receiveUser,@"receiveUser",message,@"message",sendTime,@"sendTime",msgIdArray,@"msgIdArray",subject, @"subject", msgId, @"id", type, @"type", nil]];
        }
        
        [rs close];
    }
    
    [db close];
    return imageArray;
}


//返回消息id
+(NSString *)queryMessageId:(NSString *)chatWithUser{
    NSString * msgId= 0 ;
    NSString *selectSqlStr=[NSString stringWithFormat:@"select id, sendUser,message,readMark,receiveUser,msgType ,subject,sendTime from ChatMessage where (sendUser=\"%@\" and receiveUser=\"%@\") or (sendUser=\"%@\" and receiveUser=\"%@\") and myJID=\"%@\" order by id desc limit %d,%d",chatWithUser,MY_USER_NAME,MY_USER_NAME,chatWithUser,MY_JID,0,1];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            msgId= [rs stringForColumn:@"id"];
        }
        [rs close];
    }
    
    [db close];
    return msgId;
}

+ (void)deleteChatWithUserMessage2:(NSString *)myUserName chatWithUserName:(NSString *)chatWithUserName{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        
        NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM ChatMessage where sendUser=\"%@\" or receiveUser=\"%@\" and myJID=\"%@\"",chatWithUserName,chatWithUserName,MY_JID];

        if (![db executeUpdate:sqlStr]) {
            NSLog(@"error when delete ChatMessage !");
        }else{
            NSLog(@" delete ChatMessage success ! ");
            [ChatBuddyCRUD updateChatBuddy:chatWithUserName name:nil nickName:@"" lastMsg:@"" msgType:@"chat" msgSubject:@"" lastMsgTime:nil];
        }

    }
    [db close];
}

+ (NSString *)querySendTimeWithRandomId:(NSString *)aRandomId {
    __block NSString *sendTime = nil;
    FMDatabaseQueue *queue = [MyFMDatabaseQueue getSharedInstance];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select sendTime from ChatMessage where msgRandomId = ?", aRandomId];
        while ([rs next]) {
            sendTime = [rs stringForColumn:@"sendTime"];
        }
    }];
    [MyFMDatabaseQueue close];
    return sendTime;
}


//查询消息的读过标志
+(int)queryMessageReadMarkByMsgId:(NSString*)msgId
{
    int readMark = 0;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select readMark from ChatMessage where id = ?";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,msgId];
        while ([rs next]) {
            readMark = [rs intForColumnIndex:0];
        }
        [rs close];
    }
    [db close];
    
    return readMark;
}

//更新消息状态(fmdb)
+(void)updateMessageReadMark:(NSString *)msgId readMark:(int)readMark
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE ChatMessage SET readMark = %d WHERE id=\"%@\"",readMark, msgId];
        
        
        if (![db executeUpdate:updateSqlStr]) {
            NSLog(@"error when upd ChatMessage readMark ");
            
        } else {
            NSLog(@"success to upd ChatMessage readMark ");
        }
        
    }
    [db close];
    
}

//更新消息发送时间
+(void)updateMessage:(NSString*)msgId  sendTime:(NSString *)UTCSendTimeStr
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *updateSqlStr = @"UPDATE ChatMessage SET sendTime = ?, receiveTime = ? WHERE id= ?";
        
        if (![db executeUpdate:updateSqlStr, UTCSendTimeStr, UTCSendTimeStr, msgId]) {
            NSLog(@"error when update ChatMessage sendTime");
        } else {
            NSLog(@"success to update ChatMessage sendTime");
        }
        
    }
    [db close];
}

+ (void) setSendingMessagesFailed
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults] objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        [db executeUpdate:@"update ChatMessage set sendStatus =  \
         'disconnect' where sendUser = ? and sendStatus = 'connection'" , MY_USER_NAME];
    }
    [db close];
}

+(BOOL)isReplicatedMessage:(NSString*)msgRandomId
{
    if(msgRandomId != nil && msgRandomId.length >= 32){
        int count = 0;
        NSString *database_path = [[NSUserDefaults standardUserDefaults] objectForKey:SQLITE_DB_PATH];
        db =  [FMDatabase databaseWithPath:database_path];
        if ([db open]) {
            FMResultSet * rs = [db executeQuery:@"select count(1) from ChatMessage where msgRandomId = ?" , msgRandomId];
            while ([rs next]) {
                count = [rs intForColumnIndex:0];
            }
            [rs close];
        }
        [db close];
        return count > 0;
    }

    return NO;
}

@end
