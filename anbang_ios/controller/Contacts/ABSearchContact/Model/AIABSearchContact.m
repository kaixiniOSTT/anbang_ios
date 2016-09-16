//
//  AIABSearchContact.m
//  anbang_ios
//
//  Created by rooter on 15-5-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIABSearchContact.h"

@implementation AIABSearchContact

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString string];
    
    [desc appendFormat:@"branch=%@,", self.branch];
    [desc appendFormat:@"employeeName=%@", self.employeeName];
    [desc appendFormat:@"userName=%@", self.userName];
    [desc appendFormat:@"avatar=%@", self.avartar];
    
    return [NSString stringWithFormat:@"<%@, %p> {%@}", [self class], self, desc];
}

@end
