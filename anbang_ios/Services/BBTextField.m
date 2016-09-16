//
//  BBTextField.m
//  anbang_ios
//
//  Created by YAO on 15/7/17.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "BBTextField.h"

@implementation BBTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(id)initWithFrame:(CGRect)frame Icon:(UIImageView*)icon
{
    self = [super initWithFrame:frame];
    if (self) {
        self.leftView = icon;
        self.leftViewMode = UITextFieldViewModeAlways;
    }
    return self;
}

-(CGRect) leftViewRectForBounds:(CGRect)bounds {
    
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.origin.x += 10;
    return iconRect;
}

-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
    if (!self.leftView) {
        CGRect inset = CGRectMake(bounds.origin.x + 10, bounds.origin.y, bounds.size.width - 10, bounds.size.height);
        return inset;
        
    }else {
        CGRect inset = CGRectMake(bounds.origin.x + 30, bounds.origin.y, bounds.size.width - 30, bounds.size.height);
        return inset;
        
    }

}

-(CGRect)textRectForBounds:(CGRect)bounds
{
    if (!self.leftView) {
        CGRect inset = CGRectMake(bounds.origin.x + 10, bounds.origin.y, bounds.size.width - 10, bounds.size.height);
        return inset;
        
    }else {
        CGRect inset = CGRectMake(bounds.origin.x + 30, bounds.origin.y, bounds.size.width - 30, bounds.size.height);
        return inset;
    }
}

-(CGRect)editingRectForBounds:(CGRect)bounds
{
    if (!self.leftView) {
        CGRect inset = CGRectMake(bounds.origin.x + 10, bounds.origin.y, bounds.size.width - 10, bounds.size.height);
        return inset;
        
    }else {
        CGRect inset = CGRectMake(bounds.origin.x + 30, bounds.origin.y, bounds.size.width - 30, bounds.size.height);
        return inset;
        
    }
}


@end
