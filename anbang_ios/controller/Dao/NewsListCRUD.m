//
//  NewsListCRUD.m
//  anbang_ios
//
//  Created by seeko on 14-5-13.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "NewsListCRUD.h"
#import "PublicCURD.h"


@implementation NewsListCRUD
sqlite3 *database;
FMDatabase *db;
+(void)createNewsList{
    char *errorMsg;
    // NSString *createSqlStr=@"create table if not exists ChatBuddy (id integer primary key autoincrement, jid varchar(50), name varchar(50),nickName varchar(50),avatar varchar, phone varchar(15),myJID varchar(15),addTime varchar(20)";
    
    const char *createSql="create table if not exists NewsList (title varchar(20) primary key,myjid verchar(20),type varchar(10),readMark int DEFAULT 0, outline TEXT,imgUrl varchar(50), url varchar(50),publishTime varchar(20))";
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
//        NSLog(@"NewList create ok.");
    }
    else
    {
//        NSLog( @"can not create ChatBuddy" );
        //[self ErrorReport:(NSString *)createSql];
    }
}
+ (void)insertNewsList:(NSString *)type title:(NSString *)title outline:(NSString *)outline imgUrl:(NSString *)imgUrl url:(NSString *)url publishTime:(NSString *)publishTime readMark:(int)mark{
//    char *errorMsg;
    NSString *myjid=[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    NSString *insertSqlStr=[NSString stringWithFormat:@"insert or replace into NewsList (myjid,type, title,outline,imgUrl,url,publishTime,readMark) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%d\")",myjid,type,title,outline,imgUrl,url,publishTime,mark];
    
    
//    const char *insertSql = [insertSqlStr UTF8String];
    
//    if (sqlite3_exec(database, insertSql, NULL, NULL, &errorMsg)==SQLITE_OK)
//    {
//        NSLog(@"insert ok.");
//    }
//    else
//    {
//        NSLog( @"can not insert it to table" );
//        [self ErrorReport: (NSString *)insertSqlStr];
//    }
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        if (![db executeUpdate:insertSqlStr]) {
            NSLog(@"error when insert  ");
            [self ErrorReport: (NSString *)insertSqlStr];
        } else {
            NSLog(@"success to insert ");
        }
    }
    [db close];

}


+(NSMutableArray *)selectNewsList{
    NSString *myjid=[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    NSString *selectSqlStr=[NSString stringWithFormat:@"select title,outline,imgUrl,url,publishTime from NewsList where myjid=\"%@\" order by publishTime desc",myjid];
    NSMutableArray *maNews=[[NSMutableArray alloc]init];
    NSMutableArray *arrNews=[[NSMutableArray alloc]init];
//    const char *selectSql = [selectSqlStr UTF8String];
//    sqlite3_stmt *statement;
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        FMResultSet * rs = [db executeQuery:selectSqlStr];

        while ([rs next])//SQLITE_OK SQLITE_ROW
        {
            
            //int _id=sqlite3_column_int(statement, 0);
            
            NSString *title=[rs stringForColumn:@"title"];

            
            NSString *outline=[rs stringForColumn:@"outline"];
            
            NSString *imgUrl=[rs stringForColumn:@"imgUrl"];
            
            NSString *url=[rs stringForColumn:@"url"];
            
            NSString *publishTime=[rs stringForColumn:@"publishTime"];
            
            //            NSString *DBYear=[publishTime substringToIndex:4];  //年
            //            NSString *nonDBYear=[publishTime substringFromIndex:5];
            //            NSString *DBMounth=[nonDBYear substringToIndex:2];  //月
            //            NSString *nonDBMounth=[nonDBYear substringFromIndex:3];
            //            NSString *DBDay=[nonDBMounth substringToIndex:2];//日
            //            NSString *nonMA=[nonDBMounth substringFromIndex:2];
            //            NSString *DBMA=[nonMA substringToIndex:1];      //判断上下午
            //            NSString *nonDBDay=[nonDBMounth substringFromIndex:3];
            //            NSString *DBHour=[nonDBDay substringToIndex:2];     //时
            //            NSString *nonDBHour=[nonDBDay substringFromIndex:3];
            //            NSString *DBMinute=[nonDBHour substringToIndex:2];  //分
            //            NSString *nonDBMinute=[nonDBHour substringFromIndex:3];
            //            NSString *DBSecond=[nonDBMinute substringToIndex:2];   //秒
            
            
            [maNews addObject:[NSDictionary dictionaryWithObjectsAndKeys:title,@"title",outline, @"outline",imgUrl,@"imgUrl",url,@"url",publishTime,@"publishTime", nil]];
        }
        
        for (int i=([maNews count]-1); i>(-1); i--) {
            [arrNews addObject:[maNews objectAtIndex:i]];
        }
        [rs close];
    }
    [db close];
    return arrNews;
}


//新闻数量
+ (int)queryNewsCountId:(NSString *)chatUserName myUserName:(NSString *)myUserName{
    [PublicCURD openDataBaseSQLite];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select count(title) from ChatBuddy where  chatUserName=\"%@\" and myUserName=\"%@\" ",chatUserName,myUserName];
    const char *selectSql = [selectSqlStr UTF8String];
    int count = 0;
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {

        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            count = sqlite3_column_int(statement, 0);
        }
        
    }
   
    
    sqlite3_finalize(statement);

    [PublicCURD closeDataBaseSQLite];
    return count;

}


//查询新闻未读消息条数
+ (int)queryNewsCountUnread:(NSString *)userName chatWithUser:(NSString *)chatWithUser
{
    [PublicCURD openDataBaseSQLite];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select count(title) from ChatMessage where sendUser=\"%@\" and receiveUser=\"%@\" and readMark=%d ",chatWithUser,userName,0];
    
    const char *selectSql = [selectSqlStr UTF8String];
    int count = 0;
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
//        NSLog(@"select ok.");
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            count = sqlite3_column_int(statement, 0);
        }
    }
    else
    {
        //error
        [self ErrorReport: (NSString *)selectSqlStr];
    }
    
    [PublicCURD closeDataBaseSQLite];
    
    return count;
}


+(void)updataReadMark:(int)mark userName:(NSString *)userName newsName:(NSString *)title{

    
   
}


+(void)deleteTableData:(NSString *)myjid{
    
    [PublicCURD openDataBaseSQLite];
    
    NSString *deleteSqlStr=[NSString stringWithFormat:@"delete from NewsList where myjid=\"%@\"",myjid];
    const char *deleteSql=[deleteSqlStr UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, deleteSql, -1, &statement, nil)==SQLITE_OK)
    {
//        NSLog(@"delete ok.");
        
    }
    else
    {
        //error
    }
    [PublicCURD closeDataBaseSQLite];
    
}

+(News *)querynewsName:(NSString *)username newsName:(NSString *)title{
    
    [PublicCURD openDataBaseSQLite];
    
    News * news = [[News alloc]init];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select type, title,outline,imgUrl,url,publishTime,readMark from NewsList where title=\"%@\"",title];
    
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    
    
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            // int _id=sqlite3_column_int(statement, 0);
            
//            NSString *type=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            
            NSString *title=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            
            NSString *outline=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            
            NSString *imgUrl=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            
            NSString *url=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            
            NSString *publishTime=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            
            news.title=title;
            news.outline=outline;
            news.imgUrl=imgUrl;
            news.url=url;
            news.publishTime=publishTime;
        
        }
    }
    [PublicCURD closeDataBaseSQLite];
    
    return news;
}
//error
+ (void)ErrorReport: (NSString *)item
{
    char *errorMsg;
    
    const char *itemChar = [item UTF8String];
    
    
    if (sqlite3_exec(database, (const char *)itemChar, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
//        NSLog(@"%@ ok.",item);
    }
    else
    {
//        NSLog(@"error: %s",errorMsg);
        sqlite3_free(errorMsg);
    }
}
@end
