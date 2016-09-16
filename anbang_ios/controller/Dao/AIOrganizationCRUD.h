//
//  AIOrganizationCRUD.h
//  anbang_ios
//
//  Created by rooter on 15-5-12.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIOrganization;

@interface AIOrganizationCRUD : NSObject

+ (void)prepareDataToSandBox;

+ (BOOL)addOrganization:(AIOrganization *)organization;
+ (BOOL)addOrganizations:(NSArray *)organizations;

+ (void)deleteOrganizations:(NSArray *)organizations;

// 主体
+ (NSArray *)queryBooks;
// 机构
+ (NSArray *)queryAgencysWithBookCode:(NSString *)code;
// 部门
+ (NSArray *)querybranchsWithAgencyCode:(NSString *)code;

@end
