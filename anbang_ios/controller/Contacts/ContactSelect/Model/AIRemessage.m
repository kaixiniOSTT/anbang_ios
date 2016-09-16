//
//  AIRemessage.m
//  anbang_ios
//
//  Created by rooter on 15-5-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIRemessage.h"

@implementation AIRemessage

- (id)initWithDictionary:(NSDictionary *)message {
    self = [super init];
    if (self) {
        [self setupWithDictionary:message];
    }
    return self;
}

- (void)setupWithDictionary:(NSDictionary *)message {
    _text = message[@"text"];
//    _speaker = message[@"speaker"];
    NSString *type = message[@"subject"];
    if([type isEqualToString:@"chat"]) {
        _messageType = AIRemessageTypeChat;
    }else if ([type isEqualToString:@"image"]) {
        _messageType = AIRemessageTypeImage;
    }else if ([type isEqualToString:@"card"]) {
        _messageType = AIRemessageTypeCard;
    }else if ([type isEqualToString:@"document"]) {
        _messageType = AIRemessageTypeDocument;
    }else if ([type isEqualToString:@"location"]) {
        _messageType = AIRemessageTypeLocation;
    }else if ([type isEqualToString:@"article"]) {
        _messageType = AIRemessageTypeArticle;
    }
}


@end
