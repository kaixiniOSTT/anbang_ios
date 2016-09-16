//
//  ChatInit.m
//  anbang_ios
//
//  Created by silenceSky  on 14-4-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "ChatInit.h"
#import "Utility.h"
#import "ChatMessageCRUD.h"
#import "ChatBuddyCRUD.h"
#import "GroupChatMessageCRUD.h"
#import "ChatGroup.h"
#import "GroupCRUD.h"
#import "JSONKit.h"
#import "CHAppdelegate.h"
#import "NewsListCRUD.h"
#import "UserNameCRUD.h"
#import "News.h"
#import "NewsCRUD.h"
#import "SystemMessageCRUD.h"
#import "UserInfoCRUD.h"
#import "UserInfo.h"
#import "ContactsCRUD.h"
#import "GroupMembersCRUD.h"
#import "IdGenerator.h"
#import "DejalActivityView.h"
#import "MultiplayerTalkCRUD.h"
#import "MyFMDatabaseQueue.h"
#import "InviteUtil.h"
#import "ASIHTTPRequest.h"
#import "AddContactsResultViewController.h"
#import "CHAppDelegate.h"
#import "MyServices.h"
#import "StrUtility.h"
#import "AIHttpTool.h"
#import "AIUsersUtility.h"
#import "AIPersonalCard.h"
#import "AIDocument.h"
#import "NSString+Chinese.h"

#if !TARGET_IPHONE_SIMULATOR
#import "APPRTCViewController.h"
#endif

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif
@implementation ChatInit


//设置通知中心，接收聊天消息。
+(void)RegisterMsgNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMsgNotfication:)
                                                 name:@"NNC_ChatMessage" object:nil];
}

//设置通知中心,接收网络电话视频结束信息。
+(void)phoneAndVideoEndNotificationCenter
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(voipFinish:) name:@"VOIP_FINISH" object:nil];

}

//设置通知中心，接收userInfo数据；
+(void)receivedUserInfoNotificationCenter
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoReceived:)
                                                 name:@"NNC_Received_UserInfo" object:nil];

}


//设置通知中心,接收联系人信息；
+ (void)receivedContactsNotificationCenter
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedContacts:)
                                                 name:@"NNC_Received_Contacts" object:nil];
}

//设置通知中心，接收圈子数据；
+(void)receivedGroupNotificationCenter
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatGroupReceived:)
                                                 name:@"NNC_Received_Group" object:nil];

    //每次查询
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatGroupReceived2:)
                                                 name:@"NNC_Received_Group2" object:nil];

}

//设置通知中心，接收圈子成员数据；
+(void)receivedGroupMembersNotificationCenter
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupMembersReceived:)
                                                 name:@"NNC_Received_GroupMember" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupMembersReceived2:)
                                                 name:@"NNC_Received_GroupMember2" object:nil];

}


//设置通知中心，保存 userInfo 版本号；
+(void)receivedUserInfoVersion
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveUserInfoVersion)
                                                 name:@"NNC_Received_UserinfoVersion" object:nil];

}


//设置通知中心，保存 groupMembers 版本号；
+(void)receivedGroupMembersVersion
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveGroupMemberVersion)
                                                 name:@"NNC_Received_GroupMembersVersion" object:nil];

}


//设置通知中心，切换帐号时，需注销的操作
+ (void)receivedLogout{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLogout)
                                                 name:@"NNC_Received_Logout" object:nil];

}

//设置通知中心，二维码扫瞄结果
+(void)receivedScanResult{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveScanResult:)
                                                 name:@"NNS_Receive_ScanResult" object:nil];


}

//设置通知中心，App更新提示
+(void)receivedAppUpdateNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveAppUpdateResult:)
                                                 name:@"NNS_App_Update" object:nil];


}

//设置通知中心，添加好友时刷新；
+(void)receivedAddFriendResult{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addContactsSecondStep:)
                                                 name:@"NNC_AddContacts" object:nil];
}



//设置通知中心,确定消息已发出；
+(void)receivedMsgReceipt{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgReceipt:)
                                                 name:@"CNN_Msg_Send" object:nil];
}


- (void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_ChatMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VOIP_FINISH" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Received_UserInfo" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Received_Contacts" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Received_Group" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Received_Group2" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Received_GroupMember" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Received_UserinfoVersion" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Received_Logout" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNS_App_Update" object:nil];
    //[super dealloc];
}



//消息回执
+(void)msgReceipt:(NSNotification*)notify
{
    NSString *msgRandomId = notify.object;
    //[_chatTableView reloadData];
    NSLog(@"*******%@",msgRandomId);
    //[_ylImageview removeFromSuperview];
    NSArray *msgRandomIdArray = [msgRandomId componentsSeparatedByString:@"_"];
    if ([[msgRandomIdArray objectAtIndex:0] isEqualToString:@"chat"]) {
        [ChatMessageCRUD updateMsgByMsgReceipt:[msgRandomIdArray objectAtIndex:1] sendStatus:@"complete"];

    }else if([[msgRandomIdArray objectAtIndex:0] isEqualToString:@"groupchat"]){

        [GroupChatMessageCRUD updateMsgByMsgReceipt:[msgRandomIdArray objectAtIndex:1] sendStatus:@"complete"];


    }else {
        [ChatMessageCRUD updateMsgByMsgReceipt:msgRandomId sendStatus:@"complete"];
        [GroupChatMessageCRUD updateMsgByMsgReceipt:msgRandomId sendStatus:@"complete"];
    }

}




/*---切换帐号时，需注销的操作  start-------------------------------------------------------*/

+(void)receiveLogout{

    //发送注销iq包，服务器注销apns
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/quit"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addChild:queryElement];
    [[XMPPServer xmppStream] sendElement:iq];

    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"contact_version"];

    [[XMPPServer sharedServer]disconnect];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //写入历史登录帐号
    NSString *avatar = [UserInfoCRUD queryUserInfoAvatar:MY_JID];
    [UserNameCRUD insertIDtable:[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"] avatar:avatar myJID: MY_JID];//ID插入数据库

    [defaults setObject:@"login_out" forKey:@"NSUD_LoginStatus"];

    //清除个人信息
    [defaults removeObjectForKey:@"mytoken"];
    [defaults removeObjectForKey:@"password"];
    [defaults removeObjectForKey:@"confirmPassword"];
    [defaults removeObjectForKey:@"oncePassword"];
    [defaults removeObjectForKey:@"name"];
    [defaults removeObjectForKey:@"headImage"];
    [defaults removeObjectForKey:@"email"];
    [defaults removeObjectForKey:@"phone"];

    //清除roster版本号
    [defaults removeObjectForKey:@"Ver_Query_Roster"];
    //清除userInfo 版本号
    [defaults removeObjectForKey:@"Ver_Query_UserInfo"];

    //清除 groupmembers 版本号
    [defaults removeObjectForKey:@"Ver_Query_GroupMembers"];
    
    //清除cookie
    [ASIHTTPRequest setSessionCookies:nil];
    
    [UserInfo clearCache];

    //改变登录状态为注销 loginFlag=4;
    [XMPPServer sharedServer].loginFlag=4;

    //注销voip
    [[NSNotificationCenter defaultCenter]postNotificationName:@"NNC_VOIP_Deactivate" object:nil userInfo:nil];

    [MyFMDatabaseQueue removeFMDatabaseQueue];

    [[NSUserDefaults standardUserDefaults] synchronize];

}

/*---切换帐号时，需注销的操作 end-------------------------------------------------------*/



/*---保存 userInfo 版本号  start-------------------------------------------------------*/

+(void)receiveUserInfoVersion{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:[defaults objectForKey:@"Ver_Temp_UserInfo"] forKey:@"Ver_Query_UserInfo"];

}

/*---保存 userInfo,group 版本号 end-------------------------------------------------------*/



/*---保存 groupmembers 版本号  start-------------------------------------------------------*/

+(void)receiveGroupMemberVersion{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //客户端自定义
    NSString *groupMembersVer = [NSString stringWithFormat:@"%@_%@",@"Ver_GroupMembersComplete",MY_USER_NAME];
    [defaults setObject:groupMembersVer forKey:@"Ver_Query_GroupMembers"];

}

/*---保存 userInfo,group 版本号 end-------------------------------------------------------*/

/*---通知中心接受到消息后，响应该方法  start-------------------------------------------------------*/
+(void)receiveMsgNotfication:(NSNotification*)notify
{
    XMPPMessage *message = [notify.userInfo objectForKey:@"message"];
    NSString *msgRandomId = [[message attributeForName:@"id"] stringValue];
    NSString *msg = [StrUtility string:[[message elementForName:@"body"] stringValue]];
    NSString *type = [StrUtility string:[[message attributeForName:@"type" ]stringValue]];
    NSString *mtype = [StrUtility string:[[message elementForName:@"mtype" ]stringValue]];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    DDXMLElement *delay = [message elementForName:@"delay"];

    NSString *sendUTCTimeStr = [[delay attributeForName:@"stamp"]stringValue];
    NSString *receiveTimeStr = [Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    NSString *receiveUTCTimeStr = [Utility getUTCFormateLocalDate:receiveTimeStr];

    //判断是否有人@你
    BOOL hasAtMe = NO;
    DDXMLElement *at = [message elementForName:@"at"];
    if(at && at.childCount > 0){
        for(DDXMLElement *child in at.children){
            if([MY_JID isEqualToString:[child stringValue]]){
                hasAtMe = YES;
                break;
            }
        }
    }

    //最后消息时间精确到秒，聊天历史列表按此时间排序
    // NSString *lastMsgTime = [[delay attributeForName:@"stamp"]stringValue];
    // NSLog(@"****%@",lastMsgTime);

    NSDate * lastMsgDate = [Utility getNowDateFromatAnDate:[Utility dateFromUtcString:receiveUTCTimeStr]];
    NSString *lastMsgTime = [Utility stringFromDate:lastMsgDate formatStr:@"yyyy-MM-dd HH:mm:ss"];

    NSString*senderName= @"";
    NSString*senderGroupName= @"";
    //**********新闻*************
    DDXMLElement *event=[message elementForName:@"event"];
    DDXMLElement *items=[event elementForName:@"items"];
    DDXMLElement *item=[items elementForName:@"item"];
    DDXMLElement *news=[item elementForName:@"news"];
    if (news!=nil) {
        type=@"news";
    }

    //多人对话
    NSString *subject = @"";
    NSString *thread=[[message elementForName:@"thread"]stringValue];
    if (thread!=nil) {
        type=@"multichat";
        subject = [[message elementForName:@"subject"]stringValue];
    }

    //  NSString *title=[[news attributeForName:@"title"] stringValue]; //新闻标题
    //  NSString *outline=[[news attributeForName:@"outline"] stringValue];//新闻内容
    //  NSString *imgUrl=[[news attributeForName:@"imgUrl"] stringValue];     //图片文件服务器地址
    //  NSString *url=[[news attributeForName:@"url"] stringValue];     //新闻地址
    //  NSString *publishTime=[[news attributeForName:@"publishTime"] stringValue]; //发布时间

    //*********系统通知*********
    //    NSXMLElement *delay=[message elementForName:@"delay"];
    NSString *informsSendTime=nil;

    NSXMLElement *properties=[message elementForName:@"properties"];
    NSXMLElement *body=[message elementForName:@"body"];

    //NSString *strBody=nil;
    NSString *systemMessageType=nil;

    if (properties!=nil) {
        type = @"system";

        NSArray *propertys=[properties children];
        for (NSXMLElement *propert in propertys) {
            if ([propert.name isEqualToString:@"property"]) {
                NSArray *items=[propert children];

                for (NSXMLElement *item in items) {


                    if ([item.name isEqualToString:@"value"]) {
                        if ([item.stringValue isEqualToString:@"modify_password"]) {
                            //修改密码
                            if (body!=nil){
                                //strBody=body.stringValue;
                            }
                            if (delay!=nil){
                                informsSendTime=[delay attributeForName:@"stamp"].stringValue;
                            }
                            systemMessageType=@"modify_password";
                        }else if ([item.stringValue isEqualToString:@"welcome"]){
                            type = @"system_ab_community";
                            //strBody=body.stringValue;
                            if (delay!=nil){
                                informsSendTime=[delay attributeForName:@"stamp"].stringValue;
                            }


                        }else if ([item.stringValue isEqualToString:@"welcome_bangbang"]){
                            //欢迎信息
                            //strBody=body.stringValue;
                            type = @"system_ab_newGuidance";

                            if (delay!=nil){
                                informsSendTime=[delay attributeForName:@"stamp"].stringValue;
                            }

                        }else if ([item.stringValue isEqualToString:@"public_user_invited"]){
                            //邀请通知
                            //strBody=body.stringValue;
                            if (delay!=nil){
                                informsSendTime=[delay attributeForName:@"stamp"].stringValue;
                            }

                            systemMessageType=@"public_user_invited";

                        }else if ([item.stringValue isEqualToString:@"bind_email"]){
                            //邮箱绑定

                        }else if ([item.stringValue isEqualToString:@"secret_question"]){
                            //密保问题

                        }else if ([item.stringValue isEqualToString:@"email_activated"]){
                            //邮箱激活
                            if (body!=nil){
                                // strBody=body.stringValue;
                            }
                            if (delay!=nil){
                                informsSendTime=[delay attributeForName:@"stamp"].stringValue;
                            }
                            systemMessageType=@"email_activated";
                        }else if ([item.stringValue isEqualToString:@"join_circle"]){
                            //加入圈子
                        }else if ([item.stringValue isEqualToString:@"public_user_invited"]){
                            //个人二维码邀请提示
                            if (delay!=nil){
                                informsSendTime=[delay attributeForName:@"stamp"].stringValue;
                            }

                        }else if ([item.stringValue isEqualToString:@"pkg_update"]){
                            //更新提示



                        }else if([item.stringValue isEqualToString:@"private_user_actived"]){

                            //短信激活通知
                            //strBody=body.stringValue;
                            if (delay!=nil){
                                informsSendTime=[delay attributeForName:@"stamp"].stringValue;
                            }
                            systemMessageType = @"private_user_actived";

                        }else if([item.stringValue isEqualToString:@"public_user_invited"]){

                            //二维码邀请通知
                            //strBody=body.stringValue;
                            if (delay!=nil){
                                informsSendTime=[delay attributeForName:@"stamp"].stringValue;
                            }
                            systemMessageType = @"public_user_invited";

                        }else{

                            //其他系统通知
                            //strBody=body.stringValue;
                            if (delay!=nil){
                                informsSendTime=[delay attributeForName:@"stamp"].stringValue;
                            }
                            systemMessageType = @"other";
                        }
                    }

                }

            }
        }
    }

    //客服消息
    NSXMLElement *meta=[message elementForName:@"meta"];
    if (meta!=nil) {
        type=[[meta attributeForName:@"type" ]stringValue];
    }

    NSString * senderJID = @"";

    //消息发送人
    if ([type isEqualToString:@"chat"]) {
        NSString*str_character = @"@";
        NSRange senderRange = [from rangeOfString:str_character];
        if ([from rangeOfString:str_character].location != NSNotFound) {
            senderName = [from substringToIndex:senderRange.location];
        }
        senderJID = [NSString stringWithFormat:@"%@@%@",senderName, OpenFireHostName];
    }else if([type isEqualToString:@"groupchat"]){
        NSString*str_character = @"/";
        NSRange senderRange = [from rangeOfString:str_character];
        if ([from rangeOfString:str_character].location != NSNotFound) {
            senderGroupName = [from substringToIndex:senderRange.location];
        }

        NSArray *arry=[from componentsSeparatedByString:@"/"];
        if (arry.count==2) {
            senderName = [arry objectAtIndex:1];

            //10391@circle-muc.ab-insurance.com/10668_580226
            if ([senderName rangeOfString:@"_"].location != NSNotFound) {

                senderName= [senderName substringToIndex:[senderName rangeOfString:@"_"].location];
            }

        }
    }else if([type isEqualToString:@"multichat"]){
        senderGroupName = thread;
        NSString*str_character = @"@";
        NSRange senderRange = [from rangeOfString:str_character];
        if ([from rangeOfString:str_character].location != NSNotFound) {
            senderName = [from substringToIndex:senderRange.location];
        }

    }else if ([type isEqualToString:@"news"]){
        senderName=from;
    }else if ([type isEqualToString:@"system"] ){

        senderName = from;

    }else if([type isEqualToString:@"cs"]){
        NSString*str_character = @"@";
        NSRange senderRange = [from rangeOfString:str_character];
        if ([from rangeOfString:str_character].location != NSNotFound) {

            senderName = [from substringToIndex:senderRange.location];
        }
    }else{
        senderName = from;
    }



    if ([type isEqualToString:@"chat"]) {
        if(mtype == nil){
            mtype = @"chat";
        }
        NSString *subject = [[message elementForName:@"subject" ]stringValue];

        // NSLog(@"*******%@",subject);
        JLLog_I(@"received message msgRandomId=%@", msgRandomId);
        
        if([ChatMessageCRUD isReplicatedMessage:msgRandomId]){
            return;
        }
        
        if ([subject isEqualToString:@"image"]){
            NSString *imageJsonStr = [msg stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
            [ChatMessageCRUD insertChatMessage:senderName msg:imageJsonStr receiveUser:MY_USER_NAME msgType:type subject:subject sendTime:sendUTCTimeStr receiveTime:receiveUTCTimeStr readMark:0 sendStatus:@"complete" msgRandomId:msgRandomId myJID:MY_JID];

        }else if([subject isEqualToString:@"voice"]){

            NSString *voiceJsonStr = [msg stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
            [ChatMessageCRUD insertChatMessage:senderName msg:voiceJsonStr receiveUser:MY_USER_NAME msgType:type subject:subject sendTime:sendUTCTimeStr receiveTime:receiveUTCTimeStr readMark:0 sendStatus:@"complete" msgRandomId:msgRandomId myJID:MY_JID];


        }else if([subject isEqualToString:@"phone"]){
            // NSString *voiceJsonStr = [msg stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
            // NSDictionary *msgDic = [msg objectFromJSONString];
            NSString *msg = @"未接通";
            [ChatMessageCRUD insertChatMessage:senderName msg:msg receiveUser:MY_USER_NAME msgType:type subject:subject sendTime:sendUTCTimeStr receiveTime:receiveUTCTimeStr readMark:0 sendStatus:@"complete" msgRandomId:msgRandomId myJID:MY_JID];

        }else if([subject isEqualToString:@"video"]){
            // NSString *voiceJsonStr = [msg stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
            NSString *msg = @"未接通";
            [ChatMessageCRUD insertChatMessage:senderName msg:msg receiveUser:MY_USER_NAME msgType:type subject:subject sendTime:sendUTCTimeStr receiveTime:receiveUTCTimeStr readMark:0 sendStatus:@"complete" msgRandomId:msgRandomId myJID:MY_JID];

        }else{
            [ChatMessageCRUD insertChatMessage:senderName msg:msg receiveUser:MY_USER_NAME msgType:type subject:subject sendTime:sendUTCTimeStr receiveTime:receiveUTCTimeStr readMark:0 sendStatus:@"complete" msgRandomId: msgRandomId myJID:MY_JID];
        }


        //查询聊天列表是否存在
        NSString * myJID =  [NSString stringWithFormat:@"%@@%@",MY_USER_NAME, OpenFireHostName];

        UserInfo *userInfo = nil;
        userInfo = [UserInfoCRUD queryUserInfo:senderJID myJID:myJID];
        NSString *remarkName = [ContactsCRUD queryContactsRemarkName:senderJID];
        if ([remarkName isEqualToString:@"(null)"]) {
            remarkName = @"";
        }

        NSString *lastMsg = @"";
        if ([type isEqualToString:@"chat"] && ([subject isEqualToString:@"chat"] || [subject isEqualToString:@"notice"])) {
            lastMsg = msg;
        }else if([type isEqualToString:@"chat"] && [subject isEqualToString:@"image"]){
            lastMsg = @"[图片]";
        }else if([type isEqualToString:@"chat"] && [subject isEqualToString:@"voice"]){
            lastMsg = @"[语音]";
        }else if ([type isEqualToString:@"chat"] && [subject isEqualToString:@"card"]) {
            AIPersonalCard *card = [AIPersonalCard cardWithJson:msg];
            NSString *bname = [AIUsersUtility nameForShowWithJID:card.username];
            NSString *remessage = [NSString stringWithFormat:@"%@推荐了%@", [AIUsersUtility nameForShowWithJID:senderJID], ![StrUtility isBlankString:bname] ? bname : card.name];
            lastMsg = remessage;
        }else if ([type isEqualToString:@"chat"] && [subject isEqualToString:@"document"]) {
            AIDocument *document = [AIDocument documentWithJson:msg];
            lastMsg = document.fileName;
        }else if ([type isEqualToString:@"chat"] && [subject isEqualToString:@"location"]) {
            lastMsg = [NSString stringWithFormat:@"%@发送了一个地理位置",[AIUsersUtility nameForShowWithJID:senderJID]];
        }else if([type isEqualToString:@"chat"] && [subject isEqualToString:@"article"]){
            lastMsg = @"[链接]";
        }


        if ([ChatBuddyCRUD queryChatBuddyTableCountId:senderName myUserName:MY_USER_NAME]==0){

            if (userInfo != nil && ![userInfo.jid isEqualToString:@""] && userInfo.jid!=NULL) {
                [ChatBuddyCRUD insertChatBuddyTable:senderName jid:userInfo.jid name:remarkName nickName:userInfo.nickName phone:userInfo.phone avatar:userInfo.avatar myUserName:MY_USER_NAME type:@"chat" lastMsg:lastMsg msgType:type msgSubject:subject lastMsgTime:lastMsgTime tag:@""];
                //[self queryChatBuddyList:MY_USER_NAME];
            }else{
                //重装应用时，初始化未完成收到离线消息时，须要将离线消息延迟处理；
                NSMutableDictionary *jidDict = [[NSMutableDictionary alloc] init];
                [jidDict setObject:senderJID forKey:@"senderJID"];
                [jidDict setObject:myJID forKey:@"myJID"];
                [jidDict setObject:senderName forKey:@"senderName"];
                [jidDict setObject:msg forKey:@"msg"];
                [jidDict setObject:type forKey:@"type"];
                [jidDict setObject:subject forKey:@"subject"];
                [jidDict setObject:lastMsgTime forKey:@"lastMsgTime"];

                NSTimer *insertChatBuddyTimer;
                insertChatBuddyTimer = [NSTimer scheduledTimerWithTimeInterval: 8
                                                                        target: self
                                                                      selector: @selector(insertChatBuddy:)
                                                                      userInfo: jidDict
                                                                       repeats: NO];
            }
        }else{

            //[ChatBuddyCRUD updateChatBuddy:senderName name:remarkName nickName:userInfo.nickName lastMsg:lastMsg msgType:type msgSubject:subject lastMsgTime:lastMsgTime];
            //同时更新头像
            [ChatBuddyCRUD updateChatBuddyTwo:senderName name:remarkName nickName:userInfo.nickName phone:userInfo.phone avatar:userInfo.avatar lastMsg:lastMsg msgType:type msgSubject:subject lastMsgTime:lastMsgTime];
        }
    } else if([type isEqualToString:@"groupchat"]){
        //过滤自己收到自己的消息
        if ([senderName isEqualToString:MY_USER_NAME]) {
            return;
        }
        // NSString *mtype = [[message elementForName:@"mtype" ]stringValue];

        //离线消息太多时，可能出现问题，所以使用锁；
        // NSRecursiveLock *theLock = [[NSRecursiveLock alloc] init];
        //加锁
        // [theLock lock];

        if([GroupChatMessageCRUD isReplicatedMessage:msgRandomId]){
            return;
        }
        
        if ([mtype isEqualToString:@"image"]){
            //存入数据库前将双引号转成单引号
            NSString *imageJsonStr = [msg stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];

            [GroupChatMessageCRUD insertGroupChatMessageMultithread:senderGroupName sendUser:senderName msg:imageJsonStr type:type msgType:mtype sendTime:sendUTCTimeStr receiveTime:receiveUTCTimeStr readMark:0 sendStatus:@"complete" msgRandomId:msgRandomId myJID:MY_JID];

        }else if([mtype isEqualToString:@"voice"]){
            NSString *imageJsonStr = [msg stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];

            [GroupChatMessageCRUD insertGroupChatMessageMultithread:senderGroupName sendUser:senderName msg:imageJsonStr type:type msgType:mtype sendTime:sendUTCTimeStr receiveTime:receiveUTCTimeStr readMark:0 sendStatus:@"complete" msgRandomId:msgRandomId myJID:MY_JID];

        }else if([mtype isEqualToString:@"chat"] || [mtype isEqualToString:@"notice"]){
            [GroupChatMessageCRUD insertGroupChatMessageMultithread:senderGroupName sendUser:senderName msg:msg type:type msgType:mtype sendTime:sendUTCTimeStr receiveTime:receiveUTCTimeStr readMark:[mtype isEqualToString:@"notice"]?1:0 sendStatus:@"complete" msgRandomId:msgRandomId myJID:MY_JID];
        }else if ([mtype isEqualToString:@"chat"] || [mtype isEqualToString:@"card"]) {
            [GroupChatMessageCRUD insertGroupChatMessageMultithread:senderGroupName sendUser:senderName msg:msg type:type msgType:mtype sendTime:sendUTCTimeStr receiveTime:receiveUTCTimeStr readMark:0 sendStatus:@"complete" msgRandomId:msgRandomId myJID:MY_JID];
        }else if ([mtype isEqualToString:@"chat"] || [mtype isEqualToString:@"document"]) {
            [GroupChatMessageCRUD insertGroupChatMessageMultithread:senderGroupName sendUser:senderName msg:msg type:type msgType:mtype sendTime:sendUTCTimeStr receiveTime:receiveUTCTimeStr readMark:0 sendStatus:@"complete" msgRandomId:msgRandomId myJID:MY_JID];
        }else {
            [GroupChatMessageCRUD insertGroupChatMessageMultithread:senderGroupName sendUser:senderName msg:msg type:type msgType:mtype sendTime:sendUTCTimeStr receiveTime:receiveUTCTimeStr readMark:0 sendStatus:@"complete" msgRandomId:msgRandomId myJID:MY_JID];
        }
        
        
        //解锁
        // [theLock unlock];
        NSString *senderJID = [NSString stringWithFormat:@"%@@%@", senderName, OpenFireHostName];
        
        //查询聊天列表是否存在
        NSString * myJID =  [NSString stringWithFormat:@"%@@%@",MY_USER_NAME, OpenFireHostName];
        ChatGroup * chatGroup = nil;
        chatGroup = [GroupCRUD queryChatGroupByJID:senderGroupName myJID:myJID];
        
        // NSString *sender = [GroupMembersCRUD queryNickNameWithGroupJID:chatGroup.jid memberJID:senderJID];
        NSString *sender = [AIUsersUtility gnameForShowWithJID:senderJID inGroup:chatGroup.jid];
        
        NSString *tmp = @"";
        if([type isEqualToString:@"groupchat"] && [mtype isEqualToString:@"image"]){
            tmp = @"[图片]";
        }else if([type isEqualToString:@"groupchat"] && [mtype isEqualToString:@"voice"]){
            tmp = @"[语音]";
        }else if([type isEqualToString:@"groupchat"] && [mtype isEqualToString:@"phone"]){
            tmp = @"[语音通话]";
        }else if ([type isEqualToString:@"groupchat"] && [mtype isEqualToString:@"card"]) {
            AIPersonalCard *card = [AIPersonalCard cardWithJson:msg];
            NSString *bname = [AIUsersUtility nameForShowWithJID:card.username];
            tmp = [NSString stringWithFormat:@"推荐了%@", ![StrUtility isBlankString:bname] ? bname : card.name];
        }else if ([type isEqualToString:@"groupchat"] && [mtype isEqualToString:@"document"]) {
            AIDocument *document = [AIDocument documentWithJson:msg];
            tmp = [NSString stringWithFormat:@"[文件]%@",document.fileName];
        }else if ([type isEqualToString:@"groupchat"] && [mtype isEqualToString:@"location"]) {
            tmp = @"发送了一个地埋位置";
        }else if([type isEqualToString:@"groupchat"] && [mtype isEqualToString:@"article"]){
            tmp = @"[链接]";
        }
        else{
            tmp = msg;
        }
        
        NSString *lastMsg = tmp;
        if(![mtype isEqualToString:@"notice"]){
            NSString *colon = ([mtype isEqualToString:@"card"] || [mtype isEqualToString:@"location"] || [mtype isEqualToString:@"card"])?@"":@"：";
            lastMsg = [NSString stringWithFormat:@"%@%@%@", sender, colon, tmp];
        }
        
        if (mtype == nil) {
            return;
        }

        //将用户写入聊天历史列表
        if ([ChatBuddyCRUD queryChatBuddyTableCountId:senderGroupName myUserName:MY_USER_NAME]==0){

            if (chatGroup != nil && ![chatGroup.groupMucId isEqualToString:@""] && chatGroup.groupMucId!=NULL) {
                [ChatBuddyCRUD insertChatBuddyTable:senderGroupName jid:chatGroup.jid name:chatGroup.name nickName:chatGroup.name phone:@"" avatar:@"" myUserName:MY_USER_NAME type:@"groupchat" lastMsg:lastMsg msgType:type msgSubject:mtype lastMsgTime:lastMsgTime tag:@""];
                //[self queryChatBuddyList:MY_USER_NAME];
            }else{
                //重装应用时，初始化未完成收到离线消息时，须要将离线消息延迟处理；
                NSMutableDictionary *jidDict = [[NSMutableDictionary alloc] init];
                [jidDict setObject:myJID forKey:@"myJID"];
                [jidDict setObject:senderGroupName forKey:@"senderGroupName"];
                [jidDict setObject:senderName forKey:@"senderName"];
                [jidDict setObject:msg forKey:@"msg"];
                [jidDict setObject:type forKey:@"type"];
                [jidDict setObject:mtype forKey:@"mtype"];
                [jidDict setObject:lastMsgTime forKey:@"lastMsgTime"];

                NSTimer *inserChatBuddyTimer =nil;
                inserChatBuddyTimer = [NSTimer scheduledTimerWithTimeInterval: 8
                                                                       target: self
                                                                     selector: @selector(insertChatBuddyGroup:)
                                                                     userInfo: jidDict
                                                                      repeats: NO];
            }
        }else{
            [ChatBuddyCRUD updateChatBuddy:senderGroupName name:chatGroup.name nickName:chatGroup.name lastMsg:lastMsg msgType:type msgSubject:mtype lastMsgTime:lastMsgTime];

        }

    } else if ([type isEqualToString:@"system_ab_community"]){

        NSLog(@"****%@",msg);
        if ([StrUtility isBlankString:msg]) {
            return;
        }

        //系统提示
        NSString *name= @"邦邦社区";
        senderName = @"system_ab_community";
        [SystemMessageCRUD insertSytemMessageSendName:senderName myUserName:MY_USER_NAME readMark:@"0" msg:msg msgType:systemMessageType time:sendUTCTimeStr];
        if ([ChatBuddyCRUD queryChatBuddyTableCountId:senderGroupName myUserName:MY_USER_NAME]==0){

            [ChatBuddyCRUD insertChatBuddyTable:senderName jid:senderName name:name nickName:name phone:@"" avatar:@"" myUserName:MY_USER_NAME type:type lastMsg:msg msgType:mtype msgSubject:systemMessageType lastMsgTime:lastMsgTime tag:@""];

        }else{

            [ChatBuddyCRUD updateChatBuddy:senderName name:name nickName:name lastMsg:msg msgType:mtype msgSubject:systemMessageType lastMsgTime:lastMsgTime];

        }
    }else if ([type isEqualToString:@"system_ab_newGuidance"]){

        NSLog(@"****%@",msg);
        if ([StrUtility isBlankString:msg]) {
            return;
        }

        //系统提示
        NSString *name= @"安邦消息通知";
        senderName = @"system_ab_newGuidance";
        [SystemMessageCRUD insertSytemMessageSendName:senderName myUserName:MY_USER_NAME readMark:@"0" msg:msg msgType:systemMessageType time:sendUTCTimeStr];
        if ([ChatBuddyCRUD queryChatBuddyTableCountId:senderGroupName myUserName:MY_USER_NAME]==0){

            [ChatBuddyCRUD insertChatBuddyTable:senderName  jid:senderName name:name nickName:name phone:@"" avatar:@"" myUserName:MY_USER_NAME type:type lastMsg:msg msgType:mtype msgSubject:systemMessageType lastMsgTime:lastMsgTime tag:@""];

        }else{

            [ChatBuddyCRUD updateChatBuddy:senderName name:name nickName:name lastMsg:msg msgType:mtype msgSubject:systemMessageType lastMsgTime:lastMsgTime];

        }
    }
    else{
        NSLog(@"未知消息！");
    }

    JLLog_I(@"after update chat buddy");
    NSDictionary *postData = @{@"JID":senderJID, @"groupJID": senderGroupName, @"hasAtMe":hasAtMe?@"1":@"0"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Chat_Buddy_View_Refresh" object:postData userInfo:nil];
    return;
}




/*---装机时离线消息处理 start-------------------------------------------------------------------------------*/
//将联系人信息写入聊天列表
+(void)insertChatBuddy:(NSTimer *)timer
{
    NSString *myJID =[[timer userInfo] objectForKey:@"myJID"];
    NSString *senderJID =[[timer userInfo] objectForKey:@"senderJID"];
    NSString *senderName =[[timer userInfo] objectForKey:@"senderName"];
    NSString *msg =[[timer userInfo] objectForKey:@"msg"];
    NSString *type =[[timer userInfo] objectForKey:@"type"];
    NSString *subject =[[timer userInfo] objectForKey:@"subject"];
    NSString *lastMsgTime =[[timer userInfo] objectForKey:@"lastMsgTime"];
    
    UserInfo *userInfo = nil;
    userInfo = [UserInfoCRUD queryUserInfo:senderJID myJID:myJID];
    NSString *remarkName = [ContactsCRUD queryContactsRemarkName:senderJID];
    if ([remarkName isEqualToString:@"(null)"]) {
        remarkName = @"";
    }
    
    NSString *lastMsg = @"";
    if ([type isEqualToString:@"chat"] && ([subject isEqualToString:@"chat"] || [subject isEqualToString:@"notice"])) {
        lastMsg = msg;
    }else if([type isEqualToString:@"chat"] && [subject isEqualToString:@"image"]){
        lastMsg = @"[图片]";
    }else if([type isEqualToString:@"chat"] && [subject isEqualToString:@"voice"]){
        lastMsg = @"[语音]";
    }else if ([type isEqualToString:@"chat"] && [subject isEqualToString:@"card"]) {
        AIPersonalCard *card = [AIPersonalCard cardWithJson:msg];
        NSString *bname = [AIUsersUtility nameForShowWithJID:card.username];
        NSString *remessage = [NSString stringWithFormat:@"%@推荐了%@", [AIUsersUtility nameForShowWithJID:senderJID], ![StrUtility isBlankString:bname] ? bname : card.name];
        lastMsg = remessage;
    }else if ([type isEqualToString:@"chat"] && [subject isEqualToString:@"document"]) {
        AIDocument *document = [AIDocument documentWithJson:msg];
        lastMsg = document.fileName;
    }else if ([type isEqualToString:@"chat"] && [subject isEqualToString:@"location"]) {
        lastMsg = [NSString stringWithFormat:@"%@发送了一个地理位置",[AIUsersUtility nameForShowWithJID:senderJID]];
    }else if([type isEqualToString:@"chat"] && [subject isEqualToString:@"article"]){
        lastMsg = @"[链接]";
    }

    //离线消息时保证只写入一条数据；
    //  if ([ChatBuddyCRUD queryChatBuddyTableCountId:senderName myUserName:MY_USER_NAME]==0){

    if (![userInfo.jid isEqualToString:@""] && userInfo.jid!=NULL) {
        [ChatBuddyCRUD insertChatBuddyTable:senderName jid:userInfo.jid name:remarkName nickName:userInfo.nickName phone:userInfo.phone avatar:userInfo.avatar myUserName:MY_USER_NAME type:type lastMsg:lastMsg msgType:type msgSubject:subject lastMsgTime:lastMsgTime tag:@""];
        // [self queryChatBuddyList: MY_USER_NAME];
    }else{
        //重装应用时，初始化未完成收到离线消息时，须要将离线消息延迟处理；
        //以后将接收陌生人的消息，将重新处理。

        //消息发送者不在联系人表时，查询是否存在userInfo
        [ChatBuddyCRUD insertChatBuddyTable:senderName jid:senderJID name:@"" nickName:@"" phone:@"" avatar:@"" myUserName:MY_USER_NAME type:type lastMsg:lastMsg msgType:type msgSubject:subject lastMsgTime:lastMsgTime tag:@""];

    }


    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Chat_Buddy_View_Refresh" object:nil userInfo:nil];
}


//将群组信息写入聊天列表
+(void)insertChatBuddyGroup:(NSTimer *)timer
{
    NSString *myJID =[[timer userInfo] objectForKey:@"myJID"];
    NSString *senderGroupName =[[timer userInfo] objectForKey:@"senderGroupName"];
    NSString *senderName =[[timer userInfo] objectForKey:@"senderName"];
    NSString *msg =[[timer userInfo] objectForKey:@"msg"];
    NSString *type =[[timer userInfo] objectForKey:@"type"];
    NSString *mtype =[[timer userInfo] objectForKey:@"mtype"];
    NSString *lastMsgTime =[[timer userInfo] objectForKey:@"lastMsgTime"];

    NSString *senderJID = [NSString stringWithFormat:@"%@@%@", senderName, OpenFireHostName];
    
    //查询聊天列表是否存在
    ChatGroup * chatGroup = nil;
    chatGroup = [GroupCRUD queryChatGroupByJID:senderGroupName myJID:myJID];
    
    // NSString *sender = [GroupMembersCRUD queryNickNameWithGroupJID:chatGroup.jid memberJID:senderJID];
    NSString *sender = [AIUsersUtility gnameForShowWithJID:senderJID inGroup:chatGroup.jid];
    
    NSString *tmp = @"";
    if([type isEqualToString:@"groupchat"] && [mtype isEqualToString:@"image"]){
        tmp = @"[图片]";
    }else if([type isEqualToString:@"groupchat"] && [mtype isEqualToString:@"voice"]){
        tmp = @"[语音]";
    }else if([type isEqualToString:@"groupchat"] && [mtype isEqualToString:@"phone"]){
        tmp = @"[语音通话]";
    }else if ([type isEqualToString:@"groupchat"] && [mtype isEqualToString:@"card"]) {
        AIPersonalCard *card = [AIPersonalCard cardWithJson:msg];
        NSString *bname = [AIUsersUtility nameForShowWithJID:card.username];
        tmp = [NSString stringWithFormat:@"推荐了%@", ![StrUtility isBlankString:bname] ? bname : card.name];
    }else if ([type isEqualToString:@"groupchat"] && [mtype isEqualToString:@"document"]) {
        AIDocument *document = [AIDocument documentWithJson:msg];
        tmp = [NSString stringWithFormat:@"[文件]%@",document.fileName];
    }else if ([type isEqualToString:@"groupchat"] && [mtype isEqualToString:@"location"]) {
        tmp = @"发送了一个地埋位置";
    }else if([type isEqualToString:@"groupchat"] && [mtype isEqualToString:@"article"]){
        tmp = @"[链接]";
    }
    else{
        tmp = msg;
    }
    
    NSString *lastMsg = tmp;
    if(![mtype isEqualToString:@"notice"]){
        NSString *colon = ([mtype isEqualToString:@"card"] || [mtype isEqualToString:@"location"] || [mtype isEqualToString:@"card"])?@"":@"：";
        lastMsg = [NSString stringWithFormat:@"%@%@%@", sender, colon, tmp];
    }

    //将用户写入聊天历史列表
    if ([ChatBuddyCRUD queryChatBuddyTableCountId:senderGroupName myUserName:MY_USER_NAME]==0){
        if (![chatGroup.groupMucId isEqualToString:@""] && chatGroup.groupMucId!=NULL) {
            [ChatBuddyCRUD insertChatBuddyTable:senderGroupName jid:chatGroup.jid name:chatGroup.name nickName:chatGroup.name phone:@"" avatar:@"" myUserName:MY_USER_NAME type:@"groupchat" lastMsg:lastMsg msgType:type msgSubject:mtype lastMsgTime:lastMsgTime tag:@""];
            //[self queryChatBuddyList:MY_USER_NAME];

        }else{

            //如果延迟后，还未得到圈子信息得情况...

        }
    }else{
        [ChatBuddyCRUD updateChatBuddy:senderGroupName name:chatGroup.name nickName:chatGroup.name lastMsg:lastMsg msgType:type msgSubject:mtype lastMsgTime:lastMsgTime];
    }

    //发送通知，刷新聊天列表;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Chat_Buddy_View_Refresh" object:nil userInfo:nil];

}


//将新闻写入聊天列表
+(void)insertNews:(NSTimer *)timer{
    NSString *name=@"新闻";
    // NSString *myJID =[[timer userInfo] objectForKey:@"myJID"];
    NSString *senderJID =[[timer userInfo] objectForKey:@"senderName"];
    NSString *msg =[[timer userInfo] objectForKey:@"msg"];
    NSString *type =[[timer userInfo] objectForKey:@"type"];
    NSString *sendTimeStr =[[timer userInfo] objectForKey:@"sendTime"];    //离线消息时保证只写入一条数据；
    News *news = nil;
    news = [NewsListCRUD querynewsName:MY_USER_NAME newsName:msg];
    NSString *lastMsg = @"";
    if ([type isEqualToString:@"news"]) {
        lastMsg=msg;
    }
    if ([NewsCRUD quearReadMark:MY_USER_NAME]==1){
        [NewsCRUD updata:[NewsCRUD quearReadMark:MY_USER_NAME]+1 userName:MY_USER_NAME ];
        if (![news.title isEqualToString:@""] && news.title!=NULL) {
            [ChatBuddyCRUD insertChatBuddyTable:senderJID jid:senderJID name:name nickName:name phone:@"" avatar:@"" myUserName:MY_USER_NAME type:type lastMsg:lastMsg msgType:type msgSubject:type lastMsgTime:sendTimeStr tag:@""];
        }else{
            //重装应用时，初始化未完成收到离线消息时，须要将离线消息延迟处理；
            //以后将接收陌生人的消息，将重新处理。
            return;
        }
    }

    //发送通知，刷新聊天列表;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"chatBuddyView" object:self userInfo:nil];
}
/*---装机时离线消息处理 end-------------------------------------------------------------------------------*/

/*---通知中心接受到消息后，响应该方法  end---------------------------------------------------*/




/*---------------------------------好友列表数据初始化--------------------------------------------*/
//查询所有好友
+(void)queryRoster{
    /*
     <iq type="get"
     　　from="xiaoming@example.com"
     　　to="example.com"
     　　id="1234567">
     　　<query xmlns="jabber:iq:roster"/>
     <iq />
     */
    NSLog(@"------queryRoster------");
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    XMPPJID *myJID = [XMPPServer xmppStream].myJID;
    //id 随机生成（须确保无重复）
    // NSLog(@"*******%@",[IdGenerator next]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[IdGenerator next] forKey:@"IQ_Query_Roster"];

    [iq addAttributeWithName:@"id" stringValue:[defaults stringForKey:@"IQ_Query_Roster"]];
    [iq addAttributeWithName:@"from" stringValue:myJID.description];
    [iq addAttributeWithName:@"to" stringValue:myJID.domain];
    [iq addAttributeWithName:@"type" stringValue:@"get"];

    [queryElement addAttributeWithName:@"ver" stringValue:[defaults stringForKey:@"Ver_Query_Roster"]];

    [iq addChild:queryElement];
    // NSLog(@"jid:%@",myJID);
    NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
}

//接收所有好友
//+(void)newBuddyOnline:(NSString *)jid buddyName:(NSString *)name{
//    NSString * myJID = [[NSString alloc] initWithFormat:@"%@", [XMPPServer xmppStream].myJID.bareJID];
//    NSLog(@"%@",myJID);
//    //写库
//    if ([ContactsCRUD queryBuddyListTableCountId:jid myJID:myJID]==0) {
//        [ContactsCRUD insertContactsTable:jid name:name myJID:myJID];
//    }
//}


//接收所有好友
+ (void)receivedContacts:(NSNotification *) noti
{
    //异步写入好友数据
    dispatch_async(dispatch_get_main_queue(),^(void){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString*ver=[defaults stringForKey:@"Ver_Query_Roster"];

        //清除roster版本号
        [defaults removeObjectForKey:@"Ver_Query_Roster"];

        NSMutableArray *insertContactsSqlArray = [[NSMutableArray alloc]init];
        NSString *addTime = Utility.getCurrentDate;

        // int contactsCount = [[noti object] count];
        int i = 0;
        //NSString * myJID = [[NSString alloc] initWithFormat:@"%@", [XMPPServer xmppStream].myJID.bareJID];
        for (NSDictionary* dic in [noti object]) {
            i++;
            NSString *jid = [dic objectForKey: @"jid"];
            NSString *remarkName = [dic objectForKey: @"name"];
            NSString *subscription = dic[@"subscription"];
            NSString *phone = @"";
            NSString *avatar = @"";
            NSString *nickName = @"";

            NSString *insertSqlStr=[NSString stringWithFormat:@"replace into Contacts (jid,remarkName,nickName,phone,avatar,myJID,addTime,subscription,remarkName_sort,remarkName_short_sort) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",jid,remarkName, nickName,phone,avatar,MY_JID,addTime,subscription,[remarkName transformToPinyin], [remarkName getPrenameAbbreviation]];

            [insertContactsSqlArray addObject:insertSqlStr];

            //        if (i==contactsCount) {
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_UserInfoPercentage" object:@"50" userInfo:nil];
            //        }
        }
        //NSLog(@"*******%@",ver);

        //写库
        if ([[noti object] count]>0) {
            [ContactsCRUD replaceContactsTable:insertContactsSqlArray ver:ver];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_Contacts_Database_Ready"
                                                                object:[noti object]];
        }
        

    });
}

+ (void)getNewFriendsList {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *ver = [[NSUserDefaults standardUserDefaults] objectForKey:kNew_Friends_List_Ver];
        JLLog_I(@"<New friend list ver=%@>",ver);
        ver = ver ? ver : @"0";
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"id" stringValue:@"AI_Get_New_Friends_List"];
        [iq addAttributeWithName:@"type" stringValue:@"get"];
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:kXmppValidateNameSpace];
        [query addAttributeWithName:@"ver" stringValue:ver];
        [iq addChild:query];
        JLLog_I(@"%@", iq);
        [[XMPPServer xmppStream] sendElement:iq];
    });
}



/*---群组数据初始化 start-----------------------------------------------------------------*/
//查询群组，查可接收群组消息
+(void)queryRoom{
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/list"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];


    NSMutableArray *groupArray = nil;

    groupArray = [GroupCRUD queryGroupInfo:MY_JID];

    for (NSDictionary*dic in groupArray) {
        NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
        [circle addAttributeWithName:@"jid" stringValue:[dic objectForKey:@"groupJID"]];
        [circle addAttributeWithName:@"ver" stringValue:[dic objectForKey:@"version"]];
        [queryElement addChild:circle];
    }

    [iq addAttributeWithName:@"id" stringValue:@"iq_query_group"];

    [iq addAttributeWithName:@"to" stringValue:@"circle.ab-insurance.com"];

    [iq addAttributeWithName:@"type" stringValue:@"get"];

    [iq addChild:queryElement];

    // NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];


}




////圈子信息
+(void)chatGroupReceived:(NSNotification *) noti
{
    //   dispatch_async(dispatch_get_main_queue(), ^{
    NSMutableArray *groupArray = nil;
    NSMutableArray *insertGroupSqlArray = [[NSMutableArray alloc]init];
    NSString *timeStr = [Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    groupArray = [noti object];
    NSString * groupVer = @"";
    for (ChatGroup* group in groupArray) {

        JLLog_I(@"<group remove> %@",group.removeStr);
        if([group.removeStr isEqualToString:@"true"]){
            [GroupCRUD deleteMyGroup:group.jid myJID:MY_JID];
            return;
        }

        if(![GroupCRUD queryGroupInfoVersionUpd:group.jid myJID:MY_JID ver:group.version]){
        }

        BOOL isExists = [GroupCRUD queryChatRoomTableCountId:group.jid myJID:MY_JID] > 0 ? YES : NO;
        NSString *insertGroupSqlStr = nil;
        if (isExists) {
            insertGroupSqlStr = [NSString stringWithFormat:@"update ChatGroup set groupJID=\"%@\", name=\"%@\", creator=\"%@\", groupMucId=\"%@\", groupType=\"%@\", myJID=\"%@\", version=\"%@\", inviteUrl=\"%@\", createDate=\"%@\", modificationDate=\"%@\",name_sort=\"%@\",name_short_sort=\"%@\" where groupJID=\"%@\";",group.jid, [StrUtility string:group.name defaultValue:@""],group.creator,group.groupMucId,[StrUtility string:group.groupType], MY_JID,group.version,group.inviteUrl,group.createDate,group.modificationDate,[group.name transformToPinyin],[group.name getPrenameAbbreviation],group.jid];
        }else {
            insertGroupSqlStr=[NSString stringWithFormat:@"replace into ChatGroup (groupJID,name,creator,groupMucId,groupType,myJID,version,inviteUrl,createDate,modificationDate,name_sort,name_short_sort) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",group.jid, [StrUtility string:group.name defaultValue:@""],group.creator,group.groupMucId,[StrUtility string:group.groupType], MY_JID,group.version,group.inviteUrl,group.createDate,group.modificationDate,[group.name transformToPinyin], [group.name getPrenameAbbreviation]];
        }

        [insertGroupSqlArray addObject:insertGroupSqlStr];
        groupVer = group.version;
    }
    //这里使用多线程，可能会造成锁表
    if (insertGroupSqlArray.count>0) {
        [GroupCRUD replaceGroup:insertGroupSqlArray version:groupVer];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Chat_Buddy_View_Refresh" object:nil];
    }
    //    });
    
}


////圈子信息
+(void)chatGroupReceived2:(NSNotification *) noti
{
    NSMutableArray *groupArray = nil;
    groupArray = [noti object];

    for (ChatGroup* group in groupArray) {
        if([group.removeStr isEqualToString:@"true"]){
            [GroupCRUD deleteMyGroup:group.jid myJID:MY_JID];
            return;
        }

    }

}


//圈子成员信息 <在线>
+(void)groupMembersReceived:(NSNotification *) noti
{
    //  dispatch_async(dispatch_get_main_queue(), ^{
    NSMutableArray *groupMemberArray = nil;
    NSMutableArray *insertGroupMembersSqlArray = [[NSMutableArray alloc]init];

    groupMemberArray = [noti object];
//    JLLog_I(@"groupMember=%@", groupMemberArray);

    for (NSDictionary* dic in groupMemberArray) {

        NSString *memberJID = [dic objectForKey: @"jid"];
        NSString *nickName = [dic objectForKey:@"nickName"];
        NSString *role = [dic objectForKey:@"role"];
        NSString *roleSort = [role isEqualToString:@"owner"]?@"0":([role isEqualToString:@"admin"]?@"1":@"2");
        NSString *groupJID = [dic objectForKey:@"groupJID"];
        NSString *groupMucJID = [dic objectForKey:@"groupMucJID"];
        NSString *remove = [dic objectForKey:@"remove"];
        NSString *createTime = [dic objectForKey:@"createtime"];

        // NSLog(@"******%@",remove);
        if([remove isEqualToString:@"true"]){
            if ([memberJID isEqualToString:MY_JID]) {
                [GroupCRUD deleteMyGroup:groupJID myJID:MY_JID];
                //同时删除聊天历史列表
                [ChatBuddyCRUD deleteChatBuddyByChatUserName:groupMucJID myUserName:MY_USER_NAME];
            }
            [GroupMembersCRUD deleteGroupMember:groupJID memberJID:memberJID myJID:MY_JID];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Group_Load_OK" object:self userInfo:nil];
            return;
        }

        NSString *insertGroupMembersSqlStr = [NSString stringWithFormat:@"replace into GroupMembers (jid,nickName,role,roleSort,groupJID,myJID,createtime) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",memberJID,nickName,role,roleSort,groupJID,MY_JID,createTime];

        // NSLog(@"*********%@",insertGroupMembersSqlStr);

        [insertGroupMembersSqlArray addObject:insertGroupMembersSqlStr];
    }

    [GroupMembersCRUD replaceGroupMembersTable:insertGroupMembersSqlArray];




    //    });
}



//圈子成员信息 <登录之时>
+(void)groupMembersReceived2:(NSNotification *) noti
{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
    NSMutableArray *groupMemberArray = nil;
    NSMutableArray *insertGroupMembersSqlArray = [[NSMutableArray alloc]init];

    groupMemberArray = [noti object];
//    JLLog_I(@"groupMember=%@", groupMemberArray);

    for (NSDictionary* circle in groupMemberArray) {
        
        NSString *groupJID = circle[@"groupJID"];
        [GroupMembersCRUD deleteAllGroupMemberByGroupId:groupJID myJID:MY_JID];
        
        for (NSDictionary *dic in circle[@"members"]) {
            NSString *memberJID = [dic objectForKey: @"jid"];
            NSString *nickName = [dic objectForKey:@"nickName"];
            NSString *role = [dic objectForKey:@"role"];
            NSString *roleSort = [role isEqualToString:@"owner"]?@"0":([role isEqualToString:@"admin"]?@"1":@"2");
            NSString *groupJID = [dic objectForKey:@"groupJID"];
            NSString *groupMucJID = [dic objectForKey:@"groupMucJID"];
            NSString *remove = [dic objectForKey:@"remove"];
            NSString *createTime = [StrUtility string:[dic objectForKey:@"createtime"]];
            
            //[GroupMembersCRUD deleteAllGroupMember:groupJID myJID:MY_JID];
            
            // NSLog(@"******%@",remove);
            if([remove isEqualToString:@"true"]){
                if ([memberJID isEqualToString:MY_JID]) {
                    [GroupCRUD deleteMyGroup:groupJID myJID:MY_JID];
                    //同时删除聊天历史列表
                    [ChatBuddyCRUD deleteChatBuddyByChatUserName:groupMucJID myUserName:MY_USER_NAME];
                }
                [GroupMembersCRUD deleteGroupMember:groupJID memberJID:memberJID myJID:MY_JID];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Group_Load_OK" object:self userInfo:nil];
                return;
            }
            
            NSString *insertGroupMembersSqlStr = [NSString stringWithFormat:@"replace into GroupMembers (jid,nickName,role,roleSort,groupJID,myJID,createtime) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",memberJID,nickName,role,roleSort,groupJID,MY_JID,createTime];
            
            // NSLog(@"*********%@",insertGroupMembersSqlStr);
            
            [insertGroupMembersSqlArray addObject:insertGroupMembersSqlStr];
        }
    }
    [GroupMembersCRUD replaceGroupMembersTable:insertGroupMembersSqlArray];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Group_Load_OK" object:self userInfo:nil];

//    });

}

/*---群组数据初始化 end--------------------------------------------------------------------*/






/*---所有订阅用户数据初始化 start------------------------------------------------------------*/
//查询所有订阅用户信息
+(void)queryUserInfo{
    //id 随机生成（须确保无重复）
    // NSLog(@"*******%@",[IdGenerator next]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[IdGenerator next] forKey:@"IQ_Query_UserInfo"];

    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];

    [iq addAttributeWithName:@"id" stringValue:[defaults stringForKey:@"IQ_Query_UserInfo"]];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [queryElement addAttributeWithName:@"ver" stringValue:[defaults stringForKey:@"Ver_Query_UserInfo"]];
    [iq addChild:queryElement];
    // NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
}

+(void)queryUserInfoWithJid:(NSString *)jid
{
    //id 随机生成（须确保无重复）
    // NSLog(@"*******%@",[IdGenerator next]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[IdGenerator next] forKey:@"IQ_Query_UserInfo"];

    NSXMLElement *user = [NSXMLElement elementWithName:@"user"];
    [user addAttributeWithName:@"jid" stringValue:jid];

    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];

    [iq addAttributeWithName:@"id" stringValue:[defaults stringForKey:@"IQ_Query_UserInfo"]];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [queryElement addAttributeWithName:@"ver" stringValue:[defaults stringForKey:@"Ver_Query_UserInfo"]];
    [queryElement addChild:user];
    [iq addChild:queryElement];
    // NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
}



+(void)queryDndInfo{

//     <iq type="get">
//     <query xmlns="http:www.nihualao.com/xmpp/dnd" ver="客户端缓存的版本号"/>
//     </iq>

    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/dnd"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addChild:queryElement];
    // NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];

}


+(void)userInfoReceived:(NSNotification *) noti
{
    // _avtarURL = [NSString stringWithFormat:@"%@/%@",ResourcesURL, avatarURL];
    NSMutableArray *userInfoArray = nil;
    userInfoArray = [noti object];
    // 这里判断是否第一次
    if ([UserInfoCRUD queryUserInfoTableTotal:MY_JID]==0) {
        [self userInfoReceivedMultiThread:userInfoArray];
    }else{
        [self userInfoReceivedMultiThread:userInfoArray];
    }

}

+(void)userInfoReceivedMultiThread:(NSMutableArray *) userInfoArray
{
    NSMutableArray *insertUserInfoSqlArray = [[NSMutableArray alloc]init];

    if (userInfoArray.count==0) {
        return;
    }
    
//    JLLog_I(@"userInfoArray=%@", userInfoArray);
    
    for (NSDictionary* dic in userInfoArray) {

        NSString *jid = [dic objectForKey: @"jid"];
        NSString *nickName = [dic objectForKey:@"nickName"];
        NSString *remarkName = [dic objectForKey: @"nickName"];
        NSString *phone = [dic objectForKey:@"phone"];
        NSString *avatar = [dic objectForKey:@"avatar"];

        NSString *email = [dic objectForKey:@"email"];
        NSString *secondEmail = [dic objectForKey:@"secondEmail"];
        NSString *source = [dic objectForKey:@"source"];
        NSString *inviteUrl = [dic objectForKey:@"inviteUrl"];
        NSString *accountType = [dic objectForKey:@"accountType"];
        NSString *cemployeeCde = [dic objectForKey:@"cemployeeCde"];
        NSString *accountName = [dic objectForKey:@"accountName"];
        NSString *gender = [dic objectForKey:@"gender"];
        NSString *areaId = [dic objectForKey:@"areaId"];
        NSString *bookNme = [dic objectForKey:@"bookNme"];
        NSString *agencyNme = [dic objectForKey:@"agencyNme"];
        NSString *branchNme = [dic objectForKey:@"branchNme"];
        NSString *centerNme = [dic objectForKey:@"centerNme"];
        NSString *employeeNme = [dic objectForKey:@"employeeNme"];
        NSString *departmentNme = [dic objectForKey:@"departmentNme"];
        NSString *signature = dic[@"signature"];
        NSString *employeePhone = dic[@"employeePhone"];
        NSString *publicPhone = dic[@"publicPhone"];
        NSString *officalPhone = dic[@"officalPhone"];
        
        NSString *version = [dic objectForKey:@"version"];
        NSString *remove = [dic objectForKey:@"remove"];

        if([remove isEqualToString:@"true"]){
            [UserInfoCRUD deleteUserInfoByJIDAndMyJID:jid myJID:MY_JID];
            continue;
        }
        NSString *addTime = Utility.getCurrentDate;

        BOOL isExists = [UserInfoCRUD queryUserInfoTableCountId:jid myJID:MY_JID] > 0 ? YES : NO;
        NSString *insertUserInfoSqlStr = nil;
        if (isExists) {
            insertUserInfoSqlStr = [NSString stringWithFormat:@"update UserInfo set jid=\"%@\", remarkName=\"%@\", nickName=\"%@\", phone=\"%@\", avatar=\"%@\", email==\"%@\", secondEmail=\"%@\", source=\"%@\", inviteUrl=\"%@\", accountType=\"%@\", employeeCode=\"%@\", accountName=\"%@\", gender=\"%@\", areaId=\"%@\", bookName=\"%@\", agencyName=\"%@\", branchName=\"%@\", centerName=\"%@\", employeeName=\"%@\", departmentNme=\"%@\", version=\"%@\", myJID=\"%@\", addTime=\"%@\", signature=\"%@\", employeePhone=\"%@\", publicPhone=\"%@\",officalPhone =\"%@\",nickName_sort=\"%@\",nickName_short_sort=\"%@\",employeeName_sort=\"%@\",employeeName_short_sort=\"%@\" where jid =\"%@\";", jid,remarkName, nickName,phone,avatar,email,secondEmail,source,inviteUrl,accountType,cemployeeCde,accountName,gender,areaId,bookNme,agencyNme,branchNme,centerNme,employeeNme,departmentNme,version,MY_JID,addTime, signature, employeePhone, publicPhone, officalPhone,[nickName transformToPinyin],[nickName getPrenameAbbreviation],[employeeNme transformToPinyin],[employeeNme getPrenameAbbreviation], jid];
        }else {
            insertUserInfoSqlStr = [NSString stringWithFormat:@"REPLACE INTO UserInfo (jid,remarkName,nickName,phone,avatar,email,secondEmail,source,inviteUrl,accountType,employeeCode,accountName,gender,areaId,bookName,agencyName,branchName,centerName,employeeName,departmentNme,version,myJID,addTime,signature,employeePhone,publicPhone,officalPhone,nickName_sort,nickName_short_sort,employeeName_sort,employeeName_short_sort) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\");",jid,remarkName, nickName,phone,avatar,email,secondEmail,source,inviteUrl,accountType,cemployeeCde,accountName,gender,areaId,bookNme,agencyNme,branchNme,centerNme,employeeNme,departmentNme,version,MY_JID,addTime, signature,employeePhone,publicPhone,officalPhone,[nickName transformToPinyin],[nickName getPrenameAbbreviation],[employeeNme transformToPinyin], [employeeNme getPrenameAbbreviation]];
        }

        [insertUserInfoSqlArray addObject:insertUserInfoSqlStr];
    }
    //已改成联合查询（起初考虑到性能问题）
//    JLLog_I(@"sql array=%@", insertUserInfoSqlArray);
    [UserInfoCRUD insertUserInfoTableMultithread:insertUserInfoSqlArray];
}



+(void)userInfoReceivedSingleThread:(NSMutableArray *) userInfoArray{

    // NSString * myJID = [[NSString alloc] initWithFormat:@"%@", [XMPPServer xmppStream].myJID.bareJID];
    //  dispatch_async(dispatch_get_main_queue(), ^{
    if (userInfoArray.count==0) {
        return;
    }


    for (NSDictionary* dic in userInfoArray) {
        //NSLog(@"*******%@",dic);
        NSString *jid = [dic objectForKey: @"jid"];
        NSString *nickName = [dic objectForKey:@"nickName"];
        NSString *remarkName = [dic objectForKey: @"nickName"];
        NSString *phone = [dic objectForKey:@"phone"];
        NSString *avatar = [dic objectForKey:@"avatar"];
        NSString *version = [dic objectForKey:@"version"];
        NSString *remove = [dic objectForKey:@"remove"];

        NSLog(@"******%@,%@,%@",remove,nickName,version);
        if([remove isEqualToString:@"true"]){
            [UserInfoCRUD deleteUserInfoByJIDAndMyJID:jid myJID:MY_JID];
            continue;
        }

        //replace 语句
        [UserInfoCRUD insertUserInfoTable:jid remarkName:remarkName nickName:nickName phone:phone avatar:avatar ver:version myJID:MY_JID];

    }
    //   });
}
/*---所有订阅用户数据初始化 end------------------------------------------------------------*/


/*---接受App更新提示 start----------------------------------------------------------------*/
+(void)receiveAppUpdateResult:(NSNotification *) noti{

    NSDictionary* dic = [noti object];
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];

    NSString *currentVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];

    NSLog(@"********%@",[dic objectForKey:@"version"]);
    NSLog(@"********%@",currentVersion);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[dic objectForKey:@"url"] forKey:@"NSUD_EnterpriseURL"];


    if ([[dic objectForKey:@"version"] isEqualToString:currentVersion]) {
        if ([[defaults objectForKey:@"NSUD_CheckUpdate_Method"] isEqualToString:@"automatic_check_update"]) {
            return;
        }else{
            [self showAlertView:NSLocalizedString(@"checkVersion.message2",@"message")];
        }
    }else{
        //记录提示时间
        NSDate *nowDate = [NSDate date];
        [defaults setObject:nowDate forKey:@"NSUD_AppUpdatePromptTime"];

        [self showAlertView2:NSLocalizedString(@"checkVersion.message3",@"message") tag:10001 ];
    }
}

/*--个人信息 start-------------------------------------------------------------------*/
+(void)sendIQInformationList{
    /*
     <iq type=”get”>
     <query xmlns=”http://www.icircall.com/xmpp/userinfo“ >
     <user jid=””/> </query>
     </iq>
     */
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *userJid=[NSXMLElement elementWithName:@"user"];
    NSLog(@"jid:%@",[[NSUserDefaults standardUserDefaults]stringForKey:@"jid"]);
    [userJid addAttributeWithName:@"jid" stringValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"jid"]];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"personalInformation"];
    [queryElement addChild:userJid];
    [iq addChild:queryElement];
    NSLog(@"请求个人信息：%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
}
/*--个人信息 end-------------------------------------------------------------------*/




/*---获取服务器地址 start----------------------------------------------------------------*/
+(void)getServersUrl{
    //InviteUtil * util = [InviteUtil instance];
    InviteUtil * util = nil;
    NSString *promptStr=nil;
    if ([util isServersUrl]) {
        promptStr = [NSString stringWithFormat:@"http://%@:9000/address-servers", Server_Host];
        //NSString *promptStr = [util objectForkey:@"address-servers"];
        

    }else{
        promptStr = [NSString stringWithFormat:@"http://%@:9000/address-servers", Server_Host];

    }
    JLLog_I(@"******%@",promptStr);

    NSURL *url = [NSURL URLWithString:promptStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate: self];
    //[request setTimeOutSeconds:10];
    // [request setShouldAttemptPersistentConnection:NO];
    if ([StrUtility isBlankString:[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_XMPP_SERVERS"]]) {
        [request startSynchronous];
    }else{
        [request startAsynchronous];
    }
}

+ (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    NSData* jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resultsDictionary = [jsonData objectFromJSONData];
    NSString *xmppStr = [resultsDictionary objectForKey:@"xmpp"];
    NSString *httpStr = [resultsDictionary objectForKey:@"http"];
    NSString *tfsStr = [resultsDictionary objectForKey:@"tfs"];
    NSDictionary *urlDict = [resultsDictionary objectForKey:@"url"];
    NSString *footprintStr = @"";
    NSString *accountStr = @"";
    NSString *resourceStr = @"";
    NSString *questionStr = @"";
    NSString *myAccountStr = @"";
    NSString *communityStr = @"";
    NSString *readabilityStr = @"";
    NSString *friendCircleStr = @"";
    
    if(urlDict[@"footprint"]){
        footprintStr = [urlDict objectForKey:@"footprint"];
    }
    
    if(urlDict[@"account"]){
        accountStr = [urlDict objectForKey:@"account"];
    }
    
    if(urlDict[@"resource"]){
        resourceStr = [urlDict objectForKey:@"resource"];
    }
    
    if(urlDict[@"question"]){
        questionStr = [urlDict objectForKey:@"question"];
    }
    
    if(urlDict[@"myAccount"]){
        myAccountStr = [urlDict objectForKey:@"myAccount"];
    }
    
    if(urlDict[@"community"]){
        communityStr = [urlDict objectForKey:@"community"];
    }
    
    if(urlDict[@"readability"]){
        readabilityStr = urlDict[@"readability"];
    }
    
    if(urlDict[@"friendCircle"]){
        friendCircleStr = urlDict[@"friendCircle"];
    }
    
    NSString*str_character = @":";
    NSRange senderRange = [xmppStr rangeOfString:str_character];
    if ([xmppStr rangeOfString:str_character].location != NSNotFound) {
        xmppStr =[xmppStr substringToIndex:senderRange.location];
    }
    
    if (xmppStr != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:xmppStr forKey:@"NSUD_XMPP_SERVERS"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@%@",@"http://",httpStr] forKey:@"NSUD_HTTP_SERVERS"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@%@",@"http://",tfsStr] forKey:@"NSUD_TFS_SERVERS"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",footprintStr] forKey:@"NSUD_FOOTPRINT_ADDRESS"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",accountStr] forKey:@"NSUD_ACCOUNT_ADDRESS"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",myAccountStr] forKey:@"NSUD_MYACCOUNT_ADDRESS"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",resourceStr] forKey:@"NSUD_RESOURCE_ADDRESS"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",questionStr] forKey:@"NSUD_QUESTION_ADDRESS"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",communityStr] forKey:@"NSUD_COMMUNITY_ADDRESS"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",readabilityStr] forKey:@"NSUD_READABILITY_ADDRESS"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",friendCircleStr] forKey:@"NSUD_FRIENDCIRCLE_ADDRESS"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else{
        //return NO;
    }
    
    NSLog(@"*****%@/%@/%@",xmppStr,httpStr,tfsStr);
}


+(void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"******获取服务器地址失败:%@",error);
}


/*---获取服务器地址 end----------------------------------------------------------------*/

/*---添加好友 start----------------------------------------------------------------*/
/*
 Created by silenceSky  on 14-4-28.
 method 添加好友第一步查询好友信息并写入本地数据库
 */
+(void)queryContactsUserInfo:(NSString *)jid{
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *userJid=[NSXMLElement elementWithName:@"user"];
    // NSLog(@"jid:%@",[[NSUserDefaults standardUserDefaults]stringForKey:@"jid"]);

    //id 随机生成（须确保无重复）
    // NSLog(@"*******%@",[IdGenerator next]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[IdGenerator next] forKey:@"IQ_Add_Roster"];

    [userJid addAttributeWithName:@"jid" stringValue:jid];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[defaults stringForKey:@"IQ_Add_Roster"]];

    [queryElement addChild:userJid];
    [iq addChild:queryElement];
    //NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
}


+(void)addContactsSecondStep:(NSNotification*)notify{
    //NSLog(@"*****%@",notify.userInfo);

    // NSString *myJID = [[NSString alloc] initWithFormat:@"%@", [XMPPServer xmppStream].myJID.bareJID];

    NSString *jid = [notify.userInfo objectForKey:@"jid"];
    NSString *nickName = [notify.userInfo objectForKey:@"nickName"];
    NSString *phone = [notify.userInfo objectForKey:@"phone"];
    NSString *avatar = [notify.userInfo objectForKey:@"avatar"];
    // NSString *version = [notify.userInfo objectForKey:@"version"];
    NSString *timeStr = [Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];

    //写入userInfo
    [UserInfoCRUD insertUserInfoTable:jid remarkName:@"" nickName:nickName phone:phone avatar:avatar ver:@"" myJID:MY_JID];


    //写入contacts
    if ([ContactsCRUD queryContactsCountId:jid myJID:MY_JID]>0) {
        //已存在，不做处理；
        //[BuddyListCRUD updateBuddyListTable:jid buddyName:nickName myJID:myJID];
    }else{
        if (jid != nil && ![jid isEqualToString:@""] && jid !=NULL && ![jid isEqualToString:MY_JID]) {
            [ContactsCRUD insertContactsTable2:jid nickName:nickName name:@"" phone:phone avatar:avatar myJID:MY_JID];

            NSString *contactsUserName;
            NSString*str_character = @"@";
            NSRange senderRange = [jid rangeOfString:str_character];
            if ([jid rangeOfString:str_character].location != NSNotFound) {
                contactsUserName = [jid substringToIndex:senderRange.location];
            }

            [ChatBuddyCRUD insertChatBuddyTable:contactsUserName jid:jid name:@"" nickName:nickName phone:phone avatar:avatar myUserName:MY_USER_NAME type:@"chat" lastMsg:@"" msgType:@"chat" msgSubject:@"chat" lastMsgTime:timeStr tag:@"new"];
        }

    }
    //重新加载数据

    [self addContactsByUserName:jid];

    [DejalBezelActivityView removeViewAnimated:YES];
}


/*
 Created by silenceSky  on 14-4-28.
 method 添加好友第二步建立订阅关系
 */
+(void)addContactsByUserName:(NSString *)jid{
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addAttributeWithName:@"type" stringValue:@"subscribe"];
    [presence addAttributeWithName:@"to" stringValue:jid];
    [presence addAttributeWithName:@"id" stringValue:@"1003"];
    //NSLog(@"组装后的xml:%@",presence);
    [[XMPPServer xmppStream] sendElement:presence];

}


/*---添加好友 end----------------------------------------------------------------*/

/*---推送通知 start-------------------------------------------------------------*/
+(void)initRemoteNotifications{
    if (kIOS_VERSION>=8.0) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else{
        [[UIApplication sharedApplication]
                registerForRemoteNotificationTypes:
                        (UIRemoteNotificationTypeAlert |
                                UIRemoteNotificationTypeBadge |
                                UIRemoteNotificationTypeSound)];
    }
}

//重新发生token
+(void)resendToken{
    XMPPPresence *presence = [XMPPPresence presence];
    NSXMLElement *client = [NSXMLElement elementWithName:@"client" xmlns:@"http://www.nihualao.com/xmpp/client"];
    NSXMLElement *push = [NSXMLElement elementWithName:@"push"];
    NSXMLElement *os = [NSXMLElement elementWithName:@"os"];
    NSXMLElement *device = [NSXMLElement elementWithName:@"device"];

    [push addAttributeWithName:@"type" stringValue:@"apns2"];
    [push addAttributeWithName:@"token" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"]];

    [os setStringValue:[NSString stringWithFormat:@"%@-%@",@"IOS",[[UIDevice currentDevice] systemVersion]]];

    [presence addChild:client];
    [client addChild:push];
    [client addChild:os];
    [client addChild:device];

    // NSLog(@"组装后的xml:%@",presence);

    [[XMPPServer xmppStream]  sendElement:presence];
}

/*---推送通知 end-----------------------------------------------------------------------*/

/*---voip ui deal 通话结束   start-------------------------------------------------------*/
+(void)voipFinish:(NSNotification*)notify
{
    //VOIP 结束
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults removeObjectForKey:@"NSUD_VOIP_IsCall"];
    //
    //   if ([defaults boolForKey:@"NSUD_Tabbar_Loaded"]) {
    //   }else{
    //
    //       CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
    //       appDelegate .window.rootViewController = appDelegate.tabBarController;
    //       [appDelegate loadCustomTabBarView];
    //
    //   }
    //   dispatch_async(dispatch_get_main_queue(), ^{
#if !TARGET_IPHONE_SIMULATOR

    APPRTCViewController *appRTCVC = notify.object;
    //    NSLog(@"****%d",appRTCVC.talkTime);
    //    NSLog(@"*****%i",appRTCVC.isVideo);
    //    NSLog(@"*****%i",appRTCVC.isCaller);
    //    NSLog(@"******%i", STATE_NOTCONNECTION);
    //    NSLog(@"******%i", STATE_CANCEL);
    //    NSLog(@"******%i", appRTCVC.voip_staus);
    //    NSLog(@"******%@", appRTCVC.msgID);

    NSString *sendTimeStr = [Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    NSString *sendUTCTimeStr = [Utility getUTCFormateLocalDate:sendTimeStr];

    //未接通 STATE_NOTCONNECTION,

    //已接通 STATE_CONNECTION,

    //已取消  STATE_CANCEL,

    //已拒接 STATE_REJECT


    NSString *msg = NSLocalizedString(@"chatviewPublic.noConnect",@"message");
    if (appRTCVC.voip_staus == STATE_NOTCONNECTION) {
        //未接通
        msg = NSLocalizedString(@"chatviewPublic.noConnect",@"message");
    }else if(appRTCVC.voip_staus == STATE_CONNECTION){
        //通话时间
        if(appRTCVC.talkTime > 0){
            msg = NSLocalizedString(@"chatviewPublic.talkTime",@"message");
            NSString *timeStr = [Utility secondFormatTime:[NSString stringWithFormat:@"%d",appRTCVC.talkTime]];
            msg = [NSString stringWithFormat:@"%@%@",msg,[NSString stringWithFormat:@"%@",timeStr]];
       }
    }else if(appRTCVC.voip_staus == STATE_CANCEL){
        //已取消
        msg = NSLocalizedString(@"chatviewPublic.cancelled",@"message");

    }else if(appRTCVC.voip_staus == STATE_REJECT){
        //已拒接
        msg = NSLocalizedString(@"chatviewPublic.hasBeenRefused",@"message");

    }

    //  NSLog(@"*****%@",appRTCVC.from);

    NSString *senderName = @"";
    NSString*str_character = @"@";
    NSRange senderRange = [appRTCVC.from rangeOfString:str_character];
    if ([appRTCVC.from rangeOfString:str_character].location != NSNotFound) {
        senderName = [appRTCVC.from substringToIndex:senderRange.location];
    }

    if (appRTCVC.isCaller){
        //视频&语音
        if (appRTCVC.isVideo) {
            [ChatMessageCRUD insertChatMessage:MY_USER_NAME msg:msg receiveUser:senderName msgType:@"chat" subject:@"video" sendTime:sendUTCTimeStr
                                   receiveTime:sendUTCTimeStr  readMark:0 sendStatus:@"complete" msgRandomId:appRTCVC.msgID myJID:MY_JID];
        }else{
            [ChatMessageCRUD insertChatMessage:MY_USER_NAME msg:msg receiveUser:senderName msgType:@"chat" subject:@"phone" sendTime:sendUTCTimeStr receiveTime:sendUTCTimeStr readMark:0 sendStatus:@"complete" msgRandomId:appRTCVC.msgID myJID:MY_JID];
        }


        //发送通知，刷新聊天列表;
        // [[NSNotificationCenter defaultCenter] postNotificationName:@"chatBuddyView" object:self userInfo:nil];
        //发送通知，刷新聊天界面;
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"ChatVC_Refresh" object:self userInfo:nil];


    }else{

        // NSLog(@"**********%@",appRTCVC.msgID);

        //如果是被叫方，消息走另一方法处理写入，这里更新消息
        [ChatMessageCRUD updateMsgByMsgRandomId:appRTCVC.msgID msg:msg];
        //发送通知，刷新聊天列表;
        // [[NSNotificationCenter defaultCenter] postNotificationName:@"chatBuddyView" object:self userInfo:nil];
        //发送通知，刷新聊天界面;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatVC_Refresh" object:self userInfo:nil];

    }

    //查询聊天列表是否存在
    NSString *lastMsg = @"";
    NSString *type = @"chat";
    NSString *subject = @"";
    if (appRTCVC.isVideo == YES) {
        //[视频通话]
        lastMsg =  NSLocalizedString(@"chatviewPublic.videoCallFlag",@"message");
        subject = @"video";
    }else{
        //[语音通话]
        lastMsg =  NSLocalizedString(@"chatviewPublic.voiceCallFlag",@"message");
        subject = @"phone";
    }

    //NSString * myJID =  [NSString stringWithFormat:@"%@@%@",MY_USER_NAME, OpenFireHostName];
    NSString * senderJID = [NSString stringWithFormat:@"%@@%@",senderName, OpenFireHostName];


    //UserInfo *userInfo = [[[UserInfo alloc]init]autorelease];
    UserInfo *userInfo = [UserInfoCRUD queryUserInfo:senderJID myJID:MY_JID];
    NSString *remarkName = [ContactsCRUD queryContactsRemarkName:senderJID];
    if ([remarkName isEqualToString:@"(null)"]) {
        remarkName = @"";
    }

    NSString *lastMsgTime = [Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    if ([ChatBuddyCRUD queryChatBuddyTableCountId:senderName myUserName:MY_USER_NAME]==0){

        if (![userInfo.jid isEqualToString:@""] && userInfo.jid!=NULL && ![userInfo.jid isEqualToString:@"(null)"]) {

            [ChatBuddyCRUD insertChatBuddyTable:senderName jid:userInfo.jid name:remarkName nickName:userInfo.nickName phone:userInfo.phone avatar:userInfo.avatar myUserName:MY_USER_NAME type:@"chat" lastMsg:lastMsg msgType:type msgSubject:subject lastMsgTime:lastMsgTime tag:@""];


            //发送通知，更新聊天历史列表已存在此好友;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Update_Chat_Buddy_Flag" object:self userInfo:nil];
        }else{
            //陌生人电话
            [ChatBuddyCRUD insertChatBuddyTable:senderName jid:senderJID name:@"" nickName:@"" phone:@"" avatar:@"" myUserName:MY_USER_NAME type:@"chat" lastMsg:lastMsg msgType:type msgSubject:subject lastMsgTime:lastMsgTime tag:@""];

        }

    }else{

        [ChatBuddyCRUD updateChatBuddyTwo:senderName name:remarkName nickName:userInfo.nickName phone:userInfo.phone avatar:userInfo.avatar lastMsg:lastMsg msgType:type msgSubject:subject lastMsgTime:lastMsgTime];
    }

    //已拒接，通话时间:00:00，已取消
    if ([msg isEqualToString:NSLocalizedString(@"chatviewPublic.hasBeenRefused",@"message")] || (![msg isEqualToString:NSLocalizedString(@"chatviewPublic.talkTime2",@"message")] && ![msg isEqualToString:NSLocalizedString(@"chatviewPublic.cancelled",@"message")] )) {
        //更新消息状态为已读
        [ChatMessageCRUD updateFlagByUserName:senderName userName:MY_USER_NAME];
    }

    //发送通知，刷新聊天界面;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Chat_Buddy_View_Refresh2" object:self userInfo:nil];
#endif

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatVC_Refresh" object:self userInfo:nil];

    //外置声音播放模式
    // [[MPMusicPlayerController applicationMusicPlayer] setVolume:1.0];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    // });
}


#pragma mark - Show AlertView
+(void)showAlertView:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - Show AlertView
+(void)showAlertView2:(NSString *)message tag:(int)tag{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"title") otherButtonTitles:NSLocalizedString(@"public.alert.ok",@"title"), nil];
    alertView.tag = tag;
    [alertView show];
}

+(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==10001) {
        if (buttonIndex==1) {

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSURL *url = [NSURL URLWithString:[defaults objectForKey:@"NSUD_EnterpriseURL"]];
            //NSURL *url = [NSURL URLWithString:kUpgradeUrl];
            NSLog(@"*****%@",url);
            [[UIApplication sharedApplication]openURL:url];
        }
    }

}

+(void) getToKenInfo{
    BOOL needToGet = NO;
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"mytoken"];
    if(![StrUtility isBlankString:token]){
        long expiresIn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"mytokenExpiresIn"] longValue];
        long createTime = (long)[[[NSUserDefaults standardUserDefaults] objectForKey:@"mytokenCreateTime"] longValue];
        long currentTime = [[NSDate date] timeIntervalSince1970];
        if(currentTime - createTime > expiresIn - 86400L){
            needToGet = YES;
        }
    } else {
        needToGet = YES;
    }

    if(needToGet){
        NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/token"];
        
        NSString* qTime =  [NSString stringWithFormat:@"%ld", (long)[[NSDate dateWithTimeIntervalSinceNow:0]timeIntervalSince1970] ];
        NSString* qnum = [NSString stringWithFormat:@"%d", arc4random() % 10000 + 10000];
        NSString* iqId = [NSString stringWithFormat: @"iOS%@%@", qTime, qnum];
        
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"type" stringValue:@"get"];
        [iq addAttributeWithName:@"id" stringValue:iqId];
        [iq addChild:queryElement];
        //NSLog(@"组装后的xml:%@",iq);
        [[XMPPServer xmppStream] sendElement:iq];
    }
}

-(void) getToken{

}

@end
