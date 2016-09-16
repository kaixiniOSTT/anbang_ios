//
//  AINewFriendsCRUD.h
//  anbang_ios
//
//  Created by rooter on 15-6-16.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AINewFriendRequestItem.h"

@interface AINewFriendsCRUD : NSObject

+ (void)addANewFriendItem:(AINewFriendRequestItem *)aItem;
+ (void)addNewFriendsItens:(NSArray *)items;
+ (NSArray *)requestItems;
+ (void)updateReadStatuses;
+ (NSInteger)unreadCount;
+ (void)updateStatus:(NSString *)status ofRequester:(NSString *)requester;
+ (void)deleteAItem:(AINewFriendRequestItem *)aItem;

@end
