//
//  AIDocument.m
//  anbang_ios
//
//  Created by rooter on 15-6-3.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIDocument.h"
#import "MJExtension.h"

@implementation AIDocument

+ (AIDocument *)documentWithFilePath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        return nil;
    }
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
    AIDocument *document = [[AIDocument alloc] init];
    NSInteger size = [fileAttributes[NSFileSize] integerValue];
    CGFloat kb_size = size /  1024.0;
    if (kb_size < 1024) {
        document.size = [NSString stringWithFormat:@"%.2fKB", kb_size];
    }else {
        CGFloat mb_size = kb_size / 1024.0;
        document.size = [NSString stringWithFormat:@"%.2fMB", mb_size];
    }
    document.fileName = filePath.lastPathComponent;
    document.fileType = [[document.fileName componentsSeparatedByString:@"."] lastObject];
    document.link = filePath;
    document.charSize = [NSString stringWithFormat:@"%d", size];
    return document;
}

+ (AIDocument *)documentWithJson:(NSString *)json {
    NSError *error = nil;
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *docu = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    if (error) {
        JLLog_I(@"Invalid Data! %@", error);
    }
    return [AIDocument objectWithKeyValues:docu];
}

- (NSString *)documentMessageBody {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.keyValues
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    return [[NSString alloc] initWithData:jsonData
                                 encoding:NSUTF8StringEncoding];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<class=%@, self=%p> {%@}", [self class], self, self.keyValues];
}

@end
