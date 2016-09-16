//
//  AISandBoxHandler.m
//  anbang_ios
//
//  Created by rooter on 15-6-4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AISandBoxHandler.h"

@implementation AISandBoxHandler

+ (NSString *)documentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
}

// If file or directory is exists,
// then go ahead and return target path

+ (NSString *)createDirectoryInDocument:(NSString *)aDirctoryName {
    NSString *documentPath = [self documentPath];
    NSString *targetPath = [documentPath stringByAppendingPathComponent:aDirctoryName];
    [self createDirectoryAtPath:targetPath];
    return targetPath;
}

+ (NSString *)createDirectoryAtPath:(NSString *)aTargetPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL flag = [fileManager fileExistsAtPath:aTargetPath];
    if (!flag) {
        [fileManager createDirectoryAtPath:aTargetPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    return aTargetPath;
}

+ (BOOL)isExistsAtPath:(NSString *)aPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:aPath];
}


+ (NSString *)copyItemAtPath:(NSString *)aSourcePath
                          to:(NSString *)aTargetPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL flag = [fileManager fileExistsAtPath:aSourcePath];
    if (!flag) {
        JLLog_I(@"File non-existstent ! <path=%@>", aSourcePath);
        return nil;
    }
    NSError *error = nil;
    [fileManager copyItemAtPath:aSourcePath toPath:aTargetPath error:&error];
    if (error) {
        JLLog_E(@"Ops! error copying = %@", error);
        return nil;
    }
    return aTargetPath;
}

@end
