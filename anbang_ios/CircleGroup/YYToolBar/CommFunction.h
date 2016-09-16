
//
//  Created by baiteng06 on 14-10-20.
//  Copyright (c) 2014年 baiteng06. All rights reserved.
//

#import <Foundation/Foundation.h>

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@interface CommFunction : NSObject

+ (int)CompareDateForDay:(NSString *)datetime;

+ (NSString *)GetDayString:(NSString *)datetime;

+ (NSString *)GetSetTime;

+ (void)SetdynTime;

+ (NSString *)GetTempName;

+ (NSString *)GetCurrTime;

+ (NSString *)base64Encoding:(NSData *)datainfo;

@end
