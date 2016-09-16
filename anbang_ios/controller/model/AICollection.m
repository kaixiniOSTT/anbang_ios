//
//  AICollection.m
//  anbang_ios
//
//  Created by rooter on 15-4-30.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AICollection.h"

@implementation AICollection

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString string];
    
    [desc appendFormat:@"\n\nsernder:%@\n", self.sender];
    [desc appendFormat:@"owner:%@\n", self.owner];
    [desc appendFormat:@"message:%@\n", self.message];
    [desc appendFormat:@"message_type:%d\n", self.messageType];
    [desc appendFormat:@"sourceType:%d\n", self.sourceType];
    
    return [NSString stringWithFormat:@"<class=%@, userinfo=%p> {%@}", [self class], self, desc];
}

@end
