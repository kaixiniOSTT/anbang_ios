//
//  MyFMDatabaseQueue.m
//  anbang_ios
//
//  Created by silenceSky  on 14-6-7.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "MyFMDatabaseQueue.h"
static FMDatabaseQueue *my_FMDatabaseQueue=nil;


@implementation MyFMDatabaseQueue

+(FMDatabaseQueue *)getSharedInstance
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    
    if (!my_FMDatabaseQueue) {
        my_FMDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:database_path];
    }
    return my_FMDatabaseQueue;
}

+ (void)close
{
    [my_FMDatabaseQueue close];
}

+ (void)removeFMDatabaseQueue {
    [self close];
    my_FMDatabaseQueue = nil;
}

@end
