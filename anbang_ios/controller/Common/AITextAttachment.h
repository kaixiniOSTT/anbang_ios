//
//  AITextAttachment.h
//  anbang_ios
//
//  Created by Kim on 15/8/1.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AITextAttachment : NSTextAttachment

//表情的字符串表示，见前文
@property(strong, nonatomic) NSString *emojiTag;

//新增：保存当前表情图片的大小
@property(assign, nonatomic) CGFloat emojiSize;

@end
