//
//  AIArticle.h
//  anbang_ios
//
//  Created by rooter on 15-7-30.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface AIArticle : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *abstract;
@property (strong, nonatomic) NSString *src;
@property (strong, nonatomic) NSString *cover;

+ (AIArticle *)articleWithJson:(NSString *)json;
- (NSString *)articleMessageBody;

@end
