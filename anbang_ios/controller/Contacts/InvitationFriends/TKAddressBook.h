//
//  TKAddressBook.h
//  anbang_ios
//
//  Created by seeko on 14-4-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKAddressBook : NSObject
{
    NSInteger sectionNumber;
    NSInteger recordID;
    NSString *name;
    NSString *email;
    NSString *tel;
    NSString *jid;
    NSString *sortKey;
    NSString *string;
    NSString *pinYin;
    NSString *avatar;
    NSString *nickname;
    NSString *remarkName;
    NSInteger accountType;
    NSInteger gender;
    BOOL registered;
    BOOL isMyFriend;
}
@property NSInteger sectionNumber;
@property NSInteger recordID;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *tel;
@property (nonatomic, retain) NSString *jid;
@property (nonatomic, retain) NSString *sortKey;
@property (nonatomic, retain) NSString *string;
@property (nonatomic, retain) NSString *pinYin;
@property (nonatomic, retain) NSString *avatar;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *remarkName;
@property NSInteger accountType;
@property NSInteger gender;
@property (nonatomic, assign) BOOL registered;
@property (nonatomic, assign) BOOL isMyFriend;
@end
