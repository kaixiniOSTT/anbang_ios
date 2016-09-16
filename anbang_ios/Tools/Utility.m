//
//  Utility.m
//  anbang_ios
//
//  Created by silenceSky  on 14-3-25.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "Utility.h"
#import <CommonCrypto/CommonDigest.h>
#import "CSNotificationView.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "Reachability.h"

@implementation Utility

//md5加密
+(NSString *)createMD5:(NSString *)signString
{
    const char*cStr =[signString UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    return[NSString stringWithFormat:
           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
           result[0], result[1], result[2], result[3],
           result[4], result[5], result[6], result[7],
           result[8], result[9], result[10], result[11],
           result[12], result[13], result[14], result[15]
           ];
}

//UTC 时间
+ (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}


//utc NSString 转 NSDate
+ (NSDate *)dateFromUtcString:(NSString *)dateString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
    
}


//NSDate 转 NSString 自定义格式
+ (NSString *)stringFromDate:(NSDate *)date formatStr:(NSString *)formatStr{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    [dateFormatter setDateFormat:formatStr];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}


// NSString 转 NSDate 自定义格式
+ (NSDate *)dateFromString:(NSString *)dateString formatStr:(NSString *)formatStr{
    
    NSLog(@"*****%@",dateString);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: formatStr];
    
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
    
}





//将本地日期字符串转为UTC日期字符串
//本地日期格式:2013-08-03 12:53:51
//可自行指定输入输出格式
+ (NSString *)getUTCFormateLocalDate:(NSString *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:localDate];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}


//将UTC日期字符串转为本地时间字符串
//输入的UTC日期格式2013-08-03T04:53:51+0000
+ (NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //NSLog(@"*****%@",utcDate);
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    //NSLog(@"*****%@",dateString);
    
    return dateString;
}


+(NSString *)getCurrentTime{
    
    NSDate *nowUTC = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    return [dateFormatter stringFromDate:nowUTC];
    
}


// 根据日期，获取该日期所在周，月，年的开始日期，结束日期 的方法

+ (BOOL)getMonthBeginAndEndWith:(NSDate *)newDate{
    if (newDate == nil) {
        newDate = [NSDate date];
    }
    
    NSDate* todayDate = [NSDate date];
    
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginDate interval:&interval forDate:newDate];
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit NSMonthCalendarUnit
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return NO;
    }
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"yyyy.MM.dd"];
    // NSString *beginString = [myDateFormatter stringFromDate:beginDate];
    // NSString *endString = [myDateFormatter stringFromDate:endDate];
    
    NSTimeInterval timeInterval = [todayDate timeIntervalSinceDate:endDate];
    
    if (timeInterval>0) {
        return NO;
    }else{
        return YES;
    }
    
}


+(NSString *)createPostURL:(NSMutableDictionary *)params
{
    NSString *postString=@"";
    for(NSString *key in [params allKeys])
    {
        NSString *value=[params objectForKey:key];
        postString=[postString stringByAppendingFormat:@"%@=%@&",key,value];
    }
    if([postString length]>1)
    {
        postString=[postString substringToIndex:[postString length]-1];
    }
    return postString;
}



+(NSString *)getCurrentDate
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}



//系统时间，指定时间格式，返回NSString
+(NSString *)getCurrentTime:(NSString *)formatStr{
    NSDate *  sendDate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:formatStr];
    NSString *  sendTimeStr=[dateformatter stringFromDate:sendDate];
    return sendTimeStr;
    
}


//系统时间，指定时间格式,返回NSDate(UTC 与北京时间相差8小时)
+(NSDate *)getCurrentDate:(NSString *)formatStr{
    NSDate *  sendDate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:formatStr];
    NSString *  sendTimeStr=[dateformatter stringFromDate:sendDate];
    [dateformatter setDateFormat: formatStr];
    sendDate= [dateformatter dateFromString:sendTimeStr];
    //NSLog(@"*****%@",sendDate);
    return sendDate;
}

//系统时间，指定时间格式,返回NSDate（本地时间）
+(NSDate *)getLocalDate:(NSString *)formatStr{
    NSDate *date =[NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate * localDate = [date dateByAddingTimeInterval:interval];
    return localDate;
}

//将NSInteger类型的秒，转换为00:00:00格式
+(NSString *)secondFormatTime:(NSString *)second{
    
    NSString*time = second;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"mm:ss"];
    NSDate*confromTimesp = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[time intValue]];
    NSString*confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}


//星期
+ (NSString*)week:(NSInteger)week
{
    NSString*weekStr=nil;
    if(week==1)
    {
        weekStr=NSLocalizedString(@"chat.sunday",@"title");
    }else if(week==2){
        weekStr=NSLocalizedString(@"chat.monday",@"title");
    }else if(week==3){
        weekStr=NSLocalizedString(@"chat.tuesday",@"title");
    }else if(week==4){
        weekStr=NSLocalizedString(@"chat.wednesday",@"title");
    }else if(week==5){
        weekStr=NSLocalizedString(@"chat.thursday",@"title");
    }else if(week==6){
        weekStr=NSLocalizedString(@"chat.friday",@"title");
    }else if(week==7){
        weekStr=NSLocalizedString(@"chat.saturday",@"title");
    }
    return weekStr;
}


//通过区分字符串

+(BOOL)validateEmail:(NSString*)email
{
    if((0 != [email rangeOfString:@"@"].length) &&
       (0 != [email rangeOfString:@"."].length))
    {
        NSCharacterSet* tmpInvalidCharSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSMutableCharacterSet* tmpInvalidMutableCharSet = [tmpInvalidCharSet mutableCopy];
        [tmpInvalidMutableCharSet removeCharactersInString:@"_-"];
        
        
        NSRange range1 = [email rangeOfString:@"@"
                                      options:NSCaseInsensitiveSearch];
        
        //取得用户名部分
        NSString* userNameString = [email substringToIndex:range1.location];
        NSArray* userNameArray   = [userNameString componentsSeparatedByString:@"."];
        
        for(NSString* string in userNameArray)
        {
            NSRange rangeOfInavlidChars = [string rangeOfCharacterFromSet: tmpInvalidMutableCharSet];
            if(rangeOfInavlidChars.length != 0 || [string isEqualToString:@""])
                return NO;
        }
        
        //取得域名部分
        NSString *domainString = [email substringFromIndex:range1.location+1];
        NSArray *domainArray   = [domainString componentsSeparatedByString:@"."];
        
        for(NSString *string in domainArray)
        {
            NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet:tmpInvalidMutableCharSet];
            if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])
                return NO;
        }
        
        return YES;
    }
    else {
        return NO;
    }
}

//利用正则表达式验证
+(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+(BOOL)isValidateString:(NSString *)myString
{
    NSCharacterSet *nameCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
    NSRange userNameRange = [myString rangeOfCharacterFromSet:nameCharacters];
    if (userNameRange.location != NSNotFound) {
        //NSLog(@"包含特殊字符");
        return FALSE;
    }else{
        return TRUE;
    }
    
}



//格式话小数 四舍五入类型
+ (NSString *) decimalwithFormat:(NSString *)format  floatV:(float)floatV
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    [numberFormatter setPositiveFormat:format];
    
    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
}


//手机号码格式检测
+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//邮箱格式检测
+ (BOOL) isEmail: (NSString *) candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

//提示框
+ (void)publicAlert:(UIViewController *)vc {
    //[UIColor colorWithRed:0.000 green:0.6 blue:1 alpha:1]
    //录音时间太短!
    [CSNotificationView showInViewController:vc
                                   tintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:0.2]
                                       image:nil
                                     message:NSLocalizedString(@"chatviewPublic.recordingShort",@"message")
                                    duration:2.0f];
}




//删除tableview 多余线条
+ (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}




+ (NSString *)getCurrentIP
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}


//通用 alert
+(void)showAlert:(NSString *)title message:(NSString*)message btn:(NSString *)btnTitle btn2:(NSString *)btnTitle2{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:btnTitle,btnTitle2, nil];
    [alertView show];
  
}

#pragma mark
#pragma mark 日期显示新需求

+ (NSString *)timespToUTCFormat:(NSString *)timesp
{
    NSString * timeStampString = timesp;
    NSTimeInterval _interval=[[timeStampString substringToIndex:10] doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSString *dateString = [dateFormatter stringFromDate:date];

    return dateString;
}

+ (NSString *)UTCFormatToLocalFormat:(NSString *)strTime
{
    NSDate *date = [self dateFromUtcString:strTime];
    NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *sendTimeStr = [formatter stringFromDate:date];
    return sendTimeStr;
}

/**
 * 对话界面中时间显示
 */

+(NSString *)friendlyTime:(NSString *)dataTime{
    
//    JLLog_I(@"<time=%@>", dataTime);
    
    /**  原有代码
        NSString *today = [Utility getCurrentTime:@"yyyy-MM-dd"];
        //参数字符串转化成时间格式
        NSString *date = [dataTime substringToIndex:10];
        int hour = [[dataTime substringWithRange:NSMakeRange(11, 2)] intValue];
        
        //上述时间差输出不同信息
        NSString *prefix = @"";
        if ([today isEqualToString:date]){
            if(hour < 6){
                prefix = @"凌晨";
            } else if(hour < 12){
                prefix = @"早上";
            } else if(hour < 13){
                prefix = @"中午";
            } else if(hour < 18) {
                prefix = @"下午";
            } else if(hour < 24) {
                prefix = @"晚上";
            }
            return [NSString stringWithFormat:@"%@%@", prefix, [dataTime substringWithRange:NSMakeRange(11, 5)]];
        }
        
        return [dataTime substringWithRange:NSMakeRange(5, 11)];
     */
    
    NSString *time = [[self time:dataTime] substringToIndex:5];
    
    if ([self isToday:[self date:dataTime]]) {
        return time;
    }else if ([self isYestoday:dataTime]) {
        return [NSString stringWithFormat:@"昨天 %@", time];
    }else if ([self detalFromNow:dataTime] >= 2 && [self detalFromNow:dataTime] <= 7) {
        NSString *weekday = [self weekday:[self date:dataTime]];
        return [NSString stringWithFormat:@"%@ %@", weekday, time];
    }else {
        NSString *date = [self date:dataTime];
        return [NSString stringWithFormat:@"%@ %@", [date substringFromIndex:2], time];
    }
}

/**
 * 列表中时间显示
 */

+ (NSString *)friendlyTime_02:(NSString *)datatime
{
//    JLLog_I(@"<time=%@>", datatime);
    
    if ([self isToday:[self date:datatime]]) {
        return [[self time:datatime] substringToIndex:5];
    }else if ([self isYestoday:datatime]) {
        return @"昨天";
    }else if ([self detalFromNow:datatime] >= 2 && [self detalFromNow:datatime] <= 7) {
        return [self weekday:[self date:datatime]];
    }else {
        return [[self date:datatime] substringFromIndex:2];
    }
}

+ (NSString *)friendlyTime_03:(NSString *)dataTime
{
    if ([self isToday:[self date:dataTime]]) {
        return @"今天";
    }else if ([self isYestoday:dataTime]) {
        return @"昨天";
    }else if ([self detalFromNow:dataTime] >= 2 && [self detalFromNow:dataTime] <= 7) {
        NSString *weekday = [self weekday:[self date:dataTime]];
        return weekday;
    }else {
        NSString *date = [self date:dataTime];
        return date;
    }
}

+ (NSString *)time:(NSString *)str
{
    return [str componentsSeparatedByString:@" "][1];
}

+ (NSString *)date:(NSString *)str
{
    return [str componentsSeparatedByString:@" "][0];
}

+ (NSDate *)dateFromStrDate:(NSString *)strDate
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    return [fmt dateFromString:strDate];
}

+ (BOOL)isToday:(NSString *)datetime
{
    NSString *today = [Utility getCurrentTime:@"yyyy-MM-dd"];
    return [today isEqualToString:datetime] ? YES : NO;
}

+ (BOOL)isYestoday:(NSString *)datetime
{
    return [self detalFromNow:datetime] == 1;
}

+ (NSDate *)dateWithYMD:(NSDate *)datetime
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *selfStr = [fmt stringFromDate:datetime];
    return [fmt dateFromString:selfStr];
}

+ (NSInteger)detalFromNow:(NSString *)datetime
{
    // 2014-05-01
    NSDate *nowDate = [self dateWithYMD:[NSDate date]];
    
    // 2014-04-30
    NSDate *date = [self dateFromStrDate:datetime];
    NSDate *selfDate = [self dateWithYMD:date];
    
    // 获得nowDate和selfDate的差距
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay fromDate:selfDate toDate:nowDate options:0];
    return cmps.day;
}

+ (NSString *)weekday:(NSString *)datetime
{
    NSArray *components = [datetime componentsSeparatedByString:@"-"];
    NSDateComponents *_comps = [[NSDateComponents alloc] init];
    
    [_comps setDay:[components[2] intValue]];
    [_comps setMonth:[components[1] intValue]];
    [_comps setYear:[components[0] intValue]];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:_comps];
    NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
    NSInteger weekday = [weekdayComponents weekday];
    return [self week:weekday];
}

+ (NSMutableAttributedString*) parseLinks:(NSString*) message
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                  
                                  @"<a\\s+href=(['\"])([^<>]+)\\1>([^<>]+)</a>" options:0 error:nil];
    
    NSString *content  = [regex stringByReplacingMatchesInString:message options:0 range:NSMakeRange(0, message.length) withTemplate:@"$3"];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:content];
    [attrString beginEditing];
    
    NSArray *array = [regex matchesInString:message options:0 range:NSMakeRange(0, message.length)];
    
    for (NSTextCheckingResult* b in array)
    {
        NSString *link = [message substringWithRange:[b rangeAtIndex:2]];
        NSString *text = [message substringWithRange:[b rangeAtIndex:3]];
        NSRange range = [content rangeOfString:text options:NSCaseInsensitiveSearch];
        content = [content substringFromIndex:(range.location + range.length)];

        [attrString addAttributes:@{
                                    NSLinkAttributeName:link,
                                    NSForegroundColorAttributeName:AB_Color_68af2f
                                    
                                    }
                            range:range];
    }
    
    return attrString;
}

+(int) getMessageTimeout:(NSString*)messageType
{
    NSDictionary *timeoutDict = nil;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            timeoutDict = @{@"chat":@3, @"voice":@3, @"location":@3, @"phone":@3, @"image":@3, @"clip":@3, @"video": @3, @"document": @3};
            break;
        case ReachableViaWiFi:
            timeoutDict = @{@"chat":@10, @"voice":@20, @"location":@10, @"phone":@25, @"image":@60, @"clip":@60, @"video": @45, @"document": @90};
            break;
        case ReachableViaWWAN:
            timeoutDict = @{@"chat":@15, @"voice":@30, @"location":@15, @"phone":@30, @"image":@90, @"clip":@90, @"video": @90, @"document": @120};
            //@"3G");
            break;
    }

    if(![[timeoutDict allKeys] containsObject:messageType]) return 60;
    
    return [timeoutDict[messageType] intValue];
}

#pragma end

@end
