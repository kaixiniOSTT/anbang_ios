//
//  XMPPServer.m
//  anbang_ios
//
//  Created by silenceSky  on 14-4-18.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "XMPPServer.h"
#import "XMPPPresence.h"
#import "XMPPJID.h"
#import "GroupMembers.h"

#import "GroupChatMessageCRUD.h"
#import "ChatMessageCRUD.h"
#import "NewsListCRUD.h"
#import "NewsCRUD.h"
#import "UserNameCRUD.h"
#import "CHAppDelegate.h"
#if !TARGET_IPHONE_SIMULATOR
#import "VoipModule.h"
#import "APPRTCViewController.h"
#endif
#import "JSONKit.h"
#import "AddressBookCRUD.h"
#import "ChatGroup.h"
#import "ChatInit.h"
#import "CHAppDelegate.h"
#import "PublicCURD.h"
#import "CHAppDelegate.h"
#import "IQIDDefine.h"
#import "XMPPStream.h"
#import "XMPPServer+Add.m"
#import "MyServices.h"
#import "UserInfo.h"
#import "ContactModule.h"
#import "ContactsCRUD.h"
#import "UserInfoCRUD.h"
#import "ChatBuddyCRUD.h"
#import "GroupMembersCRUD.h"
#import "DndInfoCRUD.h"
#import "GroupCRUD.h"
#import "AICollection.h"
#import "AICollectionCRUD.h"
#import "Utility.h"
#import "AIOrganization.h"
#import "AIOrganizationCRUD.h"
#import "AIABSearchContact.h"
#import "AINewFriendsCRUD.h"
#import "NSString+Chinese.h"
#import "AIUsersUtility.h"
#import "AIPersonalCard.h"
#import "AIDocument.h"
#import "AIMessagesManager.h"

NSString *const XMPPServerDidDisconnectNotification = @"XMPPServerDidDisconnectNotification";

static XMPPServer *singleton = nil;

@implementation XMPPServer
@synthesize xmppServer;
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;

@synthesize chatDelegate;
@synthesize messageDelegate;
@synthesize groupChatDelegate;
@synthesize groupMessageDelegate;
@synthesize contactModule;

@synthesize isLogin;
@synthesize loginFlag;
@synthesize downloadUrl;
@synthesize reLoginTimer;
@synthesize reloginCount;


#pragma mark - singleton
+(XMPPServer *)sharedServer{
    @synchronized(self){
        if (singleton == nil) {
            singleton = [[self alloc] init];
        }
    }
    return singleton;
    
}

+(id)allocWithZone:(NSZone *)zone{
    
    @synchronized(self){
        if (singleton == nil) {
            singleton = [super allocWithZone:zone];
            return singleton;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone{
    return singleton;
}

//-(id)retain{
//    return singleton;
//}
//
//-(oneway void)release{
//}
//
//+(id)release{
//    return nil;
//}
//
//-(id)autorelease{
//    return singleton;
//}
//
//-(void)dealloc{
//    [self teardownStream];
//    [super dealloc];
//}


#pragma mark - private
-(void)setupStream{
    // NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
    xmppStream = [[XMPPStream alloc] init];
    xmppStream.enableBackgroundingOnSocket = YES;
    
    
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        
        //xmppStream.enableBackgroundingOnSocket = NO;
    }
#endif
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    //silencesky upd
    //xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    // Setup capabilities
    //
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    //
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    //
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    
    // Activate xmpp modules
    //silencesky upd
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Optional:
    //
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    //
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    //
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    //	[xmppStream setHostName:@"talk.google.com"];
    //    [xmppStream setHostName:@"192.168.2.226"];
    //	[xmppStream setHostPort:5222];
}

- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    //silencesky upd
    [xmppReconnect         deactivate];
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
    [contactModule      deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesStorage = nil;
    contactModule= nil;
}

-(void)getOnline{
    //发送在线状态
    XMPPPresence *presence = [XMPPPresence presence];
    [xmppStream sendElement:presence];
}

-(void)getOffline{
    //发送下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

-(BOOL)connect{
    [self showServerDisconnectStatus];//正在连接...
    self.isLogin = NO;
    loginFlag = 1; //开始登录
    [self setupStream];
    //从本地取得用户名，密码和服务器地址
    JLLog_D(@"从本地取得用户名，密码和服务器地址,开始登录！") ;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults stringForKey:@"userName"];
    NSString *pass = [defaults stringForKey:@"password"];
    NSString *server = [defaults stringForKey:@"server"];
    
    server = OpenFireUrl;
    
    if (server == nil) {
        return NO;
    }
    
    JLLog_D(@"*****%@",server);
    JLLog_D(@"******%@,%@",userId,pass);
    password = pass;
    
    if (![self.xmppStream isDisconnected]) {
        return YES;
    }
    
    if (userId <= 0) {
        return NO;
    }
    //设置用户：user1@chtekimacbook-pro.local格式的用户名
    NSString *jid=[NSString stringWithFormat:@"%@@%@/%@",userId,OpenFireHostName,@"Hisuper"];
    [[NSUserDefaults standardUserDefaults]setObject:jid forKey:@"jid"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    JLLog_D("Start connect Xmpp server (jid=%@, hostname=%@)",jid,server);
    
    [xmppStream setMyJID:[XMPPJID jidWithString:jid]];
    //设置服务器
    [xmppStream setHostName:server];
    
    //连接服务器
    NSError *error = nil;
    
    // if ( ![xmppStream connect:&error]) {
    if (![xmppStream connectWithTimeout:60 error:&error]) {//新版本的xmpp
        NSLog(@"cant connect %@", server);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"password"];
        [defaults removeObjectForKey:@"confirmPassword"];
        return NO;
    }
    return YES;
}


//- (void)loginAuthenticate{
//    NSString *psd = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
//    NSString *username=[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
//    //    NSString *mechanism = nil;
//    NSError *error = nil;
//    if ([username isEqual:@"anonymouss"]) {
//        //**********移除本地账号信息*************
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults removeObjectForKey:@"userName"];
//        [defaults removeObjectForKey:@"password"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        return;
//        //************************************
//    }
//    if (![self.xmppStream authenticateWithPassword:psd error:&error]) {
//        JLLog_D(@"Authenticate Error: %@", [[error userInfo] description]);
//        
//    }else{
//        //
//        //
//    }
//}

//断开服务器连接
-(void)disconnect{
    [self getOffline];
    [xmppStream disconnect];
    //[[ContactModule shareContactModule]unregisterCallback];//注销通讯录监听
    
}


#pragma mark - Show AlertView
-(void)showAlertView:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - Show AlertView
-(void)showAlertView2:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"title") otherButtonTitles:NSLocalizedString(@"public.alert.ok",@"title"), nil];
    
    [alertView show];
}


#pragma mark - XMPPStream delegate
//连接服务器
//xmppStream:didNotAuthenticate:
- (void)xmppStreamWillConnect:(XMPPStream *)sender
{
    JLLog_D(@"启动连接操作后回调 表示将要连接 xmppStreamWillConnect");
    
}


- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    JLLog_D(@"连接服务器成功调用－－验证帐户密码xmppStreamDidConnect");
    //    isOpen = YES;
    NSString *psd = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    NSString *username=[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    //    NSString *mechanism = nil;
    NSError *error = nil;
    if ([username isEqual:@"anonymouss"]) {
        //**********移除本地账号信息*************
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"userName"];
        [defaults removeObjectForKey:@"password"];
        [defaults removeObjectForKey:@"confirmPassword"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
        //************************************
    }
    if (![self.xmppStream authenticateWithPassword:psd error:&error]) {
        JLLog_D(@"Authenticate Error: %@", [[error userInfo] description]);
        
    }else{
    }
    //    68[[NSNotificationCenter defaultCenter]postNotificationName:@"theRegister" object:nil userInfo:nil];
    
    
}


- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    
    JLLog_D(@"登陆失败的回调didNotAuthenticate:%@",error.description);
    //**********移除本地账号信息*************
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults removeObjectForKey:@"userName"];
//    [defaults removeObjectForKey:@"password"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    //************************************
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"NSN_Login_Failure" object:nil userInfo:nil];
    //[self showAlertView:@"密码错误"];
}



//连接服务器错误
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    JLLog_D(@"与服务器断开连接！%@",error.description);
    
    //[[NSNotificationCenter defaultCenter]
    // postNotificationName:XMPPServerDidDisconnectNotification object:nil];
    
    
    //显示正在连接;
    NSTimer *titleTimer;
    int timeInt = 0;
    titleTimer=[NSTimer scheduledTimerWithTimeInterval:timeInt
                                                target:self
                                              selector:@selector(showServerDisconnectStatus)
                                              userInfo:nil
                                               repeats:NO];
    
    //后台停止运行时，不再重连；
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"NSUD_backgroundTaskStatus"] &&self.loginFlag != 4 && loginFlag != 5){
        NSLog(@"开始重连...%d",self.loginFlag);
        
        int reloginTimeInt = 10;
        [reLoginTimer invalidate];
        reLoginTimer = nil;
        reLoginTimer=[NSTimer scheduledTimerWithTimeInterval:reloginTimeInt
                                                      target:self
                                                    selector:@selector(loginApp)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    
    
    self.isLogin = NO;
    loginFlag = 3; //登录失败
    //重新获取服务器地址
    [ChatInit getServersUrl];
    
    NSString *username=[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    if ([username isEqual:@"anonymouss"]) {
        //**********移除本地账号信息*************
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"userName"];
    }
    
}


//通知界面显示连接状态
- (void)showServerDisconnectStatus{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"NNC_Server_Disconnect" object:self userInfo:nil];
}


- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    JLLog_D(@"登陆成功的回调－－可以加上上线状态 xmppStreamDidAuthenticate");
    
    JLLog_D("Did login");
    
    //记录登录成功
    self.isLogin = YES;
    loginFlag = 2; //登录成功
    //初始化voip
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_VOIP_Init" object:self userInfo:nil];

    
    //[UserNameCRUD insertIDtable:[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"]];
    
    //发送上线
    
    //发送设备信息（apns)
    
    XMPPPresence *presence = [XMPPPresence presence];
    
    NSXMLElement *client = [NSXMLElement elementWithName:@"client" xmlns:@"http://www.nihualao.com/xmpp/client"];
    //    NSXMLElement *deviceToken = [NSXMLElement elementWithName:@"deviceToken"];
    //    NSXMLElement *appid = [NSXMLElement elementWithName:@"appid"];
    //    [deviceToken setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"]];
    //    [appid setStringValue:@"com.icircall.icircallenterprise"];
    NSXMLElement *push = [NSXMLElement elementWithName:@"push"];
    NSXMLElement *os = [NSXMLElement elementWithName:@"os"];
    NSXMLElement *device = [NSXMLElement elementWithName:@"device"];
    NSXMLElement *badge = [NSXMLElement elementWithName:@"badge"];
    [push addAttributeWithName:@"type" stringValue:@"apns2"];
    [push addAttributeWithName:@"token" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"]];
    
    [os setStringValue:[NSString stringWithFormat:@"%@-%@",@"IOS",[[UIDevice currentDevice] systemVersion]]];
    
    [presence addChild:client];
    [client addChild:push];
    [client addChild:os];
    [client addChild:device];
    [client addChild:badge];
    
    // NSLog(@"组装后的xml:%@",presence);
    
//    if([StrUtility isBlankString:[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"]] ){
//        [self performSelector:@selector(resendToken) withObject:@"0" afterDelay:3];//3秒后执行
//    }
    [xmppStream sendElement:presence];
    
    //fighting modify 邀请码加为好友
    NSString* username = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    
    if ([@"anonymouss" isEqualToString:username]) {
        return;
    }

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[defaults objectForKey:@"password"] forKey:@"confirmPassword"];
    [defaults synchronize];

    
    BOOL apkValid = [defaults boolForKey:@"NSUD_Valid"];
    if (apkValid) {
        NSString* taskID = [defaults objectForKey:@"task"];
        NSString* code = [defaults objectForKey:@"code"];
        NSString* apkId = [defaults objectForKey:@"apkId"];
        taskID = [taskID stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if (taskID != nil) {
            
            XMPPIQ *iq = [XMPPIQ iqWithType:@"set" ];
            iq.xmlns = @"jabber:client";
            
            XMPPElement *task  =  (XMPPElement*)[XMPPElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/task"];
            
            XMPPElement *exec = [XMPPElement elementWithName:@"exec"];
            [exec addAttributeWithName:@"task" stringValue:taskID];
            [task addChild:exec];
            [iq addChild:task];
            [xmppStream sendElement:iq];
            //清除数据，否则切换帐号时会重复执行此过程；
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"task"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NSUD_Valid"];
            
            
            NSLog(@"fighting:send task:%@",task);
        }
        
        if (code != nil && [code length]>0) {
            
            XMPPIQ *iq = [XMPPIQ iqWithType:@"set" ];
            XMPPElement * query = (XMPPElement*)[XMPPElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/init"];
            XMPPElement *ele_code = [XMPPElement elementWithName:@"code" stringValue:code];
            XMPPElement *ele_apkid = [XMPPElement elementWithName:@"apkId" stringValue:apkId];
            [query addChild:ele_code];
            [query addChild:ele_apkid];
            [iq addChild:query];
            [xmppStream sendElement:iq];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"code"];
            NSLog(@"fighting:send init code:%@",code);
            
        }
    }
    
    //通知登录成功
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Notification_Load_OK" object:nil userInfo:nil];
    
    //判断程序是否第一次登录
    if (![defaults boolForKey:@"everLaunched"]) {
        [defaults setBool:YES forKey:@"everLaunched"];
        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    }
    else{
        //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    }
    
    //清除退出状态
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"NSUD_LoginStatus"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Application_Start_Init_Data" object:nil];

    
    // Before service data returning..
    [PublicCURD updateDatabase];
    
    //获得token
    [ChatInit getToKenInfo];
    //获取最新数据
    [ChatInit sendIQInformationList];//个人信息
    [ChatInit queryUserInfo];
    [ChatInit queryRoster];
    [ChatInit queryRoom];
    [ChatInit getNewFriendsList];
    
    //获得最新的DND配置数据
    [ChatInit queryDndInfo];
    
    [defaults setObject:@"connection" forKey:@"Network_Status"];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"NNC_Network_Status_Connection" object:nil userInfo:nil];
    //通知聊天历史列表提示连接
    [[NSNotificationCenter defaultCenter]postNotificationName:@"NNC_Server_Connect" object:nil userInfo:nil];
}


- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    
}


- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    JLLog_D(@"注册失败会调用xmppStream:didNotRegister ");
    [self showAlertView:@"注册失败"];
}


//检测帐号冲突 可处理是否多点登陆
- (NSString *)xmppStream:(XMPPStream *)sender alternativeResourceForConflictingResource:(NSString *)conflictingResource
{
    JLLog_D(@"alternativeResourceForConflictingResource: %@",conflictingResource);
    return @"XMPPIOS";
}


//账号冲突返回客户端error
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    JLLog_D(@"didReceiveError:%@",error);
    
    DDXMLNode *errorNode = (DDXMLNode *)error;
    
    if ([[errorNode name] isEqualToString:@"ack"]) {
        NSString *msgId = [error attributeStringValueForName:@"id"];
        JLLog_D(@"***********%@",msgId);
        //发送通知，更新聊天历史列表已存在此好友;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Msg_Send" object:msgId userInfo:nil];
        
    }
    
    
    //遍历错误节点
    for(DDXMLNode *node in [errorNode children])
    {
        //若错误节点有【冲突】
        if([[node name] isEqualToString:@"conflict"])
        {
            //停止轮训检查链接状态
            //[_timer invalidate];
            //            NSString *message = [NSString stringWithFormat:@"%@账号已经在别的地方登录",[[[SharedAppDelegate myInfo] myCardDetial]fullNameWithSpace]];
            //            NSString *message = @"账号已经在别的地方登录";
            //弹出登陆冲突,点击OK后logout
            //        [self showAlertView:message];
            [self disconnect];
            
#if !TARGET_IPHONE_SIMULATOR
            [_voipModule deactivate];
#endif
            //不再重连
            self.isLogin = YES;
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"public.text.offLine",@"message") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"public.alert.cancel",@"button"),NSLocalizedString(@"public.text.relogin",@"button"), nil];
            alert.tag=1030;
            [alert show];
            
        }
        
        if ([[node name] isEqualToString:@"update"]) {
            
            for(DDXMLNode *node2 in [node children])
            {
                if ([[node2 name] isEqualToString:@"pkg"]) {
                    downloadUrl = node2.stringValue;
                }
            }
            
            if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:BundleId]) {
                downloadUrl=  [NSString stringWithFormat:@"%@/ipa-download",httpRequset];
            }
            
            if ([[node name] isEqualToString:@"text"]) {
                //不再重连
                self.isLogin = YES;
                NSString * msg = node.stringValue;
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"public.alert.cancel",@"title") ,NSLocalizedString(@"public.text.update",@"title") , nil];
                alert.tag=1031;
                [alert show];
                
            }
            
        }
        
    }
    
}


#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1030&&buttonIndex==0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_Logout" object:nil userInfo:nil];
        
        CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault removeObjectForKey:@"password"];
        [userDefault removeObjectForKey:@"confirmPassword"];
        [userDefault synchronize];
        [appDelegate loadAppConfiguration];
        loginFlag = 4;
    }else if(alertView.tag==1030&&buttonIndex==1){
        //注销voip
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NNC_VOIP_Deactivate" object:nil userInfo:nil];
        
        //断开连接
        [self disconnect];
        
        //打开重连
        self.isLogin = NO;

        if ([self connect]) {
            JLLog_D(@"进入应用重新连接");
        }
    }else if(alertView.tag==1031&&buttonIndex==1){
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downloadUrl]];
        
    }
}


//初始化voip
-(void)InitializeTheVoip{
#if !TARGET_IPHONE_SIMULATOR
    _voipModule = [VoipModule shareVoipModule];
    _voipModule.voipDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
    [_voipModule activate:[XMPPServer sharedServer].xmppStream];
#endif
}


//重连方法
- (void)loginApp{
    NSLog(@"重连定时器启动2");
    reloginCount++;
    if (reloginCount>100) {
        [reLoginTimer invalidate];
        reLoginTimer = nil;
        [self showServerDisconnectStatus];
        return;
    }
    
    if(loginFlag == 2){
        NSLog(@"重连时发现已经连接...");
        [reLoginTimer invalidate];
        reLoginTimer = nil;
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults stringForKey:@"userName"];
    NSString *pass = [defaults stringForKey:@"password"];
    
    
    [self  disconnect];
    
    if (userId&&pass) {
        if ([self connect]) {
            [reLoginTimer invalidate];
            reLoginTimer = nil;
        }else{
        }
    }
}

//重新发生token
-(void)resendToken{
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
    
    [xmppStream sendElement:presence];
}


//silenceSky 新增
- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender
{
    //self.isLogin = NO;
    JLLog_D(@"断开连接回调");
}


/**
 * These methods are called after their respective XML elements are received on the stream.
 *
 * In the case of an IQ, the delegate method should return YES if it has or will respond to the given IQ.
 * If the IQ is of type 'get' or 'set', and no delegates respond to the IQ,
 * then xmpp stream will automatically send an error response.
 *
 * Concerning thread-safety, delegates shouldn't modify the given elements.
 * As documented in NSXML / KissXML, elements are read-access thread-safe, but write-access thread-unsafe.
 * If you have need to modify an element for any reason,
 * you should copy the element first, and then modify and use the copy.
 *
 */

/*
 
 名册
 
 <iq xmlns="jabber:client" type="result" to="user2@chtekimacbook-pro.local/80f94d95">
 <query xmlns="jabber:iq:roster">
 <item jid="user6" name="" ask="subscribe" subscription="from"/>
 <item jid="user3@chtekimacbook-pro.local" name="bb" subscription="both">
 <group>好友</group><group>user2的群组1</group>
 </item>
 <item jid="user7" name="" ask="subscribe" subscription="from"/>
 <item jid="user7@chtekimacbook-pro.local" name="" subscription="both">
 <group>好友</group><group>user2的群组1</group>
 </item>
 <item jid="user1" name="" ask="subscribe" subscription="from"/>
 </query>
 </iq>
 */

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
//    NSLog(@"----------------------------- Receive IQ ---------------------------------------");
//    NSLog(@"%@", iq);
//    NSLog(@"----------------------------- Receive IQ ---------------------------------------");
    
    //网络切换
    if ([@"result" isEqualToString:iq.type] && [@"ping" isEqualToString:iq.elementID]){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Relogin" object:nil userInfo:nil];
        
    }
    
    //ping packet
    if ([@"get" isEqualToString:iq.type]) {
        NSXMLElement *query = iq.childElement;
        if ([@"ping" isEqualToString:query.name]) {
            
            [self sendPingPacket:iq.elementID];
            return YES;
            
        }
    }else if ([@"error" isEqualToString:iq.type]){
        // NSXMLElement *error=[iq elementForName:@"error"];
        // NSString *text=[[error elementForName:@"text"] stringValue];
        //[self showAlertView:[NSString stringWithFormat:@"%@",error]];
        // return NO;
    }
    
    //    NSString *userId = [[sender myJID] user];//当前用户
    if([@"check-update" isEqualToString:iq.elementID]){                    //--------- 获取App更新信息 ---------
        if ([@"result" isEqualToString:iq.type]) {
            NSXMLElement *query = iq.childElement;
            if ([@"query" isEqualToString:query.name]) {
                NSString *url = @"";
                NSString *desc = @"";
                NSString *version = @"";
                NSArray *pkgArray = [query children];
                
                
                for (NSXMLElement *item in pkgArray) {
                    
                    NSArray *pkgChildrenArray = [item children];
                    for (NSXMLElement *item in pkgChildrenArray) {
                        
                        if ([item.name isEqual:@"url"]) {
                            url = [item stringValue];
                        }
                        if ([item.name isEqual:@"desc"]) {
                            desc = [item stringValue];
                            //NSLog(@"****%@",desc);
                        }
                        if ([item.name isEqual:@"version"]) {
                            version = [item stringValue];
                            //NSLog(@"****%@",desc);
                        }
                        
                    }
                    
                }
                NSDictionary *updateDic = [NSDictionary dictionaryWithObjectsAndKeys:url,@"url",desc,@"desc", version,@"version",nil];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"NNS_App_Update" object:updateDic];
            }
        }
    }else if([@"getContactInfoWithSearch" isEqualToString:iq.elementID]){
        //查询通讯录
        NSMutableDictionary* contactsDic = [NSMutableDictionary dictionary];
        if ([@"result" isEqualToString:iq.type]) {
            NSXMLElement *query = iq.childElement;
            NSArray* users = [NSArray array];
            
            if ([@"query" isEqualToString:query.name]) {
                users = [query children];
                for (int i= 0; i < users.count; i++) {
                    NSXMLElement *user = users[i];
                    NSMutableDictionary* contact = [[NSMutableDictionary alloc]init];
                    [contact setObject:[[user attributeForName:@"jid"] stringValue] forKey:@"jid"];
                    
                    for (NSXMLElement* item in user.children) {
                        if ([item.name isEqual:@"phone"]) {
                            [contact setObject:[item stringValue] forKey:@"phone"];
                        }else if ([item.name isEqual:@"name"]) {
                            [contact setObject:[item stringValue] forKey:@"nickName"];
                            
                        }else if ([item.name isEqual:@"accountType"]) {
                            [contact setObject:[item stringValue] forKey:@"accountType"];
                            
                        }else if ([item.name isEqual:@"avatar"]) {
                            [contact setObject:[item stringValue] forKey:@"avatar"];
                            
                        }else if ([item.name isEqualToString:@"activated"]){
                            [contact setObject:[item stringValue] forKey:@"activated"];
                            
                        }else if ([item.name isEqualToString:@"email"]){
                            [contact setObject:[item stringValue] forKey:@"email"];
                            
                        }else if ([item.name isEqualToString:@"secondEmail"]){
                            [contact setObject:[item stringValue] forKey:@"secondEmail"];
                            
                        }else if ([item.name isEqualToString:@"inviteUrl"]){
                            [contact setObject:[item stringValue] forKey:@"inviteUrl"];
                            
                        }else if ([item.name isEqualToString:@"cemployeeCde"]){
                            [contact setObject:[item stringValue] forKey:@"employeeCode"];
                            
                        }else if ([item.name isEqualToString:@"accountName"]){
                            [contact setObject:[item stringValue] forKey:@"accountName"];
                            
                        }else if ([item.name isEqualToString:@"gender"]){
                            [contact setObject:[item stringValue] forKey:@"gender"];
                            
                        }else if ([item.name isEqualToString:@"areaId"]){
                            [contact setObject:[item stringValue] forKey:@"areaId"];
                            
                        }else if ([item.name isEqualToString:@"bookNme"]){
                            [contact setObject:[item stringValue] forKey:@"bookName"];
                            
                        }else if ([item.name isEqualToString:@"agencyNme"]){
                            [contact setObject:[item stringValue] forKey:@"agencyName"];
                            
                        }else if ([item.name isEqualToString:@"branchNme"]){
                            [contact setObject:[item stringValue] forKey:@"branchName"];
                            
                        }else if ([item.name isEqualToString:@"employeeNme"]){
                            [contact setObject:[item stringValue] forKey:@"employeeName"];
                            
                        }else if ([item.name isEqualToString:@"departmentNme"]){
                            [contact setObject:[item stringValue] forKey:@"departmentName"];
                            
                        }else if ([item.name isEqualToString:@"centerNme"]){
                            [contact setObject:[item stringValue] forKey:@"centerName"];
                            
                        }
                        
                    }
                    [contactsDic setObject:contact forKey:[NSString stringWithFormat:@"%d", i]];
                }
            }
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NNS_ContactInfo_Search" object:contactsDic];
        
    }else if ([@"invitationNewFriend" isEqualToString:iq.elementID]) {        //--------- 邀请朋友获取下载地址 ---------
        if ([@"result" isEqualToString:iq.type]) {
            NSXMLElement *query = iq.childElement;
            if ([@"query" isEqualToString:query.name]) {
                DDXMLNode *message=query.nextNode;
                NSArray *array=[message children];
                for (NSXMLElement *item in array) {
                    if ([item.name isEqual:@"smContent"]) {          //昵称
                        [[NSUserDefaults standardUserDefaults] setObject:item.stringValue forKey:@"smContent"];
                        [[NSUserDefaults standardUserDefaults] synchronize];//保存
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"smContent" object:nil userInfo:nil];
                        
                    }
                }
            }
            return YES;
        }else if ([@"error" isEqualToString:iq.type]){
            NSXMLElement *error=[iq elementForName:@"error"];
            NSString *text=[[error elementForName:@"text"] stringValue];
            [self showAlertView:text];
        }
        return NO;
    }
    
    else if ([@"AI_Friend_Proving" isEqualToString:iq.elementID]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        if ([@"result" isEqualToString:iq.type]) {
            [center postNotificationName:@"AI_Friend_Proving_Return" object:nil];
            return YES;
        }else {
            [center postNotificationName:@"AI_Friend_Proving_Error" object:nil];
            return NO;
        }
    }
    
    else if ([@"AI_New_Friend_Acception" isEqualToString:iq.elementID]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        if ([@"result" isEqualToString:iq.type]) {
            NSXMLElement *query = [iq elementForName:@"query"];
            NSString *ver = [query attributeStringValueForName:@"ver"];
            if (ver) { // save list ver
                [[NSUserDefaults standardUserDefaults] setObject:ver forKey:kNew_Friends_List_Ver];
            }
            AINewFriendRequestItem *i = [[AINewFriendRequestItem alloc] init];
            NSXMLElement *item = [query elementForName:@"item"];
            NSString *status = [item attributeStringValueForName:@"status"];
            NSString *requester = [item attributeStringValueForName:@"requester"];
            NSString *action = [item attributeStringValueForName:@"action"];
            NSString *name = [item attributeStringValueForName:@"name"];
            NSString *avatar = [item attributeStringValueForName:@"avatar"];
            NSString *accountType = [item attributeStringValueForName:@"accounttype"];
            NSString *nameSpelling = [name transformToPinyin];
            NSString *validateInfo = [item stringValue];
            
            i.status = status;
            i.name = name;
            i.requester = requester;
            i.accountType = accountType;
            i.avatar = avatar;
            i.nameSpelling = nameSpelling;
            i.validateInfo = validateInfo;
            
            if (action.intValue == 1) {
                [AINewFriendsCRUD updateStatus:status ofRequester:requester];
            }else {
                [AINewFriendsCRUD addANewFriendItem:i];
            }
            [center postNotificationName:@"AI_New_Friend_Acception_Return" object:nil];
            return YES;
        }else {
            [center postNotificationName:@"AI_New_Friend_Acception_Error" object:nil];
            return NO;
        }
    }
    else if ([@"AI_Get_New_Friends_List" isEqualToString:iq.elementID]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSXMLElement *query = [iq elementForName:@"query"];
            NSString *ver = [query attributeStringValueForName:@"ver"];
            if (ver) {
                [[NSUserDefaults standardUserDefaults] setObject:ver
                                                          forKey:kNew_Friends_List_Ver];
            }

            NSArray *items = [query elementsForName:@"item"];
            for (NSXMLElement *item in items) {
                AINewFriendRequestItem *i = [[AINewFriendRequestItem alloc] init];
                i.requester = [item attributeStringValueForName:@"requester"];
                i.name = [item attributeStringValueForName:@"name"];
                i.avatar = [item attributeStringValueForName:@"avatar"];
                i.accountType = [item attributeStringValueForName:@"accounttype"];
                i.status = [item attributeStringValueForName:@"status"];
                i.validateInfo = item.stringValue;
                i.nameSpelling = [i.name transformToPinyin];
                [AINewFriendsCRUD addANewFriendItem:i];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_New_Friends_List_Load_Finished" object:nil];
        });
        return YES;
    }
    
    else if ([@"AI_Search_AB_Contact" isEqualToString:iq.elementID]) {
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        if ([@"result" isEqualToString:iq.type]) {
            NSXMLElement *query = [iq elementForName:@"query"];
            NSMutableArray *employees = [NSMutableArray array];
            
            for (NSXMLElement *item in [query elementsForName:@"item"]) {
                AIABSearchContact *contact = [[AIABSearchContact alloc] init];
        
                NSString *branch = [item attributeStringValueForName:@"b"];
                NSString *employeeName = [item attributeStringValueForName:@"e"];
                NSString *avatar = [item attributeStringValueForName:@"a"];
                NSString *userName = [item attributeStringValueForName:@"u"];
                
                contact.branch = branch;
                contact.employeeName = employeeName;
                contact.avartar = avatar;
                contact.userName = userName;
                
                [employees addObject:contact];
            }
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:employees forKey:@"result"];
            [center postNotificationName:@"AI_AB_Contact_Search_Return" object:nil userInfo:userInfo];
            return YES;
            
        }else {
            [center postNotificationName:@"AI_AB_Contact_Search_Error" object:nil];
            return NO;
        }
    }
    
    else if ([@"AI_Contact_Info" isEqualToString:iq.elementID]) {
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        if ([@"result" isEqualToString:iq.type]) {
            
            UserInfo *userInfo = [[UserInfo alloc] init];
            
            NSXMLElement *query = [iq elementForName:@"query"];
            NSXMLElement *item = [query elementForName:@"user"];
            
            userInfo.jid = [item attributeStringValueForName:@"jid"];
            userInfo.phone = [[item elementForName:@"phone"] stringValue];
            userInfo.nickName = [[item elementForName:@"name"] stringValue];
            userInfo.avatar = [[item elementForName:@"avatar"] stringValue];
            
            userInfo.email = [[item elementForName:@"email"] stringValue];
            userInfo.secondEmail = [[item elementForName:@"secondEmail"] stringValue];
            userInfo.soure = [[item elementForName:@"source"] stringValue];
            userInfo.inviteUrl = [[item elementForName:@"inviteUrl"] stringValue];
            userInfo.accountType = [[[item elementForName:@"accountType"] stringValue] intValue];
            userInfo.employeeCode = [[item elementForName:@"cemployeeCde"] stringValue];
            userInfo.accountName = [[item elementForName:@"accountName"] stringValue];
            userInfo.gender = [[[item elementForName:@"gender"] stringValue] intValue];
            userInfo.areaId = [[item elementForName:@"areaId"] stringValue];
            userInfo.bookName = [[item elementForName:@"bookNme"] stringValue];
            userInfo.agencyName = [[item elementForName:@"agencyNme"] stringValue];
            userInfo.branchName = [[item elementForName:@"branchNme"] stringValue];
            userInfo.centerName = [[item elementForName:@"centerNme"] stringValue];
            userInfo.employeeName = [[item elementForName:@"employeeNme"] stringValue];
            userInfo.departmentName = [[item elementForName:@"departmentNme"] stringValue];
            userInfo.signature = [[item elementForName:@"signature"] stringValue];
            userInfo.employeePhone = [[item elementForName:@"employeePhone"] stringValue];
            userInfo.publicPhone = [[item elementForName:@"publicPhone"] stringValue];
            userInfo.officalPhone = [[item elementForName:@"officalPhone"] stringValue];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObject:userInfo forKey:@"result"];
            [center postNotificationName:@"AI_Contact_Info_Return" object:nil userInfo:dict];
            XMPPMessage *message = [AIMessagesManager messageWithKey:userInfo.jid];
            if (message) {
                BOOL isSuccess = [UserInfoCRUD addAnUserInfo:userInfo];
                if (isSuccess) {
                    [self xmppStream:xmppStream didReceiveMessage:message];
                }
                [AIMessagesManager removeMessageForKey:userInfo.jid];
            }
            
            return YES;
        }else {
            [center postNotificationName:@"AI_Contact_Info_Error" object:nil];
            return NO;
        }
    }
    
    else if ([@"AI_Get_Organization_List" isEqualToString:iq.elementID]) {
        
        __block NSMutableArray *organizations = [NSMutableArray array];
        __block NSMutableArray *deletes = [NSMutableArray array];
        
        if ([@"result" isEqualToString:iq.type]) {
            NSXMLElement *query = [iq elementForName:@"query"];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (NSXMLElement *item in [query elementsForName:@"item"]) {
                    BOOL del = [[item attributeStringValueForName:@"del"] boolValue];
                    NSString *name = [item attributeStringValueForName:@"n"];
                    NSString *code = [item attributeStringValueForName:@"c"];
                    NSString *parentCode = [item attributeStringValueForName:@"p"];
                    NSString *index_id = [item attributeStringValueForName:@"i"];
                    NSString *pingyin = [item attributeStringValueForName:@"y"];
                    
                    if (del)
                    {
                        AIOrganization *organization = [[AIOrganization alloc] init];
                        organization.indexId = index_id;
                        organization.code = code;
                        [deletes addObject:organization];
                    }
                    else
                    {
                        AIOrganization *organization = [[AIOrganization alloc] init];
                        organization.name = name;
                        organization.code = code;
                        organization.parentCode = parentCode ? parentCode : @"null";
                        organization.indexId = index_id;
                        organization.pinyin = pingyin;
                        [organizations addObject:organization];
                    }
                }
                [AIOrganizationCRUD deleteOrganizations:deletes];
                BOOL isFinished = [AIOrganizationCRUD addOrganizations:organizations];
                if (isFinished) {
                    NSString *ver = [query attributeStringValueForName:@"ver"];
                    [[NSUserDefaults standardUserDefaults] setObject:ver forKey:kOrganization_Contact_Ver];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Get_Organization_List_Return" object:self];
            });
            return YES;
        }else {
            return NO;
        }
    }
    
    else if ([@"AI_Collection_Create" isEqualToString:iq.elementID]) {
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        if ([@"result" isEqualToString:iq.type])
        {
            NSXMLElement *query = [iq elementForName:@"query"];
            NSString *ver = [query attributeStringValueForName:@"ver"];
            [[NSUserDefaults standardUserDefaults] setObject:ver forKey:kMy_Collection_Ver];
            
            NSXMLElement *storeup = [query elementForName:@"storeUp"];
            
            NSString *success = [storeup attributeStringValueForName:@"success"];
            NSString *id = [storeup attributeStringValueForName:@"id"];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            BOOL isSuccess = NO;
            
            if ([@"true" isEqualToString:success])
            {
                NSString *tmp = [[storeup elementForName:@"createdate"] stringValue];
                NSString *create_date = [Utility timespToUTCFormat:tmp];
                isSuccess = YES;
    
                [dict setObject:id forKey:@"id"];
                [dict setObject:create_date forKey:@"create_date"];
            }
            [dict setObject:[NSNumber numberWithBool:isSuccess] forKey:@"success"];
            [center postNotificationName:@"AI_Collection_Create_Return" object:nil userInfo:dict];
            return YES;
        }
        else
        {
            [center postNotificationName:@"AI_Collection_Create_Error" object:nil];
            return NO;
        }
        
    }
    
    else if ([@"AI_Collection_Delete" isEqualToString:iq.elementID]) {
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        NSXMLElement *query = [iq elementForName:@"query"];
        NSString *ver = [query attributeStringValueForName:@"ver"];
        [[NSUserDefaults standardUserDefaults] setObject:ver forKey:kMy_Collection_Ver];
        
        if ([@"result" isEqualToString:iq.type])
        {
            NSXMLElement *query = [iq elementForName:@"query"];
            NSXMLElement *storeup = [query elementForName:@"storeUp"];
            
            NSString *id = [storeup attributeStringValueForName:@"id"];
            NSString *success = [storeup attributeStringValueForName:@"success"];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:id forKey:@"id"];
            [dict setObject:success forKey:@"success"];
            
            [center postNotificationName:@"AI_Collection_Delete_Return" object:dict];
            return YES;
        }
        else
        {
            [center postNotificationName:@"AI_Collection_Delete_Error" object:nil];
            return NO;
        }
    }
    
    else if ([@"AI_Collections_Delete" isEqualToString:iq.elementID]) {
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        if ([@"result" isEqualToString:iq.type])
        {
            NSXMLElement *query = [iq elementForName:@"query"];
            NSArray *storeups = [query elementsForName:@"storeUp"];
            NSMutableArray *resultset = [NSMutableArray array];
            
            for (NSXMLElement *storeup in storeups) {
                
                NSString *id = [storeup attributeStringValueForName:@"id"];
                NSString *success = [storeup attributeStringValueForName:@"success"];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:id forKey:@"id"];
                [dict setObject:success forKey:@"success"];
                
                [resultset addObject:dict];
            }
            [center postNotificationName:@"AI_Collections_Delete_Return" object:resultset];
            return YES;
        }
        else
        {
            [center postNotificationName:@"AI_Collections_Delete_Error" object:nil];
            return NO;
        }
    }
    
    else if ([@"AI_Set_Backup_Name" isEqualToString:iq.elementID]) {
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

        if ([@"result" isEqualToString:iq.type]) {
            [center postNotificationName:@"AI_Set_Backup_Name_Succeed" object:@"yes"];
            return YES;
        }else {
            [center postNotificationName:@"AI_Set_Backup_Name_Succeed" object:@"no"];
            return NO;
        }
    }
    
    else if ([@"AI_Delete_Friend" isEqualToString:iq.elementID]) {
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        if ([@"result" isEqualToString:iq.type]) {
            [center postNotificationName:@"AI_Delete_Friend_Success" object:@"yes"];
            return YES;
        }else {
            [center postNotificationName:@"AI_Delete_Friend_Success" object:@"no"];
            return NO;
        }
    }
    else if ([@"AI_Set_Signature" isEqualToString:iq.elementID]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        BOOL flag = [@"result" isEqualToString:iq.type];
        if (flag) {
            [center postNotificationName:@"AI_Save_Signature_Return" object:nil];
            return YES;
        }else {
            [center postNotificationName:@"AI_Save_Signature_Error" object:nil];
            return NO;
        }
    }

    else if ([@"AI_Set_Area" isEqualToString:iq.elementID]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        BOOL flag = [@"result" isEqualToString:iq.type];
        if (flag) {
            [center postNotificationName:@"AI_Set_Area_Return" object:nil];
            return YES;
        }else {
            [center postNotificationName:@"AI_Set_Area_Error" object:nil];
            return NO;
        }
    }
    
    else if ([@"AIuserinfo_set_bbid" isEqualToString:iq.elementID]) {
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        NSNumber *result = [NSNumber numberWithBool:YES];
        
        if ([@"result" isEqualToString:iq.type])
        {
            NSXMLElement *query = [iq elementForName:@"query"];
            NSXMLElement *user = [query elementForName:@"user"];
            NSXMLElement *accountName = [user elementForName:@"accountName"];
            if (![[accountName stringValue] isEqualToString:@""]) {
                [center postNotificationName:@"AI_Set_BBId_Result" object:result userInfo:nil];
            }else {
                result = [NSNumber numberWithBool:NO];
                [center postNotificationName:@"AI_Set_BBId_Result" object:result userInfo:nil];
            }
            return YES;
        }
        else
        {
            [center postNotificationName:@"AI_Set_BBId_Error" object:result userInfo:nil];
            return NO;
        }
    }
    
    else if ([@"bindPhoneNumber" isEqualToString:iq.elementID]) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        if ([@"result" isEqualToString:iq.type]) {
            
            NSXMLElement *query = [iq elementForName:@"query"];
            NSArray *items = [query children];
            for (NSXMLElement *item in items) {
                if ([@"isBind" isEqualToString:item.name]) {
                    NSString *isBind = [item stringValue];
                    [dict setObject:isBind forKey:@"result"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Bind_Phone" object:dict];
                }
            }
        }else {
            
            if ([@"error" isEqualToString:iq.type]) {
                NSXMLElement *error = [iq elementForName:@"error"];
                NSXMLElement *textElement = [error elementForName:@"text"];
                NSString *text = [textElement stringValue];
                [dict setObject:text forKey:@"error"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Bind_Phone_Error" object:dict];
        }
    }
    
    else if ([@"unbindPhone" isEqualToString:iq.elementID]) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if ([@"result" isEqualToString:iq.type]) {
            
            NSXMLElement *query = [iq elementForName:@"query"];
            NSArray *items = [query children];
            for (NSXMLElement *item in items) {
                if ([@"isUnbind" isEqualToString:item.name]) {
                    NSString *isBind = [item stringValue];
                    [dict setObject:isBind forKey:@"result"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Unbind_Phone" object:dict];
                }
            }
            return YES;
        }else {
            if ([@"error" isEqualToString:iq.type]) {
                NSXMLElement *error = [iq elementForName:@"error"];
                NSArray *items = [error children];
                for (NSXMLElement *item in items) {
                    if ([@"text" isEqualToString:item.name]) {
                        NSString* text = [item stringValue];
                        if (text) {
                            [dict setObject:text forKey:@"error"];
                        }
                        
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Unbind_Phone_Error" object:dict];
                return NO;
            }
        }
    }
    
    
    else if ([@"AIbind_email" isEqualToString:iq.elementID]) {
        
        if ([@"result" isEqualToString:iq.type]) {
            
            NSXMLElement *query = [iq elementForName:@"query"];
            NSArray *items = [query children];
            for (NSXMLElement *item in items) {
                if ([@"isBind" isEqualToString:item.name]) {
                    NSString *isBind = [item stringValue];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Bind_Email_Succeed" object:isBind];
                }
            }
            
            return YES;
        }else {
            
            if ([@"error" isEqualToString:iq.type]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Bind_Email_Error" object:@"error"];
                return NO;
            }
        }
    }
    
    else if([@"UnbindEmail" isEqualToString:iq.elementID]) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if ([@"result" isEqualToString:iq.type]) {
            
            NSXMLElement *query = [iq elementForName:@"query"];
            NSArray *items = [query children];
            for (NSXMLElement *item in items) {
                if ([@"isUnbind" isEqualToString:item.name]) {
                    NSString *isBind = [item stringValue];
                    [dict setObject:isBind forKey:@"result"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Unbind_Email" object:dict];
                }
            }
            return YES;
        }else {
            
            NSXMLElement *error = [iq elementForName:@"error"];
            NSArray *items = [error children];
            for (NSXMLElement *item in items) {
                if ([@"text" isEqualToString:item.name]) {
                    NSString *text = [item stringValue];
                    if(text) {
                        [dict setObject:text forKey:@"error"];
                    }
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Unbind_Email_Error" object:dict];
            return NO;
        }
    }
    
    else if ([@"checkPassword" isEqualToString:iq.elementID]) {
        
        if ([@"result" isEqualToString:iq.type]) {
            
            NSXMLElement *query = [iq elementForName:@"query"];
            NSArray *items = [query children];
            for (NSXMLElement *item in items) {
                if ([@"result" isEqualToString:item.name]) {
                    NSString *isCorrect = [item stringValue];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Check_Password" object:isCorrect];
                }
            }
            return YES;
        }else {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Check_Password_Error" object:nil];
            return NO;
        }
    }
    
    else if ([@"changeCurrentPassword" isEqualToString:iq.elementID]) {
        
        if ([@"result" isEqualToString:iq.type]) {
            
            NSXMLElement *query = [iq elementForName:@"query"];
            NSArray *items = [query children];
            for (NSXMLElement *item in items) {
                if ([@"result" isEqualToString:item.name]) {
                    NSString *isCorrect = [item stringValue];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Change_Password" object:isCorrect];
                }
            }
            return YES;
        }else {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Change_Password_Error" object:nil];
            return NO;
        }
    }
    else if ([@"AI_Get_Collection_List" isEqualToString:iq.elementID]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *currentVer = [defaults objectForKey:kMy_Collection_Ver];
        if ([@"result" isEqualToString:iq.type])
        {
            NSXMLElement *query = [iq elementForName:@"query"];
            NSString *ver = [query attributeStringValueForName:@"ver"];
            NSMutableArray *collections = [NSMutableArray array];
            
            if (![ver isEqualToString:currentVer])
            {
                [AICollectionCRUD clear];
                [defaults setObject:ver forKey:kMy_Collection_Ver];
                
                NSArray *storeups = [query elementsForName:@"storeUp"];
                for (NSXMLElement *storeup in storeups)
                {
                    AICollection *collection = [[AICollection alloc] init];
                    collection.serviceId = [storeup attributeStringValueForName:@"id"];
                    collection.owner = [[storeup elementForName:@"username"] stringValue];
                    collection.sender = [[storeup elementForName:@"sender"] stringValue];
                    collection.sourceType = [[[storeup elementForName:@"source"] stringValue] integerValue];
                    collection.messageType = [[[storeup elementForName:@"msgType"] stringValue] integerValue];
                    collection.message = [[storeup elementForName:@"message"] stringValue];
                    collection.circleID = [[storeup elementForName:@"circleId"] stringValue];
                    
                    NSString *timetmp = [[storeup elementForName:@"createdate"] stringValue];
                    collection.createDate = [Utility timespToUTCFormat:timetmp];
                    
                    [collections addObject:collection];
                }
                
                [AICollectionCRUD insertCollections:collections];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Collection_List_Return" object:nil];
            return YES;
            
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Collection_List_Error" object:nil];
            return NO;
        }
    }

    else if ([@"AIuserinfo_setGender" isEqualToString:iq.elementID]) {
        
        if ([@"result" isEqualToString:iq.type]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_Set_Gender_Succeed" object:nil userInfo:nil];
            return YES;
        }else {
            return NO;
        }
    }
    else if ([@"setName" isEqualToString:iq.elementID]) {                     // --------- 修改昵称 ---------
        if ([@"result" isEqualToString:iq.type]) {
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"setName_ok" object:nil userInfo:nil];
            
            return YES;
        }else{
            return NO;
        }
    }else if ([@"bindingEmail" isEqualToString:iq.elementID]){                // --------- 绑定邮箱 ---------
        if ([@"result" isEqualToString:iq.type]) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"bindingEmail_ok" object:nil userInfo:nil];
            //            [self showAlertView:@"激活邮件已发送,请到绑定的邮箱激活。收件箱如何没找到，请到垃圾箱寻找。带来不变敬请谅解！"];
            return YES;
        }else{
            return NO;
        }
        
    }else if ([@"bindingEmails" isEqualToString:iq.elementID]){
        if ([@"result" isEqualToString:iq.type]) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"bindingEmails_ok" object:nil userInfo:nil];
            //            [self showAlertView:@"激活邮件已发送,请到绑定的邮箱激活。收件箱如何没找到，请到垃圾箱寻找。带来不变敬请谅解！"];
            return YES;
        }else{
            return NO;
        }
    }

    else if ([@"phonenumbinding" isEqualToString:iq.elementID]){              // --------- 绑定手机 ---------
        if ([@"result" isEqualToString:iq.type]) {
            //            [self showAlertView:@"绑定成功"];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"bindingPhone_ok" object:nil userInfo:nil];
            return YES;
        }else if([@"error" isEqualToString:iq.type]){
            NSXMLElement *error=[iq elementForName:@"error"];
            NSString *text=[[error elementForName:@"text"] stringValue];
            [self showAlertView:text];
        }
        
    }else if ([@"sendQuestion" isEqualToString:iq.elementID])                 // --------- 设置问题 ---------
    {
        if ([@"result" isEqualToString:iq.type]) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"setQuestion_ok" object:nil userInfo:nil];
        }
    }else if ([@"ChangePassword" isEqualToString:iq.elementID])               // --------- 修改密码 ---------
    {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if ([@"result" isEqualToString:iq.type]) {
            
            NSXMLElement *query = iq.childElement;
            NSArray *items = [query children];
            for (NSXMLElement *item in items) {
                if ([item.name isEqualToString:@"isChange"]) {
                    NSString *text = [item stringValue];
                    JLLog_I("<text=%@>", text);
                    [dict setObject:text forKey:@"isChange"];
                }else if([item.name isEqual:@"password"]){
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:item.stringValue forKey:@"password"];
                    [defaults setObject:item.stringValue forKey:@"oncePassword"];
                    [defaults synchronize];
                }else if([item.name isEqualToString:@"account"]) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:item.stringValue forKey:@"account"];
                    [defaults synchronize];
                }
            }
        }else if ([@"error" isEqualToString:iq.type]) {
            
            NSXMLElement *query = iq.childElement;
            NSArray *items = [query children];
            for (NSXMLElement *item in items) {
                if ([item.name isEqualToString:@"text"]) {
                    NSString *text = [item stringValue];
                    [dict setObject:text forKey:@"isChange"];
                }
            }
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"changeSuccess" object:nil userInfo:dict];
        return YES;
    }
    else if ([@"ID_Invitation_Friend" isEqualToString:iq.elementID]){         // --------- 带圈子的邀请 ---------
        
        
        //NSLog(@"*****%@",iq);
        
        if ([@"result" isEqualToString:iq.type]) {
            
            NSXMLElement *query = iq.childElement;
            if ([@"query" isEqualToString:query.name]) {
                DDXMLNode *accounts=query.nextNode;
                NSArray *array=[accounts children];
                NSString *inviteUrl=nil;
                for (NSXMLElement *item in array) {
                    DDXMLNode *smContent=item.nextNode;
                    
                    if ([smContent.name isEqual:@"smContent"]) {
                        inviteUrl = smContent.stringValue;
                        // NSLog(@"********%@",inviteUrl);
                        
                    }
                    
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Invitation_Friend_Circle" object:inviteUrl userInfo:nil];
            }
        }else if([@"error" isEqualToString:iq.type]){
            NSXMLElement *error=[iq elementForName:@"error"];
            NSString *text=[[error elementForName:@"text"] stringValue];
            [self showAlertView:text];
        }
    }else if ([@"AI_Circle_Detail_Request" isEqualToString:iq.elementID]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        if ([@"result" isEqualToString:iq.type]) {
            
            NSMutableDictionary *d = [NSMutableDictionary dictionary];
            
            NSXMLElement *query = [iq elementForName:@"query"];
            NSXMLElement *circle = [query elementForName:@"circle"];
            
            NSString *jid = [circle attributeStringValueForName:@"jid"];
            NSString *size = [circle attributeStringValueForName:@"size"];
            NSString *isFull = [circle attributeStringValueForName:@"isFull"];
            
            NSString *name = [circle attributeStringValueForName:@"name"];
            NSNumber *flag = [isFull isEqualToString:@"true"] ? @YES : @NO;

            [d setObject:jid forKey:@"jid"];
            [d setObject:size forKey:@"size"];
            [d setObject:name forKey:@"name"];
            [d setObject:flag forKey:@"isFull"];
            
            NSMutableArray *members = [NSMutableArray array];
            for (NSXMLElement *member in circle.children) {
                NSMutableDictionary *md = [NSMutableDictionary dictionary];
                NSString *avatar = [member attributeStringValueForName:@"avatar"];
                [md setObject:avatar forKey:@"avatar"];
                [members addObject:md];
            }
            [d setObject:members forKey:@"members"];
            
            [center postNotificationName:@"AI_Circle_Detail_Return" object:nil userInfo:d];
        }else {
            [center postNotificationName:@"AI_Circle_Detail_Error" object:nil userInfo:nil];
        }
    }
    else if ([@"scanAddContacts" isEqualToString:iq.elementID]){               // --------- 二维码扫瞄添加联系人 ---------
        NSXMLElement *query=iq.childElement;
        DDXMLNode *items=query.nextNode;
        NSArray *item=[items children];
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
        NSString *type = @"";
        NSString *jid = @"";
        NSString *nickName = @"";
        NSString *avatar = @"";
        NSString *signature = nil;
        NSString *areaId = nil;
        
        for (NSXMLElement *it in [query children]) {
            type = [[it attributeForName:@"type"] stringValue];
        }
        
        for (NSXMLElement *it in item) {
            NSLog(@"*****%@",it.name);
            if ([@"qr" isEqualToString:it.name]) {
                
            }
            if ([type isEqualToString:@"user"]) {
                if ([@"user" isEqualToString:it.name]) {
                    jid =  [[it attributeForName:@"jid"] stringValue];
                    
                    NSArray *item=[it children];
                    for (NSXMLElement *it in item) {
                        if ([it.name isEqual:@"name"]) {
                            nickName = it.stringValue;
                        }
                        if ([it.name isEqual:@"avatar"]) {
                            avatar = it.stringValue;
                        }
                        
                        if ([it.name isEqual:@"signature"]) {
                            signature = it.stringValue;
                        }
                        
                        if ([it.name isEqual:@"areaId"]) {
                            areaId = it.stringValue;
                        }
                    }
                }
                
                areaId = areaId ? areaId : @"";
                signature = signature ? signature : @"";
                
                [dic setObject:type forKey:@"type"];
                [dic setObject:jid forKey:@"jid"];
                [dic setObject:nickName forKey:@"nickName"];
                [dic setObject:avatar forKey:@"avatar"];
                [dic setObject:signature forKey:@"signature"];
                [dic setObject:areaId forKey:@"areaId"];
                
            }else if([type isEqualToString:@"circle"]){
                
                if ([@"circle" isEqualToString:it.name]) {
                    jid =  [[it attributeForName:@"jid"] stringValue];
                    nickName =  [[it attributeForName:@"name"] stringValue];
                    nickName = nickName ? nickName : @"群聊";
                    
                }
                
                [dic setObject:type forKey:@"type"];
                [dic setObject:jid forKey:@"jid"];
                [dic setObject:nickName forKey:@"nickName"];
                
            }
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NNS_Receive_ScanResult" object:dic];
        
    }else if ([@"queryNewRequest" isEqualToString:iq.elementID]){
        NSXMLElement *query=iq.childElement;
        DDXMLNode *items=query.nextNode;
        NSArray *item=[items children];
        for (NSXMLElement *it in item) {
            NSString *title=[[it attributeForName:@"title"] stringValue];
            NSString *outline=[[it attributeForName:@"outline"] stringValue];
            NSString *imgUrl=[[it attributeForName:@"imgUrl"] stringValue];
            NSString *url=[[it attributeForName:@"url"] stringValue];
            NSString *publishTime=[[it attributeForName:@"publishTime"] stringValue];
            [NewsListCRUD insertNewsList:@"news" title:title outline:outline imgUrl:imgUrl url:url publishTime:publishTime readMark:0];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NNS_Receive_News" object:nil userInfo:nil];
    }else if ([@"Is_Have_Userinfo" isEqualToString:iq.elementID])                     // ---------- 检测用户是否存在 ----------
    {
        //NSLog(@"%@",iq);
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"NSU_Userinfo_Array"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        NSXMLElement *query = iq.childElement;
        DDXMLNode *user=query.nextNode;
        NSArray *array=[user children];
        NSString *have=nil;
        if ([array count]>0) {
            have=@"hava";
        }
        //        [[NSUserDefaults standardUserDefaults]setObject:[array count] forKey:@"NSU_Userinfo_Array"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"NSUD_PhoneImage"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        for (NSXMLElement *item in array) {
            //NSLog(@"%@",item.name);
            if([item.name isEqual:@"avatar"]){    //头像
                NSLog(@"---{%@}",item.stringValue);
                [[NSUserDefaults standardUserDefaults] setObject:item.stringValue forKey:@"NSUD_PhoneImage"];
                [[NSUserDefaults standardUserDefaults] synchronize];//保存
            }
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NNC_Is_Have_Userinfo" object:have];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NNC_Is_Have_Userinfo2" object:have];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NNC_Is_Have_Userinfo3" object:have];
        
    }else if([@"validate_code" isEqualToString:iq.elementID])                            // ---------- 验证码 ----------
    {
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
        if ([iq.type isEqualToString:@"result"]) {
            [dic setObject:@"yes" forKey:@"validate"];
        }
        else
        {
            NSXMLElement *error=[iq elementForName:@"error"];
            NSString *text=[[error elementForName:@"text"] stringValue];
            [dic setObject:@"no" forKey:@"validate"];
            [dic setObject:text forKey:@"text"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"validate_code" object:dic];
        return YES;
    }else if([@"result" isEqualToString:iq.type] && [@"phoneNum" isEqualToString:iq.elementID])     // ---------- 手机号注册 ------------
    {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Validate_PhoneNum_Success" object:nil];
        return YES;
    }else if ([@"emailRegister" isEqualToString:iq.elementID]) {                // ------------ 邮箱注册 ---------
        
        if ([@"error" isEqualToString:iq.type]) {
            
            NSDictionary * dict = nil;
            NSXMLElement *error = iq.childErrorElement;
            NSArray *items = error.children;
            for (NSXMLElement *item in items) {
                
                if ([item.name isEqualToString:@"text"]) {
                    NSString *text = item.stringValue;
                    dict = [NSDictionary dictionaryWithObject:text forKey:@"errorMsg"];
                }
            }
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NSN_Mail_Registered_Fail" object:dict];
            
            return NO;
            
        }else if ([@"result" isEqualToString:iq.type]) {
            
            NSString *employeeName = nil;
            
            NSXMLElement *query = iq.childElement;
            NSArray *items = [query children];
            for (NSXMLElement *item in items) {
                if ([item.name isEqualToString:@"username"]) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:item.stringValue forKey:@"userName"];
                    [defaults synchronize];
                    
                }else if([item.name isEqual:@"password"]){
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:item.stringValue forKey:@"password"];
                    [defaults setObject:item.stringValue forKey:@"oncePassword"];
                    [defaults synchronize];
                }else if([item.name isEqual:@"name"]){
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:item.stringValue forKey:@"name"];
                    [defaults synchronize];//保存
                    //                        [[XMPPServer sharedServer]connect];//登录
                    
                }else if ([@"user" isEqualToString:item.name]) {
                    NSArray *items = [item children];
                    NSString *inviteUrl =@"";
                    for (NSXMLElement *item in items) {
                        if([item.name isEqual:@"inviteUrl"]){
                            inviteUrl = item.stringValue;
                        }else if ([item.name isEqualToString:@"employeeNme"]) {
                            employeeName = item.stringValue;
                        }
                    }
                    
                    [[NSUserDefaults standardUserDefaults] setObject:inviteUrl forKey:@"inviteUrl"];
                    [[NSUserDefaults standardUserDefaults] synchronize];//保存
                }
            }
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NSN_Mail_Registered_Success" object:employeeName userInfo:nil];
            return YES;
        }
    }
    else if([@"error" isEqualToString:iq.type])                                         // ----------- 手机号码格式验证错误 -----------
    {
        
        if ([@"phoneNum" isEqualToString:iq.elementID]) {
            NSXMLElement *error=[iq elementForName:@"error"];
            NSString *text=[[error elementForName:@"text"] stringValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Validate_PhoneNum_Error" object:text];
            
            // [self showAlertView:text];
        }else if ([@"phoneNumCode" isEqualToString: iq.elementID]||[@"pswPhoneNumCode" isEqualToString:iq.elementID]||[@"phonenumbinding" isEqualToString:iq.elementID]){
            NSXMLElement *error=[iq elementForName:@"error"];
            NSString *text=[[error elementForName:@"text"] stringValue];
            [self showAlertView:text];
        }else if ([@"email" isEqualToString:iq.elementID]) {
            NSXMLElement *error=[iq elementForName:@"error"];
            NSString *text=[[error elementForName:@"text"] stringValue];
            [self showAlertView:text];
        }
    }
    
    else{
        
        if ([@"result" isEqualToString:iq.type] || [@"set" isEqualToString:iq.type]) {
            NSXMLElement *query = iq.childElement;
            NSArray *items = [query children];
            if ([@"query" isEqualToString:query.name]) {
                NSMutableDictionary *phoneDictionary = [NSMutableDictionary dictionary];
                dispatch_async(dispatch_get_main_queue(),^(void){
                    NSXMLElement *query = [iq elementForName:@"query" xmlns:@"http://www.nihualao.com/xmpp/contacts"];
                    
                    if([query.xmlns isEqualToString:@"http://www.nihualao.com/xmpp/contacts"]){
                        if (![iq isErrorIQ]) {
                            if (query != nil && [iq.type isEqualToString:@"result"]) {
                                for (NSXMLElement *item in items) {
                                    phoneDictionary[[[item elementForName:@"p"] stringValue]] = @{@"nickname":[[item elementForName:@"n"] stringValue]
                                                                                    ,@"avatar":[[item elementForName:@"a"] stringValue]
                                                                                    ,@"username":[[item elementForName:@"u"] stringValue]
                                                                                    ,@"gender":[[item elementForName:@"g"] stringValue]
                                                                                    ,@"accountType":[[item elementForName:@"t"] stringValue]};
                                }
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"NCC_AddressBooK_Success" object:self userInfo:phoneDictionary];
                            }
                        }
                    }
                });

                // ------------- 注册新用户 -------------
                if ([@"aKey" isEqualToString:iq.elementID]||[@"phoneNumCode" isEqualToString:iq.elementID]||[@"pswPhoneNumCode"isEqualToString:iq.elementID]) {
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"name"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    for (NSXMLElement *item in items) {
                        if ([item.name isEqual:@"username"]) {
                            //NSLog(@"%@",item.stringValue);
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setObject:item.stringValue forKey:@"userName"];
                            [defaults synchronize];//保存
                        }else if([item.name isEqual:@"password"]){
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setObject:item.stringValue forKey:@"password"];
                            [defaults setObject:item.stringValue forKey:@"oncePassword"];
                            [defaults synchronize];//保存
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"passwordBackSuccess" object:nil userInfo:nil];
                        }else if([item.name isEqual:@"name"]){
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setObject:item.stringValue forKey:@"name"];
                            [defaults synchronize];//保存
                            //                        [[XMPPServer sharedServer]connect];//登录
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"NSN_Registered_Success" object:nil userInfo:nil];
                            
                        }else if ([@"user" isEqualToString:item.name]) {
                            NSArray *items = [item children];
                            NSString *inviteUrl =@"";
                            for (NSXMLElement *item in items) {
                                if([item.name isEqual:@"inviteUrl"]){
                                    inviteUrl = item.stringValue;
                                }
                            }
                            
                            NSLog(@"******%@",inviteUrl);
                            [[NSUserDefaults standardUserDefaults] setObject:inviteUrl forKey:@"inviteUrl"];
                            [[NSUserDefaults standardUserDefaults] synchronize];//保存
                        }
                        
                    }
                }
                //个人信息
                else if([@"personalInformation" isEqualToString:iq.elementID]){
                    
                    UserInfo *userInfo = [UserInfo loadArchive];
                    
                    DDXMLNode *user=query.nextNode;
                    NSArray *array=[user children];
                    //NSLog(@"%@",iq);
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"name"];
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"headImage"];
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"email"];
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"phone"];
                    //                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"inviteUrl"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    for (NSXMLElement *item in array) {
                        //NSLog(@"%@",item.name);
                        if ([item.name isEqual:@"name"]) {          //昵称
                            [[NSUserDefaults standardUserDefaults] setObject:item.stringValue forKey:@"name"];
                            [[NSUserDefaults standardUserDefaults] synchronize];//保存
                            
                            userInfo.nickName = item.stringValue;
                        }else if([item.name isEqual:@"avatar"]){    //头像
                            [[NSUserDefaults standardUserDefaults] setObject:item.stringValue forKey:@"headImage"];
                            [[NSUserDefaults standardUserDefaults] synchronize];//保存
                            
                            userInfo.avatar = item.stringValue;
                        }else if([item.name isEqual:@"email"])      //邮箱
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:item.stringValue forKey:@"email"];
                            NSString *activated=[item attributeForName:@"activated"].stringValue;
                            [[NSUserDefaults standardUserDefaults] setObject:activated forKey:@"activated"];
                            [[NSUserDefaults standardUserDefaults] synchronize];//保存
                            
                            userInfo.email = item.stringValue;
                            userInfo.emailActivate = activated;
                        }else if([item.name isEqual:@"phone"]){     //手机
                            [[NSUserDefaults standardUserDefaults] setObject:item.stringValue forKey:@"phone"];
                            [[NSUserDefaults standardUserDefaults] synchronize];//保存
                            
                            userInfo.phone = item.stringValue;
                        }else if ([item.name isEqual:@"passwordReplaced"]){
                            
                        }else if([item.name isEqual:@"inviteUrl"]){    //二维码URL
                            [[NSUserDefaults standardUserDefaults] setObject:item.stringValue forKey:@"inviteUrl"];
                            [[NSUserDefaults standardUserDefaults] synchronize];//保存
                            
                            userInfo.inviteUrl = item.stringValue;
                        }else if ([item.name isEqualToString:@"secondEmail"]) {
                            
                            userInfo.secondEmail = item.stringValue;
                            userInfo.secondEmailActivate = [item attributeStringValueForName:@"activated"];
                        }else if ([item.name isEqualToString:@"accountType"]) {
                            
                            int accountType = item.stringValue.intValue;
                            userInfo.accountType = accountType;
                        }else if ([item.name isEqualToString:@"employeeNme"]) {
                            
                            userInfo.employeeName = item.stringValue;
                        }else if ([item.name isEqualToString:@"cemployeeCde"]) {
                            
                            userInfo.employeeCode = item.stringValue;
                        }else if ([item.name isEqualToString:@"branchNme"]) {
                            
                            userInfo.branchName = item.stringValue;
                        }else if ([item.name isEqualToString:@"accountName"]) {
                            
                            userInfo.accountName = item.stringValue;
                            
                        } else if ([item.name isEqualToString:@"gender"]) {
                            
                            userInfo.myGender = item.stringValue.intValue;
                        } else if ([item.name isEqualToString:@"areaId"]) {
                            userInfo.areaId = item.stringValue;
                        } else if ([item.name isEqualToString:@"bookNme"]) {
                            userInfo.bookName = item.stringValue;
                        } else if ([item.name isEqualToString:@"agencyNme"]) {
                            userInfo.agencyName = item.stringValue;
                        } else if ([item.name isEqualToString:@"departmentNme"]) {
                            userInfo.departmentName = item.stringValue;
                        }else if ([item.name isEqualToString:@"signature"]) {
                            userInfo.signature = item.stringValue;
                        }else if ([item.name isEqualToString:@"employeePhone"]) {
                            userInfo.employeePhone = item.stringValue;
                        }else if ([item.name isEqualToString:@"publicPhone"]) {
                            userInfo.publicPhone = item.stringValue;
                        }else if([item.name isEqualToString:@"officalPhone"]) {
                            userInfo.officalPhone = item.stringValue;
                        }
                    }
                
                    [userInfo save];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"NNC_PersonalInfomation_Loaded" object:nil userInfo:nil];
                    return YES;
                }
                
                else if([iq.elementID isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"IQ_Add_Roster"]])//添加好友
                {
                    
                    for (NSXMLElement *item in items) {
                        
                        if ([@"user" isEqualToString:item.name]) {
                            
                            NSString *jid = [item attributeStringValueForName:@"jid"];
                            NSString *phone = [[item elementForName:@"phone"] stringValue];
                            NSString *nickName = [[item elementForName:@"name"] stringValue];
                            NSString *avatar = [[item elementForName:@"avatar"] stringValue];
                            NSString *accountType = [[item elementForName:@"accountType"] stringValue];
                            
                            
                            NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithCapacity:6];
                            [dictionary setObject:nickName forKey:@"nickName"];
                            [dictionary setObject:jid forKey:@"jid"];
                            [dictionary setObject:avatar forKey:@"avatar"];
                            [dictionary setObject:phone forKey:@"phone"];
                            [dictionary setObject:accountType forKey:@"accountType"];
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_AddContacts" object:self userInfo:dictionary];
                            
                        }
                    }
                    
                }else if([iq.elementID isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"IQ_Add_BlackList"]]){
                    //添加黑名单返回
                    //更新黑名单状态
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Blacklist" object:self userInfo:nil];
                    
                }else if([iq.elementID isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"IQ_Relieve_BlackList"]])
                {
                    //解除黑名单返回
                    //解除黑名单状态
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Blacklist" object:self userInfo:nil];
                    
                }else if([iq.elementID isEqualToString:IQID_Group_Upd_Name]){
                    //修改圈子名称
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Group_Upd_Name" object:self userInfo:nil];
                    
                }else if([iq.elementID isEqualToString:IQID_GroupMember_Upd_Name]){
                    //修改圈子成员名称
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_GroupMember_Upd_Name" object:self userInfo:nil];
                    
                }else if([iq.elementID isEqualToString:IQID_Group_Delete_GroupMember]){
                    //删除圈子成员
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Group_Delete_GroupMember" object:self userInfo:nil];
                    
                }else if([iq.elementID isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"IQ_Query_UserInfo"]] ){
                    //所有订阅关系者,手工查询
                    //版本号
                    NSString *userInfoVersion = [[query attributeForName:@"ver"] stringValue];
                    
                    //临时保存userInfo 版本号
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:userInfoVersion forKey:@"Ver_Temp_UserInfo"];
                    
                    NSMutableArray *userInfoArray = [[NSMutableArray alloc]init];
                    for (NSXMLElement *item in items) {
                        if ([@"user" isEqualToString:item.name]) {
                            NSString *jid = [item attributeStringValueForName:@"jid"];
                            NSString *remarkName = @"";
                            NSString *phone = [StrUtility string:[[item elementForName:@"phone"] stringValue]];
                            NSString *nickName = [StrUtility string:[[item elementForName:@"name"] stringValue]];
                            NSString *avatar = [StrUtility string:[[item elementForName:@"avatar"] stringValue]];
                            
                            NSString *email = [StrUtility string:[[item elementForName:@"email"] stringValue]];
                            NSString *secondEmail = [StrUtility string:[[item elementForName:@"secondEmail"] stringValue]];
                            NSString *source = [StrUtility string:[[item elementForName:@"source"] stringValue]];
                            NSString *inviteUrl = [StrUtility string:[[item elementForName:@"inviteUrl"] stringValue]];
                            NSString *accountType = [StrUtility string:[[item elementForName:@"accountType"] stringValue]];
                            NSString *cemployeeCde = [StrUtility string:[[item elementForName:@"cemployeeCde"] stringValue]];
                            NSString *accountName = [StrUtility string:[[item elementForName:@"accountName"] stringValue]];
                            NSString *gender = [StrUtility string:[[item elementForName:@"gender"] stringValue]];
                            NSString *areaId = [StrUtility string:[[item elementForName:@"areaId"] stringValue]];
                            NSString *bookNme = [StrUtility string:[[item elementForName:@"bookNme"] stringValue]];
                            NSString *agencyNme = [StrUtility string:[[item elementForName:@"agencyNme"] stringValue]];
                            NSString *branchNme = [StrUtility string:[[item elementForName:@"branchNme"] stringValue]];
                            NSString *centerNme = [StrUtility string:[[item elementForName:@"centerNme"] stringValue]];
                            NSString *employeeNme = [StrUtility string:[[item elementForName:@"employeeNme"] stringValue]];
                            NSString *departmentNme = [StrUtility string:[[item elementForName:@"departmentNme"] stringValue]];
                            NSString *remove = [StrUtility string:[item attributeStringValueForName:@"remove"]];
                            NSString *signature = [StrUtility string:[[item elementForName:@"signature"] stringValue]];
                            NSString *employeePhone = [StrUtility string:[[item elementForName:@"employeePhone"] stringValue]];
                            NSString *officalPhone = [StrUtility string:[[item elementForName:@"officalPhone"] stringValue]];
                            NSString *publicPhone = [StrUtility string:[[item elementForName:@"publicPhone"] stringValue]];
                            
                            jid = jid ? jid : @"";
                            phone = phone ? phone : @"";
                            nickName = nickName ? nickName : @"";
                            avatar = avatar ? avatar : @"";
                            email = email ? email : @"";
                            secondEmail = secondEmail ? secondEmail : @"";
                            source = source ? source : @"";
                            inviteUrl = inviteUrl ? inviteUrl : @"";
                            accountType = accountType ? accountType : @"";
                            cemployeeCde = cemployeeCde ? cemployeeCde : @"";
                            accountName = accountName ? accountName : @"";
                            gender = gender ? gender : @"";
                            areaId = areaId ? areaId : @"";
                            bookNme = bookNme ? bookNme : @"";
                            agencyNme = agencyNme ? agencyNme : @"";
                            branchNme = branchNme ? branchNme : @"";
                            centerNme = centerNme ? centerNme : @"";
                            employeeNme = employeeNme ? employeeNme : @"";
                            departmentNme = departmentNme ? departmentNme : @"";
                            remove = remove ? remove : @"";
                            signature = signature ? signature : @"";
                            employeePhone = employeePhone ? employeePhone : @"";
                            officalPhone = officalPhone ? officalPhone : @"";
                            publicPhone = publicPhone ? publicPhone : @"";
                            userInfoVersion = userInfoVersion ? userInfoVersion : @"";
                            
                            NSMutableDictionary *d = [NSMutableDictionary dictionary];
                            [d setObject:employeePhone forKey:@"employeePhone"];
                            [d setObject:officalPhone forKey:@"officalPhone"];
                            [d setObject:publicPhone forKey:@"publicPhone"];
                            [d setObject:signature forKey:@"signature"];
                            [d setObject:jid forKey:@"jid"];
                            [d setObject:remarkName forKey:@"remarkName"];
                            [d setObject:phone forKey:@"phone"];
                            [d setObject:nickName forKey:@"nickName"];
                            [d setObject:avatar forKey:@"avatar"];
                            [d setObject:email forKey:@"email"];
                            [d setObject:secondEmail forKey:@"secondEmail"];
                            [d setObject:source forKey:@"source"];
                            [d setObject:inviteUrl forKey:@"inviteUrl"];
                            [d setObject:accountType forKey:@"accountType"];
                            [d setObject:cemployeeCde forKey:@"cemployeeCde"];
                            [d setObject:accountName forKey:@"accountName"];
                            [d setObject:gender forKey:@"gender"];
                            [d setObject:areaId forKey:@"areaId"];
                            [d setObject:bookNme forKey:@"bookNme"];
                            [d setObject:agencyNme forKey:@"agencyNme"];
                            [d setObject:branchNme forKey:@"branchNme"];
                            [d setObject:centerNme forKey:@"centerNme"];
                            [d setObject:employeeNme forKey:@"employeeNme"];
                            [d setObject:departmentNme forKey:@"departmentNme"];
                            [d setObject:remove forKey:@"remove"];
                            [d setObject:userInfoVersion forKey:@"version"];
                            
                            [userInfoArray addObject:d];
                            
//                            [userInfoArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:employeePhone, @"employeePhone", officalPhone ,@"officalPhone", publicPhone, @"publicPhone", signature, @"signature",jid,@"jid",remarkName, @"remarkName",phone,@"phone",nickName,@"nickName",avatar,@"avatar",email,@"email",secondEmail,@"secondEmail",source,@"source",inviteUrl,@"inviteUrl",accountType,@"accountType",cemployeeCde,@"cemployeeCde",accountName,@"accountName",gender,@"gender",areaId,@"areaId",bookNme,@"bookNme",agencyNme,@"agencyNme",branchNme,@"branchNme",centerNme,@"centerNme",employeeNme,@"employeeNme",departmentNme,@"departmentNme",remove, @"remove",userInfoVersion, @"version", nil]];
                            
                        }
                    }
//                    JLLog_I(@"userInfoArray=%@", userInfoArray);
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_UserInfo" object:userInfoArray userInfo:nil];
                    
                    //保存版本号通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_UserinfoVersion" object:userInfoArray userInfo:nil];
                    
                    
                }else if([iq.elementID isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"IQ_Query_Group_InvitationURL"]] ){
                    //获取圈子邀请成员链接
                    /*  <iq xmlns="jabber:client" type="result" id="14012099402352" from="circle.ab-insurance.com" to="10668@ab-insurance.com/Hisuper"><query xmlns="http://www.nihualao.com/xmpp/circle/admin"><accounts><account jid="10691@ab-insurance.com" phone="+8618138217605" countryCode="86"><smContent>我为体育中心设置了免费网络电话"邦邦社区",加入很简单,点http://c-t.pw/117CGR 下载安装就行了,可喜,10710,10690他们已经在使用了.</smContent></account></accounts></query></iq>*/
                    
                    //NSLog(@"xmmpp******%@",iq);
                    
                    
                    if ([@"result" isEqualToString:iq.type]) {
                        NSXMLElement *query = iq.childElement;
                        if ([@"query" isEqualToString:query.name]) {
                            DDXMLNode *accounts=query.nextNode;
                            NSArray *array=[accounts children];
                            for (NSXMLElement *item in array) {
                                DDXMLNode *smContent=item.nextNode;
                                
                                if ([smContent.name isEqual:@"smContent"]) {
                                    NSString *inviteUrl = smContent.stringValue;
                                    // NSLog(@"********%@",inviteUrl);
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_Group_InviteUrl" object:inviteUrl userInfo:nil];
                                    
                                }
                                
                            }
                        }
                    }else if ([@"error" isEqualToString:iq.type]){
                        [self showAlertView:@"无法邀请"];
                    }
                    return YES;
                    
                }else if([query.xmlns isEqualToString:@"http://www.nihualao.com/xmpp/circle/list"]){
                    //NSLog(@"********%@",iq);
                    NSMutableArray *groupArray = [[NSMutableArray alloc]init];
                    NSMutableArray *groupArray2 = [[NSMutableArray alloc]init];
                    NSMutableArray *groupMemberArray = [[NSMutableArray alloc]init];
                    
                    if ([iq.elementID isEqualToString:@"iq_query_group"]) {
                        
                        for (NSXMLElement *item in items) {
                            if([@"circle" isEqualToString:item.name]){
                                
                                ChatGroup *chatGroup = [[ChatGroup alloc]init];
                                
                                NSString *circleVersion = [item attributeStringValueForName:@"ver"];
                                
                                NSString *groupJID = [item attributeStringValueForName:@"jid"];
                                
                                NSString *groupType = [item attributeStringValueForName:@"circleType"];
                                
                                NSString *removeStr = [item attributeStringValueForName:@"remove"];
                                
                                chatGroup.version = circleVersion;
                                chatGroup.jid = groupJID;
                                chatGroup.groupType = groupType;
                                chatGroup.removeStr = removeStr;
                                
                                [groupArray2 addObject:chatGroup];
                            }
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_Group2" object:groupArray2 userInfo:nil];
                        
                    }
                    
                    //首次安装
                    //获取圈子,客户端查询
                    
                    for (NSXMLElement *item in items) {
                        
                        NSMutableArray *membersData = [NSMutableArray array];
                        NSMutableDictionary *circleData = [NSMutableDictionary dictionary];
                        
                        if([@"circle" isEqualToString:item.name]){
                            
                            NSString *circleType = [item attributeStringValueForName:@"circleType"];
                            if(![circleType isEqualToString:@"circle"] && ![circleType isEqualToString:@"department"]){
                                continue;
                            }
                            
                            ChatGroup *chatGroup = [[ChatGroup alloc]init];
                            
                            NSString *circleVersion = [item attributeStringValueForName:@"ver"];
                            
                            NSString *groupJID = [item attributeStringValueForName:@"jid"];
                            
                            NSString *groupMucJID = [item attributeStringValueForName:@"room"];
                            NSString *groupType = [item attributeStringValueForName:@"circleType"];
                            NSString *groupName = [item attributeStringValueForName:@"name"];
                            NSString *creator = [item attributeStringValueForName:@"creator"];
                            NSString *inviteUrl = [item attributeStringValueForName:@"inviteUrl"];
                            NSString *createDate = [item attributeStringValueForName:@"createDate"];
                            NSString *modificationDate = [item attributeStringValueForName:@"modificationDate"];
                            NSString *removeStr = [item attributeStringValueForName:@"remove"];
                            
                            chatGroup.version = circleVersion;
                            chatGroup.jid = groupJID;
                            chatGroup.name = groupName;
                            chatGroup.creator = creator;
                            chatGroup.groupMucId = groupMucJID;
                            chatGroup.groupType = groupType;
                            chatGroup.inviteUrl = inviteUrl;
                            chatGroup.createDate = createDate;
                            chatGroup.modificationDate = modificationDate;
                            chatGroup.removeStr = removeStr;
                            
                            [groupArray addObject:chatGroup];
                            
                            [circleData setObject:groupJID forKey:@"groupJID"];
                            
                            //通过委托写入数据
                            //[groupChatDelegate chatGroupReceived:chatGroup];
                            
                            NSArray *members = [item elementsForName:@"members"];
                            for (NSXMLElement *membersElement in members) {
                                
                                NSArray *member = [membersElement children];
                                
                                for (NSXMLElement *item in member) {
                                    // GroupMembers *groupMembers = [[GroupMembers alloc]init];
                                    
                                    NSString *jid = [item attributeStringValueForName:@"jid"];
                                    NSString *role = [item attributeStringValueForName:@"role"];
                                    NSString *nickName = [item attributeStringValueForName:@"nickname"];
                                    NSString *memberRemove = [StrUtility string:[item attributeStringValueForName:@"remove"]];
                                    NSString *createTime = [StrUtility string:[item attributeStringValueForName:@"create"]];
                                    // NSLog(@"*******%@",jid);
                                    // NSLog(@"*******%@",nickName);
                                    
                                    //                                    groupMembers.jid = jid;
                                    //                                    groupMembers.nickName = nickName;
                                    //                                    groupMembers.role = role;
                                    //                                    //名字须统一
                                    //                                    groupMembers.groupJID = groupJID;
                                    
                                    //[groupChatDelegate groupMembersReceived:groupMembers];
                                    
                                    
                                    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",nickName, @"nickName",role,@"role",groupJID,@"groupJID",memberRemove,@"remove", createTime, @"createtime", nil];
                                    [membersData addObject:d];
                                    
//                                    [groupMemberArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",nickName, @"nickName",role,@"role",groupJID,@"groupJID",memberRemove,@"remove", createTime, @"createtime", nil]];
                                    
                                }
                            }
                            [circleData setObject:membersData forKey:@"members"];
                            [groupMemberArray addObject:circleData];
                        }
                    }
                    
                    //同步圈子数据（删除有变的圈子成员数据，重新写入）
                    
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_Group" object:groupArray userInfo:nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_GroupMember2" object:groupMemberArray userInfo:nil];
                    
                    return  YES;
                    
                }else if ([query.xmlns isEqualToString:@"http://www.nihualao.com/xmpp/validate"]) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSXMLElement *query = [iq elementForName:@"query"];
                        NSString *ver = [query attributeStringValueForName:@"ver"];
                        if (ver) {
                            [[NSUserDefaults standardUserDefaults] setObject:ver forKey:kNew_Friends_List_Ver];
                        }
                        NSXMLElement *item = [query elementForName:@"item"];
                        AINewFriendRequestItem *i = [[AINewFriendRequestItem alloc] init];
                        i.requester = [item attributeStringValueForName:@"requester"];
                        i.name = [item attributeStringValueForName:@"name"];
                        i.avatar = [item attributeStringValueForName:@"avatar"];
                        i.accountType = [item attributeStringValueForName:@"accounttype"];
                        i.status = [item attributeStringValueForName:@"status"];
                        i.validateInfo = item.stringValue;
                        i.nameSpelling = [i.name transformToPinyin];
                        NSString *action = [item attributeStringValueForName:@"action"];
                        if (action.intValue == 1) {
                            [AINewFriendsCRUD updateStatus:i.status ofRequester:i.requester];
                        }else {
                            [AINewFriendsCRUD addANewFriendItem:i];
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_New_Friend_Request" object:nil];
                    });
                    return YES;
                }
                else if([query.xmlns isEqualToString:@"http://www.nihualao.com/xmpp/circle/create"]){
                    if ([@"result" isEqualToString:iq.type]) {
                        NSMutableArray *groupArray = [[NSMutableArray alloc]init];
                        for (NSXMLElement *item in items) {
                            // NSLog(@"******%@",item);
                            if([@"circle" isEqualToString:item.name]){
                                /*
                                 NSString *circleType = [item attributeStringValueForName:@"circleType"];
                                 if(![circleType isEqualToString:@"circle"]){
                                 continue;
                                 }
                                 */
                                ChatGroup *chatGroup = [[ChatGroup alloc]init];
                                
                                NSString *circleVersion = [item attributeStringValueForName:@"ver"];
                                
                                NSString *groupJID = [item attributeStringValueForName:@"jid"];
                                
                                NSString *groupMucJID = [item attributeStringValueForName:@"room"];
                                NSString *groupName = [item attributeStringValueForName:@"name"];
                                NSString *creator = [item attributeStringValueForName:@"creator"];
                                NSString *inviteUrl = [item attributeStringValueForName:@"inviteUrl"];
                                NSString *createDate = [item attributeStringValueForName:@"createDate"];
                                NSString *modificationDate = [item attributeStringValueForName:@"modificationDate"];
                                
                                chatGroup.version = circleVersion;
                                chatGroup.jid = groupJID;
                                chatGroup.name = groupName;
                                chatGroup.creator = creator;
                                chatGroup.groupMucId = groupMucJID;
                                chatGroup.inviteUrl = inviteUrl;
                                chatGroup.createDate = createDate;
                                chatGroup.modificationDate = modificationDate;
                                
                                [groupArray addObject:chatGroup];
                                
                            }
                        }
                        if (groupArray.count==1) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_GroupCreate" object:groupArray userInfo:nil];
                        }
                        return YES;
                    }else {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_GroupCreate_Error" object:nil userInfo:nil];
                        return NO;
                    }
                    
                }else if([query.xmlns isEqualToString:@"http://www.nihualao.com/xmpp/circle/notify"]){
                    //  NSLog(@"*******%@",iq);
                    //获取圈子,客户端查询
                    NSMutableArray *groupArray = [[NSMutableArray alloc]init];
                    NSMutableArray *groupMemberArray = [[NSMutableArray alloc]init];
                    // NSLog(@"xmmpp******%@",items);
                    
                    
                    for (NSXMLElement *item in items) {
                        // NSLog(@"******%@",item);
                        if([@"circle" isEqualToString:item.name]){
                            /*
                             NSString *circleType = [item attributeStringValueForName:@"circleType"];
                             if(![circleType isEqualToString:@"circle"]){
                             continue;
                             }
                             */
                            ChatGroup *chatGroup = [[ChatGroup alloc]init];
                            
                            NSString *circleVersion = [item attributeStringValueForName:@"ver"];
                            
                            NSString *groupJID = [item attributeStringValueForName:@"jid"];
                            
                            NSString *groupMucJID = [item attributeStringValueForName:@"room"];
                            NSString *groupName = [item attributeStringValueForName:@"name"];
                            NSString *creator = [item attributeStringValueForName:@"creator"];
                            NSString *inviteUrl = [item attributeStringValueForName:@"inviteUrl"];
                            NSString *createDate = [item attributeStringValueForName:@"createDate"];
                            NSString *modificationDate = [item attributeStringValueForName:@"modificationDate"];
                            NSString *removeStr = [item attributeStringValueForName:@"remove"];
                            
                            chatGroup.version = circleVersion;
                            chatGroup.jid = groupJID;
                            chatGroup.name = (groupName == nil) ? @"" : groupName;
                            chatGroup.creator = creator;
                            chatGroup.groupMucId = groupMucJID;
                            chatGroup.inviteUrl = inviteUrl;
                            chatGroup.createDate = createDate;
                            chatGroup.modificationDate = modificationDate;
                            chatGroup.removeStr = removeStr;
                            
                            [groupArray addObject:chatGroup];
                            
                            //通过委托写入数据
                            //[groupChatDelegate chatGroupReceived:chatGroup];
                            
                            
                            //修改圈子成员名称时，没有返回members 节点，所以单独处理
                            NSArray *member = [item elementsForName:@"member"];
                            
                            for (NSXMLElement *membersElement in member) {
                                
                                if([@"member" isEqualToString:membersElement.name]){
                                    
                                    NSString *jid = [membersElement attributeStringValueForName:@"jid"];
                                    NSString *role = [membersElement attributeStringValueForName:@"role"];
                                    NSString *nickName = [membersElement attributeStringValueForName:@"nickname"];
                                    NSString *memberRemove = [membersElement attributeStringValueForName:@"remove"];
                                    
                                    if([memberRemove isEqualToString:@"true"]){
                                        role = @"";
                                        nickName = @"";
                                        
                                    }
                                    
                                    [groupMemberArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",nickName, @"nickName",role,@"role",groupJID,@"groupJID",groupMucJID,@"groupMucJID",memberRemove,@"remove", nil]];
                                    
                                }
                            }
                            
                            NSArray *members = [item elementsForName:@"members"];
                            for (NSXMLElement *membersElement in members) {
                                
                                NSArray *member = [membersElement children];
                                
                                for (NSXMLElement *item in member) {
                                    // GroupMembers *groupMembers = [[GroupMembers alloc]init];
                                    
                                    NSString *jid = [item attributeStringValueForName:@"jid"];
                                    NSString *role = [item attributeStringValueForName:@"role"];
                                    NSString *nickName = [item attributeStringValueForName:@"nickname"];
                                    NSString *memberRemove = [StrUtility string:[item attributeStringValueForName:@"remove"]];
                                    NSString *createTime = [item attributeStringValueForName:@"create"];
                                    
                                    if([memberRemove isEqualToString:@"true"]){
                                        role = @"";
                                        nickName = @"";
                                    }
                                    
                                    //                                    groupMembers.jid = jid;
                                    //                                    groupMembers.nickName = nickName;
                                    //                                    groupMembers.role = role;
                                    //                                    //名字须统一
                                    //                                    groupMembers.groupJID = groupJID;
                                    
                                    //[groupChatDelegate groupMembersReceived:groupMembers];
                                    
                                    [groupMemberArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",nickName, @"nickName",role,@"role",groupJID,@"groupJID",groupMucJID,@"groupMucJID", createTime, @"createtime", memberRemove,@"remove",nil]];
                                    
                                }
                            }
                            
                            chatGroup.groupMembersArray = groupMemberArray;
                        }
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_Group" object:groupArray userInfo:nil];
                        
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_GroupMember" object:groupMemberArray userInfo:nil];
                    
                    
                    return  YES;
                    
                    
                }else if([@"http://www.nihualao.com/xmpp/dnd" isEqualToString:query.xmlns]){
                    //免打扰消息的处理
//                    <iq type="result" to="11500@ab-insurance.com/Peyser-PC">
//                    <query xmlns="http://www.nihualao.com/xmpp/dnd">
//                    <item isChanged="false" remove="false" jid="11700@ab-insurance.com"/>
//                    <item isChanged="true" remove="true" jid="11700@ab-insurance.com"/>
//                    </query>
//                    </iq>
                    NSArray* items = [query children];
                    NSString* jid = @"";
                    NSString* isAdd = @"";
                 
                    if ([query attributeForName:@"ver"] == nil || [[query attributeForName:@"ver"].stringValue isEqualToString:@""]) {
                        NSXMLElement *itemTemp = [items firstObject];
                        if([[[itemTemp attributeForName:@"isChanged"] stringValue] isEqualToString:@"true"]){
                            if([[[itemTemp attributeForName:@"remove"] stringValue] isEqualToString:@"true"]){
                                isAdd = @"0";
                            }else{
                                isAdd = @"1";
                            }
                            jid = [[itemTemp attributeForName:@"jid"] stringValue];
                            
                            if ([DndInfoCRUD queryOfRosterExtNumberWithJid:jid] == 0) {
                                [DndInfoCRUD insertOfRosterExtTableWithUserName:MY_USER_NAME Jid:jid Dnd:isAdd];
                            }else if ([DndInfoCRUD queryOfRosterExtNumberWithJid:jid] == 1){
                                [DndInfoCRUD updateOfRosterExtWithJid:jid Dnd:isAdd];
                            }
                            
                        }

                        
                    }else{
                        for (NSXMLElement *itemTemp in items) {
                            
                            if([itemTemp.name isEqualToString:@"item"]){
                                
                                jid = [[itemTemp attributeForName:@"jid"] stringValue];
                                isAdd = @"1";
                                if ([DndInfoCRUD queryOfRosterExtNumberWithJid:jid] == 0) {
                                    [DndInfoCRUD insertOfRosterExtTableWithUserName:MY_USER_NAME Jid:jid Dnd:isAdd];
                                }else if ([DndInfoCRUD queryOfRosterExtNumberWithJid:jid] == 1){
                                    [DndInfoCRUD updateOfRosterExtWithJid:jid Dnd:isAdd];
                                }
                            }
                        }
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"CNN_Update_Group_Member" object:nil userInfo:nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_UpdateContact" object:nil userInfo:nil];
                    
                }else if([query.xmlns isEqualToString:@"http://www.nihualao.com/xmpp/token"]){
                    
                    NSArray* items = [query children];
                    NSString *mytoken = @"";
                    long expiresIn = 0;
                    NSXMLElement *item = [items firstObject];
                    if([item.name isEqualToString:@"token"]){
                        mytoken = item.stringValue;
                        expiresIn = [item attributeUInt32ValueForName:@"expiresin"];
                    }
                    
                    if(![mytoken isEqualToString:@""] && mytoken != nil){
                        [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithLong:expiresIn] forKey:@"mytokenExpiresIn"];
                        [[NSUserDefaults standardUserDefaults] setObject: mytoken forKey:@"mytoken"];
                        [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithLong:
                                                                           (long)[[NSDate date] timeIntervalSince1970]] forKey:@"mytokenCreateTime"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    
                }
                else if([query.xmlns isEqualToString:@"http://www.nihualao.com/xmpp/userinfo"]){
                    //所有订阅关系者,服务器主动推送(根据命名空间判断）
                    
                    NSString *userInfoVersion = [[query attributeForName:@"ver"] stringValue];
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:userInfoVersion forKey:@"Ver_Query_UserInfo"];
                    
                    NSMutableArray *userInfoArray = [[NSMutableArray alloc]init];
                    for (NSXMLElement *item in items) {
                        if ([@"user" isEqualToString:item.name]) {
      
                            
                            NSString *jid = [item attributeStringValueForName:@"jid"];
                            NSString *remarkName = @"";
                            NSString *phone = [[item elementForName:@"phone"] stringValue];
                            NSString *nickName = [[item elementForName:@"name"] stringValue];
                            NSString *avatar = [[item elementForName:@"avatar"] stringValue];

                            //NSString *ver = [item attributeStringValueForName:@"ver"];
                            NSString *remove = [item attributeStringValueForName:@"remove"];

                            
                            NSString *email = [[item elementForName:@"email"] stringValue];
                            NSString *secondEmail = [[item elementForName:@"secondEmail"] stringValue];
                            NSString *source = [[item elementForName:@"source"] stringValue];
                            NSString *inviteUrl = [[item elementForName:@"inviteUrl"] stringValue];
                            NSString *accountType = [[item elementForName:@"accountType"] stringValue];
                            NSString *cemployeeCde = [[item elementForName:@"cemployeeCde"] stringValue];
                            NSString *accountName = [[item elementForName:@"accountName"] stringValue];
                            NSString *gender = [[item elementForName:@"gender"] stringValue];
                            NSString *areaId = [[item elementForName:@"areaId"] stringValue];
                            NSString *bookNme = [[item elementForName:@"bookNme"] stringValue];
                            NSString *agencyNme = [[item elementForName:@"agencyNme"] stringValue];
                            NSString *branchNme = [[item elementForName:@"branchNme"] stringValue];
                            NSString *centerNme = [[item elementForName:@"centerNme"] stringValue];
                            NSString *employeeNme = [[item elementForName:@"employeeNme"] stringValue];
                            NSString *departmentNme = [[item elementForName:@"departmentNme"] stringValue];
                            NSString *signature = [[item elementForName:@"signature"] stringValue];
                            NSString *employeePhone = [[item elementForName:@"employeePhone"] stringValue];
                            NSString *officalPhone = [[item elementForName:@"officalPhone"] stringValue];
                            NSString *publicPhone = [[item elementForName:@"publicPhone"] stringValue];
                            
                            
                            jid = jid ? jid : @"";
                            remarkName = @"";
                            phone = phone ? phone : @"";
                            nickName = nickName ? nickName : @"";
                            avatar = avatar ? avatar : @"";
                            remove = remove ? remove : @"";
                            email = email ? email : @"";
                            secondEmail = secondEmail ? secondEmail : @"";
                            source = source ? source : @"";
                            inviteUrl = inviteUrl ? inviteUrl : @"";
                            accountType = accountType ? accountType : @"";
                            cemployeeCde = cemployeeCde ? cemployeeCde : @"";
                            accountName = accountName ? accountName : @"";
                            gender = gender ? gender : @"";
                            areaId = areaId ? areaId : @"";
                            bookNme = bookNme ? bookNme : @"";
                            agencyNme = agencyNme ? agencyNme : @"";
                            branchNme = branchNme ? branchNme : @"";
                            centerNme = centerNme ? centerNme : @"";
                            employeeNme = employeeNme ? employeeNme : @"";
                            departmentNme = departmentNme ? departmentNme : @"";
                            signature = signature ? signature : @"";
                            employeePhone = employeePhone ? employeePhone : @"";
                            officalPhone = officalPhone ? officalPhone : @"";
                            publicPhone = publicPhone ? publicPhone : @"";
                            userInfoVersion = userInfoVersion ? userInfoVersion : @"";
                            
                            NSMutableDictionary *d = [NSMutableDictionary dictionary];
                            [d setObject:employeePhone forKey:@"employeePhone"];
                            [d setObject:officalPhone forKey:@"officalPhone"];
                            [d setObject:publicPhone forKey:@"publicPhone"];
                            [d setObject:signature forKey:@"signature"];
                            [d setObject:jid forKey:@"jid"];
                            [d setObject:remarkName forKey:@"remarkName"];
                            [d setObject:phone forKey:@"phone"];
                            [d setObject:nickName forKey:@"nickName"];
                            [d setObject:avatar forKey:@"avatar"];
                            [d setObject:email forKey:@"email"];
                            [d setObject:secondEmail forKey:@"secondEmail"];
                            [d setObject:source forKey:@"source"];
                            [d setObject:inviteUrl forKey:@"inviteUrl"];
                            [d setObject:accountType forKey:@"accountType"];
                            [d setObject:cemployeeCde forKey:@"cemployeeCde"];
                            [d setObject:accountName forKey:@"accountName"];
                            [d setObject:gender forKey:@"gender"];
                            [d setObject:areaId forKey:@"areaId"];
                            [d setObject:bookNme forKey:@"bookNme"];
                            [d setObject:agencyNme forKey:@"agencyNme"];
                            [d setObject:branchNme forKey:@"branchNme"];
                            [d setObject:centerNme forKey:@"centerNme"];
                            [d setObject:employeeNme forKey:@"employeeNme"];
                            [d setObject:departmentNme forKey:@"departmentNme"];
                            [d setObject:remove forKey:@"remove"];
                            [d setObject:userInfoVersion forKey:@"version"];
                            
                            [userInfoArray addObject:d];
                            
                            
//                            [userInfoArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:employeePhone, @"employeePhone", officalPhone ,@"officalPhone", publicPhone, @"publicPhone", signature, @"signature",jid,@"jid",remarkName, @"remarkName",phone,@"phone",nickName,@"nickName",avatar,@"avatar",email,@"email",secondEmail,@"secondEmail",source,@"source",inviteUrl,@"inviteUrl",accountType,@"accountType",cemployeeCde,@"cemployeeCde",accountName,@"accountName",gender,@"gender",areaId,@"areaId",bookNme,@"bookNme",agencyNme,@"agencyNme",branchNme,@"branchNme",centerNme,@"centerNme",employeeNme,@"employeeNme",departmentNme,@"departmentNme",remove,@"remove",userInfoVersion, @"version", nil]];
                            
                        }
                    }
                    
//                    JLLog_I(@"userInfoArray=%@", userInfoArray);
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AI_After_Bind_Succeed" object:userInfoArray userInfo:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_UserInfo" object:userInfoArray userInfo:nil];
                    
                    
                    
                }else if([query.xmlns isEqualToString:@"jabber:iq:roster"]){
                    
                    // NSLog(@"xmmpp******%@",iq);
                    NSString *rosterVersion = [[query attributeForName:@"ver"] stringValue];
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:rosterVersion forKey:@"Ver_Query_Roster"];
                    
                    NSMutableArray *contactsArray = [[NSMutableArray alloc]init];
                    
                    for (NSXMLElement *item in items) {
                        //订阅签署状态
                        NSString *subscription = [item attributeStringValueForName:@"subscription"];
                        NSString *jid = [item attributeStringValueForName:@"jid"];
                        NSString *remarkName =[StrUtility string:[item attributeStringValueForName:@"name"]];
                        [contactsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",remarkName, @"name", subscription, @"subscription", nil]];
                    }
                    
//                    JLLog_I(@"contactArray=%@", contactsArray);
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_Contacts" object:contactsArray userInfo:nil];
                    
                }
            }
            //用户头像
            else if([@"vCard" isEqualToString:query.name]){
                //NSString *avatar_url =  [[query elementForName:@"avatar_url" ]stringValue];
                //NSLog(@"****%@",avatar_url);
                //消息委托（图像)
                //[chatDelegate avatarReceived:avatar_url];
            }
        }
    }
    return YES;
}






/*
 收到消息
 <message
 to='romeo@example.net'
 from='juliet@example.com/balcony'
 type='chat'
 xml:lang='en'>
 <body>Wherefore art thou, Romeo?</body>
 </message>
 
 */
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSLog(@"－－－－－－－－－－－－－－收到消息－－－－－－－－－－－－－－－－－－");
    
    NSLog(@"%@",message);
    NSString *msgRandomId = [[message attributeForName:@"id"] stringValue];
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    NSString *type = [[message attributeForName:@"type" ]stringValue];
    DDXMLElement *delay = [message elementForName:@"delay"];
    NSString *sendUTCTimeStr = [[delay attributeForName:@"stamp"]stringValue];
    
    NSString *subject = [[message elementForName:@"subject" ]stringValue];
    
    
    NSString *mtype = [[message elementForName:@"mtype" ]stringValue];
    
    if([StrUtility isBlankString:msgRandomId] || [StrUtility isBlankString:from] || [StrUtility isBlankString:msg]){
        return;
    }
    
    DDXMLElement *reqEle = [message elementForName:@"req"];
    NSString *reqId = [[reqEle attributeForName:@"id"] stringValue];
    
    //消息回执，已收到消息
    if (![reqId isEqualToString:@""] && reqId !=NULL ) {
        [self sendMsgReceipt:reqId];
    }
    
    DDXMLElement *event=[message elementForName:@"event"];
    DDXMLElement *items=[event elementForName:@"items"];
    DDXMLElement *item=[items elementForName:@"item"];
    
    if([type isEqualToString:@"chat"]){
        NSString *userName = (NSString*)[[from componentsSeparatedByString:@"@"] objectAtIndex:0];
        NSString *jid = [NSString stringWithFormat:@"%@@%@", userName, OpenFireHostName];
        NSInteger count = [UserInfoCRUD queryUserInfoTableCountId:jid myJID:MY_JID];
        if (count <= 0) {
            [AIMessagesManager setMessage:message forKey:jid];
            [xmppServer sendABContactInfoIQ:userName];
            return;
        }
    }
    
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
    
    //tyep＝error
    if([type isEqualToString:@"error"]){
        return;
    }
    
    //多人聊天
    //多人对话
    NSString *thread=[[message elementForName:@"thread"]stringValue];
    if (thread!=nil) {
        type=@"multichat";
    }
    
    
    //    ********新闻********
    DDXMLElement *news=[item elementForName:@"news"];
    NSString *title=[[news attributeForName:@"title"] stringValue]; //新闻标题
    NSString *outline=[[news attributeForName:@"outline"] stringValue];//新闻内容
    NSString *imgUrl=[[news attributeForName:@"imgUrl"] stringValue];     //图片文件服务器地址
    NSString *url=[[news attributeForName:@"url"] stringValue];     //新闻地址
    NSString *publishTime=[[news attributeForName:@"publishTime"] stringValue]; //发布时间
    //********新闻********
    
    //********系统消息***********
    //NSXMLElement *properties=[message elementForName:@"properties"];
    NSXMLElement *body=[message elementForName:@"body"];
    NSString *sendTime=nil;
    NSString *systemMessage=nil;
    //********系统消息通知上传通讯录***********
    
    
    

    
    
    
#if !TARGET_IPHONE_SIMULATOR
    //如果是语音和视频电话的离线消息时，需要回复一条消息告诉对方重发信令
    if ([type isEqualToString:@"chat"] && [subject isEqualToString:@"phone"]) {
        // NSString *jid=[NSString stringWithFormat:@"%@@%@/%@",from,OpenFireHostName,@"Hisuper"];
        // NSDictionary *msgDic = [msg objectFromJSONString];
        
        // XMPPJID *chatWithJID = [XMPPJID jidWithString:from] ;
        //  [[VoipModule shareVoipModule] sendOnline:chatWithJID isvideo:false msgID:msgRandomId];
        
    }else if([type isEqualToString:@"chat"] && [subject isEqualToString:@"video"]){
        
        //NSDictionary *msgDic = [msg objectFromJSONString];
        
        // XMPPJID *chatWithJID = [XMPPJID jidWithString:from] ;
        // [[VoipModule shareVoipModule] sendOnline:chatWithJID isvideo:true msgID:msgRandomId];
    }
#endif
    
    //向通知中心发送消息     +新闻识别  news字段 +系统通知headline
    if ([type isEqualToString:@"chat"] || [type isEqualToString:@"groupchat"] || [type isEqualToString:@"multichat"] || [type isEqualToString:@"normal"] || [type isEqualToString:@"headline"]) {
        JLLog_I(@"<type=%@>",type);
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:message forKey:@"message"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_ChatMessage" object:self userInfo:dictionary];
    }
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        
        if ([type isEqualToString:@"chat"]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            if(msgRandomId != nil){
                [dict setObject:msgRandomId forKey:@"msgRandomId"];
            }
            
            if (msg !=nil) {
                
                [dict setObject:msg forKey:@"msg"];
                [dict setObject:from forKey:@"sender"];
                if (type == NULL) {
                    type = @"";
                }
                
                if (subject == NULL||subject == nil) {
                    subject = @"";
                }
                [dict setObject:type forKey:@"type"];
                [dict setObject:subject forKey:@"subject"];
                
                
                //消息接收到的时间
                if (sendUTCTimeStr ==nil) {
                    sendUTCTimeStr=@"";
                }
                [dict setObject:sendUTCTimeStr forKey:@"sendTime"];
                
                //消息委托（聊天界面）
                [messageDelegate newMessageReceived:dict];
            }
            
            
        }else if([type isEqualToString:@"groupchat"]){
            
            [groupMessageDelegate newGroupMessageReceived:message];
            
        }else if([type isEqualToString:@"normal"]){
            
            [messageDelegate newMessageReceived:nil];
            
        }else if(news!=nil){
            //[JSMessageSoundEffect playMessageReceivedSound2];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:msgRandomId forKey:@"msgRandomId"];
            if (title!=nil||outline!=nil||imgUrl!=nil||url!=nil||publishTime!=nil) {
                /*
                 [dict setObject:@"新闻" forKey:@"sender"];
                 [dict setObject:title forKey:@"title"];
                 [dict setObject:outline forKey:@"outline"];
                 [dict setObject:imgUrl forKey:@"imgUrl"];
                 [dict setObject:url forKey:@"url"];
                 [dict setObject:publishTime forKey:@"publishTime"];
                 */
            }
            
            //消息委托（聊天界面）
            [messageDelegate newMessageReceived:dict];
            
        }else if([systemMessage isEqualToString:@"email_activated"]||[systemMessage isEqualToString:@"modify_password"]){
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:@"" forKey:@"msgRandomId"];
            [dict setObject:@"系统通知" forKey:@"sender"];
            [dict setObject:body forKey:@"msg"];
            [dict setObject:sendTime forKey:@"sendTime"];
            //消息委托（聊天界面）
            [messageDelegate newMessageReceived:dict];
            
        }else if ([type isEqualToString:@"normal"]){
            
            
            
            
        }
        
    }else if([UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground){//如果程序在后台运行，收到消息以通知类型来显示
        if (![type isEqualToString:@"chat"]&&![type isEqualToString:@"groupchat"]&&news==nil&&![type isEqualToString:@"headline"] &&![type isEqualToString:@"multichat"]){
            return;
        }
        
        if ([@"notice" isEqualToString:subject]){
            return;
        }
        
        if ([type isEqualToString:@"chat"]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:msgRandomId forKey:@"msgRandomId"];
            
            if (msg !=nil) {
                
                [dict setObject:msg forKey:@"msg"];
                [dict setObject:from forKey:@"sender"];
                if (type == NULL) {
                    type = @"";
                }
                
                if (subject == NULL||subject == nil) {
                    subject = @"";
                }
                [dict setObject:type forKey:@"type"];
                [dict setObject:subject forKey:@"subject"];
                
                
                //消息接收到的时间
                if (sendUTCTimeStr ==nil) {
                    sendUTCTimeStr=@"";
                }
                [dict setObject:sendUTCTimeStr forKey:@"sendTime"];
                
                //消息委托（聊天界面）
                [messageDelegate newMessageReceived:dict];
            }
            
            
        }else if([type isEqualToString:@"groupchat"]){
            
            [groupMessageDelegate newGroupMessageReceived:message];
            
        }else if([type isEqualToString:@"multichat"]){
            [groupMessageDelegate newMultiChatMessageReceived:message];
            
        }else if(news!=nil){
            //[JSMessageSoundEffect playMessageReceivedSound2];
            /*
             NSMutableDictionary *dict = [NSMutableDictionary dictionary];
             [dict setObject:msgRandomId forKey:@"msgRandomId"];
             if (title!=nil||outline!=nil||imgUrl!=nil||url!=nil||publishTime!=nil) {
             [dict setObject:@"新闻" forKey:@"sender"];
             [dict setObject:title forKey:@"title"];
             [dict setObject:outline forKey:@"outline"];
             [dict setObject:imgUrl forKey:@"imgUrl"];
             [dict setObject:url forKey:@"url"];
             [dict setObject:publishTime forKey:@"publishTime"];
             }
             
             //消息委托（聊天界面）
             [messageDelegate newMessageReceived:dict];
             */
            
        }else if([systemMessage isEqualToString:@"email_activated"]||[systemMessage isEqualToString:@"modify_password"]){
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:@"" forKey:@"msgRandomId"];
            [dict setObject:@"系统通知" forKey:@"sender"];
            [dict setObject:body forKey:@"msg"];
            [dict setObject:sendTime forKey:@"sendTime"];
            //消息委托（聊天界面）
            [messageDelegate newMessageReceived:dict];
            
        }
        
        //消息发送者信息
        NSString *fromJID = @"";
        NSString *name = @"";
        NSString *groupName = @"";
        // UserInfo *userInfo = nil;
        NSString*str_character = @"/";
        NSRange senderRange = [from rangeOfString:str_character];
        if ([from rangeOfString:str_character].location != NSNotFound) {
            fromJID = [from substringToIndex:senderRange.location];
        }else {
            fromJID = from;
        }
        
        JLLog_I(@"<fromJID=%@>", fromJID);
        
        NSString *msg = [[message elementForName:@"body"] stringValue];
        
        if ([type isEqualToString:@"chat"] || [type isEqualToString:@"multichat"]) {
            
            /*
            userInfo = [UserInfoCRUD queryUserInfo:fromJID myJID:MY_JID];
            NSString *remarkName = [ContactsCRUD queryContactsRemarkName:fromJID];
            
            if (remarkName ==nil || [remarkName isEqualToString:@"(null)"] || [remarkName isEqualToString:@""]) {
                if (userInfo.nickName==nil || [userInfo.nickName isEqualToString:@"(null)"] || [userInfo.nickName isEqualToString:@""]) {
                    NSString*str_character = @"@";
                    NSRange senderRange = [from rangeOfString:str_character];
                    if ([from rangeOfString:str_character].location != NSNotFound) {
                        name = [from substringToIndex:senderRange.location];
                    }
                }else{
                    name = userInfo.nickName;
                }
            }else {
                name = remarkName;
            }
             */
            
            // name show
            name = [AIUsersUtility nameForShowWithJID:fromJID];
            
        }else if([type isEqualToString:@"groupchat"]){
            NSString *groupJID=@"";
            NSString *senderJID=@"";
            NSString *senderUserName=@"";
            
            NSString*str_character = @"@";
            
            NSRange senderRange = [from rangeOfString:str_character];
            if ([from rangeOfString:str_character].location != NSNotFound) {
                groupJID = [NSString stringWithFormat:@"%@@%@",[from substringToIndex:senderRange.location],GroupDomain];
            }
            
            NSArray *arry=[from componentsSeparatedByString:@"/"];
            
            if (arry.count==2) {
                
                senderUserName = [arry objectAtIndex:1];
                
                if ([senderUserName rangeOfString:@"_"].location != NSNotFound) {
                    
                    senderUserName= [senderUserName substringToIndex:[senderUserName rangeOfString:@"_"].location];
                }
            }
            senderJID = [NSString stringWithFormat:@"%@@%@",senderUserName,OpenFireHostName];
            //排除自己发送的消息
            if ([senderUserName isEqualToString:MY_USER_NAME]) {
                return;
            }
            
            NSMutableDictionary * groupMemberDic =[GroupMembersCRUD queryMemberNameByMemberJID:groupJID memberJID:senderJID myJID:MY_JID];
            if ([groupMemberDic objectForKeyedSubscript:@"businessCard"]) {
                name = [groupMemberDic objectForKeyedSubscript:@"businessCard"];
            }else{
                name = [groupMemberDic objectForKeyedSubscript:@"nickName"];
            }
            
            // name show
            name = [AIUsersUtility gnameForShowWithJID:senderJID inGroup:groupJID];

            NSDictionary *chatGroup = [GroupCRUD queryOneMyChatGroup:groupJID myJID:MY_JID];
            groupName = [chatGroup objectForKey:@"groupName"];
            if(groupName == nil || [@"" isEqualToString:groupName] || [@"(null)" isEqualToString:groupName]){
                groupName = NSLocalizedString(@"public.groupChat",@"message");
            }
        }
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        
        BOOL isDndJID = [DndInfoCRUD queryOfRosterExtWithJid:[from componentsSeparatedByString:@"/"][0]];
        if ((hasAtMe || !isDndJID) && localNotification!=nil) {
            // NSDate *now=[NSDate new];
            // localNotification.fireDate=[now dateByAddingTimeInterval:1];//10秒后通知
            
            NSMutableArray *msgArray = [[NSMutableArray alloc] init];
            [StrUtility getImageRange:msg :msgArray];
            NSString *regularMsg= @"";
            
            if ([type isEqualToString:@"chat"]) {
                
                localNotification.alertAction = @"查看";
                
                if ([type isEqualToString:@"chat"] && [subject isEqualToString:@"phone"]) {
                    msg =  NSLocalizedString(@"localNotification.audio.msg",@"message");
                    // NSString* soundPath = [[NSBundle mainBundle] pathForResource:@"app_ring" ofType:@"wav"];
                    localNotification.soundName = @"app_ring.wav";//通知声音
                    
                }else if([type isEqualToString:@"chat"] && [subject isEqualToString:@"video"]){
                    msg = [NSString stringWithFormat:@"%@:%@", name, NSLocalizedString(@"localNotification.video.msg",@"message")];
                    //NSString* soundPath = [[NSBundle mainBundle] pathForResource:@"app_ring" ofType:@"wav"];
                    localNotification.soundName = @"app_ring.wav";//通知声音
                    
                }else if([type isEqualToString:@"chat"] && [subject isEqualToString:@"image"]){
                    msg = [NSString stringWithFormat:@"%@:%@", name, NSLocalizedString(@"localNotification.image.msg",@"action")];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;//通知声音
                }else if([type isEqualToString:@"chat"] && [subject isEqualToString:@"article"]){
                    msg = [NSString stringWithFormat:@"%@：%@", name, @"[链接]"];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;//通知声音
                }
                
                else if([type isEqualToString:@"chat"] && [subject isEqualToString:@"voice"]){
                    msg = [NSString stringWithFormat:@"%@:%@", name, NSLocalizedString(@"localNotification.voice.msg",@"message")];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;//通知声音
                }else if ([type isEqualToString:@"chat"] && [subject isEqualToString:@"card"]) {
                    AIPersonalCard *card = [AIPersonalCard cardWithJson:msg];
                    NSString *bName = [AIUsersUtility nameForShowWithJID:card.username];
                    msg = [NSString stringWithFormat:@"%@推荐了%@", name, ![StrUtility isBlankString:bName] ? bName : card.name];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;
                }else if ([type isEqualToString:@"chat"] && [subject isEqualToString:@"document"]) {
                    AIDocument *doc = [AIDocument documentWithJson:msg];
                    msg = [NSString stringWithFormat:@"%@:%@", name, doc.fileName];
                     localNotification.soundName = UILocalNotificationDefaultSoundName;
                }else if ([type isEqualToString:@"chat"] && [subject isEqualToString:@"location"]) {
                    msg = [NSString stringWithFormat:@"%@发送了一个地理位置",name];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;
                }
                else{
                    if (msgArray) {
                        if (msgArray.count<2) {
                            regularMsg = msg;
                        }else{
                            for (int i=0;i < [msgArray count];i++) {
                                NSString *s=[msgArray objectAtIndex:i];
                                
                                //  NSLog(@"str--->%@",s);
//                                
//                                if ([s hasPrefix: CHAT_BEGIN_FLAG] && [s hasSuffix: CHAT_END_FLAG])
//                                {
//                                    //    //NSLog(@"str(image)---->%@",str);
//                                    s=NSLocalizedString(@"public.text.emoji",@"message");
//                                    
//                                }
                                regularMsg =[NSString stringWithFormat:@"%@%@",regularMsg,s];
                            }
                        }
                    }
                    if ([msg isEqualToString:@"咕嘟"]|| [msg isEqualToString:@"gurgle"]) {
                        localNotification.soundName = @"gudu.wav";//通知声音
                        
                    }else{
                        localNotification.soundName = UILocalNotificationDefaultSoundName;//通知声音
                    }
                }
                
            }else if([type isEqualToString:@"groupchat"]){
                
                localNotification.alertAction = @"查看";
                
                if([mtype isEqualToString:@"image"]){
                    msg = [NSString stringWithFormat:@"%@：%@", name, NSLocalizedString(@"localNotification.image.msg",@"action")];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;//通知声音
                }else if([mtype isEqualToString:@"voice"]){
                    msg = [NSString stringWithFormat:@"%@：%@", name, NSLocalizedString(@"localNotification.voice.msg",@"message")];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;//通知声音
                }else if ([mtype isEqualToString:@"card"]) {
                    AIPersonalCard *card = [AIPersonalCard cardWithJson:msg];
                    NSString *bName = [AIUsersUtility nameForShowWithJID:card.username];
                    msg = [NSString stringWithFormat:@"%@推荐了%@", name, ![StrUtility isBlankString:bName] ? bName : card.name];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;
                }else if ([mtype isEqualToString:@"article"]) {
                    msg = [NSString stringWithFormat:@"%@：%@", name, @"[链接]"];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;
                }
                else if ([mtype isEqualToString:@"document"]) {
                    AIDocument *doc = [AIDocument documentWithJson:msg];
                    msg = [NSString stringWithFormat:@"%@：%@", name, doc.fileName];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;
                }else if ([mtype isEqualToString:@"location"]) {
                    msg = [NSString stringWithFormat:@"%@发送了一个地理位置",name];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;
                }else if ([mtype isEqualToString:@"chat"]) {
                    msg = [NSString stringWithFormat:@"%@：%@", name, msg];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;
                }
                else{
                    localNotification.soundName = UILocalNotificationDefaultSoundName;//通知声音
                }
                
            }else if([type isEqualToString:@"multichat"]){
                
                if([mtype isEqualToString:@"image"]){
                    msg =  NSLocalizedString(@"localNotification.image.msg",@"action");
                    localNotification.soundName = UILocalNotificationDefaultSoundName;//通知声音
                }else if([mtype isEqualToString:@"voice"]){
                    msg =  NSLocalizedString(@"localNotification.voice.msg",@"message");
                    localNotification.soundName = UILocalNotificationDefaultSoundName;//通知声音
                }else{
                    localNotification.soundName = UILocalNotificationDefaultSoundName;//通知声音
                }
                
            }else{
                
                localNotification.soundName = UILocalNotificationDefaultSoundName;//通知声音
                
            }
            
            if ([type isEqualToString:@"chat"] && [subject isEqualToString:@"chat"]) {
                localNotification.alertBody = [NSString stringWithFormat:@"%@:%@",[StrUtility string:name],regularMsg];//通知主体
                
            }else{
                if(hasAtMe){
                    localNotification.alertBody = [NSString stringWithFormat:@"%@%@",[StrUtility string:name], NSLocalizedString(@"localNotification.atMe.msg",@"message")];
                } else{
                    localNotification.alertBody = msg;
                }
            }
            
            if(kIOS_VERSION >= 8.2){
                localNotification.alertTitle = [type isEqualToString:@"groupchat"]?groupName:[StrUtility string:name];
            }
            
            int unreadTotal = [ChatBuddyCRUD queryAllMsgTotal];
            localNotification.applicationIconBadgeNumber = unreadTotal;//标记数
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];//发送通知
            //[[UIApplication sharedApplication]   scheduleLocalNotification:localNotification];
            
        }
        
    }
}

/*
 消息回执
 */
-(void)sendMsgReceipt:(NSString*)reqId{
    //XMPPFramework主要是通过KissXML来生成XML文件
    //生成XML消息文档
    NSXMLElement *ack = [NSXMLElement elementWithName:@"ack"];
    //消息id
    [ack addAttributeWithName:@"id" stringValue:reqId];
    NSLog(@"%@",ack);
    //发送消息
    [[XMPPServer xmppStream] sendElement:ack];
    
}


/*
 回复ping包
 */
-(void)sendPingPacket:(NSString*)reqId{
    //XMPPFramework主要是通过KissXML来生成XML文件
    //生成XML消息文档
    @autoreleasepool {
        
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        //消息id
        [iq addAttributeWithName:@"id" stringValue:reqId];
        [iq addAttributeWithName:@"type" stringValue:@"result"];
        //发送消息
        [[XMPPServer xmppStream] sendElement:iq];
    }
}



/*
 收到好友状态
 <presence xmlns="jabber:client"
 from="user3@chtekimacbook-pro.local/ch&#x7684;MacBook Pro"
 to="user2@chtekimacbook-pro.local/7b55e6b">
 <priority>0</priority>
 <c xmlns="http://jabber.org/protocol/caps" node="http://www.apple.com/ichat/caps" ver="900" ext="ice recauth rdserver maudio audio rdclient mvideo auxvideo rdmuxing avcap avavail video"/>
 <x xmlns="http://jabber.org/protocol/tune"/>
 <x xmlns="vcard-temp:x:update">
 <photo>E10C520E5AE956E659A0DBC5C7F48E12DF9BE6EB</photo>
 </x>
 </presence>
 */
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    
    NSString *presenceType = [presence type]; //取得好友状态
    
    NSLog(@"取得好友状态%@",presenceType);
    
    NSString *userId = [[sender myJID] user];//当前用户
    
    NSString *presenceFromUser = [[presence from] user];//在线用户
    NSLog(@"didReceivePresence---- presenceType:%@,用户:%@",presenceType,presenceFromUser);
    
    if (![presenceFromUser isEqualToString:userId]) {
        //对收到的用户的在线状态的判断在线状态
        
        //在线用户
        if ([presenceType isEqualToString:@"available"]) {
            
            //           NSString *buddy = [[NSString stringWithFormat:@"%@@%@", presenceFromUser, OpenFireHostName] retain];
            //            NSLog(@"获取在线用户%@",buddy);
            //            [chatDelegate newBuddyOnline:buddy];//用户列表委托
        }
        
        //用户下线
        else if ([presenceType isEqualToString:@"unavailable"]) {
            // [chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, OpenFireHostName]];//用户列表委托
            NSString *buddy = [NSString stringWithFormat:@"%@@%@", presenceFromUser, OpenFireHostName];
            NSLog(@"error%@",buddy);
            // [chatDelegate newBuddyOffline:buddy];//用户列表委托
            
        } else if ([presenceType isEqualToString:@"subscribed"]) {
            XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",[presence from]]];
            [[XMPPServer xmppRoster] acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
        }
        
        //用户拒绝添加好友
        else if ([presenceType isEqualToString:@"unsubscribed"]) {
            //TODO
        }else if ([presenceType isEqualToString:@"error"]);{
            NSString *buddy = [NSString stringWithFormat:@"%@@%@", presenceFromUser, OpenFireHostName];
            NSLog(@"error%@",buddy);
            //  [chatDelegate newBuddyOffline:buddy];//用户列表委托
        }
    }
}

#pragma mark - XMPPRoster delegate
/**
 * Sent when a presence subscription request is received.
 * That is, another user has added you to their roster,
 * and is requesting permission to receive presence broadcasts that you send.
 *
 * The entire presence packet is provided for proper extensibility.
 * You can use [presence from] to get the JID of the user who sent the request.
 *
 * The methods acceptPresenceSubscriptionRequestFrom: and rejectPresenceSubscriptionRequestFrom: can
 * be used to respond to the request.
 *
 *  好友添加请求
 */
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    //好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]];
    //请求的用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    
    
    NSLog(@"didReceivePresenceSubscriptionRequest----presenceType:%@,用户：%@,presence:%@",presenceType,presenceFromUser,presence);
    
    
    XMPPJID *jid = [XMPPJID jidWithString:presenceFromUser];
    [[XMPPServer xmppRoster]  acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    
    /*
     user1向登录账号user2请求加为好友：
     
     presenceType:subscribe
     presence2:<presence xmlns="jabber:client" to="user2@chtekimacbook-pro.local" type="subscribe" from="user1@chtekimacbook-pro.local"/>
     sender2:<XMPPRoster: 0x7c41450>
     
     登录账号user2发起user1好友请求，user5
     presenceType:subscribe
     presence2:<presence xmlns="jabber:client" type="subscribe" to="user2@chtekimacbook-pro.local" from="user1@chtekimacbook-pro.local"/>
     sender2:<XMPPRoster: 0x14ad2fb0>
     */
}

/**
 * Sent when a Roster Push is received as specified in Section 2.1.6 of RFC 6121.
 *
 * 添加好友、好友确认、删除好友
 
 //请求添加user6@chtekimacbook-pro.local 为好友
 <iq xmlns="jabber:client" type="set" id="880-334" to="user2@chtekimacbook-pro.local/f3e9c656">
 <query xmlns="jabber:iq:roster">
 <item jid="user6@chtekimacbook-pro.local" ask="subscribe" subscription="none"/>
 </query>
 </iq>
 
 //用户6确认后：
 <iq xmlns="jabber:client" type="set" id="880-334" to="user2@chtekimacbook-pro.local/662d302c"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" ask="subscribe" subscription="none"/></query></iq>
 
 //删除用户6：？？？
 <iq xmlns="jabber:client" type="set" id="592-372" to="user2@chtekimacbook-pro.local/c8f2ab68"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" ask="unsubscribe" subscription="from"/></query></iq>
 
 <iq xmlns="jabber:client" type="set" id="954-374" to="user2@chtekimacbook-pro.local/c8f2ab68"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" ask="unsubscribe" subscription="none"/></query></iq>
 
 <iq xmlns="jabber:client" type="set" id="965-376" to="user2@chtekimacbook-pro.local/e799ef0c"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" subscription="remove"/></query></iq>
 */
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq{
    NSLog(@"didReceiveRosterPush:(XMPPIQ *)iq is :%@",iq.XMLString);
}

/**
 * Sent when the initial roster is received.
 *
 */
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender{
    NSLog(@"xmppRosterDidBeginPopulating");
}

/**
 * Sent when the initial roster has been populated into storage.
 *
 */
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    NSLog(@"xmppRosterDidEndPopulating");
}

/**
 * Sent when the roster recieves a roster item.
 *
 * Example:
 *
 * <item jid='romeo@example.net' name='Romeo' subscription='both'>
 *   <group>Friends</group>
 * </item>
 *
 */
- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(NSXMLElement *)item{
    
    //    NSString *jid = [item attributeStringValueForName:@"jid"];
    //    NSString *name = [item attributeStringValueForName:@"name"];
    //    NSString *subscription = [item attributeStringValueForName:@"subscription"];
    //    DDXMLNode *node = [item childAtIndex:0];
    //    NSXMLElement *groupElement = [item elementForName:@"group"];
    //    NSString *group = [groupElement attributeStringValueForName:@"group"];
    //
    //    NSLog(@"didRecieveRosterItem:  jid=%@,name=%@,subscription=%@",jid,name,subscription);
    //
    ////    NSString*str_character = @"/";
    ////    NSRange senderRange = [jid rangeOfString:str_character];
    ////    NSString * buddyName = [jid substringToIndex:senderRange.location];
    //
    //   // NSString *buddy = [[NSString stringWithFormat:@"%@@%@", buddyName, OpenFireHostName] retain];
    //
    //    if(![name isEqualToString:@""]&&name !=NULL)
    //    [chatDelegate newBuddyOnline:name];//用户列表委托
}

#if !TARGET_IPHONE_SIMULATOR
#pragma mark --VoipDeleate
-(void) voipJson:(NSString *) from json:(NSString*) msg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self)
        {
            @autoreleasepool {
                NSLog(@"fighting:%@",msg);
                NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding ];
                NSError * error = nil;
                NSDictionary * jsonStr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error ];
                if (error ) {
                    return;
                }
                
                if ([[jsonStr objectForKey:@"type"] isEqualToString:@"call"]) {
                    
                    NSString* video = [jsonStr objectForKey:@"video"];
                    NSString* msgID = [jsonStr objectForKey:@"mid"];
                    APPRTCViewController *appView = [[APPRTCViewController alloc]init];
                    appView.from = from;
                    BOOL isvideo = [video boolValue];
                    appView.isVideo = isvideo;
                    appView.msgID = msgID;
                    appView.modalTransitionStyle= UIModalTransitionStyleCrossDissolve;
                    [self.window.rootViewController presentViewController:appView animated:YES completion:^{
                        NSArray *firstSplit = [from componentsSeparatedByString:@"@"];
                        [appView.lbname setText:[firstSplit objectAtIndex:0]];
                        UIImage *image = [UIImage imageNamed:@"Icon"];
                        [appView.ivavatar setImage:image];
                    }];
                    //[appView release];
                    // CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
                    // appDelegate.tabBarBG.hidden=YES;
                }
                else
                {
                    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
                    [notifyCenter postNotificationName:@"voip" object:msg];
                    
                }
            }
        }
    });
}

- (void)sendABContactInfoIQ:(NSString *)userName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *jid = [NSString stringWithFormat:@"%@@%@", userName, OpenFireHostName];
        
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"id" stringValue:@"AI_Contact_Info"];
        [iq addAttributeWithName:@"type" stringValue:@"get"];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:kUserInfoNameSpace];
        NSXMLElement *user = [NSXMLElement elementWithName:@"user"];
        [user addAttributeWithName:@"jid" stringValue:jid];
        
        [query addChild:user];
        [iq addChild:query];
        
        JLLog_I(@"Contact info=%@", iq);
        [[XMPPServer xmppStream] sendElement:iq];
    });
}


-(void) error:(NSString *)from error:(XMPPElement *)ele
{
    
    //NSLog(@"ERROR---------------");
}



//- (void)xmppStream:(XMPPStream *)sender socketWillConnect:(GCDAsyncSocket *)socket
//{
//    // Tell the socket to stay around if the app goes to the background (only works on apps with the VoIP background flag set)
//    [socket performBlock:^{
//        [socket enableBackgroundingOnSocket];
//    }];
//}


#endif

@end
