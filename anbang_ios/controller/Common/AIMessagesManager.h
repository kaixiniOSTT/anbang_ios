//
//  AIMessagesManager.h
//  anbang_ios
//
//  Created by rooter on 15-7-20.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XMPPMessage;

@interface AIMessagesManager : NSObject

+ (void) setMessage:(XMPPMessage *)message forKey:(NSString *)key;

+ (void) removeMessageForKey:(NSString *)key;

+ (XMPPMessage *) messageWithKey:(NSString *)key;

@end
