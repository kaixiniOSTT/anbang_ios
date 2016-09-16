//
//  AITitleBarButtonItem.h
//  anbang_ios
//
//  Created by Kim on 15/8/4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AITitleBarButtonItem : UIBarButtonItem
{
    UIButton *_button;
}

- (id)initWithTitle:(NSString*)title target:(id)target action:(SEL)action;

@property (nonatomic, strong, readonly) UIButton *button;

@end
