//
//  AICollectionCRUD.h
//  anbang_ios
//
//  Created by rooter on 15-4-30.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AICollection;

@interface AICollectionCRUD : NSObject

+ (void)insertCollection:(AICollection *)aCollection;
+ (void)insertCollections:(NSArray *)collections;

+ (void)deleteCollection:(NSString *)aServiceId;
+ (void)clear;

+ (NSArray *)collections;

@end
