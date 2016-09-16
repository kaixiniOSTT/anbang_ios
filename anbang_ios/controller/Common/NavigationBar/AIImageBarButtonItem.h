//
//  AIImageBarButtonItem.h
//  anbang_ios
//
//  自定义图片UIBarButtonItem，可传入图片名称以及处理动作
//
//  Created by Kim on 15/8/4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIImageBarButtonItem : UIBarButtonItem

- (id)initWithImageNamed:(NSString*)name target:(id)target action:(SEL)action;

@end
