//
//  MobileAddressBookCRUD.h
//  anbang_ios
//
//  Created by seeko on 14-5-26.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
@interface MobileAddressBookCRUD : NSObject
+(void)creatMobileAddressBookTable;
+(void)insertMobileAddressBookkName:(NSString *)name phoneNum:(NSString *)PhoneNum;

+(BOOL)detectiontMobileAddressBookkName:(NSString *)name phoneNum:(NSString *)PhoneNum;
@end
