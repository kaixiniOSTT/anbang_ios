//
//  AIMessageSendAssisstantDelegate.h
//  anbang_ios
//
//  Created by rooter on 15-6-10.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AIMessageSendAssisstantDelegate <NSObject>
- (void)reloadMessages:(NSArray *)randomIds;
- (void)messageSendingAbort:(NSArray *)randomIds;
@end
