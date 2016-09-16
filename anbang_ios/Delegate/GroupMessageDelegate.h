//
//  GroupMessageDelegate.h
//  anbang_ios
//
//  Created by silenceSky  on 14-5-22.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPMessage.h"

@protocol GroupMessageDelegate <NSObject>
-(void)newGroupMessageReceived:(XMPPMessage *)message;
//以后考虑将临时多人会话过渡成圈子
-(void)newMultiChatMessageReceived:(XMPPMessage *)message;
@end
