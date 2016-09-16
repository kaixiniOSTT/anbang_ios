//
//  ChatRoom.m
//  anbang_ios
//
//  Created by silenceSky  on 14-3-27.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "ChatGroup.h"

@implementation ChatGroup
@synthesize jid,name,creator,groupMucId,myJID,version,inviteUrl,createDate,modificationDate,removeStr,groupType;


- (id)init
{
    if (self) {
        self = [super init];
        self.name = @"";
    }
    return self;
}

- (void)dealloc
{

}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"groupName"]) {
        self.name = value;
    }
    
    if ([key isEqualToString:@"groupJID"]) {
        self.jid = value;
    }
}

@end
