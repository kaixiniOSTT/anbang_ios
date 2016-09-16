//
//  GroupChatMessageCRUD.m
//  anbang_ios
//
//  Created by silenceSky  on 14-4-11.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "GroupChatMessageCRUD.h"
#import "PublicCURD.h"
#import "MyFMDatabaseQueue.h"
#import "ChatBuddyCRUD.h"
#import "GroupCRUD.h"

#import "sqlite3.h"
@implementation GroupChatMessageCRUD
sqlite3 *database;
FMDatabase *db;

+ (void)createGroupChatMessageTable
{
    
    
    char *errorMsg;
    NSString *createSqlStr = @"create table if not exists GroupChatMessage (id integer primary key autoincrement, groupMucId text(50),sendUser text(50),myJID text(50), message text,readMark int DEFAULT 0, type text(10),msgType text(10),sendStatus text(20),msgRandomId text(50),sendTime text(20),receiveTime text(20))";
    
    const char *createSql= "create table if not exists GroupChatMessage (id integer primary key autoincrement, groupMucId text(50),sendUser text(50),myJID text(50), message text,readMark int DEFAULT 0, type text(10),msgType text(10),sendStatus text(20),msgRandomId text(50),sendTime text(20),receiveTime text(20))";
    
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"GroupChatMessage create ok.");
    }
    else
    {
        NSLog( @"can not create table" );
        [self ErrorReport:(NSString *)createSqlStr];
    }
    
}

/*--
 //目前表设计为，后进来群组的也可以看到进群组之前的消息
 + (void)insertGroupChatMessage:(NSString *)groupMucId sendUser:(NSString *)userName msg:(NSString *)message type:(NSString *)type  msgType:(NSString*)msgType sendTime:(NSString*)sendTime receiveTime:(NSString*)receiveTime  readMark:(int)readMark sendStatus:(NSString *)sendStatus msgRandomId:(NSString *)msgRandomId myJID:(NSString *)myJID
 {
 [PublicCURD openDataBaseSQLite];
 
 char *errorMsg;
 
 NSLog(@"*************%@,%@,%@,%@,%@,%@",message,userName,groupMucId,type,msgType,sendTime);
 
 // NSString *insertSqlStr=[NSString stringWithFormat:@"insert into GroupChatMessage (room,sendUser,message,type,msgType,sendTime) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",room,userName,message,type,msgType,sendTime];
 
 NSString *insertSqlStr=[NSString stringWithFormat:@"insert into GroupChatMessage (groupMucId,sendUser,message,type,msgType,sendTime,receiveTime ,readMark,sendStatus,msgRandomId,myJID) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",%d,\"%@\",\"%@\",\"%@\")",groupMucId,userName,message,type,msgType,sendTime,receiveTime,readMark,sendStatus,msgRandomId,myJID];
 
 const char *insertSql = [insertSqlStr UTF8String];
 
 if (sqlite3_exec(database, insertSql, NULL, NULL, &errorMsg)==SQLITE_OK)
 {
 NSLog(@"insert  GroupChatMessage ok.");
 }
 else
 {
 NSLog( @"can not insert GroupChatMessage table" );
 [self ErrorReport: (NSString *)insertSqlStr];
 }
 
 [PublicCURD closeDataBaseSQLite];
 
 }
 ---*/



//目前表设计为，后进来群组的也可以看到进群组之前的消息(fmdb)
+ (void)insertGroupChatMessage:(NSString *)groupMucId sendUser:(NSString *)userName msg:(NSString *)message type:(NSString *)type  msgType:(NSString*)msgType sendTime:(NSString*)sendTime receiveTime:(NSString*)receiveTime  readMark:(int)readMark sendStatus:(NSString *)sendStatus msgRandomId:(NSString *)msgRandomId myJID:(NSString *)myJID
{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        
        NSString *insertSqlStr = @"replace into GroupChatMessage (groupMucId,sendUser,message,type,msgType,sendTime,receiveTime ,readMark,sendStatus,msgRandomId,myJID) values (?,?,?,?,?,?,?,?,?,?,?)";
        
        if (![db executeUpdate:insertSqlStr,groupMucId,userName,message,type,msgType,sendTime,receiveTime,[NSNumber numberWithInt:readMark],sendStatus,msgRandomId,myJID]) {
            NSLog(@"error when insertSql GroupChatMessage ");
            
        } else {
            NSLog(@"success to insertSql GroupChatMessage");
        }
    }
    [db close];
}


//目前表设计为，后进来群组的也可以看到进群组之前的消息(fmdb)
+ (void)insertGroupChatMessageMultithread:(NSString *)groupMucId sendUser:(NSString *)userName msg:(NSString *)message type:(NSString *)type  msgType:(NSString*)msgType sendTime:(NSString*)sendTime receiveTime:(NSString*)receiveTime  readMark:(int)readMark sendStatus:(NSString *)sendStatus msgRandomId:(NSString *)msgRandomId myJID:(NSString *)myJID
{
    
    FMDatabaseQueue * queue  = [MyFMDatabaseQueue getSharedInstance];
    dispatch_queue_t q1 = dispatch_queue_create("queue1",   NULL);
    NSString *insertSqlStr = @"insert into GroupChatMessage (groupMucId,sendUser,message,type,msgType,sendTime,receiveTime ,readMark,sendStatus,msgRandomId,myJID) values (?,?,?,?,?,?,?,?,?,?,?)";
    
    dispatch_async(q1, ^{
        [queue inDatabase:^(FMDatabase *db) {
            
            BOOL res = [db executeUpdate:insertSqlStr, groupMucId,userName,message,type,msgType,sendTime,receiveTime,[NSNumber numberWithInt:readMark],sendStatus,msgRandomId,myJID];
            if (!res) {
                NSLog(@"error when insertSql GroupChatMessage Multithread");
            } else {
                NSLog(@"success to insertSql GroupChatMessage Multithread");
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调
        });
    });
    
    // dispatch_release(q1);
    
}



//查询群组未读消息
+ (int)queryGroupCountUnreadMsg:(NSString *)room
{
    int count = 0;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr = @"select count(*) from GroupChatMessage where groupMucId=? and readMark=0";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr, room];
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
            
        }
        [rs close];
    }
    [db close];
    return count;
    
}

//query table
+(int)queryGroupChatMessageCount:(NSString *)room
{
    int count = 0;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select count(id) from GroupChatMessage where groupMucId = ?";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,room];
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
        }
        [rs close];
    }
    [db close];

    return count;
}



//查询当前数据ID(自己是发送者）
+ (NSString*)queryMsgIdByUserName:(NSString *)userName chatWithGroup:(NSString *)chatWithGroup
{
    NSString* msgId = @"0";
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select id from GroupChatMessage where  sendUser= ? and groupMucId= ? order by id desc limit 0, 1";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,userName,chatWithGroup];
        while ([rs next]) {
            msgId = [rs stringForColumnIndex:0];
        }
        [rs close];
    }
    [db close];
    
    return msgId;
}


//查询当前数据ID(自己是发送者）
+ (NSString*)queryIdByUserName:(NSString *)userName chatWithUser:(NSString *)chatWithUser
{
    NSString* msgId = @"0";
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select id, sendUser,message,readMark,receiveUser,msgType,sendTime from GroupChatMessage where  sendUser=? and receiveUser=? order by id desc limit 0, 1";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,userName,chatWithUser];
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
    NSString *selectSqlStr=[NSString stringWithFormat:@"select  message from GroupChatMessage where  id=%d ",msgId];
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            //message=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            message = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            
        }
    }else{
        //error
        [self ErrorReport: (NSString *)selectSqlStr];
    }
    
    
    
    message =  [message stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    
    [PublicCURD closeDataBaseSQLite];
    return message;
}

+ (NSDictionary *)messageWithRandomId:(NSString *)aRandomId {
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select id, message, msgType, sendStatus from GroupChatMessage where msgRandomId = ?", aRandomId];
        while ([rs next]) {
            [md setObject:[rs stringForColumn:@"id"] forKey:@"id"];
            [md setObject:[rs stringForColumn:@"message"] forKey:@"message"];
            [md setObject:[rs stringForColumn:@"msgType"] forKey:@"subject"];
            [md setObject:[rs stringForColumn:@"sendStatus"] forKey:@"sendStatus"];
        }
        [rs close];
    }
    [db close];
    return md;
}


//查询某条消息，返回消息发送人
+ (NSString*)querySenderByMsgId:(int)msgId
{
    [PublicCURD openDataBaseSQLite];
    
    NSString *sendUser = @"";
    NSString *selectSqlStr=[NSString stringWithFormat:@"select  sendUser from GroupChatMessage where  id=%d ",msgId];
    
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
+ (void)deleteTable:(NSString *)msgId
{
    [PublicCURD openDataBaseSQLite];
    
    NSLog(@"*****%@",msgId);
    char *errorMsg;
    
    NSString *deleteSqlStr=[NSString stringWithFormat:@"DELETE FROM GroupChatMessage where id=\"%@\"",msgId];
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


//更新消息状态(fmdb)
+(void)updateGroupChatMessage:(NSString *)groupMucId
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE GroupChatMessage SET readMark = 1 WHERE readMark = 0 and groupMucId=\"%@\"",groupMucId];
        
        
        if (![db executeUpdate:updateSqlStr]) {
            NSLog(@"error when upd GroupChatMessage readMark ");
            
        } else {
            NSLog(@"success to upd GroupChatMessage readMark ");
        }
        
    }
    [db close];
    
}

//更新消息状态(fmdb)
+(void)updateMessageReadMark:(NSString *)msgId readMark:(int)readMark
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE GroupChatMessage SET readMark = %d WHERE id=\"%@\"",readMark, msgId];
        
        
        if (![db executeUpdate:updateSqlStr]) {
            NSLog(@"error when upd GroupChatMessage readMark ");
            
        } else {
            NSLog(@"success to upd GroupChatMessage readMark ");
        }
        
    }
    [db close];
    
}


//更新消息内容
+(void)updateGroupChatMsgStr:(NSString *)msgRandomId msg:(NSString *)msgStr groupMucId:(NSString *)groupMucId
{
    
//    [PublicCURD openDataBaseSQLite];
//    
//    char *errorMsg;
//    
//    NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE GroupChatMessage SET message = \"%@\" WHERE msgRandomId=\"%@\" and groupMucId=\"%@\"",msgStr,msgRandomId,groupMucId];
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
//    
//    [PublicCURD closeDataBaseSQLite];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        BOOL flag = [db executeUpdate:@"update GroupChatMessage set message = ? where msgRandomId = ? and groupMucId = ?", msgStr, msgRandomId, groupMucId];
        if (!flag) {
            JLLog_I(@"Ops! update GroupChatMessage error.");
        }else {
            JLLog_I(@"Yeah! update GroupChatMessage Succeed.");
        }
    }
    [db close];
}


//更新消息发送状态（消息回执)
+ (void)updateMsgByMsgReceipt:(NSString *)msgRandomId sendStatus:(NSString *)sendStatus{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    //[self openDataBase];
    NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE GroupChatMessage SET sendStatus = \"%@\" WHERE msgRandomId=\"%@\"",sendStatus,msgRandomId];
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



//所有图片
+(NSMutableArray *)queryGroupChatPictureMessage:(NSString *)groupMucId{
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select id,sendUser,message,sendTime,type from GroupChatMessage  where  groupMucId= \"%@\" and myJID = \"%@\" and msgType = \"%@\" ",groupMucId,MY_JID,@"image"];
    
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
            NSString *message=[rs stringForColumn:@"message"];
            NSString *sendTime=[rs stringForColumn:@"sendTime"];
            NSString *type = [rs stringForColumn:@"type"];
            message =  [message stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
            
            [msgIdArray addObject:msgId];
            
            [imageArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:sendUser, @"sendUser",message,@"message",sendTime,@"sendTime",msgIdArray,@"msgIdArray",@"image", @"subject", type, @"type", nil]];
        }
    }
    
    [db close];
    return imageArray;
}






//根据msgId 删除消息
+ (void)deleteMyGroupChatMsg:(NSString *)msgId
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    
    NSString *deleteSqlStr=[NSString stringWithFormat:@"DELETE FROM GroupChatMessage where id=\"%@\"",msgId];
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

//根据myjid 删除消息
+ (void)deleteAllGroupChatWithMyJid:(NSString*) myjid
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *deleteSqlStr= @"DELETE FROM GroupChatMessage where myJid = ?";
        if ([db executeUpdate:deleteSqlStr,myjid]) {
            NSLog(@"delete deleteAllGroupChat ok.");
            
        }
        else
        {
            NSLog( @"can not delete GroupChatMessageByGroupMucId" );
        }
    }
    
    [db close];
}


//根据groupMucId 删除消息
+ (void)deleteMyGroupChatMsgByGroupMucId:(NSString *)groupMucId
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *deleteSqlStr= @"DELETE FROM GroupChatMessage where groupMucId = ?";
        if ([db executeUpdate:deleteSqlStr,groupMucId]) {
            NSLog(@"delete GroupChatMessageByGroupMucId ok.");
            [ChatBuddyCRUD updateChatBuddy:groupMucId name:nil nickName:@"" lastMsg:@"" msgType:@"groupchat" msgSubject:@"" lastMsgTime:nil];
        }
        else
        {
            NSLog( @"can not delete GroupChatMessageByGroupMucId" );
        }
    }
    
    [db close];
}

+ (void)deleteMyGroupChatMsgByGroupMucId2:(NSString *)groupMucId
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    
    NSString *deleteSqlStr=[NSString stringWithFormat:@"DELETE FROM GroupChatMessage where groupMucId=\"%@\"",groupMucId];
    const char *deleteSql = [deleteSqlStr UTF8String];
    
    NSString *sqlStr2 = [NSString stringWithFormat:@"DELETE FROM ChatBuddy where chatUserName=\"%@\"",groupMucId];
    
    
    if (sqlite3_exec(database, deleteSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"delete GroupChatMessageByGroupMucId ok.");
    }
    else
    {
        NSLog( @"can not delete GroupChatMessageByGroupMucId" );
        [self ErrorReport: (NSString *)deleteSqlStr];
    }
    const char *sqlDele = [sqlStr2 UTF8String];
    if (sqlite3_exec(database, sqlDele, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"delte ChatBuddy success .");
    }
    else
    {
        NSLog( @"error when delete ChatBuddy " );
        [self ErrorReport: (NSString *)deleteSqlStr];
    }
    
    [PublicCURD closeDataBaseSQLite];
    
}

//查询消息的读过标志
+(int)queryMessageReadMarkByMsgId:(NSString*)msgId
{
    int readMark = 0;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select readMark from GroupChatMessage where id = ?";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,msgId];
        while ([rs next]) {
            readMark = [rs intForColumnIndex:0];
        }
        [rs close];
    }
    [db close];
    
    return readMark;
}




+(void)dropTable
{
    //DROP TABLE ChatMessage;
}


- (BOOL)shouldAutorotate

{
    
    return NO;
    
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

+ (void) setSendingMessagesFailed
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults] objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        [db executeUpdate:@"update GroupChatMessage set sendStatus = 'disconnect' \
         where sendUser = ? and sendStatus = 'connection'", MY_USER_NAME];
    }
    [db close];
}

//更新消息发送时间
+(void)updateMessage:(NSString*)msgId  sendTime:(NSString *)UTCSendTimeStr
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *updateSqlStr = @"UPDATE GroupChatMessage SET sendTime = ?, receiveTime = ? WHERE id = ?";
        
        if (![db executeUpdate:updateSqlStr, UTCSendTimeStr, UTCSendTimeStr, msgId]) {
            NSLog(@"error when update GroupChatMessage sendTime");
        } else {
            NSLog(@"success to update GroupChatMessage sendTime");
        }
        
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
            FMResultSet * rs = [db executeQuery:@"select count(1) from GroupChatMessage where msgRandomId = ?" , msgRandomId];
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
