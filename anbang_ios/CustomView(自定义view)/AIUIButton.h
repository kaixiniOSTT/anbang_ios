//
//  AIUIButton.h
//  anbang_ios
//
//  Created by Kim on 15/5/5.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIUIButton : UIButton
@property (nonatomic, copy) NSString *name;
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;
- (UIColor *)backgroundColorForState:(UIControlState)state;
@end
