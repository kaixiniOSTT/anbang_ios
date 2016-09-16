//
//  AIContactTool.m
//  anbang_ios
//
//  Created by rooter on 15-4-29.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIContactTool.h"

@implementation AIContactTool

+ (NSString *)groupName:(NSDictionary *)contact
{
    NSString *groupName = contact[@"groupName"];
    NSArray *members = contact[@"groupMembersArray"];
    if ([StrUtility isBlankString:groupName])
    {
        NSMutableString *tmp = [NSMutableString string];
        
        for (int i = 0; i < members.count; ++i)
        {
            NSDictionary *member = members[i];
            [tmp appendString:member[@"nickName"]];
            if (i <= member.count - 1) {
                [tmp appendString:@","];
            }
        }
        groupName = tmp;
    }
    
    return groupName;
}

@end
