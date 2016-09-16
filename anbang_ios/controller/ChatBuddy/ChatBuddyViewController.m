//
//  ChatBuddyViewController.m
//  anbang_ios
//
//  Created by rooter on 15-7-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "ChatBuddyViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "GBPathImageView.h"
#import "UserCenterViewController.h"
#import "Utility.h"
#import "ChatBuddyCRUD.h"
#import "ChatViewController2.h"
#import "ChatMessageCRUD.h"
#import "GroupChatMessageCRUD.h"
#import "ContactsCRUD.h"
#import "GroupChatMessageCRUD.h"
#import "GroupMembersCRUD.h"
#import "MobileAddressBookCRUD.h"
#import "GroupCRUD.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "Reachability.h"
#import "NewsListCRUD.h"
#import "NewsCRUD.h"
#import "SystemMessageViewController.h"
#import "SystemMessageCRUD.h"
#import "GroupChatViewController2.h"
#import "IdGenerator.h"
#import "UserInfoCRUD.h"
#import "TKAddressBook.h"
#import "JSMessageSoundEffect.h"
#import "AddressBookCRUD.h"
#import "CHAppDelegate.h"
#import "DejalActivityView.h"
#import "ChatInit.h"
#import "ImageUtility.h"
#import "MultiplayerTalkCRUD.h"
#import "UIImageView+WebCache.h"
#import "UIColor+CustomColors.h"
#import "CustonTextField.h"
#import "QRCodeGenerator.h"
#import "AddressBookViewController3.h"
#import "QrCodeViewController.h"
#import "KxMenu.h"
#import "ScanViewController.h"
#import "InvitationURLViewControllerNew.h"
#import "GroupCreateViewController.h"
#import "AddFriendVCTableViewController.h"
#import "DndInfoCRUD.h"
#import "BBCommunityVC.h"
#import "AIQLPreviewController.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.H"
#import "KxMenu.h"
#import "AIChatBuddyCell.h"
#import "UIImageView+WebCache.h"
#import "NSString+Chinese.h"
//#import "AIBuddySearchCell.h"
#import "UIImageView+WebCache.h"
#import "ContactsCRUD.h"
#import "AISearchContactViewController.h"

#define Cell_Badge_View_Tag  1234

#define WiressSDKDemoAppKey     @"801500977"
#define WiressSDKDemoAppSecret  @"17451664cf27b9dfe5726de3da894978"
#define REDIRECTURI             @"http://user.qzone.qq.com/348931837/myhome"

@interface ChatBuddyViewController () <UISearchDisplayDelegate>
{
    Reachability *reachability;
    CGRect lastMsgTimeLabelFrame;
    UIFont *lastMsgTimeLabelFont;
    NSMutableArray *groupNameTempArray;//记录未命名的群，用于搜索；
    BOOL mRightBarButtonSelected;
    
    long lastSoundPlayTime;
    long lastVibratePlayTime;
    BOOL mFirstSound;
    BOOL mFirstVibrate;
    NSMutableArray *remindJIDList;
    NSArray *mSearchFormats;
    
    NSInteger _incorrectContactCount;
}

@property(nonatomic,retain) NSMutableArray *chatContactsArray;
@property(nonatomic,retain) NSMutableArray *subscriptionUserInfo;
@property(nonatomic,retain) NSMutableArray *buddyNickNameArray;
@property(nonatomic,retain) NSMutableArray *buddyNumberArray;
@property(nonatomic,retain) NSMutableArray *userInfoNickNameArray;
@property(nonatomic,retain) NSMutableArray *userInfoAvtarArray;
@property(nonatomic,retain) UIView *customView;

@property (nonatomic, strong) UIButton *easyToAddFriends;

@end

@implementation ChatBuddyViewController
@synthesize myUserName=_myUserName;
@synthesize chatContactsArray;
@synthesize subscriptionUserInfo;
@synthesize buddyNickNameArray;
@synthesize messages = _messages;
@synthesize chatDic = _chatDic;
@synthesize badgeView = _badgeView;
@synthesize badgeViewArray = _badgeViewArray;
@synthesize chatBuddyMessageFlag = _chatBuddyMessageFlag;
@synthesize avtarURL = _avtarURL;
@synthesize options = _options;

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Chat_Buddy_View_Refresh" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Chat_Buddy_View_Refresh2" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Chat_Buddy_View_Refresh3" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_PersonalInfomation_Loaded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Chat_Buddy_View_Msg_Refresh" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CNN_Group_Load_OK" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Network_Status_Disconnect" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Network_Status_Connection" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Server_Disconnect" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Server_Connect" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Server_Timeout" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Relogin" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_KxMenu_Dismiss" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XMPPServerDidDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

- (id) init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshInterface)
                                                     name:@"CNN_Contacts_LoadFinish"
                                                   object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    
    NSLog(@"内存警告－聊天");
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];//即使没有显示在window上，也不会自动的将self.view释放。
    // Add code to clean up any of your own resources that are no longer necessary.
    
    // 此处做兼容处理需要加上ios6.0的宏开关，保证是在6.0下使用的,6.0以前屏蔽以下代码，否则会在下面使用self.view时自动加载viewDidUnLoad
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        
        //需要注意的是self.isViewLoaded是必不可少的，其他方式访问视图会导致它加载 ，在WWDC视频也忽视这一点。
        
        if (self.isViewLoaded && !self.view.window)// 是否是正在使用的视图
        {
            // Add code to preserve data stored in the views that might be
            // needed later.
            
            // Add code to clean up other strong references to the view in
            // the view hierarchy.
            //self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
            
        }
        
    }
    
}


//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookVer) name:@"NNC_Upload_AddressBook" object:nil];
//        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onecObtainAddressBook) name:@"NCC_AddressBooK_Success" object:nil];
//    }
//    return self;
//}


-(void)laodTabelView{
    //重新加载tableView
    // NSLog(@"图片：%@",[[NSUserDefaults standardUserDefaults]stringForKey:@"headImage"]);
}

#pragma mark - life circle
-(void)loadView{
    [super loadView];
    
    lastSoundPlayTime = (long)[[NSDate date] timeIntervalSince1970];
    lastVibratePlayTime = (long)[[NSDate date] timeIntervalSince1970];
    
    mFirstSound = YES;
    mFirstVibrate= YES;
    
    remindJIDList = [NSMutableArray array];
    
    [DejalBezelActivityView removeViewAnimated:YES];
    
    JLLog_D("Loading ChatBubby ViewController");
    
    //navigationItemTitle 初始化
    if ([XMPPServer  sharedServer].loginFlag == 1) {
        [self.navigationItem setTitle:NSLocalizedString(@"chat.connection",@"title")];
        
    }else{
        [self.navigationItem setTitle:NSLocalizedString(@"chat.chat",@"title")];
        
    }
    
    //    CGRect rect = CGRectMake(0, 0, 200, 44);
    //    UILabel *aa = [[UILabel alloc] initWithFrame:rect];
    //    aa.backgroundColor = [UIColor clearColor];
    //    aa.text = NSLocalizedString(@"chat.chat",@"title");
    //    aa.textColor = [UIColor blackColor];
    //    aa.font = [UIFont boldSystemFontOfSize:22];
    //    aa.textAlignment = NSTextAlignmentCenter;
    
    
    // self.navigationItem.titleView = aa;
    
    //[self sendIQInformationList];
    _myUserName =[[NSString alloc]initWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"userName"]];
    
    
    // _tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-cutHeight) style:UITableViewStylePlain];
    // _tableView.dataSource = self;
    // _tableView.delegate = self;
    // _tableView.scrollsToTop = YES;
    // _tableView.backgroundColor = [UIColor colorWithWhite:0 alpha:.1];
    //  [self.view addSubview:_tableView];
}

- (NSArray *)searchFormats
{
    NSMutableArray *formats = [NSMutableArray array];
    for (NSDictionary *contact in self.chatContactsArray) {
        NSMutableDictionary *recombine = [NSMutableDictionary dictionaryWithDictionary:contact];
        
        NSString *name = contact[@"name"] ? contact[@"name"] : @"";
        NSString *nickName = contact[@"nickName"] ? contact[@"nickName"] : @"";
        NSString *groupTempName = contact[@"groupTempName"] ? contact[@"groupTempName"] : @"";
        
        NSString *format_01 = [[name transformToPinyin] lowercaseString];
        NSString *format_02 = [[nickName transformToPinyin] lowercaseString];
        NSString *format_03 = [[groupTempName transformToPinyin] lowercaseString];
        
        //        JLLog_I(@"<format_01=%@, format_02=%@, format_03=%@>", format_01, format_02, format_03);
        if ([format_01 isEqualToString:@"gongzuotai"]) {
            continue;
        }
        
        [recombine setObject:format_01 forKey:@"format_01"];
        [recombine setObject:format_02 forKey:@"format_02"];
        [recombine setObject:format_03 forKey:@"format_03"];
        [formats addObject:recombine];
    }
    //    JLLog_I(@"formats.count=%d", formats.count);
    return formats;
}

- (void)setupNavigationItem
{
    self.navigationItem.backBarButtonItem.title = @"";
    self.navigationItem.hidesBackButton = YES;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake(0, 0, 30, 30);
    [button setImage:[UIImage imageNamed:@"header_btn_plus"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [self.navigationItem setRightBarButtonItem:item];
}

- (void)setupController
{
    self.chatContactsArray = [NSMutableArray array];
    self.buddyNickNameArray = [NSMutableArray array];
}

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuAutoRelease:)
                                                 name:@"AI_KxMenu_Dismiss"
                                               object:nil];
    
    //设置通知中心，来消息时刷新；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView:)
                                                 name:@"NNC_Chat_Buddy_View_Refresh" object:nil];
    
    //设置通知中心，来消息时刷新（无声音刷新）；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView2)
                                                 name:@"NNC_Chat_Buddy_View_Refresh2" object:nil];
    
    //设置通知中心，来消息时刷新（）；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView3:)
                                                 name:@"NNC_Chat_Buddy_View_Refresh3" object:nil];
    
    //设置通知中心，个人信息刷新；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMyHeadImage)
                                                 name:@"NNC_PersonalInfomation_Loaded" object:nil];
    
    //设置通知中心，更新tabbarItem上面的消息数目；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllMsgTotal)
                                                 name:@"NNC_Chat_Buddy_View_Msg_Refresh" object:nil];
    
    //设置通知中心，退出圈子时，刷新聊天列表；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupInfo)
                                                 name:@"CNN_Group_Load_OK" object:nil];
    //网络监测
    [self startNotificationNetwork];
    
    //设置通知中心，提示网络连接状态断开；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatusDisconnect)
                                                 name:@"NNC_Network_Status_Disconnect" object:nil];
    
    //设置通知中心，提示网络连接状态恢复；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatusConnection)
                                                 name:@"NNC_Network_Status_Connection" object:nil];
    
    
    //设置通知中心，提示服务器连接状态断开；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateServerStatusDisconnect)
                                                 name:@"NNC_Server_Disconnect" object:nil];
    
    //设置通知中心，提示登录网络超时
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatusTimeout)
                                                 name:@"NNC_Server_Timeout" object:nil];
    
    //设置通知中心，提示服务器连接状态；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateServerStatusConnection)
                                                 name:@"NNC_Server_Connect" object:nil];
    
    //设置通知中心，提示服务器连接状态；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteReloginTimer)
                                                 name:@"NNC_Relogin" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInCorrectData)
                                                 name:@"Application_Start_Init_Data"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverDisconnect:)
                                                 name:XMPPServerDidDisconnectNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverDisconnect:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshInterface)
                                                 name:@"AI_Empty_Friends"
                                               object:nil];
}

- (void)handleInCorrectData {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userInfoReturn:)
                                                 name:@"AI_Contact_Info_Return"
                                               object:nil];
    
    NSArray *incorrectContacts = [ChatBuddyCRUD incorrectContacts];
    _incorrectContactCount = incorrectContacts.count;
    for (NSDictionary *d in incorrectContacts) {
        NSString *userName = d[@"userName"];
        if (![StrUtility isBlankString:userName]) {
            [self sendABContactInfoIQ:userName];
        }
    }
}

- (void)serverDisconnect:(NSNotification *)notification
{
    [ChatMessageCRUD setSendingMessagesFailed];
    [GroupChatMessageCRUD setSendingMessagesFailed];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self setupNavigationItem];
    [self setupController];
    [self setupNotifications];
    
    
    //消息提醒（声音，振动）
    NSString *soundPalyMark = [[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Sound_Play_Mark"];
    NSString *vibratePalyMark = [[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Vibrate_Play_Mark"];
    
    if(soundPalyMark == nil ){
        [[NSUserDefaults standardUserDefaults] setObject:@"play" forKey:@"NSUD_Sound_Play_Mark"];
        
    }
    if (vibratePalyMark == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"play" forKey:@"NSUD_Vibrate_Play_Mark"];
    }
    
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    
    //    myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //
    //    NSString *myImageUrl =  [NSString stringWithFormat:@"%@/%@",ResourcesURL,[[NSUserDefaults standardUserDefaults]stringForKey:@"headImage"]];
    //    UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 50.0, 50.0)];
    //    [photoView setImageWithURL:[NSURL URLWithString:myImageUrl] placeholderImage:[UIImage imageNamed:@"defaultUser"]];
    //
    //    [myButton setBackgroundImage:photoView.image
    //                        forState:UIControlStateNormal];
    //    [myButton addTarget:self action:@selector(gotoQRCode)
    //       forControlEvents:UIControlEventTouchUpInside];
    //    myButton.frame = CGRectMake(10, 0, 25, 25);
    //    myButton.layer.masksToBounds = YES;
    //    myButton.layer.cornerRadius = CGRectGetHeight([myButton bounds]) / 2;
    
    //UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    
    // [self.view addSubview:myButton];
    //self.navigationItem.leftBarButtonItem = menuButton;
    
    CGFloat yTabBar = self.tabBarController.tabBar.frame.size.height;
    CGRect frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Both_Bar_Height - yTabBar);
    UITableView *tablView = [[UITableView alloc]
                             initWithFrame:frame style:UITableViewStylePlain];
    tablView.tableFooterView = [[UIView alloc] init];
    tablView.showsVerticalScrollIndicator = NO;
    tablView.dataSource = self;
    tablView.delegate = self;
    [self.view addSubview:tablView];
    self.tableView = tablView;
    
    self.view.backgroundColor = AB_Color_f6f2ed;
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
    self.tableView.backgroundView.backgroundColor = AB_Color_f6f2ed;
    
    //网络提示状态栏
    customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, KCurrWidth, 44.0)];
    // UILabel * headerLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero ];
    // headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = YES;
    headerLabel.textColor = [UIColor lightGrayColor];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    headerLabel.frame = CGRectMake(0.0, 0.0, KCurrWidth, 44.0);
    headerLabel.textAlignment = NSTextAlignmentCenter;
    // UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(80, 12, 20, 20)];
    //[headerImageView setImage:[UIImage imageNamed:@"chat_error.png"]];
    //headerLabel.textColor = [UIColor redColor];
    headerLabel.text =  NSLocalizedString(@"public.alert.networkConnectionFailure",@"title");
    customView.backgroundColor =[UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.0f];
    //[customView addSubview:headerImageView];
    [customView addSubview:headerLabel];
    
    
    //服务器断开提示状态栏
    //    customView2 = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
    //    // UILabel * headerLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    //    UILabel * headerLabel2 = [[UILabel alloc] initWithFrame:CGRectZero ];
    //    // headerLabel.backgroundColor = [UIColor clearColor];
    //    headerLabel2.opaque = YES;
    //    headerLabel2.textColor = [UIColor lightGrayColor];
    //    headerLabel2.highlightedTextColor = [UIColor whiteColor];
    //    headerLabel2.font = [UIFont boldSystemFontOfSize:16];
    //    headerLabel2.frame = CGRectMake(80.0, 0.0, 300.0, 44.0);
    //    UIImageView *headerImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(25, 3, 30, 30)];
    //    [headerImageView2 setImage:[UIImage imageNamed:@"chat_error.png"]];
    //    headerLabel2.textColor = [UIColor redColor];
    //    headerLabel2.text =  @"服务器未连接";
    //    customView2.backgroundColor =[UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.0f];
    //   // [customView2 addSubview:headerImageView2];
    //    [customView2 addSubview:headerLabel2];
    
    
    
    // 设定位置和大小
    //    CGRect frame = CGRectMake(25,5,20,20);
    //    frame.size = [UIImage imageNamed:@"loading2.gif"].size;
    //    // 读取gif图片数据
    //    NSData *gif = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"loading2" ofType:@"gif"]];
    //    // view生成
    //    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
    //    webView.userInteractionEnabled = NO;//用户不可交互
    //    [webView loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    //
    //    [customView2 addSubview:webView];
    //
    //    [webView release];
    //    [headerImageView2 release];
    //    [headerLabel2 release];
    
    
    //搜索栏
    mySearchBar = [[UISearchBar alloc] init];
    mySearchBar.delegate = self;
    mySearchBar.barTintColor = AB_Color_f6f2ed;
    [mySearchBar setContentMode:UIViewContentModeScaleAspectFill];
    [mySearchBar setPlaceholder:NSLocalizedString(@"chat.search",@"action")];
    mySearchBar.keyboardType=UIKeyboardTypeNamePhonePad;
    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:mySearchBar contentsController:self];
    searchDisplayController.active = NO;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableHeaderView = mySearchBar;
    //    mySearchBar.barTintColor = [UIColor colorFromHexString:@"#f6f2ed"];
    //    for (UIView *obj in [mySearchBar subviews]) {
    //        for (UIView *objs in [obj subviews]) {
    //            if ([objs isKindOfClass:NSClassFromString(@"UISearchBarBackground")]){
    //                [objs removeFromSuperview];
    //            }
    //
    //        }
    //        if ([obj isKindOfClass:NSClassFromString(@"UISearchBarBackground")]){
    //            [obj removeFromSuperview];
    //        }
    //    }
    
    //添加搜索框文本框的边框
    UITextField *txfSearchField = [mySearchBar valueForKey:@"_searchField"];
    txfSearchField.borderStyle = UITextBorderStyleRoundedRect;
    txfSearchField.layer.cornerRadius = 3.0f;
    txfSearchField.layer.masksToBounds = YES;
    txfSearchField.layer.borderWidth = .5;
    txfSearchField.layer.borderColor = [[UIColor colorWithRed:214.0f/255.0f green:200.0f/255.0f blue:179.0f/255.0f alpha:1.0f] CGColor];
    
//    [self setExtraCellLineHidden:self.tableView];
    self.tableView.separatorColor = UIColorFromRGB(0xe7e2dd);
    _options = [NSArray arrayWithObjects:
                [NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"sns_icon_19.png"],@"img",NSLocalizedString(@"share.sms",@"title"),@"text", nil],
                [NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"sns_icon_22"],@"img",NSLocalizedString(@"share.weixin",@"title"),@"text", nil],
                [NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"sns_icon_23"],@"img",NSLocalizedString(@"share.moments",@"title"),@"text", nil],
                [NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"sns_icon_24"],@"img",NSLocalizedString(@"share.qq",@"title"),@"text", nil],
                [NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"sina.png"],@"img",NSLocalizedString(@"share.sinaWeibo",@"title"),@"text", nil],
                nil];
    
    
    //    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    //    tapGr.cancelsTouchesInView = NO;
    //    [self.navigationController.view addGestureRecognizer:tapGr];
    
    //下拉刷新
    //    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    //    refresh.tintColor = [UIColor lightGrayColor];
    //    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"  "];
    //    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    //    self.refreshControl = refresh;
    
    //self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self performSelector:@selector(refreshPersonalInformation) withObject:@"0" afterDelay:2];//1秒后执行
    
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 3, 0, 0);
    self.tableView.separatorColor = Buddy_Table_Separator_color;
    
    lastMsgTimeLabelFrame = CGRectMake(KCurrWidth-110, 3, 100, 15);
    lastMsgTimeLabelFont = [UIFont systemFontOfSize:10];
    groupNameTempArray=[[NSMutableArray alloc]init];
}




//跳转个人二维码
-(void)gotoQRCode{
    
    QrCodeViewController *qrCodeView = [[QrCodeViewController alloc]init];
    qrCodeView.hidesBottomBarWhenPushed=YES;
    if ([[NSUserDefaults standardUserDefaults]stringForKey:@"name"].length>0){
        qrCodeView.labNmaetext =[[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
    }else{
        qrCodeView.labNmaetext=[[NSUserDefaults standardUserDefaults]stringForKey:@"userName"];
    }
    
    [self.navigationController pushViewController:qrCodeView animated:YES];
    
}



- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        self.searchDisplayController.searchResultsTableView.allowsMultipleSelection = YES;
        //[self.searchDisplayController.searchResultsTableView setEditing:YES];
        return searchResults.count;
    }
    else {
        
        return self.chatContactsArray.count;
        
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *returnCell = nil;
    
    if (tableView == searchDisplayController.searchResultsTableView) {
        
        NSDictionary *contactsDic = searchResults[indexPath.row];
        AIChatBuddyCell *cell = [AIChatBuddyCell cellWithTableView:self.tableView];
        cell.timeLabel.text = @"";
        cell.detailTextLabel.text = @"";
        cell.abIcon.hidden = YES;
        cell.dndIcon.hidden = YES;
        returnCell = cell;
        
        NSString *type = contactsDic[@"type"];
        NSString *name = contactsDic[@"name"];
        NSString *nickName = contactsDic[@"nickName"];
        
        if ([type isEqualToString:@"system_ab_workbench"]) {
            cell.imageView.image = [UIImage imageNamed:@"icon_abWorkTable"];
            cell.textLabel.text = @"安邦工作台";
        }else if ([type isEqualToString:@"groupchat"]) {
            cell.groupMemebers = contactsDic[@"groupMembersArray"];
            cell.abIcon.hidden = [@"department" isEqualToString:contactsDic[@"groupType"]] ? NO : YES;
            NSString *groupTempName = contactsDic[@"groupTempName"];
            cell.groupMemebers = contactsDic[@"groupMembersArray"];
            cell.textLabel.text = [StrUtility string:name defaultValue:nickName];
            cell.textLabel.text = [StrUtility string:cell.textLabel.text defaultValue:groupTempName];
        }else {
            cell.abIcon.hidden = [contactsDic[@"accountType"] intValue] == 2 ? NO : YES;
            cell.textLabel.text = ![name isEqualToString:nickName] ? [NSString stringWithFormat:@"%@(%@)", name, nickName] : nickName;
            NSString *avatar = contactsDic[@"avatar"];
            NSURL *url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", ResourcesURL, avatar]];
            [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
        }
    }
    else {
        
        AIChatBuddyCell *cell = [AIChatBuddyCell cellWithTableView:tableView];
        returnCell = cell;
        
        NSDictionary *buddyDic = [self.chatContactsArray objectAtIndex:[indexPath row]];
        // NSDictionary *buddyDic = [[[NSDictionary alloc]init]autorelease];
        NSString *chatUserName = [buddyDic objectForKey:@"chatUserName"];
        int unreadMsgTotal = 0;
        
        //        UIImageView *icon = (UIImageView *)[cell.imageView viewWithTag:Buddy_AB_Icon_Tag];
        //        if (!icon) {
        //            UIImageView *abIcon = [[UIImageView alloc] init];
        //            abIcon.frame = CGRectMake(29, 34, 16, 11);
        //            abIcon.image = [UIImage imageNamed:@"icon_ab01"];
        //            abIcon.tag = Buddy_AB_Icon_Tag;
        //            [cell.imageView addSubview:abIcon];
        //            icon = abIcon;
        //        }
        cell.abIcon.hidden = ([[buddyDic objectForKey:@"accountType"] intValue] == 2) ? NO : YES;
        cell.dndPointView.hidden = YES;
        
        if ([[buddyDic objectForKey:@"type"] isEqualToString:@"system_ab_community"]){
            cell.textLabel.text = [buddyDic objectForKey:@"name"];
            cell.detailTextLabel.textColor = AB_Gray_Color;
            cell.detailTextLabel.text = [buddyDic objectForKey:@"lastMsg"];
            
            NSString *lastMsgTime = [buddyDic objectForKey:@"lastMsgTime"];
            cell.timeLabel.text = @"";
            
            //            UILabel * lastMsgTimeLabel = [[UILabel alloc] initWithFrame:lastMsgTimeLabelFrame];
            //
            //            lastMsgTimeLabel.text = [Utility friendlyTime_02:lastMsgTime];;
            //            lastMsgTimeLabel.textColor = [UIColor blackColor];
            //            lastMsgTimeLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
            //            lastMsgTimeLabel.font = lastMsgTimeLabelFont;  //设置文本字体与大小
            //            lastMsgTimeLabel.textAlignment = NSTextAlignmentRight;
            //
            //            lastMsgTimeLabel.textColor =  [UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1];
            
            //            CGSize itemSize = CGSizeMake(40, 40);
            //            UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
            //            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            //            [[UIImage imageNamed:@"Icon"] drawInRect:imageRect];
            //            cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            //            UIGraphicsEndImageContext();
            
            cell.imageView.image = [UIImage imageNamed:@"Icon"];
            
            
            //unreadMsgTotal=0;
            //                unreadMsgTotal=[ChatBuddyCRUD queryChatBuddyTableCountId:@"ab-insurance.com" myUserName:MY_USER_NAME];
            
            unreadMsgTotal=[SystemMessageCRUD queryCountUnread:@"system_ab_community" myUserName:MY_USER_NAME];
            if (unreadMsgTotal>0) {
                [cell.badgeView removeFromSuperview];
                JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:cell.imageView alignment:JSBadgeViewAlignmentTopRight];
                badgeView.badgeText = unreadMsgTotal > 99?@"99+":[NSString stringWithFormat:@"%d", unreadMsgTotal];
                cell.badgeView = badgeView;
            }else{
                [cell.badgeView removeFromSuperview];
            }
            
            //            [cell addSubview:lastMsgTimeLabel];
            
        } else if ([[buddyDic objectForKey:@"type"] isEqualToString:@"system_ab_newGuidance"]){
            cell.textLabel.text = [buddyDic objectForKey:@"name"];
            cell.detailTextLabel.textColor = AB_Gray_Color;
            cell.detailTextLabel.text = [buddyDic objectForKey:@"lastMsg"];
            
            NSString *lastMsgTime = [buddyDic objectForKey:@"lastMsgTime"];
            
            UILabel * lastMsgTimeLabel = [[UILabel alloc] initWithFrame:lastMsgTimeLabelFrame];
            
            cell.timeLabel.text = [Utility friendlyTime_02:lastMsgTime];
            
            lastMsgTimeLabel.textColor = [UIColor blackColor];
            lastMsgTimeLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
            lastMsgTimeLabel.font = lastMsgTimeLabelFont;  //设置文本字体与大小
            lastMsgTimeLabel.textAlignment = NSTextAlignmentRight;
            
            lastMsgTimeLabel.textColor =  [UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1];
            
            //            CGSize itemSize = CGSizeMake(40, 40);
            //            UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
            //            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            //            [[UIImage imageNamed:@"Icon"] drawInRect:imageRect];
            //            cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            //            UIGraphicsEndImageContext();
            cell.imageView.image = [UIImage imageNamed:@"Icon"];
            
            //unreadMsgTotal=0;
            //                unreadMsgTotal=[ChatBuddyCRUD queryChatBuddyTableCountId:@"ab-insurance.com" myUserName:MY_USER_NAME];
            
            unreadMsgTotal=[SystemMessageCRUD queryCountUnread:@"system_ab_newGuidance" myUserName:MY_USER_NAME];
            if (unreadMsgTotal>0) {
                [cell.badgeView removeFromSuperview];
                JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:cell.imageView alignment:JSBadgeViewAlignmentTopRight];
                badgeView.badgeText = unreadMsgTotal > 99?@"99+":[NSString stringWithFormat:@"%d", unreadMsgTotal];
                cell.badgeView = badgeView;
            }else{
                [cell.badgeView removeFromSuperview];
            }
            
            [cell addSubview:lastMsgTimeLabel];
            
        } else if ([[buddyDic objectForKey:@"type"] isEqualToString:@"system_ab_workbench"]){
            cell.textLabel.text = [buddyDic objectForKey:@"name"];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.detailTextLabel.text = @" ";
            cell.timeLabel.text = @"";
            
            //            CGSize itemSize = CGSizeMake(40, 40);
            //            UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
            //            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            //            [[UIImage imageNamed:@"icon_abWorkTable" ] drawInRect:imageRect];
            //            cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            //            UIGraphicsEndImageContext();
            cell.imageView.image = [UIImage imageNamed:@"icon_abWorkTable"];
            
            unreadMsgTotal=[SystemMessageCRUD queryCountUnread:@"system_ab_workbench" myUserName:MY_USER_NAME];
            if (unreadMsgTotal>0) {
                [cell.badgeView removeFromSuperview];
                JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:cell.imageView alignment:JSBadgeViewAlignmentTopRight];
                badgeView.badgeText = unreadMsgTotal > 99?@"99+":[NSString stringWithFormat:@"%d", unreadMsgTotal];
                cell.badgeView = badgeView;
            }else{
                [cell.badgeView removeFromSuperview];
            }
        }
        else{
            if (indexPath.section ==0) {
                // cell.textLabel.text = [self.onlineUsers objectAtIndex:[indexPath row]];
                //UILabel *nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)] autorelease];
                //nameLabel.font = [UIFont systemFontOfSize:12];  //设置文本字体与大小
                //nameLabel.textColor = [UIColor blackColor];
                
                NSString *lastMsg = [buddyDic objectForKey:@"lastMsg"];
                if (![[buddyDic objectForKey:@"name"] isEqualToString:@"(null)"] && [buddyDic objectForKey:@"name"] !=NULL && ![[buddyDic objectForKey:@"name"] isEqualToString:@""]){
                    
                    cell.textLabel.text = [buddyDic objectForKey:@"name"];
                    cell.detailTextLabel.textColor = AB_Gray_Color;
                    
                }else if (![[buddyDic objectForKey:@"nickName"] isEqualToString:@"(null)"] && [buddyDic objectForKey:@"nickName"]!=NULL && ![[buddyDic objectForKey:@"nickName"] isEqualToString:@""]) {
                    
                    cell.textLabel.text = [buddyDic objectForKey:@"nickName"];
                    cell.detailTextLabel.textColor = AB_Gray_Color;
                    
                }else{
                    cell.textLabel.text = [buddyDic objectForKey:@"chatUserName"];
                    cell.detailTextLabel.textColor = AB_Gray_Color;
                }
                
                lastMsg =[lastMsg stringByReplacingOccurrencesOfString:@"<br>" withString:@" "];
                
                BOOL hasAtMe = [remindJIDList containsObject: chatUserName];
                
                NSString *atStr = hasAtMe ? @"[有人@我]" : @"";
                NSString *allMsg = [NSString stringWithFormat:@"%@%@", atStr, lastMsg];
                //allMsg = [@[@":",@"："] containsObject:allMsg]?@"":allMsg;
                
                if(![StrUtility isBlankString: allMsg]){
                    if(hasAtMe){
                        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:allMsg];
                        NSRange range = NSMakeRange(0, atStr.length);
                        [attrString beginEditing];
                        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
                        [attrString endEditing];
                        
                        cell.detailTextLabel.attributedText = attrString;
                    } else {
                        cell.detailTextLabel.text = allMsg;
                    }
                } else {
                    cell.detailTextLabel.text = @"";
                }
                
                //最新消息时间
                NSString *lastMsgTime = [buddyDic objectForKey:@"lastMsgTime"];
                if(![StrUtility isBlankString:lastMsgTime]){
                    if (indexPath.section ==0) {
                        UILabel * lastMsgTimeLabel = [[UILabel alloc] initWithFrame:lastMsgTimeLabelFrame];
                        lastMsgTimeLabel.textColor = [UIColor blackColor];
                        lastMsgTimeLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
                        lastMsgTimeLabel.font = lastMsgTimeLabelFont;  //设置文本字体与大小
                        lastMsgTimeLabel.textAlignment = NSTextAlignmentRight;
                        lastMsgTimeLabel.textColor =  [UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1];
                        cell.timeLabel.text = [Utility friendlyTime_02:lastMsgTime];
                    }
                }
                
                
                //实现圈子头像效果
                if ([[buddyDic objectForKey:@"type"] isEqualToString:@"groupchat"]) {
                    
                    NSMutableArray *groupMembersArray = [buddyDic objectForKey:@"groupMembersArray"];
                    
                    if ([buddyDic[@"groupType"] isEqualToString:@"department"]) {
                        cell.abIcon.hidden = NO;
                    }
                    
                    //                    cell.imageView.image = [ImageUtility getGroupAvatar:groupMembersArray];
                    cell.groupMemebers = groupMembersArray;
                    cell.textLabel.text = [StrUtility string:[buddyDic objectForKey:@"name"] defaultValue:buddyDic[@"groupTempName"]];
                    
                    //                    CGSize itemSize = CGSizeMake(45, 45);
                    //                    UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
                    //                    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                    //                    [cell.imageView.image drawInRect:imageRect];
                    //                    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                    //                    UIGraphicsEndImageContext();
                }
                else{
                    NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [buddyDic objectForKey:@"avatar"]];
                    UIImageView *photoView = [[UIImageView alloc] init];
                    [photoView setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
                    //                    cell.imageView.image = photoView.image;
                    [cell.imageView setImageWithURL:[NSURL URLWithString:avatarURL]
                                   placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
                }
                
                NSString *chatType = [buddyDic objectForKey:@"type"];
                unreadMsgTotal = 0;
                if ([chatType isEqualToString:@"groupchat"]) {
                    unreadMsgTotal=[GroupChatMessageCRUD queryGroupCountUnreadMsg:chatUserName];
                }else if([chatType isEqualToString:@"multichat"]){
                    unreadMsgTotal=[GroupChatMessageCRUD queryGroupCountUnreadMsg:chatUserName];
                }else if([chatType isEqualToString:@"chat"]){
                    unreadMsgTotal= [ChatMessageCRUD queryCountUnread:_myUserName chatWithUser:chatUserName];
                    NSString *stickie_time = [UserInfoCRUD queryStickieTimeWithJID:buddyDic[@"jid"]];
                    if (![stickie_time isEqualToString:@"0"]) {
                        cell.contentView.backgroundColor = AB_Color_fffdf5;
                    }else {
                        cell.contentView.backgroundColor = AB_Color_ffffff;
                    }
                }else if ([[buddyDic objectForKey:@"type"] isEqualToString:@"news"]){
                    unreadMsgTotal=[NewsCRUD quearReadMark:_myUserName];
                }else if ([[buddyDic objectForKey:@"type"] isEqualToString:@"headline"]){//系统通知
                    unreadMsgTotal=[SystemMessageCRUD queryCountUnread:@"ab-insurance.com" myUserName:MY_USER_NAME];
                }
                
                if (unreadMsgTotal>0) {
                    [cell.badgeView removeFromSuperview];
                    JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:cell.imageView alignment:JSBadgeViewAlignmentTopRight];
                    badgeView.badgeText = unreadMsgTotal > 99?@"99+":[NSString stringWithFormat:@"%d", unreadMsgTotal];
                    cell.badgeView = badgeView;
                } else{
                    [cell.badgeView removeFromSuperview];
                }
                
                if ([[buddyDic objectForKey:@"type"] isEqualToString:@"groupchat"] ) {
                    
                    NSString *stickie_time = [GroupCRUD queryStickieTimeWithJID:buddyDic[@"jid"]];
                    if (![stickie_time isEqualToString:@"0"]) {
                        cell.contentView.backgroundColor = AB_Color_fffdf5;
                    }else {
                        cell.contentView.backgroundColor = AB_Color_ffffff;
                    }
                    
                }else if ([[buddyDic objectForKey:@"type"] isEqualToString:@"multichat"] ) {
                    //                    CGSize itemSize = CGSizeMake(45, 45);
                    //                    UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
                    //                    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                    //                    [cell.imageView.image drawInRect:imageRect];
                    //                    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                    //                    UIGraphicsEndImageContext();
                    
                    
                }else{
                    //                    CGSize itemSize = CGSizeMake(45, 45);
                    //                    UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
                    //                    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                    //                    [cell.imageView.image drawInRect:imageRect];
                    //                    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                    //                    UIGraphicsEndImageContext();
                    
                    if ([[buddyDic objectForKey:@"tag"] isEqualToString:@"new"]) {
                        //                        JSBadgeView * badgeView = [[JSBadgeView alloc] initWithParentView:cell alignment:JSBadgeViewAlignmentTopRigthCustom2];
                        //                        badgeView.badgeText = [NSString stringWithFormat:@"%@", @"new"];
                        
                    }
                    
                }
                
            }
            else{
                UIImage *userImage =[UIImage imageNamed:@"defaultUser.png"];
                //            GBPathImageView *squareImage = [[GBPathImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 50.0, 50.0) image:userImage pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor whiteColor] pathWidth:1.0];
                cell.imageView.image = userImage;
                
                //                CGSize itemSize = CGSizeMake(45, 45);
                //                UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
                //                CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                //                [cell.imageView.image drawInRect:imageRect];
                //                cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                //                UIGraphicsEndImageContext();
                
                if (unreadMsgTotal>0) {
                    [cell.badgeView removeFromSuperview];
                    JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:cell.imageView alignment:JSBadgeViewAlignmentTopRight];
                    badgeView.badgeText = unreadMsgTotal > 99?@"99+":[NSString stringWithFormat:@"%d", unreadMsgTotal];
                    cell.badgeView = badgeView;
                }else{
                    [cell.badgeView removeFromSuperview];
                }
            }
        }
        CGRect rect = [cell.textLabel textRectForBounds:cell.textLabel.frame limitedToNumberOfLines:0];
        // 設置顯示榘形大小
        
        CGSize itemSize = CGSizeMake(14, 14);
        
        rect.size = itemSize;
        // 重置列文本區域
        cell.textLabel.frame = rect;
        // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 3.0;
        cell.imageView.layer.borderWidth = 0.0;
        if ([[buddyDic objectForKey:@"type"] isEqualToString:@"groupchat"] || [[buddyDic objectForKey:@"type"] isEqualToString:@"multichat"] ){
            cell.imageView.layer.borderWidth = 0.0;
            cell.imageView.backgroundColor = kMainColor4;
        }
        //        cell.textLabel.text = @"安邦办公室";
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.textLabel.textColor = UIColorFromRGB(0x403b36);
        cell.detailTextLabel.textColor = UIColorFromRGB(0x9c958a);
        
        NSString* tempStrJid = @"";
        
        NSString* tempStrType = [buddyDic objectForKey:@"type"];
        
        if ([tempStrType isEqualToString:@"groupchat"]) {
            
            tempStrJid = [buddyDic objectForKey:@"chatUserName"];
            
            
        }else if([tempStrType isEqualToString:@"chat"]){
            
            tempStrJid = [NSString stringWithFormat:@"%@@%@",[buddyDic objectForKey:@"chatUserName"], OpenFireHostName];
            
        }
        
        
        if ([DndInfoCRUD queryOfRosterExtWithJid:tempStrJid]) {
            [cell.dndIcon setHidden:NO];
            
            NSArray* views =cell.imageView.subviews;
            for (UIView* view in views) {
                if([view isKindOfClass:[JSBadgeView class]]){
                    //                    JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:cell.imageView alignment:JSBadgeViewAlignmentTopRight];
                    //                    badgeView.badgeText = @" ";
                    //                    //badgeView.badgeTextFont = [UIFont boldSystemFontOfSize:5];
                    //                    cell.badgeView = badgeView;
                    cell.dndPointView.hidden = (unreadMsgTotal == 0);
                    cell.badgeView.hidden = YES;
                    break;
                }
            }
        } else {
            [cell.dndIcon setHidden:YES];
        }
    }
    
    returnCell.imageView.layer.borderColor = [kMainColor4 CGColor];
    
    returnCell.selectedBackgroundView = [[UIView alloc] initWithFrame:returnCell.frame];
    returnCell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
    
    return returnCell;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    // UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)] autorelease];
//
//    return NULL;
//}
//别忘了设置高度
//- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//    return 44.0;
//    }
//}


#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //start a Chat
    //    if (indexPath.row ==  self.chatContactsArray.count-1) {
    //        [self gotoQRCode];
    //        return;
    //    }
    
    // [self.tableView reloadRowsAtIndexPaths:indexPath.row withRowAnimation:YES];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //区分搜索结果列表
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        //NSLog(@"选中搜索好友");
        NSDictionary *chatContactsDic = [searchResults objectAtIndex:[indexPath row]];
        [selectedResults addObject:[chatContactsDic objectForKey:@"jid"]];
        
        NSString *type = [chatContactsDic objectForKey:@"type"];
        
        //区分单聊,群组聊天,临时多人聊天
        if ([type isEqualToString:@"groupchat"]) {
            [ChatBuddyCRUD updateCommonChatBuddy:@"tag" value:@""];
            GroupChatViewController2 *groupChatCtl = [[GroupChatViewController2 alloc] init];
            // NSDictionary *buddyDic = [self.chatContactsArray objectAtIndex:[indexPath row]];
            //NSString *chatNickName = (NSString *)[chatContactsDic objectForKey:@"searchName"];
            NSString *chatUserName = (NSString *)[chatContactsDic objectForKey:@"chatUserName"];
            groupChatCtl.roomName = chatUserName;
            
            //NSLog(@"***%@",chatNickName);
            if([StrUtility isBlankString: [chatContactsDic objectForKey:@"nickName"]]){
                //groupChatCtl.title = @"群聊";
                groupChatCtl.roomNickName = @"群聊";
            }else{
                //groupChatCtl.title = [chatContactsDic objectForKey:@"nickName"];
                groupChatCtl.roomNickName = [chatContactsDic objectForKey:@"nickName"];
            }
            //隐藏tabbar
            groupChatCtl.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:groupChatCtl animated:YES];
            
        }
        else if ([type isEqualToString:@"system_ab_workbench"]){
            BBCommunityVC *vc = [[BBCommunityVC alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else{
            [ChatBuddyCRUD updateCommonChatBuddy:@"tag" value:@""];
            
            NSString *chatUserName = (NSString *)[chatContactsDic objectForKey:@"chatUserName"];
            
            ChatViewController2 * chatViewCtl=[[ChatViewController2 alloc] init];
            
            chatViewCtl.chatWithUser = chatUserName;
            chatViewCtl.chatWithNick = [StrUtility string:chatContactsDic[@"nickName"]];
            chatViewCtl.remarkName = [StrUtility string:chatContactsDic[@"name"]];
            NSString *ChatWithJID = [NSString stringWithFormat:@"%@@%@",chatUserName, OpenFireHostName];
            chatViewCtl.chatWithJID  = ChatWithJID;
            // _chatBuddyMessageFlag = @"NO";
            
            chatViewCtl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            //隐藏tabbar
            chatViewCtl.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:chatViewCtl animated:YES];
        }
        
        [searchDisplayController setActive:NO animated:YES];
    }
    else{
        
        NSDictionary *chatContactsDic = [self.chatContactsArray objectAtIndex:[indexPath row]];
        NSString *chatNickName = @"";
        NSString *chatUserName = (NSString *)[chatContactsDic objectForKey:@"chatUserName"];
        
        
        if (![[chatContactsDic objectForKey:@"nickName"] isEqualToString:@""] && ![[chatContactsDic objectForKey:@"nickName"] isEqualToString:@"(null)"]) {
            chatNickName = (NSString *)[chatContactsDic objectForKey:@"nickName"];
        }
        
        if (![[chatContactsDic objectForKey:@"name"] isEqualToString:@""] &&![[chatContactsDic objectForKey:@"name"] isEqualToString:@"(null)"] ) {
            chatNickName = (NSString *)[chatContactsDic objectForKey:@"name"];
        }
        
        if ([chatNickName isEqualToString:@""]) {
            chatNickName = chatUserName;
        }
        
        NSString *type = [chatContactsDic objectForKey:@"type"];
        
        // NSLog(@"选中好友%@",type);
        
        //区分单聊和群组聊天
        if ([type isEqualToString:@"groupchat"]) {
            [ChatBuddyCRUD updateCommonChatBuddy:@"tag" value:@""];
            GroupChatViewController2 *groupChatVC = [[GroupChatViewController2 alloc] init] ;
            NSDictionary *buddyDic = [self.chatContactsArray objectAtIndex:[indexPath row]];
            groupChatVC.roomName = [buddyDic objectForKey:@"chatUserName"];
            groupChatVC.groupJID = [buddyDic objectForKey:@"groupJID"];
            
            NSString *groupName = [buddyDic objectForKey:@"name"];
            
            //从at的群列表里面移除
            [remindJIDList removeObject:[buddyDic objectForKey:@"chatUserName"]];
            
            int memberCount = [[chatContactsDic objectForKey:@"groupMembersArray"] count];
            
            if([StrUtility isBlankString: groupName]){
                groupChatVC.title = [NSString stringWithFormat:@"群聊(%d)",memberCount];
                groupChatVC.roomNickName = @"群聊";
            }else{
                if(groupName.length > 12){
                    groupName = [NSString stringWithFormat:@"%@···%@", [groupName substringToIndex:6], [groupName substringFromIndex:groupName.length - 3]];
                }
                groupChatVC.title = [NSString stringWithFormat:@"%@(%d)", groupName, memberCount] ;
                groupChatVC.roomNickName = groupName;
            }
            
            //隐藏tabbar
            groupChatVC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:groupChatVC animated:YES];
            
        }else if([type isEqualToString:@"chat"]){
            [ChatBuddyCRUD updateCommonChatBuddy:@"tag" value:@""];
            ChatViewController2 * chatViewCtl=[[ChatViewController2 alloc] init];
            chatViewCtl.chatWithUser = chatUserName;
            chatViewCtl.chatWithNick = chatNickName;
            chatViewCtl.remarkName = chatNickName;
            NSString *ChatWithJID = [NSString stringWithFormat:@"%@@%@",[chatContactsDic objectForKey:@"chatUserName"], OpenFireHostName];
            chatViewCtl.chatWithJID  = ChatWithJID;
            
            //NSLog(@"******%@:%@:%@",ChatWithJID,chatNickName,chatUserName);
            
            _chatBuddyMessageFlag = @"NO";
            //chatViewCtl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            chatViewCtl.title = chatNickName;
            //隐藏tabbar
            chatViewCtl.hidesBottomBarWhenPushed= YES;
            [self.navigationController pushViewController:chatViewCtl animated:YES];
            
        }else if ([type isEqualToString:@"system_ab_community"]){
            
            SystemMessageViewController *systenmInforms=[[SystemMessageViewController alloc]init];
            systenmInforms.sendName = @"system_ab_community";
            systenmInforms.sendTitle = NSLocalizedString(@"public.system.systemPrompt",@"title");
            systenmInforms.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:systenmInforms animated:YES];
            
            
        }else if ([type isEqualToString:@"system_ab_newGuidance"]){
            
            SystemMessageViewController *systenmInforms=[[SystemMessageViewController alloc]init];
            systenmInforms.sendName = @"system_ab_newGuidance";
            systenmInforms.sendTitle = NSLocalizedString(@"public.system.anbangMessage",@"title");
            systenmInforms.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:systenmInforms animated:YES];
            
            
        }else if ([type isEqualToString:@"system_ab_workbench"]){
            BBCommunityVC *vc = [[BBCommunityVC alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
}


- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewShouldScrollToTop");
    return YES;
}


//tableView的编辑模式中当提交一个编辑操作时候调用：比如删除，添加等
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    // if (indexPath.section == 0) {
    
    // [self.chatContactsArray removeObjectAtIndex:indexPath.row];
    // }
    // UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    //  [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    
    
    //    if (self.chatContactsArray.count==0) {
    //        //[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
    //        //                withRowAnimation:UITableViewRowAnimationTop];
    //        return;
    //
    //    }
    //
    
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSDictionary *buddyDic = [self.chatContactsArray objectAtIndex:[indexPath row]];
        [ChatBuddyCRUD deleteChatBuddyByChatUserName:[buddyDic objectForKey:@"chatUserName"] myUserName:MY_USER_NAME];
        [self.chatContactsArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        mSearchFormats = [self searchFormats];
        [self refreshAllMsgTotal];
        
        //        int row = [indexPath row];
        //
        //        if (row == self.chatContactsArray.count) {
        //            if (indexPath.section == 0) {
        //                [self.chatContactsArray removeObjectAtIndex:indexPath.row];
        //            }
        //            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
        //                                  withRowAnimation:UITableViewRowAnimationTop];
        //            return;
        //
        //        }
        //
        //        NSDictionary *buddyDic = [self.chatContactsArray objectAtIndex:[indexPath row]];
        //        [ChatBuddyCRUD deleteChatBuddyByChatUserName:[buddyDic objectForKey:@"chatUserName"] myUserName:MY_USER_NAME];
        //        //同时刷新消息数目
        //        [self refreshAllMsgTotal];
        //
        //        if (indexPath.section == 0) {
        //            [self.chatContactsArray removeObjectAtIndex:indexPath.row];
        //        }
        //        NSLog(@"delete!");
        //        //        if(self.chatContactsArray.count<6){
        //        //
        //        //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //        //
        //        //                [self.tableView reloadData];
        //        //
        //        //            });
        //        //
        //        //        }else{
        //        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
        //                              withRowAnimation:UITableViewRowAnimationTop];
        // }
    }
    
}


//每次设置为编辑模式之前，都会访问这个方法：
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    if(self.chatContactsArray.count==5){
    //        if (indexPath.row>=5) {
    //            return NO;
    //        }
    //    }else if(self.chatContactsArray.count==4){
    //        if (indexPath.row>=4) {
    //            return NO;
    //        }
    //    }else if(self.chatContactsArray.count==3){
    //        if (indexPath.row>=3) {
    //            return NO;
    //        }
    //    }else if(self.chatContactsArray.count==2){
    //        if (indexPath.row>=2) {
    //            return NO;
    //        }
    //    }else if(self.chatContactsArray.count==1){
    //        if (indexPath.row>=1) {
    //            return NO;
    //        }
    //    }
    if ([UserInfoCRUD queryUserInfoAccountTypeWith:MY_JID] == 2) {
        if (indexPath.row == 0) {
            return UITableViewCellEditingStyleNone;
        }
    }
    return UITableViewCellEditingStyleDelete;
    // return self.tableView.tag;
}

//编辑模式的时候，拖动的时候会调用这个方法：
//-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
//
//
//    //TODO
//}


//可能我们会对按钮的出现和消失的时刻感兴趣，那么此刻要实现代理的方法：
- (void) tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void) tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}




//渐变 和 移动
- (UIGestureRecognizer *)createTapRecognizerWithSelector:(SEL)selector {
    return [[UITapGestureRecognizer alloc]initWithTarget:self action:selector];
}


- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}


-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random()%(to - from + 1)));
}




//跳转填写手机号码
-(void)invitationFriends{
    AddressBookViewController3* addressBookView=[[AddressBookViewController3 alloc]init];
    addressBookView.title = NSLocalizedString(@"contacts.inviteFridend.mobilePhoneNumberToInvite",@"title");
    addressBookView.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:addressBookView animated:YES];
}


#pragma mark - private
//删除好友
-(void)toDeleteButty{
    self.tableView.tag = UITableViewCellEditingStyleDelete;//删除状态：以tag值来传递编辑状态
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
}



//用户中心
-(void)userCenter{
    UserCenterViewController *userCenterVC = [[UserCenterViewController alloc]init];
    CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideTabBar:YES];
    [self.navigationController pushViewController:userCenterVC animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //获取最新数据
    self.chatContactsArray = [ChatBuddyCRUD queryChatContactsList:MY_USER_NAME];
    //    JLLog_I(@"chatContactsArray=%@", self.chatContactsArray);
    
    if (!mSearchFormats && self.chatContactsArray.count != 0) {
        mSearchFormats = [self searchFormats];
    }
    
    //更新未读消息
    int unreadTotal = [ChatBuddyCRUD queryAllMsgTotal];
    if (unreadTotal>0 && unreadTotal<100) {
        [[self.tabBarController.tabBar .items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%d",unreadTotal]];
        
    }else if(unreadTotal>=100){
        [[self.tabBarController.tabBar .items objectAtIndex:0] setBadgeValue:@"99+"];
    }else if(unreadTotal==0){
        [[self.tabBarController.tabBar .items objectAtIndex:0] setBadgeValue:nil];
    }
    
    [self.tableView reloadData];//3
    
    // [self refreshInterface];
}

- (void) refreshInterface
{
    BOOL hasFriends = [ContactsCRUD hasFriends];
    if (!hasFriends) {
        if (!_easyToAddFriends) {
            [self showAddFriendsButton];
        }
    }else {
        if (_easyToAddFriends) {
            [self.easyToAddFriends removeFromSuperview];
            self.easyToAddFriends = nil;
            self.tableView.contentInset = UIEdgeInsetsZero;
        }
    }
}

- (void) showAddFriendsButton
{
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    
    // Beafore return, adding a button for inviting friends
    CGFloat ycenter = Screen_Height - self.tabBarController.tabBar.frame.size.height - 22 - Both_Bar_Height;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = (CGRect){CGPointZero, CGSizeMake(Screen_Width, 44)};
    button.center = CGPointMake(Screen_Width / 2, ycenter);
    [button setTitle:@"快去添加好友吧！" forState:UIControlStateNormal];
    [button setTitleColor:AB_Color_9c958a forState:UIControlStateNormal];
    [button addTarget:self action:@selector(toAddFriendVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.easyToAddFriends = button;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _chatBuddyMessageFlag=@"NO";
    
}


/*---搜索聊天联系人----------------------------------------------------------------------------------*/
#pragma mark
#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    AISearchContactViewController *c = [[AISearchContactViewController alloc] init];
    __weak typeof(self)wself = self;
    c.completedBlock = ^(UIViewController *viewController) {
        viewController.hidesBottomBarWhenPushed = YES;
        [wself.navigationController pushViewController:viewController animated:YES];
    };
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:c];
    [self.navigationController presentViewController:navigation animated:YES completion:nil];
    return NO;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (!searchResults) {
        searchResults = [NSMutableArray array];
    }
    if (mSearchFormats.count == 0 || !mSearchFormats) {
        mSearchFormats = [self searchFormats];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchResults removeAllObjects];
    searchResults = [NSMutableArray array];
    mSearchFormats = [NSArray array];
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    
    [searchResults removeAllObjects];
    if (!searchText || [searchText isEqualToString:@""]) return;
    
    if (self.chatContactsArray.count > 0) {
        NSDictionary *contact = self.chatContactsArray[0];
        if ([@"system_ab_workbench" isEqualToString:contact[@"type"]]) {
            [searchResults addObject:contact];
        }
    }
    
    NSString *search_format = [[searchText transformToPinyin] lowercaseString];
    for (NSDictionary *contact in mSearchFormats) {
        
        NSString *format_01 = contact[@"format_01"];
        NSString *format_02 = contact[@"format_02"];
        NSString *format_03 = contact[@"format_03"];
        
        if ([format_01 hasPrefix:search_format] || [format_02 hasPrefix:search_format] || [format_03 hasPrefix:search_format]) {
            [searchResults addObject:contact];
        }
    }
    //    JLLog_I(@"result=%@", searchResults);
    [searchDisplayController.searchResultsTableView reloadData];
    
    
    
    //    if (mySearchBar.text.length>0&&![ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
    //        for (int i=0; i<self.chatContactsArray.count; i++) {
    //
    //
    //            NSDictionary *searchBuddyDic = [self.chatContactsArray objectAtIndex:i];
    //
    //            //无名称的群
    //
    //
    //            NSString *type = [searchBuddyDic objectForKey:@"type"];
    //            NSString *chatUserName = [searchBuddyDic objectForKey:@"chatUserName"];
    //            NSString *searchName = @"";
    //
    //
    //            if ([searchBuddyDic objectForKey:@"name"]!=NULL && ![[searchBuddyDic objectForKey:@"name"] isEqualToString:@""] &&![[searchBuddyDic objectForKey:@"name"] isEqualToString:@"(null)"]) {
    //                searchName = [searchBuddyDic objectForKey:@"name"];
    //
    //            }else if ([searchBuddyDic objectForKey:@"nickName"]!=NULL && ![[searchBuddyDic objectForKey:@"nickName"] isEqualToString:@""] && ![[searchBuddyDic objectForKey:@"nickName"] isEqualToString:@"(null)"]) {
    //                searchName= [searchBuddyDic objectForKey:@"nickName"];
    //
    //            }else{
    //                searchName = chatUserName;
    //            }
    //
    //            if([type isEqualToString: @"groupchat"]){
    //                NSMutableArray *groupMembersArray = [searchBuddyDic objectForKey:@"groupMembersArray"];
    //                for (int i=0; i<1; i++) {
    //
    //                    NSDictionary *groupDic = [groupMembersArray objectAtIndex:i];
    //                    searchName = [groupDic objectForKey:@"nickName"];
    //                    NSLog(@"******%@",searchName);
    //                }
    //            }
    //
    //            if ([ChineseInclude isIncludeChineseInString:searchName]) {
    //                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:searchName];
    //                NSRange titleResult=[tempPinYinStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
    //                if (titleResult.length>0) {
    //                    // [searchResults addObject:searchName];
    //                    [searchResults addObject:[NSDictionary dictionaryWithObjectsAndKeys:chatUserName,@"chatUserName",searchName, @"searchName",type,@"type",nil]];
    //                }
    //                //                NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:searchName];
    //                //                NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
    //                //                if (titleHeadResult.length>0) {
    //                //                    [searchResults addObject:searchName];
    //                //                }
    //            }
    //            else {
    //                NSRange titleResult=[searchName rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
    //                if (titleResult.length>0) {
    //                    //[searchResults addObject:searchName];
    //                    [searchResults addObject:[NSDictionary dictionaryWithObjectsAndKeys:chatUserName,@"chatUserName",searchName, @"searchName",type,@"type",nil]];
    //                }
    //            }
    //        }
    //    } else if (mySearchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
    //        for (NSDictionary *tempDic in self.chatContactsArray) {
    //
    //            NSString *type = [tempDic objectForKey:@"type"];
    //            NSString *chatUserName = [tempDic objectForKey:@"chatUserName"];
    //            NSString *searchName = @"";
    //
    //
    //
    //            if ([tempDic objectForKey:@"name"]!=NULL && ![[tempDic objectForKey:@"name"] isEqualToString:@""] &&![[tempDic objectForKey:@"name"] isEqualToString:@"(null)"]) {
    //                searchName = [tempDic objectForKey:@"name"];
    //
    //            }else if ([tempDic objectForKey:@"nickName"]!=NULL && ![[tempDic objectForKey:@"nickName"] isEqualToString:@""] && ![[tempDic objectForKey:@"nickName"] isEqualToString:@"(null)"]) {
    //                searchName= [tempDic objectForKey:@"nickName"];
    //
    //            }else{
    //                searchName = chatUserName;
    //            }
    //
    //            if([type isEqualToString: @"groupchat"]){
    //                NSMutableArray *groupMembersArray = [tempDic objectForKey:@"groupMembersArray"];
    //                for (int i=0; i<1; i++) {
    //
    //                    NSDictionary *groupDic = [groupMembersArray objectAtIndex:i];
    //                    searchName = [groupDic objectForKey:@"nickName"];
    //                }
    //            }
    //
    //
    //            NSRange titleResult=[searchName rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
    //            if (titleResult.length>0) {
    //                //[searchResults addObject:tempStr];
    //                [searchResults addObject:[NSDictionary dictionaryWithObjectsAndKeys:chatUserName,@"chatUserName",searchName, @"searchName",type,@"type",nil]];
    //            }
    //        }
    //    }
    //
    //
    //    NSMutableArray* contacts = [ContactsCRUD queryContactsList:MY_JID];
    //
    //    if (mySearchBar.text.length>0 && ![ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
    //        for (int i=0; i< contacts.count; i++) {
    //            NSDictionary* tempDic = contacts[i];
    //            NSString* chatJid =[tempDic valueForKey:@"userName"];
    //            NSString* chatUserName = [chatJid componentsSeparatedByString:@"@"][0];
    //              // 匹配昵称跟备注
    //            NSString *format_01 = [tempDic valueForKey:@"nickName"] ;
    //            NSString *format_02 = [tempDic valueForKey:@"name"] ;
    //
    //            NSString* searchName = nil;
    //
    //            if (![format_02 isEqualToString:@""] && format_02 != nil && ![format_02 isEqualToString:@"(null)"]) {
    //                searchName = format_02;
    //            }else{
    //                searchName = format_01;
    //            }
    //
    //            if ([ChineseInclude isIncludeChineseInString:format_01]) {
    //                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:format_01];
    //                NSRange titleResult=[tempPinYinStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
    //
    //                if (titleResult.length>0) {
    //                    // [searchResults addObject:searchName];
    //
    //                    NSDictionary* contactDic = [NSDictionary dictionaryWithObjectsAndKeys:chatUserName,@"chatUserName",searchName, @"searchName",@"chat",@"type",nil];
    //                    NSInteger num = [searchResults indexOfObject:contacts];
    //                    if ( num < 0 || num >= contacts.count) {
    //                         [searchResults addObject:contactDic];
    //                    }
    //
    //
    //                }else{
    //                    if ([ChineseInclude isIncludeChineseInString:format_02]) {
    //                        NSString *temp = [PinYinForObjc chineseConvertToPinYin:format_02];
    //                        NSRange res = [temp rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
    //                        if (res.length > 0) {
    //                            NSDictionary* contactDic = [NSDictionary dictionaryWithObjectsAndKeys:chatUserName,@"chatUserName",searchName, @"searchName",@"chat",@"type",nil];
    //                            NSInteger num = [searchResults indexOfObject:contacts];
    //                            if ( num < 0 || num >= contacts.count) {
    //                                [searchResults addObject:contactDic];
    //                            }
    //
    //                        }
    //                    }else {
    //                        NSRange res = [format_02 rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
    //
    //                        if (res.length > 0) {
    //                            NSDictionary* contactDic = [NSDictionary dictionaryWithObjectsAndKeys:chatUserName,@"chatUserName",searchName, @"searchName",@"chat",@"type",nil];
    //                            NSInteger num = [searchResults indexOfObject:contacts];
    //                            if ( num < 0 || num >= contacts.count) {
    //                                [searchResults addObject:contactDic];
    //                            }
    //
    //                        }
    //                    }
    //                }
    //            }
    //            else {
    //                NSRange titleResult=[format_01 rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
    //
    //                if (titleResult.length>0) {
    //                    //[searchResults addObject:searchName];
    //                    NSDictionary* contactDic = [NSDictionary dictionaryWithObjectsAndKeys:chatUserName,@"chatUserName",searchName, @"searchName",@"chat",@"type",nil];
    //                    NSInteger num = [searchResults indexOfObject:contacts];
    //                    if ( num < 0 || num >= contacts.count) {
    //                        [searchResults addObject:contactDic];
    //                    }
    //
    //                }
    //            }
    //
    //        }
    //
    //    } else if (mySearchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
    //        for (int i=0; i<contacts.count; i++) {
    //            NSDictionary* tempDic = contacts[i];
    //            NSString* chatJid =[tempDic valueForKey:@"userName"];
    //            NSString* chatUserName = [chatJid componentsSeparatedByString:@"@"][0];
    //            // 匹配昵称跟备注
    //            NSString *format_01 = [tempDic valueForKey:@"nickName"] ;
    //            NSString *format_02 = [tempDic valueForKey:@"name"] ;
    //
    //            NSString* searchName = nil;
    //
    //            if (![format_02 isEqualToString:@""] && format_02 != nil && ![format_02 isEqualToString:@"(null)"]) {
    //                searchName = format_02;
    //            }else{
    //                searchName = format_01;
    //            }
    //            NSRange titleResult=[format_01 rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
    //            //contact.pinYin = searchName;
    //            if (titleResult.length>0) {
    //                NSDictionary* contactDic = [NSDictionary dictionaryWithObjectsAndKeys:chatUserName,@"chatUserName",searchName, @"searchName",@"chat",@"type",nil];
    //                NSInteger num = [searchResults indexOfObject:contacts];
    //                if ( num < 0 || num >= contacts.count) {
    //                    [searchResults addObject:contactDic];
    //                }
    //            }
    //            else {
    //                NSRange res = [format_02 rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
    //                if (res.length > 0) {
    //                    NSDictionary* contactDic = [NSDictionary dictionaryWithObjectsAndKeys:chatUserName,@"chatUserName",searchName, @"searchName",@"chat",@"type",nil];
    //                    NSInteger num = [searchResults indexOfObject:contacts];
    //                    if ( num < 0 || num >= contacts.count) {
    //                        [searchResults addObject:contactDic];
    //                    }
    //                }
    //            }
    //
    //        }
    //
    //    }
    //
    //
    //    [self.tableView  reloadData];
}

#pragma end


//用户头像
-(void)avatarReceived:(NSString *)avatarURL{
    //这里不做处理
}


//展示好友列表
-(void)showBuddyList{
    //这里不做处理
}


//接收通知，刷新聊天历史列表
-(void)refreshTableView:(NSNotification *) sender{
    JLLog_I(@"refresh buddy table");
    
    if (sender.object) {
        NSDictionary *dict = (NSDictionary*)sender.object;
        NSString *groupJID = [dict.allKeys containsObject:@"groupJID"]?dict[@"groupJID"]:@"";
        NSString *JID = [dict.allKeys containsObject:@"JID"]?dict[@"JID"]:@"";
        
        BOOL hasAtMe = [@"1" isEqualToString:dict[@"hasAtMe"]];
        if(hasAtMe){
            [remindJIDList addObject:groupJID];
        }
        
        BOOL isDND = [DndInfoCRUD queryOfRosterExtWithJid: [StrUtility string:groupJID defaultValue:JID]];
        
        if(hasAtMe || !isDND){
            NSString *soundPalyMark = [[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Sound_Play_Mark"];
            NSString *vibratePalyMark = [[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Vibrate_Play_Mark"];
            
            long currentTime = (long)[[NSDate date] timeIntervalSince1970];
            
            if ([soundPalyMark isEqualToString:@"play"]) {
                if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive){
                    if(mFirstSound || currentTime - lastSoundPlayTime > 5){
                        [JSMessageSoundEffect playMessageReceivedSound2];
                        lastSoundPlayTime = currentTime;
                        mFirstSound = NO;
                    }
                }
            }
            if ([vibratePalyMark isEqualToString:@"play"]) {
                if(mFirstVibrate || currentTime - lastVibratePlayTime > 5){
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    lastVibratePlayTime = currentTime;
                    mFirstVibrate = NO;
                }
            }
        }
    }
    
    self.chatContactsArray = [ChatBuddyCRUD queryChatContactsList:MY_USER_NAME];
    [self.tableView reloadData];
    
    //更新未读消息
    int unreadTotal = [ChatBuddyCRUD queryAllMsgTotal];
    if (unreadTotal>0 && unreadTotal<100) {
        [[self.tabBarController.tabBar .items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%d",unreadTotal]];
    }else if(unreadTotal>=100){
        [[self.tabBarController.tabBar .items objectAtIndex:0] setBadgeValue:@"99+"];
    }else if(unreadTotal==0){
        [[self.tabBarController.tabBar .items objectAtIndex:0] setBadgeValue:nil];
    }
    
    [self sendBadge:[NSString stringWithFormat:@"%d", unreadTotal]];
    
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



//接收通知，刷新聊天历史列表（去掉提示声音）
-(void)refreshTableView2{
    chatContactsArray = [ChatBuddyCRUD queryChatContactsList:MY_USER_NAME];
    //更新未读消息
    int unreadTotal = [ChatBuddyCRUD queryAllMsgTotal];
    if (unreadTotal>0 && unreadTotal<100) {
        [[self.tabBarController.tabBar .items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%d",unreadTotal]];
    }else if(unreadTotal>=100){
        [[self.tabBarController.tabBar .items objectAtIndex:0] setBadgeValue:@"99+"];
    }else if(unreadTotal==0){
        [[self.tabBarController.tabBar .items objectAtIndex:0] setBadgeValue:nil];
    }
    [self.tableView reloadData];
    
    [self sendBadge:[NSString stringWithFormat:@"%d", unreadTotal]];
}


//接收通知，刷新聊天历史列表
-(void)refreshTableView3:(NSNotification*)sender{
    NSDictionary *dict = (NSDictionary*)sender.object;
    NSString *JID = dict[@"JID"];
    
    BOOL isDND = [DndInfoCRUD queryOfRosterExtWithJid:JID];
    
    if(!isDND){
        NSString *soundPalyMark = [[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Sound_Play_Mark"];
        NSString *vibratePalyMark = [[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Vibrate_Play_Mark"];
        
        long currentTime = (long)[[NSDate date] timeIntervalSince1970];
        
        if ([soundPalyMark isEqualToString:@"play"]) {
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive){
                if(mFirstSound || currentTime - lastSoundPlayTime > 5000){
                    [JSMessageSoundEffect playMessageReceivedSound2];
                    lastSoundPlayTime = currentTime;
                    mFirstSound = NO;
                }
            }
        }
        
        
        if ([vibratePalyMark isEqualToString:@"play"]) {
            if(mFirstVibrate || currentTime - lastVibratePlayTime > 5000){
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                lastVibratePlayTime = currentTime;
                mFirstVibrate = NO;
            }
        }
    }
    
    chatContactsArray = [ChatBuddyCRUD queryChatContactsList:MY_USER_NAME];
    //更新未读消息
    int unreadTotal = [ChatBuddyCRUD queryAllMsgTotal];
    if (unreadTotal>0 && unreadTotal<100) {
        [[self.tabBarController.tabBar .items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%d",unreadTotal]];
    }else if(unreadTotal>=100){
        [[self.tabBarController.tabBar .items objectAtIndex:0] setBadgeValue:@"99+"];
    }else if(unreadTotal==0){
        [[self.tabBarController.tabBar .items objectAtIndex:0] setBadgeValue:nil];
    }
    [self.tableView reloadData];
    
    [self sendBadge:[NSString stringWithFormat:@"%d", unreadTotal]];
}


-(void)refreshPersonalInformation{
    
    
}

-(void)refreshMyHeadImage{
    [self performSelector:@selector(refreshPersonalInformation) withObject:@"0" afterDelay:1];//1秒后执行
}

//更新未读消息
-(void)refreshAllMsgTotal{
    int unreadTotal = [ChatBuddyCRUD queryAllMsgTotal];
    if (unreadTotal>0 && unreadTotal<100) {
        [[self.tabBarController.tabBar .items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%d",unreadTotal]];
    }else if(unreadTotal>=100){
        [[self.tabBarController.tabBar .items objectAtIndex:0] setBadgeValue:@"99+"];
    }else if(unreadTotal==0){
        [[self.tabBarController.tabBar .items objectAtIndex:0] setBadgeValue:nil];
    }
}


//接收通知，刷新聊天历史列表圈子相关信息
-(void)refreshGroupInfo{
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    self.chatContactsArray = [ChatBuddyCRUD queryChatContactsList:MY_USER_NAME];
    [self.tableView reloadData];
}


//接收通知，更新聊天历史列表网络连接状态
-(void)updateNetworkStatusDisconnect{
    self.tableView .tableHeaderView = customView;
    [self.navigationItem setTitle:NSLocalizedString(@"chat.chat",@"title")];
}

//接收通知，更新聊天历史列表网络连接状态
-(void)updateNetworkStatusConnection{
    self.tableView .tableHeaderView = mySearchBar;
    //[self.navigationItem setTitle:NSLocalizedString(@"chat.chat",@"title")];
    
}

//接收通知，更新聊天历史列表服务器连接状态
-(void)updateServerStatusDisconnect{
    //self.tableView .tableHeaderView = customView2;
    //if ([self.navigationItem.title isEqualToString:NSLocalizedString(@"chat.chat",@"title")]) {
    [self titleBlink];
}


//title 闪烁效果
- (void)titleBlink {
    //检测网络情况
    NSString *network = [[NSUserDefaults standardUserDefaults] stringForKey:@"Network_Status"];
    if ([network isEqualToString:@"connection"]) {
        self.navigationItem.title = NSLocalizedString(@"chat.connection",@"title");
    }else{
        [self.navigationItem setTitle:NSLocalizedString(@"chat.chat",@"title")];
    }
}



//接收通知，更新聊天历史列表服务器连接状态
-(void)updateServerStatusConnection{
    //停止timer
    //self.tableView .tableHeaderView = mySearchBar;
    
    NSTimer *updConnectionTitleTimer;
    int timeInt = 0;
    updConnectionTitleTimer=[NSTimer scheduledTimerWithTimeInterval:timeInt
                                                             target:self
                                                           selector:@selector(updateServerStatusConnectionTitle)
                                                           userInfo:nil
                                                            repeats:NO];
}
//接收通知，更新聊天历史列表服务器连接状态
-(void)updateServerStatusConnectionTitle{
    self.navigationItem.title = NSLocalizedString(@"chat.chat",@"title");
    
    //    [titleTimer invalidate];
    //    titleTimer = nil;
    //    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0 , 100, 44)];
    //    titleLabel.textColor = [UIColor whiteColor];
    //    titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
    //    titleLabel.font = [UIFont boldSystemFontOfSize:18];  //设置文本字体与大小
    //    titleLabel.textAlignment = NSTextAlignmentCenter;
    //    titleLabel.text = @"聊天";
    //    self.navigationItem.titleView = titleLabel;
    //    [titleLabel release];
    
}


//接收通知，更新聊天历史列表登录网络超时
-(void)updateNetworkStatusTimeout{
    // self.tableView .tableHeaderView = customView;
    [self.navigationItem setTitle:NSLocalizedString(@"public.alert.networkTimeOut",@"title")];
    ;
}

//图文混排

-(void)getImageRange:(NSString*)message : (NSMutableArray*)array {
    NSRange range=[message rangeOfString: CHAT_BEGIN_FLAG];
    NSRange range1=[message rangeOfString: CHAT_END_FLAG];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0) {
        if (range.location > 0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else {
                return;
            }
        }
        
    } else if (message != nil) {
        [array addObject:message];
    }
}

/*---快捷菜单start-------------------------------------------------------------------------------------------*/
- (void)showMenu:(UIBarButtonItem *)sender
{
    if (!mRightBarButtonSelected) {
        
        mRightBarButtonSelected = YES;
        
        NSArray *menuItems =
        @[
          
          
          [KxMenuItem menuItem:@"发起群聊"
                         image:[UIImage imageNamed:@"check_icon"]
                        target:self
                        action:@selector(createGroup)],
          
          [KxMenuItem menuItem:@"添加好友"
                         image:[UIImage imageNamed:@"action_icon"]
                        target:self
                        action:@selector(toAddFriendVC)],
          
          [KxMenuItem menuItem:@"扫一扫"
                         image:[UIImage imageNamed:@"reload"]
                        target:self
                        action:@selector(ScanQRCode:)],
          
          //          [KxMenuItem menuItem:@"PDF"
          //                         image:[UIImage imageNamed:@"openPDF"]
          //                        target:self
          //                        action:@selector(openPDF:)],
          //
          ];
        
        KxMenuItem *first = menuItems[0];
        first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
        first.alignment = NSTextAlignmentCenter;
        
        [KxMenu showMenuInView:self.view
                      fromRect:CGRectMake(KCurrWidth-25, 0, 0, 0)
                     menuItems:menuItems];
    }else {
        
        [self dismissMenu];
    }
    
    
}

//上传声音数据到资源服务器
-(void) uploadDocument:(NSMutableData *)data
{
    NSString *urlstr = ResourcesURL;
    NSURL *myurl = [NSURL URLWithString:urlstr];
    ASIFormDataRequest  *request = [ASIFormDataRequest requestWithURL:myurl];
    //设置表单提交项
    [request setPostBody:data];
    //[request setPostValue:data forKey:@""];
    //[request setFile: amrPath forKey: @"this_is_file"];
    //[request setPostValue:username.text forKey:@"password"];
    //[request setDelegate:self];
    [request buildRequestHeaders];
    //[request setDidFinishSelector:@selector(GetVoiceResult:)];
    //[request setDidFailSelector:@selector(GetErr:)];
    
    //使用block 否则退出再进入时会造成崩溃
    request.completionBlock = ^{
        NSData *jsonData = [request responseData];
        //输出接收到的字符串
        NSDictionary *d = [jsonData objectFromJSONData];
        
        AIQLPreviewController *controller = [[AIQLPreviewController alloc] init];
        controller.docKey = d[@"TFS_FILE_NAME"];
        controller.docType = @"doc";
        controller.docName = @"测试文档测试文档测试文档测试文档";
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    };
    
    [request setFailedBlock:^{
    }];
    
    [request startAsynchronous];
}

-(void)openPDF:(id)sender
{
    //NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample" ofType:@"doc"]];
    //[self uploadDocument:(NSMutableData *) [NSData dataWithContentsOfURL:url]];
    //    AIQLPreviewController *controller = [[AIQLPreviewController alloc] init];
    //    controller.docKey = @"T1StJTByJT1RCvBVdK";
    //    controller.docType = @"jpg";
    //    controller.docName = @"测试文档测试文档测试文档测试文档";
    //    controller.hidesBottomBarWhenPushed = YES;
    //    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark -UIAlearView delegate
//添加好友
-(void)addFriendsAlerview{
    UIAlertView* addFriendsAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"contacts.addContacts.addContact",@"title")
                                                              message:NSLocalizedString(@"contacts.addContacts.enterUserID",@"title")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"contacts.addContacts.cancel",@"action")
                                                    otherButtonTitles:NSLocalizedString(@"contacts.addContacts.add",@"action"), nil];
    addFriendsAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    addFriendsAlert.tag=30000;
    [addFriendsAlert show];
}

//发起群聊
-(void)createGroup{
    
    [self dismissMenu];
    
    GroupCreateViewController *groupCreateVC=[[GroupCreateViewController alloc]init];
    groupCreateVC.hidesBottomBarWhenPushed=YES;
    groupCreateVC.title =  NSLocalizedString(@"contacts.inviteFridend.urlToInvite",@"title");
    [self.navigationController pushViewController:groupCreateVC animated:YES];
}

- (void)dismissSearchViewController {
    if (searchDisplayController.active) {
        [searchDisplayController setActive:NO animated:NO];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self dismissMenu];
    [self dismissSearchViewController];
}

//跳转到新增好友界面
-(void)toAddFriendVC{
    
    [self dismissMenu];
    
    AddFriendVCTableViewController* addFriendVC = [[AddFriendVCTableViewController alloc]init];
    //    UINavigationController* navigationVC = [[UINavigationController alloc]initWithRootViewController:addFriendVC];
    //    [self presentViewController:navigationVC animated:YES completion:nil];
    addFriendVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addFriendVC animated:YES];
    
}


- (void) ScanQRCode:(id)sender
{
    [self dismissMenu];
    
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:@"请真机运行！！！" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [myAlert addButtonWithTitle:NSLocalizedString(@"public.alert.ok",@"message")];
        [myAlert show];
        
    }
    
    ScanViewController *scanVC=[[ScanViewController alloc]init];
    scanVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:scanVC animated:YES];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==30000) {
        if (buttonIndex==1) {
            UITextField *tf = [alertView textFieldAtIndex:0];
            [tf setKeyboardType:UIKeyboardTypeNumberPad];  //调用键盘格式
            if ([tf.text isEqual:@""]) {
                return;
            }
            unichar single=[tf.text characterAtIndex:0];
            if (single >='0' && single<='9'){
                [DejalBezelActivityView activityViewForView:self.view];
                /*判断用户是否存在*/
                NSString *url=[NSString stringWithFormat:@"%@/security-question?username=%@",httpRequset,tf.text];
                
                [[NSUserDefaults standardUserDefaults] setObject:tf.text forKey:@"txtid"];
                NSError *error;
                //加载一个NSURL对象
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                //将请求的url数据放到NSData对象中
                NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                if (response==nil) {
                    [DejalBezelActivityView removeViewAnimated:YES];
                    //网络未连接
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"contacts.addContacts.error",@"title") message:NSLocalizedString(@"contacts.addContacts.pleaseCheckTheNetwork",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"contacts.addContacts.ok",@"action") otherButtonTitles:nil, nil];
                    [alert show];
                    
                    
                }else{
                    
                    //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
                    NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
                    NSString *nameInfo = [weatherDic objectForKey:@"msg"];
                    //code=8 用户不存在
                    int code = [[weatherDic objectForKey:@"code"] intValue];
                    if (code==8) {
                        [DejalBezelActivityView removeViewAnimated:YES];
                        
                        UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"contacts.addContacts.prompt",@"title") message:nameInfo delegate:self cancelButtonTitle:NSLocalizedString(@"contacts.addContacts.ok",@"action") otherButtonTitles:nil, nil];
                        [alerView show];
                        return;
                    }else{
                        NSString * jid = [NSString stringWithFormat:@"%@@%@",tf.text,OpenFireHostName];
                        [ChatInit queryContactsUserInfo:jid];
                    }
                }
            }else{
                UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"contacts.addContacts.prompt",@"title") message:NSLocalizedString(@"contacts.addContacts.accountNumberFormatError",@"message")delegate:self cancelButtonTitle:NSLocalizedString(@"contacts.addContacts.ok",@"action") otherButtonTitles:nil, nil];
                [alerView show];
            }
        }
        
    }
    [self.tableView reloadData];
}


/*---快捷菜单end------------------------------------------------------------------------------------------------*/


/*---网络监测start----------------------------------------------------------------------------------------------*/
- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    NetworkStatus status = [curReach currentReachabilityStatus];
    NSLog(@"*****%@", curReach.currentReachabilityString);
    
    
    if(status ==NotReachable) {
        //向通知中心发送消息,提示聊天历史列表网络连接状态
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NNC_Network_Status_Disconnect" object:nil userInfo:nil];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"disconnect" forKey:@"Network_Status"];
        
        NSLog(@"监控发现网络断开连接...");
        [XMPPServer sharedServer].loginFlag=5;
        [[XMPPServer sharedServer] disconnect];
        
        //停止重连接任务
        [self deleteReloginTimer];
        
    }else{
        NSLog(@"connect with the internet successfully");
        
        [XMPPServer sharedServer].loginFlag = 3;
        networkType = curReach.currentReachabilityString;
        
        [self relogin];
        
    }
}

-(void)deleteReloginTimer{
    
    [[XMPPServer sharedServer].reLoginTimer invalidate];
    [XMPPServer sharedServer].reLoginTimer = nil;
}


//重新连接
-(void)loginTimer{
    
    loginTimer=[NSTimer scheduledTimerWithTimeInterval:10
                                                target:self
                                              selector:@selector(relogin)
                                              userInfo:nil
                                               repeats:NO];
    [self sendPingPacket:@"ping"];
    
}


//重新连接
-(void)relogin{
    //正在登录和注销登录时排除
    if ([XMPPServer sharedServer].loginFlag == 1) {
        NSLog(@"此时有连接正在登录");
        return;
    }
    
    //程序从内存中清除后的第一次登录排除
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"NSUD_RemoveApp"]) {
        NSLog(@"程序从内存中清除后的第一次登录排除:%d",[XMPPServer sharedServer].loginFlag);
        return;
    }
    
    //后台任务暂停时不再重连
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"NSUD_backgroundTaskStatus"]){
        NSLog(@"后台任务暂停时不再重连");
        return;
    }
    
    //已经登录不再重连
    if([XMPPServer sharedServer].loginFlag == 2){
        NSLog(@"已经登录不再重连");
        return;
    }
    
    [[XMPPServer sharedServer] disconnect];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults stringForKey:@"userName"];
    NSString *pass = [defaults stringForKey:@"password"];
    
    XMPPServer* xmppServer = [XMPPServer sharedServer];
    if (![xmppServer.xmppStream isConnected]) {
        if (userId&&pass) {
            JLLog_D(@"网络变更，断开连接，重新登录");
            if ([xmppServer connect]) {
            }
        }
    }
}

/*
 回复ping包
 */
-(void)sendPingPacket:(NSString*)pingId{
    //XMPPFramework主要是通过KissXML来生成XML文件
    //生成XML消息文档
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *ping = [NSXMLElement elementWithName:@"ping" xmlns:@"urn:xmpp:ping"];
    //消息id
    [iq addAttributeWithName:@"id" stringValue:pingId];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addChild:ping];
    //发送消息
    [[XMPPServer xmppStream] sendElement:iq];
}

- (void)userInfoReturn:(NSNotification *)notification {
    --_incorrectContactCount;
    
    UserInfo *userInfo = notification.userInfo[@"result"];
    if (!userInfo) {
        return;
    }
    
    [UserInfoCRUD addAnUserInfo:userInfo];
    [self refreshTableView:nil];
    
    if (_incorrectContactCount == 0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"AI_Contact_Info_Return"
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"Application_Start_Init_Data"
                                                      object:nil];
    }
}


// 连接改变
- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
}


-(void)startNotificationNetwork{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    reachability=[Reachability reachabilityWithHostName:@"www.apple.com"];
    [reachability startNotifier];
    
    /*
     Reachability * reach = [Reachability reachabilityWithHostname:@"www.apple.com"];
     reach.reachableBlock = ^(Reachability * reachability)
     {
     dispatch_async(dispatch_get_main_queue(), ^{
     NSLog (@"Block Says Reachable");
     });
     };
     
     reach.unreachableBlock = ^(Reachability * reachability)
     {
     dispatch_async(dispatch_get_main_queue(), ^{
     NSLog(@"Block Says Unreachable");
     });
     };
     
     [reach startNotifier];
     */
}
/*---网络监测end----------------------------------------------------------------------------------------------*/


//下拉刷新
-(void)handleData
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm:ss a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"refresh.text2",@"title"),[formatter stringFromDate:[NSDate date]]];
    //    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    // self.count++;
    //[self.countArr addObject:[NSString stringWithFormat:@"%d. %@, code4app.com",self.count,[formatter stringFromDate:[NSDate date]]]];
    
    [self dismissMenu];
    //    [self.refreshControl endRefreshing];
    [ChatInit sendIQInformationList];
    [self.tableView reloadData];
}

-(void)refreshView:(UIRefreshControl *)refresh
{
    if (refresh.refreshing) {
        refresh.attributedTitle = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"refresh.text",@"title")];
        [self performSelector:@selector(handleData) withObject:nil afterDelay:2];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self dismissMenu];
}

- (void)menuAutoRelease:(NSNotification *)n {
    
    mRightBarButtonSelected = NO;
}

- (void)dismissMenu {
    
    [KxMenu dismissMenu:YES complete:^{
        mRightBarButtonSelected = NO;
    }];
}


- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //self.searchingFetchedResultsController = nil;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [self.tableView insertSubview:self.searchDisplayController.searchBar aboveSubview:self.tableView];
    }
    return;
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



@end
