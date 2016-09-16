//
//  GroupMembersCRUD.m
//  anbang_ios
//
//  Created by silenceSky  on 14-3-28.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "GroupMembersCRUD.h"
#import "PublicCURD.h"
#import "MyFMDatabaseQueue.h"
#import "AIUsersUtility.h"

@implementation GroupMembersCRUD
sqlite3 *database;
FMDatabase *db;
NSString *database_path;
@synthesize onlineUsers;



//批量写入
+(void) replaceGroupMembersTable:(NSMutableArray *)insertGroupMembersSqlArray
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
            [db beginTransaction];
            BOOL isRollBack = NO;
            NSLog(@"begin to insert groupMember data");
            @try {
                for (int i = 0; i<insertGroupMembersSqlArray.count; i++){
                    NSString *insertSql1= [insertGroupMembersSqlArray objectAtIndex:i];
                    BOOL a = [db executeUpdate:insertSql1];
                    if (!a) {
                        NSLog(@"插入失败：sql=%@", insertSql1);
                    }
                }
            }
            @catch (NSException *exception) {
                isRollBack = YES;
                NSLog(@"error to insert groupMember data:%@", exception);
                [db rollback];
            }
            @finally {
                if (!isRollBack) {
                    [db commit];
                    NSLog(@"succ to insert groupMember data");
                }
            }

    };
    
    [db close];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_GroupMembersVersion" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Update_Group_Member" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Group_Load_OK" object:self userInfo:nil];
}


// 更新圈子成员名称
+ (void)updateGroupMemberName:(NSString *)jid nickName:(NSString *)nickName groupJID:(NSString *)groupJID
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        NSString *updateSqlStr = @"UPDATE GroupMembers SET nickName = ? WHERE jid= ? and groupJID= ?";
        
        BOOL ok = [db executeUpdate:updateSqlStr,nickName,jid,groupJID];
        if(ok){
            NSLog(@"updateGroupMemberName ok!");
        } else {
            NSLog(@"updateGroupMemberName error!");
        }
    }
    
    [db close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Update_Group_Member"
                                                        object:nil userInfo:nil];
}


//删除某个群组成员(fmdb)
+(void)deleteGroupMember:(NSString *)groupJID memberJID:(NSString *)memberJID myJID:(NSString *)myJID{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    
    if ([db open]) {
        NSString *deleteSql = @"delete from GroupMembers where groupJID = ? and jid = ? and myJID = ?";
        
        if (![db executeUpdate:deleteSql,groupJID,memberJID,myJID]) {
            NSLog(@"error when delete member ");
        } else {
            NSLog(@"success to delete");
        }
    }
    [db close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Update_Group_Member"
                                                        object:nil userInfo:nil];
}



//删除某个群组成员
+(void)deleteGroupMember2:(NSString *)groupJID memberJID:(NSString *)memberJID myJID:(NSString *)myJID{
    
    NSString *deleteSqlStr = @"delete from GroupMembers where groupJID = ? and jid = ? and myJID = ?";
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if([db open]){
        BOOL res = [db executeUpdate:deleteSqlStr,groupJID,memberJID,myJID];
        if (!res) {
            NSLog(@"error to delete member data");
        } else {
            NSLog(@"succ to delete member data");
        }
    }
    
    [db close];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Update_Group_Member"
                                                                object:nil userInfo:nil];
}


//删除某个群组的所有成员(fmdb)
+(void)deleteAllGroupMemberByGroupId:(NSString *)groupJID  myJID:(NSString *)myJID{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *deleteSql = @"delete from GroupMembers where groupJID = ? and myJID = ?";
        
        if (![db executeUpdate:deleteSql,groupJID,myJID]) {
            NSLog(@"error when delete member");
        } else {
            NSLog(@"success to delete all groupMember");
        }
    }
    [db close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Update_Group_Member"
                                                        object:nil userInfo:nil];
}

+ (BOOL)group:(NSString *)groupJID existsMember:(NSString *)jid {
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if (![db open]) {
        return NO;
    }

    NSInteger count = 0;
    FMResultSet *rs = [db executeQuery:@"select count(*) from GroupMembers where groupJID = ? and \
                       jid = ?", groupJID, jid];
    while ([rs next]) {
        count = [rs intForColumnIndex:0];
    }
    
    return count > 0;
}


//删除全部群组成员(fmdb)
+(void)deleteAllGroupMember:(NSString *)myJID{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    
    if ([db open]) {
        NSString *deleteSql = @"delete from GroupMembers where myJID = ?";
        
        if (![db executeUpdate:deleteSql,myJID]) {
            NSLog(@"error when delete member");
        } else {
            NSLog(@"success to delete all groupMember");
        }
    }
    [db close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Update_Group_Member"
                                                        object:nil userInfo:nil];
}


//查询群组成员，根据userInfo 表 myJID 查询
+(NSMutableArray *)queryChatRoomByGroupJID:(NSString *)groupJID myJID:(NSString *)myJID
{
    NSMutableArray *groupMembers =[[NSMutableArray alloc]init];
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if([db open]){
        NSString *selectSqlStr= @"select g.jid,g.nickName,g.role,g.groupJID,u.avatar,u.phone, u.accountType from GroupMembers g, UserInfo u where g.jid=u.jid and groupJID= ? and u.myJID = ? order by g.roleSort, g.createtime, g.jid";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,groupJID,myJID];
        while ([rs next]) {
            NSString *jid=[rs stringForColumn:@"jid"];
            
            NSString *nickName = [AIUsersUtility gnameForShowWithJID:jid inGroup:groupJID];
            
            NSString *role=[rs stringForColumn:@"role"];
            
            NSString *groupJID=[rs stringForColumn:@"groupJID"];
            
            NSString *avatar=[rs stringForColumn:@"avatar"];
            
            NSString *phone=[rs stringForColumn:@"phone"];
            
            NSString *accountType = [rs stringForColumn:@"accountType"];
            
            [groupMembers addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",nickName, @"nickName",role,@"role",groupJID,@"groupJID",avatar,@"avatar",phone,@"phone", accountType, @"accountType", nil]];

        }
        
        [rs close];
    }
    [db close];
    
    return groupMembers;
}

//查询群组成员，根据userInfo 表 myJID 查询
+(NSMutableArray *)queryMembersByKeyword:(NSString *)keyword groupJID:(NSString *)groupJID myJID:(NSString *)myJID
{
    NSMutableArray *groupMembers =[[NSMutableArray alloc]init];
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if([db open]){
        FMResultSet * rs = nil;
        NSString *selectSqlStr = @"";
        if(keyword != nil && ![@"" isEqualToString:keyword]){
            selectSqlStr= @"select g.jid,g.nickName,g.role,g.groupJID,u.avatar,u.phone from GroupMembers g, UserInfo u where g.jid=u.jid and g.nickName like ? and groupJID= ? and u.myJID = ? order by g.roleSort, g.createtime, g.jid";
            rs = [db executeQuery:selectSqlStr,[NSString stringWithFormat:@"%%%@%%",keyword],groupJID,myJID];
        } else {
            selectSqlStr= @"select g.jid,g.nickName,g.role,g.groupJID,u.avatar,u.phone from GroupMembers g, UserInfo u where g.jid=u.jid and groupJID= ? and u.myJID = ? order by g.roleSort, g.createtime, g.jid";
            rs = [db executeQuery:selectSqlStr,groupJID,myJID];
        }
    
        NSLog(@"###############%@",selectSqlStr);

        while ([rs next]) {
            NSString *jid=[rs stringForColumn:@"jid"];
            
            NSString *nickName=[rs stringForColumn:@"nickName"];
            
            NSString *role=[rs stringForColumn:@"role"];
            
            NSString *groupJID=[rs stringForColumn:@"groupJID"];
            
            NSString *avatar=[rs stringForColumn:@"avatar"];
            
            NSString *phone=[rs stringForColumn:@"phone"];
            
            [groupMembers addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",nickName, @"nickName",role,@"role",groupJID,@"groupJID",avatar,@"avatar",phone,@"phone", nil]];

        }
        [rs close];
    }
    [db close];
        
    return groupMembers;
}

//查询群组成员，根据userInfo 表 myJID 查询(fmdb)
+(NSMutableArray *)queryChatRoomByGroupJID2:(NSString *)groupJID myJID:(NSString *)myJID
{
    
    NSMutableArray *groupMembers =[[NSMutableArray alloc]init];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select g.jid,g.nickName,g.role,g.groupJID,u.avatar,u.phone,u.nickName,u.accountType from GroupMembers g, UserInfo u where g.jid=u.jid and groupJID= ? and g.myJID=u.myJID and u.myJID = ? order by g.roleSort, g.createtime, g.jid";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,groupJID,myJID];
        while ([rs next]) {
            
            NSString *jid=[rs stringForColumn:@"jid"];
            
            NSString *businessCard=[rs stringForColumnIndex:1];
            
            NSString *role=[rs stringForColumn:@"role"];
            
            NSString *groupJID=[rs stringForColumn:@"groupJID"];
            
            NSString *avatar=[rs stringForColumn:@"avatar"];
            
            NSString *phone=[rs stringForColumn:@"phone"];
            
            NSString *nickName=[rs stringForColumn:@"nickName"];
            
            NSNumber *accountType = [NSNumber numberWithInt:[rs intForColumn:@"accountType"]];
            
            [groupMembers addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",nickName, @"nickName",businessCard,@"businessCard",accountType, @"accountType", role,@"role",groupJID,@"groupJID",avatar,@"avatar",phone,@"phone", nil]];
            
            
        }
        
        [rs close];
    }
    [db close];
    return groupMembers;
}


//查询某个圈子某个成员的名称(fmdb)
+(NSMutableDictionary *)queryMemberNameByMemberJID:(NSString *)groupJID memberJID:(NSString *)memberJID myJID:(NSString *)myJID
{
    
    NSMutableDictionary *groupMemberDic =[[NSMutableDictionary alloc]init];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select g.jid,g.nickName,g.role,g.groupJID,u.nickName from GroupMembers g, UserInfo u where g.jid=u.jid and groupJID= ? and g.jid= ? and g.myJID=u.myJID and u.myJID = ? order by g.roleSort, g.createtime, g.jid";
        
        NSLog(@"***%@",selectSqlStr);
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,groupJID,memberJID, myJID];
        while ([rs next]) {
            
            NSString *jid=[rs stringForColumn:@"jid"];
            
            NSString *businessCard=[rs stringForColumnIndex:1];
            
            NSString *role=[rs stringForColumn:@"role"];
            
            NSString *groupJID=[rs stringForColumn:@"groupJID"];
            
            NSString *nickName=[rs stringForColumn:@"nickName"];
            
            groupMemberDic =  [NSMutableDictionary dictionaryWithObjectsAndKeys:jid,@"jid",nickName, @"nickName",businessCard,@"businessCard",role,@"role",groupJID,@"groupJID", nil];
            
            
        }
        
        [rs close];
    }
    [db close];
    return groupMemberDic;
}

+ (NSString *)queryNickNameWithGroupJID:(NSString *)groupJID memberJID:(NSString *)memberJID
{
    NSString *nickName = nil;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        NSString *sql = @"select nickName from GroupMembers where groupJID=? and jid=?";
        
        FMResultSet *rs = [db executeQuery:sql, groupJID, memberJID];
        while ([rs next]) {
            nickName = [rs stringForColumn:@"nickName"];
        }
        [rs close];
    }
    [db close];
    return nickName;
}

@end
