//
//  XMPPServer.h
//  anbang_ios
//
//  Created by silenceSky  on 14-4-18.
//  Copyright (c) 2014年 ch. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "KKChatDelegate.h"
#import "KKMessageDelegate.h"
#import "KKGroupChatDelegate.h"
#import "GroupMessageDelegate.h"
#import "ContactModule.h"

extern NSString *const XMPPServerDidDisconnectNotification;


#if !TARGET_IPHONE_SIMULATOR
#import "VoipModule.h"
#endif
@protocol XMPPServerDelegate <NSObject>

-(void)setupStream;
-(void)getOnline;
-(void)getOffline;

@end

@interface XMPPServer : NSObject<XMPPServerDelegate,XMPPRosterDelegate,UIAlertViewDelegate
#if !TARGET_IPHONE_SIMULATOR
,VoipDelegate
#endif
>{
    XMPPStream *xmppStream;
    
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    NSString *password;
    BOOL isOpen;
    UIAlertView *Alert;
    XMPPServer *xmppServer;
    
}

@property (nonatomic,retain) XMPPServer *xmppServer;
//silencesky upd
@property(nonatomic,assign)BOOL isLogin;
//silencesky upd 1 开始登录  2 登录成功 3 登录失败 4 不再重连 5 网络恢复
@property int loginFlag;
//reloginTimer重连的最大次数
@property int reloginCount;

@property(nonatomic,retain)NSString * downloadUrl;



@property (retain, nonatomic) UIWindow *window;
@property (nonatomic, retain, readonly) XMPPStream *xmppStream;
@property (nonatomic, retain, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, retain, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, retain, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, retain, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, retain, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, retain, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, retain, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property (nonatomic, retain)  id<KKChatDelegate>       chatDelegate;
@property (nonatomic, retain)  id<KKMessageDelegate>    messageDelegate;
@property (nonatomic, retain)  id<KKGroupChatDelegate>    groupChatDelegate;
@property (nonatomic, retain)  id<GroupMessageDelegate>    groupMessageDelegate;
@property (nonatomic, retain, readonly) ContactModule *contactModule;
@property (nonatomic, strong) NSTimer *reLoginTimer;


#if !TARGET_IPHONE_SIMULATOR
@property(nonatomic,retain) VoipModule* voipModule;
#endif
- (void)showAlertView:(NSString *)message;//show alertview

+(XMPPServer *)sharedServer;

-(BOOL)connect;

-(void)disconnect;

-(void)sendABContactInfoIQ:(NSString*)userName;

@end
