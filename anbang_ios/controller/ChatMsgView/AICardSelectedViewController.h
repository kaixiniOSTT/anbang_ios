//
//  AICardSelectedViewController.h
//  anbang_ios
//
//  Created by rooter on 15-6-3.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIMessageSendAssisstant.h"

@interface AICardSelectedViewController : UIViewController

@property (nonatomic, copy) NSString *oppositeJID;
@property (nonatomic, assign) AIChatType chatType;
@property (nonatomic, assign) id<AIMessageSendAssisstantDelegate> delegate;

@end
