//
//  AIShareButton.m
//  anbang_ios
//
//  Created by rooter on 15-7-30.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIShareButton.h"

@implementation AIShareButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    float width = contentRect.size.width;
    float height = contentRect.size.height;
    CGRect rect = CGRectMake(0, height*2/3, width, height/3);
    return rect;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    float width = contentRect.size.width;
    float height = contentRect.size.height;
    CGRect rect = CGRectMake(width/3/2, 0, width*2/3, height*2/3);
    return rect;
}

@end
