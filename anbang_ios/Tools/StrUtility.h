//
//  StrUtility.h
//  anbang_ios
//
//  Created by silenceSky  on 14-12-31.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StrUtility : NSObject
//判断字符串为空和只为空格解决办法
+ (BOOL)isBlankString:(NSString *)string;

//如果字符串为空返回默认字符串
+ (NSString*)string:(NSString *)string defaultValue:(NSString*)defaultValue;

//如果字符串为空返回空字符串
+ (NSString*)string:(NSString *)string;

//截取 jid @ 前面部份
+ (NSString *)subJIDStr:(NSString *)str;

//图文混排
+ (void)getImageRange:(NSString*)message : (NSMutableArray*)array ;

+ (NSString*)data2JsonString:(id)object;
@end
