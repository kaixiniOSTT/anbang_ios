//
//  Utility.h
//  anbang_ios
//
//  Created by silenceSky  on 14-3-25.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+(NSString *)createMD5:(NSString *)signString;

+(NSString *)createPostURL:(NSMutableDictionary *)params;

+(NSString *)getCurrentDate;

+(BOOL)validateEmail:(NSString*)email;

+(BOOL)isValidateEmail:(NSString *)email;

+(BOOL)isValidateString:(NSString *)myString;

+(NSString *) decimalwithFormat:(NSString *)format  floatV:(float)floatV;

+(NSString *)getCurrentTime:(NSString *)formatStr;

//系统时间，指定时间格式,返回NSDate(UTC 与北京时间相差8小时)
+(NSDate *)getCurrentDate:(NSString *)formatStr;

//系统时间，指定时间格式,返回NSDate（本地时间）
+(NSDate *)getLocalDate:(NSString *)formatStr;

//将NSInteger类型的秒，转换为00:00:00格式
+(NSString *)secondFormatTime:(NSString *)second;

//UTC 时间
+ (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate;

//utc NSString 转 NSDate
+ (NSDate *)dateFromUtcString:(NSString *)dateString;

//NSDate 转 NSString 自定义格式
+ (NSString *)stringFromDate:(NSDate *)date formatStr:(NSString *)formatStr;

// NSString 转 NSDate 自定义格式
+ (NSDate *)dateFromString:(NSString *)dateString formatStr:(NSString *)formatStr;

//将本地日期字符串转为UTC日期字符串
//本地日期格式:2013-08-03 12:53:51
//可自行指定输入输出格式
+ (NSString *)getUTCFormateLocalDate:(NSString *)localDate;

//将UTC日期字符串转为本地时间字符串
//输入的UTC日期格式2013-08-03T04:53:51+0000
+ (NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate;

//星期
+(NSString*)week:(NSInteger)week;

+(NSString *)getCurrentTime;

// 根据日期，获取该日期所在周，月，年的开始日期，结束日期 的方法
+ (BOOL)getMonthBeginAndEndWith:(NSDate *)newDate;

//手机号码格式检测
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

//邮箱格式检测
+ (BOOL) isEmail: (NSString *) candidate;

//删除tableview 多余线条
+ (void)setExtraCellLineHidden: (UITableView *)tableView;

+ (NSString *)getCurrentIP;

//通用 alert
+(void)showAlert:(NSString *)title message:(NSString*)message btn:(NSString *)btnTitle btn2:(NSString *)btnTitle2;

//时间显示优化
+(NSString *)friendlyTime:(NSString *)datetime;

//时间显示新需求
+ (NSString *)friendlyTime_02:(NSString *)datatime;

+ (NSString *)friendlyTime_03:(NSString *)datetime;

+ (NSString *)UTCFormatToLocalFormat:(NSString *)strTime;

+ (NSString *)timespToUTCFormat:(NSString *)timesp;

+ (NSMutableAttributedString*) parseLinks:(NSString*) message;

+(int) getMessageTimeout:(NSString*)messageType;

@end
