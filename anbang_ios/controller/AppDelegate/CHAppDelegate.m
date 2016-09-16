#import "CHAppDelegate.h"
#import "CHNewFeatureController.h"
#import "AINavigationController.h"

#import "LoginViewController.h"

#import "MobileAddressBookCRUD.h"
#import "AddressBookCRUD.h"
#import "NewsCRUD.h"
#import "NewsListCRUD.h"
#import "SystemMessageCRUD.h"
#import "UserNameCRUD.h"
#import "GroupCRUD.h"
#import "GroupMembersCRUD.h"
#import "ChatBuddyCRUD.h"
#import "ContactsCRUD.h"
#import "UserInfoCRUD.h"
#import "BlackListCRUD.h"
#import "ChatMessageCRUD.h"
#import "PublicCURD.h"
#import "GroupChatMessageCRUD.h"
#import "MyFMDatabaseQueue.h"

#import "ChatBuddyViewController.h"
#import "MyGroupViewController.h"
#import "ContactsViewController2.h"
#import "UserCenterViewController.h"


#import "DialViewController2.h"
#import "CallViewController.h"

#import "Utility.h"
#import "ChatInit.h"
#import "InviteUtil.h"
#import "AKeyRegisteredTableViewController2.h"
#if !TARGET_IPHONE_SIMULATOR
#import "APPRTCViewController.h"
#endif
#import "JSONKit.h"
#import "ASIHTTPRequest.h"
#import "UIImageView+WebCache.h"
#import "UIColor+CustomColors.h"
#import "MyServices.h"
#import "CallContactsViewController.h"
#import "CommunityViewController.h"
#import "BBCommunityVC.h"

#import "AIAppDeleagteTool.h"
#import "AIOrganizationCRUD.h"
#import "UIImageView+WebCache.h"
#import "AIQLPreviewController.h"
#import "AICurrentContactController.h"
#import "AIDocument.h"
#import "MJExtension.h"
#import "ChatViewController2.h"
#import "GroupChatViewController2.h"
#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import "AIAreaCRUD.h"
#import "AIUIWebViewController.h"

@implementation CHAppDelegate{
    NSString* backgroudDate;
    NSString *trackViewUrl;
    
}

@synthesize xmppServer;
@synthesize tabBarBG=_tabBarBG;
@synthesize selectedBtn=_selectedBtn;
@synthesize viewDelegate = _viewDelegate;

- (id)init
{
    if(self = [super init])
    {
        _viewDelegate = [[AGViewDelegate alloc] init];
    }
    return self;
}

- (void)dealloc
{
    /*
     [_window release];
     [_viewController release];
     [_tabBarController release];
     [_tabBarBG release];
     [_selectedBtn release];
     [xmppServer dealloc];
     [trackViewUrl release];
     [super dealloc];
     */
}

- (void)registerShareSDK
{
    //[ShareSDK registerApp:@"8c96db86be48"];
    [ShareSDK registerApp:ShareSdkAppKey];
    
    
    //添加微信应用  http://open.weixin.qq.com
    
    //生产
    [ShareSDK connectWeChatWithAppId:WeChatAppKey
                           appSecret:WeChatAppSecret
                           wechatCls:[WXApi class]];
    
    
    
//    //当使用新浪微博客户端分享的时候需要按照下面的方法来初始化新浪的平台 （注意：2个方法只用写其中一个就可以）
//    [ShareSDK  connectSinaWeiboWithAppKey:@"1945211127"
//                                appSecret:@"4d8f88ced84146fba133b260eeae4d12"
//                              redirectUri:@"http://www.sharesdk.cn"
//                              weiboSDKCls:[WeiboSDK class]];
    
//    //添加QQ空间应用  注册网址  http://connect.qq.com/intro/login/
//    [ShareSDK connectQZoneWithAppKey:@"1104770810"
//                           appSecret:@"aEPRmvG6ObPP5zSa"
//                   qqApiInterfaceCls:[QQApiInterface class]
//                     tencentOAuthCls:[TencentOAuth class]];
//    
//    //添加QQ应用  注册网址  http://mobile.qq.com/api/
//    [ShareSDK connectQQWithQZoneAppKey:@"1104770810"
//                     qqApiInterfaceCls:[QQApiInterface class]
//                       tencentOAuthCls:[TencentOAuth class]];

}

- (void)registerBaiduMap
{
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    //BOOL ret = [_mapManager start:@"681tszaMQdDn0MUIOozGEPzY"  generalDelegate:nil]; //UAT
    BOOL ret = [_mapManager start:BaiduMapAppKey  generalDelegate:nil]; //SIT
    
    if (!ret) {
        NSLog(@"manager start failed!");
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerBaiduMap];
    [self registerShareSDK];
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    JLLog_I("sand box <path=%@>",NSHomeDirectory());
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    //升级
    
    [PublicCURD updateTable];
    [AIOrganizationCRUD prepareDataToSandBox];
    [AIAreaCRUD prepareDatabaseInSandBox];
    
    //registering for push notifications
    
    JLLog_D("Start register APNs");
    
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
    
    //判断程序是否第一次安装
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everInstall"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everInstall"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstInstall"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstInstall"];
    }
    
    //清除app 从内存中被清除后的第一次登录状态
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NSUD_RemoveApp"];
    
    //程序加载清除网络状态
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Network_Status"];
    
    //后台状态
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NSUD_backgroundTaskStatus"];
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    [[NSUserDefaults standardUserDefaults] setValue:currentLanguage forKey:@"NSUD_language"];

    [ChatInit getServersUrl];
    
    [self.window makeKeyAndVisible];
    
    
    
    /*---第一时间初始化start-------------------------------------------------------------------------------*/
    //注册VOIP初始化通知中心
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(voipInit) name:@"NNC_VOIP_Init" object:nil];
    
    //注册VOIP初始化通知中心
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(voipDeactivate) name:@"NNC_VOIP_Deactivate" object:nil];
    
    //注册消息通知中心
    [ChatInit RegisterMsgNotificationCenter];
    
    //设置通知中心,接收网络电话视频结束信息。
    [ChatInit phoneAndVideoEndNotificationCenter];
    
    //设置通知中心，接收userInfo数据；
    [ChatInit receivedUserInfoNotificationCenter];
    
    //设置通知中心，接收Roster数据；
    [ChatInit receivedContactsNotificationCenter];
    
    //设置通知中心，接收圈子数据；
    [ChatInit receivedGroupNotificationCenter];
    
    //设置通知中心，接收圈子成员数据；
    [ChatInit receivedGroupMembersNotificationCenter];
    
    //设置通知中心，保存userInfo版本号码；
    [ChatInit receivedUserInfoVersion];
    
    //设置通知中心，保存 groupMembers 版本号；
    [ChatInit receivedGroupMembersVersion];
    
    //设置通知中心，切换帐号时，需注销的操作
    [ChatInit receivedLogout];
    
    //设置通知中心，App更新提示
    [ChatInit receivedAppUpdateNotificationCenter];
    
    //设置通知中心，添加好友时刷新；
    [ChatInit receivedAddFriendResult];
    
    //设置通知中心，二维码扫瞄结果
    // [ChatInit receivedScanResult];
    
    //设置通知中心,确定消息已发出；
    [ChatInit receivedMsgReceipt];
    
    //清除voip忙线状态
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"NSUD_Voip_status"];
    
    //取消屏幕保持唤醒
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    //ip地址
    //[Utility getCurrentIP];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        /**
         *  Custom color for bar backgroud.
         */
        //[[UINavigationBar appearance] setBarTintColor:kAppStyleColor];
        [[UINavigationBar appearance]  setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               [UIColor whiteColor],
                                                               UITextAttributeTextColor,
                                                               [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
                                                               UITextAttributeTextShadowColor,
                                                               [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                               UITextAttributeTextShadowOffset,
                                                               [UIFont fontWithName:@"Arial-Bold" size:1.0],
                                                               UITextAttributeFont,nil]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        
    }else{
        
    }
    
    
    //读取配置信息
    //[self loadAppConfiguration];
    
    [AIAppDeleagteTool chooseRootViewController];
    
    //[XMPPStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
    
    return YES;
}

-(void)moveAllVoiceFiles
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(MY_USER_NAME){
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error = nil;
            NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *sourceDirectory = docPath;
            NSString *destinationDirectory = [NSString stringWithFormat:@"%@/%@/", docPath, MY_USER_NAME];
            NSArray *contents = [fileManager contentsOfDirectoryAtPath:sourceDirectory error:&error];
            for(NSString *sourceFileName in contents) {
                if([sourceFileName hasSuffix:@".wav"] || [sourceFileName hasSuffix:@".amr"]){
                    NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:sourceFileName];
                    NSString *destFile = [destinationDirectory stringByAppendingPathComponent:sourceFileName];
                    if(![fileManager moveItemAtPath:sourceFile toPath:destFile error:&error]) {
                        JLLog_I(@"转移旧语音文件失败！Error: %@", error);
                    } else {
                        JLLog_I(@"转移旧语音文件[%@]至[%@]成功！",sourceFile, destFile);
                    }
                }
            }
            
            JLLog_I(@"转移所有语音文件成功");
        }
    });
}


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    JLLog_D("Application open URL <url=%@>",url);
    
    NSString*str_character = @"task=";
    if ([[url query] rangeOfString:str_character].location != NSNotFound) {
        NSString *taskID = [[url query] substringFromIndex:[[url query] rangeOfString:@"task="].location+5];
        if (taskID != nil && [taskID length]>0) {
            
            [[NSUserDefaults standardUserDefaults] setObject:taskID forKey:@"task"];
            // [self showAlert:[[NSUserDefaults standardUserDefaults] stringForKey:@"task"]];
        }
    }
    
    if (url && [url isFileURL]) {
        NSString *filePath = url.path;
        AIDocument *documentFile = [AIDocument documentWithFilePath:filePath];
        if (documentFile) {
            JLLog_I(@"document=%@", documentFile);
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:documentFile.keyValues
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:nil];
            NSString *text = [[NSString alloc] initWithData:jsonData
                                                   encoding:NSUTF8StringEncoding];
            
            NSArray *messages = @[@{@"text" : text, @"subject" : @"document"}];
            
            // find out current chat view controller if exist
            // then set delegate for reloading tableView when finish sending
            NSString *to = nil;
            UIViewController *delegateController = nil;
            NSArray *viewControllers = [self.tabBarController.viewControllers[0] viewControllers];
            if (viewControllers.count == 2) {
                UIViewController *viewController = viewControllers[1];
                if ([viewController isKindOfClass:[ChatViewController2 class]]) {
                    ChatViewController2 *controller = (ChatViewController2 *)viewController;
                    to = controller.chatWithUser;
                }else if ([viewController isKindOfClass:[GroupChatViewController2 class]]) {
                    GroupChatViewController2 *controller = (GroupChatViewController2 *)viewController;
                    to = controller.roomName;
                }
                delegateController = viewController;
            }
            
            AICurrentContactController *controller = [[AICurrentContactController alloc] init];
            // message must behind fromUserName and delegate
            controller.fromUserName = to;
            controller.delegate = (id<AIMessageSendAssisstantDelegate>)delegateController;
            controller.messages = messages;
            // Cause ChatViewController2 and GroupChatViewController2
            // both response to protocol 'AIMessageSendAssisstantDelegate'
            AINavigationController *navigation = [[AINavigationController alloc] initWithRootViewController:controller];
            [self.tabBarController presentViewController:navigation
                                                animated:YES
                                              completion:nil];
        }else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"对不起，文件复制错误。"
                                                               delegate:nil
                                                      cancelButtonTitle:@"知道了"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }

    return [ShareSDK handleOpenURL:url sourceApplication:sourceApplication annotation:annotation wxDelegate:self];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    
    //  application.applicationIconBadgeNumber = 0;
    //    // [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    JLLog_D("Application did enter background");
    
    int unreadTotal = [ChatBuddyCRUD queryAllMsgTotal];
    application.applicationIconBadgeNumber = unreadTotal;
    
    [self sendBadge:[NSString stringWithFormat:@"%d", unreadTotal]];
    
    //后台状态(后台任务开始)
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NSUD_backgroundTaskStatus"];
    
    
    [self startBackgroundTask];
    
    //[NSTimer scheduledTimerWithTimeInterval:60.0f*6 target:self selector:@selector(killTask) userInfo:nil repeats:NO];
    
    //    [xmppServer disconnect];
    //#if !TARGET_IPHONE_SIMULATOR
    //    [_voipModule deactivate];
    //#endif
    
    //   application.applicationIconBadgeNumber = 0;
    //    // [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //
    //    backgroudDate = [Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    //
    //    NSLog(@"%@",backgroudDate);
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults setObject:backgroudDate forKey:@"backgroundDate"];
}

- (void)updateBadgeValueIQ
{
//    <iq id="hN4p9-6" type="set">
//    <query xmlns="http://www.nihualao.com/xmpp/badge">
//    <badge>12<ge>
//    </query>
//    </iq>
    
    UITabBarItem *item = (UITabBarItem *)self.tabBarController.tabBar.items[0];
    NSString *badgeValue = item.badgeValue;
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:kBadgeValueNamepace];
    NSXMLElement *badge = [NSXMLElement elementWithName:@"badge" stringValue:badgeValue ? badgeValue : @"0"];
    [query addChild:badge];
    [iq addChild:query];
    
    [[xmppServer xmppStream] sendElement:iq];
}

-(void)sendBadge:(NSString*)badgeNum{
    /*
     <iq type=”set”>
     <query xmlns=”http://www.nihualao.com/xmpp/badge”>
     <badge>5</badge>
     </query>
     </iq>
     */
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/badge"];
    
    NSXMLElement *badge = [NSXMLElement elementWithName:@"badge" stringValue:badgeNum];
    
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addChild:queryElement];
    [queryElement addChild:badge];
    //发送badge
    [[XMPPServer xmppStream] sendElement:iq];
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    JLLog_D("Application did enter foreground");
    
    //清除后台任务
    if (backgroundTask != UIBackgroundTaskInvalid){
        NSLog(@"********%@",@"清除后台任务");
        [application endBackgroundTask:backgroundTask];
    }
    
    /*
     NSLog(@"%@",  [[NSUserDefaults standardUserDefaults]objectForKey:@"backgroundDate"]);
     
     NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
     NSDate *date1=[formatter dateFromString:[[NSUserDefaults standardUserDefaults]objectForKey:@"backgroundDate"]];
     NSDate *date2=[NSDate date];
     NSTimeInterval aTimer=[date2 timeIntervalSinceDate:date1];
     int hour=(int)(aTimer/3600);
     int minute=(int)(aTimer-hour*3600)/60;
     int second=aTimer-hour*3600-minute*60;
     NSLog(@"%d,%d,%d",hour,minute,second);
     
     
     if (hour>=1 || minute>=6) {
     NSLog(@"重新初始化应用");
     //        self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
     //        // Override point for customization after application launch.
     //        self.window.backgroundColor = [UIColor whiteColor];
     //        [self.window makeKeyAndVisible];
     
     xmppServer = [XMPPServer sharedServer];
     [xmppServer connect];
     
     //        NSTimer *timer;
     //        timer=[NSTimer scheduledTimerWithTimeInterval:1
     //                                               target:self
     //                                             selector:@selector(setTimer)
     //                                             userInfo:nil
     //                                              repeats:NO];
     
     }
     
     NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
     
     NSString *appVersion = [infoDic objectForKey:@"CFBundleVersion"];
     
     NSLog(@"******%@",appVersion);
     */
    
    
    //后台状态
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NSUD_backgroundTaskStatus"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults stringForKey:@"userName"];
    NSString *pass = [defaults stringForKey:@"password"];

    //进入应用重新连接
    xmppServer = [XMPPServer sharedServer];
    
    if (xmppServer.loginFlag != 2) {
        
        [xmppServer disconnect];
        
        if (userId&&pass) {
            if ([xmppServer connect]) {
            }
        }
    }
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    JLLog_D(@"Application Will Terminate");
    [self updateBadgeValueIQ];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenStr = [NSString
                                stringWithFormat:@"%@",deviceToken];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:deviceTokenStr forKey:@"deviceToken"];
    [defaults synchronize];//保存
    
    JLLog_I("Did register APNs <token=%@>", deviceTokenStr);
    
}


- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    JLLog_E("APNs failed <err=%@>",err);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    JLLog_D("APNs push <info=%@>",userInfo);
    
}

-(void)ui{
    
    self.tabBarController = [[UITabBarController alloc] init];
    
    UIViewController *viewController1 = [[ChatBuddyViewController alloc] init];
    UIViewController *viewController2 = [[ContactsViewController2 alloc] init];
    

    AIUIWebViewController *viewController4 = [[AIUIWebViewController alloc] init];
    viewController4.url = [[NSUserDefaults standardUserDefaults]stringForKey:@"NSUD_COMMUNITY_ADDRESS"];
    viewController4.usingToken = YES;
    viewController4.mode = AIUIWebViewModeRoot;
    viewController4.hidesBottomBarWhenPushed = YES;
  
    UIViewController *viewController5 = [[UserCenterViewController alloc] init];
    
    AINavigationController *firstNavigation = [[AINavigationController alloc] initWithRootViewController:viewController1];
    // firstNavigation.navigationBar.tintColor =[UIColor underPageBackgroundColor];
    firstNavigation.navigationBar.barStyle = UIBarStyleBlack;
    firstNavigation.navigationController.title =NSLocalizedString(@"chat.chat",@"title");
    
    AINavigationController *secondNavigation = [[AINavigationController alloc] initWithRootViewController:viewController2];
    secondNavigation.navigationBar.barStyle = UIBarStyleBlack;
    secondNavigation.navigationController.title =NSLocalizedString(@"contacts.contacts",@"title");
    
    AINavigationController *fourthNavigation = [[AINavigationController alloc] initWithRootViewController:viewController4];
    //fourthNavigation.navigationBar.tintColor = [UIColor underPageBackgroundColor];
    fourthNavigation.navigationBar.barStyle = UIBarStyleBlack;
    fourthNavigation.navigationController.title = NSLocalizedString(@"circle.myCircle",@"title");
    
    AINavigationController *fifthNavigation = [[AINavigationController alloc] initWithRootViewController:viewController5];
    //fourthNavigation.navigationBar.tintColor = [UIColor underPageBackgroundColor];
    fifthNavigation.navigationBar.barStyle = UIBarStyleBlack;
    fifthNavigation.navigationController.title = NSLocalizedString(@"settings.settings",@"title");
    
    NSArray *viewControllers = @[firstNavigation,secondNavigation,fourthNavigation,fifthNavigation];
    
    [self.tabBarController setViewControllers:viewControllers];
    [[UITabBar appearance] setBarTintColor:Label_Back_Color];
    
    self.window.rootViewController = self.tabBarController;
    self.tabBarController.view.hidden = YES;
    self.tabBarController.view.backgroundColor = AB_Color_f6f2ed;
    
    //tabBarController 代理
//    self.tabBarController.delegate=self;
    
    [self loadCustomTabBarView];
    
    startView = self.window.rootViewController.view;//初始化startView(loginView)
    
    rView=[[UIView alloc]initWithFrame:self.window.frame];//初始化rView
    
    [rView addSubview:startView];//add 到rView
    [rView addSubview:self.window.rootViewController.view];//add 到rView
    
    [self.window addSubview:rView];//add 到window
    
    [self performSelector:@selector(loginFinish) withObject:nil afterDelay:0];//5秒后执行TheAnimation
    
}



- (void)loadCustomTabBarView{
    
    //    //记录主界面是否加载完成
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults setBool:YES forKey:@"NSUD_Tabbar_Loaded"];
    //    [defaults synchronize];
    //self.tabBarController.tabBar.hidden =NO;
    
    _selectView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 49)];
    
    _selectView.image = [UIImage imageNamed:@"tabbar_slider2.png"];
    // [self.tabBarController.tabBar addSubview:_selectView];
    
    [self.tabBarController.tabBar setBackgroundColor:[UIColor whiteColor]];
    
    //[[UITabBarItem appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:kMainColor8,NSForegroundColorAttributeName,nil] forState:UIControlStateSelected];
    
    // Creat items on tab bar
    UIImage *image1_0 = [UIImage imageNamed:@"tab_button_chat_selected"];//transformtosize的功能是将图片大小转化
    UIImage *image1_1 = [UIImage imageNamed:@"tab_button_chat_unselected"];
    [(UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:0] setFinishedSelectedImage:image1_0 withFinishedUnselectedImage:image1_1];
    [(UITabBarItem *)[self.tabBarController.tabBar .items objectAtIndex:0] setTitle: NSLocalizedString(@"tabbar.chat",@"tabbar")];
    
    
    // Creat items on tab bar
    UIImage *image2_0 = [UIImage imageNamed:@"tab_button_adbo_selected"];
    UIImage *image2_1 = [UIImage imageNamed:@"tab_button_adbo_unselected"];
    [(UITabBarItem *)[self.tabBarController.tabBar .items objectAtIndex:1] setFinishedSelectedImage:image2_0 withFinishedUnselectedImage:image2_1];
    [(UITabBarItem *)[self.tabBarController.tabBar .items objectAtIndex:1] setTitle:NSLocalizedString(@"tabbar.contacts",@"tabbar")];
    
    // Creat items on tab bar
    //    UIImage *image3_0 = [UIImage imageNamed:@"dial_on"];
    //    UIImage *image3_1 = [UIImage imageNamed:@"dial_off"];
    //    [(UITabBarItem *)[self.tabBarController.tabBar .items objectAtIndex:2] setFinishedSelectedImage:image3_0 withFinishedUnselectedImage:image3_1];
    
    //    [(UITabBarItem *)[self.tabBarController.tabBar .items objectAtIndex:2] setTitle:NSLocalizedString(@"tabbar.call",@"")];
    
    
    // Creat items on tab bar
    UIImage *image4_0 = [UIImage imageNamed:@"tab_button_commu_selected"];
    UIImage *image4_1 = [UIImage imageNamed:@"tab_button_commu_unselected"];
    [(UITabBarItem *)[self.tabBarController.tabBar .items objectAtIndex:2] setFinishedSelectedImage:image4_0 withFinishedUnselectedImage:image4_1];
    [(UITabBarItem *)[self.tabBarController.tabBar .items objectAtIndex:2] setTitle:NSLocalizedString(@"tabbar.circle",@"")];
    
    // Creat items on tab bar
    UIImage *image5_0 = [UIImage imageNamed:@"tab_button_me_selected"];
    UIImage *image5_1 = [UIImage imageNamed:@"tab_button_me_unselected"];
    [(UITabBarItem *)[self.tabBarController.tabBar .items objectAtIndex:3] setFinishedSelectedImage:image5_0 withFinishedUnselectedImage:image5_1];
    [(UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:3] setTitle:NSLocalizedString(@"tabbar.setting",@"")];
    //self.tabBarController.tabBar.backgroundColor = kMainColor5;
    
    //[self.tabBarController.tabBar setSelectedImageTintColor:[UIColor colorFromHexString:@"#2196f3"]];
    [self.tabBarController.tabBar setSelectedImageTintColor:AB_Red_Color];
    
    //[self.tabBarController.tabBar setBarStyle:UIBarStyleBlackOpaque];
}



//- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
//    // NSLog(@"********%d",tabBarController.selectedIndex);
//    //前一个按钮设置
//    //self.selectedBtn.userInteractionEnabled = YES;
//    //self.selectedBtn.selected = NO;
//    //[self.selectedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    //当前点击的按钮设置
//    //[self.selectedBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    
//    //_selectView.frame = CGRectMake(button.tag*64,0, 64, 49);
//    //_selectView.frame = CGRectMake(tabBarController.selectedIndex*64,0, 64, 49);
//    return YES;
//}


//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
//{
//    // _selectView.frame = CGRectMake(tabBarController.selectedIndex*64,0, 64, 49);
//    
//}


-(void)changeViewController:(UIButton *)button{
    if (self.selectedBtn == button) {
        return;
    }
    //前一个按钮设置
    self.selectedBtn.userInteractionEnabled = YES;
    self.selectedBtn.selected = NO;
    //[self.selectedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //当前点击的按钮设置
    self.selectedBtn = button;
    self.selectedBtn.userInteractionEnabled = NO;
    self.selectedBtn.selected = YES;
    //[self.selectedBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    // NSLog(@"*******@%d",button.tag);
    self.tabBarController.selectedIndex =button.tag;
    
    
    //_selectView.frame = CGRectMake(button.tag*64,0, 64, 49);
    _selectView.frame = CGRectMake(button.tag*64,0, 64, 49);
    [button.imageView setContentMode:UIViewContentModeCenter];
    
    //[UIView beginAnimations:@"View Flip"  context:NULL];
    // _selectView.frame = CGRectMake(14 + button.tag*64,49.0/2-20, 42, 40);
}


-(void) showAlert:(NSString*)msg
{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"调试" message:msg delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alertView show];
}

/*---程序加载读取配置信----------------------------------------------------------------------------------*/
-(void)loadAppConfiguration{
    
    
    JLLog_D("Loading app configure");
    
    //    //电话界面控制变量
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults setBool:NO forKey:@"NSUD_VOIP_IsCall"];
    //    [defaults synchronize];
    
    self.tabBarBG.hidden = YES;
    //各种流程选择
    InviteUtil * util = [InviteUtil instance];
    [util checkTask];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDefault valueForKey:@"userName"];
    NSString* password = [userDefault valueForKey:@"confirmPassword"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (username) {
            //正常流程
            //有用户名和密码
            //[self showAlert:@"正常流程1"];
            if (username&&password) {
                
                JLLog_D("Immediately Login");
                
                [PublicCURD createDataBase];
                [PublicCURD createAllTable];
                //升级
                [PublicCURD updateTable];
                
                [self moveAllVoiceFiles];
                
                [self immediatelyLogin];
                
            }else{
                
                JLLog_D("Login view controller : needed password");
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"NSUD_LoginStatus"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                LoginViewController *loginCtl = [[LoginViewController alloc] init];
                AINavigationController *nav=[[AINavigationController alloc]initWithRootViewController:loginCtl];
                //        nav.navigationBar.barStyle = UIBarStyleBlack;
                //nav.tabBarController.view.hidden = true;
                //self.viewController = nav;
                nav.delegate = self;
                self.window.rootViewController = nav;
                
            }
            
        }else{
            if ([util checkApkidIsvalid]) {
                if ([util isAutoRegister]) {
                    
                    JLLog_D("Auto register");
                    
                    //注册提示
                    NSString *promptStr = [util objectForkey:@"prompt"];
                    //用户来源
                    NSString *userSource = [util objectForkey:@"source"];
                    //自动注册流程
                    //[self showAlert:@"自动注册流程"];
                    AKeyRegisteredTableViewController2 *akeyRegVC = [[AKeyRegisteredTableViewController2 alloc]init];
                    akeyRegVC.prompt = promptStr;
                    akeyRegVC.userSource = userSource;
                    
                    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:akeyRegVC];
                    nav.delegate = self;

                    nav.navigationBar.barStyle=UIBarStyleBlack;
                    
                    self.viewController = nav;
                    self.window.rootViewController = self.viewController;
                    
                    //标记用户为新用户
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:@"newUser" forKey:@"NSUD_NewUser"];
                    
                    
                }else if([util isAutoLogin]){
                    
                    JLLog_D("Auto login : Imediately Login");
                    //自动登录流程 userdefault的username,password 值已填充
                    //[self showAlert:@"自动登录流程"];
                    //有用户名和密码
                    //数据库初始化
                    [PublicCURD createDataBase];
                    [PublicCURD createAllTable];
                    [PublicCURD updateTable];
                    [self immediatelyLogin];
                    
                }
            }else {
                //正常流程
                //[self showAlert:@"正常流程2"];
                
                JLLog_D("Normal Login");
                
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"NSUD_LoginStatus"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                LoginViewController *loginCtl = [[LoginViewController alloc] init];
                AINavigationController *nav=[[AINavigationController alloc]initWithRootViewController:loginCtl];
                //        nav.navigationBar.barStyle = UIBarStyleBlack;
                nav.delegate = self;
                self.viewController = nav;
                self.window.rootViewController = nav;
            }
        }
    });
    
}

//有用户名和密码，立即登录
-(void)immediatelyLogin{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults stringForKey:@"userName"];
    NSString *pass = [defaults stringForKey:@"password"];
    
    //如果已经登录过
    if (userId && pass) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //记录主界面是否加载完成
        [defaults setBool:NO forKey:@"NSUD_Tabbar_Loaded"];
        
        xmppServer = [XMPPServer sharedServer];
        
        [xmppServer disconnect];
        //登录前先销毁voip
#if !TARGET_IPHONE_SIMULATOR
        [_voipModule deactivate];
#endif
        
        if ([xmppServer connect]) {
            
        }

        self.window.rootViewController = self.tabBarController;
        
        rView=[[UIView alloc]initWithFrame:self.window.frame];//初始化rView
        
        [rView addSubview:startView];//add 到rView
        [rView addSubview:self.window.rootViewController.view];//add 到rView
        
        [self.window addSubview:rView];//add 到window
        
        [self performSelector:@selector(loadFinish) withObject:nil afterDelay:20];
    }
    
}

-(void)loadFinish{
    
    self.tabBarController.view.hidden = NO;
    
    [self loadCustomTabBarView];
    
    //[self TheAnimation];
    
    
    //检测版本
    NSDate *nowDate = [NSDate date];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *promptTime = [defaults objectForKey:@"NSUD_AppUpdatePromptTime"];
    if(promptTime == nil){
        [defaults setObject:@"automatic_check_update" forKey:@"NSUD_CheckUpdate_Method"];
        [MyServices onCheckVersion];
        return;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlags = NSHourCalendarUnit;
    
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:[defaults objectForKey:@"NSUD_AppUpdatePromptTime"]  toDate:nowDate  options:0];
    int hours = [comps hour];
    JLLog_D(@"小时数===%d",hours);
    if (hours > 3) {
        [defaults setObject:@"automatic_check_update" forKey:@"NSUD_CheckUpdate_Method"];
        [MyServices onCheckVersion];
        
    }
}


//切换帐号
-(void)loginFinish{
    self.tabBarController.view.hidden=NO;
    //[self TheAnimation];
}


//voip ui deal 通话结束
//-(void)voipFinish:(NSNotification*)notify
//{
//
//
//#if !TARGET_IPHONE_SIMULATOR
//    APPRTCViewController *appRTCVC = notify.object;
//    NSLog(@"****%d",appRTCVC.talkTime);
//    NSLog(@"*****%i",appRTCVC.isVideo);
//    NSLog(@"*****%i",appRTCVC.voip_staus);
//    self.tabBarBG.hidden = NO;
//#endif
//}



//初始化voip
-(void)voipInit{
    xmppServer = [XMPPServer sharedServer];
    //  XMPPServer* server = [XMPPServer sharedServer];
    
#if !TARGET_IPHONE_SIMULATOR
    _voipModule = [VoipModule shareVoipModule];
    [_voipModule deactivate];
    _voipModule.voipDelegate = self;
    
    [_voipModule activate:xmppServer.xmppStream];
    
#endif
    
}

//注销voip
-(void)voipDeactivate{
#if !TARGET_IPHONE_SIMULATOR
    [_voipModule deactivate];
#endif
    
}


#if !TARGET_IPHONE_SIMULATOR
#pragma mark --VoipDeleate
-(void) voipJson:(NSString *) from json:(NSString*) msg sessionID:(NSString *)sessionID
{
    
    // [self showAlert:@"来电"];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding ];
        NSError * error = nil;
        NSDictionary * jsonStr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error ];
        if (error ) {
            return;
        }
        
        if ([[jsonStr objectForKey:@"type"] isEqualToString:@"call"]) {
            
            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rtcNotifyAction:) name:@"voip" object:nil];
            NSLog(@"******%@",jsonStr);
            NSString* video = [jsonStr objectForKey:@"video"];
            NSString* msgID = [jsonStr objectForKey:@"mid"];
            APPRTCViewController *appView = [[APPRTCViewController alloc]init];
            
            appView.from = from;
            BOOL isvideo = [video boolValue];
            if (isvideo) {
                //声音初始化
                //声音初始化
                NSError *setCategoryError = nil;
                AVAudioSession* avsession = [AVAudioSession sharedInstance];
                [avsession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&setCategoryError];
                //  [avsession setDelegate:self];
                [avsession setActive:YES error: &setCategoryError];
                
            }else{
                
            }
            
            appView.isVideo = isvideo;
            appView.msgID = msgID;
            appView.msessionID = sessionID;
            NSString *fromJID = [from componentsSeparatedByString:@"/"][0];
            UserInfo *userInfo = [UserInfoCRUD queryUserInfo:fromJID myJID:MY_JID];
            NSString *remarkName = [ContactsCRUD queryContactsRemarkName:fromJID];
            [self.window.rootViewController presentViewController:appView animated:YES completion:^{
                
                [appView.lbname setText:[StrUtility string:remarkName defaultValue:userInfo.nickName]];
                NSString *headImageAvatar= userInfo.avatar;
                UIImage *image = [UIImage imageNamed:@"defaultUser.png"];
  
                if (headImageAvatar!=nil) {
                    NSString *photoImageUrl=[NSString stringWithFormat:@"%@/%@",ResourcesURL,headImageAvatar];
                    UIImageView *avatarImage = [[UIImageView alloc]init];
                    [avatarImage setImageWithURL:[NSURL URLWithString:photoImageUrl] placeholderImage:image];
                    [appView.ivavatar setImage:avatarImage.image];
                }else{
                    [appView.ivavatar setImage:image];
                    
                }
                
                appView.ivavatar.layer.masksToBounds = YES;
                appView.ivavatar.layer.cornerRadius = 3.0;
                appView.ivavatar.layer.borderWidth = 3.0;
                appView.ivavatar.backgroundColor = kMainColor4;
                appView.ivavatar.layer.borderColor = [[UIColor whiteColor]CGColor];
                
            }];
            
        }
        else
        {
            
            NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
            [notifyCenter postNotificationName:@"voip" object:msg];
            
        }
    });
    
}


-(void) error:(NSString *)from error:(XMPPElement *)ele
{
    
}
#endif



- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}




//渐变 和 移动
- (UIGestureRecognizer *)createTapRecognizerWithSelector:(SEL)selector {
    return [[UITapGestureRecognizer alloc]initWithTarget:self action:selector];
}


//淡入淡出

- (void)TheAnimation{
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_LoginStatus"] isEqualToString:@"login_out"]) {
        animation.duration = 2.0 ;  // 动画持续时间(秒)
    }else{
        animation.duration = 2.0 ;  // 动画持续时间(秒)
    }
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionFade;//淡入淡出效果
    
    NSUInteger f = [[rView subviews] indexOfObject:startView];
    NSUInteger z = [[rView subviews] indexOfObject:self.window.rootViewController.view];
    [rView exchangeSubviewAtIndex:z withSubviewAtIndex:f];
    
    [[rView layer] addAnimation:animation forKey:@"animation"];
}


- (void)startBackgroundTask
{
    UIApplication *application = [UIApplication sharedApplication];
    application.delegate = self;
    //通知系统, 我们需要后台继续执行一些逻辑
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        //超过系统规定的后台运行时间, 则暂停后台逻辑
        NSLog(@"超过系统规定的后台运行时间, 则暂停后台逻辑");
        
        //后台状态（后台任务暂停时不再重连）
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSUD_backgroundTaskStatus"];
        
        //停止任务前发送badge
        int unreadTotal = [ChatBuddyCRUD queryAllMsgTotal];
        application.applicationIconBadgeNumber = unreadTotal;
        [self sendBadge:[NSString stringWithFormat:@"%d",unreadTotal]];
        
        [xmppServer.reLoginTimer invalidate];
        xmppServer.reLoginTimer = nil;
        
        //登录状态为4时 不再重连；
        xmppServer.loginFlag =4;
        
        [xmppServer disconnect];
        
        [application endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }];
    
    NSLog(@"进入后台");
    
    //判断如果申请失败了, 返回
    if (backgroundTask == UIBackgroundTaskInvalid) {
        NSLog(@"后台时间申请失败");
        xmppServer.loginFlag =4;
        [xmppServer disconnect];
        
        //后台状态（后台任务暂停时不再重连）
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSUD_backgroundTaskStatus"];
        
        return;
    }
}

-(void)killTask{
    //  UIApplication *application = [UIApplication sharedApplication];
    //超过系统规定的后台运行时间, 则暂停后台逻辑
    //        [application endBackgroundTask:backgroundTask];
    //        backgroundTask = UIBackgroundTaskInvalid;
    [xmppServer disconnect];
#if !TARGET_IPHONE_SIMULATOR
    [_voipModule deactivate];
#endif
}

#pragma UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewDidLoad];
}

#pragma mark - WXApiDelegate

/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
-(void) onReq:(BaseReq*)req{
    
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
-(void) onResp:(BaseResp*)resp{
    
}

@end
