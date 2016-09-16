//
//  BuddyListCRUD.m
//  anbang_ios
//
//  Created by silenceSky  on 14-3-29.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "ContactsCRUD.h"
#import "Utility.h"
#import "PublicCURD.h"
#import "MyFMDatabaseQueue.h"
#import "UserInfoCRUD.h"
#import "ChatBuddyCRUD.h"
#import "AIUsersUtility.h"
#import "NSString+Chinese.h"

@implementation ContactsCRUD
sqlite3 *database;
FMDatabase *db;
//好友列表数据库操作
//create BuddyList  table
+ (void)createBuddyListTable
{
    
    char *errorMsg;
    NSString *createSqlStr=@"create table if not exists Contacts (jid varchar(50), remarkName varchar(50) DEFAULT('') ,nickName varchar(50),avatar varchar, phone varchar(15),myJID varchar(50),addTime varchar(20),primary key(jid,myJID))";
    
    const char *createSql="create table if not exists Contacts (jid varchar(50), remarkName varchar(50) DEFAULT('') ,nickName varchar(50),avatar varchar, phone varchar(15),myJID varchar(50),addTime varchar(20),primary key(jid,myJID))";
    
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        //  NSLog(@"Contacts create ok.");
    }
    else
    {
        //  NSLog( @"can not create table" );
        [self ErrorReport:(NSString *)createSqlStr];
    }
}

//insert buddyListTable
+ (void)insertContactsTable:(NSString *)jid name:(NSString *)name myJID:(NSString *)myJID
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *contactsUserName = nil;
    
    NSString*str_character = @"@";
    NSRange senderRange = [jid rangeOfString:str_character];
    if ([jid rangeOfString:str_character].location != NSNotFound) {
        contactsUserName = [jid substringToIndex:senderRange.location];
    }
    
    NSString *nickName =contactsUserName;
    NSString *remarkName = name;
    NSString *phone = @"";
    NSString *avatar = @"";
    
    
    NSString *addTime = Utility.getCurrentDate;
    NSString *insertSqlStr=[NSString stringWithFormat:@"insert into Contacts (jid,remarkName,nickName,phone,avatar,myJID,addTime,remarkName_sort,remarkName_short_sort) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",jid,remarkName, nickName,phone,avatar,myJID,addTime,[remarkName transformToPinyin],[remarkName getPrenameAbbreviation]];
    
    NSLog(@"%@",insertSqlStr);
    
    const char *insertSql = [insertSqlStr UTF8String];
    
    if (sqlite3_exec(database,insertSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        //  NSLog(@"insert ok.");
    }
    else
    {
        //  NSLog( @"can not insert it to table" );
        [self ErrorReport: (NSString *)insertSqlStr];
    }
    
    [PublicCURD closeDataBaseSQLite];
}




//insert buddyListTable
+ (void)replaceContactsTable:(NSString *)jid name:(NSString *)name myJID:(NSString *)myJID
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    NSString *contactsUserName = nil;
    
    NSString*str_character = @"@";
    NSRange senderRange = [jid rangeOfString:str_character];
    if ([jid rangeOfString:str_character].location != NSNotFound) {
        contactsUserName = [jid substringToIndex:senderRange.location];
    }
    
    NSString *nickName =contactsUserName;
    NSString *remarkName = name;
    NSString *phone = @"";
    NSString *avatar = @"";
    
    
    NSString *addTime = Utility.getCurrentDate;
    NSString *insertSqlStr=[NSString stringWithFormat:@"replace into Contacts (jid,remarkName,nickName,phone,avatar,myJID,addTime,remarkName_sort,remarkName_short_sort) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",jid,remarkName, nickName,phone,avatar,myJID,addTime,[remarkName transformToPinyin],[remarkName getPrenameAbbreviation]];
    
    if ([db open]) {
        
        if (![db executeUpdate:insertSqlStr]) {
            // NSLog(@"error when insertSql Contacts ");
            
        } else {
            //    NSLog(@"success to insertSql Contacts");
        }
    }
    [db close];
}



//多线程写入(fmdb)
+ (void) replaceContactsTable:(NSMutableArray *)transactionSql ver:(NSString *)ver
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
                       JLLog_I(@"error to inster Contacts data");
                    
                } else {
                       JLLog_I(@"succ to inster Contacts data");
                }
                
                
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:ver forKey:@"Ver_Query_Roster"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Contacts_LoadFinish" object:nil userInfo:nil];
        });
        
    });
    //dispatch_release(q1);
    
}



//添加联系人
+ (void)insertContactsTable2:(NSString *)jid nickName:(NSString *)nickName name:(NSString *)name phone:(NSString *)phone avatar:(NSString *)avatar  myJID:(NSString *)myJID
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *addTime = Utility.getCurrentDate;
    
    NSString *insertSqlStr=[NSString stringWithFormat:@"insert into Contacts (jid,remarkName,nickName,phone,avatar,myJID,addTime,remarkName_sort,remarkName_short_sort) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",jid,name, nickName,phone,avatar,myJID,addTime,[name transformToPinyin], [name getPrenameAbbreviation]];
    
    NSLog(@"%@",insertSqlStr);
    
    const char *insertSql = [insertSqlStr UTF8String];
    
    if (sqlite3_exec(database,"BEGIN", NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(database,insertSql, -1, &statement,NULL)==SQLITE_OK)
        {
            if (sqlite3_step(statement)!=SQLITE_DONE) sqlite3_finalize(statement);
        }
        if (sqlite3_exec(database, "COMMIT", NULL, NULL, &errorMsg)==SQLITE_OK) {
            NSLog(@"提交事务成功");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ContactInserted" object:nil];
        }
    }
    else
    {
        // NSLog( @"can not insert it to table" );
        [self ErrorReport: (NSString *)insertSqlStr];
    }
    
    [PublicCURD closeDataBaseSQLite];
}




//查询contats count(fmdb)
+ (int)queryContactsCountId:(NSString *)jid myJID:(NSString *)myJID
{
    
    int count = 0;
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select count(*) from Contacts where  jid=\"%@\" and myJID =\"%@\" and subscription in ('none', 'both')",jid,myJID];
        
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
            
        }
        [rs close];
    }
    [db close];
    
    // NSLog(@"****%d",count);
    return count;
}

+ (BOOL) hasFriends {
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if (![db open]) {
        return NO;
    }
    NSInteger count = 0;
    FMResultSet *rs = [db executeQuery:@"select count(*) from Contacts where \
                                                subscription in ('none', 'both')"];
    while ([rs next]) {
        count = [rs intForColumnIndex:0];
    }
    [rs close];
    [db close];
    return count > 0;
}


//已废弃
+(NSMutableArray *)queryBuddyList:(NSString *)myJID{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    NSMutableArray *contactsArray =[[NSMutableArray alloc]init];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select jid,remarkName,nickName,phone,avatar,addTime from Contacts where myJID = \"%@\"",myJID];
    
    if ([db open]) {
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            
            NSString *jid=[rs stringForColumn:@"jid"];
            
            NSString *remarkName=[rs stringForColumn:@"remarkName"];
            
            NSString *nickName=[rs stringForColumn:@"nickName"];
            
            NSString *phone=[rs stringForColumn:@"phone"];
            
            NSString *avatar=[rs stringForColumn:@"avatar"];
            
            NSString *addTime=[rs stringForColumn:@"addTime"];
            
            //NSLog(@"%@,%@,%@",nickName,phone,avatar);
            [contactsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"userName",remarkName, @"name",nickName,@"nickName",phone,@"phone",avatar,@"avatar", addTime, @"addTime", nil]];
        }
        [rs close];
    }
    [db close];
    
    return contactsArray;
}



//根据UserInfo 表 联合查询(fmdb)
+(NSMutableArray *)queryContactsList:(NSString *)myJID{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    NSMutableArray *contactsArray =[[NSMutableArray alloc]init];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select c.jid,c.remarkName,u.nickName,u.phone,u.avatar,c.addTime from Contacts c, UserInfo u where c.jid = u.jid and c.myJID = u.myJID and c.myJID = \"%@\" and subscription in ('none', 'both')",myJID];
    
    if ([db open]) {
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            
            NSString *jid=[rs stringForColumn:@"jid"];
            
            NSString *remarkName=[rs stringForColumn:@"remarkName"];
            
            NSString *nickName=[rs stringForColumn:@"nickName"];
            
            NSString *phone=[rs stringForColumn:@"phone"];
            
            NSString *avatar=[rs stringForColumn:@"avatar"];
            
            NSString *addTime=[rs stringForColumn:@"addTime"];
            
            [contactsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"userName",remarkName, @"name",nickName,@"nickName",phone,@"phone",avatar,@"avatar", addTime, @"addTime", nil]];
            
        }
        [rs close];
    }
    
    [db close];
    
    return contactsArray;
}



//根据UserInfo 表 联合查询(fmdb)
+(NSMutableArray *)queryContactsListTwo:(NSString *)myJID{
    
    NSMutableArray *contactsArray =[[NSMutableArray alloc]init];
    
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select c.jid,c.remarkName,u.nickName,u.accountType,u.phone,u.avatar,c.addTime, c.subscription from Contacts c, UserInfo u where c.subscription in ('none', 'both') and c.jid = u.jid and c.myJID = u.myJID and c.myJID = \"%@\"",myJID];
        
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            
            NSString *jid=[rs stringForColumn:@"jid"];
            
//            NSString *remarkName=[rs stringForColumn:@"remarkName"];
            NSString *remarkName = [AIUsersUtility nameForShowWithJID:jid];
            
            NSString *nickName=[rs stringForColumn:@"nickName"];
            
            NSString *phone=[rs stringForColumn:@"phone"];
            
            NSString *avatar=[rs stringForColumn:@"avatar"];
            
            NSString *addTime=[rs stringForColumn:@"addTime"];
            
            NSString *subscription = [rs stringForColumn:@"subscription"];
            
            int accountType = [rs intForColumn:@"accountType"];
            NSNumber *accountTypeNumber = [NSNumber numberWithInt:accountType];
            
            [contactsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"userName",remarkName, @"name",nickName,@"nickName",phone,@"phone",avatar,@"avatar", addTime, @"addTime", accountTypeNumber, @"accountType", subscription, @"subscription", nil]];
        }
        
        [rs close];
    }
    [db close];
    
//    JLLog_I(@"contactArray=%@", contactsArray);
    return contactsArray;
}

+ (BOOL)isFriend:(NSString *)aJID {
    NSString *subsription = nil;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select subscription from Contacts where jid = ?", aJID];
        while ([rs next]) {
            subsription = [rs stringForColumn:@"subscription"];
        }
        [rs close];
    }
    [db close];
    return [subsription isEqualToString:@"none"] || [subsription isEqualToString:@"both"];
}



//根据UserInfo 表 联合查询,并记录是否是圈子成员
+(NSMutableArray *)queryContactsListForAddGroupMembers:(NSString *)myJID groupMembers:(NSMutableArray *)groupMembers{
    
    [PublicCURD openDataBaseSQLite];
    
    NSMutableArray *contactsArray =[[NSMutableArray alloc]init];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select c.jid,c.remarkName,u.nickName,u.phone,u.avatar,c.addTime from Contacts c, UserInfo u where c.jid = u.jid and c.subscription in ('none', 'both') and c.myJID = u.myJID  and c.myJID = \"%@\"",myJID];
    
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    
    
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        // NSLog(@"select ok.");
        
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            NSString *jid=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            
            NSString *remarkName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            
            NSString *nickName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            
            NSString *phone=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            
            NSString *avatar=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            
            NSString *addTime=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            
            //NSLog(@"%@,%@,%@",nickName,phone,avatar);
            
            NSString *isGroupMemebers = @"";
            for (NSDictionary* dic in groupMembers) {
                
                if ([jid isEqualToString:[dic objectForKey:@"jid"]]) {
                    isGroupMemebers = @"yes";
                }
            }
            
            [contactsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",remarkName, @"name",nickName,@"nickName",phone,@"phoneNum",avatar,@"avatar", addTime, @"addTime",isGroupMemebers,@"isGroupMemebers", nil]];
            
        }
    }
    
    [PublicCURD closeDataBaseSQLite];
    
    return contactsArray;
}





//查询头像(从UserInfo 表查询
+(NSString *)queryContactsAvatar:(NSString *)contactsUserJID{
    
    [PublicCURD openDataBaseSQLite];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select avatar from UserInfo where jid = \"%@\"",contactsUserJID];
    
    NSString *avatar = @"";
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    
    
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        //NSLog(@"select ok.");
        
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            //avatar=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            avatar = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            
        }
    }
    [PublicCURD closeDataBaseSQLite];
    return avatar;
}


//查询备注名
+(NSString *)queryContactsRemarkName:(NSString *)contactsUserJID{
    NSString *remarkName = nil;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select remarkName from Contacts where jid = ?", contactsUserJID];
        while ([rs next]) {
            remarkName = [rs stringForColumn:@"remarkName"];
        }
        [rs close];
    }
    [db close];
    return remarkName;
    
    
    
//    [PublicCURD openDataBaseSQLite];
//    
//    NSString *selectSqlStr=[NSString stringWithFormat:@"select remarkName from Contacts where jid = \"%@\"",contactsUserJID];
//    NSString *remarkName = @"";
//    const char *selectSql = [selectSqlStr UTF8String];
//    sqlite3_stmt *statement;
//    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
//    {
//        // NSLog(@"select ok.");
//        
//        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
//        {
//            //remarkName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
//            remarkName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
//        }
//    }
//    
//    [PublicCURD closeDataBaseSQLite];
//    return remarkName;
}

/*更新备注------------------------------------------------------------------------------------------------------------------*/


+ (void)updateContactsRemarkName:(NSString *)jid remarkName:(NSString *)name myJID:(NSString *)myJID
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE Contacts SET remarkName = \"%@\",remarkName_sort = \"%@\",remarkName_short_sort=\"%@\" WHERE jid=\"%@\" and myJID=\"%@\"",name,jid,myJID,[name transformToPinyin],[name getPrenameAbbreviation]
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
    
    [PublicCURD closeDataBaseSQLite];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_UpdateContact" object:nil userInfo:@{@"remarkName":name}];
}




/*获取userInfo 更新好友列表------------------------------------------------------------------------------------------------------------------*/


+ (void)updateBuddyListFromUserInfo:(NSString *)jid nickName:(NSString *)nickName remarkName:(NSString *)remarkName phone:(NSString *)phone avatar:(NSString *)avatar myJID:(NSString *)myJID
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE Contacts SET nickName = \"%@\",phone = \"%@\",avatar = \"%@\" WHERE jid=\"%@\" and myJID = \"%@\" ",nickName, phone,avatar,jid,myJID];
    const char *updateSql = [updateSqlStr UTF8String];
    
    if (sqlite3_exec(database, updateSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        //NSLog(@"update ok.");
    }
    else
    {
        //NSLog( @"can not update it" );
        [self ErrorReport: (NSString *)updateSqlStr];
    }
    
    [PublicCURD closeDataBaseSQLite];
}



//多线程更新（fmdb)
+ (void)updateContactsFromUserInfoThread:(NSMutableArray *)transactionSql

{
    
    
    FMDatabaseQueue * queue  = [MyFMDatabaseQueue getSharedInstance];
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    // dispatch_queue_t q2 = dispatch_queue_create("queue2", NULL);
    
    dispatch_async(q1, ^{
        for (int i = 0; i<transactionSql.count; i++){
            [queue inDatabase:^(FMDatabase *db2) {
                
                NSString *insertSql1= [transactionSql objectAtIndex:i];
                
                
                BOOL res = [db2 executeUpdate:insertSql1];
                if (!res) {
                    // NSLog(@"error to update data");
                } else {
                    //  NSLog(@"succ to update data");
                }
            }];
        }
    });
    
    
}





//删除联系人
+ (void)deleteContactsByChatUserName:(NSString *)contactsUserName{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if([db open]){
        NSString *deleteSqlStr= @"DELETE FROM Contacts where jid=?";
        if([db executeUpdate:deleteSqlStr, contactsUserName]){
            JLLog_D(@"delete friend ok.");
            NSString *chatUserName = [contactsUserName componentsSeparatedByString:@"@"][0];
            [ChatBuddyCRUD deleteChatBuddyByChatUserName:chatUserName myUserName:MY_USER_NAME];
        } else {
            JLLog_D(@"delete failed.");
        }
    }
    
    [db close];
    
    if (![ContactsCRUD hasFriends]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Empty_Friends" object:nil];
    }
}


//删除所有联系人
+(void)deleteAllContacts
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    //[self openDataBase];
    NSString *sqlStr = @"delete from Contacts where 1=1";
    const char *sql = "delete from Contacts where 1=1";
    if (sqlite3_exec(database, sql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        //  NSLog(@"delete all ok.");
    }
    else
    {
        // NSLog( @"can not delete all it" );
        [self ErrorReport: (NSString *)sqlStr];
    }
    [PublicCURD closeDataBaseSQLite];
}




+(void)dropSubscriptionUserInfoTable
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    //[self openDataBase];
    NSString *sqlStr = @"DROP TABLE SubscriptionUserInfo";
    const char *sql = "DROP TABLE Contacts";
    if (sqlite3_exec(database, sql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        //  NSLog(@"drop ok.");
    }
    else
    {
        // NSLog( @"can not drop it" );
        [self ErrorReport: (NSString *)sqlStr];
    }
    [PublicCURD closeDataBaseSQLite];
}



+(void)dropBuddyListTable
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    //[self openDataBase];
    NSString *sqlStr = @"DROP TABLE Contacts";
    const char *sql = "DROP TABLE Contacts";
    if (sqlite3_exec(database, sql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        //  NSLog(@"drop ok.");
    }
    else
    {
        //  NSLog( @"can not drop it" );
        [self ErrorReport: (NSString *)sqlStr];
    }
    [PublicCURD closeDataBaseSQLite];
}



//error
+(void)ErrorReport: (NSString *)item
{
    char *errorMsg;
    
    const char *itemChar = [item UTF8String];
    
    
    if (sqlite3_exec(database, (const char *)itemChar, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        //  NSLog(@"%@ ok.",item);
    }
    else
    {
        //  NSLog(@"error: %s",errorMsg);
        // sqlite3_free(errorMsg);
    }
}



@end
