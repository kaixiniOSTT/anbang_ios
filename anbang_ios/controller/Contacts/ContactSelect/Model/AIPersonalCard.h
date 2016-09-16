//
//  AIPersonalCard.h
//  anbang_ios
//
//  Created by rooter on 15-5-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIPersonalCard : NSObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, copy) NSString *avatar;

- (id)initWithJID:(NSString *)jid;
+ (AIPersonalCard *)cardWithJson:(NSString *)json;

@end
