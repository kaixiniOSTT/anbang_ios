//
//  UserInfoCRUD.m
//  anbang_ios
//
//  Created by silenceSky  on 14-5-16.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "UserInfoCRUD.h"
#import "PublicCURD.h"
#import "Utility.h"
#import "UserInfo.h"
#import "MyFMDatabaseQueue.h"
#import "NSString+Chinese.h"

@implementation UserInfoCRUD

sqlite3 *database;
FMDatabase *db;

//所有订阅用户数据库操作
//create UserInfo  table
+ (void)createUserInfoTable
{
    
    char *errorMsg;
    NSString *createSqlStr=@"create table if not exists UserInfo (jid varchar(50), remarkName varchar(50),nickName varchar(50),avatar varchar(200), phone varchar(15),myJID varchar(50),version varchar(20), addTime varchar(20),primary key(jid,myJID))";
    
    const char *createSql="create table if not exists UserInfo (jid varchar(50), remarkName varchar(50) DEFAULT('') ,nickName varchar(50),avatar varchar(200), phone varchar(15),myJID varchar(50),version varchar(20),addTime varchar(20),primary key(jid,myJID))";
    
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"UserInfo create ok.");
    }
    else
    {
        NSLog( @"can not create table" );
        [self ErrorReport:(NSString *)createSqlStr];
    }
}

+ (BOOL)addAnUserInfo:(UserInfo *)userInfo {
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    __block BOOL isSuccess = NO;
    if ([db open]) {
        isSuccess =
        [db executeUpdate:@"replace into UserInfo (jid, remarkName, nickName, avatar, phone, email,\
         secondEmail, source, inviteUrl, accountType, employeeCode, accountName, gender, areaId,   \
         bookName, agencyName, branchName, centerName, employeeName, departmentNme, myJID, version,\
         addTime, stickie_time, signature, employeePhone, publicPhone, officalPhone) values (?, ?, \
         ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);",
         userInfo.jid, userInfo.remarkName, userInfo.nickName, userInfo.avatar, userInfo.phone,
         userInfo.email, userInfo.secondEmail, userInfo.soure, userInfo.inviteUrl,
         [NSNumber numberWithInt:userInfo.accountType], userInfo.employeeCode, userInfo.accountName,
         [NSNumber numberWithInt:userInfo.gender],
         userInfo.areaId, userInfo.bookName, userInfo.agencyName, userInfo.branchName,
         userInfo.centerName, userInfo.employeeName, userInfo.departmentName, MY_JID,
         @"", @"", @"0", userInfo.signature, userInfo.employeePhone, userInfo.publicPhone,
         userInfo.officalPhone];
    }
    [db close];
    return isSuccess;
}

//insert UserInfo table(fmdb)
+ (void)insertUserInfoTable:(NSString *)jid remarkName:(NSString *)remarkName nickName:(NSString *)nickName phone:(NSString *)phone avatar:(NSString *)avatar ver:(NSString *)ver myJID:(NSString *)myJID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *addTime = Utility.getCurrentDate;
        
        NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
        db =  [FMDatabase databaseWithPath:database_path];
        
        if ([db open]) {
            
            NSString *insertSqlStr=[NSString stringWithFormat:@"replace into UserInfo (jid,remarkName,nickName,phone,avatar,version,myJID,addTime,nickName_sort,nickName_short_sort) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",jid,remarkName, nickName,phone,avatar,ver,myJID,addTime,[nickName transformToPinyin],[nickName getPrenameAbbreviation]];
            
            NSLog(@"**************%@",insertSqlStr);
            
            if (![db executeUpdate:insertSqlStr]) {
                NSLog(@"error when insertSql UserInfo ");
                
            } else {
                NSLog(@"success to insertSql UserInfo");
            }
            
        }
        [db close];
    });
}


//insert UserInfo table
+ (void)insertUserInfoTable2:(NSMutableArray *)transactionSql
{
    [PublicCURD openDataBaseSQLite];
    //使用事务，提交插入sql语句
    @try{
        char *errorMsg;
        if (sqlite3_exec(database, "BEGIN", NULL, NULL, &errorMsg)==SQLITE_OK)
        {
            NSLog(@"启动事务成功");
            sqlite3_free(errorMsg);
            sqlite3_stmt *statement;
            for (int i = 0; i<transactionSql.count; i++)
            {
                if (sqlite3_prepare_v2(database,[[transactionSql objectAtIndex:i] UTF8String], -1, &statement,NULL)==SQLITE_OK)
                {
                    if (sqlite3_step(statement)!=SQLITE_DONE) sqlite3_finalize(statement);
                }
            }
            if (sqlite3_exec(database, "COMMIT", NULL, NULL, &errorMsg)==SQLITE_OK)   NSLog(@"提交事务成功");
            sqlite3_free(errorMsg);
        }
        else sqlite3_free(errorMsg);
    }
    @catch(NSException *e)
    {
        char *errorMsg;
        if (sqlite3_exec(database, "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)  NSLog(@"回滚事务成功");
        sqlite3_free(errorMsg);
    }
    @finally{}
    
    [PublicCURD closeDataBaseSQLite];
}



//多线程写入
+(void) insertUserInfoTableMultithread:(NSMutableArray *)transactionSql
{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if([db open]){
        [db beginTransaction];
        BOOL isRollBack = NO;
        NSLog(@"begin to insert UserInfo data");
        @try {
            for (int i = 0; i<transactionSql.count; i++){
                NSString *insertSql1= [transactionSql objectAtIndex:i];
                BOOL a = [db executeUpdate:insertSql1];
                if (!a) {
                    NSLog(@"插入失败：sql=%@", insertSql1);
                }
            }
        }
        @catch (NSException *exception) {
            isRollBack = YES;
            NSLog(@"error to insert UserInfo data:%@", exception);
            [db rollback];
        }
        @finally {
            if (!isRollBack) {
                [db commit];
                NSLog(@"succ to insert UserInfo data");
            }
        }
    }
    
    [db close];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_UserInfoPercentage" object:@"100" userInfo:nil];
        
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_UserinfoVersion" object:nil userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DB_SAVE_SUCCESS" object:nil];

    
}


////查询是否已经存在此用户
//+ (int)queryUserInfoTableCountId:(NSString *)jid myJID:(NSString *)myJID
//{
//    NSString *selectSqlStr=[NSString stringWithFormat:@"select count(*) from UserInfo where  jid=\"%@\" and myJID =\"%@\" ",jid,myJID];
//    const char *selectSql = [selectSqlStr UTF8String];
//    int count = 0;
//    sqlite3_stmt *statement;
//    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
//    {
//        NSLog(@"select ok.");
//        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
//        {
//            count = sqlite3_column_int(statement, 0);
//        }
//
//    }
//    else
//    {
//        //error
//        [self ErrorReport: (NSString *)selectSqlStr];
//    }
//
//    sqlite3_finalize(statement);
//
//    NSLog(@"count %d",count);
//
//    return count;
//}



//查询是否已经存在此用户(fmdb)
+ (int)queryUserInfoTableCountId:(NSString *)jid myJID:(NSString *)myJID
{
    int count = 0;
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select count(*) from UserInfo where  jid=\"%@\" and myJID =\"%@\" ",jid,myJID];
        
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
            
        }
        [rs close];
    }
    [db close];
    return count;
}




//查询用户是否有订阅关系用户（fmdb)
+ (int)queryUserInfoTableTotal:(NSString *)myJID
{
    int count = 0;
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select count(*) from UserInfo where myJID =\"%@\"",myJID];
        
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
            
        }
        [rs close];
    }
    [db close];
    return count;
    
}


//查询用户是否有订阅关系用户
//+ (int)queryUserInfoTableTotal:(NSString *)myJID
//{
//    NSString *selectSqlStr=[NSString stringWithFormat:@"select count(*) from UserInfo where myJID =\"%@\"",myJID];
//    const char *selectSql = [selectSqlStr UTF8String];
//    int count = 0;
//    sqlite3_stmt *statement;
//    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
//    {
//        NSLog(@"select ok.");
//        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
//        {
//            count = sqlite3_column_int(statement, 0);
//        }
//
//    }
//    else
//    {
//        //error
//        [self ErrorReport: (NSString *)selectSqlStr];
//    }
//
//    sqlite3_finalize(statement);
//
//    NSLog(@"count %d",count);
//
//    return count;
//}




//查询是否有更新
+ (BOOL)queryUserInfoVersionUpd:(NSString *)jid myJID:(NSString *)myJID ver:(NSString *)ver
{
    [PublicCURD openDataBaseSQLite];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select version from UserInfo where  jid=\"%@\" and myJID =\"%@\" ",jid,myJID];
    const char *selectSql = [selectSqlStr UTF8String];
    NSString * verStr = @"";
    BOOL updateBool = NO;
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            //ver = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            ver = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
        }
    }
    else
    {
        //error
        [self ErrorReport: (NSString *)selectSqlStr];
    }
    
    sqlite3_finalize(statement);
    
    if ([ver isEqualToString:verStr]) {
        updateBool = YES;
    }
    
    [PublicCURD closeDataBaseSQLite];
    return updateBool;
}



/*更新UserInfo------------------------------------------------------------------------------------------------------------------*/
+ (void)updateUserInfo:(NSString *)jid remarkName:(NSString *)remarkName nickName:(NSString *)nickName phone:(NSString *)phone avatar:(NSString *)avatar version:(NSString *)version myJID:(NSString *)myJID
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE UserInfo SET remarkName = \"%@\",nickName = \"%@\",phone = \"%@\",avatar = \"%@\",version = \"%@\" WHERE jid=\"%@\" and myJID=\"%@\", nickName_sort=\"%@\", nickName_short_sort=\"%@\" ",remarkName,nickName,phone,avatar,version, jid,myJID, [nickName transformToPinyin], [nickName getPrenameAbbreviation]];
    
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



//多线程更新
+(void) updateUserInfoMultithread:(NSMutableArray *)transactionSql
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
                    NSLog(@"error to inster UserInfo data");
                } else {
                    NSLog(@"succ to update UserInfo data");
                }
            }];
        }
    });
    //dispatch_release(q1);
}



//查询某个用户userInfo 信息
+ (UserInfo *)queryUserInfo:(NSString *)jid myJID:(NSString *)myJID {
    
//    UserInfo * userInfo = [[UserInfo alloc] init];
    UserInfo *userInfo = nil;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select jid,remarkName,nickName,phone,avatar,email,secondEmail,source,inviteUrl,accountType,employeeCode,employeeName,accountName,gender,areaId,bookName,agencyName,branchName,centerName,departmentNme,addTime,signature,employeePhone,publicPhone,officalPhone from UserInfo where jid=\"%@\" and myJID=\"%@\" ",jid,myJID];
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            
            userInfo = [[UserInfo alloc] init];
            
            NSString *jid = [rs stringForColumn:@"jid"];
            NSString *nickName =[rs stringForColumn:@"nickName"];
            NSString *phone =[rs stringForColumn:@"phone"];
            NSString *avatar =[rs stringForColumn:@"avatar"];
            NSString *remarkName = [rs stringForColumn:@"remarkName"];
            NSString *email =[rs stringForColumn:@"email"];
            NSString *secondEmail =[rs stringForColumn:@"secondEmail"];
            NSString *source =[rs stringForColumn:@"source"];
            NSString *inviteUrl =[rs stringForColumn:@"inviteUrl"];
            int accountType =[rs intForColumn:@"accountType"];
            NSString *cemployeeCde =[rs stringForColumn:@"employeeCode"];
            NSString *employeeNme =[rs stringForColumn:@"employeeName"];
            NSString *accountName =[rs stringForColumn:@"accountName"];
            int gender =[rs intForColumn:@"gender"];
            NSString *areaId =[rs stringForColumn:@"areaId"];
            NSString *bookNme =[rs stringForColumn:@"bookName"];
            NSString *agencyNme =[rs stringForColumn:@"agencyName"];
            NSString *branchNme =[rs stringForColumn:@"branchName"];
            NSString *centerNme =[rs stringForColumn:@"centerName"];
            NSString *departmentNme =[rs stringForColumn:@"departmentNme"];
            NSString *signature = [rs stringForColumn:@"signature"];
            NSString *employeePhone = [rs stringForColumn:@"employeePhone"];
            NSString *publicPhone = [rs stringForColumn:@"publicPhone"];
            NSString *officalPhone = [rs stringForColumn:@"officalPhone"];
            
            NSString *addTime =[rs stringForColumn:@"addTime"];
            
            userInfo.jid = jid;
            userInfo.nickName = nickName;
            userInfo.phone = phone;
            userInfo.avatar = avatar;
            userInfo.email = email;
            userInfo.secondEmail = secondEmail;
            userInfo.soure = source;
            userInfo.inviteUrl = inviteUrl;
            userInfo.accountType = accountType;
            userInfo.employeeCode = cemployeeCde;
            userInfo.employeeName = employeeNme;
            userInfo.gender = gender;
            userInfo.areaId = areaId;
            userInfo.accountName = accountName;
            userInfo.branchName = branchNme;
            userInfo.bookName = bookNme;
            userInfo.agencyName = agencyNme;
            userInfo.centerName = centerNme;
            userInfo.remarkName = remarkName;
            userInfo.addTime = addTime;
            userInfo.departmentName = departmentNme;
            userInfo.signature = signature;
            userInfo.employeePhone = employeePhone;
            userInfo.publicPhone = publicPhone;
            userInfo.officalPhone = officalPhone;
            
        }
        [rs close];
    }
    
    [db close];
    return userInfo;
}


//删除用户
//+ (void)deleteUserInfoByJIDAndMyJID:(NSString *)jid myJID:(NSString *)myJID{
//    char *errorMsg;
//    NSString *deleteSqlStr=[NSString stringWithFormat:@"DELETE FROM UserInfo where jid=\"%@\" and myJID=\"%@\"",jid,myJID ];
//    const char *deleteSql = [deleteSqlStr UTF8String];
//
//    if (sqlite3_exec(database, deleteSql, NULL, NULL, &errorMsg)==SQLITE_OK)
//    {
//        NSLog(@"delete ok.");
//    }
//    else
//    {
//        NSLog( @"can not delete it" );
//        [self ErrorReport: (NSString *)deleteSqlStr];
//    }
//}


//删除用户(fmdb)
+ (void)deleteUserInfoByJIDAndMyJID:(NSString *)jid myJID:(NSString *)myJID
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *deleteSqlStr=[NSString stringWithFormat:@"DELETE FROM UserInfo where jid=\"%@\" and myJID=\"%@\"",jid,myJID ];
        if (![db executeUpdate:deleteSqlStr]) {
            NSLog(@"error when delete userInfo (remove) ");
            
        } else {
            NSLog(@"success to delete userInfo (remove)");
        }
    }
    [db close];
}





//查询用户头像
+(NSString *)queryUserInfoAvatar:(NSString *)userJID{
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select avatar from UserInfo where  jid=\"%@\"",userJID];
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    NSString *avatar = @"";
    
    if ([db open]) {
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            
            avatar=[rs stringForColumn:@"avatar"];
        }
        [rs close];
    }
    [db close];
    return avatar;
}

+ (int)queryUserInfoAccountTypeWith:(NSString *)userJID {
//    __block int accountType;
//    FMDatabaseQueue *queue = [MyFMDatabaseQueue getSharedInstance];
//    [queue inDatabase:^(FMDatabase *db) {
//        FMResultSet *rs = [db executeQuery:@"select accountType from UserInfo where  jid = ?", userJID];
//        while ([rs next]) {
//            accountType = [rs intForColumn:@"accountType"];
//        }
//        [rs close];
//    }];
//    [MyFMDatabaseQueue close];
//    return accountType;
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select accountType from UserInfo where  jid=\"%@\"",userJID];
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    int accountType = 0;
    
    if ([db open]) {
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            
            accountType = [rs intForColumn:@"accountType"];
        }
        [rs close];
    }
     [db close];
    
    return accountType;
}

+ (NSString *)employeeNameWithJID:(NSString *)aJID {
    NSString *employeeName = nil;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select employeeName from UserInfo where jid = ?", aJID];
        while ([rs next]) {
            employeeName = [rs stringForColumn:@"employeeName"];
        }
        [rs close];
    }
    [db close];
    return employeeName;
}

+ (NSString *)nickNameWithJID:(NSString *)aJID {
    NSString *nickName = nil;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select nickName from UserInfo where jid = ?", aJID];
        while ([rs next]) {
            nickName = [rs stringForColumn:@"nickName"];
        }
        [rs close];
    }
    [db close];
    return nickName;
}

/*-----------------------------------------------------------------------------------------------------------------------------------*/



/*更新备注------------------------------------------------------------------------------------------------------------------*/


+ (void)updateContactsRemarkName:(NSString *)jid remarkName:(NSString *)name myJID:(NSString *)myJID
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE Contacts SET remarkName = \"%@\" WHERE jid=\"%@\" and myJID=\"%@\"",name,jid,myJID
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
}




+(void)deleteAllUserInfo
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    //[self openDataBase];
    NSString *sqlStr = @"delete from UserInfo where 1=1";
    const char *sql = "delete from UserInfo where 1=1";
    if (sqlite3_exec(database, sql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"delete all ok.");
    }
    else
    {
        NSLog( @"can not delete all it" );
        [self ErrorReport: (NSString *)sqlStr];
    }
    [PublicCURD closeDataBaseSQLite];
}



+(void)dropContactsListTable
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    //[self openDataBase];
    NSString *sqlStr = @"DROP TABLE Contacts";
    const char *sql = "DROP TABLE Contacts";
    if (sqlite3_exec(database, sql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"drop ok.");
    }
    else
    {
        NSLog( @"can not drop it" );
        [self ErrorReport: (NSString *)sqlStr];
    }
    [PublicCURD closeDataBaseSQLite];
}




+(void)dropSubscriptionUserInfoTable
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *sqlStr = @"DROP TABLE SubscriptionUserInfo";
    const char *sql = "DROP TABLE Contacts";
    if (sqlite3_exec(database, sql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"drop ok.");
    }
    else
    {
        NSLog( @"can not drop it" );
        [self ErrorReport: (NSString *)sqlStr];
    }
    [PublicCURD closeDataBaseSQLite];
}


+(NSString *)selectUserInfoAvatarWithJID:(NSString *)jid myJID:(NSString *)myJID {
    //    NSString *selectSqlStr=[NSString stringWithFormat:@"select avatar from UserInfo where  jid=\"%@\" and myJID =\"%@\" ",jid,myJID];
    //    const char *selectSql = [selectSqlStr UTF8String];
    //    NSString *avatar=nil;
    //    sqlite3_stmt *statement;
    //    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    //    {
    //        NSLog(@"select ok.");
    //        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
    //        {
    //            avatar = [[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding]autorelease];
    //        }
    //
    //    }
    //    else
    //    {
    //        //error
    //        [self ErrorReport: (NSString *)selectSqlStr];
    //    }
    //    return avatar;
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select avatar from UserInfo where  jid=\"%@\" and myJID =\"%@\" ",jid,myJID];
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    NSString *avatar = @"";
    
    if ([db open]) {
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            
            avatar=[rs stringForColumn:@"avatar"];
        }
        [rs close];
    }
    [db close];
    return avatar;
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

+ (NSString *)queryStickieTimeWithJID:(NSString *)memberJID
{
    NSString *stickie_time = nil;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        FMResultSet * rs = [db executeQuery:@"select stickie_time from UserInfo where jid = ?", memberJID];
        while ([rs next]) {
            stickie_time = [rs stringForColumn:@"stickie_time"];
        }
        [rs close];
    }
    [db close];
    
    if (!stickie_time) {
        stickie_time = @"0";
        [self addStickieTime:stickie_time withJID:memberJID];
    }
    
    return stickie_time;
}

+ (void)addStickieTime:(NSString *)stickieTime withJID:(NSString *)memberJID
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        [db executeUpdate:@"update UserInfo set stickie_time = ? where jid = ?;", stickieTime, memberJID];
    }
    [db close];
}

+ (NSArray*)queryUserInfoForJid{
    NSMutableArray *jidArr = [NSMutableArray array];
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        FMResultSet * rs = [db executeQuery:@"select jid from UserInfo"];
         while ([rs next]) {
            [jidArr addObject: [rs stringForColumn:@"jid"]];
         }
         [rs close];
    }
    [db close];
    NSArray* resultArr = [NSArray arrayWithArray:jidArr];
    return resultArr;
}

+ (void)saveSignature:(NSString *)aValue targetJID:(NSString *)aJID {
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        [db executeUpdate:@"update UserInfo set signature = ? where jid = ?", aValue, aJID];
    }
    [db close];
}

+ (NSString *)signatureWithJID:(NSString *)aJID {
    FMDatabaseQueue *queue = [MyFMDatabaseQueue getSharedInstance];
    __block NSString *signature = nil;
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select signature from UserInfo where jid = ?", aJID];
        while ([rs next]) {
            signature = [rs stringForColumn:@"signature"];
        }
        [rs close];
    }];
    [MyFMDatabaseQueue close];
    return signature;
}

+ (void) saveAreaId:(NSString *)aValue targetJID:(NSString *)aJID {
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        [db executeUpdate:@"update UserInfo set areaId = ? where jid = ?", aValue, aJID];
    }
    [db close];
}

@end
