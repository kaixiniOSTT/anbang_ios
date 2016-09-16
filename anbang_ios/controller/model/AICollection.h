//
//  AICollection.h
//  anbang_ios
//
//  Created by rooter on 15-4-30.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserInfo;

typedef NS_ENUM(NSInteger, AICollectionSourceType) {
    AICollectionSourceTypeChat = 1,
    AICollectionSourceTypeGroupChat
};

typedef NS_ENUM(NSInteger, AIMessageType) {
    AIMessageTypeText = 1,
    AIMessageTypePicture,
    AIMessageTypeVoice,
    AIMessageTypeDocument,
    AIMessageTypeVedio,
    AIMessageTypeLocation,
    AIMessageTypePersonal,
    AIMessageTypeArticle
};

@interface AICollection : NSObject

@property (nonatomic, copy)     NSString *owner;
@property (nonatomic, copy)     NSString *sender;
@property (nonatomic, assign)   AICollectionSourceType sourceType;
@property (nonatomic, assign)   AIMessageType messageType;
@property (nonatomic, copy)     NSString *circleID;
@property (nonatomic, copy)     NSString *createDate;
@property (nonatomic, strong)   NSString *message;
@property (nonatomic, copy)     NSString *serviceId;

@end

