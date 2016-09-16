//
//  AITitleBarButtonItem.m
//  anbang_ios
//
//  Created by Kim on 15/8/4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AITitleBarButtonItem.h"

@implementation AITitleBarButtonItem


- (id)initWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button setTitle:title forState:UIControlStateNormal];
    _button.titleLabel.font = [UIFont systemFontOfSize:16];
    _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    CGSize size = [title boundingRectWithSize:CGSizeMake(200, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil].size;
    _button.frame = CGRectMake(0, 0, size.width, 30);
    return [[super init] initWithCustomView:_button];
}

- (UIButton*) button
{
    return _button;
}

@end
