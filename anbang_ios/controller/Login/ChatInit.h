//
//  ChatInit.h
//  anbang_ios
//
//  Created by silenceSky  on 14-4-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "ASIHTTPRequestDelegate.h"

@interface ChatInit : NSObject<ASIHTTPRequestDelegate>

//设置通知中心，接收聊天消息。
+ (void)RegisterMsgNotificationCenter;

//设置通知中心,接收网络电话视频结束信息。
+ (void)phoneAndVideoEndNotificationCenter;

//设置通知中心，接收userInfo数据；
+ (void)receivedUserInfoNotificationCenter;

//设置通知中心,接收联系人信息；
+ (void)receivedContactsNotificationCenter;

//设置通知中心，接收圈子数据；
+ (void)receivedGroupNotificationCenter;

//设置通知中心，接收圈子成员数据；
+(void)receivedGroupMembersNotificationCenter;

//设置通知中心，保存 userInfo 版本号；
+(void)receivedUserInfoVersion;

//设置通知中心，保存 groupMembers 版本号；
+(void)receivedGroupMembersVersion;

//设置通知中心，切换帐号时，需注销的操作
+ (void)receivedLogout;

//设置通知中心，二维码扫瞄结果
+(void)receivedScanResult;

//设置通知中心，App更新提示
+(void)receivedAppUpdateNotificationCenter;

//设置通知中心，App更新处理
+(void)receivedAppUpdateResult;

//设置通知中心，添加好友时刷新；
+(void)receivedAddFriendResult;


//设置通知中心,确定消息已发出；
+(void)receivedMsgReceipt;

//推送通知
+(void)initRemoteNotifications;

//重新发生token
+(void)resendToken;

//**********************************
//个人信息
+(void)sendIQInformationList;

//查询群组，查可接收群组消息
+ (void)queryRoom;

//查询所有订阅用户信息
+ (void)queryUserInfo;
+(void)queryUserInfoWithJid:(NSString *)jid;

// Get New Friends Requests
+ (void)getNewFriendsList;

//查询好友用户信息
+ (void)queryRoster;

+ (void)getServersUrl;


// method 添加好友第一步查询好友信息并写入本地数据库
+(void)queryContactsUserInfo:(NSString *)jid;
+(void)addContactsSecondStep:(NSNotification*)notify;
// method 添加好友第二步建立订阅关系
+(void)addContactsByUserName:(NSString *)jid;

//查询最新的Dnd信息
+(void)queryDndInfo;

//获取token
+(void)getToKenInfo;
@end
