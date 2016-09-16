//
//  AIExtraInfo.m
//  anbang_ios
//
//  Created by rooter on 15-5-4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIExtraInfo.h"

@implementation AIExtraInfo

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@, %p> <name=%@, atvar=%@>", [self class], self, self.name, self.iconId];
}

@end
