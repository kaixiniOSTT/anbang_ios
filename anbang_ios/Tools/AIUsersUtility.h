//
//  AIUsersUtility.h
//  anbang_ios
//
//  Created by rooter on 15-6-25.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIUsersUtility : NSObject

+ (NSString *)nameForShowWithJID:(NSString *)aJID;
+ (NSString *)gnameForShowWithJID:(NSString *)aJID inGroup:(NSString *)groupJID;
+ (NSMutableDictionary*)gnameForShowWithJIDs:(NSArray *)aJIDs inGroup:(NSString *)groupJID;

@end
