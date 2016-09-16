//
//  AIBottomView.h
//  anbang_ios
//
//  Created by rooter on 15-5-7.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AIBottomView;

@protocol AIBottomViewDelegate <NSObject>

-           (void)bottomView:(AIBottomView *)bottomView
    didSelectedButtonAtIndex:(NSInteger)index
                      button:(UIButton *)button;

@end

@interface AIBottomView : UIView
{
    id<AIBottomViewDelegate> mDelegate;
}

+ (AIBottomView *)bottomViewWithDelegete:(id<AIBottomViewDelegate>)delegate;

- (void)show;

- (void)hide;

@end
