//
//  AIMessageTool.h
//  anbang_ios
//
//  Created by rooter on 15-5-4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIMessageTool : NSObject

/**
 *  Image message tools
 */
+ (UIImage *)messageToImage:(NSString *)message;
+ (NSString *)HDImageLinkIdWithMessage:(NSString *)text;
+ (NSString *)HDImageLinkWithMessage:(NSString *)text;
+ (UIImage *)DocumentIconWithType:(NSString *)documentType;

@end
