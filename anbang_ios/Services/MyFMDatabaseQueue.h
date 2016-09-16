//
//  MyFMDatabaseQueue.h
//  anbang_ios
//
//  Created by silenceSky  on 14-6-7.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"

@interface MyFMDatabaseQueue : NSObject

+(FMDatabaseQueue *)getSharedInstance;
+(void)removeFMDatabaseQueue;
+ (void)close;
@end
