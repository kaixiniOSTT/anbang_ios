//
//  MyServices.h
//  anbang_ios
//
//  Created by silenceSky  on 14-11-6.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyServices : NSObject
//检测版本
+(void)onCheckVersion;

//检查电话号码
+(BOOL)checkUSPhoneNumber:(NSString*)phoneNumber;

//扫瞄二维码结果
+(void)receiveScanResult:(NSNotification *) notify target:(UIViewController *)vc;

//打电话
+(void)playDial:(NSString *)callJID name:(NSString *)name avatar:(NSString *)avatar target:(UIViewController *)target;
@end
