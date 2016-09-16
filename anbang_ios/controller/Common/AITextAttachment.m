//
//  AITextAttachment.m
//  anbang_ios
//
//  Created by Kim on 15/8/1.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AITextAttachment.h"

@implementation AITextAttachment

//I want my emoticon has the same size with line's height
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex NS_AVAILABLE_IOS(7_0)
{
    return [self scaleImageSizeToWidth:_emojiSize];;
}

//计算新的图片大小
//这里不涉及对图片实际数据的压缩，所以不用异步处理~

- (CGRect)scaleImageSizeToWidth:(CGFloat)width {
    //缩放系数
    CGFloat factor = 1.0;
    
    //获取原本图片大小
    CGSize oriSize = [self.image size];
    
    //计算缩放系数
    factor = (CGFloat) (width / oriSize.width);
    
    //创建新的Size
    CGRect newSize = CGRectMake(0, -3, oriSize.width * factor, oriSize.height * factor);
    
    return newSize;
    
}

@end
