//
//  AIAreaCRUD.m
//  anbang_ios
//
//  Created by rooter on 15-7-10.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIAreaCRUD.h"
#import "FMDatabaseQueue.h"

static FMDatabaseQueue *queue = nil;

@implementation AIArea

@end

@implementation AIAreaCRUD

+ (FMDatabaseQueue *) queue {
    if (!queue) {
        queue = [[FMDatabaseQueue alloc] initWithPath:[self databasePath]];
    }
    return queue;
}

+ (NSString *)databasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:@"ABArea.db"];
}

+ (void) prepareDatabaseInSandBox
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSArray *paths = [bundle pathsForResourcesOfType:@"db" inDirectory:@"ABArea"];
    NSString *pre = paths[0];
    
    NSString *destiny = [self databasePath];
//    if (![manager fileExistsAtPath:destiny]) {
    [manager removeItemAtPath:destiny error:nil];
        [manager copyItemAtPath:pre toPath:destiny error:nil];
//    }
}

+ (NSArray *) selectWithpcode:(NSString *)pcode {
    __block NSMutableArray *targets = [NSMutableArray array];
    FMDatabaseQueue *queue = [self queue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select name, code from area where pcode = ?", pcode];
        while ([rs next]) {
            AIArea *area = [AIArea new];
            area.code = [rs stringForColumn:@"code"];
            area.name = [rs stringForColumn:@"name"];
            [targets addObject:area];
        }
        [rs close];
    }];
    return targets;
}

+ (NSArray *) provinces {
    return [self selectWithpcode:@"0"];
}

+ (NSArray *) citiesWithpcode:(NSString *)pcode {
    return [self selectWithpcode:pcode];
}

+ (NSArray *) areas {
    NSArray *provinces = [self provinces];
    for (AIArea *province in provinces) {
        province.subareas = [self citiesWithpcode:province.code];
    }
    return provinces;
}

+ (AIArea *) selectAreaWithCode:(NSString *)code {
    __block AIArea *area = [[AIArea alloc] init];
    FMDatabaseQueue *queue = [self queue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select name, pcode from area where code = ?", code];
        while ([rs next]) {
            area.pcode = [rs stringForColumn:@"pcode"];
            area.name  = [rs stringForColumn:@"name"];
        }
        [rs close];
    }];
    return area;
}

+ (NSString *) selectNameForShowWithCode:(NSString *)code {
    if (!code || [code isEqualToString:@"0"]) {
        return nil;
    }
    
    NSMutableString *name = [NSMutableString string];
    AIArea *aArea = [self selectAreaWithCode:code];
    if (!aArea.name) {
        return nil;
    }
    
    if (![aArea.pcode isEqualToString:@"0"]) {
        AIArea *parentArea = [self selectAreaWithCode:aArea.pcode];
        [name appendString:parentArea.name];
        [name appendString:@" "];
        [name appendString:aArea.name];
    }
    
    return name;
}

@end
