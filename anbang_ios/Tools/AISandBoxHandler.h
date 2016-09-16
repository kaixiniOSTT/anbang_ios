//
//  AISandBoxHandler.h
//  anbang_ios
//
//  Created by rooter on 15-6-4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AISandBoxHandler : NSObject

+ (NSString *)createDirectoryInDocument:(NSString *)aDirctoryName;

+ (NSString *)createDirectoryAtPath:(NSString *)aTargetPath;

+ (BOOL)isExistsAtPath:(NSString *)aPath;

+ (NSString *)copyItemAtPath:(NSString *)aSourcePath
                          to:(NSString *)aTargetPath;

@end
