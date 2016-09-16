//
//  AIMessageSendAssisstant.h
//  anbang_ios
//
//  Created by rooter on 15-5-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIMessageSendAssisstantDelegate.h"

@class AIRemessage;

typedef NS_ENUM(NSInteger, AIChatType) {
    AIChatTypeChat,
    AIChatTypeGroup,
};

@interface AIMessageSendAssisstant : NSObject

@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, assign) id<AIMessageSendAssisstantDelegate> delegate;

- (id)initWithFromUserName:(NSString *)aUserName;
- (void)sendMessagesTo:(NSDictionary *)contact;

@end
