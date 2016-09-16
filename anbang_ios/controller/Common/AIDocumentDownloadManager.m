//
//  AIDocumentDownloadManager.m
//  anbang_ios
//
//  Created by rooter on 15-7-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIDocumentDownloadManager.h"

static NSMutableDictionary *requests = nil;

@implementation AIDocumentDownloadManager

+ (NSMutableDictionary *) requests {
    if (!requests) {
        requests = [NSMutableDictionary dictionary];
    }
    return requests;
}

+ (void) setRequest:(ASIHTTPRequest *)aRequest forKey:(NSString *)aKey {
    ASIHTTPRequest *request = [[self requests] objectForKey:aKey];
    if (request) { return; }
    [[self requests] setObject:aRequest forKey:aKey];
}

+ (ASIHTTPRequest *)requestWithKey:(NSString *)aKey {
    return [[self requests] objectForKey:aKey];
}

+ (void) removeRequestForKey:(NSString *)aKey {
    ASIHTTPRequest *request = [[self requests] objectForKey:aKey];
    [request clearDelegatesAndCancel];
    [[self requests] removeObjectForKey:aKey];
    request = nil;
}

+ (void) cancelAll {
    [[self requests] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        ASIHTTPRequest *request = obj;
        [request clearDelegatesAndCancel];
        [requests removeObjectForKey:key];
    }];
}

+ (BOOL) isDownloadingWithKey:(NSString *)aKey {
    ASIHTTPRequest *request = [[self requests] objectForKey:aKey];
    if (!request) {
        return NO;
    }
    return request.isExecuting;
}

@end
