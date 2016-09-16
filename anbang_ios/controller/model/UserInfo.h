//
//  UserInfo.h
//  anbang_ios
//
//  Created by silenceSky  on 14-6-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject <NSCoding>

@property (copy,nonatomic)    NSString          *jid;
@property (copy, nonatomic)   NSString          *remarkName;
@property (copy, nonatomic)   NSString          *nickName;
@property (copy, nonatomic)   NSString          *phone;
@property (copy, nonatomic)   NSString          *avatar;
@property (copy, nonatomic)   NSString          *addTime;
@property (copy, nonatomic)     NSString        *name;
@property (copy, nonatomic)     NSString        *userName;     //用户标识
@property (assign, nonatomic)   int               accountType;
@property (copy, nonatomic)     NSString        *employeeName;
@property (copy, nonatomic)     NSString        *employeeCode;


@property (copy, nonatomic)   NSString          *bookName;
@property (copy, nonatomic)   NSString          *agencyName;
@property (copy, nonatomic)    NSString        *branchName;
@property (copy, nonatomic)   NSString          *centerName;
@property (copy, nonatomic)   NSString        *departmentName;

@property (strong, nonatomic)     NSString        *accountName;  //BB id

@property (assign, nonatomic)       int           myGender;
@property (assign, nonatomic)       int           gender;
@property (copy, nonatomic)     NSString        *areaId;
@property (copy, nonatomic)     NSString        *inviteUrl;
@property (copy, nonatomic)     NSString        *email;
@property (copy, nonatomic)     NSString        *emailActivate;
@property (copy, nonatomic)     NSString        *secondEmail;
@property (copy, nonatomic)     NSString        *secondEmailActivate;
@property (copy, nonatomic)     NSString        *signature;
@property (copy, nonatomic)     NSString        *employeePhone;
@property (copy, nonatomic)     NSString        *publicPhone;
@property (copy, nonatomic)     NSString        *officalPhone;

@property (strong, nonatomic)     NSString        *soure;

+ (UserInfo *)loadArchive;
- (void)save;

+ (void)clearCache;

@end
