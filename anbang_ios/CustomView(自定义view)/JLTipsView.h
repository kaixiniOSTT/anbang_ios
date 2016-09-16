//
//  JLTipsView.h
//  CustomViews
//
//  Created by rooter on 15-3-12.
//  Copyright (c) 2015年 rooter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLTipsView : UILabel {
    
    NSString *mTip;
}

- (instancetype)initWithFrame:(CGRect)frame tip:(NSString *)tip;

- (instancetype)initWithTip:(NSString *)tip;

- (void)showInView:(UIView *)view animated:(BOOL)animated;

- (void)show:(NSString *)tip;

- (void)showInView:(UIView *)view animated:(BOOL)animated autoRelease:(BOOL)release;

- (void)doneWithAnimated:(BOOL)animated;

@end
