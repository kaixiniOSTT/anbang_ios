//
//  UITextField+JL.m
//  anbang_ios
//
//  Created by rooter on 15-3-25.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "UITextField+JL.h"

@implementation UITextField (JL)

- (void)setCustomPlaceholder:(NSString *)placeHolder {
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = AB_Gray_Color;
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolder attributes:attrs];
}

@end
