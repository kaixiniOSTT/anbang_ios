//
//  DndInfoCRUD.m
//  anbang_ios
//
//  Created by yangsai on 15/4/7.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "DndInfoCRUD.h"
#import "PublicCURD.h"
#import "MyFMDatabaseQueue.h"

@implementation DndInfoCRUD


sqlite3 *database;
FMDatabase *db;
NSString *database_path;


+ (void)createOfRosterExtTable{
    char *errorMsg;
    NSString *createSqlStr=@"CREATE  TABLE  IF NOT EXISTS  OFROSTEREXT (USERNAME VARCHAR(64)  NOT NULL , JID VARCHAR(1024)  NOT NULL , DND INTEGER(1)  NOT NULL DEFAULT 0, SHOWPROFILE INTEGER(1)  NOT NULL DEFAULT 1)";
    
    const char *createSql=[createSqlStr UTF8String];
    
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"ChatRoom create ok.");
    }
    else
    {
        NSLog( @"can not create   OfResterExt" );
        [self ErrorReport:(NSString *)createSqlStr];
    }

}

//写入群组信息
+ (void)insertOfRosterExtTableWithUserName:(NSString *)userName Jid:(NSString *)jid Dnd:(NSString*) dnd{
    
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
         NSString *insertSqlStr=[NSString stringWithFormat:@"insert or replace into OFROSTEREXT (username, Jid, dnd) values (\"%@\",\"%@\",\"%@\")",userName, jid, dnd];
        
        if (![db executeUpdate:insertSqlStr]) {
            NSLog(@"error when insert  OfResterExt ");
            
        } else {
            NSLog(@"success to insert  OfResterExt");
        }
    }
    [db close];
    
    
}

 

//查询jid
+(BOOL)queryOfRosterExtWithJid:(NSString *)Jid{
    
    NSMutableArray *groupArray =[[NSMutableArray alloc]init];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select jid, dnd  from OfRosterExt where jid = \"%@\"",Jid];
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            
            NSString *Jid= [rs stringForColumn:@"jid"];
            
            NSString *Dnd=[rs stringForColumn:@"dnd"];
            
            [groupArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:Jid,@"jid",Dnd, @"dnd", nil]];
            
        }
        [rs close];
    }
    [db close];
    
    if(groupArray.count <= 0 || groupArray.count >= 2){
        return NO;
    }else{
        NSString* dnd = [[groupArray firstObject] objectForKey:@"dnd"];
        if ([dnd isEqualToString:@"1"]) {
            return YES;
        }else{
            return NO;
        }
    }
    
    return NO;
}



+(NSInteger)queryOfRosterExtNumberWithJid:(NSString *)Jid{
    NSMutableArray *groupArray =[[NSMutableArray alloc]init];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select jid, dnd  from OfRosterExt where jid = \"%@\"",Jid];
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            
            NSString *Jid= [rs stringForColumn:@"jid"];
            
            NSString *Dnd=[rs stringForColumn:@"dnd"];
            
            [groupArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:Jid,@"jid",Dnd, @"dnd", nil]];
            
        }
        [rs close];
    }
    [db close];
    
    return groupArray.count;
}

+(void)updateOfRosterExtWithJid:(NSString *)Jid Dnd:(NSString *)dnd{

    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
       NSString *updateSqlStr=[NSString stringWithFormat:@"update OfRosterExt set dnd = \"%@\" where jid = \"%@\"",dnd, Jid];
        if (![db executeUpdate:updateSqlStr]) {
            NSLog(@"error when update  OfResterExt ");
            
        } else {
            NSLog(@"success to update  OfResterExt");
        }
    }
    [db close];
    
}



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

+(NSArray*)queryDNDList
{
    NSMutableArray *dndList = [NSMutableArray array];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select jid from OfRosterExt where dnd = 1 and jid like ?";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr, [NSString stringWithFormat:@"%%%@%%",OpenFireHostName]];
        while ([rs next]) {
            NSString *username = [[rs stringForColumn:@"jid"] componentsSeparatedByString:@"@"][0];
            [dndList addObject:username];
        }
        [rs close];
    }
    [db close];
    
    return dndList;
}

+(NSArray*)queryGroupDNDList
{
    NSMutableArray *dndList = [NSMutableArray array];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select jid from OfRosterExt where dnd = 1 and jid like ?";
        
        FMResultSet * rs = [db executeQuery:selectSqlStr, [NSString stringWithFormat:@"%%%@%%",GroupMucIdDomain]];
        while ([rs next]) {
            [dndList addObject:[rs stringForColumn:@"jid"]];
        }
        [rs close];
    }
    [db close];
    
    return dndList;
}

@end
