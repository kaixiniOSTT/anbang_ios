//
//  CustomMethod.h
//  gtg1.0
//
//  Created by zhoubin@moshi on 14-4-15.
//  Copyright (c) 2014年 lijx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"
#import "OHAttributedLabel.h"
#import "SCGIFImageView.h"

@interface ChatCustomMethod : NSObject

+(NSString *)escapedString:(NSString *)oldString;
+(void)drawImage:(OHAttributedLabel *)label;

+ (NSMutableArray *)addHttpArr:(NSString *)text;
+ (NSMutableArray *)addPhoneNumArr:(NSString *)text;
+ (NSMutableArray *)addEmailArr:(NSString *)text;
+ (NSString *)transformString:(NSString *)originalStr  emojiDic:(NSDictionary *)_emojiDic;
//silencesky upd
+ (NSString *)transformString2:(NSString *)originalStr  emojiDic:(NSDictionary *)_emojiDic;


@end
