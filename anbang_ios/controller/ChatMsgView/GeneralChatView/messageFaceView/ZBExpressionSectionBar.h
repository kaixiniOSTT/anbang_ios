//
//  ZBExpressionSectionBar.h
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-13.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ZBExpressionSectionBarDelegate <NSObject>

/*
 * 点击发送表情代理
 * @param
 *
 */
- (void)didSendBtnFace;

@end

@interface ZBExpressionSectionBar : UIView
@property (nonatomic,weak) id<ZBExpressionSectionBarDelegate>delegate;
@end
