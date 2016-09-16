//
//  VoiceBody.h
//  anbang_ios
//
//  Created by silenceSky  on 14-4-7.
//  Copyright (c) 2014年 ch. All rights reserved.
//
#define VOICEMESSAGE_PATH @"path"
#define VOICEMESSAGE_TIME @"time"
#define VOICEMESSAGE_SRC @"src"
#define VOICEMESSAGE_LINK @"link"

#import <Foundation/Foundation.h>

@interface VoiceBody : NSObject
@property (nonatomic,retain) NSString*  path;//
@property (nonatomic,retain) NSNumber*  time;//消息时间
@property (nonatomic,retain) NSString*  src;//
@property (nonatomic,retain) NSString*  link;//源

@property (nonatomic,retain) NSMutableDictionary*  dictionary;

//将对象转换为字典
-(NSDictionary*)toDictionary;

@end
