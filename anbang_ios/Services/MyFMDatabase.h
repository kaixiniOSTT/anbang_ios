//
//  MyFMDatabase.h
//  anbang_ios
//
//  Created by silenceSky  on 14-6-9.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
@interface MyFMDatabase : NSObject

+(FMDatabase *)getSharedInstance;
@end

