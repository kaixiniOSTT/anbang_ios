//
//  DataPlist.h
//  Weather
//
//  Created by he on 13-7-10.
//  Copyright (c) 2013年 CoreLo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataPlist : NSObject

+ (NSString *)getPlistPath:(NSString *)name;

+ (void)writeToPlist:(NSMutableArray *)arr plistName:(NSString *)str;

+ (NSMutableArray *) readFromPlist:(NSString *) plistname;

+ (NSString *)getDocument;

//背景图片的设置
+(void)setBGimage:(UIView *)view pName:(NSString *)pstr dBGimage:(NSString *)bgname;

@end
