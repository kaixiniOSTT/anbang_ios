//
//  AddressBookCRUD.m
//  anbang_ios
//
//  Created by seeko on 14-5-16.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "AddressBookCRUD.h"
#import "PublicCURD.h"

@implementation AddressBookCRUD

sqlite3 *database;
FMDatabase *db;
NSString *database_path;



+(void)creatAddressBookTable{
    
        char *errorMsg;
        const char *createSql="create table if not exists AddressBook (myJid varchar(20),name varchar(20),phoneNum varchar(20),jid varchar(20),ver varchar(20),primary key(myJid,name,phoneNum))";
        
        //    const char *createSql="create table if not exists IDtable (id integer primary key autoincrement, ID varchar(20))";
        
        if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
        {
        }
        else
        {
        }
}
+(void)insertServerAddressBookMyJid:(NSString *)myJid name:(NSString *)name phoneNum:(NSString *)PhoneNum jid:(NSString *)jid ver:(NSString *)ver{
    
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *insertSqlStr=[NSString stringWithFormat:@"insert or replace into AddressBook (myJid,name,phoneNum,jid,ver) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",myJid,name,PhoneNum,jid,ver];
    
    
    const char *insertSql = [insertSqlStr UTF8String];
    
    if (sqlite3_exec(database, insertSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        
        NSLog(@"insert AddressBook OK!");
        
    }
    else
    {
    }
    
    [PublicCURD closeDataBaseSQLite];
}

+(void)insertLocilAddressBookmyJid:(NSString *)myJid name:(NSString *)name phoneNum:    (NSString *)PhoneNum{
    
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *insertSqlStr=[NSString stringWithFormat:@"insert or replace into AddressBook (myJid,name,phoneNum) values (\"%@\",\"%@\",\"%@\")",myJid,name,PhoneNum];
    
    
    const char *insertSql = [insertSqlStr UTF8String];
    
    if (sqlite3_exec(database, insertSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
//        [self deleteAddressBookMyJid:myJid];
//        return;
    }
    else
    {
    }
    
    [PublicCURD closeDataBaseSQLite];
    
}


+(void)deleteAddressBookMyJid:(NSString *)myJid{
    
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *deleteSqlStr=[NSString stringWithFormat:@"delete  from AddressBook where myJid = \"%@\" ",myJid];
    
    const char *deleteSql = [deleteSqlStr UTF8String];
    
    if (sqlite3_exec(database, deleteSql, 0, 0, &errorMsg)==SQLITE_OK)
    {
        
    }else{
    }
    
    [PublicCURD closeDataBaseSQLite];
    
}
+(void)deleteAddressBookPhoneNum:(NSString *)phoneNum{
    
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *deleteSqlStr=[NSString stringWithFormat:@"delete  from AddressBook where phoneNum = \"%@\" ",phoneNum];
    
    const char *deleteSql = [deleteSqlStr UTF8String];
    
    if (sqlite3_exec(database, deleteSql, 0, 0, &errorMsg)==SQLITE_OK)
    {
        
    }else{
    }
    
    [PublicCURD closeDataBaseSQLite];
    
}
+(NSMutableArray *)selectAddressBookJid{
    
    [PublicCURD openDataBaseSQLite];
    
    NSString *selectSqlStr=@"select myJid from AddressBook";
    const char *selectSql=[selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    NSString *jid = nil;
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
//        NSLog(@"select ok.");
        BOOL isHave=NO;
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            //int _id=sqlite3_column_int(statement, 0);
            
            jid=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            if (isHave) {
                if (![jid isEqual:[arr objectAtIndex:0]]) {
                    [arr addObject:jid];
                }
            }else{
                [arr addObject:jid];
            }
            isHave=YES;
        }
    }
  
    
    
    [PublicCURD closeDataBaseSQLite];
    return arr;
}
+(NSMutableArray *)selectAddressBookPhoneNum:(NSString *)myJid{
    [PublicCURD openDataBaseSQLite];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select phoneNum from AddressBook where myJid=\"%@\"",myJid];
    const char *selectSql=[selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
//        NSLog(@"select ok.");
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
           NSString *phoneNum= [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            
            [arr addObject:phoneNum];
        }
    }
    
    [PublicCURD closeDataBaseSQLite];
    return arr;
}


//群组添加成员服务端通讯录列表（silence sky)
+(NSMutableArray *)queryAddressBookList:(NSString *)myJID groupMembers:(NSMutableArray *)groupMembers{
   
    NSMutableArray *addressBookArray =[[NSMutableArray alloc]init];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
   
    db = [FMDatabase databaseWithPath:database_path] ;
    
    if([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select name,phoneNum,jid from AddressBook  where myJid = \"%@\"",myJID];
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            
            NSString *jid= [rs stringForColumn:@"jid"];
            
            NSString *name=[rs stringForColumn:@"name"];
            
            NSString *phoneNum=[rs stringForColumn:@"phoneNum"];
            
            NSString *isGroupMemebers = nil;
        
            //影响性能
//            for (NSDictionary* dic in groupMembers) {
//                NSLog(@"******%@",[dic objectForKey:@"jid"]);
//                if ([jid isEqualToString:[dic objectForKey:@"jid"]]) {
//                    isGroupMemebers = @"yes";
//                }
//            }
        
           [addressBookArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",name, @"name",phoneNum,@"phoneNum",isGroupMemebers,@"isGroupMemebers", nil]];
        }
    }
     [db close];
    return addressBookArray;
}


+(NSMutableArray *)queryAddressBook:(NSString *)myJID{
    
    NSMutableArray *addressBookArray =[[NSMutableArray alloc]init];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    
    db = [FMDatabase databaseWithPath:database_path] ;
    
    if([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select name,phoneNum,jid from AddressBook  where myJid = \"%@\"",myJID];
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            
            NSString *jid= [rs stringForColumn:@"jid"];
            
            NSString *name=[rs stringForColumn:@"name"];
            
            NSString *phoneNum=[rs stringForColumn:@"phoneNum"];
            
            
            [addressBookArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",name, @"name",phoneNum,@"phoneNum", nil]];
        }
    }
    [db close];
    return addressBookArray;
}


@end
