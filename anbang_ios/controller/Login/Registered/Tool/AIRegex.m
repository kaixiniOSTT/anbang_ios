//
//  AIRegex.m
//  anbang_ios
//
//  Created by rooter on 15-3-21.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIRegex.h"
#import "AIControllersTool.h"

@implementation AIRegex

+ (BOOL)isEmailFormat:(NSString *)email
{
    NSString *emailRegex = @"^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isPhoneNumberFromat:(NSString *)phone
{
    NSString *phoneRegex = @"1[0-9]{10}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phone];
}

+ (BOOL)isRegularFormat:(NSString *)text
{
    if (![self isEmailFormat:text]) {
        if (![self isPhoneNumberFromat:text]) {
            return NO;
        }
    }
    
    return YES;
}

+ (BOOL)isBBIdFormat:(NSString *)bbIdString
{
    NSString *format = @"^(?!([Aa][Bb]\\d{6}$)|(1\\d{10}$)|(_.*$)|(.*_$))[A-Za-z0-9_]{4,16}$";
    NSPredicate *bbIdTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", format];
    
    return [bbIdTest evaluateWithObject:bbIdString];
}

+ (BOOL)isPasswordFormat:(NSString *)password
{
    NSString *format_01 = @"^[0-9]*$";
    NSString *format_02 = @"^[A-Za-z]*$";
    NSString *format_03 = @"^[0-9A-Za-z_]{6,16}$";
    
    NSPredicate *passwordTest_01 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", format_01];
    NSPredicate *passwordTest_02 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", format_02];
    NSPredicate *passwordTest_03 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", format_03];
    
    BOOL isPassword = NO;
    do {
        if ([passwordTest_01 evaluateWithObject:password])
        {
            [AIControllersTool tipViewShow:@"密码不能全是数字"];
            break;
        }
        if ([passwordTest_02 evaluateWithObject:password])
        {
            [AIControllersTool tipViewShow:@"密码不能全是字母"];
            break;
        }
        
        if ([passwordTest_03 evaluateWithObject:password]) {
            isPassword = YES;
            break;
        }else {
            [AIControllersTool tipViewShow:@"密码长度6-16位，由字母、数字、下划线组成"];
            break;
        }
        
    } while (0);
    
    return isPassword;
}

@end
