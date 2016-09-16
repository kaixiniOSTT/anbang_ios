//
//  AIUsersUtility.m
//  anbang_ios
//
//  Created by rooter on 15-6-25.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIUsersUtility.h"
#import "UserInfoCRUD.h"
#import "ContactsCRUD.h"
#import "GroupMembersCRUD.h"

static FMDatabase *db = nil;

@implementation AIUsersUtility

+ (NSString *)nameForShowWithJID:(NSString *)aJID {
    NSString *name = nil;
    UserInfo *userInfo = [UserInfo loadArchive];
    NSNumber *myAccountType = [NSNumber numberWithInt:userInfo.accountType];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db = [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select case when u.accountType = '2' and 2 = ? then u.employeeName when c.remarkName is not null and c.remarkName <> '' then c.remarkName else u.nickname end name from userInfo u left join contacts c on c.jid = u.jid where u.jid = ?", myAccountType,aJID];
        while ([rs next]) {
            name = [rs stringForColumn:@"name"];
        }
        [rs close];
    }
    [db close];
    return name;
}

+ (NSString *)gnameForShowWithJID:(NSString *)aJID
                          inGroup:(NSString *)groupJID {
    if ([aJID isEqualToString:MY_JID]) {
        return [GroupMembersCRUD queryNickNameWithGroupJID:groupJID memberJID:MY_JID];
    }
    
    NSString *gname = nil;
    UserInfo *userInfo = [UserInfo loadArchive];
    NSNumber *myAccountType = [NSNumber numberWithInt:userInfo.accountType];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db = [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select case when u.accountType = '2' and 2 = ? then u.employeeName when c.remarkName is not null and c.remarkName <> '' then c.remarkName when g.nickName is not null then g.nickName else u.nickname end name from userInfo u left join contacts c on c.jid = u.jid left join GroupMembers g on g.groupJID = ? and g.jid = u.jid where u.jid = ?", myAccountType, groupJID, aJID];
        while ([rs next]) {
            gname = [rs stringForColumn:@"name"];
        }
        [rs close];
    }
    
    [db close];
    return gname;
}

+ (NSMutableDictionary*)gnameForShowWithJIDs:(NSArray *)aJIDs
                          inGroup:(NSString *)groupJID {
    NSMutableDictionary *gnames = [@{} mutableCopy];
    UserInfo *userInfo = [UserInfo loadArchive];	
    NSNumber *myAccountType = [NSNumber numberWithInt:userInfo.accountType];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db = [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select u.jid, case when u.accountType = '2' and 2 = ? then u.employeeName when c.remarkName is not null and c.remarkName <> '' then c.remarkName when g.nickName is not null then g.nickName else u.nickname end name from userInfo u left join contacts c on c.jid = u.jid left join GroupMembers g on g.groupJID = ? and g.jid = u.jid where u.jid in ('%@')", [aJIDs componentsJoinedByString:@"','"]];
        
        FMResultSet *rs = [db executeQuery:sql, myAccountType, groupJID];
        while ([rs next]) {
            gnames[[rs stringForColumn:@"jid"]] = [rs stringForColumn:@"name"];
        }
        [rs close];
    }
    
    [db close];
    return gnames;
}

@end
