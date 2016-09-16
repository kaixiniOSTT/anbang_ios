//
//  AIFriendPrivilegeCRUD.h
//  anbang_ios
//
//  Created by rooter on 15-8-3.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>


#define  kPrivilegeColumnMyCircleLock @"my_circle_lock"
#define  kPrivilegeColoumnHisCircleMark @"his_circle_mark"

@interface AIFriendPrivilegeCRUD : NSObject

+ (void)setValue:(NSString *)value withColumnKey:(NSString *)columnKey whose:(NSString *)jid;
+ (NSString *)valueWithColumnKey:(NSString *)columnKey whose:(NSString *)jid;

@end
