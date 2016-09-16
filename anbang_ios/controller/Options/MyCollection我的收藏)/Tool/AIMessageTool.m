//
//  AIMessageTool.m
//  anbang_ios
//
//  Created by rooter on 15-5-4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIMessageTool.h"
#import "JSONKit.h"
#import "Photo.h"

@implementation AIMessageTool

+ (NSDictionary *)dictionaryWithMessage:(NSString *)message
{
    NSString *imageJsonStr = [message stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    return [imageJsonStr objectFromJSONString];
}

+ (UIImage *)messageToImage:(NSString *)text
{
    NSDictionary *imageData = [self dictionaryWithMessage:text];
    return [Photo string2Image:[imageData objectForKey:@"data"]];
}

+ (NSString *)HDImageLinkIdWithMessage:(NSString *)text
{
    NSDictionary *imageData = [self dictionaryWithMessage:text];
    return [imageData objectForKey:@"link"];
}

+ (NSString *)HDImageLinkWithMessage:(NSString *)text
{
    return [NSString stringWithFormat:@"%@/%@", ResourcesURL, [self HDImageLinkIdWithMessage:text]];
}

+ (UIImage *)DocumentIconWithType:(NSString *)documentType
{
    NSString *icon_name = nil;
    if ([documentType isEqualToString:@"pdf"]) {
        icon_name = @"icon_pdf";
    }else if ([documentType isEqualToString:@"ppt"] || [documentType isEqualToString:@"pptx"]) {
        icon_name = @"icon_ppt";
    }else if ([documentType isEqualToString:@"doc"] || [documentType isEqualToString:@"docx"]) {
        icon_name = @"icon_word";
    }else if ([documentType isEqualToString:@"xls"] || [documentType isEqualToString:@"xlsx"]) {
        icon_name = @"icon_excel";
    }
    return [UIImage imageNamed:icon_name];
}

@end
