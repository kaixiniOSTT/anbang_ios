//
//  GroupMembers.h
//  anbang_ios
//
//  Created by silenceSky  on 14-3-28.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupMembers : NSObject
@property (retain,nonatomic)  NSString *jid;
@property (retain, nonatomic) NSString *nickName;
@property (retain, nonatomic) NSString *role;
@property (retain, nonatomic) NSString *groupJID;
@property (retain, nonatomic) NSString *gotoFlag;
@property (retain, nonatomic) NSString *removeStr;
@end
