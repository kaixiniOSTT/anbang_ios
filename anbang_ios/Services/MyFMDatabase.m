//
//  MyFMDatabase.m
//  anbang_ios
//
//  Created by silenceSky  on 14-6-9.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "MyFMDatabase.h"
static FMDatabase *my_FMDatabase=nil;
@implementation MyFMDatabase

+(FMDatabase *)getSharedInstance
{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    
    if (!my_FMDatabase) {
        
        my_FMDatabase = [FMDatabase databaseWithPath:database_path];
    }
    NSLog(@"+++++++++++++++++++++++++++++++++++++my_FMDatabase+:%@",my_FMDatabase);
    return my_FMDatabase;
}
@end
