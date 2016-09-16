//
//  SystemMessageCRUD.h
//  anbang_ios
//
//  Created by seeko on 14-6-9.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface SystemMessageCRUD : NSObject
+(void)creatSystemMessageTable;

+(void)insertSytemMessageSendName:(NSString *)sendName myUserName:(NSString *)myUserName readMark:(NSString *)readMark msg:(NSString *)msg msgType:(NSString *)msgType time:(NSString *)time;

+(NSMutableArray *)selectSytemMessage:(NSString *)sendName myUserName:(NSString *)myUserName start:(int)start total:(int)total;

+(void)updataSytemMessageSendName:(NSString *)sendName myUserName:(NSString *)myUserName readMark:(NSString *)readMark;

+ (int)queryCountUnread:(NSString *)sendName myUserName:(NSString *)myUserName;

+(void)deleteAllSytemMessage;
@end
