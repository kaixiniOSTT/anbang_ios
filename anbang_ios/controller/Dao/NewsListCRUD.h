//
//  NewsListCRUD.h
//  anbang_ios
//
//  Created by seeko on 14-5-13.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "News.h"
@interface NewsListCRUD : NSObject
+(void)createNewsList;
+ (void)insertNewsList:(NSString *)type title:(NSString *)title outline:(NSString *)outline imgUrl:(NSString *)imgUrl url:(NSString *)url publishTime:(NSString *)publishTime readMark:(int)mark;
+ (int)queryNewsCountId:(NSString *)chatUserName myUserName:(NSString *)myUserName;
+ (int)queryNewsCountUnread:(NSString *)userName chatWithUser:(NSString *)chatWithUser;
+(void)updataReadMark:(int)mark userName:(NSString *)userName newsName:(NSString *)title;
+(void)deleteTableData:(NSString *)myjid;
+(NSMutableArray *)selectNewsList;
+(News *)querynewsName:(NSString *)username newsName:(NSString *)title;
@end
