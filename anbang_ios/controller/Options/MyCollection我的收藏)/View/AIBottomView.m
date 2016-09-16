//
//  AIBottomView.m
//  anbang_ios
//
//  Created by rooter on 15-5-7.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBottomView.h"

@implementation AIBottomView

- (id)initWithDelegate:(id<AIBottomViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        mDelegate = delegate;
        [self setupMe];
        [self setupSubviews];
    }
    return self;
}

+ (AIBottomView *)bottomViewWithDelegete:(id<AIBottomViewDelegate>)delegate
{
    return [[[self class] alloc] initWithDelegate:delegate];
}

- (void)setupMe
{
    CGFloat view_w = Screen_Width;
    CGFloat view_h = 40;
    CGRect rect = CGRectMake(0, Screen_Height - Both_Bar_Height, view_w, view_h);
    self.frame = rect;
}

- (void)setupSubviews
{
    CGFloat view_w = self.frame.size.width;
    CGFloat view_h = self.frame.size.height;
    
    CGFloat margin_w = 0.5;
    CGFloat button_w = (view_w - margin_w) / 2.0;
    
    CGRect trans_frame = CGRectMake(0, 0, button_w, view_h);
    UIButton *trans = [[UIButton alloc] initWithFrame:trans_frame];
    trans.frame = trans_frame;
    trans.backgroundColor = AB_Color_efe8df;
    [trans setImage:[UIImage imageNamed:@"my_icon_repost"] forState:UIControlStateNormal];
    [trans addTarget:self action:@selector(retweet:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:trans];
    
    CGFloat margin_y = 5;
    CGFloat margin_h = view_h - 2 * margin_y;
    UIView *marginView = [[UIView alloc] init];
    marginView.frame = CGRectMake(CGRectGetMaxX(trans.frame), margin_y, margin_w, margin_h);
    marginView.backgroundColor = AB_Gray_Color;
    [self addSubview:marginView];
    
    UIButton *trash = [UIButton buttonWithType:UIButtonTypeCustom];
    trash.frame = CGRectMake(CGRectGetMaxX(marginView.frame), 0, button_w, view_h);
    trash.backgroundColor = AB_Color_efe8df;
    [trash setImage:[UIImage imageNamed:@"my_icon_delete"] forState:UIControlStateNormal];
    [trash addTarget:self action:@selector(trash:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:trash];
}

#pragma mark
#pragma mark Animations

- (void)show
{
    CGRect frame = self.frame;
    CGFloat h = frame.size.height;
    frame.origin.y -= h;
    
    [UIView beginAnimations:@"bottom_show" context:nil];
    [UIView setAnimationDuration:0.3];
    self.frame = frame;
    [UIView commitAnimations];
}

- (void)hide
{
    CGRect frame = self.frame;
    CGFloat h = frame.size.height;
    frame.origin.y += h;
    
    [UIView beginAnimations:@"bottom_hide" context:nil];
    [UIView setAnimationDuration:0.3];
    self.frame = frame;
    [UIView commitAnimations];
}

#pragma end

#pragma mark
#pragma mark Button Actions

- (void)retweet:(UIButton *)sender
{
    if (mDelegate && [mDelegate respondsToSelector:@selector(bottomView:didSelectedButtonAtIndex:button:)]) {
        [mDelegate bottomView:self didSelectedButtonAtIndex:0 button:sender];
    }
}

- (void)trash:(UIButton *)sender
{
    if (mDelegate && [mDelegate respondsToSelector:@selector(bottomView:didSelectedButtonAtIndex:button:)]) {
        [mDelegate bottomView:self didSelectedButtonAtIndex:1 button:sender];
    }
}

#pragma end



@end
