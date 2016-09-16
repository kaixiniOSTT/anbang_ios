//
//  AICollectionCRUD.m
//  anbang_ios
//
//  Created by rooter on 15-4-30.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AICollectionCRUD.h"
#import "AICollection.h"
#import "PublicCURD.h"
#import "MyFMDatabaseQueue.h"
#import "FMDatabaseQueue.h"

@implementation AICollectionCRUD

+ (void)insertCollection:(AICollection *)aCollection
{
    FMDatabaseQueue *queue = [MyFMDatabaseQueue getSharedInstance];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        NSNumber *message_type = [NSNumber numberWithInteger:aCollection.messageType];
        NSNumber *source_type = [NSNumber numberWithInteger:aCollection.sourceType];
        
        [db executeUpdate:@"insert into t_collection (owner, sender, source, circleID, create_date, message, message_type, store_id) values(?, ?, ?, ?, ?, ?, ?, ?);", aCollection.owner, aCollection.sender, source_type, aCollection.circleID, aCollection.createDate, aCollection.message, message_type, aCollection.serviceId];
    }];
    
    [MyFMDatabaseQueue close];
}

+ (void)insertCollections:(NSArray *)collections
{
    for (AICollection *collection in collections) {
        [self insertCollection:collection];
    }
}

+ (void)deleteCollection:(NSString *)aServiceId
{
    FMDatabaseQueue *queue = [MyFMDatabaseQueue getSharedInstance];
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"delete from t_collection where store_id = ?;", aServiceId];
    }];
}

+ (void)clear
{
    FMDatabaseQueue *queue = [MyFMDatabaseQueue getSharedInstance];
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"delete from t_collection;"];
    }];
    [MyFMDatabaseQueue close];
}

+ (void)deleteCollectionsWithServiceId:(NSArray *)indexes
{
    for (NSString *index in indexes) {
        [self deleteCollection:index];
    }
}

+ (NSArray *)collections
{
    FMDatabaseQueue *queue = [MyFMDatabaseQueue getSharedInstance];
    
    __block NSMutableArray *collections = nil;
    
    [queue inDatabase:^(FMDatabase *db) {
        
        collections = [NSMutableArray array];
        
        FMResultSet *rs = nil;
        rs = [db executeQuery:@"select * from t_collection;"];
        
        while ([rs next]) {
            AICollection *collection = [[AICollection alloc] init];
            collection.owner = [rs stringForColumn:@"owner"];
            collection.sender = [rs stringForColumn:@"sender"];
            collection.circleID = [rs stringForColumn:@"circleID"];
            collection.createDate = [rs stringForColumn:@"create_date"];
            collection.message = [rs stringForColumn:@"message"];
            collection.sourceType = [rs intForColumn:@"source"];
            collection.messageType = [rs intForColumn:@"message_type"];
            collection.serviceId = [rs stringForColumn:@"store_id"];
            
            [collections addObject:collection];
        }
        
        [rs close];
    }];
    
    [MyFMDatabaseQueue close];
    return collections;
}

@end
