//
//  AIOrganizationCRUD.m
//  anbang_ios
//
//  Created by rooter on 15-5-12.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIOrganizationCRUD.h"
#import "AIOrganization.h"
#import "MyFMDatabaseQueue.h"
#import "FMDatabaseQueue.h"
#import "NSString+Chinese.h"

@implementation AIOrganizationCRUD

#pragma mark
#pragma mark private

+ (NSArray *)sort:(NSArray *)organization {
    return [organization sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        AIOrganization *or_01 = (AIOrganization *)obj1;
        AIOrganization *or_02 = (AIOrganization *)obj2;
        
        NSString *format_01 = [or_01.name getPrenameAbbreviation];
        NSString *format_02 = [or_02.name getPrenameAbbreviation];
        
        NSComparisonResult ret = [format_01 compare:format_02];
        return ret == NSOrderedDescending;
    }]; //sort
}

+ (NSString *)databasePath
{
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [documents stringByAppendingPathComponent:@"ABOrganization.db"];
}

#pragma end



+ (BOOL)addOrganization:(AIOrganization *)aOrganization
{
    __block BOOL isSuccess = NO;
    FMDatabaseQueue *queue = [[FMDatabaseQueue alloc] initWithPath:[self databasePath]];
    [queue inDatabase:^(FMDatabase *db) {
       isSuccess = [db executeUpdate:@"replace into organization (name, code, parent_code, id, pinyin) values (?, ?, ?, ?, ?);",
         aOrganization.name, aOrganization.code, aOrganization.parentCode, aOrganization.indexId, aOrganization.pinyin];
    }];
    return isSuccess;
}

+ (BOOL)addOrganizations:(NSArray *)organizations
{
    BOOL isSuccess = NO;
    for (AIOrganization *organization in organizations) {
        isSuccess = [self addOrganization:organization];
        if (!isSuccess) {
            break;
        }
    }
    return isSuccess;
}

+ (NSArray *)queryBooks
{
    NSArray *books = [self queryOrganizationsWithParentCode:@"null"];
//    return [self sort:books];
    return books;
}

+ (NSArray *)queryAgencysWithBookCode:(NSString *)code
{
    NSArray *agency = [self queryOrganizationsWithParentCode:code];
//    return [self sort:agency];
    return agency;
}

+ (NSArray *)querybranchsWithAgencyCode:(NSString *)code
{
    NSArray *branch = [self queryOrganizationsWithParentCode:code];
//    return [self sort:branch];
    return branch;
}

+ (NSArray *)queryOrganizationsWithParentCode:(NSString *)code
{
    FMDatabaseQueue *queue = [[FMDatabaseQueue alloc] initWithPath:[self databasePath]];
    __block NSMutableArray *organizations = nil;
    
    [queue inDatabase:^(FMDatabase *db) {
        
        organizations = [NSMutableArray array];
        
        FMResultSet *rs = nil;
        rs = [db executeQuery:@"select * from organization where parent_code = ? order by pinyin;", code];
        
        while ([rs next]) {
            AIOrganization *organizaiton = [[AIOrganization alloc] init];
            organizaiton.name = [rs stringForColumn:@"name"];
            organizaiton.code = [rs stringForColumn:@"code"];
            [organizations addObject:organizaiton];
        }
        [rs close];
    }];
    [queue close];
    
    return organizations;
}

+ (void)deleteOrganizations:(NSArray *)organizations
{
    for (AIOrganization *organization in organizations) {
        [self deleteOrganization:organization];
    }
}

+ (void)deleteOrganization:(AIOrganization *)organization
{
    FMDatabaseQueue *queue = [[FMDatabaseQueue alloc] initWithPath:[self databasePath]];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"delete from organization where id = ?", organization.indexId];
    }];
    [queue close];
}

+ (void)prepareDataToSandBox
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSArray *paths = [bundle pathsForResourcesOfType:@"db" inDirectory:@"ABOrganization"];
    NSString *pre = paths[0];
    NSString *fileName = [[pre lastPathComponent] componentsSeparatedByString:@"."][0];
    long long timesp = [fileName longLongValue];
    
    NSString *str_ver = [defaluts objectForKey:kOrganization_Contact_Ver];
    str_ver = str_ver ? str_ver : @"0";
    long long ver = [str_ver longLongValue];
    
    JLLog_I(@"filename=%@, str_ver=%@", fileName, str_ver);
    if(timesp <= ver && [manager fileExistsAtPath:[self databasePath]]) return;
    
    NSString *destiny = [self databasePath];
    [manager removeItemAtPath:destiny error:nil];
    [manager copyItemAtPath:pre toPath:destiny error:nil];
    [defaluts setObject:fileName forKey:kOrganization_Contact_Ver];
}

@end
