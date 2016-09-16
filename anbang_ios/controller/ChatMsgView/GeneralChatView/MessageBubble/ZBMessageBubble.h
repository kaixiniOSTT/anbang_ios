//
//  ZBMessageBubble.h
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-19.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBMessage.h"
#import "CustomMethod.h"
#import "OHAttributedLabel.h"
#import "MarkupParser.h"
#import "ZBMessageBubbleFactory.h"


@interface ZBMessageBubble : NSObject<OHAttributedLabelDelegate>

- (UIImageView *)getBubbleViewByMessage:(ZBMessage *)message;

@end
