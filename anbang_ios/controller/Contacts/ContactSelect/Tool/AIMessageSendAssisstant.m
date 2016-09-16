//
//  AIMessageSendAssisstant.m
//  anbang_ios
//
//  Created by rooter on 15-5-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIMessageSendAssisstant.h"
#import "AIRemessage.h"
#import "Utility.h"
#import "IdGenerator.h"
#import "UserInfoCRUD.h"
#import "ChatMessageCRUD.h"
#import "ChatBuddyCRUD.h"
#import "Contacts.h"
#import "GroupChatMessageCRUD.h"
#import "JSMessageSoundEffect.h"
#import "GroupCRUD.h"
#import "ChatGroup.h"
#import "AIDocument.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.H"
#import "MJExtension.h"
#import "AIChatResourceCache.h"
#import "AIMessageTool.h"
#import "AIPersonalCard.h"
#import "AIDocument.h"

@implementation AIMessageSendAssisstant {
    
    NSMutableArray  *mRemessages;
    NSString *mFromUserName;  // For searching image.
    NSDictionary    *mContact;
    AIChatType      mChatType;
    AIChatResourceCache *mResourceCache;
    NSString *mSpeaker;
}

- (id)initWithFromUserName:(NSString *)aUserName {
    self = [super init];
    if (self) {
        mFromUserName = aUserName;
    }
    return self;
}


#pragma mark
#pragma mark setter & getter

- (void)setMessages:(NSArray *)messages {
    mRemessages = [NSMutableArray array];
    for (NSDictionary *message in messages) {
        AIRemessage *aMessage = [[AIRemessage alloc] initWithDictionary:message];
        [mRemessages addObject:aMessage];
    }
}

#pragma end

#pragma mark
#pragma mark common

- (void)copyFileToDocumentCacheNamed:(NSString *)TFSLink
                      sourceDocument:(AIDocument *)document {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = [fileManager contentsAtPath:document.link];
    [mResourceCache storeDocument:data type:document.fileType forKey:TFSLink];
}

#pragma end

#pragma mark
#pragma mark private

- (NSString *)jidWithUserName:(NSString *)userName {
    return [NSString stringWithFormat:@"%@@%@", userName, OpenFireHostName];
}

- (void)chatMessageWriteToDatabase:(AIRemessage *)message
                          callback:(void(^)(NSString *time, NSString *randomId, NSString *subject))callback {
    
    NSString * msgRandomId = [IdGenerator next];
    NSString *timeString   = Utility.getCurrentDate;
    NSString *network = @"connection";
    NSString *sendTimeStr =[Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    NSString *sendUTCTimeStr = [Utility getUTCFormateLocalDate:sendTimeStr];
    NSString *userName = mContact[@"userName"];
    NSString *_chatWithJID  = [self jidWithUserName:userName];
    UserInfo *userInfo = [UserInfoCRUD queryUserInfo:userName myJID:MY_JID];
    NSString *remarkName = ![StrUtility isBlankString:userInfo.remarkName] ? userInfo.remarkName : userInfo.nickName;
    
    JLLog_I(@"chatWithUser=%@, chatWithJID=%@, remarkName=%@", userName, _chatWithJID, remarkName);
    
    
    // If message type is document or image
    // then copy to detiny cache directory.
    NSString *subject = nil;
    NSString *lastMsg = nil;
    switch (message.messageType) {
        case AIRemessageTypeCard: {
            subject = @"card";
            AIPersonalCard *card = [AIPersonalCard cardWithJson:message.text];
            lastMsg = [NSString stringWithFormat:@"您推荐了%@", card.name];
        }
            break;
            
        case AIRemessageTypeDocument: {
            subject = @"document";
            AIDocument *doc = [AIDocument documentWithJson:message.text];
            lastMsg = doc.fileName;
        }
            break;
        case AIRemessageTypeLocation: {
            subject = @"location";
            lastMsg = @"您发送了一个地理位置";
        }
            break;
        case AIRemessageTypeChat:
            subject = @"chat";
            lastMsg = message.text;
            break;
        
        case AIRemessageTypeImage: {
            subject = @"image";
            lastMsg = @"[图片]";
            
            NSString *aKey = [AIMessageTool HDImageLinkIdWithMessage:message.text];
            AIChatResourceCache *sourceCache = [AIChatResourceCache cacheWithUserName:mFromUserName];
            NSString *tfsLink =[NSString stringWithFormat:@"%@/%@",ResourcesURL, aKey];
            UIImage *aImage = [sourceCache imageForKey:tfsLink];
            if (aImage) {
                JLLog_I(@"Image exists in <%@>", mFromUserName);
                [mResourceCache storeImage:aImage forKey:tfsLink];
            }
        }
            break;
            
        case AIRemessageTypeArticle: {
            subject = @"article";
            lastMsg = @"[链接]";
        }
            break;
            
        default:
            break;
    }
    
    [ChatMessageCRUD insertChatMessage:MY_USER_NAME msg:message.text receiveUser:userName msgType:@"chat" subject:subject sendTime:sendUTCTimeStr receiveTime:sendUTCTimeStr readMark:1 sendStatus:network msgRandomId:msgRandomId myJID:MY_JID];
    
    Contacts *contacts = nil;
    contacts = [ChatBuddyCRUD queryBuddyByJID:_chatWithJID myJID:MY_JID];
    NSString *lastMsgTime = [Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    
    BOOL chatBuddyFlag = [ChatBuddyCRUD queryChatBuddyTableCountId:userName myUserName:MY_USER_NAME] > 0 ? YES : NO;
    if(chatBuddyFlag == NO){
        [ChatBuddyCRUD insertChatBuddyTable:userName jid:contacts.jid name:remarkName nickName:contacts.nickName phone:contacts.phone avatar:contacts.avatar myUserName:MY_USER_NAME type:@"chat" lastMsg:lastMsg msgType:@"chat" msgSubject:subject lastMsgTime:lastMsgTime tag:@""];
    }else{
        [ChatBuddyCRUD updateChatBuddy:userName name:remarkName nickName:contacts.nickName lastMsg:lastMsg msgType:@"chat" msgSubject:subject lastMsgTime:lastMsgTime];
    }
    
    if ([mFromUserName isEqualToString:mContact[@"userName"]]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(reloadMessages:)]) {
            [self.delegate reloadMessages:@[msgRandomId]];
        }
    }
    
    callback(timeString, msgRandomId, subject);
}

- (void)chatMessageXML:(NSString *)aRandomId
                  time:(NSString *)aTime
                  boby:(NSString *)aText
               subject:(NSString *)aSubject
              complete:(void(^)())complete {
    
    NSString *userName = mContact[@"userName"];
    NSString *_chatWithJID  = [self jidWithUserName:userName];
    
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    [mes addAttributeWithName:@"id" stringValue:aRandomId];
    [mes addAttributeWithName:@"type" stringValue:@"chat"];
    [mes addAttributeWithName:@"to" stringValue:_chatWithJID];
    [mes addAttributeWithName:@"from" stringValue:MY_USER_NAME];
    [mes addAttributeWithName:@"time" stringValue:aTime];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:aText];
    NSXMLElement *subject = [NSXMLElement elementWithName:@"subject" stringValue:aSubject];
    
    NSXMLElement *req = [NSXMLElement elementWithName:@"req" xmlns:@"urn:xmpp:receipts"];
    [req addAttributeWithName:@"id" stringValue:aRandomId];
    
    NSXMLElement *mtype = [NSXMLElement elementWithName:@"mtype"  xmlns:@"message:type"];
    [mtype setStringValue:aSubject];
    
    [mes addChild:mtype];
    [mes addChild:subject];
    [mes addChild:body];
    [mes addChild:req];
    
    JLLog_I(@"mes=%@", mes);
    
    //发送消息
    [[XMPPServer xmppStream] sendElement:mes];
    
    if (complete) {
        complete();
    }
}

- (void)chatSendMessage:(AIRemessage *)message {
    [self chatMessageWriteToDatabase:message callback:^(NSString *time, NSString *randomId, NSString *subject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self chatMessageXML:randomId time:time boby:message.text subject:subject complete:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [JSMessageSoundEffect playMessageSentSound];
            });
        });
    }];
}

- (void)sendDocumentMessageWithTFSLink:(NSString *)link
                              document:(AIDocument *)document
                                  time:(NSString *)aTime
                                random:(NSString *)aRandomId {
    
    NSString *sourceLink = document.link;
    document.link = link;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:document.keyValues
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *text = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
    NSDictionary *message = @{@"text" : text, @"subject" : @"document"};
//    AIRemessage *remessage = [[AIRemessage alloc] initWithDictionary:message];
//    [self chatSendMessage:remessage];
    [self chatMessageXML:aRandomId time:aTime boby:text subject:@"document" complete:^{
        [ChatMessageCRUD updateMsgByMsgRandomId:aRandomId msg:text];
    }];
    
    document.link = sourceLink;
    [self copyFileToDocumentCacheNamed:link sourceDocument:document];
}

// upload document data..
- (void)uploadDocument:(NSMutableData *)data
              document:(AIDocument *)document
                random:(NSString *)aRandomId
                  time:(NSString *)aTime
{
    NSString *urlstr = ResourcesURL;
    NSURL *myurl = [NSURL URLWithString:urlstr];
    ASIFormDataRequest  *request = [ASIFormDataRequest requestWithURL:myurl];
    [request setPostBody:data];
    [request buildRequestHeaders];
    
    // Using block...
    request.completionBlock = ^{
        NSData *jsonData = [request responseData];
        NSDictionary *d = [jsonData objectFromJSONData];
        NSString *link = d[@"TFS_FILE_NAME"];
        [self sendDocumentMessageWithTFSLink:link document:document time:aTime random:aRandomId];
    };
    
//    __weak typeof(self)wself = self;
    [request setFailedBlock:^{
//        [AIControllersTool tipViewShow:@"文件上传失败"];
//        if (wself.delegate && [wself.delegate respondsToSelector:@selector(messageSendingAbort:)]) {
//            [wself.delegate messageSendingAbort:@[aRandomId]];
//        }
    }];
    
    [request startAsynchronous];
}

- (void)chatSendDocument:(AIRemessage *)message {
    AIDocument *document = [AIDocument documentWithJson:message.text];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:document.link];
    if (isExists) {
        NSData *data = [fileManager contentsAtPath:document.link];
        [self chatMessageWriteToDatabase:message callback:^(NSString *aTime, NSString *aRandomId, NSString *aSubject) {
            [self uploadDocument:[NSMutableData dataWithData:data] document:document random:aRandomId time:aTime];
        }];
    }else {
        [self chatMessageWriteToDatabase:message callback:^(NSString *time, NSString *randomId, NSString *subject) {
            [self chatMessageXML:randomId time:time boby:message.text subject:subject complete:nil];
            AIChatResourceCache *cache = [AIChatResourceCache cacheWithUserName:mFromUserName];
            [cache copyItemWithKey:document.link type:document.fileType to:mContact[@"userName"]];
        }];
    }
}


#pragma end

- (void)chatSendMessages {
    for (AIRemessage *message in mRemessages) {
        switch (message.messageType) {
            case AIRemessageTypeChat:
            case AIRemessageTypeCard:
            case AIRemessageTypeImage:
            case AIRemessageTypeArticle:
                [self chatSendMessage:message];
                break;

            case AIRemessageTypeDocument:
                [self chatSendDocument:message];
                break;
            case AIRemessageTypeLocation:
                [self chatSendDocument:message];
                break;
            default:
                break;
        }
    }
}

- (void)sendMessagesTo:(NSDictionary *)contact {
    mContact = contact;
    mChatType = [@"chat" isEqualToString:mContact[@"type"]] ? AIChatTypeChat : AIChatTypeGroup;
    mResourceCache = [AIChatResourceCache cacheWithUserName:contact[@"userName"]];
    JLLog_I(@"To <userName=%@>", contact[@"userName"]);
    switch (mChatType) {
        case AIChatTypeChat:
            [self chatSendMessages];
            break;
            
        case AIChatTypeGroup:
            [self groupChatSendMessages];
            break;
            
        default:
            break;
    }
}


#pragma mark 
#pragma mark Group part

- (void)groupChatSendMessages {
    for (AIRemessage *message in mRemessages) {
        switch (message.messageType) {
            case AIRemessageTypeChat:
            case AIRemessageTypeCard:
            case AIRemessageTypeImage:
            case AIRemessageTypeArticle:
                [self gorupSendMessage:message];
                break;
                
            case AIRemessageTypeDocument:
                [self groupChatSendDocument:message];
                break;
            default:
                break;
        }
    }
}

- (void)groupMessageXML:(NSString *)aRandomId
                   body:(NSString *)aText
                subject:(NSString *)aSubject
              roomMucId:(NSString *)aMucId complete:(void(^)())complete {
    
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message" xmlns:@"jabber:client"];
    
    [mes addAttributeWithName:@"id" stringValue:aRandomId];
    [mes addAttributeWithName:@"type" stringValue:@"groupchat"];
    [mes addAttributeWithName:@"to" stringValue:aMucId];
    [mes addAttributeWithName:@"from" stringValue:MY_USER_NAME];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:aText];
    
    NSXMLElement *mSubject = [NSXMLElement elementWithName:@"subject" stringValue:aSubject];
    
    NSXMLElement *mtype = [NSXMLElement elementWithName:@"mtype"  xmlns:@"message:type"];
    [mtype setStringValue:aSubject];
    
    NSXMLElement *req = [NSXMLElement elementWithName:@"req" xmlns:@"urn:xmpp:receipts"];
    [req addAttributeWithName:@"id" stringValue:aRandomId];

    [mes addChild:mtype];
    [mes addChild:mSubject];
    [mes addChild:body];
    [mes addChild:req];
    
    JLLog_I(@"%@", mes);
    [[XMPPServer xmppStream] sendElement:mes];
    
    if (complete) {
        complete();
    }
}

- (void)groupChatSendDocument:(AIRemessage *)message
{
    AIDocument *document = [AIDocument documentWithJson:message.text];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:document.link];
    // If "document.link" is TFS link, file would not exists,
    // then just go ahead and send message XML without uploading data.
    if (isExists) {
        NSData *data = [fileManager contentsAtPath:document.link];
        [self groupChatMessageWriteToDatabase:message callback:^(NSString *aRandomId, NSString *aRoomName, NSString *aSubject) {
            [self groupUploadDocument:[NSMutableData dataWithData:data] document:document random:aRandomId roomMucId:aRoomName];
        }];
    }else {
        [self groupChatMessageWriteToDatabase:message callback:^(NSString *aRandomId, NSString *aRoomName, NSString *aSubject) {
            [self groupMessageXML:aRandomId body:message.text subject:aSubject roomMucId:aRoomName complete:nil];
            AIChatResourceCache *cache = [AIChatResourceCache cacheWithUserName:mFromUserName];
            [cache copyItemWithKey:document.link type:document.fileType to:mContact[@"userName"]];
        }];
    }
}

- (void)groupUploadDocument:(NSMutableData *)data
                   document:(AIDocument *)document
                     random:(NSString *)aRandomId
                  roomMucId:(NSString *)aMucId
{
    NSString *urlstr = ResourcesURL;
    NSURL *myurl = [NSURL URLWithString:urlstr];
    ASIFormDataRequest  *request = [ASIFormDataRequest requestWithURL:myurl];
    [request setPostBody:data];
    [request buildRequestHeaders];
    
    // Using block...
    request.completionBlock = ^{
        NSData *jsonData = [request responseData];
        NSDictionary *d = [jsonData objectFromJSONData];
        NSString *link = d[@"TFS_FILE_NAME"];
        [self groupChatSendDocumentWithTFSLink:link
                                      document:document
                                      randomId:aRandomId
                                       subject:@"document"
                                     roomMucId:aMucId];
    };
    
//    __weak typeof(self)wself = self;
    [request setFailedBlock:^{
//        [AIControllersTool tipViewShow:@"文件上传失败"];
//        if (wself.delegate && [wself.delegate respondsToSelector:@selector(messageSendingAbort:)]) {
//            [wself.delegate messageSendingAbort:@[aRandomId]];
//        }
    }];
    
    [request startAsynchronous];
}

- (void)groupChatSendDocumentWithTFSLink:(NSString *)link
                                document:(AIDocument *)document
                                randomId:(NSString *)aRandomId
                                 subject:(NSString *)aSubject
                               roomMucId:(NSString *)aMucId
{
    NSString *sourceLink = document.link;
    document.link = link;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:document.keyValues
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *text = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
//    NSDictionary *message = @{@"text" : text, @"subject" : @"document"};
//    AIRemessage *remessage = [[AIRemessage alloc] initWithDictionary:message];
//    [self gorupSendMessage:remessage];
    [self groupMessageXML:aRandomId
                     body:text
                  subject:aSubject
                roomMucId:aMucId complete:^{
                    [GroupChatMessageCRUD updateGroupChatMsgStr:aRandomId msg:text groupMucId:aMucId];
                }];
    
    document.link = sourceLink;
    [self copyFileToDocumentCacheNamed:link sourceDocument:document];
}

- (void)groupChatMessageWriteToDatabase:(AIRemessage *)message
                               callback:(void(^)(NSString *aRandomId, NSString *aRoomName, NSString *aSubject))callback {
    
    NSString *_roomName = mContact[@"userName"];
    ChatGroup *group = [GroupCRUD queryChatGroupByJID:_roomName myJID:MY_JID];
    NSString * msgRandomId = [IdGenerator next];
    //检测网络情况
    NSString *network = @"connection";
    
    NSString *sendTimeStr =[Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    NSString *sendUTCTimeStr = [Utility getUTCFormateLocalDate:sendTimeStr];
    
    //播放提示音
    [JSMessageSoundEffect playMessageSentSound];
    
    NSString *lastMessage = nil;
    NSString *subject = nil;
    switch (message.messageType) {
        case AIRemessageTypeCard: {
            AIPersonalCard *card = [AIPersonalCard cardWithJson:message.text];
            lastMessage = [NSString stringWithFormat:@"您推荐了%@", card.name];
            subject = @"card";
        }
            break;
        
        case AIRemessageTypeDocument: {
            AIDocument *doc = [AIDocument documentWithJson:message.text];
            lastMessage = [NSString stringWithFormat:@"我：%@", doc.fileName];
            subject = @"document";
        }
            break;
        case AIRemessageTypeLocation: {
            lastMessage = @"您发送了一个地理位置";
            subject = @"location";
        }
            break;
        case AIRemessageTypeImage: {
            lastMessage = @"我：[图片]";
            subject = @"image";
            
            NSString *aKey = [AIMessageTool HDImageLinkIdWithMessage:message.text];
            AIChatResourceCache *sourceCache = [AIChatResourceCache cacheWithUserName:mFromUserName];
            NSString *tfsLink = [NSString stringWithFormat:@"%@/%@",ResourcesURL, aKey];
            UIImage *aImage = [sourceCache imageForKey:tfsLink];
            if (aImage) {
                JLLog_I(@"Image exists in <%@>", mFromUserName);
                [mResourceCache storeImage:aImage forKey:tfsLink];
            }
        }
            break;
            
        case AIRemessageTypeArticle: {
            subject = @"article";
            lastMessage = @"[链接]";
        }
            break;
            
        case AIRemessageTypeChat:
            lastMessage = message.text;
            subject = @"chat";
            break;
            
            
        default:
            break;
    }
    
    [GroupChatMessageCRUD insertGroupChatMessage:_roomName sendUser:MY_USER_NAME msg:message.text type:@"groupchat" msgType:subject sendTime:sendUTCTimeStr receiveTime:sendUTCTimeStr readMark:1 sendStatus:network msgRandomId:msgRandomId myJID:MY_JID];
    //查询聊天列表是否存在
    NSString *lastMsgTime = [Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    BOOL chatBuddyFlag = [ChatBuddyCRUD queryChatBuddyTableCountId:_roomName myUserName:MY_USER_NAME] > 0 ? YES : NO;
    if(chatBuddyFlag == NO){
        [ChatBuddyCRUD insertChatBuddyTable:_roomName jid:group.jid name:group.name nickName:@"" phone:@"" avatar:@"" myUserName:MY_USER_NAME type:@"groupchat" lastMsg:lastMessage msgType:@"groupchat" msgSubject:subject lastMsgTime:lastMsgTime tag:@""];
    }else{
        [ChatBuddyCRUD updateChatBuddy:_roomName name:group.name nickName:@"" lastMsg:lastMessage msgType:@"groupchat" msgSubject:subject lastMsgTime:lastMsgTime];
    }
    
    if ([mFromUserName isEqualToString:mContact[@"userName"]]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(reloadMessages:)]) {
            [self.delegate reloadMessages:@[msgRandomId]];
        }
    }
    
    callback(msgRandomId, _roomName, subject);
}

- (void)gorupSendMessage:(AIRemessage *)message
{
    [self groupChatMessageWriteToDatabase:message callback:^(NSString *aRandomId, NSString *aRoomName, NSString *aSubject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self groupMessageXML:aRandomId body:message.text subject:aSubject roomMucId:aRoomName complete:nil];
        });
    }];
}

#pragma end

@end
