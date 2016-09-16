

#import "ChatViewController.h"

#import "ChatCustomCell.h"
//#import "AppDelegate.h"
#import "ChatStatic.h"
#import "Header.h"
#import "XMPPHelper.h"

#import "Photo.h"

#import <ImageIO/ImageIO.h>


#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "GBPathImageView.h"

#import "Utility.h"
#import "JSONKit.h"

#import "ChatBuddyCRUD.h"
#import "ChatMessageCRUD.h"

#import "User.h"
#import "CHAppDelegate.h"



#define TOOLBARTAG		200
#define TABLEVIEWTAG	300


#define BEGIN_FLAG @"[/"
#define END_FLAG @"]"

@interface ChatViewController (Private)

- (void)bounceOutAnimationStopped;
- (void)bounceInAnimationStopped;

@end

@implementation ChatViewController

@synthesize titleString = _titleString;
@synthesize chatArray = _chatArray;
@synthesize tempChatArray=_tempChatArray;
@synthesize beforeChatArray=_beforeChatArray;
@synthesize chatTableView = _chatTableView;
@synthesize messageTextField = _messageTextField;
@synthesize messageToolbar = _messageToolbar;
@synthesize voiceToolbar = _voiceToolbar;
@synthesize hideTextField = _hideTextField;
@synthesize phraseViewController = _phraseViewController;
//@synthesize udpSocket = _udpSocket;
@synthesize messageString = _messageString;
@synthesize phraseString = _phraseString;
@synthesize lastTime = _lastTime;
@synthesize chatWithUser = _chatWithUser;
@synthesize chatWithJID = _chatWithJID;
@synthesize chatBuddyFlag = _chatBuddyFlag;
@synthesize messages = _messages;
@synthesize myPhoto;
@synthesize buddyPhoto;
@synthesize refreshing=_refreshing;
@synthesize pageSize=_pageSize;
@synthesize start=_start;
@synthesize total=_total;
@synthesize msgButArray=_msgButArray;

@synthesize messgaeFlag = _messgaeFlag;

@synthesize playMode = _playMode;
@synthesize deleteIndexPath=_deleteIndexPath;

@synthesize myUserName;

NSString *UPLOAD_PATH=@"";


#pragma mark - life circle
-(void)loadView{
    [super loadView];
    myUserName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];

    //初始化分页
    _pageSize =5;
    _start =0;
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
    [self openDataBase];
    _total =[self queryTableCount:userName];
    
    
    CGRect bounds = self.view.bounds;
    //bounds.size.height -= 80.f;
    //bounds.origin.y = 44.f;
    _chatTableView = [[PullingRefreshTableView alloc] initWithFrame:bounds pullingDelegate:self];
    _chatTableView.dataSource = self;
    _chatTableView.delegate = self;
    _chatTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    // _chatTableView.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.2 alpha:1];
    
    
    [self.view addSubview:_chatTableView];
    self.chatTableView.tag = TABLEVIEWTAG;
    _chatTableView.headerOnly = YES;
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        NSLog(@"ios7");
       // self.edgesForExtendedLayout=UIRectEdgeNone;
       // self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;

    }
    
}

- (UIStatusBarStyle)preferredStatusBarStyle

{
    
    return UIStatusBarStyleLightContent;
    
}

- (BOOL)prefersStatusBarHidden

{
    
    return NO;
    
}
-(void)tapBackground //在ViewDidLoad中调用
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnce)];//定义一个手势
    [tap setNumberOfTouchesRequired:1];//触击次数这里设为1
    [self.view addGestureRecognizer:tap];//添加手势到View中
}

-(void)tapOnce//手势方法
{
    [self.messageTextField resignFirstResponder];
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    [self tapBackground];
    _messageTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
 
    self.voiceToolbar.hidden=YES;
    
    
    // self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainViewBg.png"]];
    
    self.messages = [NSMutableArray array];
    //    [_messageTextField becomeFirstResponder];
    
    
    //设置信息代理
    [XMPPServer sharedServer].messageDelegate = self;
    
    //创建一个导航栏
    UINavigationBar *navigationBar = nil;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        navigationBar= [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
        self.chatTableView.frame = CGRectMake(0, 64, 320, viewHight-64-44);
    }else{
        navigationBar= [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        self.chatTableView.frame = CGRectMake(0, 44, 320, viewHight-64-44);
    }
    
    //创建个导航栏集合
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:nil];
    //创建一个左边按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"   style:UIBarButtonItemStyleDone       target:self action:@selector(clickLeftButton)];
    //设置导航栏内容
    [navigationItem setTitle:_chatWithNick];
    [navigationItem setLeftBarButtonItem:leftButton];
  
    //把导航栏集合添加入导航栏中，设置动画关闭
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    //    navigationBar.tintColor = [UIColor underPageBackgroundColor];
    //设置navigationbar为半透明状
    navigationBar.barStyle = UIBarStyleBlack;
    navigationBar.backgroundColor = [UIColor blackColor];


    //navigationBar.translucent = YES;
   // navigationBar.barStyle = UIBarStyleBlack;
    [self.view addSubview:navigationBar];
    
    UIImage *image = [UIImage imageNamed:@"backitem.png"];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [backBtn setBackgroundImage:image forState:UIControlStateNormal];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:backBtn ];
    self.navigationItem.leftBarButtonItem = backItem;
    //[backItem release];
    
    
    
   	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.chatArray = tempArray;
	//[tempArray release];
	self.tempChatArray = [[NSMutableArray alloc] init];
    self.beforeChatArray = [[NSMutableArray alloc] init];
    
    
    
    NSMutableString *tempStr = [[NSMutableString alloc] initWithFormat:@""];
    self.messageString = tempStr;
   // [tempStr release];
    
	NSDate   *tempDate = [[NSDate alloc] init];
	self.lastTime = tempDate;
	//[tempDate release];
    
    
    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }else{
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
    }
    
    
    _shareMoreView =[[WCChatSelectionView alloc]init];
    [_shareMoreView setFrame:CGRectMake(0, 0, 320, 170)];
    [_shareMoreView setDelegate:self];
    
    
    //语音功能
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(myButtonLongPressed:)];
    // you can control how many seconds before the gesture is recognized
    gesture.minimumPressDuration =0;
    [self.touchbutton addGestureRecognizer:gesture];
    
    
    //加载历史聊天纪录。
    [self openDataBase];
   [self receiveBeforeMessage:_start total:_pageSize];
    
    
    //弹出菜单
    // popupMenu2
    QBPopupMenu *popupMenu1 = [[QBPopupMenu alloc] init];
    QBPopupMenu *popupMenu2 = [[QBPopupMenu alloc] init];
    QBPopupMenu *popupMenu3 = [[QBPopupMenu alloc] init];
    
    QBPopupMenuItem *item1 = [QBPopupMenuItem itemWithTitle:@"切换至听筒" target:self action:@selector(changeVoicePlayMode:)];
    QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:@"切换至扬声器" target:self action:@selector(changeVoicePlayMode2:)];
    
    
    QBPopupMenuItem *item3 = [QBPopupMenuItem itemWithTitle:@"收藏" target:nil action:NULL];
    item3.enabled = NO;
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
    customView.backgroundColor = [UIColor clearColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(6, 6, 68, 38);
    [button setTitle:@"Button" forState:UIControlStateNormal];
    [customView addSubview:button];
    
    // QBPopupMenuItem *item6 = [QBPopupMenuItem itemWithCustomView:customView target:nil action:NULL];
    QBPopupMenuItem *item4 = [QBPopupMenuItem itemWithTitle:@"删除" target:self action:@selector(deleteCellFromTableView)];
    
    // item4.enabled = NO;
    item4.title = @"删除";
    
 //   [customView release];
    
    popupMenu1.items = [NSArray arrayWithObjects:item1, item3,item4,nil];
    popupMenu3.items = [NSArray arrayWithObjects: item3, item4, nil];
    
    
    self.popupMenu = popupMenu1;
    self.popupMenu3 = popupMenu3;
    
//    [popupMenu release];
//    [popupMenu2 release];
//    [popupMenu3 release];
    
    //查询是否已存在聊天列表
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults stringForKey:@"userName"];
    NSString *myJID = [NSString stringWithFormat:@"%@@%@",userName, OpenFireHostName];

    if ([ChatBuddyCRUD queryChatBuddyTableCountId:self.chatWithJID myJID:myJID]>0){
        
        self.chatBuddyFlag = YES;
    }
   
    
}



//删除
-(IBAction)deleteCellFromTableView{
    int index = self.deleteIndexPath.row;
    
    NSLog(@"*****%d",index);
    
    NSDictionary *item = [self.chatArray objectAtIndex:index];

    NSString *msgId = [item objectForKey:@"msgId"];
  

    [self openDataBase];

    if (index>0) {
        if ([[self.chatArray objectAtIndex:index-1] isKindOfClass:[NSDate class]]) {
            
            [self deleteTable:msgId];
            [self.chatArray removeObjectAtIndex:index-1];
            [self.chatArray removeObjectAtIndex:index-1];
            
        }else{
            
            [self deleteTable:msgId];
            [self.chatArray removeObjectAtIndex:index];
        }
    }else{
        [self deleteTable:msgId];
        [self.chatArray removeObjectAtIndex:index];
    }
       [self.chatTableView reloadData];
}

-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gesture locationInView:self.chatTableView];
        NSIndexPath * indexPath = [self.chatTableView indexPathForRowAtPoint:point];
        //删除时所用
        self.deleteIndexPath = indexPath;
        
        if(indexPath == nil) return ;
        //add your code here
        NSLog(@"*****%@",indexPath);
        
        [self showPopupMenu3:indexPath];
    }
}

- (void)showPopupMenu2:(UIButton *) btn {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    
    
    
    UITableViewCell* cell = [self.chatTableView cellForRowAtIndexPath:indexPath];
    
    CGRect rectInTableView = [self.chatTableView rectForRowAtIndexPath:indexPath];
    
    
    CGRect rect = [self.chatTableView convertRect:rectInTableView toView:[self.chatTableView superview]];
    
    [self.popupMenu2 showInView:self.view atPoint:CGPointMake(cell.center.x, rect.origin.y
                                                              )];
    
}


-(IBAction)changeVoicePlayMode:(id)sender{
    
    self.playMode=@"Play";
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:@"切换至扬声器" target:self action:@selector(changeVoicePlayMode2:)];
    QBPopupMenuItem *item3 = [QBPopupMenuItem itemWithTitle:@"收藏" target:nil action:NULL];
    QBPopupMenuItem *item4 = [QBPopupMenuItem itemWithTitle:@"删除" target:self action:@selector(deleteCellFromTableView:)];
    QBPopupMenu *popupMenu = [[QBPopupMenu alloc] init];
    popupMenu.items = [NSArray arrayWithObjects:item2, item3,item4,nil];
    self.popupMenu = popupMenu;
    [self.chatTableView flashMessage2:@"已切换为听筒模式"];
    
}

-(IBAction)changeVoicePlayMode2:(id)sender{
    self.playMode=@"Playback";
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    QBPopupMenuItem *item1 = [QBPopupMenuItem itemWithTitle:@"切换至听筒" target:self action:@selector(changeVoicePlayMode:)];
    QBPopupMenuItem *item3 = [QBPopupMenuItem itemWithTitle:@"收藏" target:nil action:NULL];
    QBPopupMenuItem *item4 = [QBPopupMenuItem itemWithTitle:@"删除" target:self action:@selector(deleteCellFromTableView:)];
    QBPopupMenu *popupMenu = [[QBPopupMenu alloc] init];
    popupMenu.items = [NSArray arrayWithObjects:item1, item3,item4,nil];
    self.popupMenu = popupMenu;
    [self.chatTableView flashMessage2:@"已切换为扬声器模式"];
}

- (void)showPopupMenu3:(NSIndexPath *) indexPath {
    
    NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
    NSString *type = [chatInfo objectForKey:@"type"];
    NSLog(@"******%@",type);
    
    UITableViewCell* cell = [self.chatTableView cellForRowAtIndexPath:indexPath];
    CGRect rectInTableView = [self.chatTableView rectForRowAtIndexPath:indexPath];
    CGRect rect = [self.chatTableView convertRect:rectInTableView toView:[self.chatTableView superview]];
    
    if ([type isEqualToString:@"voice"]) {
        [self.popupMenu showInView:self.chatTableView atPoint:CGPointMake(cell.center.x, rect.origin.y
                                                                 )];
    }else if([type isEqualToString:@"text"]){
        [self.popupMenu3 showInView:self.view atPoint:CGPointMake(cell.center.x, rect.origin.y
                                                                  )];
    }else if([type isEqualToString:@"image"]){
        [self.popupMenu3 showInView:self.view atPoint:CGPointMake(cell.center.x, rect.origin.y
                                                                  )];
    }
    
    
}



- (void)reply:(id)sender
{
    NSLog(@"*** reply: %@", [sender class]);
}



-(void) dismissSelf{
    [self dismissModalViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];
    
    CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.tabBarBG.hidden=YES;

	
	[self.messageTextField setText:self.messageString];
	[self.chatTableView reloadData];
    
    _messgaeFlag=@"UpdateMessageFlag";
}


-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
    CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.tabBarBG.hidden=NO;
    
    
    
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}


- (void)dealloc {
//	[_lastTime release];
//	[_phraseString release];
//	[_messageString release];
	//[_udpSocket release];
//	[_phraseViewController release];
//	[_messageTextField release];
//    [_messageToolbar release];
//    [_voiceToolbar release];
//	[_chatArray release];
//	[_titleString release];
//	[_chatTableView release];
 //   [_popupMenu2 release];
    
  //  [super dealloc];
}

//发送消息
-(IBAction)sendMessage_Click:(id)sender
{
   	NSString *messageStr = self.messageTextField.text;
    NSLog(@"发送消息%@",messageStr);
    self.messageString = self.messageTextField.text;
    if (messageStr == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送失败1！" message:@"发送的内容不能为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
     //   [alert release];
    }else
    {
        [self sendMassage:messageStr];
    }
	self.messageTextField.text = @"";
    self.messageString = self.messageTextField.text;
	[_messageTextField resignFirstResponder];
    
}
//发送文本消息
-(void)sendMassage:(NSString *)message
{
    NSLog(@"发送消息@%@",message);
	NSDate *nowTime = [NSDate date];
	NSMutableString *sendString=[NSMutableString stringWithCapacity:100];
	[sendString appendString:message];
    
    NSString *timeString=Utility.getCurrentDate;
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
    
	//开始发送
    
    if (message.length > 0) {
        
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_chatWithJID];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:userName];
        //发送时间
        [mes addAttributeWithName:@"time" stringValue:timeString];
        //组合
        
        //组合
        [mes addChild:body];
        
        NSLog(@"%@",mes);
        
        //发送消息
        [[XMPPServer xmppStream] sendElement:mes];
        
        self.messageTextField.text = @"";
        [self.messageTextField resignFirstResponder];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        [dictionary setObject:message forKey:@"msg"];
        [dictionary setObject:@"me" forKey:@"sender"];
        //加入发送时间
        [dictionary setObject:[ChatStatic getCurrentTime] forKey:@"time"];
        
        [self.messages addObject:dictionary];
        
        //重新刷新tableView
        [self.tView reloadData];
	}
	
	if ([self.chatArray lastObject] == nil) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
        
        
	}
	// 发送后生成泡泡显示出来
	NSTimeInterval timeInterval = [nowTime timeIntervalSinceDate:self.lastTime];
	if (timeInterval >60) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
        
        
	}
    
    
    [self insertTable:userName sencond:message third:_chatWithUser msgType:@"chat" subject:@"text" sendTime:timeString];
    [self updateTable:userName];
    NSString *msgId = [self queryIdByUserName:userName chatWithUser:_chatWithUser];
    
    
    UIView *chatView = [self bubbleView:message from:YES type:@"chat" subject:@"text" historyFlag:NO];
	[self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", message, @"text", @"self", @"speaker",@"text",@"type", chatView, @"view", nil]];
    
	
	[self.chatTableView reloadData];
	[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
							  atScrollPosition: UITableViewScrollPositionBottom
									  animated:YES];
    
    
    NSLog(@"播放提示音%@",msgId);
    AudioServicesPlaySystemSound(1105);
    
    
    //查询聊天列表是否存在
    if(self.chatBuddyFlag == NO){
        //NSString * myJID =  [NSString stringWithFormat:@"%@@%@",myUserName, OpenFireHostName];
        User *user = [[User alloc]init];
        user = [ChatBuddyCRUD queryBuddyByJID:_chatWithUser myJID:myUserName];
        [ChatBuddyCRUD insertChatBuddyTable:user.userName name:user.name nickName:user.nickName phone:user.phone avatar:user.avatar myUserName:myUserName type:@"text"];
        self.chatBuddyFlag = YES;
    }
    
    //更新消息状态
    [ChatMessageCRUD updateFlagByUserName:myUserName];

    
}



//发送语音
-(void)sendMassage2:(NSString *)message type:(NSString *)msgType subject:(NSString *)subjectStr
{
    NSLog(@"发送语音消息@");
    
	NSDate *nowTime = [NSDate date];
	
	NSMutableString *sendString=[NSMutableString stringWithCapacity:100];
	[sendString appendString:message];
    
    NSString *timeString=Utility.getCurrentDate;
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
    
	//开始发送
    
    if (message.length > 0) {
        
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        //生成<subject>文档
        NSXMLElement *subject = [NSXMLElement elementWithName:@"subject"];
        [subject setStringValue:subjectStr];
        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:msgType];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_chatWithJID];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:userName];
        //发送时间
        [mes addAttributeWithName:@"time" stringValue:timeString];
        //组合
        [mes addChild:subject];
        [mes addChild:body];
        
        // NSLog(@"%@",mes);
        //发送消息
        [[XMPPServer xmppStream] sendElement:mes];
        self.messageTextField.text = @"";
        [self.messageTextField resignFirstResponder];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        [dictionary setObject:message forKey:@"msg"];
        [dictionary setObject:@"me" forKey:@"sender"];
        //加入发送时间
        [dictionary setObject:[ChatStatic getCurrentTime] forKey:@"time"];
        
        [self.messages addObject:dictionary];
        
        //重新刷新tableView
        [self.tView reloadData];
        //  }
        
        // return;
        
    }
	
	if ([self.chatArray lastObject] == nil) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
        
        
	}
	// 发送后生成泡泡显示出来
	NSTimeInterval timeInterval = [nowTime timeIntervalSinceDate:self.lastTime];
	if (timeInterval >60) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
        
	}
    
    [self insertTable:userName sencond:message third:_chatWithUser  msgType:@"chat" subject:@"voice" sendTime:timeString];
    [self updateTable:userName];
    NSString *msgId = [self queryIdByUserName:userName chatWithUser:_chatWithUser];
    UIView *chatView = [self bubbleView:message from:YES type:msgType subject:subjectStr historyFlag:NO];
	[self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", message, @"text", @"self", @"speaker",@"voice",@"type", chatView, @"view", nil]];
    
	
	[self.chatTableView reloadData];
	[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
							  atScrollPosition: UITableViewScrollPositionBottom
									  animated:YES];
    
    NSLog(@"播放提示音");
    AudioServicesPlaySystemSound(1105);
}


//选择系统表情
-(IBAction)showPhraseInfo:(id)sender
{
    self.messageString =[NSMutableString stringWithFormat:@"%@",self.messageTextField.text];
	[self.messageTextField resignFirstResponder];
	if (self.phraseViewController == nil) {
		FaceViewController *temp = [[FaceViewController alloc] initWithNibName:@"FaceViewController" bundle:nil];
		self.phraseViewController = temp;
		//[temp release];
	}
	[self presentModalViewController:self.phraseViewController animated:YES];
}



- (IBAction)clickAddBtn:(id)sender {
    _shareMoreView.hidden = NO;
    [_messageTextField setInputView: _messageTextField.inputView?nil: _shareMoreView];
    
    [_messageTextField reloadInputViews];
    [_messageTextField becomeFirstResponder];
    
}

- (IBAction)clickMessageTextField:(id)sender {
    NSLog(@"messageText");
    // _shareMoreView.hidden = YES;
    [_messageTextField setInputView: _shareMoreView?nil:_messageTextField.inputView];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        [_messageTextField reloadInputViews];
    }
    _shareMoreView.hidden = YES;
    // [_messageTextField becomeFirstResponder];
}


/*
 生成泡泡UIView
 */
#pragma mark -
#pragma mark Table view methods
- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf type:(NSString *)type subject:(NSString *)subject historyFlag:(BOOL *)historyFlag{
	// build single chat bubble cell with given text
    
    
     NSLog(@"#####%@",type);
    UIView *returnView =  [self assembleMessageAtIndex:text from:fromSelf type:
                           type subject:subject historyFlag:historyFlag];
    
   
    
    
    returnView.backgroundColor = [UIColor clearColor];
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"bubbleSelf":@"bubble" ofType:@"png"]];
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:20 topCapHeight:14]];
    
    UIImageView *headImageView = [[UIImageView alloc] init];
    
    if(fromSelf){
        if (self.myPhoto == NULL) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *userName = [defaults stringForKey:@"userName"];
            NSLog(@"userId%@",userName);
            XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@"OpenFireHostName,userName]];
            self.myPhoto = [XMPPHelper xmppUserPhotoForJID:jid];
            NSLog(@"*******************%@",jid);
        }
        
        if (self.myPhoto == NULL) {
            GBPathImageView *squareImage = [[GBPathImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 50.0, 50.0) image:[UIImage imageNamed:@"defaultUser.png"] pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor whiteColor] pathWidth:1.0];
            
            headImageView = squareImage;
            
        }else{
            GBPathImageView *squareImage = [[GBPathImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 50.0, 50.0) image:myPhoto pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor whiteColor] pathWidth:0.0];
            // [headImageView setImage:myPhoto];
            headImageView = squareImage;
            
            
        }
        
        returnView.frame= CGRectMake(9.0f, 15.0f, returnView.frame.size.width, returnView.frame.size.height+12);
        
        //发送语音时
        if([type isEqualToString:@"voice"]){
            // UIImage *voiceImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"voice" ofType:@"png"]];
            // UIImageView *voiceImageView = [[UIImageView alloc] initWithImage:[voiceImage stretchableImageWithLeftCapWidth:20 topCapHeight:14]];
            //  voiceImageView.frame = CGRectMake(0.0f, 14.0f, 24.0f, 24.0f);
            UILabel * voiceLabel = [[UILabel alloc]init];
            //  voiceLabel.frame = CGRectMake(5.0f, -3.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height);
            voiceLabel.frame = CGRectMake(5.0f, 3.0f, 20, 20);
            voiceLabel.text =@"(((";
            voiceLabel.backgroundColor = [UIColor clearColor];
            
            bubbleImageView.frame = CGRectMake(0.0f, 14.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height);
            [bubbleImageView addSubview:voiceLabel];
            
        }else{
            
            bubbleImageView.frame = CGRectMake(0.0f, 14.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height+24.0f );
        }
        
        cellView.frame = CGRectMake(265.0f-bubbleImageView.frame.size.width, 0.0f,bubbleImageView.frame.size.width+50.0f, bubbleImageView.frame.size.height+30.0f);
        headImageView.frame = CGRectMake(bubbleImageView.frame.size.width, cellView.frame.size.height-50.0f, 50.0f, 50.0f);
    }
	else{
        NSLog(@"好友来消息了：%@",_chatWithUser);
        if (self.buddyPhoto == NULL) {
            XMPPJID *jid = [XMPPJID jidWithString:_chatWithJID];
            self.buddyPhoto = [XMPPHelper xmppUserPhotoForJID:jid];
            //   NSLog(@"*******************%@",self.mePhoto);
        }
        if (self.buddyPhoto == NULL) {
            GBPathImageView *squareImage = [[GBPathImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0) image:[UIImage imageNamed:@"defaultUser.png"] pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor whiteColor] pathWidth:0.0];
            
            
            // [headImageView setImage:[UIImage imageNamed:@"defaultuser.jpg"]];
            headImageView = squareImage;
            ;
            
        }else{
            GBPathImageView *squareImage = [[GBPathImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0) image:buddyPhoto pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor whiteColor] pathWidth:0.0];
            
            // [headImageView setImage:buddyPhoto];
            headImageView = squareImage;
            
            
        }
        
        
        returnView.frame= CGRectMake(65.0f, 15.0f, returnView.frame.size.width, returnView.frame.size.height+12);
        //发送语音时
        if([type isEqualToString:@"voice"]){
            UILabel * voiceLabel = [[UILabel alloc]init];
            voiceLabel.frame = CGRectMake(returnView.frame.size.width+5, -5.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height);
            voiceLabel.text =@")))";
            
            bubbleImageView.frame = CGRectMake(50.0f, 14.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height);
            [bubbleImageView addSubview:voiceLabel];
        }else{
            
            
            
            bubbleImageView.frame = CGRectMake(50.0f, 14.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height+24.0f);
            
        }
        
        cellView.frame = CGRectMake(0.0f, 0.0f, bubbleImageView.frame.size.width+30.0f,bubbleImageView.frame.size.height+30.0f);
        headImageView.frame = CGRectMake(0.0f, cellView.frame.size.height-50.0f, 50.0f, 50.0f);
    }
    
    
    //长按事件
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPressGr.minimumPressDuration = 1.0;
    [cellView addGestureRecognizer:longPressGr];
   // [longPressGr release];
    
    
    
    [cellView addSubview:bubbleImageView];
    [cellView addSubview:headImageView];
    [cellView addSubview:returnView];
    //[bubbleImageView release];
   // [returnView release];
   // [headImageView release];
	return cellView;
    
}


//- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
//{
//	//无法发送时,返回的异常提示信息
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//													message:[error description]
//												   delegate:self
//										  cancelButtonTitle:@"取消"
//										  otherButtonTitles:nil];
//	[alert show];
//	[alert release];
//	
//}
//- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
//{
//	//无法接收时，返回异常提示信息
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//													message:[error description]
//												   delegate:self
//										  cancelButtonTitle:@"取消"
//										  otherButtonTitles:nil];
//	[alert show];
//	[alert release];
//}

#pragma mark -
#pragma mark Table View DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chatArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]]) {
		return 30;
	}else {
		UIView *chatView = [[self.chatArray objectAtIndex:[indexPath row]] objectForKey:@"view"];
		return chatView.frame.size.height+10;
	}
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CommentCellIdentifier = @"CommentCell";
	ChatCustomCell *cell = (ChatCustomCell*)[tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier];
	if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"ChatCustomCell" owner:self options:nil] lastObject];
	}
	
    cell.backgroundColor = [UIColor clearColor];
    
	if ([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]]) {
		// Set up the cell...
		NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yy-MM-dd HH:mm"];
		NSMutableString *timeString = [NSMutableString stringWithFormat:@"%@",[formatter stringFromDate:[self.chatArray objectAtIndex:[indexPath row]]]];
		//[formatter release];
        
		[cell.dateLabel setText:timeString];
		
        
	}else {
		// Set up the cell...
		NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
        
        NSLog(@"######%@",chatInfo);
        
		UIView *chatView = [chatInfo objectForKey:@"view"];
		[cell.contentView addSubview:chatView];
	}
    return cell;
}


#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.messageTextField resignFirstResponder];
    // [self showPopupMenu3:indexPath];
    NSLog(@"@%d----%d",indexPath.section,indexPath.row);
}
#pragma mark -
#pragma mark TextField Delegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if(textField == self.messageTextField)
	{
		//[self. moveViewUp];
        
	}
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if(textField == self.messageTextField)
	{
        //	[self.messageTextField resignFirstResponder];
	}
    
}

//按回车键发送消息
-(IBAction)textFiledReturnEditing:(id)sender {
    NSString * text = _messageTextField.text;
    if (text == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送失败1！" message:@"发送的内容不能为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        //   [alert release];
    }else
    {
        [self sendMassage:text];
    }
    [_messageTextField resignFirstResponder];

    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

-(void) autoMovekeyBoard: (float) h{
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:TOOLBARTAG];
        toolbar.frame = CGRectMake(0.0f, (float)(viewHight-h-44.0), 320.0f, 44.0f);
        UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
        tableView.frame = CGRectMake(0.0f, 64.0f, 320.0f,(float)(viewHight-h-64-44.0));
        
        if (self.chatArray.count>0) {
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                             atScrollPosition: UITableViewScrollPositionBottom
                                     animated:NO];
        }
        
    }else{
        UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:TOOLBARTAG];
    	toolbar.frame = CGRectMake(0.0f, (float)(viewHight-h-64.0), 320.0f, 44.0f);
    	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
        tableView.frame = CGRectMake(0.0f, 44.0f, 320.0f,(float)(viewHight-h-64-44.0));
        if (self.chatArray.count>0) {
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                             atScrollPosition: UITableViewScrollPositionBottom
                                     animated:NO];
        }
    }
    
    
    
}


#pragma mark -
#pragma mark Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self autoMovekeyBoard:keyboardRect.size.height];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self autoMovekeyBoard:0];
}





//图文混排

-(void)getImageRange:(NSString*)message : (NSMutableArray*)array {
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
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

#define KFacialSizeWidth  18
#define KFacialSizeHeight 20
#define MAX_WIDTH 150

-(UIView *)assembleMessageAtIndex : (NSString *) message from:(BOOL)fromself type:(NSString *)type subject:(NSString *)subject historyFlag:(BOOL *)historyFlag
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSLog(@"**********%@",type);
    NSLog(@"**********%@",subject);

    
    [self getImageRange:message :array];
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    NSArray *data = array;
    UIFont *fon = [UIFont systemFontOfSize:13.0f];
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat X = 0;
    CGFloat Y = 0;
    if (data) {
        for (int i=0;i < [data count];i++) {
            NSString *s=[data objectAtIndex:i];
            
            //  NSLog(@"str--->%@",str);
            
            if ([s hasPrefix: BEGIN_FLAG] && [s hasSuffix: END_FLAG])
            {
                if (upX >= MAX_WIDTH)
                {
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                    X = 150;
                    Y = upY;
                }
                //    NSLog(@"str(image)---->%@",str);
                NSString *imageName=[s substringWithRange:NSMakeRange(2, s.length - 3)];
                UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
                img.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                [returnView addSubview:img];
               // [img release];
                upX=KFacialSizeWidth+upX;
                if (X<150) X = upX;
                
                
            } else {
                for (int j = 0; j < [s length]; j++) {
                    NSString *temp = [s substringWithRange:NSMakeRange(j, 1)];
                    if (upX >= MAX_WIDTH)
                    {
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                        X = 150;
                        Y =upY;
                    }
                    CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(150, 40)];
                    
//                    NSArray *arry=[str componentsSeparatedByString:@":"];
//                    NSString *s = [arry objectAtIndex:1];
                    
                    NSLog(@"---------------%@",type);
                    
                    
                    
                    if ([type isEqualToString:@"chat"]) {
                        
                      
                        
 
                        
                        
                        if ([subject isEqualToString:@"image"]) {
                            
                            if (historyFlag) {
                                UIImageView *imgv = [[UIImageView alloc]initWithFrame:CGRectMake(upX,upY+10,100,100)];
                                UIImage *img = [Photo string2Image:message];
                                imgv.image = img;
                                
                                [returnView addSubview:imgv];
                             //   [imgv release];
                            }else{
                                
                                NSLog(@"**********%@",s);
                                
                                NSString *imageJsonStr = s;
                                NSLog(@"imageJsonStr:%@",imageJsonStr);
                                NSDictionary *imageData = [imageJsonStr objectFromJSONString];
                                NSLog(@"imageJsonStr.link:%@",[imageData objectForKey:@"link"]);
                                NSLog(@"imageJsonStr.data:%@",[imageData objectForKey:@"data"]);

                              //  [imageJsonStr release];
            
                                UIImageView *imgv = [[UIImageView alloc]initWithFrame:CGRectMake(upX,upY+10,100,100)];
                                
                                UIImage *img = [Photo string2Image:[imageData objectForKey:@"data"]];
                                imgv.image = img;
                                
                                [returnView addSubview:imgv];
                              //  [imgv release];
                                
                            }
                            
                            X = 100;
                            Y = 100;
                            
                            break;
                            
                        }else if ([type isEqualToString:@"voice"]){
                            
                            //  NSData *voiceData = [s base64DecodedData];
                            
                            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn.tag = self.chatArray.count;
                            
                            NSLog(@"voice length:%d",btn.tag);
                            
                            Y =KFacialSizeHeight;
                            
                            if (s.length>100000 && s.length<=200000) {
                                X = 80;
                                btn.frame = CGRectMake(0,0,80,Y+5);
                            }else if(s.length>200000 && s.length<=300000){
                                X = 100;
                                btn.frame = CGRectMake(0,0,100,Y+5);
                            }else if(s.length>300000 && s.length<=400000){
                                X = 120;
                                btn.frame = CGRectMake(0,0,120,Y+5);
                            }else if(s.length>400000 && s.length<500000){
                                X = 150;
                                btn.frame = CGRectMake(0,0,150,Y+5);
                            }else if(s.length>500000){
                                X = 180;
                                btn.frame = CGRectMake(0,0,180,Y+5);
                            }else{
                                
                                X = 60;
                                btn.frame = CGRectMake(0,0,60,Y+5);
                                
                            }
                            
                            [btn  addTarget:self action:@selector(playRecording2:) forControlEvents:UIControlEventTouchUpInside];
                            //[btn  addTarget:self action:@selector(showPopupMenu2:) forControlEvents:UIControlEventTouchUpInside];
                            btn.backgroundColor = [UIColor clearColor];
                            
                            [self.msgButArray addObject:btn];
                            //btn.hidden = YES;
                            [returnView addSubview:btn];
                            break;
                            
                        }else{
                            
                            UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY+5,size.width,size.height)];
                            la.font = fon;
                            la.text = temp;
                            la.backgroundColor = [UIColor clearColor];
                            [returnView addSubview:la];
                          //  [la release];
                            upX=upX+size.width;
                            if (X<150) {
                                X = upX;
                            }
                            
                        }
                        
                    }else{
                        
                        UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY+5,size.width,size.height)];
                        la.font = fon;
                        la.text = temp;
                        la.backgroundColor = [UIColor clearColor];
                        [returnView addSubview:la];
                     //  [la release];
                        upX=upX+size.width;
                        if (X<150) {
                            X = upX;
                        }
                    }
                    
                    
                }
                
            }
        }
    }
    returnView.frame = CGRectMake(15.0f,1.0f, X, Y); //@ 需要将该view的尺寸记下，方便以后使用
    NSLog(@"%.1f %.1f", X, Y);
    return returnView;
}




//－－－－－－－－－－－消息接收－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)receiveMessage:(NSDictionary *)messageContent{
    
    //接收到数据，用泡泡VIEW显示出来
	//发送者
    NSString *sender = [messageContent objectForKey:@"sender"];
    NSString *info = [messageContent objectForKey:@"msg"];
    NSString *type = [messageContent objectForKey:@"type"];
    NSString  *subject = [messageContent objectForKey:@"subject"];
    //NSString  *time = [messageContent objectForKey:@"time"];
    NSString  *time = Utility.getCurrentDate;
    
    

    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yy-MM-dd HH:mm"];
    NSDate *sendDate= [dateFormatter dateFromString:Utility.getCurrentDate];
    NSLog(@"destDate = %@",sendDate);
    
    NSString *senderStr = nil;
    if (![sender isEqualToString:@"me"]) {
        NSString*str_character = @"@";
        NSRange senderRange = [sender rangeOfString:str_character];
          if ([sender rangeOfString:str_character].location != NSNotFound) {
        senderStr = [sender substringToIndex:senderRange.location];
          }
    }
    
    
    
    NSLog(@"截取出来的字符串str＝%@",senderStr);
    NSLog(@"接收到数据，用泡泡VIEW显示出来%@",_chatWithNick);
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults stringForKey:@"userName"];
    if ([_messgaeFlag isEqualToString:@"UpdateMessageFlag"]) {
        
        if ([subject isEqualToString:@"image"]){
          //  NSString *imageBodyJsonStr =  [[NSString stringWithFormat:@"%@%@%@",@"{\"data\":\"", info,@"\",\"src\":\"\",\"link\":\"no url\"}"] autorelease];

            
            NSString *imageJsonStr = info;
            NSLog(@"imageJsonStr:%@",imageJsonStr);
            NSDictionary *imageData = [imageJsonStr objectFromJSONString];
            
            NSLog(@"imageJsonStr.link:%@",[imageData objectForKey:@"link"]);
            NSLog(@"imageJsonStr.data:%@",[imageData objectForKey:@"data"]);
            
            
            // NSLog(@"imageJsonStr:%@",[imageData objectForKey:@"b"]);
         //   [imageJsonStr release];
             [self insertTable:senderStr sencond:[imageData objectForKey:@"data"] third:userName msgType:type subject:subject sendTime:time];
        }else{
             [self insertTable:senderStr sencond:info third:userName msgType:type subject:subject sendTime:time];
        }
       
    }
    
    
    if ([senderStr isEqualToString:_chatWithUser]) {
        NSString*msgId=0;
        NSString *selectSqlStr=[NSString stringWithFormat:@"select id, sendUser,message,flag,receiveUser,msgType ,subject,sendTime from ChatMessage where (sendUser=\"%@\" and receiveUser=\"%@\") or (sendUser=\"%@\" and receiveUser=\"%@\") order by id desc limit \"%d\",\"%d\"",_chatWithUser,userName,userName,_chatWithUser,0,1];
        
        const char *selectSql = [selectSqlStr UTF8String];
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
        {
            NSLog(@"select ok.");
            while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
            {
                
                int _id=sqlite3_column_int(statement, 0);
                msgId = [NSString stringWithFormat:@"%d",_id];
            }
        }
        
        
        
        // 发送后生成泡泡显示出来
        NSDate *nowTime = [NSDate date];
        if ([self.chatArray lastObject] == nil) {
            self.lastTime = nowTime;
            [self.chatArray addObject:sendDate];
            
            
        }
        NSTimeInterval timeInterval = [sendDate timeIntervalSinceDate:self.lastTime];
        if (timeInterval >60) {
            self.lastTime = nowTime;
            [self.chatArray addObject:sendDate];
            
        }
        
        
        
        UIView *chatView = [self bubbleView:info
                                       from:NO type:type subject:subject historyFlag:NO];
        
        [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", info, @"text", @"other", @"speaker",type,@"type",subject,@"subject", chatView, @"view", nil]];
        [self.chatTableView reloadData];
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                                  atScrollPosition: UITableViewScrollPositionBottom
                                          animated:YES];
        
        NSLog(@"更新标记%@",_messgaeFlag);
        if ([_messgaeFlag isEqualToString:@"UpdateMessageFlag"]) {
            
            [self updateTable:_chatWithUser];
            
            NSLog(@"播放提示音");
            AudioServicesPlaySystemSound(1109);
            
        }
        
        
    }
    return;
}


//接收之前消息
-(void)receiveBeforeMessage:(int)start total:(int)total{
    //接收到数据，用泡泡VIEW显示出来
    NSLog(@"接收之前消息");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults stringForKey:@"userName"];
    
    
    //NSString *selectSqlStr=[NSString stringWithFormat:@"select count(id) from ChatMessage where flag=\"%d\" and userName=\"%@\" ",0,userName];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select id, sendUser,message,flag,receiveUser,msgType,subject,sendTime from ChatMessage where (sendUser=\"%@\" and receiveUser=\"%@\") or (sendUser=\"%@\" and receiveUser=\"%@\") order by id desc limit \"%d\",\"%d\"",_chatWithUser,userName,userName,_chatWithUser,start,total];
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    //清空重新赋值
    NSLog(@"********%d",self.chatArray.count);
    for (int i=0; i<self.chatArray.count; i++) {
        [self.beforeChatArray addObject:[self.chatArray objectAtIndex:i]];
    }
    [self.chatArray removeAllObjects];
    
    
    
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        NSString*msgId=0;
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            int _id=sqlite3_column_int(statement, 0);
            msgId = [NSString stringWithFormat:@"%d",_id];
            
            NSString *userName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            
            NSString *message=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            int _flag=sqlite3_column_int(statement, 3);
            
            NSString *receiveUser=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            
            NSString *msgType=[[NSString alloc] initWithCString:(char *) sqlite3_column_text(statement, 5)
                                                       encoding:NSUTF8StringEncoding];
            
            NSString *subjectStr=[[NSString alloc] initWithCString:(char *) sqlite3_column_text(statement, 6)
                                                       encoding:NSUTF8StringEncoding];

           // NSString *sendTime=[[NSString alloc] initWithCString:(char *) sqlite3_column_text(statement, 6)
           //                                             encoding:NSUTF8StringEncoding];
                NSString *sendTime=Utility.getCurrentDate;
            
            NSLog(@"row>>id %i, name>>%@,flag>>%i,reiceiveUser>>%@,msgType>>%@",_id,userName,_flag,receiveUser,msgType);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            
            [dateFormatter setDateFormat: @"yy-MM-dd HH:mm"];
            
            
            NSDate *sendDate= [dateFormatter dateFromString:sendTime];
            
           // [dateFormatter release];
            
            NSLog(@"%@",subjectStr);
            
            //区分自己和好友
            if ([userName isEqualToString:_chatWithUser]) {
                
                [self.tempChatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", message, @"text", _chatWithUser, @"speaker",msgType,@"type",subjectStr,@"subject", sendDate,@"sendDate", nil]];
                
            }else if([userName isEqualToString:userName]){
                
                [self.tempChatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", message, @"text", userName, @"speaker",msgType,@"type",subjectStr,@"subject",sendDate,@"sendDate",  nil]];
                
            }
            
        }
        
        
        
        NSLog(@"********%d",self.tempChatArray.count);
        NSLog(@"********%d",self.beforeChatArray.count);
        
        for (int i=self.tempChatArray.count-1; i>=0; i--) {
            NSDictionary *item = [self.tempChatArray objectAtIndex:i];
            NSString *msgId = [item objectForKey:@"msgId"];
            NSString *userName = [item objectForKey:@"speaker"];
            NSString *message = [item objectForKey:@"text"];
            NSString *msgType = [item objectForKey:@"type"];
            NSString *subject = [item objectForKey:@"subject"];
            NSDate *sendDate = [item objectForKey:@"sendDate"];
            
            if (i==self.tempChatArray.count-1) {
                [self.chatArray addObject:sendDate];
                
            }else if(i-1>=0){
                
                NSDate *lastSendDate = [[self.tempChatArray objectAtIndex:i-1] objectForKey:@"sendDate"];
                NSTimeInterval timeInterval = [lastSendDate timeIntervalSinceDate:sendDate];
                if (timeInterval >60) {
                    
                    [self.chatArray addObject:sendDate];
                    
                }
            }
            NSLog(@"％％％％％％％％％％％%@",subject);

            
            //区分自己和好友
            if ([userName isEqualToString:_chatWithUser]) {
                
                UIView *chatView = [self bubbleView:message
                                               from:NO type:msgType subject:subject historyFlag:YES];
                [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", message, @"text", _chatWithUser, @"speaker", chatView, @"view", nil]];
            }else {
                // 发送后生成泡泡显示出来
                UIView *chatView = [self bubbleView:message from:YES type:msgType subject:subject historyFlag:YES];
                [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", message, @"text", userName, @"speaker", chatView, @"view",msgType,@"type",  nil]];
                
            }
            
            
            
        }
        
        
        for (int i=0; i<self.beforeChatArray.count;i++) {
            
            if ([[self.beforeChatArray objectAtIndex:i] isKindOfClass:[NSDate class]]) {
                
                [self.chatArray addObject:[self.beforeChatArray objectAtIndex:i] ];
                
                
                
            }else{
                NSDictionary *item = [self.beforeChatArray objectAtIndex:i];
                NSString *msgId = [item objectForKey:@"msgId"];
                NSString *userName = [item objectForKey:@"speaker"];
                NSString *message = [item objectForKey:@"text"];
                NSString *msgType = [item objectForKey:@"type"];
                NSString *subject = [item objectForKey:@"subject"];
                NSDate *sendDate = [item objectForKey:@"sendDate"];
                
                NSLog(@"#######%@",userName);
                
                //区分自己和好友
                if ([userName isEqualToString:_chatWithUser]) {
                    
                    UIView *chatView = [self bubbleView:message
                                                   from:NO type:msgType subject:subject historyFlag:YES];
                    [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", message, @"text", _chatWithUser, @"speaker", chatView, @"view", nil]];
                }else {
                    // 发送后生成泡泡显示出来
                    UIView *chatView = [self bubbleView:message from:YES type:msgType subject:subject historyFlag:YES];
                    [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", message, @"text", userName, @"speaker", chatView, @"view",msgType,@"type",  nil]];
                    
                }
                
                //[self.chatArray addObject:[self.beforeChatArray objectAtIndex:i]];
            }
            
            
        }
        
        
        
        NSLog(@"********%d",self.chatArray.count);
        
        [self.chatTableView reloadData];
        
        
        
        //加载定位
        if(self.chatArray.count>0){
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-_start-1 inSection:0]
                                      atScrollPosition: UITableViewScrollPositionBottom
                                              animated:YES];
        }
        
        [self.tempChatArray removeAllObjects];
        [self.beforeChatArray removeAllObjects];
        
    }else{
        //error
        [self ErrorReport: (NSString *)selectSqlStr];
    }
    sqlite3_finalize(statement);
    [self updateTable:_chatWithUser];
    
    return;
}


#pragma mark KKMessageDelegate
-(void)newMessageReceived:(NSDictionary *)messageCotent{
    
    NSLog(@"chat one to one");
    if ([messageCotent objectForKey:@"msg"]!=nil) {
    [self.messages addObject:messageCotent];
    
    [self receiveMessage:messageCotent];
    
    [self.chatTableView reloadData];
    }
}

-(void) clickLeftButton {
    [self dismissViewControllerAnimated:NO completion:nil];
    _messgaeFlag=@"NoUpdateMessageFlag";
}



//－－－－－－－－－－－－－－－－发送图片－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
#pragma mark sharemore按钮组协议
-(void)pickPhoto
{
    UIImagePickerController *imgPicker=[[UIImagePickerController alloc]init];
    [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imgPicker setDelegate:self];
    [imgPicker setAllowsEditing:YES];
    [self presentViewController:imgPicker animated:YES completion:^{
    }];
    
    CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.tabBarBG.hidden=YES;
    
    
}


#pragma mark ----------图片选择完成-------------
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSLog(@"image info:%@",info);
    UIImage  * chosedImage=[info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self sendImage:chosedImage];
    }];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName

{
    NSData* imageData = UIImagePNGRepresentation(tempImage);
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    
    //  TMP_UPLOAD_PATH = fullPathToFile;
    
    NSArray *nameAry=[UPLOAD_PATH componentsSeparatedByString:@"/"];
    NSLog(@"===new fullPathToFile===%@",fullPathToFile);
    NSLog(@"===new FileName===%@",[nameAry objectAtIndex:[nameAry count]-1]);
    
    [imageData writeToFile:fullPathToFile atomically:NO];
    
}


-(void)sendImage:(UIImage *)aImage
{
    NSLog(@"准备发送图片");
    NSString *message = [Photo image2String:aImage];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
    
    NSString *timeString = Utility.getCurrentDate;

    NSString *bodyJsonStr =  [NSString stringWithFormat:@"%@%@%@",@"{\"data\":\"", message,@"\",\"src\":\"\",\"link\":\"no url\"}"];

    if (message.length > 0) {
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:bodyJsonStr];
        NSXMLElement *subject = [NSXMLElement elementWithName:@"subject"];
        [subject setStringValue:@"image"];
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_chatWithJID];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:userName];
        
        //发送时间
        //[mes addAttributeWithName:@"time" stringValue:timeString];
        
        //        [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:[NSString stringWithFormat:@"[1]%@",message]]];
        [mes addChild:subject];
        [mes addChild:body];
        
        //发送消息
        [[XMPPServer xmppStream] sendElement:mes];
        
        self.messageTextField.text = @"";
        [self.messageTextField resignFirstResponder];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        [dictionary setObject:message forKey:@"msg"];
        [dictionary setObject:@"me" forKey:@"sender"];
        //加入发送时间
        [dictionary setObject:[ChatStatic getCurrentTime] forKey:@"time"];
        
        [self.messages addObject:dictionary];
        
        //重新刷新tableView
        [self.chatTableView reloadData];
        
    }
    
    // [[WCXMPPManager sharedInstance]sendFile:nil toJID:[XMPPJID jidWithUser:[NSString stringWithFormat:@"%@",_chatPerson.userId] domain:@"hcios.com" resource:@"ios"]]; //重新刷新tableView
    NSDate *nowTime = [NSDate date];
    
    if ([self.chatArray lastObject] == nil) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
        
        
	}
    
	NSTimeInterval timeInterval = [nowTime timeIntervalSinceDate:self.lastTime];
	if (timeInterval >60) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
        
        
	}
    
	[self.chatTableView reloadData];
    
    [self insertTable:userName sencond:message third:_chatWithUser msgType:@"chat" subject:@"image" sendTime:timeString];
    [self updateTable:userName];
    NSString *msgId = [self queryIdByUserName:userName chatWithUser:_chatWithUser];
    
    UIView *chatView = [self bubbleView:bodyJsonStr	from:YES type:@"chat" subject:@"image" historyFlag:NO];
	[self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", message, @"text", @"self", @"speaker",@"picture",@"type", chatView, @"view", nil]];
    
    [self.chatTableView reloadData];
    
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
							  atScrollPosition: UITableViewScrollPositionBottom
                                      animated:YES];
    
    
    
    
    NSLog(@"播放提示音");
    AudioServicesPlaySystemSound(1105);
}



//--------------语音功能－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
- (void)addShapeLayer
{
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.path = [[self pathAtInterval:2.0] CGPath];
    self.shapeLayer.fillColor = [[UIColor redColor] CGColor];
    self.shapeLayer.lineWidth = 1.0;
    self.shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
    [self.viewForWave.layer addSublayer:self.shapeLayer];
}

- (void)startDisplayLink
{
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopDisplayLink
{
    [self.displayLink invalidate];
    self.displayLink = nil;
    
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink
{
    if (!self.firstTimestamp)
        self.firstTimestamp = displayLink.timestamp;
    
    self.loopCount++;
    
    NSTimeInterval elapsed = (displayLink.timestamp - self.firstTimestamp);
    
    self.shapeLayer.path = [[self pathAtInterval:elapsed] CGPath];
    
    //    if (elapsed >= kSeconds)
    //    {
    //       // [self stopDisplayLink];
    //        self.shapeLayer.path = [[self pathAtInterval:0] CGPath];
    //
    //        self.statusLabel.text = [NSString stringWithFormat:@"loopCount = %.1f frames/sec", self.loopCount / kSeconds];
    //    }
}

- (UIBezierPath *)pathAtInterval:(NSTimeInterval) interval
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0, self.viewForWave.bounds.size.height / 2.0)];
    
    CGFloat fractionOfSecond = interval - floor(interval);
    
    CGFloat yOffset = self.viewForWave.bounds.size.height * sin(fractionOfSecond * M_PI * Pitch*8);
    
    [path addCurveToPoint:CGPointMake(self.viewForWave.bounds.size.width, self.viewForWave.bounds.size.height / 2.0)
            controlPoint1:CGPointMake(self.viewForWave.bounds.size.width / 2.0, self.viewForWave.bounds.size.height / 2.0 - yOffset)
            controlPoint2:CGPointMake(self.viewForWave.bounds.size.width / 2.0, self.viewForWave.bounds.size.height / 2.0 + yOffset)];
    
    return path;
}

- (void) myButtonLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Touch down");
        
        [self.touchbutton setBackgroundImage:[UIImage imageNamed:@"listing_done_btn~iphone.png"] forState:UIControlStateNormal];
        [self startRecording];
        
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        NSLog(@"Long press Ended");
        [self stopRecording];
        [self.touchbutton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    
}

-(IBAction) startRecording
{
    self.viewForWave.hidden = NO;
    [self addShapeLayer];
    [self startDisplayLink];
    // kSeconds = 150.0;
    NSLog(@"startRecording");
    audioRecorder = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
    if(recordEncoding == ENC_PCM)
    {
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    }
    else
    {
        NSNumber *formatObject;
        
        switch (recordEncoding) {
            case (ENC_AAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatMPEG4AAC];
                break;
            case (ENC_ALAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleLossless];
                break;
            case (ENC_IMA4):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
                break;
            case (ENC_ILBC):
                formatObject = [NSNumber numberWithInt: kAudioFormatiLBC];
                break;
            case (ENC_ULAW):
                formatObject = [NSNumber numberWithInt: kAudioFormatULaw];
                break;
            default:
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
        }
        
        [recordSettings setObject:formatObject forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    }
    
    //    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/recordTest.caf", [[NSBundle mainBundle] resourcePath]]];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(
                                                            NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"recordTest.caf"];
    
    NSURL *url = [NSURL fileURLWithPath:soundFilePath];
    
    
    NSError *error = nil;
    audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    audioRecorder.meteringEnabled = YES;
    if ([audioRecorder prepareToRecord] == YES){
        audioRecorder.meteringEnabled = YES;
        [audioRecorder record];
        timerForPitch =[NSTimer scheduledTimerWithTimeInterval: 0.01 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    }else {
        int errorCode = CFSwapInt32HostToBig ([error code]);
        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
        
    }
    
}



-(NSString *)base64Code:(NSURL *)recordedFile{
    
    //将音频文件转成NSData
    NSData *soundData = [[NSData alloc] initWithContentsOfURL:recordedFile];
    
    //将NSData转成base64的NSString类型
    NSString *sound=[soundData base64EncodedString];
    //发送代码
    //    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    //    [body setStringValue:sound];
    //    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    //    [message addAttributeWithName:@"type" stringValue:@"chat"];
    //    NSString *to = [NSString stringWithFormat:@"%@", self.userJID];
    //    [message addAttributeWithName:@"to" stringValue:to];
    //    [message addChild:body];
    //    [[[self appDelegate]xmppStream] sendElement:message];
    
    return sound;
}



- (void)levelTimerCallback:(NSTimer *)timer {
	[audioRecorder updateMeters];
	NSLog(@"Average input: %f Peak input: %f", [audioRecorder averagePowerForChannel:0], [audioRecorder peakPowerForChannel:0]);
    
    float linear = pow (10, [audioRecorder peakPowerForChannel:0] / 20);
    NSLog(@"linear===%f",linear);
    float linear1 = pow (10, [audioRecorder averagePowerForChannel:0] / 20);
    NSLog(@"linear1===%f",linear1);
    if (linear1>0.03) {
        
        Pitch = linear1+.20;//pow (10, [audioRecorder averagePowerForChannel:0] / 20);//[audioRecorder peakPowerForChannel:0];
    }
    else {
        
        Pitch = 0.0;
    }
    //Pitch =linear1;
    NSLog(@"Pitch==%f",Pitch);
    _customRangeBar.value = Pitch;//linear1+.30;
    [_progressView setProgress:Pitch];
    float minutes = floor(audioRecorder.currentTime/60);
    float seconds = audioRecorder.currentTime - (minutes * 60);
    
    NSString *time = [NSString stringWithFormat:@"%0.0f.%0.0f",minutes, seconds];
    [self.statusLabel setText:[NSString stringWithFormat:@"%@ sec", time]];
    NSLog(@"recording");
    
}
-(IBAction) stopRecording
{
    NSLog(@"stopRecording");
    // kSeconds = 0.0;
    self.viewForWave.hidden = YES;
    [audioRecorder stop];
    NSLog(@"stopped");
    [self stopDisplayLink];
    self.shapeLayer.path = [[self pathAtInterval:0] CGPath];
    [timerForPitch invalidate];
    timerForPitch = nil;
    _customRangeBar.value = 0.0;
}

-(IBAction) playRecording
{
    NSLog(@"sendRecording");
    // Init audio with playback capability
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(
                                                            NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"recordTest.caf"];
    //
    NSURL *url = [NSURL fileURLWithPath:soundFilePath];
    
    // NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/recordTest.caf", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.numberOfLoops = 0;
    // [audioPlayer play];
    // NSLog(@"playing");
    NSString *message =  [self base64Code:url
                          ];
    NSString * type = @"chat";
    NSString * subject = @"voice";
    [self sendMassage2:message type:type subject:subject];
}


-(void) playRecording2:(UIButton *) btn{
    NSLog(@"playRecording%d",btn.tag);
    
    NSInteger index = btn.tag;
    NSDictionary *item = [self.chatArray objectAtIndex:index];
    
    NSString * voiceMessage= [item objectForKey:@"text"];
    
    
    NSData *voiceData = [voiceMessage base64DecodedData];
    
    
    
    NSLog(@"voiceMessage%d",voiceMessage.length);
    //NSLog(@"voiceMessage%@",voiceMessage);
    
    // Init audio with playback capability
    
    
    
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    if([self.playMode isEqualToString:@"Playback"]){
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
    }else if([self.playMode isEqualToString:@"Play"]){
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
        
    }
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(
                                                            NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"recordTest.caf"];
    
    NSURL *url = [NSURL fileURLWithPath:soundFilePath];
    
    // NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/recordTest.caf", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    //audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer=[[AVAudioPlayer alloc] initWithData:voiceData error:&error] ;
    
    audioPlayer.numberOfLoops = 0;
    [audioPlayer play];
    NSLog(@"playing");
    
}





-(IBAction) stopPlaying
{
    NSLog(@"stopPlaying");
    [audioPlayer stop];
    NSLog(@"stopped");
    
}



-(IBAction) voiceOrText
{
//    if (self.messageToolbar.hidden) {
//        self.messageToolbar.hidden = NO;
//        self.voiceToolbar.hidden = YES;
//    }else{
//        self.messageToolbar.hidden = YES;
//        self.voiceToolbar.hidden = NO;
//    }
    
    
}






#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    self.refreshing = YES;
    [self performSelector:@selector(loadDataUp) withObject:nil afterDelay:1.f];
    
}

- (NSDate *)pullingTableViewRefreshingFinishedDate{
    NSDateFormatter * df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString* dateStr;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    dateStr = [formatter stringFromDate:[NSDate date]];
    NSDate * date = [df dateFromString:dateStr];
   // [formatter release];
   // [df release];
    
    return date;
}

- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    
    
    [self performSelector:@selector(loadDataDown) withObject:nil afterDelay:1.f];
}

#pragma mark - Scroll

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.chatTableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.chatTableView tableViewDidEndDragging:scrollView];
}



- (void)loadDataUp{
    _start +=_pageSize;
    
    NSLog(@"******%d",_total);
    
    if (_start>=_total) {
        [self.chatTableView tableViewDidFinishedLoadingWithMessage:@"已加载所有数据!"];
        self.chatTableView.reachedTheEnd  = YES;
        return;
    }
    [self receiveBeforeMessage:_start total:_pageSize];
    [self.chatTableView tableViewDidFinishedLoading];
    
}


- (void)loadDataDown{

}

//－－－－－－－－sqlite3 数据库操作－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//open database
- (void)openDataBase
{
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                , NSUserDomainMask
                                                                , YES);
    NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"db.sql"];
    
    if (sqlite3_open([databaseFilePath UTF8String], &database)==SQLITE_OK)
    {
        NSLog(@"open sqlite db ok.");
    }
    else
    {
        NSLog( @"can not open sqlite db " );
        
        //close database
        sqlite3_close(database);
    }
}

//insert table
- (void)insertTable:(NSString *)userName sencond:(NSString *)message third:(NSString *)receiveUser msgType:(NSString*)msgType subject:(NSString*)subjectStr sendTime:(NSString*)sendTime
{
    char *errorMsg;
    
    NSLog(@"*************%@",message);
    
    NSString *insertSqlStr=[NSString stringWithFormat:@"insert into ChatMessage (sendUser,message,receiveUser,msgType,subject,sendTime) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",userName,message,receiveUser,msgType,subjectStr,sendTime];
    const char *insertSql = [insertSqlStr UTF8String];
    
    if (sqlite3_exec(database, insertSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"insert ok.");
    }
    else
    {
        NSLog( @"can not insert it to table" );
        [self ErrorReport: (NSString *)insertSqlStr];
    }
}


//error
- (void)ErrorReport: (NSString *)item
{
    char *errorMsg;
    
    const char *itemChar = [item UTF8String];

    
    if (sqlite3_exec(database, (const char *)itemChar, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"%@ ok.",item);
    }
    else
    {
        NSLog(@"error: %s",errorMsg);
        sqlite3_free(errorMsg);
    }
}


//query table
- (int)queryTableCount:(NSString *)userName
{
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select count(id) from ChatMessage where (sendUser=\"%@\" and receiveUser=\"%@\") or (sendUser=\"%@\" and receiveUser=\"%@\")",_chatWithUser,userName,userName,_chatWithUser];
    
    const char *selectSql = [selectSqlStr UTF8String];
    int count = 0;
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            count = sqlite3_column_int(statement, 0);
            //  int _id=sqlite3_column_int(statement, 0);
            // NSString *userName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            //  NSString *message=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            // NSLog(@"row>>id %i, name>>%@,message>> %@",_id,userName,message);
        }
        
    }
    else
    {
        //error
        [self ErrorReport: (NSString *)selectSqlStr];
    }
    
    //sqlite3_finalize(statement);
    
    return count;
}



//查询当前数据ID(自己是发送者）
- (NSString*)queryIdByUserName:(NSString *)userName chatWithUser:(NSString *)chatWithUser
{
    
    NSString* msgId = 0;
    if ([chatWithUser isEqualToString:_chatWithUser]) {
        
        NSString *selectSqlStr=[NSString stringWithFormat:@"select id, sendUser,message,flag,receiveUser,msgType ,sendTime from ChatMessage where  sendUser=\"%@\" and receiveUser=\"%@\" order by id desc limit \"%d\",\"%d\"",userName,_chatWithUser,0,1];
        
        const char *selectSql = [selectSqlStr UTF8String];
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
        {
            NSLog(@"select ok.");
            while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
            {
                
                int _id=sqlite3_column_int(statement, 0);
                msgId = [NSString stringWithFormat:@"%d",_id];
                
            }
        }else{
            //error
            [self ErrorReport: (NSString *)selectSqlStr];
        }
    }
    
    
    return msgId;
}


//delete table
- (void)deleteTable:(NSString *)msgId
{
    
    
    NSLog(@"*****%@",msgId);
    char *errorMsg;
    [self openDataBase];
    NSString *deleteSqlStr=[NSString stringWithFormat:@"DELETE FROM ChatMessage where id=\"%@\"",msgId];
    const char *deleteSql = [deleteSqlStr UTF8String];
    
    if (sqlite3_exec(database, deleteSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"delete ok.");
    }
    else
    {
        NSLog( @"can not delete it" );
        [self ErrorReport: (NSString *)deleteSqlStr];
    }
    
}

- (void)updateTable:(NSString *)userName{
    
    char *errorMsg;
    [self openDataBase];
    NSString *updateSqlStr=[NSString stringWithFormat:@" UPDATE ChatMessage SET flag = 1 WHERE sendUser=\"%@\"",userName];
    const char *updateSql = [updateSqlStr UTF8String];
    
    if (sqlite3_exec(database, updateSql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"update ok.");
    }
    else
    {
        NSLog( @"can not update it" );
        [self ErrorReport: (NSString *)updateSqlStr];
    }
    
}

-(void)dropTable
{
    //DROP TABLE ChatMessage;
}


- (BOOL)shouldAutorotate

{
    
    return NO;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation

{
    
    return NO;
    
}
@end
