//
//  NewsCRUD.h
//  anbang_ios
//
//  Created by seeko on 14-5-15.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
@interface NewsCRUD : NSObject
+(void)creatNews;
+(void)insert:(NSString *)username readMark:(int)mark;
+(void)updata:(int) mark userName:(NSString *)username;
+(NSInteger)quearReadMark:(NSString *)username;
@end
