//
//  RoomCRUD.m
//  anbang_ios
//
//  Created by silenceSky  on 14-3-26.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "GroupCRUD.h"
#import "Utility.h"
#import "ChatGroup.h"
#import "PublicCURD.h"
#import "MyFMDatabaseQueue.h"
#import "AIUsersUtility.h"
#import "NSString+Chinese.h"

@implementation GroupCRUD

sqlite3 *database;
FMDatabase *db;
NSString *database_path;

@synthesize onlineUsers;

//群组数据库操作
+(void)createChatRoomTable
{
    // [self openDataBase];inviteUrl
    char *errorMsg;
    NSString *createSqlStr=@"create table if not exists ChatGroup (groupJID varchar(50), name varchar(50),creator varchar(50),groupMucId varchar(50),myJID varchar(50),version varchar(20),inviteUrl varchar(100),createDate varchar(30),modificationDate varchar(30)),primary key(groupJID,myJID)";
    
    const char *createSql="create table if not exists ChatGroup (groupJID varchar(50), name varchar(50),creator varchar(50),groupMucId varchar(50),myJID varchar(50),version varchar(20),inviteUrl varchar(100),createDate varchar(30),modificationDate varchar(30),primary key(groupJID,myJID))";
    
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"ChatRoom create ok.");
    }
    else
    {
        NSLog( @"can not create ChatGroup" );
        [self ErrorReport:(NSString *)createSqlStr];
    }
}





//多线程写入
+(void) replaceGroup:(NSMutableArray *)insertGroupSqlArray version:(NSString*)ver
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if([db open]){
        [db beginTransaction];
        BOOL isRollBack = NO;
        NSLog(@"begin to insert group data");
        @try {
            for (int i = 0; i<insertGroupSqlArray.count; i++){
                NSString *insertSql1= [insertGroupSqlArray objectAtIndex:i];
                BOOL a = [db executeUpdate:insertSql1];
                if (!a) {
                    NSLog(@"插入失败：sql=%@", insertSql1);
                }
            }
        }
        @catch (NSException *exception) {
            isRollBack = YES;
            NSLog(@"error to insert group data:%@", exception);
            [db rollback];
        }
        @finally {
            if (!isRollBack) {
                [db commit];
                NSLog(@"succ to insert group data");
            }
        }
    }
    
    [db close];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:ver forKey:@"Ver_Query_Roster"];

}


//单线程批量写入
+(void) replaceGroup2:(NSMutableArray *)insertGroupSqlArray
{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        for (int i = 0; i<insertGroupSqlArray.count; i++){
            NSString *insertSql1= [insertGroupSqlArray objectAtIndex:i];
            
            if (![db executeUpdate:insertSql1]) {
                NSLog(@"error when insertSql1 group ");
                [self ErrorReport: (NSString *)insertSql1];
            } else {
                
                NSLog(@"success to insertSql1 group");
            }
            
        }
    }
    [db close];
    
}



//查询groupJID version(fmdb)
+(NSMutableArray *)queryGroupInfo:(NSString *)myJID
{
    NSMutableArray *groupArray =[[NSMutableArray alloc]init];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select groupJID,version from ChatGroup where myJID = ?";
        
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,myJID];
        while ([rs next]) {
            
            NSString *groupJID= [rs stringForColumn:@"groupJID"];
            
            NSString *version=[rs stringForColumn:@"version"];
            
            [groupArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:groupJID,@"groupJID",version, @"version", nil]];
            
        }
        [rs close];
    }
    [db close];
    return groupArray;
}



/*根据版本号更新群信息（圈子）*/


+ (void)updateGroupInfo:(NSString *)groupJID name:(NSString *)name  myJID:(NSString *)myJID version:(NSString *)version  modificationDate:(NSString *)modificationDate
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        NSString *updateSqlStr= @"UPDATE ChatGroup SET name =?,modificationDate = ?,version = ?, name_sort=?, name_short_sort=? WHERE groupJID= ? and myJID = ?";

        BOOL ok = [db executeUpdate:updateSqlStr,name,modificationDate,version, groupJID,[name transformToPinyin],[name getPrenameAbbreviation], myJID];
        if(ok){
            NSLog(@"update ok!");
        } else {
            NSLog(@"update error!");
        }
    }
    
    [db close];
}

//查询是否有更新
+ (BOOL)queryGroupInfoVersionUpd:(NSString *)groupJID myJID:(NSString *)myJID ver:(NSString *)ver
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    NSString * verStr = @"";
    BOOL updateBool = NO;
    if ([db open]) {
        
        NSString *selectSqlStr= @"select version from ChatGroup where  groupJID= ? and myJID = ?";
        
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,groupJID,myJID];
        while ([rs next]) {
            //verStr = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            verStr = [rs stringForColumn:@"version"];
        }
        [rs close];
    }
    if ([ver isEqualToString:verStr]) {
        updateBool = YES;
    }
    [db close];
    
    return updateBool;
}


//query table
//+ (int)queryChatRoomTableCountId:(NSString *)jid myJID:(NSString *)myJID
//{
//    //[self openDataBase];
//    NSString *selectSqlStr=[NSString stringWithFormat:@"select count(*) from ChatGroup where  groupJID=\"%@\" and myJID = \"%@\" ",jid,myJID];
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


//查询group count(fmdb)
+ (int)queryChatRoomTableCountId:(NSString *)jid myJID:(NSString *)myJID
{
    int count = 0;
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select count(*) from ChatGroup where  groupJID= ? and myJID = ?";
        
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,jid,myJID];
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
            
        }
        [rs close];
    }
    [db close];
    return count;
}


//+ (void)deleteMyGroup:(NSString *)groupJID myJID:(NSString *)myJID
//{
//
//    NSLog(@"*****%@",groupJID);
//    char *errorMsg;
//
//    NSString *deleteSqlStr=[NSString stringWithFormat:@"DELETE FROM ChatGroup where groupJID=\"%@\" and myJID=\"%@\"",groupJID,myJID];
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
//
//}


//删除群组(fmdb)
+ (void)deleteMyGroup:(NSString *)groupJID myJID:(NSString *)myJID
{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *deleteSqlStr= @"DELETE FROM ChatGroup where groupJID= ? and myJID= ?";
        NSLog(@"********%@",deleteSqlStr);
        
        if (![db executeUpdate:deleteSqlStr,groupJID,myJID]) {
            NSLog(@"error when delete group");
            [self ErrorReport: (NSString *)deleteSqlStr];
        } else {
            NSLog(@"success to delete group");
        }
    }
    [db close];
}

//删除所有群组(fmdb)
+ (void)deleteAllMyGroup{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *deleteSqlStr=[NSString stringWithFormat:@"DELETE FROM ChatGroup"];
        NSLog(@"********%@",deleteSqlStr);
        
        if (![db executeUpdate:deleteSqlStr]) {
            NSLog(@"error when delete group ");
            [self ErrorReport: (NSString *)deleteSqlStr];
        } else {
            NSLog(@"success to delete group");
        }
    }
    [db close];
    
    
}


+(void)dropChatRoomTable
{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    
    NSString *sqlStr = @"DROP TABLE ChatGroup";
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
    [PublicCURD closeDataBaseSQLite];
}


+(ChatGroup *)queryChatGroupByJID:(NSString *)groupMucId myJID:(NSString *)myJID
{
    ChatGroup * chatGroup = [[ChatGroup alloc]init];
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select groupJID,name,creator,groupMucId,createDate,modificationDate from ChatGroup where groupMucId=\"%@\" and myJID=\"%@\"",groupMucId,myJID];
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            NSString *jid=[rs stringForColumn:@"groupJID"];
            NSString *name=[rs stringForColumn:@"name"];
            NSString *creator=[rs stringForColumn:@"creator"];
            NSString *groupMucId=[rs stringForColumn:@"groupMucId"];
            NSString *createDate=[rs stringForColumn:@"createDate"];
            NSString *modificationDate=[rs stringForColumn:@"modificationDate"];
            //NSLog(@"%@,%@,%@",name,creator,createDate);
            chatGroup.jid = jid;
            chatGroup.name = name;
            chatGroup.creator = creator;
            chatGroup.groupMucId = groupMucId;
            chatGroup.createDate = createDate;
            chatGroup.modificationDate = modificationDate;
        }
        [rs close];
    }
    [db close];
    
    return chatGroup;
}

+ (NSString *)queryGroupTypeWithJID:(NSString *)groupJID {
    
    NSString *groupType = nil;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        
        NSString *selectSqlStr=[NSString stringWithFormat:@"select groupType from ChatGroup where groupJID=\"%@\"",groupJID];
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            groupType = [rs stringForColumn:@"groupType"];
        }
        [rs close];
    }
    [db close];
    
    return groupType;
}

//查询所有圈子
+(NSMutableArray *)queryAllChatGroupByMyJID2:(NSString *)myJID
{
    [PublicCURD openDataBaseSQLite];
    
    NSMutableArray *groupArray =[[NSMutableArray alloc]init];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select groupJID,name,creator,groupMucId,createDate,modificationDate from ChatGroup where myJID = \"%@\" ",myJID];
    
    NSLog(@"###############%@",selectSqlStr);
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    
    
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            // int _id=sqlite3_column_int(statement, 0);
            
            NSString *jid=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            
            NSString *name=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            
            NSString *creator=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            
            NSString *groupMucId=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            
            NSString *createDate=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            
            NSString *modificationDate=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            
            //NSLog(@"%@,%@,%@",name,creator,createDate);
            
            [groupArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"groupJID",name, @"groupName",creator,@"creator",groupMucId,@"groupMucId",createDate,@"createDate", modificationDate, @"modificationDate", nil]];
            
        }
        NSLog(@"*****%d",groupArray.count);
    }
    [PublicCURD closeDataBaseSQLite];
    
    return groupArray;
}



//查询所有圈子
+(NSMutableArray *)queryAllChatGroupByMyJID:(NSString *)myJID
{
    
    NSMutableArray *groupArray =[[NSMutableArray alloc]init];
    NSMutableArray *groupMembersArray = nil;
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr = @"select groupJID,name,creator,groupMucId,groupType,createDate,modificationDate from ChatGroup where myJID = ? ";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,myJID];
        while ([rs next]) {
            
            NSString *jid=[rs stringForColumn:@"groupJID"];
            
            NSString *name=[rs stringForColumn:@"name"];
            
            NSString *creator=[rs stringForColumn:@"creator"];
            
            NSString *groupMucId=[rs stringForColumn:@"groupMucId"];
            
            NSString *groupType = [rs stringForColumn:@"groupType"];
            
            NSString *createDate=[StrUtility string:[rs stringForColumn:@"createDate"]];
            
            NSString *modificationDate=[StrUtility string:[rs stringForColumn:@"modificationDate"]];
            
            
            //实现圈子头像
            groupMembersArray = [self queryGroupMembersByGroupJID:jid myJID:MY_JID];
            
            
            
            [groupArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"groupJID",name, @"groupName",creator,@"creator",groupMucId,@"groupMucId",groupType,@"groupType",groupMembersArray,@"groupMembersArray",createDate,@"createDate", modificationDate, @"modificationDate",[self fetchGroupTempName:groupMembersArray inGroup:jid],@"groupTempName",nil]];
            
        }
        
        [rs close];
    }
    [db close];
    return groupArray;
}

+(NSString*) fetchGroupTempName:(NSArray*)groupMembersArray inGroup:(NSString *)groupJID
{
    if (groupMembersArray.count == 0) {
        return @"";
    }
    NSString *groupTempName = @"";
    NSMutableArray *JIDArray = [NSMutableArray array];
    
    for (NSDictionary *d in groupMembersArray) {
        [JIDArray addObject:d[@"jid"]];
    }
    
    NSDictionary *nameDict = [AIUsersUtility gnameForShowWithJIDs:JIDArray inGroup:groupJID];
    NSMutableArray *nameArray = [@[] mutableCopy];
    for (NSDictionary *d in groupMembersArray) {
        [nameArray addObject:nameDict[d[@"jid"]]];
    }
    
//    for (int i=0; i<groupMembersArray.count && i < 9; i++) {
//        NSDictionary *groupDic = [groupMembersArray objectAtIndex:i];
//        [JIDArray addObject:groupDic[@"jid"]];
//    }
//    NSDictionary *nameDict = [AIUsersUtility gnameForShowWithJIDs:JIDArray inGroup:groupJID];
//    
//    
//    for (int i=0; i<groupMembersArray.count && i < 9; i++) {
//        NSDictionary *groupDic = [groupMembersArray objectAtIndex:i];
//        [nameArray addObject:nameDict[groupDic[@"jid"]]];
//    }
    
    groupTempName = [nameArray componentsJoinedByString:@","];
//    JLLog_I(@"groupTempName=%@", groupTempName);
    return groupTempName;
}


//查询自己的圈子
+(NSMutableArray *)queryMyChatGroupByMyJID2:(NSString *)myJID
{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    NSMutableArray *groupArray =[[NSMutableArray alloc]init];
    
    if ([db open]) {
        NSString *selectSqlStr = @"select groupJID,name,creator,groupMucId,createDate,modificationDate from ChatGroup where myJID = ? and creator = ?";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,myJID,myJID];
        while ([rs next]) {
            NSString *jid= [rs stringForColumn:@"groupJID"];
            
            NSString *name=[rs stringForColumn:@"name"];
            
            NSString *creator=[rs stringForColumn:@"creator"];
            
            NSString *groupMucId=[rs stringForColumn:@"groupMucId"];
            
            NSString *createDate=[rs stringForColumn:@"createDate"];
            
            NSString *modificationDate=[rs stringForColumn:@"modificationDate"];
            
            [groupArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"groupJID",name, @"groupName",creator,@"creator",groupMucId,@"groupMucId",createDate,@"createDate", modificationDate, @"modificationDate", nil]];
        }
        
        [rs close];
    }
    [db close];
    return groupArray;
}



//查询自己的圈子(fmdb)
+(NSMutableArray *)queryMyChatGroupByMyJID:(NSString *)myJID
{
    
    NSMutableArray *groupArray =[[NSMutableArray alloc]init];
    NSMutableArray *groupMembersArray = nil;
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select groupJID,name,creator,groupMucId,groupType,createDate,modificationDate from ChatGroup where myJID = ? and creator = ?";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,myJID,myJID];
        while ([rs next]) {
            
            NSString *jid= [rs stringForColumn:@"groupJID"];
            
            NSString *name=[rs stringForColumn:@"name"];
            
            NSString *creator=[rs stringForColumn:@"creator"];
            
            NSString *groupMucId=[rs stringForColumn:@"groupMucId"];
            
             NSString *groupType=[rs stringForColumn:@"groupType"];
            
            NSString *createDate=[StrUtility string:[rs stringForColumn:@"createDate"]];
            
            NSString *modificationDate=[StrUtility string:[rs stringForColumn:@"modificationDate"]];
            
            NSLog(@"*****%@,%@,%@",name,creator,createDate);
            
            //实现圈子头像
            groupMembersArray = [self queryGroupMembersByGroupJID:jid myJID:MY_JID];
            
            //NSLog(@"************%d",groupMembersArray.count);
            
            [groupArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"groupJID",name, @"groupName",creator,@"creator",groupMucId,@"groupMucId",groupType,@"groupType",createDate,@"createDate", modificationDate, @"modificationDate",groupMembersArray,@"groupMembersArray", nil]];
        }
        [rs close];
    }
    [db close];
    return groupArray;
}


//查询自己的圈子个数(fmdb)
+(int)queryCountGroupByMyJID:(NSString *)myJID
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    int count = 0;
    if ([db open]) {
        NSString *selectSqlStr= @"select count(*) from ChatGroup where myJID = ? and creator = ?";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr, myJID, myJID];
        while ([rs next]) {
            
            count = [rs intForColumnIndex:0];;
            
        }
        [rs close];
    }
    [db close];
    return count;
}


//查询群组成员，根据userInfo 表 myJID 查询(fmdb)
+(NSMutableArray *)queryGroupMembersByGroupJID:(NSString *)groupJID myJID:(NSString *)myJID
{
    NSMutableArray *groupMembers =[[NSMutableArray alloc]init];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select g.jid,g.nickName as gname, u.nickName as uname,g.role,g.groupJID,u.avatar,u.phone,u.accountType, g.role, g.createtime from GroupMembers g, UserInfo u where g.jid=u.jid and groupJID= ? and g.myJID=u.myJID and u.myJID = ? order by g.roleSort, g.createtime, g.jid";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,groupJID,myJID];
        while ([rs next]) {
            
            NSString *jid=[rs stringForColumn:@"jid"];
            NSString *nickName=[rs stringForColumn:@"gname"];
            if (nickName == nil || [nickName isEqualToString:@""]) {
                nickName = [rs stringForColumn:@"uname"];
            }
            //  NSString *role=[rs stringForColumn:@"role"];
            //  NSString *groupJID=[rs stringForColumn:@"groupJID"];
            
            NSString *avatar=[rs stringForColumn:@"avatar"];
            
            //NSString *phone=[rs stringForColumn:@"phone"];
            
            NSString *accountType=[rs stringForColumn:@"accountType"];
            
            NSString *role=[rs stringForColumn:@"role"];
            NSString *createtime=[StrUtility string:[rs stringForColumn:@"createtime"]];
            
            [groupMembers addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",nickName,@"nickName",avatar,@"avatar",accountType,@"accountType" ,role, @"role", createtime, @"createtime", nil]];
   
        }
        
        [rs close];
    }
    [db close];
    return groupMembers;
}



//查询自己的某一个圈子
+(NSDictionary *)queryOneMyChatGroup:(NSString *)groupJID myJID:(NSString *)myJID
{
    NSDictionary *groupDic =[[NSDictionary alloc]init];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        NSString *selectSqlStr= @"select groupJID,name,creator,groupMucId,createDate,modificationDate,inviteUrl from ChatGroup where groupJID = ? and myJID = ?";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,groupJID,myJID];
        while ([rs next]) {
            
            NSString *groupJID=[rs stringForColumn:@"groupJID"];
            NSString *name=[rs stringForColumn:@"name"];

            NSString *creator=[rs stringForColumn:@"creator"];
            NSString *groupMucId=[rs stringForColumn:@"groupMucId"];
            
            NSString *createDate=[rs stringForColumn:@"createDate"];
            
            NSString *modificationDate=[rs stringForColumn:@"modificationDate"];
            
            NSString *inviteUrl=[rs stringForColumn:@"inviteUrl"];
            
            groupDic = [NSDictionary dictionaryWithObjectsAndKeys:groupJID,@"groupJID",name, @"groupName",creator,@"creator",groupMucId,@"groupMucId",createDate,@"createDate", modificationDate, @"modificationDate",inviteUrl,@"inviteUrl", nil];
        }
        
        [rs close];
    }
    [db close];
    return groupDic;
}


//查询自己的某一个圈子(fmdb)
+(ChatGroup *)queryOneMyChatGroup2:(NSString *)groupJID myJID:(NSString *)myJID
{
    ChatGroup * chatGroup = [[ChatGroup alloc]init];
    NSMutableArray *groupMembersArray = nil;
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr = @"select groupJID,name,creator,groupMucId,groupType,createDate,modificationDate from ChatGroup where groupJID = ? and myJID = ?";
        
        NSLog(@"********%@",selectSqlStr);
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,groupJID,myJID];
        while ([rs next]) {
            
            NSString *jid= [rs stringForColumn:@"groupJID"];
            
            NSString *name=[rs stringForColumn:@"name"];
            
            NSString *creator=[rs stringForColumn:@"creator"];
            
            NSString *groupMucId=[rs stringForColumn:@"groupMucId"];
            
            NSString *groupType=[rs stringForColumn:@"groupType"];
            
            NSString *createDate=[StrUtility string:[rs stringForColumn:@"createDate"]];
            
            NSString *modificationDate=[StrUtility string:[rs stringForColumn:@"modificationDate"]];
            
            NSLog(@"*****%@,%@,%@",name,creator,groupType);
            
            chatGroup.jid = jid;
            chatGroup.name = name;
            chatGroup.creator = creator;
            chatGroup.groupMucId = groupMucId;
            chatGroup.groupType = groupType;
            chatGroup.createDate = createDate;
            chatGroup.modificationDate = modificationDate;
            
            
            //实现圈子头像
            groupMembersArray = [self queryGroupMembersByGroupJID:jid myJID:MY_JID];
            
            chatGroup.groupMembersArray = groupMembersArray;
            
        }
        [rs close];
    }
    [db close];
    return chatGroup;
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

+ (void)addStickieTime:(NSString *)stickieTime withJID:(NSString *)groupMucId
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        [db executeUpdate:@"update ChatGroup set stickie_time = ? where groupMucId = ?", stickieTime, groupMucId];
    }
    [db close];
}

+ (NSString *)queryStickieTimeWithJID:(NSString *)jid
{
    NSString *userName = [jid componentsSeparatedByString:@"@"][0];
    NSString *groupJID = [NSString stringWithFormat:@"%@@%@", userName, GroupDomain];
    NSString *groupMucId = [NSString stringWithFormat:@"%@@%@", userName, GroupMucIdDomain];
    
    NSString *stickie_time_01 = nil;
    NSString *stickie_time_02 = nil;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        
        FMResultSet *rs_01 = [db executeQuery:@"select stickie_time from ChatGroup where groupJID = ?", groupJID];
        FMResultSet *rs_02 = [db executeQuery:@"select stickie_time from ChatGroup where groupMucId = ?", groupMucId];
        
        while ([rs_01 next]) {
            stickie_time_01 = [rs_01 stringForColumn:@"stickie_time"];
        }
        while ([rs_02 next]) {
            stickie_time_02 = [rs_02 stringForColumn:@"stickie_time"];
        }
        
        [rs_01 close];
        [rs_02 close];
    }
    [db close];
    
    if (!stickie_time_01 && !stickie_time_02) {
        stickie_time_01 = @"0";
        NSArray *subString = [groupJID componentsSeparatedByString:@"@"];
        NSString *gorupMucId = [NSString stringWithFormat:@"%@@%@", subString[0], GroupMucIdDomain];
        [self addStickieTime:stickie_time_01 withJID:gorupMucId];
    }
    
    return stickie_time_01 ? stickie_time_01 : stickie_time_02;
}

@end
