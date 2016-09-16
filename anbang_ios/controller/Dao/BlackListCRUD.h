//
//  BlackListCRUD.h
//  anbang_ios
//
//  Created by silenceSky  on 14-5-10.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface BlackListCRUD : NSObject
+ (void)createBlacklistTable;
//删除黑名单解绑
+ (void)deleteBlackList:(NSString *)contactsUserName myUserName:(NSString *)myUserName;
+ (void)insertBlackListTable:(NSString *)contactsUserName myUserName:(NSString *)myUserName;
//查询是否存在黑名单
+ (int)queryBlacklistTableCountId:(NSString *)contactsUserName myUserName:(NSString *)myUserName;
//查询我的黑名单
+(NSMutableArray *)queryMyBlackListByMyUserName:(NSString *)myUserName;
@end
