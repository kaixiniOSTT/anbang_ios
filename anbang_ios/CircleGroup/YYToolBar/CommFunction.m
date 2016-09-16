
//
//  Created by baiteng06 on 14-10-20.
//  Copyright (c) 2014年 baiteng06. All rights reserved.
//

#import "CommFunction.h"

@implementation CommFunction

+ (int)CompareDateForDay:(NSString *)datetime
{
    int result = 0;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [dateFormatter stringFromDate:[NSDate date]];//当天系统时间
    //首先比较是否当天
    NSString *date = [datetime substringToIndex:10];
    NSComparisonResult cresult = [today compare:date];
    if (cresult != NSOrderedSame) {
        NSDate *dtoday = [dateFormatter dateFromString:today];
        NSDate *ddate = [dateFormatter dateFromString:date];
//        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//        
//        NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
//        
//        NSDateComponents *components = [gregorian components:unitFlags fromDate:ddate toDate:dtoday options:0];
//        
//        //NSInteger months = [components month];
//        result = [components day];
        
        NSTimeInterval timeInterval = [dtoday timeIntervalSinceDate:ddate];
        result = (ceil(((double)timeInterval) / (3600*24)));
    }
    return result;
}

+ (NSString *)GetDayString:(NSString *)datetime
{
    int days = [CommFunction CompareDateForDay:datetime];
    if (days >-1 && days < 3) {
        NSString *sday;
        switch (days) {
            case 0:
                sday = @"今天";
                break;
            case 1:
                sday = @"昨天";
                break;
            case 2:
                sday = @"前天";
                break;
            default:
                sday = @"今天";
                break;
        }
        NSRange range = NSMakeRange(9, 5);
        //return [NSString stringWithFormat:@"%@ %@", sday, [datetime substringFromIndex:11]];
        return [NSString stringWithFormat:@"%@ %@", sday, [datetime substringWithRange:range]];
    }
    else
    {
        NSRange range = NSMakeRange(3, 11);
        //return [datetime substringFromIndex:5];
        return [datetime substringWithRange:range];
    }

}

+ (NSString *)GetSetTime
{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    //读取字典类型NSDictionary类型的数据
    NSDictionary *myDictionary = [userDefaultes dictionaryForKey:@"loginfo"];
    return [myDictionary valueForKey:@"newTime"];
}

+ (void)SetdynTime
{
    //将上述数据全部存储到NSUserDefaults中
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *myDictionary = [[userDefaults dictionaryForKey:@"loginfo"] mutableCopy];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [myDictionary setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"newTime"];
        
    //存储时，除NSNumber类型使用对应的类型意外，其他的都是使用setObject:forKey:
    [userDefaults setObject:myDictionary forKey:@"loginfo"];
    
    //这里建议同步存储到磁盘中，但是不是必须的
    [userDefaults synchronize];
}

+ (NSString *)GetTempName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    return [dateFormatter stringFromDate:[NSDate date]];//当天系统时间
}

+ (NSString *)GetCurrTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:[NSDate date]];//当天系统时间
}

+ (NSString *)base64Encoding:(NSData *)datainfo
{
    if ([datainfo length] == 0)
        return @"";
    
    char *characters = malloc((([datainfo length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    
    NSUInteger length = 0;
    NSUInteger i = 0;
    
    while (i < [datainfo length]) {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [datainfo length])
            buffer[bufferLength++] = ((char *)[datainfo bytes])[i++];
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] ;
}

@end
