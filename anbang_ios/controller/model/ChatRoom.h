//
//  ChatRoom.h
//  anbang_ios
//
//  Created by silenceSky  on 14-3-27.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatRoom : NSObject
@property (retain,nonatomic)  NSString *jid;
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *creator;
@property (retain, nonatomic) NSString *room;
@property (retain, nonatomic) NSString *myJID;
@property (retain, nonatomic) NSString *createDate;
@property (retain, nonatomic) NSString *modificationDate;
@end
