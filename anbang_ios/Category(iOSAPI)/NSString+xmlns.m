//
//  NSString+xmlns.m
//  anbang_ios
//
//  Created by rooter on 15-3-24.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "NSString+xmlns.h"

@implementation NSString (xmlns)

+ (NSString *)xmlnsWithDefine:(NSString *)xmlns {
    
    return [NSString stringWithFormat:@"%@%@", kBaseNameSpace, xmlns];
}

@end
