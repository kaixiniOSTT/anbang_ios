//
//  AIChatResourceCache.m
//  anbang_ios
//
//  Created by rooter on 15-6-4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIChatResourceCache.h"
#import "SDImageCache.h"

#define Chat_Resource_Directory_Name  @"ChatResourceCache"
#define Chat_Images_Directory_Name @"ChatImages"

@interface AIChatResourceCache ()
@property (copy, nonatomic) NSString *documentCache;
@end

@implementation AIChatResourceCache

- (id)initWithUserName:(NSString *)aUserName {
    self = [super init];
    if (self) {
        _userName = aUserName;
        
        // Init Image disk cache, use SDImageCache
        NSString *ns_image = [NSString stringWithFormat:@"%@/%@", MY_USER_NAME, aUserName];
        _imageCache = [[SDImageCache alloc] initWithNamespace:ns_image];
        
        // Init document disk cache
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *ns = [NSString stringWithFormat:@"bbchat.documents/%@/%@", MY_USER_NAME, aUserName];
        _documentCache = [paths[0] stringByAppendingPathComponent:ns];
    }
    return self;
}

+ (AIChatResourceCache *)cacheWithUserName:(NSString *)aUserName {
    return [[AIChatResourceCache alloc] initWithUserName:aUserName];
}

- (NSString *)documentCache {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_documentCache]) {
        [fileManager createDirectoryAtPath:_documentCache withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return _documentCache;
}

#pragma mark
#pragma mark Image part

- (NSString *)storeImage:(UIImage *)aImage forKey:(NSString *)aKey {
    [self.imageCache storeImage:aImage forKey:aKey toDisk:YES];
    return [self.imageCache diskPathWithImageKey:aKey];
}

- (UIImage *)imageForKey:(NSString *)aKey {
    return [self.imageCache imageFromDiskCacheForKey:aKey];
}

- (void)deleteImageForKey:(NSString *)aKey {
    [self.imageCache removeImageForKey:aKey fromDisk:YES];
}

- (void)clearCache {
    [self.imageCache cleanDisk];
    [self.imageCache cleanDisk];
}

#pragma mark
#pragma mark Document Part

- (void)storeDocument:(NSData *)aData type:(NSString *)aType forKey:(NSString *)aKey {
    if (!aData || !aKey) {
        JLLog_I(@"NSData or Key non-existstent");
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:_documentCache]) {
        [fileManager createDirectoryAtPath:_documentCache withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSString *path = [self pathWithKey:aKey ofType:aType];
    [fileManager createFileAtPath:path contents:aData attributes:nil];
}

- (BOOL)isExistsDocumentForKey:(NSString *)aKey ofType:(NSString *)aType {
    return [[self class] isExistsAtPath:[self pathWithKey:aKey ofType:aType]];
}

- (NSString *)pathWithKey:(NSString *)aKey ofType:(NSString *)aType {
    return [self.documentCache stringByAppendingPathComponent:[self fileNameWithKey:aKey typed:aType]];
}

- (BOOL)copyItemWithKey:(NSString *)aKey type:(NSString *)aType to:(NSString *)aUserName {
    NSString *path = [self pathWithKey:aKey ofType:aType];
    AIChatResourceCache *cache = [AIChatResourceCache cacheWithUserName:aUserName];
    NSString *newPath = [cache pathWithKey:aKey ofType:aType];
    return [[self class] copyItemAtPath:path to:newPath] ? YES : NO;
}

#pragma mark
#pragma mark (private)

- (NSString *)fileNameWithKey:(NSString *)aKey typed:(NSString *)aType {
    return [aKey stringByAppendingFormat:@".%@",aType];
}


// Copy document from source path to document cacehe, then named with key
//- (NSString *)storeDocument:(NSString *)aSourcePath forKey:(NSString *)aKey {
//    
//}


@end
