//
//  KKChatDelegate.m
//  anbang_ios
//
//  Created by silenceSky  on 14-4-18.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KKMessageDelegate <NSObject>

-(void)newMessageReceived:(NSDictionary *)messageContent;

@end
