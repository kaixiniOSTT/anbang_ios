//
//  AIChatResourceCache.h
//  anbang_ios
//
//  Created by rooter on 15-6-4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AISandBoxHandler.h"

@class SDImageCache;

@interface AIChatResourceCache : AISandBoxHandler

@property (strong, nonatomic) SDImageCache *imageCache;
@property (strong, readonly)  NSString *userName; // Use for cache path namespace

+ (AIChatResourceCache *)cacheWithUserName:(NSString *)aUserName;

// For image
- (NSString *)storeImage:(UIImage *)image forKey:(NSString *)aKey;
- (UIImage *)imageForKey:(NSString *)aKey;
- (void)deleteImageForKey:(NSString *)aKey;


// For Document
- (void)storeDocument:(NSData *)aData type:(NSString *)aType forKey:(NSString *)aKey;
- (BOOL)isExistsDocumentForKey:(NSString *)aKey ofType:(NSString *)aType;
- (NSString *)pathWithKey:(NSString *)aKey ofType:(NSString *)aType;
- (BOOL)copyItemWithKey:(NSString *)aKey type:(NSString *)aType to:(NSString *)aUserName;

@end
