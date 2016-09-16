//
//  AINewFriendsCRUD.m
//  anbang_ios
//
//  Created by rooter on 15-6-16.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AINewFriendsCRUD.h"
#import "MyFMDatabaseQueue.h"
#import "FMDatabaseQueue.h"

@implementation AINewFriendsCRUD

+ (void)addANewFriendItem:(AINewFriendRequestItem *)aItem {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        FMDatabaseQueue *queue = [MyFMDatabaseQueue getSharedInstance];
        [queue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"replace into NewFriends (requester, name, avatar, accountType, status, \
             validate_info, sort_letters, read_status) values (?, ?, ?, ?, ?, ?, ?, ?);", aItem.requester, aItem.name, aItem.avatar,
             aItem.accountType, aItem.status, aItem.validateInfo, aItem.nameSpelling, aItem.status];
        }];
    });
}

+ (void)addNewFriendsItens:(NSArray *)items {
    for (AINewFriendRequestItem *item in items) {
        [self addANewFriendItem:item];
    }
}

+ (NSArray *)requestItems {
    FMDatabaseQueue *queue = [MyFMDatabaseQueue getSharedInstance];
    __block NSMutableArray *items = nil;
    [queue inDatabase:^(FMDatabase *db) {
        items = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:@"select * from NewFriends order by sort_letters;"];
        while ([rs next]) {
            AINewFriendRequestItem *i = [[AINewFriendRequestItem alloc] init];
            i.requester = [rs stringForColumn:@"requester"];
            i.name = [rs stringForColumn:@"name"];
            i.avatar = [rs stringForColumn:@"avatar"];
            i.accountType = [rs stringForColumn:@"accountType"];
            i.status = [rs stringForColumn:@"status"];
            i.validateInfo = [rs stringForColumn:@"validate_info"];
            i.nameSpelling = [rs stringForColumn:@"sort_letters"];
            [items addObject:i];
        }
        [rs close];
    }];
    return items;
}

+ (NSInteger)unreadCount {
    FMDatabaseQueue *queue = [MyFMDatabaseQueue getSharedInstance];
    __block NSInteger count = 0;
    [queue inDatabase:^(FMDatabase *db) {
        // unread symbol '1'
        FMResultSet *rs = [db executeQuery:@"select count(*) from NewFriends where read_status = '1'"];
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
        }
        [rs close];
    }];
    return count;
}

+ (void)updateStatus:(NSString *)status ofRequester:(NSString *)requester {
    FMDatabaseQueue *queue = [MyFMDatabaseQueue getSharedInstance];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"update NewFriends set status = ? where requester = ?", status, requester];
    }];
}

+ (void)updateReadStatuses {
    FMDatabaseQueue *queue = [MyFMDatabaseQueue getSharedInstance];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"update NewFriends set read_status = ?", @"0"];
    }];
}

+ (void)deleteAItem:(AINewFriendRequestItem *)aItem {
    FMDatabaseQueue *queue = [MyFMDatabaseQueue getSharedInstance];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"delete from NewFriends where requester = ?", aItem.requester];
    }];
}

@end
