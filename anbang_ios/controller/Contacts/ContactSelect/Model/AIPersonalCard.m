//
//  AIPersonalCard.m
//  anbang_ios
//
//  Created by rooter on 15-5-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIPersonalCard.h"
#import "MJExtension.h"
#import "UserInfoCRUD.h"
#import "UserInfo.h"

@implementation AIPersonalCard

- (id)initWithJID:(NSString *)jid {
    self = [super init];
    if (self) {
        [self setupWithJID:(NSString *)jid];
    }
    return self;
}

- (void)setupWithJID:(NSString *)jid
{
    UserInfo *userInfo = [UserInfoCRUD queryUserInfo:jid myJID:MY_JID];
    self.name = userInfo.nickName;
    self.username = [self usernameWithJID:jid];
    self.avatar = userInfo.avatar ? userInfo.avatar : @"";
    self.accountName = userInfo.accountName ? userInfo.accountName : @"";
}

+ (AIPersonalCard *)cardWithJson:(NSString *)json {
    NSError *error = nil;
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *user = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    if (error) {
        JLLog_I(@"Invalid Data! %@", error);
    }
    return [AIPersonalCard objectWithKeyValues:user];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<class=%@, self=%p> %@", [self class], self, self.keyValues];
}

#pragma mark
#pragma mark private

- (NSString *)usernameWithJID:(NSString *)jid {
    return [jid componentsSeparatedByString:@"@"][0];
}

#pragma end

@end
