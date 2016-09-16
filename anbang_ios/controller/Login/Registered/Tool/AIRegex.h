//
//  AIRegex.h
//  anbang_ios
//
//  Created by rooter on 15-3-21.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIRegex : NSObject

+ (BOOL)isEmailFormat:(NSString *)email;

+ (BOOL)isPhoneNumberFromat:(NSString *)phone;

+ (BOOL)isRegularFormat:(NSString *)text;

+ (BOOL)isBBIdFormat:(NSString *)bbIdString;

+ (BOOL)isPasswordFormat:(NSString *)password;

@end
