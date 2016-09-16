//
//  AIArticle.m
//  anbang_ios
//
//  Created by rooter on 15-7-30.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIArticle.h"
#import "Photo.h"

@implementation AIArticle

+ (AIArticle *)articleWithJson:(NSString *)json {
    NSError *error = nil;
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *arti = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    if (error) {
        JLLog_I(@"Invalid Data! %@", error);
    }
    return [AIArticle objectWithKeyValues:arti];
}

- (NSString *)articleMessageBody {
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
