//
//  AICurrentContactController.h
//  anbang_ios
//
//  Created by rooter on 15-5-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIMessageSendAssisstantDelegate.h"

@class AIMessageSendAssisstant;


@interface AICurrentContactController : UIViewController

@property (copy, nonatomic) NSString *fromUserName;
@property (strong, nonatomic) NSArray *messages;

@property (assign, nonatomic) id<AIMessageSendAssisstantDelegate> delegate;

@end
