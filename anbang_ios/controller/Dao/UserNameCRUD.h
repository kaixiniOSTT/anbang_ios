//
//  UserNameCRUD.h
//  anbang_ios
//
//  Created by seeko on 14-5-10.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserNameCRUD : NSObject
+(void)createChatBuddyTable;
+(void)insertIDtable:(NSString *)userName avatar:(NSString*)avatar myJID:(NSString *)myJID;
+(NSMutableArray *)selectIDtable;
+(void)deleteUserName:(NSString *)userName;

@end
