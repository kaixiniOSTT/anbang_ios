//
//  NSString+Chinese.m
//  anbang_ios
//
//  Created by rooter on 15-5-23.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "NSString+Chinese.h"

@implementation NSString (Chinese)

- (NSString *)transformToPinyin {
    NSMutableString *ms = [NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)ms, NULL, kCFStringTransformToLatin, false);
    NSString *rs = [ms stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    return [rs stringByReplacingOccurrencesOfString:@" " withString:@""];
}


- (NSString *)getPrenameAbbreviation {
    NSMutableString *ms = [NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)ms, NULL, kCFStringTransformToLatin, false);
    NSString *rs = [ms stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    NSArray *tmp = [rs componentsSeparatedByString:@" "];
    NSMutableString *result = [NSMutableString string];
    if (tmp.count <= 1) {
        return [tmp lastObject];
    }
    for (int i = 0; i < tmp.count; ++i) {
        [result appendFormat:@"%@", [tmp[i] substringToIndex:1]];
    }
    return result;
}

@end
