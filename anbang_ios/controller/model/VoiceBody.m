//
//  VoiceBody.m
//  anbang_ios
//
//  Created by silenceSky  on 14-4-7.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "VoiceBody.h"

@implementation VoiceBody
@synthesize path,time,src,link,dictionary;

-(id)init{
    self = [super init];
    if(self){
        dictionary = [[NSMutableDictionary alloc] init];
        self.time     = [NSNumber numberWithBool:NO];
    }
    return self;
}

-(void)dealloc{
}


//将对象转换为字典
-(NSMutableDictionary*)toDictionary
{
    [dictionary setValue:path forKey:VOICEMESSAGE_PATH];
    [dictionary setValue:time forKey:VOICEMESSAGE_TIME];
    [dictionary setValue:src forKey:VOICEMESSAGE_SRC];
    [dictionary setValue:link forKey:VOICEMESSAGE_LINK];

    return dictionary;
}


@end
