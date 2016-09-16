//
//  SqliteCRUD.m
//  anbang_ios
//
//  Created by silenceSky  on 14-3-25.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "ChatBuddyCRUD.h"
#import "Utility.h"
#import "PublicCURD.h"
#import "UserInfoCRUD.h"
#import "GroupCRUD.h"
#import "DndInfoCRUD.h"
#import "AIUsersUtility.h"

@implementation ChatBuddyCRUD
sqlite3 *database;
FMDatabase *db;
//聊天列表数据库操作
+(void)createChatBuddyTable
{
    //[self openDataBase];
    char *errorMsg;
    // NSString *createSqlStr=@"create table if not exists ChatBuddy (id integer primary key autoincrement, jid varchar(50), name varchar(50),nickName varchar(50),avatar varchar, phone varchar(15),myJID varchar(15),addTime varchar(20)";
    
    const char *createSql="create table if not exists ChatBuddy (chatUserName varchar(20), name varchar(50),nickName varchar(50),avatar varchar, phone varchar(15),myUserName varchar(20),type varchar(20),lastMsg text,msgType varchar(20),msgSubject varchar(20),lastMsgTime varchar(20), addTime varchar(20),primary key(chatUserName,myUserName,type))";
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"ChatBuddy create ok.");
    }
    else
    {
        NSLog( @"can not create ChatBuddy" );
       // [self ErrorReport:(NSString *)createSql];
    }
}

//写入 chatBuddy
+ (void)insertChatBuddyTable:(NSString *)chatUserName jid:(NSString *)jid name:(NSString *)name nickName:(NSString *)nickName phone:(NSString *)phone avatar:(NSString *)avatar myUserName:(NSString *)myUserName type:(NSString *)type lastMsg:(NSString *)lastMsg msgType:(NSString *)msgType msgSubject:(NSString *)msgSubject lastMsgTime:(NSString *)lastMsgTime tag:(NSString *)tag
{
    
    NSString *addTime = [Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *insertSqlStr = @"replace into ChatBuddy (chatUserName,jid,name,nickName,phone,avatar,myUserName,type,lastMsg,msgType,msgSubject,lastMsgTime,addTime,tag) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    
    NSLog(@"%@",insertSqlStr);
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        if (![db executeUpdate:insertSqlStr,chatUserName,jid,name, nickName,phone,avatar,myUserName,type,lastMsg,msgType,msgSubject,lastMsgTime, addTime,tag]) {
            NSLog(@"error when replace ChatBuddy");
        } else {
            NSLog(@"success to replace ChatBuddy");
        }
    }
    [db close];
}


//查询此联系人是否存在
+ (int)queryChatBuddyTableCountId:(NSString *)chatUserName myUserName:(NSString *)myUserName
{
    int count = 0;
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr= @"select count(*) from ChatBuddy where  chatUserName=? and myUserName=? ";
        
        
        FMResultSet * rs = [db executeQuery:selectSqlStr,chatUserName,myUserName];
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
            
        }
        [rs close];
    }
    [db close];
    
    return count;
}




//更新聊天历史列表，不更新头像和电话(fmdb)
+ (void)updateChatBuddy:(NSString *)chatUserName name:(NSString *)name nickName:(NSString *)nickName lastMsg:(NSString *)lastMsg msgType:(NSString *)msgType msgSubject:(NSString *)msgSubject lastMsgTime:(NSString *)lastMsgTime
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    

    /**
     *  当ChatBuddy表中已经有记录的时候，群聊和单聊发消息都用到了这个方法来更新表中的数据；
     *
     */
    
    NSString *jid = nil;
    if ([msgType isEqualToString:@"chat"]) {
        jid = [NSString stringWithFormat:@"%@@%@", chatUserName, OpenFireHostName];
    }else if([msgType isEqualToString:@"groupchat"]){
        NSString *userName = [chatUserName componentsSeparatedByString:@"@"][0];
        jid = [NSString stringWithFormat:@"%@@%@", userName, GroupDomain];
    }
    NSString *tempName = name?[NSString stringWithFormat:@"'%@'", name]:@"name";
    NSString *tempLastMsgTime= lastMsgTime?[NSString stringWithFormat:@"'%@'", lastMsgTime]:@"lastMsgTime";
    
    if ([db open]) {
        NSString *updateSqlStr = [NSString stringWithFormat:@" UPDATE ChatBuddy SET jid=?, name = %@, nickName = ?,lastMsg = ?,msgType = ?,msgSubject = ?,lastMsgTime = %@ WHERE chatUserName=?", tempName, tempLastMsgTime];
        
//        NSLog(@"****%@",updateSqlStr);
        if (![db executeUpdate:updateSqlStr,jid,nickName,lastMsg,msgType,msgSubject, chatUserName
              ]) {
            NSLog(@"error when update ChatBuddy ");
        } else {
            JLLog_I(@"success to update ChatBuddy");
        }
    }
    [db close];
}


//通用(fmdb)
+ (void)updateCommonChatBuddy:(NSString *)fieldStr value:(NSString *)str
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE ChatBuddy SET \"%@\" = \"%@\"",fieldStr,str
                                ];
        if (![db executeUpdate:updateSqlStr]) {
            JLLog_I(@"error when update ChatBuddy ");
            
        } else {
            JLLog_I(@"success to update ChatBuddy");
        }
    }
    [db close];
}



//更新聊天历史列表，需更新头像和电话
+ (void)updateChatBuddyTwo:(NSString *)chatUserName name:(NSString *)name nickName:(NSString *)nickName phone:(NSString *)phone avatar:(NSString *)avatar lastMsg:(NSString *)lastMsg msgType:(NSString *)msgType msgSubject:(NSString *)msgSubject lastMsgTime:(NSString *)lastMsgTime
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        NSString *updateSqlStr= @" UPDATE ChatBuddy SET name = ?,nickName = ?,phone = ?,avatar = ?,lastMsg = ?,msgType = ?,msgSubject = ?,lastMsgTime = ? WHERE chatUserName=?";
        
        if (![db executeUpdate:updateSqlStr,name,nickName,phone,avatar, lastMsg,msgType,msgSubject,lastMsgTime, chatUserName
              ]) {
            NSLog(@"error when update ChatBuddy ");
            
        } else {
            JLLog_I(@"success to update ChatBuddy");
        }
    }
    
    [db close];
}




//删除聊天好友
//+ (void)deleteChatBuddyByChatUserName:(NSString *)chatUserName myUserName:(NSString *)myUserName{
//    char *errorMsg;
//    NSString *deleteSqlStr=[NSString stringWithFormat:@"DELETE FROM ChatBuddy where chatUserName=\"%@\" and myUserName=\"%@\"",chatUserName,myUserName];
//    const char *deleteSql = [deleteSqlStr UTF8String];
//
//    if (sqlite3_exec(database, deleteSql, NULL, NULL, &errorMsg)==SQLITE_OK)
//    {
//        NSLog(@"delete ok.");
//    }
//    else
//    {
//        NSLog( @"can not delete it" );
//        [self ErrorReport: (NSString *)deleteSqlStr];
//    }
//}



//删除聊天好友(fmdb)
+ (void)deleteChatBuddyByChatUserName:(NSString *)chatUserName myUserName:(NSString *)myUserName{
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    
    if ([db open]) {
        NSString *deleteSqlStr= @"DELETE FROM ChatBuddy where chatUserName=? and myUserName=?";
        
        
        NSString *sqlStrChatMsg1 =  @"DELETE FROM ChatMessage where (sendUser=? and receiveUser=?) or (sendUser=? and receiveUser=?) and myJID=?";
        
        
        NSString *sqlStrGroupChatMsg = @"DELETE FROM GroupChatMessage where groupMucId=? and myJID=?";
        
        //NSString *sqlStrSysMsg = @"DELETE FROM SystemMessageTable where myUserName=?";
        
        
        
        if (![db executeUpdate:deleteSqlStr,chatUserName,myUserName]) {
            NSLog(@"error when delete ChatBuddy ");
            
        } else {
            NSLog(@"success to delete ChatBuddy");
        }
        
        if (![db executeUpdate:sqlStrChatMsg1,chatUserName,myUserName,myUserName,chatUserName,MY_JID]) {
            NSLog(@"error when delete ChatMessage ");
            
        } else {
            NSLog(@"success to delete ChatMessage");
        }
        
        if (![db executeUpdate:sqlStrGroupChatMsg,chatUserName,MY_JID]) {
            NSLog(@"error when delete GroupChatMessage ");
            
        } else {
            NSLog(@"success to delete GroupChatMessage");
        }
//        if (![db executeUpdate:sqlStrSysMsg,myUserName]) {
//            NSLog(@"error when delete SystemMessageTable ");
//            
//        } else {
//            NSLog(@"success to delete SystemMessageTable");
//        }
        
    }
    [db close];
}


+(void)dropBuddyListTable
{
    [PublicCURD openDataBaseSQLite];
    char *errorMsg;
    //[self openDataBase];
    NSString *sqlStr = @"DROP TABLE ChatBuddy";
    const char *sql = "DROP TABLE BuddyList";
    if (sqlite3_exec(database, sql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"drop ok.");
    }
    else
    {
        NSLog( @"can not drop it" );
        [self ErrorReport: (NSString *)sqlStr];
    }
    [PublicCURD closeDataBaseSQLite];
}


+(Contacts *)queryBuddyByJID:(NSString *)jid myJID:(NSString *)myJID
{
    
    [PublicCURD openDataBaseSQLite];
    
    Contacts * contacts = [[Contacts alloc]init];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select c.jid,c.remarkName,u.nickName,u.phone,u.avatar,c.addTime from Contacts c,UserInfo u where c.jid=u.jid and c.jid=\"%@\" and c.myJID=\"%@\" ",jid,myJID];
    
    NSLog(@"###############%@",selectSqlStr);
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    
    
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            
            NSString *jid=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            
            NSString *remarkName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            
            NSString *nickName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            
            NSString *phone=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            
            NSString *avatar=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            
            // NSString *addTime=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            
            NSLog(@"%@,%@,%@",nickName,phone,avatar);
            
            contacts.jid = jid;
            contacts.remarkName = remarkName;
            contacts.nickName = nickName;
            contacts.phone = phone;
            contacts.avatar = avatar;
            
        }
    }
    [PublicCURD closeDataBaseSQLite];
    return contacts;
}


//来消息时查询用户信息，在UserInfo表查询
+(Contacts *)queryUserInfoByJID:(NSString *)jid myJID:(NSString *)myJID
{
    
    [PublicCURD openDataBaseSQLite];
    
    Contacts * contacts = [[Contacts alloc]init];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select jid,remarkName,nickName,phone,avatar,addTime from UserInfo u where  jid=\"%@\" and myJID=\"%@\" ",jid,myJID];
    
    NSLog(@"###############%@",selectSqlStr);
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    
    
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            
            NSString *jid=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            
            NSString *remarkName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            
            NSString *nickName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            
            NSString *phone=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            
            NSString *avatar=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            
            // NSString *addTime=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            
            // NSLog(@"%@,%@,%@",nickName,phone,avatar);
            
            contacts.jid = jid;
            contacts.remarkName = remarkName;
            contacts.nickName = nickName;
            contacts.phone = phone;
            contacts.avatar = avatar;
            
        }
    }
    
    [PublicCURD closeDataBaseSQLite];
    return contacts;
}





//获取聊天列表
+(NSMutableArray *)queryChatContactsList2:(NSString *)userName{
    
    [PublicCURD openDataBaseSQLite];
    
    NSMutableArray *chatContactsArray = [[NSMutableArray alloc]init];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select chatUserName,name,nickName,phone,avatar,type,lastMsg,addTime from ChatBuddy where myUserName = \"%@\" ORDER BY lastMsgTime DESC ",userName];
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            NSString *userName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            
            NSString *remarkName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            
            NSString *nickName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            
            NSString *phone=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            
            NSString *avatar=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            
            NSString *type=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            
            NSString *lastMsg=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 6) encoding:NSUTF8StringEncoding];
            
            NSString *addTime=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 7) encoding:NSUTF8StringEncoding];
            
            [chatContactsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:userName,@"chatUserName",remarkName, @"name",nickName,@"nickName",phone,@"phone",avatar,@"avatar",type,@"type",lastMsg,@"lastMsg" ,addTime, @"addTime", nil]];
            
        }
    }
    [PublicCURD closeDataBaseSQLite];
    
    return chatContactsArray;
}

//获取聊天列表(fmdb)
+(NSMutableArray *)queryChatContactsList:(NSString *)myUserName
{
    NSMutableArray *chatContactsArray = [[NSMutableArray alloc]init];
    
    //如果是安邦员工，初始化工作台
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        
        if([UserInfo loadArchive].accountType == 2){
            NSMutableDictionary *workbench = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"工作台", @"name",@"system_ab_workbench",@"type",nil];
            
            [chatContactsArray addObject:workbench];
            
            //NSMutableDictionary *anbangMessage = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"安邦消息通知", @"name",@"system_ab_newGuidance",@"type",nil];
            
            //[chatContactsArray addObject:anbangMessage];
        }
        
        FMResultSet * rs = [db executeQuery:@"select cb.jid, cb.chatUserName, cb.name, cb.nickName, cb.phone, ui.avatar, cb.type, cb.lastMsg, cb.lastMsgTime, cb.addTime, cb.tag, case when cg.stickie_time is not null  then cg.stickie_time when ui.stickie_time is not null then ui.stickie_time else '0' end as stickie_time from ChatBuddy cb left join UserInfo ui on cb.jid = ui.jid left join ChatGroup cg on cb.jid = cg.groupJID where cb.myUserName = ? order by stickie_time desc, cb.lastMsgTime desc;", myUserName];
        while ([rs next]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            NSString *jid = [rs stringForColumn:@"jid"];
            
            NSString *chatUserName=[rs stringForColumn:@"chatUserName"];
            
            NSString *remarkName=[StrUtility string:[rs stringForColumn:@"name"] defaultValue:@""];

            NSString *nickName=[StrUtility string:[rs stringForColumn:@"nickName"] defaultValue:@""];
            
            NSString *phone= [StrUtility string:[rs stringForColumn:@"phone"] defaultValue:@""];
            
            NSString *avatar= [StrUtility string:[rs stringForColumn:@"avatar"] defaultValue:@""];
            
            NSString *type= [rs stringForColumn:@"type"];
            
            NSString *lastMsg= [rs stringForColumn:@"lastMsg"];
            
            NSString *lastMsgTime= [rs stringForColumn:@"lastMsgTime"];
            
            NSString *addTime= [rs stringForColumn:@"addTime"];
            
            NSString *tag= [rs stringForColumn:@"tag"];
            
            //            NSString *stickie_time = [rs stringForColumn:@"stickie_time"];
            //            JLLog_I(@"jid=%@, stickie_time=%@", jid, stickie_time);
            
            NSMutableArray *groupMembersArray = [NSMutableArray array];
            if ([type isEqualToString:@"groupchat"]) {
                NSString *groupJID= @"";
                NSString*str_character = @"@";
                NSRange senderRange = [chatUserName rangeOfString:str_character];
                if ([chatUserName rangeOfString:str_character].location != NSNotFound) {
                    groupJID =[NSString stringWithFormat:@"%@@%@",[chatUserName substringToIndex:senderRange.location],GroupDomain];
                }
                
                groupMembersArray = [GroupCRUD queryGroupMembersByGroupJID:groupJID myJID:MY_JID];
                NSString *groupType = [GroupCRUD queryGroupTypeWithJID:groupJID];
                if (groupType) {
                    [dict setObject:groupType forKey:@"groupType"];
                    
                }
            }else if ([type isEqualToString:@"chat"]) {
                remarkName = [AIUsersUtility nameForShowWithJID:jid];
            }
            
            int accountType = [UserInfoCRUD queryUserInfoAccountTypeWith:jid];
            NSNumber *accountTypeNumber = [NSNumber numberWithInt:accountType];
            
            NSDictionary *tmp = [NSMutableDictionary dictionaryWithObjectsAndKeys:jid, @"jid",chatUserName,@"chatUserName",remarkName, @"name",nickName,@"nickName",phone,@"phone",avatar,@"avatar",type,@"type",lastMsg,@"lastMsg",lastMsgTime,@"lastMsgTime" ,addTime, @"addTime", tag, @"tag", groupMembersArray,@"groupMembersArray",accountTypeNumber,@"accountType",[GroupCRUD fetchGroupTempName:groupMembersArray inGroup:jid],@"groupTempName", nil];
            
            [dict setValuesForKeysWithDictionary:tmp];
            
            //            JLLog_D("dict = %@", [dict description]);
            
            if ([dict[@"groupType"] isEqualToString:@"department"]) {
                [chatContactsArray insertObject:dict atIndex:chatContactsArray.count > 0?1:0];
            }else {
                [chatContactsArray addObject:dict];
            }
            
        }
        
        [rs close];
        


    }
    [db close];
    
    return chatContactsArray;
}

//查询多人对话成员，根据userInfo 表 myJID 查询(fmdb)
+(NSMutableArray *)queryMultiplayerTalkMembersAvatarByThread:(NSString *)thread myJID:(NSString *)myJID
{
    NSMutableArray *multiplayerMembers =[[NSMutableArray alloc]init];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select m.jid,u.nickName,u.avatar from MultiplayerTalk m, UserInfo u where m.jid=u.jid and m.threadId=\"%@\"  order by m.jid  desc limit %d,%d ",thread,0,4];
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            NSString *avatar=[rs stringForColumn:@"avatar"];
            [multiplayerMembers addObject:avatar];
        }
        
        [rs close];
    }
    [db close];
    return multiplayerMembers;
}




//查询聊天列表所有未读消息
+ (int)queryAllMsgTotal{
    
    int total = 0;
    int count1 = 0;
    int count2 = 0;
    int count3 = 0;
    int count4 = 0;
    
    NSArray *dndList = [DndInfoCRUD queryDNDList];
    
    NSString *dndStr = @"'0'";
    if(dndList.count > 0){
        dndStr = [NSString stringWithFormat:@"'%@'",[dndList componentsJoinedByString:@"','"]];
    }
    
    NSArray *groupDndList = [DndInfoCRUD queryGroupDNDList];
    
    NSString *groupDndStr = @"'0'";
    if(groupDndList.count > 0){
        groupDndStr = [NSString stringWithFormat:@"'%@'",[groupDndList componentsJoinedByString:@"','"]];
    }
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    JLLog_I(@"queryAllMsgTotal MY_JID=%@",MY_JID);
    
    if ([db open]) {
        NSString *selectGroupMsgSqlStr=[NSString stringWithFormat:@"select count(*) from GroupChatMessage where groupMucId not in (%@) and readMark=%d and myJID =\"%@\" ",groupDndStr,0,MY_JID];
        
        NSString *selectChatMsgSqlStr=[NSString stringWithFormat:@"select count(*) from ChatMessage where sendUser not in (%@) and readMark=%d and receiveUser =\"%@\" ",dndStr,0,MY_USER_NAME];
        
        NSString *selectSystemMessageSqlStr=[NSString stringWithFormat:@"select count(*) from SystemMessageTable where  readMark=%d and myUserName =\"%@\" ",0,MY_USER_NAME];
        
        NSString *selectNewSqlStr=[NSString stringWithFormat:@"select * from News where  userName=\"%@\" ",MY_USER_NAME];
        
        
        for(int i=0;i<4;i++) {
            
            if (i == 0) {
                FMResultSet * rs = [db executeQuery:selectGroupMsgSqlStr];
                while ([rs next]) {
                    count1 = [rs intForColumnIndex:0];
                }
                [rs close];
            }else if(i == 1){
                FMResultSet * rs = [db executeQuery:selectChatMsgSqlStr];
                while ([rs next]) {
                    count2 = [rs intForColumnIndex:0];
                }
                [rs close];
            }else if(i == 2){
                FMResultSet * rs = [db executeQuery:selectSystemMessageSqlStr];
                while ([rs next]) {
                    count3 = [rs intForColumnIndex:0];
                    
                }
                [rs close];
            }else{
                FMResultSet * rs = [db executeQuery:selectNewSqlStr];
                while ([rs next]) {
                    // count4 = [rs intForColumnIndex:0];
                    NSString *strmark=[rs stringForColumn:@"readmark"];
                    count4=[strmark intValue];
                    NSLog(@"********%d",count4);
                    
                }
                [rs close];
            }
            
            
        }
    }
    
    
    [db close];
    total = count1 + count2 +count3 +count4;
    return total;
    
}


//error
+ (void)ErrorReport: (NSString *)item
{
    char *errorMsg;
    
    const char *itemChar = [item UTF8String];
    
    
    if (sqlite3_exec(database, (const char *)itemChar, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"%@ ok.",item);
    }
    else
    {
        NSLog(@"error: %s",errorMsg);
        sqlite3_free(errorMsg);
    }
}

+ (void)updateChatBuddyName:(NSString *)newName chatUserName:(NSString *)chatUserName{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if([db open]){
            NSString *updateSqlStr= @"UPDATE ChatBuddy SET name = ? WHERE chatUserName = ?";

            NSLog(@"***%@",updateSqlStr);

            if ([db executeUpdate:updateSqlStr, newName, chatUserName])
            {
                NSLog(@"update ChatBuddy Name ok.");
            }
            else
            {
                NSLog( @"can not update ChatBuddy Name" );
            }
        
    }
    
    [db close];
}


+ (void)deleteChatBuddy
{
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    if ([db open]) {
        NSString *deleteSqlStr= @"delete from ChatBuddy";
        if (![db executeUpdate:deleteSqlStr]) {
            NSLog(@"error when  delete SqlStr ");
            
        } else {
            NSLog(@"success to  delete SqlStr");
        }
    }
    [db close];
}

+ (NSArray *)incorrectContacts {
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    NSMutableArray *incorrectContacts = nil;
    if ([db open]) {
        incorrectContacts = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:@"select chatUserName, jid from ChatBuddy where jid not in (select jid from UserInfo where jid is not null) and type = 'chat'"];
        while ([rs next]) {
            NSString *chatUserName = [rs stringForColumn:@"chatUserName"];
            NSString *jid = [rs stringForColumn:@"jid"];
            
            chatUserName = chatUserName ? chatUserName : @"";
            jid = jid ? jid : @"";
            
            [incorrectContacts addObject:@{@"userName" : chatUserName, @"jid" : jid}];
        }
    }
    return incorrectContacts;
}


@end
