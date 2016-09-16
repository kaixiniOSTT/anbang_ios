//
//  contacts.h
//  anbang_ios
//
//  Created by silenceSky  on 14-4-26.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contacts : NSObject
@property (retain,nonatomic)  NSString *jid;
@property (retain, nonatomic) NSString *remarkName;
@property (retain, nonatomic) NSString *nickName;
@property (retain, nonatomic) NSString *phone;
@property (retain, nonatomic) NSString *avatar;
@property (retain, nonatomic) NSString *string;
@property (retain, nonatomic) NSString *pinYin;
@property (assign, nonatomic) int accountType;
@end
