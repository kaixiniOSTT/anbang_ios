//
//  AIMessagesManager.m
//  anbang_ios
//
//  Created by rooter on 15-7-20.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIMessagesManager.h"
#import "XMPPMessage.h"

static NSMutableDictionary *messages;

@implementation AIMessagesManager

+ (NSMutableDictionary *)messages {
    if (!messages) {
        messages = [@{} mutableCopy];
    }
    return messages;
}

+ (void)setMessage:(XMPPMessage *)aMessage forKey:(NSString *)key {
    XMPPMessage *message = [[self messages] objectForKey:key];
    if (message) {
        return;
    }
    [[self messages] setObject:aMessage forKey:key];
}

+ (void)removeMessageForKey:(NSString *)key {
    [[self messages] removeObjectForKey:key];
}

+ (XMPPMessage *)messageWithKey:(NSString *)key {
    return messages[key];
}

@end
