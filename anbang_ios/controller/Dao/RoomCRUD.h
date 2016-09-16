//
//  RoomCRUD.h
//  Icircall_ios
//
//  Created by silenceSky  on 14-3-26.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "ChatRoom.h"


@interface RoomCRUD : NSObject{
    
    
}
@property(nonatomic,retain) NSMutableArray *onlineUsers;


+ (void)openDataBase;

+ (void)createChatRoomTable;

+ (void)insertChatRoomTable:(NSString *)jid name:(NSString *)name creator:(NSString *)creator room:(NSString *)room myJID:(NSString *)myJID createDate:(NSString *)createDate modificationDate:(NSString *)modificationDate;

+ (int)queryChatRoomTableCountId:(NSString *)jid myJID:(NSString *)myJID;

+ (void)updateChatRoomTable:(NSString *)jid name:(NSString *)name myJID:(NSString *)myJID;

+(ChatRoom *)queryChatRoomByJID:(NSString *)jid myJID:(NSString *)myJID;

+(NSMutableArray *)queryAllChatRoomByMyJID:(NSString *)myJID;

+ (void)deleteMyGroup:(NSString *)groupJID myJID:(NSString *)myJID;

+ (void)dropChatRoomTable;

+ (void)closeDataBase;
@end
