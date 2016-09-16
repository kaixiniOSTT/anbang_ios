//
//  AIRemessage.h
//  anbang_ios
//
//  Created by rooter on 15-5-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AIRemessageType) {
    AIRemessageTypeChat,
    AIRemessageTypeImage,
    AIRemessageTypeCard,
    AIRemessageTypeDocument,
    AIRemessageTypeLocation,
    AIRemessageTypeArticle
};

@interface AIRemessage : NSObject

//@property (nonatomic, copy) NSString *speaker;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) AIRemessageType messageType;

- (id)initWithDictionary:(NSDictionary *)message;

@end
