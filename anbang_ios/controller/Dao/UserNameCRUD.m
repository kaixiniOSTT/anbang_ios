//
//  UserNameCRUD.m
//  anbang_ios
//
//  Created by seeko on 14-5-10.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "UserNameCRUD.h"
#import "PublicCURD.h"
#import "sqlite3.h"
#import "MyFMDatabaseQueue.h"

@implementation UserNameCRUD
sqlite3 *database;
FMDatabase *db;

+(void)createChatBuddyTable
{
    //[self openDataBase];
    char *errorMsg;
    const char *createSql="create table if not exists UserName (userName varchar(20),myJID varchar(50),primary key(myJID))";
    
    //    const char *createSql="create table if not exists IDtable (id integer primary key autoincrement, ID varchar(20))";
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        //        NSLog(@"UserName create ok.");
    }
    else
    {
        //        NSLog( @"can not create ChatBuddy" );
        //[self ErrorReport:(NSString *)createSql];
    }
}

+(void)deleteUserName:(NSString *)userName{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_PUBLIC_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        
        NSString *deleteSqlStr=[NSString stringWithFormat:@"delete  from UserName where userName = \"%@\" ",userName];
        
        if (![db executeUpdate:deleteSqlStr]) {
            NSLog(@"error when delete PublicDB userName !");
        }else{
            NSLog(@" delete PublicDB userName  success ! ");
            NSDictionary *myDictionary = [NSDictionary dictionaryWithObject:userName forKey:@"sendKey"];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NNS_Delete_UserName" object:nil userInfo:myDictionary];
        }
        
    }
    [db close];
    
}


+(void)insertIDtable:(NSString *)userName avatar:(NSString*)avatar myJID:(NSString *)myJID
{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_PUBLIC_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        
        NSString *insertSqlStr=[NSString stringWithFormat:@"replace into UserName (userName,avatar,myJID) values (\"%@\",\"%@\",\"%@\")",userName,avatar,myJID];
        
        if (![db executeUpdate:insertSqlStr]) {
            NSLog(@"error when insertSql UserName ");
            
        } else {
            NSLog(@"success to insertSql UserName");
        }
        
    }
    [db close];
    
}




+(NSMutableArray *)selectIDtable{
    
    NSMutableArray *userNameArr=[[NSMutableArray alloc]initWithObjects: nil];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_PUBLIC_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        
        NSString *selectSqlStr=[NSString stringWithFormat:@"select userName,myJID,avatar from UserName"];
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            
            NSString *userName = [rs stringForColumn:@"userName"];
            NSString *avatar =[rs stringForColumn:@"avatar"];
            NSString *myJID =[rs stringForColumn:@"myJID"];
            
            NSLog(@"****%@",myJID);
            
            [userNameArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:userName,@"userName",avatar, @"avatar",myJID, @"myJID", nil]];
            
        }
        [rs close];
    }
    
    [db close];
    
    return userNameArr;
}




//error
+ (void)ErrorReport: (NSString *)item
{
    char *errorMsg;
    
    const char *itemChar = [item UTF8String];
    
    if (sqlite3_exec(database, (const char *)itemChar, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        //NSLog(@"%@ ok.",item);
    }
    else
    {
        // NSLog(@"error: %s",errorMsg);
        sqlite3_free(errorMsg);
    }
}
@end
