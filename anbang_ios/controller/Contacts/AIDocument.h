//
//  AIDocument.h
//  anbang_ios
//
//  Created by rooter on 15-6-3.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIDocument : NSObject

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *size;
@property (nonatomic, copy) NSString *charSize;

+ (AIDocument *)documentWithFilePath:(NSString *)filePath;

+ (AIDocument *)documentWithJson:(NSString *)json;

- (NSString *)documentMessageBody;

@end
