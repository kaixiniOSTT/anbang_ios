//
//  JLTipsView.m
//  CustomViews
//
//  Created by rooter on 15-3-12.
//  Copyright (c) 2015年 rooter. All rights reserved.
//

#import "JLTipsView.h"

#define BORDER_MARGIN    10
#define TIP_LABEL_HEIGHT 50

@implementation JLTipsView

- (instancetype)initWithTip:(NSString *)tip {
    
    CGSize size = [tip  sizeWithFont:[UIFont systemFontOfSize:14.5]
                        constrainedToSize:CGSizeMake(MAXFLOAT, 0.0)
                        lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat width = 180.0;
    
    if (size.width > 180) {
        width = size.width;
    }
    
    CGRect rect = CGRectMake(0, 0, width + 20, 40);
    
    self = [super initWithFrame:rect];
    
    if (self) {
        
        [self setupInterfaceWithTip:tip];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame tip:(NSString *)tip {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setupInterfaceWithTip:tip];
    }
    
    return self;
}

- (void)setupInterfaceWithTip:(NSString *)tip {
    
    self.backgroundColor = [UIColor lightGrayColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10.0;
    if (tip) {
        self.text = tip;
    }
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor whiteColor];
    self.font = [UIFont systemFontOfSize:14.5];
    self.alpha = 0.0;
}

- (void)showInView:(UIView *)view animated:(BOOL)animated {
    
    [self showInView:view animated:animated autoRelease:YES];
}

- (void)showInView:(UIView *)view animated:(BOOL)animated autoRelease:(BOOL)release {
    
    self.center = view.center;
    [view addSubview:self];
    
    if (animated) {
        
        [UIView beginAnimations:@"show" context:(__bridge void *)([NSNumber numberWithBool:release])];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        
        self.alpha = 0.2;
        self.alpha = 0.6;
        self.alpha = 1.0;

        [UIView commitAnimations];
        
    }else {
        
        self.alpha = 1.0;
        
        if (release) {
            
            [self doneWithAnimated:NO];
        }
    }
}

- (void)show:(NSString *)tip {
    
    mTip = tip;
    self.text = mTip;
    
    [self show];
}

- (void)show {
    
    if (!self.superview) {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        [self showInView:keyWindow animated:YES];
    }else {
        [self showInView:self.superview animated:YES];
    }
    

}

- (void)doneWithAnimated:(BOOL)animated {

    if (animated) {
        
        [UIView beginAnimations:@"hide" context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelay:1.0];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        
        self.alpha = 1.0;
        self.alpha = 0.6;
        self.alpha = 0.2;
        self.alpha = 0.0;
        
        [UIView commitAnimations];
    }
}

- (void)animationDidStop:(NSString *)animationID
                finished:(NSNumber *)finished
                 context:(void *)context {
    
    if ([animationID isEqualToString:@"show"]) {
        
        NSNumber *number = (__bridge NSNumber *)context;
        BOOL hide = [number boolValue];
        
        if (hide) {
            [self doneWithAnimated:hide];
        }
    }else {
        
        [self removeFromSuperview];
    }
}


@end
