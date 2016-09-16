//
//  PublicCURD.m
//  anbang_ios
//
//  Created by silenceSky  on 14-6-11.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "PublicCURD.h"
#import "NSString+Chinese.h"
#import "AIUsersUtility.h"
#import "GroupCRUD.h"

@implementation PublicCURD
sqlite3 *database;
FMDatabase *db;



//创建表(fmdb)
+ (void)createAllTable{
    
    
    //聊天好友表
    NSString *createChatBuddySql = @"create table if not exists ChatBuddy (chatUserName varchar(20),jid varchar(50), name varchar(50),nickName varchar(50),avatar varchar, phone varchar(15),myUserName varchar(20),type varchar(20),lastMsg text,msgType varchar(20),msgSubject varchar(20),lastMsgTime varchar(20), addTime varchar(20),tag varchar(20),primary key(chatUserName,myUserName))";
    
    //好友列表
    NSString *createContactsSql = @"create table if not exists Contacts (jid varchar(50), remarkName varchar(50) DEFAULT('') ,nickName varchar(50),avatar varchar, phone varchar(15),myJID varchar(50),addTime varchar(20),primary key(jid,myJID))";
    
    //群组表
    NSString *createChatGroupSql = @"create table if not exists ChatGroup (groupJID varchar(50), name varchar(50),creator varchar(50),groupMucId varchar(50),groupType varchar(50),myJID varchar(50),version varchar(20),inviteUrl varchar(100),createDate varchar(30),modificationDate varchar(30),primary key(groupJID,myJID))";
    
    //群组成员表
    NSString *createGroupMemberSql = @"create table if not exists GroupMembers (jid varchar(50), nickName varchar(50),role varchar(10),groupJID varchar(50),myJID varchar(50),primary key(jid,groupJID,myJID))";

    //所有订阅用户userInfo
    NSString *createUserInfoSql = @"create table if not exists UserInfo (jid varchar(50), remarkName varchar(50),nickName varchar(50),avatar varchar(200), phone varchar(15),email varchar(50),secondEmail varchar(50),source varchar(30),inviteUrl varchar(100),accountType varchar(10),employeeCode varchar(50),accountName varchar(50),gender int DEFAULT 0,areaId varchar(20),bookName varchar(50),agencyName varchar(50),branchName varchar(50),centerName varchar(50),employeeName varchar(30), departmentNme varchar(50), myJID varchar(50),version varchar(20), addTime varchar(20),primary key(jid,myJID))";
    
    //群组聊天纪录
    NSString *createGroupChatMessageSql = @"create table if not exists GroupChatMessage (id integer primary key autoincrement, groupMucId text(50),sendUser text(50),myJID text(50), message text,readMark int DEFAULT 0, type text(10),msgType text(10),sendStatus text(20),msgRandomId text(50),sendTime text(20),receiveTime text(20))";
    
    
    //联系人聊天纪录
    NSString *createChatMessageSql = @"create table if not exists ChatMessage (id integer primary key autoincrement, sendUser text(50), receiveUser text(50),message text,readMark int DEFAULT 0, msgType text(10),subject text(20),sendStatus text(20),msgRandomId text(50),msgReceipt text(50), sendTime text(20),receiveTime text(20),myJID text(50))";
    
    //通话纪录
    //    NSString *createCallMessageSql = @"create table if not exists CallMessage (id integer primary key autoincrement, sendUser text(50), receiveUser text(50),message text,readMark int DEFAULT 0, msgType text(10),subject text(20),sendStatus text(20),msgRandomId text(50), sendTime text(20),receiveTime text(20))";
    
    
    //账号记录表
    //  NSString *createUserNameSql = @"create table if not exists UserName (userName varchar(20),avatar varchar(50),myJID varchar(50),primary key(myJID))";
    
    //黑名单
    NSString *createBlackListSql= @"create table if not exists Blacklist (id integer primary key autoincrement, contactsUserName varchar(20),myUserName varchar(20),addTime varchar(20))";
    
    //新闻列表
    NSString *createNewListSql = @"create table if not exists NewsList (title varchar(20) primary key,myjid verchar(20),type varchar(10),readMark int DEFAULT 0, outline TEXT,imgUrl varchar(50), url varchar(50),publishTime varchar(20))";
    
    
    //新闻记录表
    NSString *createNewSql = @"create table if not exists News (userName varchar(20) primary key ,readmark int DEFAULT 0)";
    
    //服务器通讯录表
    NSString *createAddressBookSql = @"create table if not exists AddressBook (myJid varchar(20),name varchar(20),phoneNum varchar(20),jid varchar(20),ver varchar(20),primary key(myJid,name,phoneNum))";
    
    //手机通讯录
    NSString *createMobileAddressBookSql = @"create table if not exists MobileAddressBook (name varchar(20),phoneNum varchar(20),primary key(name,phoneNum))";
    
    //系统消息表
    NSString *createSystemMessageSql = @"create table if not exists SystemMessageTable (sendName varchar(20),myUserName varchar(20),readMark varchar(10),msg TEXT,msgType varchar(30),time varchar(20))";
    
  
    //临时多人对话
    NSString *createMultiplayerTalkSql=@"create table if not exists MultiplayerTalk (jid varchar(50),threadId varchar(100),nickName varchat(50),role int(10), addTime varchar(20),primary key(jid,threadId))";
    
    
    //Dnd配置信息表
    NSString *createOfRoseterExtSql=@"CREATE  TABLE  IF NOT EXISTS  OFROSTEREXT (USERNAME VARCHAR(64)  NOT NULL , JID VARCHAR(1024)  NOT NULL , DND VARCHAR(1)  NOT NULL DEFAULT '0', SHOWPROFILE VARCHAR(1)  NOT NULL DEFAULT '1')";
    
    NSString *createCollectionSQL = @"create table if not exists t_collection (id integer primary key autoincrement, owner varchar(64), sender varchar(64), source integer, circleID varchar(100), create_date varchar(50), message text, message_type integer, store_id varchar(40));";
    
    NSString *createNewFriendSQL = @"create table if not exists NewFriends (requester varchar(20) primary key, name varchar(20), avatar varchar(30), accountType varchar(5), status varchar(5), validate_info varchar(50), read_status varchar(5) default '1', sort_letters varchar(50), timestamps varchar(35))";
    
    NSString *createPrivilegeSettingSQL= @"create table if not exists PrivilegeSetting (id integer primary key autoincrement, my_circle_lock varchar(5) default '0', his_circle_mark varchar(5) default '0')";
    
    NSMutableArray *createSqlArray = [[NSMutableArray alloc]init];
    
    [createSqlArray addObject:createChatGroupSql];
    [createSqlArray addObject:createGroupMemberSql];
    [createSqlArray addObject:createChatBuddySql];
    [createSqlArray addObject:createContactsSql];
    [createSqlArray addObject:createUserInfoSql];
    [createSqlArray addObject:createGroupChatMessageSql];
    [createSqlArray addObject:createChatMessageSql];
    //[createSqlArray addObject:createUserNameSql]; //公共表
    [createSqlArray addObject:createBlackListSql];
    [createSqlArray addObject:createNewListSql];
    [createSqlArray addObject:createNewSql];
    [createSqlArray addObject:createAddressBookSql];
    [createSqlArray addObject:createMobileAddressBookSql];
    [createSqlArray addObject:createSystemMessageSql];
    [createSqlArray addObject:createMultiplayerTalkSql];
    [createSqlArray addObject:createOfRoseterExtSql];
    [createSqlArray addObject:createCollectionSQL];
    [createSqlArray addObject:createNewFriendSQL];
    [createSqlArray addObject:createPrivilegeSettingSQL];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db = [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        for (int i = 0; i<createSqlArray.count; i++){
            NSString *createSqlStr= [createSqlArray objectAtIndex:i];
            
            if (![db executeUpdate:createSqlStr]) {
                NSLog(@"error when create table !");
                NSLog(@"%@",createSqlStr);
                
            }else{
                NSLog(@"create table success !");
            }
            
        }
    }
    
    [db close];
}


// app update
+ (void) updateTable
{
    NSString *update_sql_01 = @"alter table ChatBuddy add column tag varchar(20)";    // ver 1.0.2
    NSString *update_sql_02 = @"alter table ChatGroup add column stickie_time varchar(35) default '0'";
    NSString *update_sql_03 = @"alter table UserInfo add column stickie_time varchar(35) default '0'";
    NSString *update_sql_04 = @"alter table GroupMembers add column createtime varchar(20) default ''";
    NSString *update_sql_05 = @"alter table GroupMembers add column roleSort varchar(1) default '0'";
    NSString *update_sql_06 = @"alter table Contacts add column subscription varchar(20) default ''";
    NSString *update_sql_07 = @"alter table UserInfo add column signature varchar(120) default ''" ;
    NSString *update_sql_08 = @"alter table UserInfo add column employeePhone varchar(20) default ''";
    NSString *update_sql_09 = @"alter table UserInfo add column publicPhone varchar(20) default ''";
    NSString *update_sql_10 = @"alter table UserInfo add column officalPhone varchar(20) default ''";
    
    NSString *update_sql_11 = @"alter table UserInfo add column nickName_sort varchar(150)";
    NSString *update_sql_12 = @"alter table UserInfo add column nickName_short_sort varchar(20)";
    
    NSString *update_sql_13 = @"alter table UserInfo add column employeeName_sort varchar(150)";
    NSString *update_sql_14 = @"alter table UserInfo add column employeeName_short_sort varchar(20)";
    
    NSString *update_sql_15 = @"alter table Contacts add column remarkName_sort varchar(150)";
    NSString *update_sql_16 = @"alter table Contacts add column remarkName_short_sort varchar(20)";
    
    NSString *update_sql_17 = @"alter table ChatGroup add column name_sort varchar(150)";
    NSString *update_sql_18 = @"alter table ChatGroup add column name_short_sort varchar(20)";
    
    NSMutableArray *update_sqls = [NSMutableArray array];
    [update_sqls addObject:update_sql_01];
    [update_sqls addObject:update_sql_02];
    [update_sqls addObject:update_sql_03];
    [update_sqls addObject:update_sql_04];
    [update_sqls addObject:update_sql_05];
    [update_sqls addObject:update_sql_06];
    [update_sqls addObject:update_sql_07];
    [update_sqls addObject:update_sql_08];
    [update_sqls addObject:update_sql_09];
    [update_sqls addObject:update_sql_10];
    [update_sqls addObject:update_sql_11];
    [update_sqls addObject:update_sql_12];
    [update_sqls addObject:update_sql_13];
    [update_sqls addObject:update_sql_14];
    [update_sqls addObject:update_sql_15];
    [update_sqls addObject:update_sql_16];
    [update_sqls addObject:update_sql_17];
    [update_sqls addObject:update_sql_18];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db = [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        for (NSString *update_sql in update_sqls) {
            if ([db executeUpdate:update_sql]) {
                JLLog_I(@"update table ok <sql | %@>",update_sql);
            }else{
                JLLog_I(@"update table error <sql | %@>",update_sql);
            }
        }
    }
    [db close];
}



//创建表(fmdb)
+ (void)createPublicTable{
    //账号记录表
    NSString *createUserNameSql = @"create table if not exists UserName (userName varchar(20),avatar varchar(50),myJID varchar(50),primary key(myJID))";
    NSMutableArray *createSqlArray = [[NSMutableArray alloc]init];
    [createSqlArray addObject:createUserNameSql];
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_PUBLIC_DB_PATH];
    db = [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        for (int i = 0; i<createSqlArray.count; i++){
            NSString *createSqlStr= [createSqlArray objectAtIndex:i];
            
            if (![db executeUpdate:createSqlStr]) {
                NSLog(@"error when create public table !");
                NSLog(@"%@",createSqlStr);
                
            }else{
                NSLog(@"create table public success !");
            }
            
        }
    }
    
    [db close];
    
}



//清除所有消息(fmdb)
+ (void)deleteAllMsg{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        
        NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM ChatMessage where sendUser=\"%@\" or receiveUser=\"%@\" and myJID=\"%@\"",MY_USER_NAME,MY_USER_NAME,MY_JID];
        NSString *sqlStr2 = [NSString stringWithFormat:@"DELETE FROM GroupChatMessage where sendUser=\"%@\" or myUserName=\"%@\" and myJID=\"%@\"",MY_USER_NAME,MY_USER_NAME,MY_JID];
        NSString *sqlStr3 = [NSString stringWithFormat:@"DELETE FROM ChatBuddy where myUserName=\"%@\"",MY_USER_NAME];
        
        
        if (![db executeUpdate:sqlStr]) {
            NSLog(@"error when delete ChatMessage !");
        }else{
            NSLog(@" delete ChatMessage success ! ");
        }
        
        if (![db executeUpdate:sqlStr2]) {
            NSLog(@"error when delete GroupChatMessage !");
        }else{
            NSLog(@" delete GroupChatMessage success ! ");
        }
        
        if (![db executeUpdate:sqlStr3]) {
            NSLog(@"error when delete ChatBuddy !");
        }else{
            NSLog(@" delte ChatBuddy success ! ");
        }
    }
    [db close];
}


//create database(fmdb)
//According to the user name to create the database
+ (void)createDataBase
{
    //    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
    //                                                                , NSUserDomainMask
    //                                                                , YES);
    //    NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"db.sql"];
    //    NSLog(@"数据库路径:%@",databaseFilePath);
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //
    //    [defaults setObject:databaseFilePath forKey:@"NSUD_SQLite_DB_Path"];
    //    [defaults synchronize];
    //
    //    db = [FMDatabase databaseWithPath:databaseFilePath] ;
    //
    //    [db close];
    
    
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                , NSUserDomainMask
                                                                , YES);
    NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"userName"],@"sql"]];
    NSLog(@"数据库路径:%@",databaseFilePath);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:databaseFilePath forKey:[NSString stringWithFormat:@"%@_%@" ,@"NSUD_SQLite_DB_Path",[[NSUserDefaults standardUserDefaults] stringForKey:@"userName"]]];
    
    [defaults synchronize];
    
    db = [FMDatabase databaseWithPath:databaseFilePath] ;
    
    //[db close];
}


+ (void)createPublicDataBase
{
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                , NSUserDomainMask
                                                                , YES);
    NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"publicDB.sql"];
    NSLog(@"数据库路径:%@",databaseFilePath);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:databaseFilePath forKey:SQLITE_PUBLIC_DB_PATH];
    
    //[defaults synchronize];
    
    db = [FMDatabase databaseWithPath:databaseFilePath] ;
    
    [db close];
}

//Open database(fmdb)
+ (void)openDataBase{
    
    NSLog(@"*********%@",SQLITE_DB_PATH);
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    [db open];
}

//Close database(fmdb)
+ (void)closeDataBase{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    [db close];
}



//Open database(ios)
+(void)openDataBaseSQLite{
    
    JLLog_I(@"*********%@",SQLITE_DB_PATH);
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    sqlite3_open([database_path UTF8String], &database);
    
}

//Close database(ios)
+ (void)closeDataBaseSQLite{
    sqlite3_close(database);
}


//Open public database(fmdb)
+ (void)openPublicDataBase{
    
    JLLog_I(@"*********%@",SQLITE_DB_PATH);
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_PUBLIC_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    [db open];
}

//Close public database(fmdb)
+ (void)closePublicDataBase{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_PUBLIC_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    [db close];
}

+ (void) updateDatabase
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db = [FMDatabase databaseWithPath:database_path];
    
    BOOL flag = [db open];
    if (!flag) {
        return;
    }
    
    NSMutableArray *sorts = [NSMutableArray array];
    
    FMResultSet *rs_contacts = [db executeQuery:@"select remarkName, jid from Contacts where \
                                remarkName_sort is null or \
                                remarkName_short_sort is null"];
    while ([rs_contacts next]) {
        NSString *sort_string = [rs_contacts stringForColumn:@"remarkName"];
        NSString *jid = [rs_contacts stringForColumn:@"jid"];
        
        sort_string = sort_string ? sort_string : @"";
        jid = jid ? jid : @"";
        
        [sorts addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                          [sort_string transformToPinyin], @"remarkName_sort",
                          [sort_string getPrenameAbbreviation], @"remarkName_short_sort",
                          jid, @"jid",nil]];
    }
    [rs_contacts close];
    
    [sorts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [db executeUpdate:@"update Contacts set remarkName_sort = ?, remarkName_short_sort = ? \
         where jid = ?", obj[@"remarkName_sort"], obj[@"remarkName_short_sort"], obj[@"jid"]];
    }];
    
    [sorts removeAllObjects];
    
    FMResultSet *userinfo_rs = [db executeQuery:@"select nickName, employeeName, jid from UserInfo where \
                                nickName_sort is null or \
                                nickName_short_sort is null or \
                                employeeName_sort is null or \
                                employeeName_short_sort is null"];
    
    while ([userinfo_rs next]) {
        NSString *nickName_sort = [userinfo_rs stringForColumn:@"nickName"];
        NSString *employeeName_sort = [userinfo_rs stringForColumn:@"employeeName"];
        NSString *jid = [userinfo_rs stringForColumn:@"jid"];
        
        nickName_sort = nickName_sort ? nickName_sort : @"";
        employeeName_sort = employeeName_sort ? employeeName_sort : @"";
        jid = jid ? jid : @"";
        
        [sorts addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                          [nickName_sort transformToPinyin], @"nickName_sort",
                          [employeeName_sort transformToPinyin], @"employeeName_sort",
                          [nickName_sort getPrenameAbbreviation], @"nickName_short_sort",
                          [employeeName_sort getPrenameAbbreviation], @"employeeName_short_sort",
                          jid, @"jid", nil]];
    }
    [userinfo_rs close];
    
    [sorts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [db executeUpdate:@"update UserInfo set nickName_sort = ?, employeeName_sort = ?, \
         nickName_short_sort = ?, employeeName_short_sort = ? where jid = ?", obj[@"nickName_sort"],
         obj[@"employeeName_sort"], obj[@"nickName_short_sort"], obj[@"employeeName_short_sort"],
         obj[@"jid"]];
    }];
    
    [sorts removeAllObjects];
    
    FMResultSet *group_rs = [db executeQuery:@"select name, groupJID from ChatGroup where \
                             name_sort is null or \
                             name_short_sort is null"];
    while ([group_rs next]) {
        NSString *name_sort = [group_rs stringForColumn:@"name"];
        NSString *jid = [group_rs stringForColumn:@"groupJID"];
        
        name_sort = name_sort ? name_sort : @"";
        jid = jid ? jid : @"";
        
        [sorts addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                          [name_sort transformToPinyin], @"name_sort",
                          [name_sort getPrenameAbbreviation], @"name_short_sort",
                          jid, @"groupJID", nil]];
    }
    [group_rs close];
    
    [sorts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [db executeUpdate:@"update ChatGroup set name_sort = ?, name_short_sort = ? \
         where groupJID = ?", obj[@"name_sort"], obj[@"name_short_sort"], obj[@"groupJID"]];
    }];
    
    [db close];
}

+ (NSArray *)didSearchContactWithKeyword:(NSString *)keyword
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db = [FMDatabase databaseWithPath:database_path];
    
    JLLog_I(@"........");
    BOOL flag = [db open];
    if (!flag) {
        return nil;
    }
    
    NSArray *friends = [self searchFriendsWithKeyword:keyword db:db];
    NSArray *groups = [self searchGroupsWithKeyword:keyword db:db];
    
    return @[friends, groups];
}

+ (NSArray *)searchFriendsWithKeyword:(NSString *)keyword {
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db = [FMDatabase databaseWithPath:database_path];
    
    BOOL flag = [db open];
    if (!flag) {
        return nil;
    }
    
    NSArray *friends = [self searchFriendsWithKeyword:keyword db:db];
    [db close];
    return friends;
}

+ (NSArray *)searchGroupsWithKeyword:(NSString *)keyword {
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db = [FMDatabase databaseWithPath:database_path];
    
    BOOL flag = [db open];
    if (!flag) {
        return nil;
    }
    
    NSArray *groups = [self searchGroupsWithKeyword:keyword db:db];
    [db close];
    return groups;
}

+ (NSArray *)searchFriendsWithKeyword:(NSString *)keyword db:(FMDatabase *)db
{
    NSString *string = [[keyword transformToPinyin] lowercaseString];
    NSString *condition = [NSString stringWithFormat:@"%@%%", string];
    
    NSMutableArray *friends = [@[] mutableCopy];
    FMResultSet *friends_rs = [db executeQuery:@"select u.jid, u.avatar, u.nickName, \
                               u.employeeName, c.remarkName, u.accountType \
                               from UserInfo u, Contacts c where  \
                               (c.remarkName_sort like ? or  \
                               c.remarkName_short_sort like ? or \
                               u.nickName_sort like ? or \
                               u.nickName_short_sort like ? or \
                               u.employeeName_sort like ? or \
                               u.employeeName_short_sort like ?) \
                               and c.subscription in ('none', 'both') and u.jid = c.jid",
                               condition, condition, condition, condition, condition, condition];
    
    while ([friends_rs next]) {
        NSString *jid = [friends_rs stringForColumn:@"jid"];
        NSString *avatar = [friends_rs stringForColumn:@"avatar"];
        NSString *remarkName = [friends_rs stringForColumn:@"remarkName"];
        NSString *nickName = [friends_rs stringForColumn:@"nickName"];
        NSString *employeeName = [friends_rs stringForColumn:@"employeeName"];
        NSString *accountType = [friends_rs stringForColumn:@"accountType"];
        
        jid = jid ? jid : @"";
        avatar = avatar ? avatar : @"";
        remarkName = remarkName ? remarkName : @"";
        nickName = nickName ? nickName : @"";
        accountType = accountType ? accountType : @"1";
        
        NSString *nameForShow = [AIUsersUtility nameForShowWithJID:jid];
        [friends addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            jid, @"jid",
                            nameForShow, @"name",
                            accountType, @"accountType",
                            avatar,@"avatar",
                            remarkName, @"remarkName",
                            employeeName, @"employeeName",
                            nickName, @"nickName",
                            @"chat", @"type", nil]];
    }
    [friends_rs close];
    
    return friends;
}

+ (NSArray *)searchGroupsWithKeyword:(NSString *)keyword db:(FMDatabase *)db
{
    NSString *string = [[keyword transformToPinyin] lowercaseString];
    NSString *condition = [NSString stringWithFormat:@"%@%%", string];
    
    NSMutableArray *groups = [@[] mutableCopy];
    FMResultSet *group_rs = [db executeQuery:@"select groupJID, groupMucId, name \
                             from ChatGroup where \
                             name_sort like ? or \
                             name_short_sort like ?", condition, condition];
    while ([group_rs next]) {
        NSString *groupJID = [group_rs stringForColumn:@"groupJID"];
        NSString *name = [group_rs stringForColumn:@"name"];
        NSString *groupMucId = [group_rs stringForColumn:@"groupMucId"];
        
        groupJID = groupJID ? groupJID : @"";
        name = name ? name : @"";
        groupMucId = groupMucId ? groupMucId : @"";
        
        NSArray *groupMembersArray = [GroupCRUD queryGroupMembersByGroupJID:groupJID myJID:MY_JID];
        [groups addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           groupJID, @"groupJID",
                           name, @"groupName",
                           groupMucId, @"groupMucId",
                           groupMembersArray, @"groupMembersArray",
                           @"groupchat", @"type", nil]];
    }
    [group_rs close];
    
    return groups;
}



@end
