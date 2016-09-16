//
//  StrUtility.m
//  anbang_ios
//
//  Created by silenceSky  on 14-12-31.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "StrUtility.h"

@implementation StrUtility

//判断字符串为空和只为空格解决办法

+ (BOOL)isBlankString:(NSString *)string{
    if (string == nil) {
        
        return YES;
        
    }
    
    if (string == NULL) {
        
        return YES;
        
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        
        return YES;
        
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        
        return YES;
        
    }
    
    if ([string isEqualToString:@"(null)"]) {
        
        return YES;
        
    }
    
    return NO;
    
}

+ (NSString*)string:(NSString *)string defaultValue:(NSString*)defaultValue
{
    return [self isBlankString:string]?defaultValue:string;
}

+ (NSString*)string:(NSString *)string
{
    return [self string:string defaultValue:@""];
}

//截取 jid @ 前面部份
+ (NSString *)subJIDStr:(NSString *)str{
    
    if (str==nil || [str isEqualToString:@""]) {
        return @"";
    }
    NSString*str_character = @"@";
    NSString*subStr = @"";
    NSRange senderRange = [str rangeOfString:str_character];
    
    if ([str rangeOfString:str_character].location != NSNotFound) {
        subStr = [str substringToIndex:senderRange.location];
    }
    return subStr;
}



//图文混排
+(void)getImageRange:(NSString*)message : (NSMutableArray*)array {
    NSRange range=[message rangeOfString: CHAT_BEGIN_FLAG];
    NSRange range1=[message rangeOfString: CHAT_END_FLAG];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0) {
        if (range.location > 0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else {
                return;
            }
        }
        
    } else if (message != nil) {
        [array addObject:message];
    }
}

+ (NSString*)data2JsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:(NSJSONWritingOptions)nil
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


@end
