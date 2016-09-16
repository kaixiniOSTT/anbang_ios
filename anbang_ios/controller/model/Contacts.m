//
//  contacts.m
//  anbang_ios
//
//  Created by silenceSky  on 14-4-26.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "Contacts.h"
#import "MJExtension.h"

@implementation Contacts
@synthesize jid,remarkName,nickName,phone,avatar,string,pinYin,accountType;

- (void)dealloc
{
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<class=%@, object=%p> {%@}", [self class], self, self.keyValues];
}

@end
