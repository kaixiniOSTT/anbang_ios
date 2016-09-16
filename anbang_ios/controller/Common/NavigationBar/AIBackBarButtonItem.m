//
//  AIBarButtonBackItem.m
//  anbang_ios
//
//  自定义返回UIBarButtonItem
//
//  Created by Kim on 15/8/3.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBackBarButtonItem.h"

@implementation AIBackBarButtonItem

- (id)initWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    title = (title == nil?@"返回":title);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button setImage:[UIImage imageNamed:@"header_button_back"] forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    CGSize size = [title boundingRectWithSize:CGSizeMake(200, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil].size;
    button.frame = CGRectMake(0, 0, size.width + 16, 30);
    return [[super init] initWithCustomView:button];
}

@end
