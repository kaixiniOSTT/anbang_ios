//
//  GroupChatMessageCRUD.h
//  anbang_ios
//
//  Created by silenceSky  on 14-4-11.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface GroupChatMessageCRUD : NSObject

+ (void)createGroupChatMessageTable;

//目前表设计为，后进来群组的也可以看到进群组之前的消息
+ (void)insertGroupChatMessage:(NSString *)groupMucId sendUser:(NSString *)userName msg:(NSString *)message type:(NSString *)type  msgType:(NSString*)msgType sendTime:(NSString*)sendTime receiveTime:(NSString*)receiveTime  readMark:(int)readMark sendStatus:(NSString *)sendStatus msgRandomId:(NSString *)msgRandomId myJID:(NSString *)myJID;

//目前表设计为，后进来群组的也可以看到进群组之前的消息(fmdb 多线程)
+ (void)insertGroupChatMessageMultithread:(NSString *)groupMucId sendUser:(NSString *)userName msg:(NSString *)message type:(NSString *)type  msgType:(NSString*)msgType sendTime:(NSString*)sendTime receiveTime:(NSString*)receiveTime  readMark:(int)readMark sendStatus:(NSString *)sendStatus msgRandomId:(NSString *)msgRandomId myJID:(NSString *)myJID;

+(int)queryGroupChatMessageCount:(NSString *)room;

+ (int)queryGroupCountUnreadMsg:(NSString *)room;
//查询当前数据ID(自己是发送者）
+ (NSString*)queryMsgIdByUserName:(NSString *)userName chatWithGroup:(NSString *)chatWithGroup;

//查询某条消息
+ (NSString*)queryMsgByMsgId:(int)msgId;
+ (NSDictionary *)messageWithRandomId:(NSString *)aRandomId;

//查询某条消息，返回消息发送人
+ (NSString*)querySenderByMsgId:(int)msgId;
//更新消息状态
+(void)updateGroupChatMessage:(NSString *)groupMucId;
+(void)updateMessageReadMark:(NSString *)msgId readMark:(int)readMark;

//更新消息发送状态（消息回执)
+ (void)updateMsgByMsgReceipt:(NSString *)msgRandomId sendStatus:(NSString *)sendStatus;

//根据msgId 删除消息
+ (void)deleteMyGroupChatMsg:(NSString *)msgId;


//根据groupMucId 删除消息
+ (void)deleteMyGroupChatMsgByGroupMucId:(NSString *)groupMucId;

+ (void)deleteMyGroupChatMsgByGroupMucId2:(NSString *)groupMucId;

//更新消息内容
+(void)updateGroupChatMsgStr:(NSString *)msgRandomId msg:(NSString *)msgStr groupMucId:(NSString *)groupMucId;

//所有图片
+(NSMutableArray *)queryGroupChatPictureMessage:(NSString *)groupMucId;

+(int)queryMessageReadMarkByMsgId:(NSString*)msgId;


+(void)ErrorReport: (NSString *)item;

//根据myjid 删除消息
+ (void)deleteAllGroupChatWithMyJid:(NSString*) myjid;

+ (void)setSendingMessagesFailed;

+(void)updateMessage:(NSString*)msgId  sendTime:(NSString *)UTCSendTimeStr;

+(BOOL)isReplicatedMessage:(NSString*)msgRandomId;

@end
