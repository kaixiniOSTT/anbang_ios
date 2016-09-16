//
//  AIDocumentDownloadManager.h
//  anbang_ios
//
//  Created by rooter on 15-7-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface AIDocumentDownloadManager : NSObject

/**
 * Use a static mutable dictioary to manage all document download tasks
 * The key is document's TFS link string by appending cache path's last component,
 * just like "Tfp458554sda443_20003", (attention to the component '_')
 * And the value is document's download request with ASIHTTPRequest object.
 */

+ (void) setRequest:(ASIHTTPRequest *)aRequest forKey:(NSString *)aKey;

+ (ASIHTTPRequest *) requestWithKey:(NSString *)aKey;

+ (void) removeRequestForKey:(NSString *)aKey;

// Cancel all tasks at when application will terminate
+ (void) cancelAll;

+ (BOOL) isDownloadingWithKey:(NSString *)aKey;

@end
