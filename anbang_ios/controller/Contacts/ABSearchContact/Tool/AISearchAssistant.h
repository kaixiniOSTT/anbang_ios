//
//  AISearchAssistant.h
//  anbang_ios
//
//  Created by rooter on 15-5-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AIOrganizationLavel) {
    AIOrganizationLavelBook = 1,
    AIOrganizationLavelAgency,
    AIOrganizationLavelBranch
};

@interface AISearchAssistant : NSObject

@property (copy, nonatomic) NSString *selectedBook;
@property (copy, nonatomic) NSString *selectedAgency;
@property (copy, nonatomic) NSString *selectedBranch;
@property (copy, nonatomic) NSString *searchKey;
@property (copy, nonatomic) NSString *after;

@property (assign, nonatomic) AIOrganizationLavel lavel;

- (void)sendSearchIQ;
- (BOOL)canSendSearchIQ;
- (void)sendABContactInfoIQ:(NSString *)userName;

- (BOOL)canGoForward;
- (BOOL)canGoback;
- (void)goBack:(void(^)(NSInteger lever))block;

@end
