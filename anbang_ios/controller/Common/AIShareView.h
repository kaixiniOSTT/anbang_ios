//
//  AIShareView.h
//  anbang_ios
//
//  Created by rooter on 15-8-4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  AIShareView;

@protocol AIShareViewDelegate <NSObject>

- (void)shareView:(AIShareView *)shareView didClickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface AIShareView : UIView

@property (nonatomic, assign) id<AIShareViewDelegate> delegate;

+ (id)shareViewWithImages:(NSArray *)images titles:(NSArray *)titles;

- (void)show;

@end
