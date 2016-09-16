//
//  AIBarButtonBackItem.h
//  anbang_ios
//
//  自定义返回UIBarButtonItem，支持传入标题及点击动作
//
//  Created by Kim on 15/8/3.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIBackBarButtonItem : UIBarButtonItem

- (id)initWithTitle:(NSString*)title target:(id)target action:(SEL)action;

@end
