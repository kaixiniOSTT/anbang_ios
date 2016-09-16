//
//  ChatMessage.h
//  anbang_ios
//
//  Created by silenceSky  on 14-4-14.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface ChatMessageCRUD : NSObject

+ (void)createChatMessage;

//写入聊天纪录
+ (void)insertChatMessage:(NSString *)senderUserName msg:(NSString *)message receiveUser:(NSString *)receiveUser msgType:(NSString*)msgType subject:(NSString*)subjectStr sendTime:(NSString*)sendTime receiveTime:(NSString*)receiveTime readMark:(int)readMark sendStatus:(NSString *)sendStatus msgRandomId:(NSString *)msgRandomId myJID:(NSString *)myJID;

+ (void)ErrorReport: (NSString *)item;

+ (int)queryCountByUserName:(NSString *)userName chatWithUser:(NSString *)chatWithUser;

+ (NSString*)queryIdByUserName:(NSString *)userName chatWithUser:(NSString *)chatWithUser;

+ (int)queryCountUnread:(NSString *)userName chatWithUser:(NSString *)chatWithUser;

//查询某条消息
+ (NSString*)queryMsgByMsgId:(int)msgId;
+ (NSDictionary *)queryMessageWithRandomId:(NSString *)aRandomId;
//查询某条消息，返回消息发送人
+ (NSString*)querySenderByMsgId:(int)msgId;

+ (void)deleteChatMessage:(NSString *)msgId;

+ (void)updateFlagByUserName:(NSString *)chatWithUser userName:(NSString *)userName;

//更新消息状态（主要用于voip)
+ (void)updateMsgByMsgRandomId:(NSString *)msgRandomId msg:(NSString *)msg;

//更新消息发送状态（消息回执)
+ (void)updateMsgByMsgReceipt:(NSString *)msgId sendStatus:(NSString *)sendStatus;

+(void)deleteAllChatMessage:(NSString *)myUserName;
//delete table
+ (void)deleteChatMessageByRandomId:(NSString *)msgRandomId;

//删除与某个联系的聊天纪录
+(void)deleteChatWithUserMessage:(NSString *)myUserName chatWithUserName:(NSString *)chatWithUserName;

+(void)dropTable;

//查询通话记录
+(NSMutableArray *)selectChatMessageCallRecords;
//+(NSMutableArray *)selectChatMessageSendUser:(NSString *)sendUser receiveUser:(NSString *)receiveUser subject:(NSString *)subject;

//所有图片
+(NSMutableArray *)queryChatPictureMessage:(NSString *)chatWithUser;

//返回消息id
+(NSString *)queryMessageId:(NSString *)chatWithUser;

//清除所有消息(fmdb)
+ (void)deleteChatWithUserMessage2:(NSString *)myUserName chatWithUserName:(NSString *)chatWithUserName;

+ (NSString *)querySendTimeWithRandomId:(NSString *)aRandomId;

//查询消息的读过标志
+(int)queryMessageReadMarkByMsgId:(NSString*)msgId;

//更新消息读过标志
+(void)updateMessageReadMark:(NSString *)msgId readMark:(int)readMark;

+ (void) setSendingMessagesFailed;

//更新消息发送时间
+(void)updateMessage:(NSString*)msgId  sendTime:(NSString *)UTCSendTimeStr;

//是否重复消息
+(BOOL)isReplicatedMessage:(NSString*)msgRandomId;

@end
