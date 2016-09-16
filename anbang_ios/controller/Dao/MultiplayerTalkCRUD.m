//
//  MultiplayerTalkCRUD.m
//  anbang_ios
//
//  Created by silenceSky  on 14-8-8.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "MultiplayerTalkCRUD.h"
#import "Utility.h"
#import "UserInfo.h"
#import "MyFMDatabaseQueue.h"

@implementation MultiplayerTalkCRUD
sqlite3 *database;
FMDatabase *db;

//create MultiplayerTalk  table
+ (void)createMultiplayerTalkTable
{
    
    char *errorMsg;
    NSString *createSqlStr=@"create table if not exists MultiplayerTalk (jid varchar(50),threadId varchar(100),nickName varchat(50),role int(10), addTime varchar(20),primary key(jid,threadId))";
    
    const char *createSql="ccreate table if not exists MultiplayerTalk (jid varchar(50),thread varchar(100),nickName varchat(50),role int(10), addTime varchar(20),primary key(jid,threadId))";
    
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"MultiplayerTalk create ok.");
    }
    else
    {
        NSLog( @"can not create MultiplayerTalk" );
        [self ErrorReport:(NSString *)createSqlStr];
    }
}



//insert MultiplayerTalk table(fmdb)
+ (void)insertMultiplayerTable:(NSString *)jid thread:(NSString *)thread nickName:(NSString *)nickName role:(int)role
{
    
    NSString *addTime = Utility.getCurrentDate;
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        
        NSString *insertSqlStr=[NSString stringWithFormat:@"replace into MultiplayerTalk (jid,threadId,nickName,role,addTime) values (\"%@\",\"%@\",\"%@\",%d,\"%@\")",jid,thread,nickName,role,addTime];
        
        if (![db executeUpdate:insertSqlStr]) {
            NSLog(@"error when insertSql MultiplayerTalk ");
            
        } else {
            NSLog(@"success to insertSql MultiplayerTalk");
        }
        
    }
    [db close];
    
}


//多线程写入
+(void) updateMultiplayerTalkMultithread:(NSMutableArray *)transactionSql
{
    FMDatabaseQueue * queue  = [MyFMDatabaseQueue getSharedInstance];
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    //dispatch_queue_t q2 = dispatch_queue_create("queue2", NULL);
    
    dispatch_async(q1, ^{
        for (int i = 0; i<transactionSql.count; i++){
            [queue inDatabase:^(FMDatabase *db2) {
                
                NSString *insertSql1= [transactionSql objectAtIndex:i];
                
                
                BOOL res = [db2 executeUpdate:insertSql1];
                if (!res) {
                    NSLog(@"error to update UserInfo data");
                } else {
                    NSLog(@"succ to update UserInfo data");
                }
            }];
        }
    });
    //dispatch_release(q1);
}


//upd MultiplayerTalk table(fmdb)
+ (void)updateMultiplayerTalk:(NSString *)sql{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        
        if (![db executeUpdate:sql]) {
            NSLog(@"error when upd MultiplayerTalk ");
            
        } else {
            NSLog(@"success to upd MultiplayerTalk");
        }
        
    }
    [db close];
    
}



//查询群组成员，根据userInfo 表 myJID 查询(fmdb)
+(NSMutableArray *)queryMultiplayerTalkMembers:(NSString *)threadId myJID:(NSString *)myJID
{
    
    NSMutableArray *multiplayerTalkMembers =[[NSMutableArray alloc]init];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select m.jid,u.nickName,u.avatar,u.phone from multiplayerTalk m, UserInfo u where m.jid=u.jid and m.threadId=\"%@\" and u.myJID = \"%@\" order by role desc ",threadId,myJID];
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            
            NSString *jid=[rs stringForColumn:@"jid"];
            
            NSString *nickName=[rs stringForColumn:@"nickName"];
            
            NSString *avatar=[rs stringForColumn:@"avatar"];
            
            NSString *phone=[rs stringForColumn:@"phone"];
            
            if (nickName==nil || [nickName isEqualToString:@"(null)"]) {
                NSString*str_character = @"@";
                NSRange senderRange = [jid rangeOfString:str_character];
                if ([jid rangeOfString:str_character].location != NSNotFound) {
                    nickName = [jid substringToIndex:senderRange.location];
                }
            }
            
            [multiplayerTalkMembers addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",nickName, @"nickName",avatar,@"avatar",phone,@"phone", nil]];
            
        }
        
        [rs close];
    }
    [db close];
    return multiplayerTalkMembers;
}



//查询群组成员名字拼接成对话标题（fmdb)
+(NSString *)queryMultiplayerTalkMembersNickName:(NSString *)threadId
{
    NSString *mutliChatTitle = @"";
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select nickName from multiplayerTalk  where threadId=\"%@\"  order by role desc ",threadId];
        int i=0;
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            if (i==0) {
                mutliChatTitle = [NSString stringWithFormat:@"%@%@",[rs stringForColumn:@"nickName"],mutliChatTitle];
                
            }else{
                mutliChatTitle = [NSString stringWithFormat:@"%@,%@",[rs stringForColumn:@"nickName"],mutliChatTitle];
            }
            i++;
        }
        
        [rs close];
    }
    [db close];
    return mutliChatTitle;
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
