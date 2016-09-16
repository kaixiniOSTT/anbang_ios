//
//  MobileAddressBookCRUD.m
//  anbang_ios
//
//  Created by seeko on 14-5-26.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "MobileAddressBookCRUD.h"
#import "PublicCURD.h"

@implementation MobileAddressBookCRUD
sqlite3 *database;
+(void)creatMobileAddressBookTable{
    char *errorMsg;
    const char *createSql="create table if not exists MobileAddressBook (name varchar(20),phoneNum varchar(20),primary key(name,phoneNum))";
    
    //    const char *createSql="create table if not exists IDtable (id integer primary key autoincrement, ID varchar(20))";
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
//        NSLog(@"AddressBook create ok.");
    }
    else
    {
//        NSLog( @"can not create AddressBook" );
    }

}
+(void)insertMobileAddressBookkName:(NSString *)name phoneNum:(NSString *)PhoneNum{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *insertSqlStr=[NSString stringWithFormat:@"insert or replace into AddressBook (myJid,phoneNum) values (\"%@\",\"%@\")",name,PhoneNum];
    
    const char *insertSql = [insertSqlStr UTF8String];
    
    if (sqlite3_exec(database, insertSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
//        NSLog(@"insert success");
    }
    else
    {
//        NSLog( @"can not insert it to table" );
    }
    [PublicCURD closeDataBaseSQLite];
}


+(BOOL)detectiontMobileAddressBookkName:(NSString *)name phoneNum:(NSString *)PhoneNum{
    [PublicCURD openDataBaseSQLite];
    
    char *errorMsg;
    NSString *insertSqlStr=[NSString stringWithFormat:@"insert or replace into AddressBook (myJid,phoneNum) values (\"%@\",\"%@\")",name,PhoneNum];
    
    BOOL isSuccess=NO;
    const char *insertSql = [insertSqlStr UTF8String];
    
    if (sqlite3_exec(database, insertSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        isSuccess=YES;
    }
    else
    {
        return NO;
    }
    
    [PublicCURD closeDataBaseSQLite];
    return isSuccess;
}
@end
