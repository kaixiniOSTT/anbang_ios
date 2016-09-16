

#import "ChatViewController2.h"
#import "ChatCustomCell.h"
#import "Header.h"
#import "XMPPHelper.h"
#import "Photo.h"
#import <ImageIO/ImageIO.h>
#import "JSMessageSoundEffect.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "GBPathImageView.h"
#import "Utility.h"
#import "JSONKit.h"
#import "ChatBuddyCRUD.h"
#import "PublicCURD.h"
#import "User.h"
#import "CHAppDelegate.h"
#import "KKMessageCell.h"
#import "XMPPStream.h"
#import "VoiceConverter.h"
#import "ChatCacheFileUtil.h"
#import "VoiceBody.h"
#import "ASIFormDataRequest.h"
#import "GLBucket.h"
#import "CSNotificationView.h"
#import "UIMenuItem+CXAImageSupport.h"
#import "ChatMessageCRUD.h"
#import "ContactsCRUD.h"
#import "UserInfoCRUD.h"
#import "Contacts.h"
#import "APPRTCViewController.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "MWCommon.h"
#import "IdGenerator.h"
#import "GroupMembersDetailsViewController.h"
#import "YLGIFImage.h"
#import "YLImageView.h"
#import <AddressBookUI/AddressBookUI.h>
#import "ChatCustomMethod.h"
#import "TempMultiPlayTalkViewController2.h"
#import "DejalActivityView.h"
#import "MyServices.h"
#import "ContactInfo.h"
#import "AINavigationController.h"
#import "AICollection.h"
#import "AICollectionCRUD.h"
#import "AIPersonalCard.h"
#import "ImageUtility.h"
#import "AIControllersTool.h"
//#import "AICurrentContactController.h"
#import "AICardSelectedViewController.h"
#import "MJExtension.h"
//#import "IFTweetLabel.h"
#import "AIDocument.h"
#import "AICurrentContactController.h"
#import "AIMessageTool.h"
#import "BaiduMapViewController.h"
#import "AIChatResourceCache.h"
#import "AIQLPreviewController.h"
#import "ImageUtility.h"
#import "DndInfoCRUD.h"
#import "AIPreviewController.h"
#import "AIDocumentDownloadManager.h"
#import "AIArticle.h"
#import "AIUIWebViewController.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


#define CHAT_TOOLBARTAG    200
#define CHAT_TABLEVIEWTAG	300
#define RecordSOUNDID  1113


static NSString *kAnimationNameKey = @"animation_name";
static NSString *kScrapDriveUpAnimationName = @"scrap_drive_up_animation";
static NSString *kScrapDriveDownAnimationName = @"scrap_drive_down_animation";
static NSString *kBucketDriveUpAnimationName = @"bucket_drive_up_animation";
static NSString *kBucketDriveDownAnimationName = @"bucket_drive_down_animation";
static const CGFloat kScrapDriveUpAnimationHeight = 200;

@interface ChatViewController2 ()<TempMultiPlayTalkVCDelegate, AVAudioPlayerDelegate>{
    FMDatabase *db;
    APPRTCViewController *appView;
    NSString * _voiceLink;
    int imageCount;
    NSString *CHAT_UPLOAD_PATH;
    int pageCellHeight;//纪录当前页所有cell高度.
    UIButton *voiceSelectorBtn; //语音栏上的更多button
    int secondsCountDown;//语音倒计时时间
    NSTimer * voiceCountDownTimer;//语音倒计时timer
    UILabel *voiceTimerLabel;//语音倒计时label
    NSString *noImgMessageStr;
    NSMutableArray *mUnplayedVoiceArray;
    
    AIChatResourceCache *mResourceCache;
    NSArray *_previewingImageMessages;
    NSDictionary *_collectedMessage;
    enum
    {
        Normal = 1,
        Employee = 2
    } AccountType;
    
    int myAccountType;
    int friendAccountType;
    
    // 计时器
    NSInteger mTime;
    NSTimer *mTimer;
    UILabel *titleLabel;
    UIImageView *dndIconView;
    UIView *titleView;
    
    NSDictionary *expressionDic;
}

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) CALayer *scrapLayer;
@property (nonatomic, strong) CALayer *bucketContainerLayer;
@property (nonatomic, strong) GLBucket *bucket;
@property (nonatomic, assign) CFTimeInterval duration;
@property (nonatomic, assign) CGFloat baseviewYOrigin;
@property (nonatomic, assign) CGFloat bucketContainerLayerActualYPos;

@property (nonatomic, strong)  UITextView *textView2;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) NSMutableArray* playVoiceImage;
@property (nonatomic, strong) NSMutableArray* playVoiceImageFrom;
@property (nonatomic, weak) UIActivityIndicatorView *activity;
@property (nonatomic, assign) NSInteger  playNumber;
@property (nonatomic) CGRect textRect;

- (void)bounceOutAnimationStopped;
- (void)bounceInAnimationStopped;

- (void)pressme:(id)sender;
- (void)deleteMsgAction:(id)sender;
- (void)broomAction:(id)sender;
- (void)textAction:(id)sender;

@end

@implementation ChatViewController2
@synthesize roomName = _roomName;
@synthesize roomNickName = _roomNickName;

@synthesize titleString = _titleString;
@synthesize chatArray = _chatArray;
@synthesize tempChatArray=_tempChatArray;
@synthesize beforeChatArray=_beforeChatArray;
@synthesize chatTableView = _chatTableView;
@synthesize messageTextField = _messageTextField;
@synthesize messageToolbar = _messageToolbar;
@synthesize voiceToolbar = _voiceToolbar;
@synthesize hideTextField = _hideTextField;
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
@synthesize menuIndexPath=_menuIndexPath;

@synthesize tempSendImage = _tempSendImage;
@synthesize tempSendImageArray = _tempSendImageArray;
@synthesize tempImgMsgRandomIdArray = _tempImgMsgRandomIdArray;

@synthesize longPress = _longPress;

@synthesize imgMsgRandomId = _imgMsgRandomId;
@synthesize voiceMsgRandomId = _voiceMsgRandomId;

@synthesize phoneNum = _phoneNum;


- (void)didReceiveMemoryWarning
{
    
    NSLog(@"内存警告－单聊消息界面");
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];//即使没有显示在window上，也不会自动的将self.view释放。
    // Add code to clean up any of your own resources that are no longer necessary.
    
    // 此处做兼容处理需要加上ios6.0的宏开关，保证是在6.0下使用的,6.0以前屏蔽以下代码，否则会在下面使用self.view时自动加载viewDidUnLoad
    //需要注意的是self.isViewLoaded是必不可少的，其他方式访问视图会导致它加载 ，在WWDC视频也忽视这一点。
    
    if (self.isViewLoaded && !self.view.window)// 是否是正在使用的视图
    {
        // Add code to preserve data stored in the views that might be
        // needed later.
        
        // Add code to clean up other strong references to the view in
        // the view hierarchy.
        self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
        
    }
}


- (void)dealloc {
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ChatVC_Refresh" object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CNN_Update_Chat_Buddy_Flag" object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CNN_Msg_Send" object:nil];
    //
    [self tearNotifications];
    [mTimer invalidate];
    
//    _chatArray=nil;
//    _roomName=nil;
//    _roomNickName=nil;
//    _titleString=nil;
//    _tempChatArray=nil;
//    _beforeChatArray=nil;
//    _chatTableView=nil;
//    _messageTextField=nil;
//    _voiceToolbar=nil;
//    _messageString=nil;
//    _phraseString=nil;
//    _lastTime=nil;
//    _chatWithUser=nil;
//    _chatWithJID=nil;
//    
//    _messages=nil;
//    myPhoto=nil;
//    buddyPhoto=nil;
//    _msgButArray=nil;
//    
//    _messgaeFlag=nil;
//    
//    _playMode=nil;
//    _menuIndexPath=nil;
//    
//    _tempSendImage=nil;
//    _tempSendImageArray=nil;
//    _tempImgMsgRandomIdArray=nil;
//    
//    _longPress=nil;
//    
//    _imgMsgRandomId=nil;
//    _voiceMsgRandomId=nil;
//    
//    _phoneNum=nil;
//    
//    avatarDefaultPath = nil;
//    avatarURL = nil;
//    friendAvatarImageView = nil;
//    myAvatarURL=nil;
//    myAvatarImageView=nil;
    
    JLLog_D(@"delloc <class=%@, self=%p>", [self class], self);
    
}



#pragma mark - life circle
-(void)loadView{
    [super loadView];
    self.playVoiceImage = [NSMutableArray array];
    self.playVoiceImageFrom = [NSMutableArray array];
    for(int i = 0; i < 4; i++){
        UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"SenderVoiceNodePlaying00%d_ios7", i%4]];
        [_playVoiceImage addObject:image];
        UIImage* image1 = [UIImage imageNamed:[NSString stringWithFormat:@"ReceiverVoiceNodePlaying00%d_ios7", i%4]];
        [_playVoiceImageFrom addObject:image1];
    }
    
    
    //multiMediaSend 模块标识
    [[NSUserDefaults standardUserDefaults] setObject:@"chat" forKey:@"NSUD_MultiMedia_Flag"];

    
    self.tempSendImageArray = [[NSMutableArray alloc]init];
    self.tempImgMsgRandomIdArray = [[NSMutableArray alloc]init];
    
    //初始化分页
    _pageSize =10;
    _start =0;
    //[self openDataBase];
    _total =[ChatMessageCRUD queryCountByUserName:MY_USER_NAME chatWithUser:_chatWithUser];
    _pageTotal = ceilf(_total/_pageSize);
    int cutHeight=0;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
        cutHeight=113;
    }else  {
        cutHeight=113;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 20*kScreenScale)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.bounds = (CGRect) {CGPointZero, CGSizeMake(20*kScreenScale, 20*kScreenScale)};
    activity.center = headerView.center;
    activity.hidden = YES;
    activity.hidesWhenStopped = YES;
    [headerView addSubview:activity];
    self.activity = activity;
    
    _chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-cutHeight) style:UITableViewStylePlain];
    _chatTableView.backgroundColor = Controller_View_Color;
    _chatTableView.dataSource = self;
    _chatTableView.delegate = self;
    _chatTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    _chatTableView.scrollsToTop = YES;
    // _chatTableView.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.2 alpha:1];
    [_chatTableView setAllowsSelection:NO];
    
    _chatTableView.tableHeaderView = headerView;
    [self.view addSubview:_chatTableView];
    self.chatTableView.tag = CHAT_TABLEVIEWTAG;
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        //NSLog(@"ios7");
//         self.edgesForExtendedLayout=UIRectEdgeNone;
//         self.extendedLayoutIncludesOpaqueBars = NO;
         self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    
    
    //UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //button.bounds = CGRectMake(0, 0, 30, 30);
    //[button setImage:[UIImage imageNamed:@"header_button_perInfo"] forState:UIControlStateNormal];
    //[button setImage:[UIImage imageNamed:@"header_button_perInfo"] forState:UIControlStateHighlighted];
    //[button addTarget:self action:@selector(multiplayerTalk:) forControlEvents:UIControlEventTouchUpInside];
    
    //UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //[self.navigationItem setRightBarButtonItem:item];
    

    [self loadAssets];
    
    self.view.backgroundColor = Controller_View_Color;
}


-(void)testSendMessage{
    for (int i=0; i<1000; i++) {
        [self sendMassage:[NSString stringWithFormat:@"%@%d",@"冬天不怕冷！！！",i]];
    }
    
}

//渐变 和 移动
- (UIGestureRecognizer *)createTapRecognizerWithSelector:(SEL)selector {
    return [[UITapGestureRecognizer alloc]initWithTarget:self action:selector];
}


- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}


//语音倒计时
-(void)timeFireMethod{
    secondsCountDown--;
    if(secondsCountDown==0){
        [voiceCountDownTimer invalidate];
    }
    
    voiceTimerLabel.text = [NSString stringWithFormat:@"%d",secondsCountDown];
}


//多人对话
- (void)multiplayerTalk:(UIButton*)sender{
    
//旧版本废弃
//    TempMultiplayerTalkViewController *tempMultiplayerTalkVC=[[TempMultiplayerTalkViewController alloc] initWithNibName:@"TempMultiplayerTalkViewController" bundle:nil];
//    //隐藏tabbar
//    tempMultiplayerTalkVC.hidesBottomBarWhenPushed=YES;
//    tempMultiplayerTalkVC.fromViewFlag = @"ChatViewController2";
//    tempMultiplayerTalkVC.memberJID = _chatWithJID;
//    tempMultiplayerTalkVC.memberUserName = _chatWithUser;
//    [self.navigationController pushViewController :tempMultiplayerTalkVC animated:YES];
    
    
    TempMultiPlayTalkViewController2* tempMultiplayerTalkVC =[[TempMultiPlayTalkViewController2 alloc]init];
    
    //隐藏tabbar
    tempMultiplayerTalkVC.hidesBottomBarWhenPushed=YES;
    tempMultiplayerTalkVC.memberJID = _chatWithJID;
    tempMultiplayerTalkVC.memberName = _chatWithUser;
    tempMultiplayerTalkVC.delegate = self;
    [self.navigationController pushViewController :tempMultiplayerTalkVC animated:YES];
}


- (void)buttonAction:(id)sender
{
    [self.button setTitle:@"" forState:UIControlStateNormal];
    [self.button setEnabled:NO];
    [self scrapDriveUpAnimation];
}



- (CGRect)CGRectIntegralCenteredInRect:(CGRect)innerRect withRect:(CGRect)outerRect
{
    CGFloat originX = floorf((outerRect.size.width - innerRect.size.width) * 0.5f);
    CGFloat originY = floorf((outerRect.size.height - innerRect.size.height) * 0.5f);
    CGRect bounds = CGRectMake(originX, originY, innerRect.size.width, innerRect.size.height);
    return bounds;
}

#pragma mark - Animation boilerplate

- (void)scrapDriveUpAnimation
{
    self.scrapLayer.hidden = NO;
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnimation.fromValue = [NSValue valueWithCGPoint:self.scrapLayer.position];
    moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.scrapLayer.frame), CGRectGetMidY(self.scrapLayer.frame) - kScrapDriveUpAnimationHeight)];
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeForwards;
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    NSArray* keyFrameValues = @[
                                @(0.0),
                                @(M_PI),
                                @(M_PI*1.5),
                                @(M_PI*2.0)
                                ];
    CAKeyframeAnimation* rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    [rotateAnimation setValues:keyFrameValues];
    [rotateAnimation setValueFunction:[CAValueFunction functionWithName: kCAValueFunctionRotateZ]];
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.fillMode = kCAFillModeForwards;
    rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.delegate = self;
    [animGroup setValue:kScrapDriveUpAnimationName forKey:kAnimationNameKey];
    animGroup.animations = @[moveAnimation, rotateAnimation];
    animGroup.duration = self.duration;
    animGroup.removedOnCompletion = NO;
    animGroup.fillMode = kCAFillModeForwards;
    [self.scrapLayer addAnimation:animGroup forKey:nil];
}

- (void)scrapDriveDownAnimation
{
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnimation.delegate = self;
    [moveAnimation setValue:kScrapDriveDownAnimationName forKey:kAnimationNameKey];
    moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.scrapLayer.position.x, self.scrapLayer.position.y - 5)];
    moveAnimation.duration = self.duration;
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeForwards;
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.scrapLayer addAnimation:moveAnimation forKey:nil];
}

- (void)bucketDriveUpAnimation
{
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnimation.delegate = self;
    [moveAnimation setValue:kBucketDriveUpAnimationName forKey:kAnimationNameKey];
    moveAnimation.fromValue = [NSValue valueWithCGPoint:self.bucketContainerLayer.position];
    moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.scrapLayer.frame), self.bucketContainerLayerActualYPos)];
    moveAnimation.duration = self.duration;
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeForwards;
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.bucketContainerLayer addAnimation:moveAnimation forKey:nil];
}

- (void)bucketDriveDownAnimation
{
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnimation.delegate = self;
    [moveAnimation setValue:kBucketDriveDownAnimationName forKey:kAnimationNameKey];
    moveAnimation.toValue = [NSValue valueWithCGPoint:self.bucketContainerLayer.position];
    moveAnimation.duration = self.duration;
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeForwards;
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.bucketContainerLayer addAnimation:moveAnimation forKey:nil];
}

#pragma mark - Animation Delegate methods

- (void)animationDidStart:(CAAnimation *)anim
{
    NSString *animationName = [anim valueForKey:kAnimationNameKey];
    if ([animationName isEqualToString:kScrapDriveDownAnimationName]) {
        [self bucketDriveUpAnimation];
        
    } else if ([animationName isEqualToString:kBucketDriveUpAnimationName]) {
        self.bucketContainerLayer.hidden = NO;
        [self.bucket performSelector:@selector(openBucket) withObject:nil afterDelay:self.duration * 0.3];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        NSString *animationName = [anim valueForKey:kAnimationNameKey];
        if ([animationName isEqualToString:kScrapDriveUpAnimationName]) {
            [self performSelector:@selector(scrapDriveDownAnimation) withObject:nil afterDelay:self.duration * 0.1];
            
        } else if ([animationName isEqualToString:kScrapDriveDownAnimationName]) {
            self.scrapLayer.hidden = YES;
            [self.bucket performSelector:@selector(closeBucket) withObject:nil afterDelay:self.duration * 0.1];
            [self performSelector:@selector(bucketDriveDownAnimation) withObject:nil afterDelay:self.duration * 1.0];
            
        } else if ([animationName isEqualToString:kBucketDriveDownAnimationName]) {
            self.bucketContainerLayer.hidden = YES;
            //self.scrapLayer.hidden = NO;
            self.scrapLayer.hidden = YES;
            [self.button setTitle:@"Press me to kick off again!!" forState:UIControlStateNormal];
            [self.button setEnabled:YES];
        }
    }
}


//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    isKeyBoardHide = NO;
    if (isFaceButtonClicked==YES) {
        [faceBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        
    }
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    containerView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
    [self autoMovekeyBoard:keyboardBounds.size.height];
}

-(void) keyboardWillHide:(NSNotification *)note{
    isKeyBoardHide = YES;
    if (isFaceButtonClicked==YES) {
        [faceBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        
    }
    
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    containerView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
    [self autoMovekeyBoard:0];
    
}


//文字发送工具栏与声音发送工具栏切换
- (void)voiceOrText
{
    if (containerView.hidden) {
        voiceView.hidden = YES;
        containerView.hidden = NO;
    }else{
        
        [self resignTextView];
        containerView.hidden = YES;
        voiceView.hidden = NO;
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    containerView.frame = r;
}

- (void)chanageTextViewHight{
    //  textView.frame = CGRectMake(60, 5, 200, 49);
    textView.text = @"";
}


-(void)resignTextView
{
    [textView resignFirstResponder];
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
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];//添加手势到View中
}

-(void)tapOnce//手势方法
{
    
    //    if (isFaceButtonClicked && !isKeyBoardHide) {
    //        isFaceButtonClicked = NO;
    //        [faceBtn setTitleColor:kAppStyleColor forState:UIControlStateNormal];
    //    }else{
    //        isFaceButtonClicked = YES;
    //        [faceBtn setTitleColor:kAppStyleColor forState:UIControlStateNormal];
    //    }
    //
    //    if (textView.isFirstResponder) {
    //        if (textView.emoticonsKeyboard){
    //            sendBtn.hidden = YES;
    //            moreBtn.hidden = NO;
    //            [textView switchToDefaultKeyboard];
    //        }
    //    }
    //    [textView resignFirstResponder];
    
    CGRect containerFrame = self.messageToolView.frame;
    CGRect containerFrame2 = self.faceView.frame;
    CGRect containerFrame3 = self.faceView.frame;
    [self.messageToolView.messageInputTextView resignFirstResponder];
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    containerFrame2.origin.y = self.view.bounds.size.height;
    containerFrame3.origin.y = self.view.bounds.size.height;
    self.messageToolView.frame = containerFrame;
    self.faceView.frame = containerFrame2;
    self.shareMenuView.frame = containerFrame3;
    
    self.messageToolView.faceSendButton.selected = NO;
    self.messageToolView.multiMediaSendButton.selected = NO;
    
    [self.messageToolView.faceSendButton setImage:[UIImage imageNamed:@"chat_button_text"]
                                         forState:UIControlStateSelected];
    
    [self autoMovekeyBoard:0];
    
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *view = [touch view];
    if ([view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    if ([view isKindOfClass:[UILabel class]]) {
        return NO;
    }
    
    if (view != self.chatTableView && [view isKindOfClass:[UIScrollView class]]) {
        return NO;
    }
    
    if ([view isKindOfClass:[ZBMessageTextView class]]) {
        return NO;
    }
    if ([view isKindOfClass:[ZBExpressionSectionBar class]]) {
        return NO;
    }
    if ([view isKindOfClass:[ZBFaceView class]]) {
        return NO;
    }
    return YES;
}

#pragma mark
#pragma mark setup navigation item

- (void)pop
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setupNavigationItem
{
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"对话" target:self action:@selector(pop)]];
    
    titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, Screen_Width - (58+70), 30.0f)];
    titleLabel.backgroundColor= [UIColor clearColor];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = AB_FONT_18_B;
    titleLabel.textColor = AB_Color_ffffff;
    
    titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, Screen_Width - (58+70), 30.0f)];
    [titleView addSubview:titleLabel];
    
    dndIconView = [[UIImageView alloc] init];
    dndIconView.image = [UIImage imageNamed:@"chat_button_nodis"];
    dndIconView.frame =  CGRectMake(0, 0, 16, 16);
    dndIconView.hidden = YES;
    [titleView addSubview:dndIconView];
    
    [self reloadTitle];
    
    self.navigationItem.titleView = titleView;
    
    self.navigationItem.rightBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                                [[AIImageBarButtonItem alloc] initWithImageNamed:@"header_button_perInfo"
                                                                                          target:self
                                                                                          action:@selector(multiplayerTalk:)]];
}


-(void)reloadTitle
{
    titleLabel.text = [StrUtility string:_remarkName defaultValue:_chatWithNick];
    
    BOOL isDND = [DndInfoCRUD queryOfRosterExtWithJid:_chatWithJID];
    if(isDND){
        CGSize titleLabelSize = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(Screen_Width - 50 - 100 - 20, 30.0f) lineBreakMode:NSLineBreakByCharWrapping];
        titleLabel.frame = CGRectMake((Screen_Width - 50 - 100 - 20 - titleLabelSize.width) /2, 0, titleLabelSize.width, 30);
        dndIconView.frame =  CGRectMake(titleLabel.frame.origin.x +titleLabelSize.width + 2, kChatAvatarPadding, 16, 16);
    }
    dndIconView.hidden = !isDND;
}

- (void)setupNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //设置通知中心，来消息时刷新；
    [center addObserver:self
               selector:@selector(refreshChatMsg)
                   name:@"ChatVC_Refresh"
                 object:nil];
    
    //设置通知中心,变更聊天历史列表好友已存在；
    [center addObserver:self
               selector:@selector(updateChatBuddyFlag)
                   name:@"CNN_Update_Chat_Buddy_Flag"
                 object:nil];
    
    //设置通知中心,确定消息已发出；
    [center addObserver:self
               selector:@selector(msgReceipt:)
                   name:@"CNN_Msg_Send"
                 object:nil];
    //收藏
    [center addObserver:self
               selector:@selector(collectionCreateReturn:)
                   name:@"AI_Collection_Create_Return"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(collectionCreateError:)
                   name:@"AI_Collection_Create_Error"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(updateContact:)
                   name:@"NNC_UpdateContact"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(contactInfoRequestReturn:)
                   name:@"AI_Contact_Info_Return"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(contactInfoRequestError:)
                   name:@"AI_Contact_Info_Error"
                 object:nil];
}

- (void)updateContact:(NSNotification*) n
{
    if(n.userInfo){
        _remarkName = n.userInfo[@"remarkName"];
    }
    [self reloadTitle];
}

- (void)setupMembers
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL voice_mode_record = [[defaults objectForKey:kBool_Voice_Mode_Play_Record] boolValue];
    self.playMode = voice_mode_record ? @"Play" : @"Playback";
    
    myAccountType = [UserInfoCRUD queryUserInfoAccountTypeWith:MY_JID];
    friendAccountType = [UserInfoCRUD queryUserInfoAccountTypeWith:_chatWithJID];
    
    JLLog_I(@"<_chatWithUser=%@>", self.chatWithUser);
    mResourceCache = [AIChatResourceCache cacheWithUserName:self.chatWithUser];
}
#pragma mark end

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationItem];
    [self setupMembers];
    
    
    //判断当前字符串是否还有表情的标志。
    NSString *plistStr = [[NSBundle mainBundle]pathForResource:@"expression" ofType:@"plist"];
    expressionDic = [[NSDictionary  alloc]initWithContentsOfFile:plistStr];
    
    self.playNumber = 0;
    //设置信息代理
    [XMPPServer sharedServer].messageDelegate = self;
    
    //_phonePicker = [[ABPeoplePickerNavigationController alloc] init];
    
    //_phonePicker.peoplePickerDelegate = self;
    
    
    _ppLabel.delegate = self;
    
    //NSString *urlstr = ResourcesURL;
    //NSURL *myurl = [NSURL URLWithString:urlstr];
    
    
    //增加对超链接的响应
    //    UITapGestureRecognizer*tapRecognizer1=[[UITapGestureRecognizeralloc] initWithTarget:selfaction:@selector(clickurl1:)];
    //    self.label2.userInteractionEnabled=YES;
    //    [self.label2addGestureRecognizer:tapRecognizer1];
    
    
    self.navigationController.navigationBar.translucent = NO;
    
    
    self.duration = 0.6;
    
    // configure zindex of each and every layers/views
    self.button.layer.zPosition = 99;
    self.bucketContainerLayer.zPosition = 98;
    self.scrapLayer.zPosition = 97;
    
    [self tapBackground];
    textView.keyboardType = UIKeyboardTypeDefault;
    
    textView.returnKeyType=UIReturnKeySend;
    
    self.voiceToolbar.hidden=YES;
    
    
    self.view.backgroundColor = Controller_View_Color;
    
    self.messages = [NSMutableArray array];
    //    [_messageTextField becomeFirstResponder];
    _messageTextField.delegate = self;
    
   	NSMutableArray *tempArray = [NSMutableArray array];
    self.chatArray = tempArray;
    //[tempArray release];
    self.tempChatArray = [NSMutableArray array];
    self.beforeChatArray = [NSMutableArray array];
    mUnplayedVoiceArray =  [NSMutableArray array];
    
    
    NSMutableString *tempStr = [[NSMutableString alloc] initWithFormat:@""];
    self.messageString = tempStr;
    // [tempStr release];
    
    //NSDate   *tempDate = [[NSDate alloc] init];
    //_lastTime= [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    _lastTime = nil;
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
    
    
    //默认头像
    avatarDefaultPath = [[NSBundle mainBundle] pathForResource:@"defaultUser" ofType:@"png"];
    
    //对方头像
    
    //NSLog(@"*******%@",_chatWithJID);
    
    avatar = [UserInfoCRUD queryUserInfoAvatar:_chatWithJID];
    
    avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, avatar];
    friendAvatarImageView = [[UIImageView alloc]init];
    friendAvatarImageView.backgroundColor = [UIColor clearColor];
    [friendAvatarImageView setImageWithURL:[NSURL URLWithString:avatarURL]
                          placeholderImage:[UIImage imageWithContentsOfFile:avatarDefaultPath]];
    
    //自己头像
    myAvatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL,[[NSUserDefaults standardUserDefaults] stringForKey:@"headImage"]];
    myAvatarImageView = [[UIImageView alloc]init];
    myAvatarImageView.backgroundColor = [UIColor clearColor];
    [myAvatarImageView setImageWithURL:[NSURL URLWithString:myAvatarURL]
                      placeholderImage:[UIImage imageWithContentsOfFile:avatarDefaultPath]];
    
    //加载历史聊天纪录。
//
    JLLog_D(@"loadMessage start");
    [self loadMessage:_start total:_pageSize flag:0];
    //[_chatTableView reloadData];
    JLLog_D(@"loadMessage end");
    
    
    //查询聊天列表是否已存在
    if ([ChatBuddyCRUD queryChatBuddyTableCountId:_chatWithUser myUserName:MY_USER_NAME]>0){
        self.chatBuddyFlag = YES;
    }
    
    // 如果进到页面之前服务器已经连接
    // 那么处理当前self.chatArray中发送中的消息
//    NSInvocationOperation *operation = [[NSInvocationOperation alloc]
//                                        initWithTarget:self
//                                        selector:@selector(resendconnectionMessage)
//                                        object:nil];
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [queue addOperation:operation];
    
    // JLLog_I(@"self.chatArray=%@", self.chatArray);
    
    [self resendconnectionMessage];
}

- (void)resendconnectionMessage
{
    NSMutableArray *muti = [@[] mutableCopy];
    NSArray *temp = [NSArray arrayWithArray:self.chatArray];
    for (NSDictionary *item in temp) {
        if ([item isKindOfClass:[NSDictionary class]]) {
            if ([item[@"sendStatus"] isEqualToString:@"connection"]) {
                [muti addObject:item];
                [self.chatArray removeObject:item];
            }
        }
    }
    
    [self.chatArray addObjectsFromArray:muti];
    
    if ([XMPPServer xmppStream].isConnected) {
        [self vc_resendConnectionMessages:muti];
    }
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else
    {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    
    
    if(_playNumber == 0){
 
        
        if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
            
            if(![UIDevice currentDevice].proximityState){
                [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            }
            
        }
        
    }
}


//响应超链接
//- (void)handleTweetNotification:(NSNotification *)notification
//{
//	NSLog(@"handleTweetNotification: notification = %@", notification);
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:notification.object]];
//
//}


-(void)msgReceipt:(NSNotification*)notify
{
    NSString *msgRandomIdStr = notify.object;
    //[_chatTableView reloadData];
    //[_ylImageview removeFromSuperview];
    NSString *msgRandomId = msgRandomIdStr;
    
    //[ChatMessageCRUD updateMsgByMsgReceipt:[msgRandomIdArray objectAtIndex:1] sendStatus:@"complete"];
    
    for (int i = 0; i < self.chatArray.count; ++i) {
        NSDictionary *dic = self.chatArray[i];
        if ([dic isKindOfClass:[NSDate class]]) {
            continue;
        }
        if ([msgRandomId isEqualToString:[dic objectForKey:@"msgRandomId"]]) {
            // Need to reload table view after sending document finished
            // cause that message content has updated, or document previewing would be failed
            if ([dic[@"subject"] isEqualToString:@"document"]) {
                NSMutableDictionary *md = [NSMutableDictionary dictionaryWithDictionary:dic];
                NSString *message = [ChatMessageCRUD queryMsgByMsgId:[dic[@"msgId"] intValue]];
                [md setObject:message forKey:@"text"];
                [self.chatArray replaceObjectAtIndex:i withObject:md];
            }
            
            UIView *view = [dic objectForKey:@"view"];
            for(UIView *sub in view.subviews){
                if([sub isKindOfClass:YLImageView.class]){
                    [sub removeFromSuperview];
                    break;
                }
            }
            break;
        }
    }
}


//弹出菜单
#pragma mark -
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    if (action == @selector(deleteMsgAction:) ||
        action == @selector(broomAction:) ||
        action == @selector(textAction:))
        return YES;
    
    return [super canPerformAction:action withSender:sender];
}

#pragma mark - privates
- (void)pressme:(id )sender
{
    int index = self.menuIndexPath.row;
    NSDictionary *item = [self.chatArray objectAtIndex:index];
    
    NSString *msgType = [item objectForKey:@"type"];
    NSString *subject = [item objectForKey:@"subject"];
    NSString *sendStatus = [item objectForKey:@"sendStatus"];
    
    if ([msgType isEqualToString:@"chat"] && [subject isEqualToString:@"chat"]) {
        //弹出菜单
        if ([sendStatus isEqualToString:@"disconnect"]) {
            //重发
            UIMenuItem *reSendItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.reSendMsg",@"action") action:@selector(resendMessage)];
            //复制
            UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.copy",@"action") action:@selector(copyTextAction:)];
            //删除
            UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
            [UIMenuController sharedMenuController].menuItems = @[reSendItem,deleteItem, copyItem];
        }else{
            
            //复制
            UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.copy",@"action") action:@selector(copyTextAction:)];
            //删除
            UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
            //转发
            UIMenuItem *retweetItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(retweetMessageAction:)];
            //收藏
            UIMenuItem *collectItem = [[UIMenuItem alloc] initWithTitle:@"收藏" action:@selector(collectMessageAction:)];
            
            [UIMenuController sharedMenuController].menuItems = @[deleteItem, copyItem, retweetItem, collectItem];
            
        }
        
    }else if([msgType isEqualToString:@"chat"]&& [subject isEqualToString:@"image"]){
        //弹出菜单
        // UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"复制", nil) action:@selector(deleteMsgAction:)];
        if ([sendStatus isEqualToString:@"disconnect"]) {
            //重发
            UIMenuItem *reSendItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.reSendMsg",@"action") action:@selector(resendMessage)];
            //删除
            UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
            
            [UIMenuController sharedMenuController].menuItems = @[reSendItem,deleteItem];
            
            
        }else{
            //删除
            UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
            //转发
            UIMenuItem *retweetItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(retweetMessageAction:)];
            //收藏
            UIMenuItem *collectItem = [[UIMenuItem alloc] initWithTitle:@"收藏" action:@selector(collectMessageAction:)];
            
            [UIMenuController sharedMenuController].menuItems = @[deleteItem, retweetItem, collectItem];
        }
        
    }else if([msgType isEqualToString:@"chat"]&& [subject isEqualToString:@"voice"]){
        //弹出菜单
        if ([self.playMode isEqualToString:@"Play"]) {
            
            if ([sendStatus isEqualToString:@"disconnect"]) {
                //删除
                UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
                //扬声器播放
                UIMenuItem *switchoverItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.speakerMode",@"action") action:@selector(switchoverItemAction:)];
                //重发
                UIMenuItem *reSendItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.reSendMsg",@"action") action:@selector(resendMessage)];
                
                [UIMenuController sharedMenuController].menuItems = @[reSendItem,deleteItem,switchoverItem];
                
            }else{
                //删除
                UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
                //扬声器播放
                UIMenuItem *switchoverItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.speakerMode",@"action") action:@selector(switchoverItemAction:)];
                
                //收藏
                UIMenuItem *collectItem = [[UIMenuItem alloc] initWithTitle:@"收藏" action:@selector(collectMessageAction:)];
                [UIMenuController sharedMenuController].menuItems = @[deleteItem, switchoverItem];
            }
            
        }else{
            
            
            if ([sendStatus isEqualToString:@"disconnect"]) {
                //删除
                UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
                //听筒播放
                UIMenuItem *switchoverItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.handsetMode",@"action") action:@selector(switchoverItemAction:)];
                
                //重发
                UIMenuItem *reSendItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.reSendMsg",@"action") action:@selector(resendMessage)];
                
                [UIMenuController sharedMenuController].menuItems = @[reSendItem,deleteItem,switchoverItem];
                
            }else{
                //删除
                UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
                //听筒播放
                UIMenuItem *switchoverItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.handsetMode",@"action") action:@selector(switchoverItemAction:)];
                [UIMenuController sharedMenuController].menuItems = @[deleteItem, switchoverItem];
            }
        }
        
    }else if([msgType isEqualToString:@"chat"]&& [subject isEqualToString:@"phone"]){
        //删除
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
        [UIMenuController sharedMenuController].menuItems = @[deleteItem];
        
        
        
    }else if([msgType isEqualToString:@"chat"]&& [subject isEqualToString:@"video"]){
        //删除
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
        [UIMenuController sharedMenuController].menuItems = @[deleteItem];
        
    }else if ([msgType isEqualToString:@"chat"] && [subject isEqualToString:@"document"]) {
        if ([sendStatus isEqualToString:@"disconnect"])
        {
        UIMenuItem *reSendItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.reSendMsg",@"action") action:@selector(resendMessage)];
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
        [UIMenuController sharedMenuController].menuItems = @[deleteItem, reSendItem];
        }
        else
        {
            UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
            UIMenuItem *retweetItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(retweetMessageAction:)];
            UIMenuItem *collectItem = [[UIMenuItem alloc] initWithTitle:@"收藏" action:@selector(collectMessageAction:)];
            [UIMenuController sharedMenuController].menuItems = @[deleteItem, retweetItem,collectItem];
        }
    }else if ([msgType isEqualToString:@"chat"] && [subject isEqualToString:@"card"]) {
        if ([sendStatus isEqualToString:@"disconnect"])
        {
            UIMenuItem *reSendItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.reSendMsg",@"action") action:@selector(resendMessage)];
            UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
            [UIMenuController sharedMenuController].menuItems = @[deleteItem, reSendItem];
        }
        else
        {
            UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
            UIMenuItem *retweetItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(retweetMessageAction:)];
            [UIMenuController sharedMenuController].menuItems = @[deleteItem, retweetItem];
        }
    }else if ([msgType isEqualToString:@"chat"] && [subject isEqualToString:@"location"]) {
        if ([sendStatus isEqualToString:@"disconnect"])
        {
            UIMenuItem *reSendItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.reSendMsg",@"action") action:@selector(resendMessage)];
            UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
            [UIMenuController sharedMenuController].menuItems = @[deleteItem, reSendItem];
        }
        else
        {
            UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
            UIMenuItem *retweetItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(retweetMessageAction:)];
            [UIMenuController sharedMenuController].menuItems = @[deleteItem, retweetItem];
        }
    }else if ([msgType isEqualToString:@"chat"] && [subject isEqualToString:@"article"]) {
        if ([sendStatus isEqualToString:@"disconnect"])
        {
//            UIMenuItem *reSendItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.reSendMsg",@"action") action:@selector(resendMessage)];
//            UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
//            [UIMenuController sharedMenuController].menuItems = @[deleteItem, reSendItem];
        }
        else
        {
            UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"chatviewPublic.delete",@"action") action:@selector(deleteMsgAction:)];
            UIMenuItem *retweetItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(retweetMessageAction:)];
            UIMenuItem *collectItem = [[UIMenuItem alloc] initWithTitle:@"收藏" action:@selector(collectMessageAction:)];
            [UIMenuController sharedMenuController].menuItems = @[deleteItem, retweetItem, collectItem];
        }

    }
    
    //NSLog(@"%@",NSStringFromCGRect([sender frame]));
    [[UIMenuController sharedMenuController] setTargetRect:[sender frame] inView:self.view];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}

#pragma mark
#pragma mark retweet & collection

//转发
- (void)retweetMessageAction:(id)sender
{
    //[self tapOnce];
    int index = self.menuIndexPath.row;
    NSDictionary *item = [self.chatArray objectAtIndex:index];
    NSInteger messageId = [item[@"msgId"] integerValue];
    NSString *subject = item[@"subject"];
    
    // If it's a type of image message, link would be assets-library URL path cause
    // having updated chatArray when finish sending message XML contruct.
    // In this case, we need to query message body from sqlite.
    NSMutableDictionary *reitem = [NSMutableDictionary dictionaryWithDictionary:item];
    if ([subject isEqualToString:@"image"]) {
        NSString *message = [ChatMessageCRUD queryMsgByMsgId:messageId];
        [reitem setObject:message forKey:@"text"];
    }
    
    if ([subject isEqualToString:@"document"]) {
        AIDocument *document = [AIDocument documentWithJson:item[@"text"]];
        NSString *key = [NSString stringWithFormat:@"%@_%@", document.link, _chatWithUser];
        BOOL isExists = [mResourceCache isExistsDocumentForKey:document.link ofType:document.fileType];
        BOOL downloading = ([AIDocumentDownloadManager requestWithKey:key] != nil);
        if (!isExists || downloading) {
            [self alertViewShowAttention:@"选择的消息中，未下载的图片、文件不能转发"];
            return;
        }
    }
    
    AICurrentContactController *controller = [[AICurrentContactController alloc] init];
    controller.fromUserName = _chatWithUser;
    controller.delegate = self;        // Delegate for reloading table view case when dismiss 'controller'
    controller.messages = @[reitem];
    AINavigationController *navigation = [[AINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigation animated:YES completion:nil];
}

//收藏
- (void)collectMessageAction:(id)sender
{
    //[self tapOnce];
    int index = self.menuIndexPath.row;
    NSDictionary *item = [self.chatArray objectAtIndex:index];
    _collectedMessage = item;
    [self sendCollectionIQ:item];
    [AIControllersTool loadingViewShow:self];
}

- (void)sendCollectionIQ:(NSDictionary *)item
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *sender    = item[@"speaker"];
        NSString *message   = item[@"text"];
        NSString *messageId = item[@"msgId"];
        int message_type    = [self messageType:item];
        int source_type     = [self sourceType:item];
        
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        [iq addAttributeWithName:@"id" stringValue:@"AI_Collection_Create"];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:kStoreupNameSpace];
        
        NSXMLElement *storeup = [NSXMLElement elementWithName:@"storeUp"];
        [storeup addAttributeWithName:@"tempId" stringValue:messageId];
        [storeup addAttributeWithName:@"do" stringValue:@"create"];
        
        NSXMLElement *xml_sender = [NSXMLElement elementWithName:@"sender" stringValue:sender];
        NSXMLElement *xml_message = [NSXMLElement elementWithName:@"message" stringValue:message];
        NSXMLElement *xml_message_type = [NSXMLElement elementWithName:@"msgType" stringValue:[NSString stringWithFormat:@"%d", message_type]];
        NSXMLElement *xml_source_type = [NSXMLElement elementWithName:@"source" stringValue:[NSString stringWithFormat:@"%d", source_type]];
        NSXMLElement *xml_circle_id = [NSXMLElement elementWithName:@"circleId" stringValue:@""];
        
        [storeup addChild:xml_message];
        [storeup addChild:xml_message_type];
        [storeup addChild:xml_sender];
        [storeup addChild:xml_source_type];
        [storeup addChild:xml_circle_id];
        
        [query addChild:storeup];
        [iq addChild:query];
        
        [[XMPPServer xmppStream] sendElement:iq];
        
        // Copy file to folder 'collection' if exists.
        switch (message_type) {
            case AIMessageTypeDocument: {
                AIDocument *document = [AIDocument documentWithJson:message];
                [mResourceCache copyItemWithKey:document.link type:document.fileType to:@"collection"];
            }
                break;
                
            case AIMessageTypePicture: {
                message = [message stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
                NSDictionary *picDic = [message objectFromJSONString];
                NSString* imageLink = [picDic objectForKey:@"link"];
                UIImage *image = [mResourceCache imageForKey:imageLink];
                if (image) {
                    AIChatResourceCache *cache = [AIChatResourceCache cacheWithUserName:@"collection"];
                    [cache storeImage:image forKey:imageLink];
                }
            }
                break;
                
            default:
                break;
        }
        
    });
}

- (AIMessageType)messageType:(NSDictionary *)aItem
{
    NSString *subject = aItem[@"subject"];
    
    if ([subject isEqualToString:@"voice"]) {
        return AIMessageTypeVoice;
    }else if ([subject isEqualToString:@"image"]) {
        return AIMessageTypePicture;
    }else if ([subject isEqualToString:@"document"]) {
        return AIMessageTypeDocument;
    }else if ([subject isEqualToString:@"article"]) {
        return AIMessageTypeArticle;
    }
    else {
        return AIMessageTypeText;
    }
}

- (AICollectionSourceType)sourceType:(NSDictionary *)aItem
{
    NSString *type = aItem[@"type"];
    
    if ([type isEqualToString:@"chat"]) {
        return AICollectionSourceTypeChat;
    }else {
        return AICollectionSourceTypeGroupChat;
    }
}

/**
 *  collection create response
 */

- (void)collectionCreateReturn:(NSNotification *)n
{
    [AIControllersTool loadingVieHide:self];
    
    if (!_collectedMessage) {
        return;
    }
    
    NSDictionary *userInfo = [n userInfo];
    BOOL isSucceed = [userInfo[@"success"] boolValue];
    if (isSucceed) {
//        int index = self.menuIndexPath.row;
//        NSDictionary *item = [self.chatArray objectAtIndex:index];
        
        NSDictionary *item = _collectedMessage;
        AICollection *collection = [[AICollection alloc] init];
        collection.sender = item[@"speaker"];
        collection.owner = MY_USER_NAME;
        collection.message = item[@"text"];
        collection.messageType = [self messageType:item];
        collection.sourceType = [self sourceType:item];
        collection.circleID = @"";
        collection.createDate = userInfo[@"create_date"];
        collection.serviceId = userInfo[@"id"];
        
        // If it's image message, then copy image to "collection" directory
        if (collection.messageType == AIMessageTypePicture) {
            // Use name space @"collection" to find the collection cache directory.
            AIChatResourceCache *cache = [AIChatResourceCache cacheWithUserName:@"collection"];
            NSString *aKey = [AIMessageTool HDImageLinkIdWithMessage:collection.message];
            NSString *tfsLink =[NSString stringWithFormat:@"%@/%@",ResourcesURL, aKey];
            UIImage *aImage = [mResourceCache imageForKey:tfsLink];
            if (aImage) {
                [cache storeImage:aImage forKey:tfsLink];
            }
        }
        
        [AICollectionCRUD insertCollection:collection];
        [AIControllersTool tipViewShow:@"收藏成功，可以在“我-我的收藏”中查看"];
        
        JLLog_D(@"storeup success <controller=%p>", self);
    }else {
        [AIControllersTool tipViewShow:@"收藏失败，请稍后重试"];
    }
    
    _collectedMessage = nil; //needed.
}

- (void)collectionCreateError:(NSNotification *)n
{
    [AIControllersTool loadingVieHide:self];
    [AIControllersTool tipViewShow:@"服务器出错，请稍后重试"];
}

#pragma end

//删除消息
- (void)deleteMsgAction:(id)sender
{
    int index = self.menuIndexPath.row;
    NSDictionary *item = [self.chatArray objectAtIndex:index];
    NSString *msgId = [item objectForKey:@"msgId"];

    id prev = self.chatArray[index-1];
    BOOL hasNext = index+1 < self.chatArray.count;
    id next = hasNext?self.chatArray[index+1]:nil;
    if([prev isKindOfClass:NSDate.class] && (next == nil || [next isKindOfClass:NSDate.class])){
        [self.chatArray removeObject:prev];
    }
    
    [ChatMessageCRUD deleteChatMessage:msgId];
    [self.chatArray removeObject:item];
    
    [self.chatTableView reloadData];
}

//删除消息
- (void)collectMsgAction:(id)sender
{
    int index = self.menuIndexPath.row;
    NSLog(@"收藏消息*****%d",index);
    
    NSDictionary *item = [self.chatArray objectAtIndex:index];
    
    if (index>0) {
        if ([[self.chatArray objectAtIndex:index-1] isKindOfClass:[NSDate class]]) {
        }else{
            
        }
    }else{
    }
    [self.chatTableView reloadData];
    
}

//复制消息
- (void)copyTextAction:(id)sender
{
    // [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"copy Item Pressed", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil] show];
    int index = self.menuIndexPath.row;
    NSDictionary *item = [self.chatArray objectAtIndex:index];
    NSString *text = [item objectForKey:@"text"];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = text;
}

- (void)messagesend:(NSString *)aBody
           randomId:(NSString *)aRandomId
            subject:(NSString *)aSubject
               time:(NSString *)aTime {
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:aBody];
    NSXMLElement *req = [NSXMLElement elementWithName:@"req" xmlns:@"urn:xmpp:receipts"];
    [req addAttributeWithName:@"id" stringValue:aRandomId];
    //消息类型
    NSXMLElement *mtype = [NSXMLElement elementWithName:@"mtype"  xmlns:@"message:type"];
    [mtype setStringValue:aSubject];
    //主题
    NSXMLElement *subject = [NSXMLElement elementWithName:@"subject" stringValue:aSubject];
    //生成XML消息文档
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    //消息ID
    [mes addAttributeWithName:@"id" stringValue:aRandomId];
    //消息类型
    [mes addAttributeWithName:@"type" stringValue:@"chat"];
    //发送给谁
    [mes addAttributeWithName:@"to" stringValue:_chatWithJID];
    //由谁发送
    [mes addAttributeWithName:@"from" stringValue:MY_JID];
    //发送时间
    [mes addAttributeWithName:@"time" stringValue:aTime];
    //组合
    [mes addChild:mtype];
    [mes addChild:subject];
    [mes addChild:body];
    [mes addChild:req];
    
    JLLog_I(@"<message send> %@", mes);
    
    //发送消息
    [[XMPPServer xmppStream] sendElement:mes];
}

- (void)networkReconnect
{
    // Muti Thread..
    //NSInvocationOperation *operation = [[NSInvocationOperation alloc]
                                        //initWithTarget:self
                                        //selector:@selector(resendconnectionMessage)
                                        //object:nil];
    //NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //[queue addOperation:operation];
    
    [self resendconnectionMessage];
}

- (void)vc_resendConnectionMessages:(NSArray *)array
{
    //JLLog_I(@"resend arrat=%@", array);
    
    for (NSDictionary *dictionary in array) {
        [self resendMessage:dictionary];
    }
    [self.chatTableView reloadData];
}

// Long pressed  to resend message
-(void)resendMessage
{
    int index = self.menuIndexPath.row;
    NSDictionary *item = [self.chatArray objectAtIndex:index];

    NSMutableDictionary *reItem = [item mutableCopy];
    UIView *aView = reItem[@"view"];
    UIView *cautionView = [aView viewWithTag:12345];
    CGRect rect = cautionView.frame;
    [cautionView removeFromSuperview];
    _ylImageview = [[YLImageView alloc] initWithFrame:rect];
    _ylImageview.image = [YLGIFImage imageNamed:@"loading.gif"];
    [aView addSubview:_ylImageview];

    reItem[@"sendStatus"] = @"connection";
    [self.chatArray replaceObjectAtIndex:index withObject:reItem];
    
    [self resendMessage:item];
    
    [self sendToButtomAtIndex:index];
}

- (void)resendMessage:(NSDictionary *)item
{
    NSString *msg= [item objectForKey:@"text"];
    NSString *subject= [item objectForKey:@"subject"];
    NSString *messageId = item[@"msgId"];
    NSString *messageRandomId = item[@"msgRandomId"];
    
    NSString *sendTimeStr =[Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    NSLog(@"****%@",sendTimeStr);

    NSString *sendUTCTimeStr = [Utility getUTCFormateLocalDate:sendTimeStr];
  
    NSString *sendTime = [Utility UTCFormatToLocalFormat:sendUTCTimeStr];
    
    [ChatMessageCRUD updateMessage:messageId sendTime:sendUTCTimeStr];
    
    if ([subject isEqualToString:@"chat"] || [subject isEqualToString:@"card"] || [subject isEqualToString:@"location"]) {
        
        NSString *aSubject = nil;
        if ([subject isEqualToString:@"chat"]) {
            aSubject = @"chat";
        }else if ([subject isEqualToString:@"card"]) {
            aSubject = @"card";
        }else {
            aSubject = @"location";
        }
        
//        UIView *view = [self bubbleView:msg msgId:messageId msgRandomId:messageRandomId from:YES type:@"chat" subject:subject avatar:avatarImage sendStatus:network];
//        NSMutableDictionary *new = [NSMutableDictionary dictionaryWithDictionary:item];
//        [new setObject:view forKey:@"view"];
//        [new setObject:network forKey:@"sendStatus"];
        //[self.chatArray replaceObjectAtIndex:index withObject:new];
        [self messagesend:msg randomId:messageRandomId subject:aSubject time:sendTime];
        
    }else if([subject isEqualToString:@"voice"]){
        
        msg = [msg stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSDictionary *voiceDic = [msg objectFromJSONString];
        NSString* voicePath = [voiceDic objectForKey:@"link"];
        NSArray *comps = [voicePath componentsSeparatedByString:@"Documents"];
        if(comps.count > 1){
            voicePath = comps[1];
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [paths objectAtIndex:0];
        voicePath = [NSString stringWithFormat:@"%@%@", docPath, voicePath];
        
        NSString *amrPath = [VoiceConverter wavToAmr:voicePath];
        
        /**
         *  _timeLen 是记录当前发送语音的时长 如果退出当前聊天界面，再次进入该界面 _timeLen被清空
         *  那么重发时，sendVoiceLink中获取的语音时长是0，这会让对方显示的数据错误
         
         *  _voiceRandomId也是一样，重发的时候也应该记录重发语音的randomId，否则loading view不会消失
         */
        
//        _timeLen = [[voiceDic objectForKey:@"time"] floatValue];
//        _voiceMsgRandomId = messageRandomId;
        
        int voiceTime = [[voiceDic objectForKey:@"time"] intValue];
        
        NSMutableData *recordData = [NSMutableData dataWithContentsOfFile:amrPath];
        //保留wav删除amr
        [[ChatCacheFileUtil sharedInstance] deleteWithContentPath:amrPath];
        _lastRecordFile = [[voicePath lastPathComponent] copy];
        
//        VoiceBody *body = [[VoiceBody alloc] init];
//        body.path = @"";
//        body.time = [NSNumber numberWithInt:voiceTime];
//        body.src = @"";
//        body.link =voicePath;
        //NSDictionary *dic = [body toDictionary];
        //NSString * bodyJsonStr = [dic JSONString];
        
//        UIView *view = [self bubbleView:bodyJsonStr msgId:messageId msgRandomId:messageRandomId from:YES type:@"chat" subject:@"voice" avatar:avatarImage sendStatus:network];
//        NSMutableDictionary *new = [NSMutableDictionary dictionaryWithDictionary:item];
//        [new setObject:view forKey:@"view"];
//        [new setObject:network forKey:@"sendStatus"];
        //[self.chatArray replaceObjectAtIndex:index withObject:new];
        [self upLoadVoiceData:recordData length:voiceTime randomId:messageRandomId];
        
    }
    else if ([subject isEqualToString:@"document"]) {
        
//        UIView *view = [self bubbleView:msg
//                                  msgId:messageId
//                            msgRandomId:messageRandomId
//                                   from:YES type:@"chat"
//                                subject:@"document"
//                                 avatar:avatarImage
//                             sendStatus:network];
//        
//        NSMutableDictionary *new = [NSMutableDictionary dictionaryWithDictionary:item];
//        [new setObject:view forKey:@"view"];
//        [new setObject:network forKey:@"sendStatus"];
        // [self.chatArray replaceObjectAtIndex:index withObject:new];
        
        AIDocument *document = [AIDocument documentWithJson:msg];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL flag = [fileManager fileExistsAtPath:document.link];
        if (flag) {
            NSData *data = [fileManager contentsAtPath:document.link];
            [self uploadData:data complete:^(NSString *TFSlink) {
                document.link = TFSlink;
                [self sendMessageXMLContruct:document.documentMessageBody
                                    randomId:messageRandomId
                                     subject:@"document"
                                    chatType:@"chat"
                                          to:_chatWithUser];
                [mResourceCache storeDocument:data
                                         type:document.fileType
                                       forKey:TFSlink];
                [ChatMessageCRUD updateMsgByMsgRandomId:messageRandomId
                                                 msg:document.documentMessageBody];
            } fail:^{
                
                [ChatMessageCRUD updateMsgByMsgReceipt:item[@"msgRandomId"] sendStatus:@"disconnect"];
                
                NSMutableDictionary *new = [NSMutableDictionary dictionaryWithDictionary:item];
                new[@"sendStatus"] = @"disconnect";
                [self.chatArray replaceObjectAtIndex:[self.chatArray indexOfObject:item] withObject:new];
                
                UIView *view = [item objectForKey:@"view"];
                UIImageView *warningImageView = [[UIImageView alloc] init];
                
                warningImageView.contentMode = UIViewContentModeScaleAspectFit;
                warningImageView.image = [UIImage imageNamed:@"icon_cuation"];
                
                for(UIView *sub in view.subviews){
                    if([sub isKindOfClass:YLImageView.class]){
                        warningImageView.frame = sub.frame;
                        [view addSubview:warningImageView];
                        [sub removeFromSuperview];
                        break;
                    }
                }
            }];
        }else {
            [self sendMessageXMLContruct:msg
                                randomId:messageRandomId
                                 subject:@"document"
                                chatType:@"chat"
                                      to:_chatWithUser];
        }
    }
    else{
        msg = [msg stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        
        NSDictionary *picDic = [msg objectFromJSONString];
        NSString* imageLink = [picDic objectForKey:@"link"];
        
//        UIView *view = [self bubbleView:msg msgId:messageId msgRandomId:messageRandomId from:YES type:@"chat" subject:@"image" avatar:avatarImage sendStatus:network];
//        NSMutableDictionary *new = [NSMutableDictionary dictionaryWithDictionary:item];
//        [new setObject:view forKey:@"view"];
//        [new setObject:network forKey:@"sendStatus"];
        //[self.chatArray replaceObjectAtIndex:index withObject:new];

        // If image have'n been uploaded, the link would be the assert library path
        // In this case, we need to upload this image and send the message XML contruct with tfs link
        //
        // If this image have even been uploaded, the link would be the tfs link
        // what we do just send the message XML contruct
        if ([[imageLink lowercaseString] hasPrefix:@"assets-library"]) {
            NSURL *imageURL = [NSURL URLWithString:imageLink];
            @try {
                ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
                [assetslibrary assetForURL:imageURL
                               resultBlock:^(ALAsset *asset){
                                   ALAssetRepresentation *rep = [asset defaultRepresentation];
                                   CGImageRef iref = [rep fullResolutionImage];
                                   if (iref) {
                                       UIImage*img = [UIImage imageWithCGImage:iref
                                                                         scale:[rep scale]
                                                                   orientation:(UIImageOrientation)[rep orientation]];
                                       
                                       [self reuploadImage:img randomId:messageRandomId];
                                   }
                               }
                              failureBlock:^(NSError *error) {
                                  MWLog(@"Photo from asset library error: %@",error);
                                  
                              }];
            } @catch (NSException *e) {
                MWLog(@"Photo from asset library error: %@", e);
            }
        }else {
            [self sendImageMessageXMLContruct:msg randomId:messageRandomId];
        }
    }
}


- (void)switchoverItemAction:(id)sender
{
    if([self.playMode isEqualToString:@"Play"]){
        self.playMode = @"Playback";
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        //扬声器模式
        [CSNotificationView showInViewController:self
                                       tintColor:[UIColor colorWithRed:0.800 green:0.2 blue:1 alpha:1]
                                           image:nil
                                         message:NSLocalizedString(@"chatviewPublic.speakerModeMsg",@"message")
                                        duration:2.0f];
        
        
    }else{
        self.playMode = @"Play";
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        //听筒模式
        [CSNotificationView showInViewController:self
                                       tintColor:[UIColor colorWithRed:0.800 green:0.2 blue:1 alpha:1]
                                           image:nil
                                         message:NSLocalizedString(@"chatviewPublic.handsetModeMsg",@"message")                                        duration:2.0f];
    }
}

-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    // gesture.view.backgroundColor = [UIColor redColor];
    
    for(UIImageView *view  in gesture.view.subviews){
        if([view isKindOfClass:[UIImageView class]]){
            
            if (!view.image) {  // 如果是Card类型消息，长按时候不需要有bubble。
                break;
            }
            
            //[view setBackgroundColor:bgColor];
            if (gesture.view.tag!=3) {
                NSLog(@"****%d",gesture.view.tag);
                if (gesture.state ==
                    UIGestureRecognizerStateBegan) {
                    NSLog(@"UIGestureRecognizerStateBegan");
                    view.image = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:gesture.view.tag?@"chat_bg_outgoing@2x":@"chat_bg_incomming@2x" ofType:@"png"]] stretchableImageWithLeftCapWidth:10 topCapHeight:15];
                }
                if (gesture.state ==
                    UIGestureRecognizerStateChanged) {
                    NSLog(@"UIGestureRecognizerStateChanged");
                }
                
                if (gesture.state == UIGestureRecognizerStateEnded) {
                    view.image = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:gesture.view.tag?@"chat_bg_outgoing@2x":@"chat_bg_incomming@2x" ofType:@"png"]] stretchableImageWithLeftCapWidth:10 topCapHeight:15];
                    NSLog(@"UIGestureRecognizerStateEnded");
                }
                
                //                if (gesture.view.tag) {
                //                    view.tag = 30001;
                //
                //                }else{
                //                    view.tag = 30002;
                //                }
            }
            
        }
    }
    
    
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint currentPoint = [gesture locationInView:self.view];
        CGPoint tablePoint = [gesture locationInView:self.chatTableView];
        
        NSIndexPath * indexPath = [self.chatTableView indexPathForRowAtPoint:tablePoint];
        
        //删除时所用
        self.menuIndexPath = indexPath;
        
        if(indexPath == nil) return ;
        //add your code here
        //NSLog(@"*****%d",indexPath.row);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = btn.frame;
        btn.frame =
        CGRectOffset(frame, currentPoint.x, currentPoint.y-20);
        //CGRectMake(currentPoint.x, currentPoint.y, 0, 0);
        [self pressme:btn];
        //[self showPopupMenu3:indexPath];
    }
}

- (void)sendCard
{
    AICardSelectedViewController *controller = [[AICardSelectedViewController alloc] init];
    controller.oppositeJID = _chatWithJID;
    controller.delegate = self;
    controller.chatType = AIChatTypeChat;
    AINavigationController *navigation = [[AINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void)sendLocation
{
    BaiduMapViewController *controller = [[BaiduMapViewController alloc] init];
    controller.delegate = self;
    controller.showsUserLocation = YES;
    AINavigationController *nav = [[AINavigationController alloc]initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}


/*---视频语音start-----------------------------------------------------------------------------------*/
//打电话
-(void)playDial{
    //NSLog(@"开始拨打电话");
#if !TARGET_IPHONE_SIMULATOR
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                // Microphone enabled code
                [MyServices playDial:_chatWithJID name:_chatWithNick avatar:avatar target:self];
            }
            else {
                
                
                // We're in a background thread here, so jump to main thread to do UI work.
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                    message:@"请在\"设置/隐私/麦克风\"中允许社区访问麦克风。"
                                                                   delegate:self
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                    alert.tag = 1251;
                    [alert show];
                    
                });
            }
        }];
    }
    
    
    
#endif
}


- (void)reply:(id)sender
{
    //NSLog(@"*** reply: %@", [sender class]);
}

-(void)viewWillAppear:(BOOL)animated{
   	[super viewWillAppear:animated];
    [self setupNotifications];
    
    // 注册服务器连接状态变法通知，处理发送中的消息
    // 在此注册，在'viewWillDisappear:'中移除
    // 那么返回到对话界面的时候，不会响应通知去重发数据
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkReconnect)
                                                 name:@"NNC_Network_Status_Connection"
                                               object:nil];

    
    //隐藏键盘
    [self tapOnce];
 
    msgSoundReminder = NO;
    msgVibrateReminder = NO;
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Vibrate_Play_Mark"] isEqualToString:@"play"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"stop" forKey:@"NSUD_Vibrate_Play_Mark"];
        msgVibrateReminder = YES;
    }else{
        msgVibrateReminder=NO;
    }
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Sound_Play_Mark"] isEqualToString:@"play"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"stop" forKey:@"NSUD_Sound_Play_Mark"];
        msgSoundReminder = YES;
    }else{
        msgSoundReminder=NO;
    }
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    [self.messageTextField setText:self.messageString];
    
    _messgaeFlag=@"UpdateMessageFlag";
    
    //更新消息状态为已读
    [ChatMessageCRUD updateFlagByUserName:_chatWithUser userName:MY_USER_NAME];
    
    
    [self sendBadgeNum];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification"
                                               object:nil];
    
    
    
}

-(void)sendBadgeNum{
    int unreadTotal = [ChatBuddyCRUD queryAllMsgTotal];
    [self sendBadge:[NSString stringWithFormat:@"%d",unreadTotal]];
    JLLog_D(@"sendBadge");
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

- (void)tearNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center removeObserver:self
                      name:@"AI_Collection_Create_Return"
                    object:nil];
    
    [center removeObserver:self
                      name:@"AI_Collection_Create_Error"
                    object:nil];
    
    [center removeObserver:self
                      name:@"AI_Contact_Info_Return"
                    object:nil];
    
    [center removeObserver:self
                      name:@"AI_Contact_Info_Error"
                    object:nil];
    
    [center removeObserver:self
                      name:@"NNC_UpdateContact"
                    object:nil];
}


-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    // 移除通知，那么在退到对话界面的时候
    // 便不会响应通知重发未发送出去的消息
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"NNC_Network_Status_Connection"
                                                  object:nil];
    
    
    //停止播放声音
    [audioPlayer stop];
    
    if (msgSoundReminder) {
        [[NSUserDefaults standardUserDefaults] setObject:@"play" forKey:@"NSUD_Sound_Play_Mark"];
    }
    if (msgVibrateReminder) {
        [[NSUserDefaults standardUserDefaults] setObject:@"play" forKey:@"NSUD_Vibrate_Play_Mark"];
    }
    
    
    // CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
    // appDelegate.tabBarBG.hidden = NO;
    _messgaeFlag=@"";
    //更新消息状态为已读
    [ChatMessageCRUD updateFlagByUserName:_chatWithUser userName:MY_USER_NAME];
    
    //发送通知，刷新聊天列表消息总数目;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Chat_Buddy_View_Msg_Refresh" object:self userInfo:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    [self tapOnce];
}


//发送消息
-(IBAction)sendMessage_Click:(id)sender
{
    
    NSString *messageStr = self.messageToolView.messageInputTextView.text;
    if ([messageStr isEqualToString:@""])
    {
        return;
    }else
    {
        ZBMessage *zbMsg = [[ZBMessage alloc]initWithText:messageStr sender:nil timestamp:[NSDate date]];
        [self sendMessage:zbMsg];
    }
    self.messageToolView.messageInputTextView.text = @"";
    // self.messageString = self.messageTextField.text;
    self.messageString = nil;
    //[self.messageToolView.messageInputTextView resignFirstResponder];
    //[self tapOnce];
    [self.messageToolView adjustTextViewHeightBy:-19];
    
    //[self textViewDidChange:textView];
    
    //播放提示音
    [JSMessageSoundEffect playMessageSentSound];
    
    //[self switchKeyboard];
    
    //发送后，清空保存的内容
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"NSUD_Text_%@",_chatWithJID]];
    
}


//发送文本消息
-(void)sendMessage:(ZBMessage *)zbMessage
{
    NSString *message = zbMessage.text;
    if ([message isEqualToString:@""])
    {
        return;
    }
    
    //播放提示音
    [JSMessageSoundEffect playMessageSentSound];
    
    NSString * myJID =  [NSString stringWithFormat:@"%@@%@",MY_USER_NAME, OpenFireHostName];
    
    //随机ID
    NSString * msgRandomId = [IdGenerator next];
    
    //NSLog(@"发送消息@%@",message);
    //NSMutableString *sendString=[NSMutableString stringWithCapacity:1000];
    //[sendString appendString:message];
    NSString *timeString=Utility.getCurrentDate;
    
    
    
    //检测网络情况
    NSString *network = @"connection";
    NSString *sendTimeStr =[Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    NSLog(@"****%@",sendTimeStr);
//    NSString *sendUTCTimeStr = [Utility friendlyTime:sendTimeStr];
    NSString *sendUTCTimeStr = [Utility getUTCFormateLocalDate:sendTimeStr];
    NSLog(@"******%@",sendUTCTimeStr);
    //消息写入数据库
    if ([_messgaeFlag isEqualToString:@"UpdateMessageFlag"]) {
        
        //发送消息时 receiveTime 与 sendTime 一致
        [ChatMessageCRUD insertChatMessage:MY_USER_NAME msg:message receiveUser:_chatWithUser msgType:@"chat" subject:@"chat" sendTime:sendUTCTimeStr receiveTime:sendUTCTimeStr readMark:1 sendStatus:network msgRandomId:msgRandomId myJID:MY_JID];
    }
    NSDate *nowTime = [Utility getCurrentDate:@"yyyy-MM-dd HH:mm:ss"];
    if ([self.chatArray lastObject] == nil) {
        [self.chatArray addObject:nowTime];
    } else {
        NSString *current = [Utility stringFromDate:nowTime formatStr:@"yyyy-MM-dd HH:mm:ss"];
        NSString *next = [Utility stringFromDate:_lastTime formatStr:@"yyyy-MM-dd HH:mm:ss"];
        
        if(![[Utility friendlyTime:current] isEqualToString:[Utility friendlyTime:next]]){
            [self.chatArray addObject:nowTime];
        }
    }
    
    _lastTime = nowTime;

    NSString *msgId = [ChatMessageCRUD queryIdByUserName:MY_USER_NAME chatWithUser:_chatWithUser];
    //用户头像
    NSString *avatarImage = [[NSUserDefaults standardUserDefaults] stringForKey:@"headImage"];
    UIView *chatView = [self bubbleView:message msgId:msgId msgRandomId:msgRandomId from:YES type:@"chat" subject:@"chat" avatar:avatarImage  sendStatus:network];
    
    NSMutableDictionary *chatMessage = [NSMutableDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId",msgRandomId,@"msgRandomId", message, @"text", MY_USER_NAME, @"speaker",@"chat",@"type", @"chat",@"subject",network, @"sendStatus",chatView, @"view", nil];
    
    [self.chatArray addObject:chatMessage];
    
    [self.chatTableView reloadData];
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                              atScrollPosition: UITableViewScrollPositionBottom
                                      animated:YES];
    
    
    //查询聊天列表是否存在
    Contacts *contacts = nil;
    contacts = [ChatBuddyCRUD queryBuddyByJID:_chatWithJID myJID:myJID];
    UserInfo *userinfo = [UserInfoCRUD queryUserInfo:_chatWithJID myJID:MY_JID];
    NSString *lastMsgTime = [Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    if(self.chatBuddyFlag == NO){
        
        [ChatBuddyCRUD insertChatBuddyTable:_chatWithUser jid:_chatWithJID name:self.remarkName nickName:userinfo.nickName phone:userinfo.phone avatar:userinfo.avatar myUserName:MY_USER_NAME type:@"chat" lastMsg:message msgType:@"chat" msgSubject:@"chat" lastMsgTime:lastMsgTime tag:@""];
        self.chatBuddyFlag = YES;
    }else{
        
        [ChatBuddyCRUD updateChatBuddy:_chatWithUser name:self.remarkName nickName:userinfo.nickName lastMsg:message msgType:@"chat" msgSubject:@"chat" lastMsgTime:lastMsgTime];
    }
    
    //开始发送
    if (message.length > 0) {
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        //req
        NSXMLElement *req = [NSXMLElement elementWithName:@"req" xmlns:@"urn:xmpp:receipts"];
        [req addAttributeWithName:@"id" stringValue:msgRandomId];
        
        //消息类型
        NSXMLElement *mtype = [NSXMLElement elementWithName:@"mtype"  xmlns:@"message:type"];
        [mtype setStringValue:@"chat"];
        //主题
        NSXMLElement *subject = [NSXMLElement elementWithName:@"subject"];
        [subject setStringValue:@"chat"];
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息ID
        [mes addAttributeWithName:@"id" stringValue:msgRandomId];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_chatWithJID];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:MY_JID];
        //发送时间
        [mes addAttributeWithName:@"time" stringValue:timeString];
        //组合
        [mes addChild:mtype];
        [mes addChild:subject];
        [mes addChild:body];
        [mes addChild:req];
        
        JLLog_I(@"%@",mes);
        
        //发送消息
        [[XMPPServer xmppStream] sendElement:mes];
        
        self.messageTextField.text = @"";
        [self.messageTextField resignFirstResponder];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        [dictionary setObject:message forKey:@"msg"];
        [dictionary setObject:@"me" forKey:@"sender"];
        //加入发送时间
        [dictionary setObject:[Utility getCurrentTime] forKey:@"time"];
        
        [self.messages addObject:dictionary];
        
    }
    
    
}


//- (void)markAsFailed:(NSMutableDictionary*)d
//{
//    UIView *chatView = d[@"view"];
//    if(chatView == nil) return;
//    
//    for(UIView *sub in chatView.subviews){
//        if([sub isKindOfClass:YLImageView.class]){
//            CGRect frame = sub.frame;
//            [sub removeFromSuperview];
//            UIImageView *cautionView = [[UIImageView alloc] init];
//            cautionView.frame = frame;
//            cautionView.contentMode = UIViewContentModeScaleAspectFit;
//            cautionView.image = [UIImage imageNamed:@"icon_cuation"];
//            [chatView addSubview:cautionView];
//            d[@"sendStatus"] = @"disconnect";
//        }
//    }
//}

- (IBAction)clickAddBtn:(id)sender {
    _shareMoreView.hidden = NO;
    [textView setInputView: textView.inputView?nil: _shareMoreView];
    
    [textView becomeFirstResponder];
    [textView reloadInputViews];
}

- (IBAction)clickMessageTextField:(id)sender {
    //NSLog(@"messageText");
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

- (void)contactInfoRequestReturn:(NSNotification *)note
{
    [AIControllersTool loadingVieHide:self];
    [mTimer invalidate];
    NSDictionary *dict = [note userInfo];
    UserInfo *userinfo = dict[@"result"];
    ContactInfo* contactinfoVC = [[ContactInfo alloc] init];
    contactinfoVC.jid = userinfo.jid;
    contactinfoVC.userinfo = userinfo;
    contactinfoVC.rightBarButtonHidden = YES;
    [self.navigationController pushViewController:contactinfoVC animated:YES];
}

- (void)contactInfoRequestError:(NSNotification *)note
{
    [mTimer invalidate];
    [AIControllersTool loadingVieHide:self];
    [AIControllersTool tipViewShow:@"服务器出错，请稍后重试"];
}

- (void)startTicks:(NSTimer *)aTimer
{
    if (mTime != 0) {
        --mTime;
    }else {
        [aTimer invalidate];
        [AIControllersTool loadingVieHide:self];
        [AIControllersTool tipViewShow:@"请求超时"];
    }
}

- (void)sendContactInfoIQ:(NSString *)jid
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
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
    [AIControllersTool loadingViewShow:self];
    mTime = 60;
    mTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(startTicks:)
                                            userInfo:self
                                             repeats:YES];
}

- (void)documentBeenTap:(UIGestureRecognizer *)gesture
{
    CGPoint tablePoint = [gesture locationInView:self.chatTableView];
    NSIndexPath * indexPath = [self.chatTableView indexPathForRowAtPoint:tablePoint];
    if(indexPath == nil) return;
    
    NSDictionary *d = self.chatArray[indexPath.row];
    AIDocument *document = [AIDocument documentWithJson:d[@"text"]];
    
    AIPreviewController *controller = [[AIPreviewController alloc] initWithCache:mResourceCache];
    controller.docKey = document.link;
    controller.docName = document.fileName;
    controller.docType = document.fileType;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)cardBeenTap:(UIGestureRecognizer *)gesture
{
    CGPoint tablePoint = [gesture locationInView:self.chatTableView];
    NSIndexPath * indexPath = [self.chatTableView indexPathForRowAtPoint:tablePoint];
    if(indexPath == nil) return;
    
    NSDictionary *d = self.chatArray[indexPath.row];
    AIPersonalCard *card = [AIPersonalCard cardWithJson:d[@"text"]];
    NSString *jid = [NSString stringWithFormat:@"%@@%@", card.username, OpenFireHostName];
    
    NSInteger count = [UserInfoCRUD queryUserInfoTableCountId:jid myJID:MY_JID];
    if (0 == count) {
        [self sendContactInfoIQ:jid];
    }else {
        ContactInfo *contactInfo = [[ContactInfo alloc] initWithNibName:@"ContactInfo" bundle:nil];
        contactInfo.jid = jid;
        [self.navigationController pushViewController:contactInfo animated:YES];
    }
}

- (UIView *)cardViewWithOrginal:(CGPoint)point messageBody:(NSString *)text
{
    AIPersonalCard *card = [AIPersonalCard cardWithJson:text];
    NSString *avatarURLString = [NSString stringWithFormat:@"%@/%@", ResourcesURL, card.avatar];
    
    CGFloat width = kBubbleViewWidth;
    CGFloat height = 110*kScreenScale;
    UIView *v = [[UIView alloc] init];
    v.frame = (CGRect){point, CGSizeMake(width, height)};
    v.backgroundColor = AB_Color_ffffff;
    v.layer.cornerRadius = 3.0*kScreenScale;
    v.layer.masksToBounds = YES;
    
    UILabel *l = [[UILabel alloc] init];
    l.frame = (CGRect){CGPointMake(15*kScreenScale,10*kScreenScale), CGSizeMake(80*kScreenScale, 25*kScreenScale)};
    l.backgroundColor = [UIColor clearColor];
    l.text = @"名片";
    l.textColor = AB_Gray_Color;
    
    UIView *s  = [[UIView alloc] init];
    s.frame = CGRectMake(15*kScreenScale, CGRectGetMaxY(l.frame)+6*kScreenScale, width - 15 * kScreenScale * 2, 0.5);
    s.backgroundColor = Label_Back_Color;
    
    CGFloat iconView_y = CGRectGetMaxY(s.frame) + 10*kScreenScale;
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.layer.masksToBounds = YES; //没这句话它圆不起来
    iconView.layer.cornerRadius = 4.0*kScreenScale;
    iconView.frame = CGRectMake(15*kScreenScale, iconView_y, 50*kScreenScale, 50*kScreenScale);
    [iconView setImageWithURL:[NSURL URLWithString:avatarURLString]
             placeholderImage:[UIImage imageNamed:@"icon_defaultPic.png"]];
    
    CGFloat nameLabel_x = CGRectGetMaxX(iconView.frame) + 10*kScreenScale;
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(nameLabel_x, iconView_y, width - nameLabel_x - 15*kScreenScale, 22*kScreenScale);
    nameLabel.textColor= UIColorFromRGB(0x403b36);
    nameLabel.text = card.name;
    
    CGFloat accountNameLabel_y = CGRectGetMaxY(nameLabel.frame) + 1;
    UILabel *accountNameLabel = [[UILabel alloc] init];
    accountNameLabel.textColor= UIColorFromRGB(0xc3bdb4);
    accountNameLabel.frame = CGRectMake(nameLabel_x, accountNameLabel_y, width - nameLabel_x - 15*kScreenScale, 22*kScreenScale);
    accountNameLabel.text = card.accountName;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardBeenTap:)];
    v.userInteractionEnabled = YES;
    [v addGestureRecognizer:tap];
    
    [v addSubview:l];
    [v addSubview:s];
    [v addSubview:iconView];
    [v addSubview:nameLabel];
    [v addSubview:accountNameLabel];
    
    return v;
}

- (UIView *)articleViewWithOriginal:(CGPoint)point messageBody:(NSString *)text
{
    AIArticle *article = [AIArticle articleWithJson:text];
    
    CGFloat width = Screen_Width - 10 * 2 - kChatAvatarWidth * 2;
    UIView *v = [[UIView alloc] init];
    v.frame = (CGRect){point, CGSizeMake(width, 0)};
    v.backgroundColor = AB_Color_ffffff;
    v.layer.cornerRadius = 3.0;
    v.layer.masksToBounds = YES;
    
    CGFloat line_height = [article.title
                           sizeWithAttributes:@{NSFontAttributeName : AB_FONT_14}].height;
    
    CGRect frame = [article.title boundingRectWithSize:CGSizeMake(width - 25, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName : AB_FONT_14}
                                              context:nil];
    UILabel *title_label = [[UILabel alloc] init];
    title_label.frame = (CGRect){CGPointMake(15, 10), frame.size};
    title_label.textColor = AB_Color_403b36;
    title_label.text = article.title;
    title_label.numberOfLines = 0;
    title_label.font = AB_FONT_14;
    
    UIView *separator = [[UIView alloc] init];
    separator.frame = CGRectMake(15, CGRectGetMaxY(title_label.frame) + 8, width - 25, 0.5);
    separator.backgroundColor = AB_Color_e7e2dd;
    
    UIImageView *icon_imageView = [[UIImageView alloc] init];
    icon_imageView.frame = CGRectMake(15,
                                      CGRectGetMaxY(separator.frame) + 8,
                                      line_height * 3,
                                      line_height * 3);
    icon_imageView.image = [Photo string2Image:article.cover];
    icon_imageView.layer.masksToBounds = YES;
    icon_imageView.layer.cornerRadius = 4.0;
    
    UILabel *abstract_label = [[UILabel alloc] init];
    abstract_label.frame = CGRectMake(CGRectGetMaxX(icon_imageView.frame) + 10,
                                      icon_imageView.frame.origin.y,
                                      width - CGRectGetMaxX(icon_imageView.frame) - 10,
                                      line_height * 3);
    abstract_label.numberOfLines = 3;
    abstract_label.text = article.abstract;
    abstract_label.font = AB_FONT_14;
    abstract_label.textColor = AB_Color_c3bdb4;
    
    [v addSubview:title_label];
    [v addSubview:separator];
    [v addSubview:icon_imageView];
    [v addSubview:abstract_label];
    
    CGRect vframe = v.frame;
    vframe.size.height = CGRectGetMaxY(icon_imageView.frame) + 10;
    v.frame = vframe;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoWebView:)];
    v.userInteractionEnabled = YES;
    [v addGestureRecognizer:tap];
    
    return v;
}

-(void)gotoWebView:(UIGestureRecognizer *)gesture
{
    CGPoint tablePoint = [gesture locationInView:self.chatTableView];
    NSIndexPath * indexPath = [self.chatTableView indexPathForRowAtPoint:tablePoint];
    if(indexPath == nil) return;
    
    NSDictionary *dict = self.chatArray[indexPath.row];
    NSString *msg = dict[@"text"];
    
    if([StrUtility isBlankString:msg]) return;
    
    AIArticle *artile = [AIArticle articleWithJson:msg];
    AIUIWebViewController *controller = [[AIUIWebViewController alloc]init];
    controller.url = artile.src;
    controller.usingCache = NO;
    controller.mode = AIUIWebViewModePresent;
    AINavigationController *nav = [[AINavigationController alloc]initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}

- (UIView *)documentViewWithOriginal:(CGPoint)point messageBody:(NSString *)text
{
    AIDocument *document = [AIDocument documentWithJson:text];
    NSString *icon_name = nil;
    if ([document.fileType isEqualToString:@"pdf"]) {
        icon_name = @"icon_pdf";
    }else if ([document.fileType isEqualToString:@"ppt"] || [document.fileType isEqualToString:@"pptx"]) {
        icon_name = @"icon_ppt";
    }else if ([document.fileType isEqualToString:@"doc"] || [document.fileType isEqualToString:@"docx"]) {
        icon_name = @"icon_word";
    }else if ([document.fileType isEqualToString:@"xls"] || [document.fileType isEqualToString:@"xlsx"]) {
        icon_name = @"icon_excel";
    }
    
    CGFloat width = Screen_Width - 10 * 2 - kChatAvatarWidth * 2;
    CGFloat height = 70.0;
    UIView *v = [[UIView alloc] init];
    v.frame = (CGRect){point, CGSizeMake(width, height)};
    v.backgroundColor = AB_Color_ffffff;
    v.layer.cornerRadius = 3.0;
    v.layer.masksToBounds = YES;
    
    UIImageView *icon = [[UIImageView alloc] init];
    icon.frame = CGRectMake(15, 10, 50, 50);
    icon.layer.cornerRadius = 4.0;
    icon.layer.masksToBounds = YES;
    icon.image = [UIImage imageNamed:icon_name];
    
    CGFloat nameLabel_x = CGRectGetMaxX(icon.frame) + 10;
    CGFloat nameLabel_w = width - nameLabel_x - 15;
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(nameLabel_x, 10, nameLabel_w, 32);
    nameLabel.numberOfLines = 2;
    nameLabel.font = AB_FONT_14;
    nameLabel.textColor = AB_Color_403b36;
    nameLabel.text = document.fileName;
    
    CGFloat sizeLabel_y = CGRectGetMaxY(nameLabel.frame) + 2.0;
    UILabel *sizeLabel = [[UILabel alloc] init];
    sizeLabel.frame = CGRectMake(nameLabel_x, sizeLabel_y, nameLabel_w, 16);
    sizeLabel.font = AB_FONT_14;
    sizeLabel.textColor = AB_Color_c3bdb4;
    sizeLabel.text = document.size;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(documentBeenTap:)];
    v.userInteractionEnabled = YES;
    [v addGestureRecognizer:tap];
    
    [v addSubview:icon];
    [v addSubview:nameLabel];
    [v addSubview:sizeLabel];
    
    return v;
}

#pragma mark
#pragma mark Bubble view
- (UIView *)bubbleView:(NSString *)text msgId:(NSString *)msgId msgRandomId:(NSString *) msgRandomId from:(BOOL)fromSelf type:(NSString *)type subject:(NSString *)subject avatar:(NSString *)avatar sendStatus:(NSString *)sendStatus{
    
    
    NSLog(@"%@-%@-%@",type,text,subject);
    UIView *returnView =  [self assembleMessageAtIndex:text msgId:msgId from:fromSelf type:
                           type subject:subject sendStatus:sendStatus];

    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    
    if([subject isEqualToString:@"notice"]){
        cellView.frame = CGRectMake(0, 0, Screen_Width, returnView.frame.size.height + 16.0*kScreenScale);
        [cellView addSubview:returnView];
        return cellView;
    }
    
    BOOL needWhiteBubble = [subject isEqualToString:@"card"] || [subject isEqualToString:@"article"];
    
    UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?(needWhiteBubble?@"chat_bg_outgoing_01@2x":@"chat_bg_outgoing@2x"):@"chat_bg_incomming@2x" ofType:@"png"]];
    
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:10 topCapHeight:15]];
    
    UILabel *systemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kTextHeight, KCurrWidth, kTextHeight)];
    systemLabel.textColor = [UIColor grayColor];
    systemLabel.textAlignment = NSTextAlignmentCenter;
    systemLabel.font = AB_FONT_12;
    
    UIImageView *abIcon = nil;
    if (myAccountType == Employee || friendAccountType == Employee) {
        abIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_ab01"]];
        abIcon.frame = CGRectMake(26*kScreenScale, 31*kScreenScale, 16*kScreenScale, 11*kScreenScale);
    }

    
    if(fromSelf){
        myAvatarImageView = [[UIImageView alloc]init];
        myAvatarImageView.backgroundColor = [UIColor clearColor];
        [myAvatarImageView setImageWithURL:[NSURL URLWithString:myAvatarURL]
                          placeholderImage:[UIImage imageWithContentsOfFile:avatarDefaultPath]];
        //returnView.frame= CGRectMake(kChatYPadding/2, 15.0f, returnView.frame.size.width, returnView.frame.size.height);
        
        
        //发送语音时
        if([subject isEqualToString:@"voice"]){
            
            isSelfFlag = 0;
            bubbleImageView.frame = CGRectMake(0.0f, 0.0f, returnView.frame.size.width + kChatXPadding, returnView.frame.size.height+kChatYPadding);
            //bubbleImageView.frame = CGRectMake(10.0f, 14.0f, 0.0f,0.0f);
            //bubbleImageView.hidden = YES;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = [msgId intValue];
            
            [btn  addTarget:self action:@selector(chatPlayVoice:) forControlEvents:UIControlEventTouchUpInside];
            //[btn  addTarget:self action:@selector(showPopupMenu2:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = [UIColor clearColor];
            
            
            btn.frame =  CGRectMake(0.0f,0.0f, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height);
            // btn.backgroundColor = [UIColor greenColor];
            // [btn setBackgroundImage:[[UIImage imageNamed:@"bubble-flat-outgoing"]stretchableImageWithLeftCapWidth:15 topCapHeight:10]forState:UIControlStateNormal];//backgroundImage
        
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(btn.frame.size.width -kMsgPaddingRight - kMsgPaddingLeft , kChatYPadding/2+(kTextHeight-18.0f*kScreenScale)/2, 17.0f*kScreenScale, 18.0f*kScreenScale)];
            imageView.image = [UIImage imageNamed:@"chatto_voice"];
            imageView.backgroundColor = [UIColor clearColor];
            imageView.animationImages = self.playVoiceImage;
            imageView.animationDuration = 1.5;
           
            [btn addSubview:imageView];
            
            [bubbleImageView addSubview: btn];
            
        }else if([subject isEqualToString:@"image"]){
            // bubbleImageView.image =nil;
            //returnView.frame= CGRectMake(-60.0f, -10.0f, returnView.frame.size.width, returnView.frame.size.height);
            
            NSString *imageJsonStr  =[text stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
            //imageJsonStr = [imageJsonStr stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];
            // //NSLog(@"imageJsonStr:%@",imageJsonStr);
            NSDictionary *imageData = [imageJsonStr objectFromJSONString];
            //NSLog(@"imageJsonStr.link:%@",[imageData objectForKey:@"link"]);
            //NSLog(@"imageJsonStr.data:%@",[imageData objectForKey:@"data"]);
            
            UIImage *img = [Photo string2Image:[imageData objectForKey:@"data"]];
            bubbleImageView.frame = CGRectMake(0.0f, 0.0f, img.size.width, img.size.height );
            UIImageView *imgv = [[UIImageView alloc]initWithFrame:CGRectMake(2.0f, 2.0f, bubbleImageView.frame.size.width-10, bubbleImageView.frame.size.height-4 )];
            imgv.image = img;
            imgv.layer.cornerRadius= 0;
            imgv.layer.masksToBounds= YES;
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag =[msgId intValue] ;
            btn.frame = CGRectMake(0.0f, 0.0f, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height );
            [btn  addTarget:self action:@selector(previewPicture2:) forControlEvents:UIControlEventTouchUpInside];
            //[btn  addTarget:self action:@selector(showPopupMenu2:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = [UIColor clearColor];
            
            //[self.msgButArray addObject:btn];
            //btn.hidden = YES;
            //returnView.frame= CGRectMake(20.0f, 0.0f, 120, returnView.frame.size.height);
            [bubbleImageView addSubview:btn];
            [bubbleImageView addSubview:imgv];
            
        }else if([subject isEqualToString:@"phone"]){
            UIImageView *imgv = [[UIImageView alloc]initWithFrame:CGRectMake(returnView.frame.size.width - kTextHeight, 0.0f, kTextHeight, kTextHeight)];
            imgv.image = [UIImage imageNamed:@"user_call"];
            [returnView addSubview:imgv];
            bubbleImageView.frame = CGRectMake(0.0f, 0.0f, returnView.frame.size.width+kPhonePadding*2, returnView.frame.size.height+kChatYPadding);
            
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn  addTarget:self action:@selector(playDial) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = [UIColor clearColor];
            btn.frame =  CGRectMake(0.0f,0.0f, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height);
            [bubbleImageView addSubview:btn];
        }
        else if ([subject isEqualToString:@"card"])
        {
            UIView *v = [self cardViewWithOrginal:CGPointMake(1, 1) messageBody:text];
            bubbleImageView.frame = CGRectMake(0.0f, 0.0f, v.bounds.size.width + 8.5, v.bounds.size.height + 2);
            [bubbleImageView addSubview:v];
        }
        else if ([subject isEqualToString:@"document"])
        {
            UIView *v = [self documentViewWithOriginal:CGPointMake(1, 1) messageBody:text];
            bubbleImageView.frame = CGRectMake(0.0f, 0.0f, v.bounds.size.width + 8.5, v.bounds.size.height + 2);
            [bubbleImageView addSubview:v];
        }
        else if ([subject isEqualToString:@"article"]) {
            UIView *v = [self articleViewWithOriginal:CGPointMake(1, 1) messageBody:text];
            bubbleImageView.frame = CGRectMake(0.0f, 0.0f, v.bounds.size.width + 8.5, v.bounds.size.height + 2);
            [bubbleImageView addSubview:v];
        }
        
        else if([subject isEqualToString:@"location"]){
            NSDictionary *locationData = [text objectFromJSONString];
            float width = MAX_WIDTH;
            float height = width*110.0f/180.0f;
            UIImage *img = [Photo string2Image2:locationData[@"cover"]];
            UIImageView *imgv = [[UIImageView alloc]initWithFrame:CGRectMake(1.0f, 1.0f, width-8.0f*kScreenScale, height-2.0f)];
            imgv.image = img;
            imgv.layer.cornerRadius = 2.0;
            imgv.layer.masksToBounds = YES;
            imgv.contentMode = UIViewContentModeScaleToFill;
            bubbleImageView.frame = CGRectMake(0.0f, 0.0f, width, height);
            [bubbleImageView addSubview:imgv];
            
            UIImageView *locationIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chat_icon_position_01"]];
            locationIcon.center = CGPointMake(imgv.center.x, imgv.center.y - 19.0f*kScreenScale);
            [bubbleImageView addSubview:locationIcon];
            
            UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(5*kScreenScale, 0, width - kChatXPadding, height*20/110)];
            addressLabel.font = AB_FONT_12_B;
            addressLabel.text = locationData[@"locationName"];
            addressLabel.textColor = [UIColor whiteColor];
            
            UIView *labelView = [[UIView alloc]initWithFrame:CGRectMake(1, height-2.0f + 1 - height*20/110, width-8.0f*kScreenScale, height*20/110)];
            labelView.backgroundColor = [UIColor blackColor];
            labelView.alpha = 0.5;
            labelView.layer.cornerRadius = 2.0f;
            labelView.layer.masksToBounds = YES;
            [labelView addSubview:addressLabel];
            [bubbleImageView addSubview:labelView];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = [msgId intValue];
            [btn  addTarget:self action:@selector(gotoMap:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = [UIColor clearColor];
            btn.frame =  CGRectMake(0.0f,0.0f, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height);
            [bubbleImageView addSubview:btn];
        }
        else
        {
            CGFloat returnViewWidth = returnView.frame.size.width;
            CGFloat returnViewHeight = returnView.frame.size.height;
            bubbleImageView.frame = CGRectMake(0.0f, 0.0f, returnViewWidth+kChatXPadding, returnViewHeight + kChatYPadding );
        }
        
        cellView.frame = CGRectMake(0.0f, 0.0f, Screen_Width, bubbleImageView.frame.size.height+16.0f*kScreenScale);
        myAvatarImageView.frame = CGRectMake(Screen_Width - kChatAvatarWidth - kChatAvatarPadding, 0, kChatAvatarWidth, kChatAvatarWidth);
        

        
    }else{
        //NSLog(@"好友来消息了：%@",_chatWithUser);
        friendAvatarImageView = [[UIImageView alloc]init];
        friendAvatarImageView.backgroundColor = [UIColor clearColor];
        [friendAvatarImageView setImageWithURL:[NSURL URLWithString:avatarURL]
                              placeholderImage:[UIImage imageWithContentsOfFile:avatarDefaultPath]];
        
        
        //发送语音时
        if([subject isEqualToString:@"voice"]){
            
            bubbleImageView.frame = CGRectMake(0.0f, 0.0f, returnView.frame.size.width + kChatXPadding, returnView.frame.size.height+kChatYPadding);
            isSelfFlag = 1;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = [msgId intValue];
            
            [btn  addTarget:self action:@selector(chatPlayVoice:) forControlEvents:UIControlEventTouchUpInside];
            //[btn  addTarget:self action:@selector(showPopupMenu2:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = [UIColor clearColor];
            
            
            btn.frame =  CGRectMake(0.0f,0.0f, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height);
            
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kMsgPaddingLeft, kChatYPadding/2+(kTextHeight-18.0f*kScreenScale)/2, 17.0f*kScreenScale, 18.0f*kScreenScale)];
            imageView.image = [UIImage imageNamed:@"chatfrom_voice"];
            imageView.backgroundColor = [UIColor clearColor];
            imageView.animationImages = self.playVoiceImageFrom;
            imageView.animationDuration = 1.5;
            
            int readmark = [ChatMessageCRUD queryMessageReadMarkByMsgId:msgId];
            if(readmark != 2){
                UIImageView *unplayedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(bubbleImageView.frame.size.width + 6.0f*kScreenScale, 0.0f, 5.0f*kScreenScale, 5.0f*kScreenScale)];
                unplayedImageView.layer.cornerRadius = 3;
                unplayedImageView.layer.masksToBounds = YES;
                unplayedImageView.tag = 10000;
                unplayedImageView.backgroundColor = AB_Color_fe0000;
                [bubbleImageView addSubview:unplayedImageView];
                [mUnplayedVoiceArray addObject:btn];
            }
            
            [btn addSubview:imageView];
            
            [bubbleImageView addSubview:btn];
            
        }else if([subject isEqualToString:@"image"]){
            
            //bubbleImageView.frame = CGRectMake(0.0f, 0.0f, returnView.frame.size.width+20, returnView.frame.size.height );
            
            NSString *imageJsonStr  =[text stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
            //imageJsonStr = [imageJsonStr stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];
            //NSLog(@"imageJsonStr:%@",imageJsonStr);
            NSDictionary *imageData = [imageJsonStr objectFromJSONString];
            //NSLog(@"imageJsonStr.link:%@",[imageData objectForKey:@"link"]);
            //NSLog(@"imageJsonStr.data:%@",[imageData objectForKey:@"data"]);
            
            UIImage *img = [Photo string2Image:[imageData objectForKey:@"data"]];
            bubbleImageView.frame =CGRectMake(0.0f, 0.0f, img.size.width, img.size.height);
            
            UIImageView *imgv = [[UIImageView alloc]initWithFrame:CGRectMake(kChatAvatarPadding, 2.0f, bubbleImageView.frame.size.width-10, bubbleImageView.frame.size.height-4 )];
            imgv.image = img;
            imgv.layer.cornerRadius= 0;
            imgv.layer.masksToBounds= YES;
            [bubbleImageView addSubview:imgv];
            
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag =[msgId intValue] ;
            
            btn.frame = CGRectMake(0.0f, 0.0f, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height );
            [btn  addTarget:self action:@selector(previewPicture2:) forControlEvents:UIControlEventTouchUpInside];
            //[btn  addTarget:self action:@selector(showPopupMenu2:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = [UIColor clearColor];
            
            //[self.msgButArray addObject:btn];
            //btn.hidden = YES;
            returnView.frame= CGRectMake(65.0f*kScreenScale, 0.0f, returnView.frame.size.width, returnView.frame.size.height);
            [bubbleImageView addSubview:btn];
            
        }else if([subject isEqualToString:@"phone"]){
            UIImageView *imgv = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, kTextHeight, kTextHeight)];
            imgv.image = [UIImage imageNamed:@"voice-red"];
            
            bubbleImageView.frame = CGRectMake(0.0f, 0.0f, returnView.frame.size.width+kPhonePadding*2, returnView.frame.size.height+kChatYPadding);
            [returnView addSubview:imgv];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [btn  addTarget:self action:@selector(playDial) forControlEvents:UIControlEventTouchUpInside];
            //[btn  addTarget:self action:@selector(showPopupMenu2:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = [UIColor clearColor];
            
            btn.frame =  CGRectMake(0.0f,0.0f, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height);
            [bubbleImageView addSubview:btn];
            
            
        }else if([subject isEqualToString:@"new_friend"]){
            
            systemLabel.text = text;
            
            
        }
        else if ([subject isEqualToString:@"card"])
        {
            UIView *v = [self cardViewWithOrginal:CGPointMake(8.5, 1) messageBody:text];
            bubbleImageView.frame = CGRectMake(0.0f, 0.0f, v.bounds.size.width + 9.5, v.bounds.size.height + 2);
            [bubbleImageView addSubview:v];
        }
        else if ([subject isEqualToString:@"document"])
        {
            UIView *v = [self documentViewWithOriginal:CGPointMake(8.5, 1) messageBody:text];
            bubbleImageView.frame = CGRectMake(0.0f, 0.0f, v.bounds.size.width + 9.5, v.bounds.size.height + 2);
            [bubbleImageView addSubview:v];
        }
        else if ([subject isEqualToString:@"article"])
        {
            UIView *v = [self articleViewWithOriginal:CGPointMake(8.5, 1) messageBody:text];
            bubbleImageView.frame = CGRectMake(0.0f, 0.0f, v.bounds.size.width + 9.5, v.bounds.size.height + 2);
            [bubbleImageView addSubview:v];
        }
        
        else if([subject isEqualToString:@"location"]){
            
            NSDictionary *locationData = [text objectFromJSONString];
            float width = MAX_WIDTH;
            float height = width*110.0f/180.0f;
            
            UIImage *img = [Photo string2Image2:locationData[@"cover"]];
            UIImageView *imgv = [[UIImageView alloc]initWithFrame:CGRectMake(7.0f, 1.0f, width - kChatAvatarPadding, height - 2.0f)];
            imgv.image = img;
            imgv.layer.cornerRadius = 2.0;
            imgv.layer.masksToBounds = YES;
            imgv.contentMode = UIViewContentModeScaleToFill;
            bubbleImageView.frame = CGRectMake(0.0f, 0.0f, width, height);
            [bubbleImageView addSubview:imgv];
            
            UIImageView *locationIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chat_icon_position_01"]];
            locationIcon.center = CGPointMake(imgv.center.x, imgv.center.y - 19.0f);
            [bubbleImageView addSubview:locationIcon];
            
            UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(5*kScreenScale, 0, width - kChatXPadding, height*20/110)];
            addressLabel.font = AB_FONT_12_B;
            addressLabel.text = locationData[@"locationName"];
            addressLabel.textColor = [UIColor whiteColor];
            
            UIView *labelView = [[UIView alloc]initWithFrame:CGRectMake(7.0*kScreenScale, height-2.0f + 1 - height*20/110, width-kChatAvatarPadding, height*20/110)];
            labelView.backgroundColor = [UIColor blackColor];
            labelView.alpha = 0.5;
            labelView.layer.cornerRadius = 2.0f;
            labelView.layer.masksToBounds = YES;
            [labelView addSubview:addressLabel];
            [bubbleImageView addSubview:labelView];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = [msgId intValue];
            [btn  addTarget:self action:@selector(gotoMap:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = [UIColor clearColor];
            btn.frame =  CGRectMake(0.0f,0.0f, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height);
            [bubbleImageView addSubview:btn];
        }
        else
        {
            CGFloat returnViewWidth = returnView.frame.size.width;
            CGFloat returnViewHeight = returnView.frame.size.height;
            bubbleImageView.frame = CGRectMake(0.0f, 0.0f, returnViewWidth+kChatXPadding, returnViewHeight + kChatYPadding);
        }
        
        cellView.frame = CGRectMake(0.0f, 0.0f, Screen_Width, bubbleImageView.frame.size.height+16.0f*kScreenScale);
        friendAvatarImageView.frame = CGRectMake(kChatAvatarPadding, 0, kChatAvatarWidth, kChatAvatarWidth);
        UIButton *avatarBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        avatarBtn.frame =  CGRectMake(kChatAvatarPadding, 0, kChatAvatarWidth, kChatAvatarWidth);
        [avatarBtn  addTarget:self action:@selector(queryUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        avatarBtn.backgroundColor = [UIColor clearColor];
        
        
        if (![subject isEqualToString:@"new_friend"]) {
            
            [cellView addSubview:avatarBtn];
        }
        
        
    }
    //===聊天背景
    CGFloat bvWidth = fromSelf?(Screen_Width - 58.0f*kScreenScale - bubbleImageView.frame.size.width):58.0f*kScreenScale;
    UIView*bubbleView = [[UIControl alloc] initWithFrame:CGRectMake(bvWidth
                                                                    , 0.0f
                                                                    , bubbleImageView.frame.size.width, bubbleImageView.frame.size.height)] ;
    
    CGFloat padding = 0.0;
    if([subject isEqualToString:@"voice"]){
        padding = 30.0f*kScreenScale;
    }
    
    //无网络时显现未发送图标
    if ([sendStatus isEqualToString:@"disconnect"]) {
        UIImageView *exclamationLabel = [[UIImageView alloc] initWithFrame:CGRectMake(bubbleView.frame.origin.x-(12+10+padding)*kScreenScale,10*kScreenScale,kChatYPadding, kChatYPadding)];
        exclamationLabel.image = [UIImage imageNamed:@"icon_cuation"];
        exclamationLabel.tag = 12345;
        exclamationLabel.contentMode = UIViewContentModeScaleAspectFill;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = [msgId intValue];
        [btn  addTarget:self action:@selector(confirmForResendMessage:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor clearColor];
        btn.frame =  exclamationLabel.frame;

        [cellView addSubview:btn];
        [cellView addSubview:exclamationLabel];
    }
    
    if (fromSelf && ![sendStatus isEqualToString:@"complete"] && ![sendStatus isEqualToString:@"disconnect"] && ![subject isEqualToString:@"phone"]) {
        _ylImageview = [[YLImageView alloc] initWithFrame:CGRectMake(bubbleView.frame.origin.x-(12+10+padding)*kScreenScale, 10*kScreenScale, kChatYPadding, kChatYPadding)];
        _ylImageview.image = [YLGIFImage imageNamed:@"loading.gif"];
        //_ylImageview.tag = msgRandomId.intValue;
        [cellView addSubview:_ylImageview];
    }
    
    //[bubbleView setBackgroundColor:bgColor];
  
    //returnView.frame = CGRectMake(5, 5, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height) ;
    
    //bubbleImageView.frame = CGRectMake(0, 0, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height);
    bubbleImageView.backgroundColor = [UIColor clearColor];
    
    if (fromSelf) {
        bubbleView.tag = 1;
        if (myAccountType == Employee) {
            [myAvatarImageView addSubview:abIcon];
        }
        [cellView addSubview:myAvatarImageView];
    }else{
        bubbleView.tag = 0;
        
        if (![subject isEqualToString:@"new_friend"]) {
            if (friendAccountType == Employee) {
                [friendAvatarImageView addSubview:abIcon];
            }
            [cellView addSubview:friendAvatarImageView];
        }
        
    }
    
    [bubbleView addSubview:bubbleImageView];
    [bubbleImageView addSubview:returnView];
    
    bubbleImageView.userInteractionEnabled = YES;
    bubbleView.userInteractionEnabled = YES;
    
    bubbleImageView.tag = [msgId intValue];
    // bubbleView.tag = [msgId intValue];
    bubbleView.layer.backgroundColor = [UIColor clearColor].CGColor;
    //长按事件
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPressGr.minimumPressDuration = 1.0;
    [bubbleView addGestureRecognizer:longPressGr];
    // [longPressGr release];
    
    // [cellView addSubview:returnView];
    
    if (![subject isEqualToString:@"new_friend"]) {
        [cellView addSubview:bubbleView];
    }else{
        [cellView addSubview:systemLabel];
    }
    
   	return cellView;
}

-(void)confirmForResendMessage:(UIButton*)button
{
    NSIndexPath *indexPath;
    if(IS_iOS8){
        indexPath = [self.chatTableView indexPathForCell:(UITableViewCell*)button.superview.superview];
    } else {
        indexPath = [self.chatTableView indexPathForCell:(UITableViewCell*)button.superview.superview.superview];
    }
    
    self.menuIndexPath = indexPath;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"重发该消息？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"重发", nil];
    alert.tag = 10000;
    [alert show];
}

//查看大图（旧的方法）
-(void)previewPicture2:(UIButton *)btn{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *tempPhotos;
    NSMutableArray *msgIdArray;
    
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    // MWPhoto *photo;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    
    tempPhotos = [ChatMessageCRUD queryChatPictureMessage:_chatWithUser];
    _previewingImageMessages = tempPhotos;
    
    if(tempPhotos.count==0){
        return;
    }
    
    for (int i=0; i<tempPhotos.count; i++) {
        NSDictionary *imageDic = [tempPhotos objectAtIndex:i];
        NSString *sendUser = [imageDic objectForKey:@"sendUser"];
        NSString *imageMessageJson = [imageDic objectForKey:@"message"];
        NSString *imageJsonStr  =[imageMessageJson stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSDictionary *imageDic2 = [imageJsonStr objectFromJSONString];
        NSString *imageLink = [imageDic2 objectForKey:@"link"];
        
        JLLog_I(@"imageLink=%@", imageLink);
        
        NSString *bigImageURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, imageLink];
        // NSLog(@"*****%@",[NSURL URLWithString:bigImageURL]);
        if ([imageLink isEqualToString:@"no url"]) {
            continue;
        }
        
        JLLog_I(@"imageLink=%@", imageLink);
        NSString *imageURLString = nil;
        BOOL flag = [[imageLink lowercaseString] hasPrefix:@"assets-library"];
        if (flag) {
            imageURLString = imageLink;
        }else {
            imageURLString = [NSString stringWithFormat:@"%@/%@",ResourcesURL, imageLink];
        }
        MWPhoto *photo_01 = [MWPhoto photoWithURL:[NSURL URLWithString:imageURLString]];
        MWPhoto *photo_02 = [MWPhoto photoWithURL:[NSURL URLWithString:imageURLString]];
        
        photo_01.imageCache = mResourceCache.imageCache;
        photo_02.imageCache = mResourceCache.imageCache;
        
        [photos addObject:photo_01];
        [thumbs addObject:photo_02];

        
//        if ([sendUser isEqualToString:MY_USER_NAME]) {
//            //UIImage * img = [UIImage imageWithContentsOfFile:imageLink];
//            //[photos addObject:[MWPhoto photoWithImage:img]];
//            //[photos addObject:[MWPhoto photoWithImage:img]];
////            [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:imageLink]]];
////            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:imageLink]]];
//            
////            [photos addObject:[MWPhoto photoWithURL:[NSURL fileURLWithPath:imageLink]]];
////            [thumbs addObject:[MWPhoto photoWithURL:[NSURL fileURLWithPath:imageLink]]];
//            
//            JLLog_I(@"Select image from disk...");
//            [photos addObject:[MWPhoto photoWithImage:[mResourceCache imageForKey:imageLink]]];
//            [thumbs addObject:[MWPhoto photoWithImage:[mResourceCache imageForKey:imageLink]]];
//            
//        }else{
//            JLLog_I(@"Select image from TFS...");
//            
//            MWPhoto *photo_01 = [MWPhoto photoWithURL:[NSURL URLWithString:bigImageURL]];
//            MWPhoto *photo_02 = [MWPhoto photoWithURL:[NSURL URLWithString:bigImageURL]];
//            
//            photo_01.imageCache = mResourceCache.imageCache;
//            photo_02.imageCache = mResourceCache.imageCache;
//            
//            [photos addObject:photo_01];
//            [thumbs addObject:photo_02];
//        }
    }
    
    NSDictionary *msgIdDic =[tempPhotos lastObject];
    msgIdArray = [msgIdDic objectForKey:@"msgIdArray"];
    NSString *msgId = [NSString stringWithFormat:@"%d",btn.tag];
    int clickIndex = [msgIdArray indexOfObject:msgId];
    if(clickIndex == NSNotFound)
    {
        // NSLog(@"对象不在数组中");
        return;
    }
    // Options
    self.photos = photos;
    self.thumbs = thumbs;
    
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:clickIndex];
    
    // Reset selections
    if (displaySelectionButtons) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < photos.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    // Show
    if (_segmentedControl.selectedSegmentIndex == 0) {
        // Push
        [self.navigationController pushViewController:browser animated:YES];
    } else {
        // Modal
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nc animated:YES completion:nil];
    }
    
    double delayInSeconds = 3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
    });
}


#pragma mark -
#pragma mark Table View DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chatArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id chatId = [self.chatArray objectAtIndex:[indexPath row]];
    
    if ([chatId isKindOfClass:[NSDate class]]) {
        return (21+16)*kScreenScale;
    }
    
    if([chatId isKindOfClass:[NSString class]]){
        return (21+16)*kScreenScale;;
    }
//    if ([chatId isKindOfClass:[NSDictionary class]]) {
//        
//        if ([[chatId valueForKey:@"subject"]isEqualToString:@"notice"]) {
//            
//            return 41;
//        }
//        
//    }
    
    UIView *chatView = [chatId objectForKey:@"view"];
    return chatView == nil ? (21+16)*kScreenScale : chatView.frame.size.height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CommentCellIdentifier = @"CommentCell";
    ChatCustomCell *cell = (ChatCustomCell*)[tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ChatCustomCell" owner:self options:nil] lastObject];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    id chatId = [self.chatArray objectAtIndex:[indexPath row]];
    
    if ([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]]) {
        // Set up the cell...
        NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *sendTimeStr = [formatter stringFromDate:[self.chatArray objectAtIndex:[indexPath row]]];
        NSString *timeString = [Utility friendlyTime: sendTimeStr];

        CGSize labTimeSize = [timeString sizeWithFont:AB_FONT_12 constrainedToSize:CGSizeMake(MAX_WIDTH, 21*kScreenScale) lineBreakMode:NSLineBreakByCharWrapping];
        
        cell.dateLabel.frame=CGRectMake((Screen_Width - labTimeSize.width - 30*kScreenScale)/2, 0.0, labTimeSize.width + 30*kScreenScale, 21*kScreenScale);
        cell.dateLabel.textAlignment=NSTextAlignmentCenter;
        cell.dateLabel.font = AB_FONT_12;
        cell.dateLabel.textColor= AB_Color_ffffff;
        cell.dateLabel.backgroundColor = AB_Color_d3d1cd;
        cell.dateLabel.layer.cornerRadius = 10.0f*kScreenScale;
        cell.dateLabel.layer.masksToBounds = YES;
        cell.dateLabel.layer.borderWidth = 1.0;
        cell.dateLabel.layer.borderColor = AB_Color_d3d1cd.CGColor;
        
        [cell.dateLabel setText:timeString];
        
    }else if([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSString class]]){
        
        
        [cell.dateLabel setText:@"..."];
        cell.dateLabel.frame = CGRectMake(0, 0, KCurrWidth, cell.dateLabel.frame.size.height);
        cell.dateLabel.textAlignment = NSTextAlignmentCenter;
        
        
        
    } else {
        // Set up the cell...
        NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
        [cell addSubview:[chatInfo objectForKey:@"view"]];
    }
    return cell;
}

- (void)sendToButtomAtIndex:(int)index
{
    id current = self.chatArray[index];
    id prev = self.chatArray[index-1];
    BOOL hasNext = index+1 < self.chatArray.count;
    id next = hasNext?self.chatArray[index+1]:nil;
    if([prev isKindOfClass:NSDate.class] && (next == nil || [next isKindOfClass:NSDate.class])){
        [self.chatArray removeObject:prev];
    }
    
    [self.chatArray removeObject:current];
    
    
    NSDate *nowTime = [Utility getCurrentDate:@"YY-MM-dd HH:mm"];
    
    NSString *currentTime = [Utility stringFromDate:nowTime formatStr:@"yyyy-MM-dd HH:mm:ss"];
    NSString *nextTime = [Utility stringFromDate:_lastTime formatStr:@"yyyy-MM-dd HH:mm:ss"];
    
    if(![[Utility friendlyTime:currentTime] isEqualToString:[Utility friendlyTime:nextTime]]){
        [self.chatArray addObject:nowTime];
    }
    
    _lastTime = nowTime;
    
    [self.chatArray addObject:current];
    
    [self.chatTableView reloadData];
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                              atScrollPosition: UITableViewScrollPositionBottom
                                      animated:YES];
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self.messageTextField resignFirstResponder];
    // [self showPopupMenu3:indexPath];
    //NSLog(@"@%d----%d",indexPath.section,indexPath.row);
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
-(void)textFiledReturnEditing:(id)sender {
    NSString * text = _messageTextField.text;
    
    
    if ([text isEqualToString:@""])
    {
        return;
    }else
    {
        [self sendMassage:text];
    }
    [_messageTextField resignFirstResponder];
    
    
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)atext {
    
    //weird 1 pixel bug when clicking backspace when textView is empty
    if(![_textView hasText] && [atext isEqualToString:@""]) return NO;
    
    //Added by bretdabaker: sometimes we want to handle this ourselves
    //    if ([delegate respondsToSelector:@selector(growingTextView:shouldChangeTextInRange:replacementText:)])
    //        return [delegate growingTextView:self shouldChangeTextInRange:range replacementText:atext];
    
    if ([atext isEqualToString:@"\n"]) {
        [self sendMassage:textView.text];
        _textView.text =@"";
        [self textViewDidChange:_textView];
        // [textView resignFirstResponder];
        return NO;
        
    }
    
    return YES;
    
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    NSLog(@"*****%@",@"正在输入");
    
}

- (void)leaveEditMode {
    
    NSLog(@"*****%@",@"离开输入");
    
    
}


- (void)textViewDidEndEditing:(UITextView *)textView {
    
    NSLog(@"*****%@",@"结束输入");
    
    
}


-(void) autoMovekeyBoard: (float) h{
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        //        UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:G_TOOLBARTAG];
        //   containerView.frame = CGRectMake(0.0f, (float)(viewHight-h-44.0), 320.0f, 44.0f);
        //UITableView *tableView = (UITableView *)[self.view viewWithTag:CHAT_TABLEVIEWTAG];
        
        if (self.chatArray.count>0) {
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:0.1];
            [UIView setAnimationCurve:7];
            
            // set views with new info
            // containerView.frame = containerFrame;
            
            _chatTableView.frame =  CGRectMake(0.0f, 0.0f, KCurrWidth,(float)(KCurrHeight-h-113));
            [_chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                                  atScrollPosition: UITableViewScrollPositionBottom
                                          animated:NO];
            
            // commit animations
            [UIView commitAnimations];
        }
        
        
    }else{
        //        UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:G_TOOLBARTAG];
        //    	toolbar.frame = CGRectMake(0.0f, (float)(viewHight-h-64.0), 320.0f, 44.0f);
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationCurve:7];
        
        UITableView *tableView = (UITableView *)[self.view viewWithTag:CHAT_TABLEVIEWTAG];
        tableView.frame = CGRectMake(0.0f, 0.0f, KCurrWidth,(float)(KCurrHeight-h-113));
        if (self.chatArray.count>0) {
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                             atScrollPosition: UITableViewScrollPositionBottom
                                     animated:NO];
        }
        
        [UIView commitAnimations];
    }
    
    
    
}


-(NSDictionary*)getAttributedDict:(NSString*)message
{
    CGSize size = CGSizeZero;
    
    NSDictionary *attributes = @{NSFontAttributeName: AB_FONT_17};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:message attributes:attributes];
    
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[NOK\\u4e00-\\u9fa5]{1,3}\\]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *matches = [regex matchesInString:message options:0 range:NSMakeRange(0, [message length])];

    if(matches.count == 0){
        size = [attributedString boundingRectWithSize:CGSizeMake(MAX_WIDTH,1000000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    } else {
        for (NSTextCheckingResult* m in [matches reverseObjectEnumerator])
        {
            NSRange range = m.range;
            NSString *faceName = [expressionDic objectForKey:[message substringWithRange:range]];
            if(faceName != nil){
                NSTextAttachment *attachment=[[NSTextAttachment alloc] initWithData:nil ofType:nil];
                UIImage *img = [UIImage imageNamed:faceName];
                attachment.image = img;
                attachment.bounds = CGRectMake(0, -5, [AB_FONT_17 lineHeight], [AB_FONT_17 lineHeight]);
                NSAttributedString *face = [NSAttributedString attributedStringWithAttachment:attachment];
                [attributedString replaceCharactersInRange:range withAttributedString:face];
            }
        }
        
        size = [attributedString boundingRectWithSize:CGSizeMake(MAX_WIDTH,1000000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    }
    
    return @{@"string": attributedString,
             @"width": [NSNumber numberWithFloat:size.width],
             @"height": [NSNumber numberWithFloat:size.height]};
}




-(UIView *)assembleMessageAtIndex:(NSString *)message msgId:(NSString *)msgId from:(BOOL)fromself type:(NSString *)type subject:(NSString *)subject sendStatus:(NSString *)sendStatus
{
    message =[message stringByReplacingOccurrencesOfString:@"<br>" withString:@" "];
    
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    returnView.backgroundColor = [UIColor clearColor];
    returnView.userInteractionEnabled = NO;
    
    if ([subject isEqualToString:@"chat"]) {
        
        NSDictionary *attrDict = [self getAttributedDict:message];
        float width = [attrDict[@"width"] floatValue];
        float height = [attrDict[@"height"] floatValue];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        
        label.attributedText = attrDict[@"string"];
        
        
        //设置自动行数与字符换行
        [label setNumberOfLines:0];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        
        
        label.font = AB_FONT_17;
        label.textColor = [UIColor colorWithRed:64.0/255.0 green:59.0/255.0 blue:54.0/255.0 alpha:1];
        if(fromself)
            label.textColor = [UIColor whiteColor];
        
        
        label.backgroundColor = [UIColor clearColor];
        
        [label setFrame:CGRectMake(0, 0, width, height)];
        
        //                    NSError *error = NULL;
        //                    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        //                    NSDataDetector *detector2 = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:&error];
        //
        //                    self.matches= [detector matchesInString:_ppLabel.text options:0 range:NSMakeRange(0, _ppLabel.text.length)];
        //                    self.matches2= [detector2 matchesInString:_ppLabel.text options:0 range:NSMakeRange(0, _ppLabel.text.length)];
        //
        //                    [self highlightLinksWithIndex:NSNotFound];
        //                    [self highlightLinksWithIndex2:NSNotFound];
        
        [returnView addSubview:label];
        
        returnView.frame = CGRectMake(fromself?kMsgPaddingLeft:kMsgPaddingRight, kChatYPadding/2, width, height);
        return returnView;
    }
    
    if ([subject isEqualToString:@"notice"]){
        CGSize callSize = [message boundingRectWithSize:CGSizeMake(Screen_Width - 90*kScreenScale, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:AB_FONT_12} context:nil].size;
        
        UILabel *noticeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        noticeLabel.text = message;
        noticeLabel.textColor = AB_White_Color;
        noticeLabel.lineBreakMode = NSLineBreakByCharWrapping;
        noticeLabel.numberOfLines = 0;
        noticeLabel.font = AB_FONT_12;
        noticeLabel.frame = CGRectMake(15*kScreenScale, 6.0*kScreenScale, callSize.width, callSize.height);
        
        UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake((Screen_Width - noticeLabel.frame.size.width - 30.0*kScreenScale)/2, 0.0f, noticeLabel.frame.size.width + 30.0*kScreenScale, noticeLabel.frame.size.height + 12*kScreenScale)];
        backgroundView.backgroundColor = AB_Color_d3d1cd;
        backgroundView.layer.cornerRadius = 10.0*kScreenScale;
        
        [backgroundView addSubview:noticeLabel];
        return backgroundView;
    }
    
    if ([subject isEqualToString:@"voice"]){
        NSString *vocieJsonStr = [message stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSDictionary *voiceData = [vocieJsonStr objectFromJSONString];
        
        int voiceTime = [[voiceData objectForKey:@"time"] intValue];
        NSString *voiceStr = [NSString stringWithFormat:@"%d%@",voiceTime,@"''"];
        
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.font = AB_FONT_12;
        CGSize callSize = [voiceStr boundingRectWithSize:CGSizeMake(50, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:AB_FONT_12} context:nil].size;
        
        CGFloat voiceLength = (MAX_WIDTH - kMsgPaddingLeft - callSize.width - 6.0f*kScreenScale)*voiceTime/60;
        
        if(fromself){
            isSelfFlag = 0;
            returnView.frame = CGRectMake(kMsgPaddingLeft, kChatYPadding/2, kMsgPaddingLeft+8*kScreenScale+voiceLength, kTextHeight);
            timeLabel.frame = CGRectMake(-kMsgPaddingLeft - 6.0f*kScreenScale - callSize.width, (kTextHeight - callSize.height)/2, callSize.width, callSize.height);
            timeLabel.textColor = [UIColor whiteColor];
        }else{
            isSelfFlag = 1;
            returnView.frame = CGRectMake(kMsgPaddingRight, kChatYPadding/2, kMsgPaddingLeft+8*kScreenScale+voiceLength, kTextHeight);
            timeLabel.frame = CGRectMake(returnView.frame.size.width + kMsgPaddingLeft + 6.0f*kScreenScale, (kTextHeight - callSize.height)/2, callSize.width, callSize.height);
        }
        timeLabel.text = voiceStr;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = UIColorFromRGB(0x9c958a);
        [returnView addSubview:timeLabel];
        return returnView;
        
    }

    if ([subject isEqualToString:@"phone"]){

            NSString *phoneJsonStr = [message stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
            //NSLog(@"phoneJsonStr:%@",phoneJsonStr);
            NSDictionary *phoneData = [phoneJsonStr objectFromJSONString];
            //NSLog(@"phoneJsonStr.time:%@",[phoneData objectForKey:@"time"]);

            NSString *callStatus = message;

            if ([[phoneData objectForKey:@"time"] isEqualToString:@"0"]) {
                callStatus = @"未接通";
}

            CGSize callSize=[callStatus sizeWithFont:AB_FONT_17 constrainedToSize:CGSizeMake(250, 35)];

            UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(fromself?0.0f:kTextHeight+10.0f*kScreenScale, 0, callSize.width , kTextHeight)];

            la.font = AB_FONT_17;
            if(fromself){
                la.textColor = [UIColor whiteColor];
            }
            la.text = callStatus;
            la.backgroundColor = [UIColor clearColor];
            la.numberOfLines = 0 ;


            [returnView addSubview:la];

        returnView.frame  = CGRectMake(kPhonePadding, kChatYPadding/2, callSize.width+kTextHeight+10.0f*kScreenScale, kTextHeight);
        return returnView;
    }

    return nil;
}




/*---UIActionSheet start----------------------------------------------------------------------------*/
- (void)clickImageView:(UIButton *) btn
{
   
}

- (void)clickPhoneNumMsg
{
    //天空为什么那么蓝
    if (kIOS_VERSION>=8.0) {
        
        UIAlertController *otherLoginAlert = nil;
        if (kIsPad) {
            otherLoginAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        }else{
            otherLoginAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        }
        
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"chatviewPublic.phoneNumMsg",@"action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"tel://",_phoneNum]]];
                                                          }]];
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"chatviewPublic.phoneNumMsg2",@"action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                                              pasteboard.string = _phoneNum;
                                                          }]];
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"chatviewPublic.phoneNumMsg3",@"action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self savePhoneNum];
                                                          }]];
        
        
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"public.alert.cancel",@"action")                                                               style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                              
                                                          }]];
        
        UIPopoverPresentationController *popover = otherLoginAlert.popoverPresentationController;
        if (popover){
            popover.sourceView = self.view;
            popover.sourceRect = self.view.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        
        [self presentViewController:otherLoginAlert animated:YES completion:nil];
        
    }else{
        
        UIActionSheet *sheetMenu=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"chatviewPublic.phoneNumMsg",@"action"),NSLocalizedString(@"chatviewPublic.phoneNumMsg2",@"action"),NSLocalizedString(@"chatviewPublic.phoneNumMsg3",@"action"),nil];
        sheetMenu.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
        [sheetMenu showInView:self.view.window];
        sheetMenu.tag = 10002;
    }
    
}

#pragma mark -
#pragma mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (actionSheet.tag==10001) {
        
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                //NSLog(@"click at index %d，选择拍照", buttonIndex);
                
                //[self pickPhoto];
      
                
                break;
            case 2:
                //NSLog(@"click at index %d，选择图片", buttonIndex);
                
                break;
            case 3:
                //NSLog(@"click at index %d，语音电话", buttonIndex);

                break;
            case 4:
                //NSLog(@"click at index %d，视频电话", buttonIndex);
         
                break;
                
            default:
                //NSLog(@"unknown： click at index %d", buttonIndex);
                break;
        }
    }else if(actionSheet.tag==10002){
        switch (buttonIndex) {
            case 0:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"tel://",_phoneNum]]];
                break;
            case 1:{
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = _phoneNum;
                break;
            }
            case 2:
                //NSLog(@"click at index %d，选择图片", buttonIndex);
                [self savePhoneNum];
                
                break;
                
            default:
                //NSLog(@"unknown： click at index %d", buttonIndex);
                break;
        }
        
    }
}
/*---UIActionSheet end----------------------------------------------------------------------------------*/



/*---发送图片---------------------------------------------------------------------------------------------*/

//从相机获取图片
- (void)photoFromCamera{
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        
        NSString *mediaType = AVMediaTypeVideo;// Or AVMediaTypeAudio
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        
        if(authStatus ==AVAuthorizationStatusAuthorized){
            [self takePhoto];
        }else if(authStatus == AVAuthorizationStatusDenied){
            // The user has explicitly denied permission for media capture.
            NSLog(@"Denied");     //应该是这个，如果不允许的话
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"请在\"设置/隐私/相机\"中允许邦邦社区访问相机。"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            alert.tag = 1251;
            [alert show];
            
        }else if(authStatus == AVAuthorizationStatusNotDetermined){
            // Explicit user permission is required for media capture, but the user has not yet granted or denied such permission.
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                if(granted){//点击允许访问时调用
                    [self takePhoto];
                }
                else {
                    NSLog(@"Not granted access to %@", mediaType);
                }
                
            }];
        }
        
        
        
    }
    else {
        //NSLog(@"该设备无相机");
    }
}

- (void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;//设置类型为相机
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
    picker.delegate = self;//设置代理
    //picker.allowsEditing = YES;//设置照片可编辑
    picker.sourceType = sourceType;
    //picker.showsCameraControls = NO;//默认为YES
    //创建叠加层
//    UIView *overLayView=[[UIView alloc]initWithFrame:CGRectMake(0, 120, 320, 254)];
//    //取景器的背景图片，该图片中间挖掉了一块变成透明，用来显示摄像头获取的图片；
//    //NSString *overLayImagPath = [[NSBundle mainBundle] pathForResource:@"zhaoxiangdingwei" ofType:@"png"];
//    //UIImage *overLayImag=[UIImage imageWithContentsOfFile:overLayImagPath];
//    //UIImageView *bgImageView=[[UIImageView alloc]initWithImage:overLayImag];
//    //[overLayView addSubview:bgImageView];
//    picker.cameraOverlayView=overLayView;
    //picker.cameraDevice=UIImagePickerControllerCameraDeviceFront;//选择前置摄像头或后置摄像头
    [self presentViewController:picker animated:YES completion:^{
    }];
    
    // CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate hideTabBar:YES];
}


#pragma mark sharemore按钮组协议
-(void)pickPhoto
{
    UIImagePickerController *imgPicker=[[UIImagePickerController alloc]init];
    [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    //[imgPicker setDelegate:self];
    [imgPicker setAllowsEditing:NO];
    imgPicker.editing = NO;
    
    [self presentViewController:imgPicker animated:YES completion:^{
    }];
    
    // CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
    // appDelegate.tabBarBG.hidden=YES;
    
}


#pragma mark ----------图片选择完成-------------
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //NSLog(@"image info:%@",info);
    //裁减为 UIImagePickerControllerEditedImage  UIImagePickerControllerOriginalImage
    UIImage* chosedImage=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    ALAssetsLibraryWriteImageCompletionBlock completeBlock = ^(NSURL *assetURL, NSError *error){
        if (!error) {
            NSString *chosedImageStr = [NSString stringWithFormat:@"%@",assetURL];
            [self dismissViewControllerAnimated:YES completion:^{
                [self saveImage:chosedImage path:chosedImageStr];
                
            }];
        }
    };
    
    if(chosedImage){
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:[chosedImage CGImage]
                                  orientation:(ALAssetOrientation)[chosedImage imageOrientation]
                              completionBlock:completeBlock];
    }
}

- (void)saveImage:(UIImage*)image path:(NSString*)path{
    [self sendImage:image filePath:[NSString stringWithFormat:@"%@", path]];
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}


#pragma mark ----------多张图片选择 start----------------------------------------------------------
- (void)launchTTImagePicker
{
    
    
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    
    
    if (author == ALAuthorizationStatusDenied || author == ALAuthorizationStatusRestricted)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请在\"设置/隐私/相册\"中允许社区访问相册。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
        TTAlbumTableController *albumTable = [[TTAlbumTableController alloc] init];
        TTImagePickerController *imagePicker = [[TTImagePickerController alloc] initWithRootViewController:albumTable];
        albumTable.delegate = imagePicker;
        albumTable.maxSelected = 10;
        [self presentViewController:imagePicker animated:YES completion:nil];
        imagePicker.delegate = self;
    }
    
    
    
    
    
}

- (void)ttImagePickerController:(TTImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    for (ALAssetRepresentation *rep in info) {
        NSString *urlString = rep.url.absoluteString;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            UIImage* image = [UIImage imageWithCGImage:[rep fullResolutionImage]
                                                 scale:[rep scale]
                                           orientation:(UIImageOrientation)[rep orientation]];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self sendImage:image filePath:urlString];
                });
        });
    }
}

#pragma mark ----------多张图片选择 end----------------------------------------------------------


- (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName

{
    NSData* imageData = UIImageJPEGRepresentation(tempImage, 0.1f);
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    
    
    NSLog(@"****%@",fullPathToFile);
    //  TMP_UPLOAD_PATH = fullPathToFile;
    
    //NSArray *nameAry=[CHAT_UPLOAD_PATH componentsSeparatedByString:@"/"];
    //NSLog(@"===new fullPathToFile===%@",fullPathToFile);
    //NSLog(@"===new FileName===%@",[nameAry objectAtIndex:[nameAry count]-1]);
    
    [imageData writeToFile:fullPathToFile atomically:NO];
    
    //[self sendImage:tempImage filePath:fullPathToFile];
    
}


-(void)sendImage:(UIImage *)aImage filePath:(NSString *)imagePath {
    
    JLLog_I(@"imagePath=%@", imagePath);
    
    NSString *message = [Photo image2String:aImage];
    
    JLLog_D(@"message.length = %d", message.length);
    NSString * myJID =  [NSString stringWithFormat:@"%@@%@",MY_USER_NAME, OpenFireHostName];
    //消息随机ID
    _imgMsgRandomId = [IdGenerator next];
    //将消息随机ID保存数组，更新时用到。
    [self.tempImgMsgRandomIdArray addObject:_imgMsgRandomId];
    
    
    if (message.length==0) {
        return;
    }
    // NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
    NSDate *nowTime = [Utility getCurrentDate:@"yyy-MM-dd HH:mm:ss"];
    
    NSString *bodyJsonStr =  [NSString stringWithFormat:@"%@%@%@%@%@",@"{\"data\":\"", message,@"\",\"src\":\"\",\"link\":\"",imagePath,@"\"}"];
    
    if ([self.chatArray lastObject] == nil) {
        [self.chatArray addObject:nowTime];
    } {
        NSString *current = [Utility stringFromDate:nowTime formatStr:@"yyyy-MM-dd HH:mm:ss"];
        NSString *next = [Utility stringFromDate:_lastTime formatStr:@"yyyy-MM-dd HH:mm:ss"];
        
        if(![[Utility friendlyTime:current] isEqualToString:[Utility friendlyTime:next]]){
            [self.chatArray addObject:nowTime];
        }
    }
    self.lastTime = nowTime;
    
    [self.chatTableView reloadData];
    //检测网络情况
    NSString *network = @"connection";
    NSString *sendTimeStr =[Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    NSString *sendUTCTimeStr = [Utility getUTCFormateLocalDate:sendTimeStr];
    
    int msgIdInt;
    
    //消息写入数据库
    //  NSString *imageBodyJsonStr =  [NSString stringWithFormat:@"%@%@%@",@"{\"data\":\"", info,@"\",\"src\":\"\",\"link\":\"no url\"}"];
    NSString *imageJsonStr = [bodyJsonStr stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    
    [ChatMessageCRUD insertChatMessage:MY_USER_NAME msg:imageJsonStr receiveUser:_chatWithUser msgType:@"chat" subject:@"image" sendTime:sendUTCTimeStr receiveTime:sendUTCTimeStr readMark:1 sendStatus:network msgRandomId:_imgMsgRandomId myJID:MY_JID];
    //[self updateTable:MY_USER_NAME];
    NSString *msgId = [ChatMessageCRUD queryIdByUserName:MY_USER_NAME chatWithUser:_chatWithUser];
    NSString *avatarImage = [[NSUserDefaults standardUserDefaults] stringForKey:@"headImage"];
    
    UIView *chatView = [self bubbleView:bodyJsonStr msgId:msgId msgRandomId:_imgMsgRandomId from:YES type:@"chat" subject:@"image" avatar:avatarImage sendStatus:network];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId",_imgMsgRandomId,@"msgRandomId", imageJsonStr, @"text", MY_USER_NAME, @"speaker",@"chat",@"type", @"image",@"subject",network, @"sendStatus",chatView, @"view", nil];
    [self.chatArray addObject:dict];
    [self.chatTableView reloadData];
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                              atScrollPosition: UITableViewScrollPositionBottom
                                      animated:YES];
    msgIdInt = [msgId intValue];
    
    //NSLog(@"播放提示音");
    [JSMessageSoundEffect playMessageSentSound];
    
    //查询聊天列表是否存在
    // Contacts *contacts = [[Contacts alloc]init];
    Contacts *contacts = [ChatBuddyCRUD queryBuddyByJID:_chatWithJID myJID:myJID];
    UserInfo *userinfo = [UserInfoCRUD queryUserInfo:_chatWithJID myJID:MY_JID];
    NSString *lastMsgTime = [Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    //[图片]
    NSString *lastMsg = NSLocalizedString(@"chatviewPublic.pictureFlag",@"message");
    if(!self.chatBuddyFlag){
        [ChatBuddyCRUD insertChatBuddyTable:_chatWithUser jid:_chatWithJID name:self.remarkName nickName:userinfo.nickName phone:userinfo.phone avatar:userinfo.avatar myUserName:MY_USER_NAME type:@"chat" lastMsg:lastMsg msgType:@"chat" msgSubject:@"image" lastMsgTime:lastMsgTime tag:@""];
        self.chatBuddyFlag = YES;
    }else{
        [ChatBuddyCRUD updateChatBuddy:_chatWithUser name:contacts.remarkName nickName:userinfo.nickName lastMsg:lastMsg msgType:@"chat" msgSubject:@"image" lastMsgTime:sendTimeStr];
    }
    
    [self upLoadImageData:[ImageUtility fixOrientation:aImage] msgId:msgIdInt];
}


-(void)sendImageLink:(int)imageTag link:(NSString *)imageLink {
    
    JLLog_I(@"<imageLink=%@, tag=%d>", imageLink, imageTag);
    
    if(self.tempSendImageArray.count < imageTag){
        return;
    }
    
    UIImage * aImage = [self.tempSendImageArray objectAtIndex:imageTag-1];
    NSString *tfsLink =[NSString stringWithFormat:@"%@/%@",ResourcesURL, imageLink];
    [mResourceCache storeImage:aImage forKey:tfsLink];
    
    NSString *message = [Photo image2String:aImage];
    
    _imgMsgRandomId =[self.tempImgMsgRandomIdArray objectAtIndex:imageTag-1];
//    NSString *randomId = [self.tempImgMsgRandomIdArray objectAtIndex:imageTag-1];
    
    if (message.length==0) {
        return;
    }
    NSString *bodyJsonStr =  [NSString stringWithFormat:@"%@%@%@%@%@",@"{\"data\":\"", message,@"\",\"src\":\"\",\"link\":\"",imageLink,@"\"}"];
    if (message.length > 0) {
        // send message
        [self sendImageMessageXMLContruct:bodyJsonStr randomId:_imgMsgRandomId];
        // update SQLite
        if (![message isEqualToString:@""]){
            NSString *imageJsonStr = [bodyJsonStr stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
            [ChatMessageCRUD updateMsgByMsgRandomId:_imgMsgRandomId msg:imageJsonStr];
        }
        
        [self.chatTableView reloadData];
    }
    
}

- (void)sendImageMessageXMLContruct:(NSString *)aBody randomId:(NSString *)randomId {
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:aBody];
    //生成<subject>文档
    NSXMLElement *mtype = [NSXMLElement elementWithName:@"mtype"  xmlns:@"message:type"];
    [mtype setStringValue:@"image"];
    
    NSXMLElement *subject = [NSXMLElement elementWithName:@"subject"];
    [subject setStringValue:@"image"];
    
    //req
    NSXMLElement *req = [NSXMLElement elementWithName:@"req" xmlns:@"urn:xmpp:receipts"];
    [req addAttributeWithName:@"id" stringValue:randomId];
    
    
    //生成XML消息文档
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    //消息随机ID
    [mes addAttributeWithName:@"id" stringValue:randomId];
    //消息类型
    [mes addAttributeWithName:@"type" stringValue:@"chat"];
    //发送给谁
    [mes addAttributeWithName:@"to" stringValue:_chatWithJID];
    //由谁发送
    [mes addAttributeWithName:@"from" stringValue:MY_JID];
    //发送时间
    //[mes addAttributeWithName:@"time" stringValue:timeString];
    [mes addChild:subject];
    [mes addChild:mtype];
    [mes addChild:body];
    [mes addChild:req];
    //发送消息
    
    //JLLog_I(@"%@", mes);
    [[XMPPServer xmppStream] sendElement:mes];
}


//上传图片
-(void) upLoadImageData:(UIImage *)image msgId:(int)msgId
{
    if(image.size.width > 2000){
        image = [ImageUtility imageWithImageSimple:image scaledToSize:CGSizeMake(image.size.width/2, image.size.height/2)];
    }
    ++imageCount;
    //self.tempSendImage = image;
    [self.tempSendImageArray addObject:image];
    NSMutableData *imageData = (NSMutableData *)UIImageJPEGRepresentation(image, 0.5);
    JLLog_D(@"upload image data length = %d", imageData.length);
    
    //imageMsgId = msgId;
    NSString *urlstr = ResourcesURL;
    NSURL *myurl = [NSURL URLWithString:urlstr];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:myurl];
    request.delegate = self;
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"image/jpg"];//这里的value值 需与服务器端 一致
    //设置表单提交项
    [request setPostBody:imageData];
    //[request setDelegate:self];
    // [request setUploadProgressDelegate:self];
    //request.showAccurateProgress=YES;
    //[request setPostValue:data forKey:@""];
    //[request setFile: amrPath forKey: @"this_is_file"];
    //[request setPostValue:username.text forKey:@"password"];
    // request.delegate = self;
    [request setUploadProgressDelegate:self];
    request.showAccurateProgress = YES;
    [request buildRequestHeaders];
    //[request setDidFinishSelector:@selector(GetImageResult:)];
    //[request setDidFailSelector:@selector(GetErr:)];
    request.tag=imageCount;
    [request setTimeOutSeconds:120];
    
    JLLog_I(@"<imagecount=%d, tag=%d>", imageCount, request.tag);
    
    __weak typeof(request)wrequest = request;
    //使用block 否则退出再进入时会造成崩溃
    [request setCompletionBlock:^{
        NSData *jsonData =[wrequest responseData];
        //输出接收到的字符串
        NSDictionary *d = [jsonData objectFromJSONData];
        voiceLink = [d objectForKey:@"TFS_FILE_NAME"];
        // NSString *str = [NSString stringWithUTF8String:[jsonData bytes]];
        //NSLog(@"%@",voiceLink);
        
        [self sendImageLink:wrequest.tag link:voiceLink];
    }];
    
    [request setFailedBlock:^{
    }];
    
    
    [request startAsynchronous];
    // [request setShouldContinueWhenAppEntersBackground:YES];
    
}

- (void)reuploadImage:(UIImage *)image randomId:(NSString *)aRandomId {
    if(image.size.width > 2000){
        image = [ImageUtility imageWithImageSimple:image scaledToSize:CGSizeMake(image.size.width/2, image.size.height/2)];
    }
    NSMutableData *imageData = (NSMutableData *)UIImageJPEGRepresentation(image, 0.5);
    JLLog_D(@"upload image data length = %d", imageData.length);
    NSString *urlstr = ResourcesURL;
    NSURL *myurl = [NSURL URLWithString:urlstr];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:myurl];
    request.delegate = self;
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"image/jpg"];
    [request setPostBody:imageData];
    [request setUploadProgressDelegate:self];
    request.showAccurateProgress = YES;
    [request buildRequestHeaders];
    [request setTimeOutSeconds:120];
    
    __weak typeof(request) wrequest = request;
    [request setCompletionBlock:^{
        NSData *jsonData =[wrequest responseData];
        NSDictionary *d = [jsonData objectFromJSONData];
        NSString *imageLink = [d objectForKey:@"TFS_FILE_NAME"];
        
        JLLog_I(@"randomId=%@, link=%@", aRandomId, imageLink);
        
        NSString *message = [Photo image2String:image];
        NSString *bodyJsonStr =  [NSString stringWithFormat:@"%@%@%@%@%@",@"{\"data\":\"", message,@"\",\"src\":\"\",\"link\":\"",imageLink,@"\"}"];
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:bodyJsonStr];
        //生成<subject>文档
        NSXMLElement *mtype = [NSXMLElement elementWithName:@"mtype"  xmlns:@"message:type"];
        [mtype setStringValue:@"image"];
        
        NSXMLElement *subject = [NSXMLElement elementWithName:@"subject"];
        [subject setStringValue:@"image"];
        
        //req
        NSXMLElement *req = [NSXMLElement elementWithName:@"req" xmlns:@"urn:xmpp:receipts"];
        [req addAttributeWithName:@"id" stringValue:aRandomId];
        
        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息随机ID
        [mes addAttributeWithName:@"id" stringValue:aRandomId];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_chatWithJID];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:MY_JID];
        //发送时间
        //[mes addAttributeWithName:@"time" stringValue:timeString];
        [mes addChild:subject];
        [mes addChild:mtype];
        [mes addChild:body];
        [mes addChild:req];
        //发送消息
        [[XMPPServer xmppStream] sendElement:mes];
    }];
    
    [request setFailedBlock:^{
    }];
    
    [request startAsynchronous];
}

//- (void)queueComplete:(ASINetworkQueue *)queue
//{
//    NSLog(@"Max: %f",myProgressIndicator.progress);
//}

/*--进度************************************************
 -(void)setProgress:(float)newProgress{
 if(_sendImageArray.count>1){
 return;
 }
 
 for (NSDictionary*dic in self.chatArray ) {
 if ([dic isKindOfClass:[NSDate class]]) {
 continue;
 }
 if ([_imgMsgRandomId isEqualToString:[dic objectForKey:@"msgId"]]) {
 UIView *view = [dic objectForKey:@"view"];
 NSLog(@"****%f",newProgress*100);
 ((UILabel *)[view viewWithTag:[_imgMsgRandomId intValue]+1000]).text = [NSString stringWithFormat:@"%0.f%%",newProgress*100];
 
 if(newProgress==1.0)
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 
 [[view viewWithTag:[_imgMsgRandomId intValue]+1000] removeFromSuperview];
 
 });
 }
 }
 }
 
 
 -(void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes{
 NSLog(@"%lld",bytes);
 }
 
 -(void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength{
 NSLog(@"%lld",newLength);
 }
 ***********************************************************************************/

//application/octet-stream
//mage/tiff

//获取请求结果
- (void)GetImageResult:(ASIHTTPRequest *)request {
    
    NSData *jsonData =[request responseData];
    
    //输出接收到的字符串
    NSDictionary *d = [jsonData objectFromJSONData];
    voiceLink = [d objectForKey:@"TFS_FILE_NAME"];
    // NSString *str = [NSString stringWithUTF8String:[jsonData bytes]];
    //NSLog(@"%@",voiceLink);
    
//    [self sendImageLink:request.tag link:voiceLink];
}

//--------------语音功能－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
#pragma mark - 录制语音
- (IBAction)recordStart:(UIButton *)sender {
    //录音声音提示
    AudioServicesPlaySystemSound(RecordSOUNDID);
    
    //隐藏更多button,显示倒计时
    voiceCountDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
    voiceTimerLabel.text = [NSString stringWithFormat:@"%d",secondsCountDown];
    voiceSelectorBtn.hidden = YES;
    voiceTimerLabel.hidden = NO;
    
    UIButton *button = (UIButton *)sender;
    button.enabled = NO;
    [NSTimer scheduledTimerWithTimeInterval:2
                                     target:self
                                   selector:@selector(updateVoiceBtn:)
                                   userInfo:button
                                    repeats:NO];
    
    //button.backgroundColor = [UIColor colorWithRed:0.200 green:0.6 blue:1 alpha:1];
    button.backgroundColor = [UIColor orangeColor];
    
    button.titleLabel.textColor = [UIColor whiteColor];
    
    if(recording)
        return;
    
    [audioPlayer pause];
    recording=YES;
    
    NSDictionary *settings=[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat:8000],AVSampleRateKey,
                            [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                            [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                            [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                            nil];
    
    AVAudioSession * session = [AVAudioSession sharedInstance];
    NSError * sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    // [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    //[[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *fileName = [NSString stringWithFormat:@"rec_%@_%@.wav",MY_USER_NAME,[dateFormater stringFromDate:now]];
    NSString *fullPath = [[[ChatCacheFileUtil sharedInstance] userDocPath] stringByAppendingPathComponent:fileName];
    NSURL *url = [NSURL fileURLWithPath:fullPath];
    pathURL = url;
    
    NSError *error;
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:pathURL settings:settings error:&error];
    audioRecorder.delegate = self;
    
    peakTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updatePeak:) userInfo:nil repeats:YES];
    [peakTimer fire];
    
    [audioRecorder prepareToRecord];
    [audioRecorder setMeteringEnabled:YES];
    [audioRecorder peakPowerForChannel:0];
    [audioRecorder record];
    
    // [dateFormater release];
}



- (void)updatePeak:(NSTimer*)timer
{
    _timeLen = audioRecorder.currentTime;
    if(_timeLen>=60)
        [self recordStop:nil];
    
    /*    [audioRecorder updateMeters];
     const double alpha=0.5;
     double peakPowerForChannel=pow(10, (0.05)*[audioRecorder peakPowerForChannel:0]);
     lowPassResults=alpha*peakPowerForChannel+(1.0-alpha)*lowPassResults;
     
     for (int i=1; i<8; i++) {
     if (lowPassResults>1.0/7.0*i){
     [[talkView viewWithTag:i] setHidden:NO];
     }else{
     [[talkView viewWithTag:i] setHidden:YES];
     }
     }*/
}

- (IBAction)recordStop:(UIButton *)sender {
    //录音声音提示
    //AudioServicesPlaySystemSound(1114);
    
    JLLog_D(@"Voice record finish");
    //显示更多button,隐藏倒计时
    
    [voiceCountDownTimer invalidate];
    voiceSelectorBtn.hidden = NO;
    voiceTimerLabel.hidden = YES;
    secondsCountDown = 60;
    
    
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor whiteColor];
    
    
    if(!recording)
        return;
    [peakTimer invalidate];
    peakTimer = nil;
    
    //    [self offRecordBtns];
    
    _timeLen = audioRecorder.currentTime;
    if(_timeLen<1){
        [audioRecorder stop];
        // [audioRecorder release];
        recording = NO;
        
        [self showCustom];
        return;
    }
    
    [audioRecorder stop];
    
    NSString *amrPath = [VoiceConverter wavToAmr:pathURL.path];
    
    NSMutableData *recordData = [NSMutableData dataWithContentsOfFile:amrPath];
    
    
    // [[ChatCacheFileUtil sharedInstance] deleteWithContentPath:pathURL.path];
    //保留wav删除amr
    [[ChatCacheFileUtil sharedInstance] deleteWithContentPath:amrPath];
    _lastRecordFile = [[amrPath lastPathComponent] copy];
    
    //NSLog(@"音频文件路径:%@\n%@",pathURL.path,amrPath);
    
    //    if (_timeLen<1) {
    //        [g_App showAlert:@"录的时间过短"];
    //        return;
    //    }
    [self insertVoiceMsgAndShow: pathURL.path];
    
    //上传服务器
    [self upLoadVoiceData:recordData length:_timeLen randomId:_voiceMsgRandomId];
    // [audioRecorder release];
    recording = NO;
    
    
}


-(void) updateVoiceBtn:(NSTimer *)timer
{
    //your other code...
    //按住  说话
    UIButton *button = (UIButton *)[timer userInfo];
    [button setTitle:NSLocalizedString(@"chatviewPublic.holdToTalk",@"title") forState:UIControlStateNormal];
    [button setEnabled:YES];
    //button.layer.borderColor=[[UIColor colorWithRed:0.200 green:0.6 blue:1 alpha:1] CGColor];
    //button.layer.borderColor=[[UIColor orangeColor] CGColor];
    //your other code
    button.backgroundColor = AB_Color_efe8df;
}



- (IBAction)recordCancel:(UIButton *)sender
{
    //删除声音提示
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    //显示更多button,隐藏倒计时
    //[voiceCountDownTimer invalidate];
    voiceSelectorBtn.hidden = NO;
    voiceTimerLabel.hidden = YES;
    secondsCountDown = 60;
    //已取消
    UIButton *button = (UIButton *)sender;
    [button setTitle:NSLocalizedString(@"chatviewPublic.cancelled",@"title") forState:UIControlStateNormal];
    button.layer.borderColor = [[UIColor grayColor]CGColor];
    button.backgroundColor = AB_Color_ffffff;
    [NSTimer scheduledTimerWithTimeInterval:2
                                     target:self
                                   selector:@selector(updateVoiceBtn:)
                                   userInfo:button
                                    repeats:NO];
    
    if(!recording)
        return;
    
    [self scrapDriveUpAnimation];
    
    [audioRecorder stop];
    // [audioRecorder release];
    [peakTimer invalidate];
    peakTimer = nil;
    recording = NO;
    
}

-(void)sendVoiceLink:(NSString *)link length:(NSInteger)length randomId:(NSString *)randomId {

    //生成消息对象
    VoiceBody *body=[[VoiceBody alloc]init];
    body.path = @"";
    body.time = [NSNumber numberWithInt:length];
    body.src = @"";
    body.link =link;
    //NSLog(@"发送语音消息@");
    NSDictionary *dic = [body toDictionary];
    NSString * bodyJsonStr = [dic JSONString];
    NSString *timeString=Utility.getCurrentDate;
    
    JLLog_I(@"<voice send> Json=%@", bodyJsonStr);
    
    //开始发送
    if (link.length > 0) {
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:bodyJsonStr];
        //消息类型
        NSXMLElement *mtype = [NSXMLElement elementWithName:@"mtype"  xmlns:@"message:type"];
        [mtype setStringValue:@"voice"];
        //生成<subject>文档
        NSXMLElement *subject = [NSXMLElement elementWithName:@"subject"];
        [subject setStringValue:@"voice"];
        
        //req
        NSXMLElement *req = [NSXMLElement elementWithName:@"req" xmlns:@"urn:xmpp:receipts"];
        [req addAttributeWithName:@"id" stringValue:randomId];
        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息随机ID
        [mes addAttributeWithName:@"id" stringValue:randomId];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_chatWithJID];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:MY_JID];
        //发送时间
        [mes addAttributeWithName:@"time" stringValue:timeString];
        //组合
        [mes addChild:mtype];
        [mes addChild:subject];
        [mes addChild:body];
        [mes addChild:req];
        
        //发送消息
        [[XMPPServer xmppStream] sendElement:mes];
        
    }
    
}

//将语音写库并显示
-(void)insertVoiceMsgAndShow:(NSString *)voicePath{
    JLLog_D(@"Voice Handle");
//    JLLog_I(@"<voice path=%@>",voicePath);
    
    //消息随机ID
    _voiceMsgRandomId = [IdGenerator next];
    //生成消息对象
    int voiceTime = [[Utility decimalwithFormat:@"0" floatV:_timeLen]intValue];
    VoiceBody *body=[[VoiceBody alloc]init];
    body.path = @"";
    body.time = [NSNumber numberWithInt:voiceTime];
    body.src = @"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    
    body.link = [voicePath substringFromIndex:docPath.length];
    NSDictionary *dic = [body toDictionary];
    NSString * bodyJsonStr = [dic JSONString];
    
    //检测网络情况
    NSString *network = @"connection";
    //发送时间
    NSString *sendTimeStr =[Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    NSString *sendUTCTimeStr = [Utility getUTCFormateLocalDate:sendTimeStr];
    
    
    //消息写入数据库
    if (![bodyJsonStr isEqualToString:@""]){
        //存入数据库时需要对双引号转换处理
        NSString *voiceJsonStr = [bodyJsonStr stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
        [ChatMessageCRUD insertChatMessage:MY_USER_NAME msg:voiceJsonStr receiveUser:_chatWithUser msgType:@"chat" subject:@"voice" sendTime
                                          :sendUTCTimeStr receiveTime:sendUTCTimeStr readMark:1 sendStatus:network msgRandomId:_voiceMsgRandomId myJID:MY_JID];
    }
    
    NSDate *nowTime = [Utility getCurrentDate:@"yyyy-MM-dd HH:mm:ss"];
    
    if ([self.chatArray lastObject] == nil) {
        [self.chatArray addObject:nowTime];
    } else {
        NSString *current = [Utility stringFromDate:nowTime formatStr:@"yyyy-MM-dd HH:mm:ss"];
        NSString *next = [Utility stringFromDate:_lastTime formatStr:@"yyyy-MM-dd HH:mm:ss"];
        
        if(![[Utility friendlyTime:current] isEqualToString:[Utility friendlyTime:next]]){
            [self.chatArray addObject:nowTime];
        }
    }
    _lastTime = nowTime;
    //  [self insertTable:userName sencond:message third:_chatWithUser  msgType:@"chat" subject:@"voice" sendTime:timeString];
    //  [self updateTable:userName];
    NSString *msgId = [ChatMessageCRUD queryIdByUserName:MY_USER_NAME chatWithUser:_chatWithUser];
    //用户头像
    NSString *avatarImage = [[NSUserDefaults standardUserDefaults] stringForKey:@"headImage"];
    UIView *chatView = [self bubbleView:bodyJsonStr msgId:msgId msgRandomId:_voiceMsgRandomId from:YES type:@"chat" subject:@"voice" avatar:avatarImage sendStatus:network];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId",_voiceMsgRandomId,@"msgRandomId", bodyJsonStr, @"text", MY_USER_NAME, @"speaker",@"chat",@"type",@"voice",@"subject",network, @"sendStatus",chatView, @"view", nil];
    [self.chatArray addObject:dict];
    [self.chatTableView reloadData];
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                              atScrollPosition: UITableViewScrollPositionBottom
                                      animated:YES];
    
    //NSLog(@"播放提示音");
    [JSMessageSoundEffect playMessageSentSound];
    
    //查询聊天列表是否存在
    //Contacts *contacts = [[Contacts alloc]init];

    UserInfo *userinfo = [UserInfoCRUD queryUserInfo:_chatWithJID myJID:MY_JID];
    NSString *lastMsgTime = [Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    //@"[语音]"
    NSString *lastMsg = NSLocalizedString(@"chatviewPublic.voiceFlag",@"message");
    if(self.chatBuddyFlag == NO){
        [ChatBuddyCRUD insertChatBuddyTable:_chatWithUser jid:_chatWithJID name:self.remarkName nickName:userinfo.nickName phone:userinfo.phone avatar:userinfo.avatar myUserName:MY_USER_NAME type:@"chat" lastMsg:lastMsg msgType:@"chat" msgSubject:@"voice" lastMsgTime:lastMsgTime tag:@""];
        self.chatBuddyFlag = YES;

    }else{
        [ChatBuddyCRUD updateChatBuddy:_chatWithUser name:self.remarkName nickName:userinfo.nickName lastMsg:lastMsg msgType:@"chat" msgSubject:@"voice" lastMsgTime:lastMsgTime];
    }
    
    //JLLog_I(@"last object=%@", self.chatArray.lastObject);
}


//上传声音数据到资源服务器
-(void) upLoadVoiceData:(NSMutableData *)data length:(NSInteger)length randomId:(NSString *)randomId
{
    JLLog_I(@"<upload length=%d, randomId =%@>", data.length, randomId);
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
    
    __weak typeof(request) wrequest = request;
    [request setCompletionBlock:^{
        NSData *jsonData =[wrequest responseData];
        //输出接收到的字符串
        NSDictionary *d = [jsonData objectFromJSONData];
        voiceLink = [d objectForKey:@"TFS_FILE_NAME"];
        // NSString *str = [NSString stringWithUTF8String:[jsonData bytes]];
        JLLog_I(@"<voice link=%@>", voiceLink);
        [self sendVoiceLink:voiceLink length:length randomId:randomId];
        
    }];
    
    [request setFailedBlock:^{
    }];
    
    [request startAsynchronous];
}


//获取请求结果
- (void)GetVoiceResult:(ASIHTTPRequest *)request{
    NSData *jsonData =[request responseData];
    //输出接收到的字符串
    NSDictionary *d = [jsonData objectFromJSONData];
    voiceLink = [d objectForKey:@"TFS_FILE_NAME"];
    // NSString *str = [NSString stringWithUTF8String:[jsonData bytes]];
    NSLog(@"%@",voiceLink);
//    [self sendVoiceLink:voiceLink];
   	
}



//连接错误调用这个函数
- (void) GetErr:(ASIHTTPRequest *)request{
    //NSLog(@"error%@",request);
}

// Upload file
- (void)uploadData:(NSData *)aData
          complete:(void(^)(NSString* TFSlink))complete fail:(void(^)())fail{
    
    NSURL *url = [NSURL URLWithString:ResourcesURL];
    ASIFormDataRequest  *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:[NSMutableData dataWithData:aData]];
    [request buildRequestHeaders];
    
    // Using block...
    request.completionBlock = ^{
        NSData *jsonData = [request responseData];
        NSDictionary *d = [jsonData objectFromJSONData];
        NSString *link = d[@"TFS_FILE_NAME"];
        if(complete){
            complete(link);
        }
    };
    
    [request setFailedBlock:^{
        [AIControllersTool tipViewShow:@"文件上传失败"];
        if(fail){
            fail();
        }
    }];
    
    [request startAsynchronous];
}

// Send Document message XML contruct
// Later rewrite for image/chat/card also
- (void)sendMessageXMLContruct:(NSString *)aBody
                      randomId:(NSString *)aRandomId
                       subject:(NSString *)aSubject
                      chatType:(NSString *)aType
                            to:(NSString *)to
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message" xmlns:@"jabber:client"];
        
        [mes addAttributeWithName:@"id" stringValue:aRandomId];
        // set type of chat ("groupchat"/"chat")
        [mes addAttributeWithName:@"type" stringValue:aType];
        [mes addAttributeWithName:@"to" stringValue:to];
        [mes addAttributeWithName:@"from" stringValue:MY_JID];
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:aBody];
        
        NSXMLElement *mtype = [NSXMLElement elementWithName:@"mtype"  xmlns:@"message:type"];
        [mtype setStringValue:aSubject];
        
        NSXMLElement *mSubject = [NSXMLElement elementWithName:@"subject"];
        [mSubject setStringValue:aSubject];
        
        NSXMLElement *req = [NSXMLElement elementWithName:@"req" xmlns:@"urn:xmpp:receipts"];
        [req addAttributeWithName:@"id" stringValue:aRandomId];
        
        [mes addChild:mtype];
        [mes addChild:mSubject];
        [mes addChild:body];
        [mes addChild:req];
        
        JLLog_I(@"%@", mes);
        [[XMPPServer xmppStream] sendElement:mes];
    });
}


//播放声音文件
- (void) chatPlayVoice:(UIButton *)btn{
    NSInteger msgId = btn.tag;
    // NSDictionary *item = [self.chatArray objectAtIndex:index];
    // NSString *voiceMessageJson= [item objectForKey:@"text"];
    NSString *voiceMessageJson = [ChatMessageCRUD queryMsgByMsgId:msgId];
    
    //更新语音消息为已播放
    [ChatMessageCRUD updateMessageReadMark:[NSString stringWithFormat:@"%d", msgId] readMark:2];
    
    //去掉红点
    [[btn.superview viewWithTag:10000] setHidden:YES];
    
    NSLog(@"*****%@",voiceMessageJson);
    
    NSString *sender = [ChatMessageCRUD querySenderByMsgId:msgId];
    
    // [btn setBackgroundImage:[UIImage imageNamed:@"bubble-flat-outgoing-selected"] forState:UIControlStateNormal];//backgroundImage
//    YLImageView* imageView = [[YLImageView alloc] initWithFrame:CGRectMake(5.0f, 3.0f, 20, 25)];
//    if([sender isEqualToString:MY_USER_NAME]){
//        imageView.frame = CGRectMake(0.0f, 0.0f, 20, 25);
//        
//        NSString *voiceSendImgPath = [[NSBundle mainBundle] pathForResource:@"voice_send" ofType:@"gif"];
//        
//        imageView.image = [YLGIFImage imageWithContentsOfFile:voiceSendImgPath];
//    }else{
//        imageView.frame =    CGRectMake(btn.frame.size.width-30,0.0f, 20, 25);
//        NSString *voiceRecImgPath = [[NSBundle mainBundle] pathForResource:@"voice_recv" ofType:@"gif"];
//        
//        imageView.image = [YLGIFImage imageWithContentsOfFile:voiceRecImgPath];
//    }
//    
//    imageView.backgroundColor = [UIColor clearColor];
//    imageView.tag = 3000;
//    
//    
//    [btn addSubview:imageView];
    
    UIImageView* imageview = [[UIImageView alloc]init];
    for(UIView* view in btn.subviews){
        if([view isKindOfClass:[UIImageView class]]){
            imageview = (UIImageView*)view;
            [imageview startAnimating];
            break;
        }
    }
    
    
    
    //NSLog(@"******%@",voiceMessageJson);
    NSDictionary *voiceDic = [voiceMessageJson objectFromJSONString];
    //NSLog(@"voice.link:%@",[voiceDic objectForKey:@"link"]);
    //NSLog(@"voice.time:%@",[voiceDic objectForKey:@"time"]);
    //voiceLink = @"T1iyETBydT1RCvBVdK";
    //  voiceLink=@"T1YRJTByxT1RCvBVdK";
    NSString *urlstr = ResourcesURL;
    voiceLink =[voiceDic objectForKey:@"link"];
    //NSURL *voiceUrl = [NSURL URLWithString:urlstr];
    
    int voiceTime = [[voiceDic objectForKey:@"time"] intValue];
    //NSLog(@"%@",voiceDic);
//    NSTimer* voiceTimer=[NSTimer scheduledTimerWithTimeInterval:voiceTime
//                                                         target:self
//                                                       selector:@selector(chanageVoiceIcon:)
//                                                       userInfo:btn
//                                                        repeats:NO];
    NSDictionary* valueDic = @{@"imageView":imageview, @"sender":sender};
    

    
    NSString *wavPath = @"";
    //发送者是自己时，语音读取本地路径播放，否则读取网络路径播放
    if ([sender isEqualToString:MY_USER_NAME]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        if (!docDir) {
            //NSLog(@"Documents 目录未找到");
        }
        
        wavPath = [NSString stringWithFormat:@"%@/%@/%@",docDir,MY_USER_NAME, voiceLink.lastPathComponent];
    }else{
        NSString *filePath = [self DownloadTextFile:urlstr fileName:voiceLink];
        NSLog(@"%@",filePath);
        wavPath = [VoiceConverter amrToWav:filePath];
    }
    
    NSLog(@"*******amrPath%@",wavPath);
    
    [self performSelector:@selector(changeVoicePlayBtImageView:) withObject: valueDic afterDelay:voiceTime];
    
    if([StrUtility isBlankString:wavPath]){
        return;
    }
    //NSMutableData *voiceData = [NSMutableData dataWithContentsOfFile:wavPath];
    
    //NSLog(@"*******voiceData%@",voiceData);
    
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
    //默认情况下扬声器播
    if([self.playMode isEqualToString:@"Playback"]){
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
    }else if([self.playMode isEqualToString:@"Play"]){
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
        
    }
    //NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // NSString *docsDir = [dirPaths objectAtIndex:0];
    // NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"recordTest.caf"];
    
    NSURL *url = [NSURL fileURLWithPath:wavPath];
    // NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/recordTest.caf", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.delegate = self;
    // audioPlayer=[[AVAudioPlayer alloc] initWithData:voiceData error:&error] ;
    audioPlayer.numberOfLoops = 0;
    [audioPlayer play];
    //NSLog(@"playing");
    if(audioPlayer != nil){
        self.playNumber++;
        [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    }
   
    //继续播放下一条
    if(mUnplayedVoiceArray.count > 0){
        int currentIndex = [mUnplayedVoiceArray indexOfObject:btn];
        if(currentIndex > -1){
            if(currentIndex < mUnplayedVoiceArray.count - 1){
                UIButton *nextButton = mUnplayedVoiceArray[currentIndex+1];
                [self performSelector:@selector(chatPlayVoice:) withObject:nextButton afterDelay:voiceTime + 1];
            }
            [mUnplayedVoiceArray removeObject:btn];
        }
    }
}

//进入地图
- (void) gotoMap:(UIButton *)btn{
    NSInteger msgId = btn.tag;
    NSString *locationMessageJson = [ChatMessageCRUD queryMsgByMsgId:msgId];
  
    NSDictionary *locationDic = [locationMessageJson objectFromJSONString];
    float latitude = [locationDic[@"latitude"] floatValue];
    float longitude = [locationDic[@"longitude"] floatValue];
    JLLog_D(@"latitude:%lf, longitude:%lf", latitude, longitude);
    BaiduMapViewController *controller = [[BaiduMapViewController alloc] init];
    controller.delegate = self;
    controller.latitude = latitude;
    controller.longitude = longitude;
    controller.addressName = locationDic[@"locationName"];
    controller.address = locationDic[@"address"];
    AINavigationController *nav = [[AINavigationController alloc]initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
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


-(void)chanageVoiceIcon:(NSTimer*)timer{
    // [btn setBackgroundImage:[UIImage imageNamed:@"bubble-flat-outgoing"] forState:UIControlStateNormal];
    [[[timer userInfo] viewWithTag:3000] removeFromSuperview];
}


//更换图标
-(void)changeVoicePlayBtImageView:(NSDictionary*)valueDic{
    UIImageView* imageview = [valueDic valueForKey:@"imageView"];
    NSString* sender = [valueDic valueForKey:@"sender"];
    [imageview stopAnimating];
    if([sender isEqualToString:MY_USER_NAME]){
        imageview.image = [UIImage imageNamed:@"chatto_voice"];
    }else{
        imageview.image = [UIImage imageNamed:@"chatfrom_voice"];
    }
    
}


-(NSString*)DownloadTextFile:(NSString*)fileUrl   fileName:(NSString*)fileNameStr
{
    //NSLog(@"*****%@",fileNameStr);
    fileUrl = [NSString stringWithFormat:@"%@/%@",fileUrl,fileNameStr ];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    if (!docDir) {
        //NSLog(@"Documents 目录未找到");
    }
    
    fileNameStr = [NSString stringWithFormat:@"%@/%@.%@",MY_USER_NAME,fileNameStr,@"amr"];
    NSString *filePath = [docDir stringByAppendingPathComponent:fileNameStr];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:filePath]){
        NSURL *url = [NSURL URLWithString:fileUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        [data writeToFile:filePath atomically:YES];
    }
    
    return filePath;
}


//下拉刷新
#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    tableView.frame = CGRectMake(0.0f, 64.0f, 320.0f,(float)(viewHight-64-49.0));
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 0) {
        [self loadDataUp];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        self.activity.hidden = NO;
        if (!self.activity.isAnimating) {
            [self.activity startAnimating];
        }
    }
}

- (void)loadDataUp{
    
    _start +=_pageSize;
    //NSLog(@"******%d,%d,%d",_start,_pageSize,_total);
    
    if (_start>=_total) {
        // [self.chatTableView tableViewDidFinishedLoadingWithMessage:@"已加载所有数据!"];
        //self.chatTableView.reachedTheEnd  = YES;
        [self.activity stopAnimating];
        return;
    }
    pageCellHeight=0;
    [self receiveBeforeMessage:_start total:_pageSize flag:1];

    [self.activity stopAnimating];
    
    //[_chatTableView beginUpdates];
    [_chatTableView setContentOffset:CGPointMake(0,pageCellHeight+120) animated:NO];
    //[_chatTableView endUpdates];
    
    // [self refreshChatMsg2];
    
    //[_chatTableView reloadData];
    //[self.chatTableView tableViewDidFinishedLoading];
    
}

- (void)loadDataDown{
    
}

//刷新
-(void)refreshChatMsg{
    //初始化分页
    _pageSize =10;
    _start =0;
    int total = self.chatArray.count;
    [self.chatArray removeAllObjects];
    
    [self loadMessage:0 total:total flag:0];
}

//解决分页是消息状态更新的问题
//-(void)refreshChatMsg2{
//
//    int total = self.chatArray.count;
//
//    [self receiveBeforeMessage2:0 total:total flag:0];
//}


//变更聊天历史列表好友已存在；
-(void)updateChatBuddyFlag{
    self.chatBuddyFlag = YES;
}


//接收新消息
#pragma mark KKMessageDelegate
- (void) newMessageReceived:(NSDictionary *)messageCotent{
    [self.messages addObject:messageCotent];
    [self receiveMessage:messageCotent];
}

-(void)receiveMessage:(NSDictionary *)messageContent{
    
    //  NSString * myJID =  [NSString stringWithFormat:@"%@@%@",MY_USER_NAME, OpenFireHostName];
    //接收到数据，用泡泡VIEW显示出来
    //发送者
    NSString *sender = [messageContent objectForKey:@"sender"];
    NSString *msg= [messageContent objectForKey:@"msg"];
    NSString *type = [messageContent objectForKey:@"type"];
    NSString  *subject = [messageContent objectForKey:@"subject"];
    NSString  *sendUTCTime = [messageContent objectForKey:@"sendTime"];
    NSString *msgRandomId =[messageContent objectForKey:@"msgRandomId"];
    
    NSDate * sendDate = [Utility getNowDateFromatAnDate:[Utility dateFromUtcString:sendUTCTime]];
    
    NSString *senderStr = nil;
    if (![sender isEqualToString:@"me"]) {
        NSString*str_character = @"@";
        NSRange senderRange = [sender rangeOfString:str_character];
        if ([sender rangeOfString:str_character].location != NSNotFound) {
            senderStr = [sender substringToIndex:senderRange.location];
        }
    }
    
    //NSLog(@"截取出来的字符串str＝%@",senderStr);
    //NSLog(@"接收到数据，用泡泡VIEW显示出来%@",_chatWithNick);
    
    if ([senderStr isEqualToString:_chatWithUser]) {
        
        NSString*msgId=[ChatMessageCRUD queryMessageId:_chatWithUser];
        // 发送后生成泡泡显示出来
        
        NSDate *nowTime = [Utility getCurrentDate:@"yyyy-MM-dd HH:mm:ss"];
        
        if ([self.chatArray lastObject] == nil) {
            [self.chatArray addObject:nowTime];
        } else {
            NSString *current = [Utility stringFromDate:nowTime formatStr:@"yyyy-MM-dd HH:mm:ss"];
            NSString *next = [Utility stringFromDate:_lastTime formatStr:@"yyyy-MM-dd HH:mm:ss"];
            
            if(![[Utility friendlyTime:current] isEqualToString:[Utility friendlyTime:next]]){
                [self.chatArray addObject:nowTime];
            }
        }
        
        self.lastTime = nowTime;
        
        //接收消息时，默认有网状态
        NSString *sendStatus =@"connection";
        //用户头像
        NSString *avatar = [ContactsCRUD queryContactsAvatar:_chatWithJID];
        UIView *chatView = [self bubbleView:msg msgId:msgId msgRandomId:msgRandomId
                                       from:NO type:type subject:subject avatar:avatar sendStatus:sendStatus];
        
        //更新消息为已读
        //[ChatMessageCRUD updateMessageReadMark:msgId readMark:1];
        
        [self.chatArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", msg, @"text", _chatWithUser, @"speaker", chatView,@"view",type,@"type",subject,@"subject",sendStatus,@"sendStatus",sendDate,@"sendDate", nil]];
        
        [self.chatTableView reloadData];
        
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                                  atScrollPosition: UITableViewScrollPositionBottom
                                          animated:YES];
        
        
        if ([_messgaeFlag isEqualToString:@"UpdateMessageFlag"]) {
            //[ChatMessageCRUD updateFlagByUserName:_chatWithUser userName:MY_USER_NAME];
            //NSLog(@"播放提示音");
            [JSMessageSoundEffect playMessageReceivedSound];
            
        }
    }
}




//接收之前消息
-(void)receiveBeforeMessage:(int)start total:(int)total flag:(int)flag
{
    // dispatch_async(dispatch_get_main_queue(), ^{
    // NSString * myJID =  [NSString stringWithFormat:@"%@@%@",MY_USER_NAME, OpenFireHostName];
    //接收到数据，用泡泡VIEW显示出来
    //NSLog(@"接收之前消息");
    NSString *userName = MY_USER_NAME;
    //NSString *selectSqlStr=[NSString stringWithFormat:@"select count(id) from ChatMessage where flag=\"%d\" and userName=\"%@\" ",0,userName];
    NSString *selectSqlStr=[NSString stringWithFormat:@"select id,msgRandomId,sendUser,message,readMark,receiveUser,msgType,subject,sendStatus,receiveTime from ChatMessage where ((sendUser=\"%@\" and receiveUser=\"%@\") or (sendUser=\"%@\" and receiveUser=\"%@\")) and myJID=\"%@\" order by receiveTime desc, id desc limit %d,%d",_chatWithUser,userName,userName,_chatWithUser,MY_JID,start,total];
    
    
    NSLog(@"****%@",selectSqlStr);
    
    //清空重新赋值
    //NSLog(@"********%d",self.chatArray.count);
    //    for (int i=0; i<_chatArray.count; i++) {
    //        [_beforeChatArray addObject:[_chatArray objectAtIndex:i]];
    //    }
    //   _beforeChatArray = (NSMutableArray *)[[_chatArray reverseObjectEnumerator] allObjects];
    //[_chatArray removeAllObjects];
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    NSDate *lastTime = _chatArray.firstObject;
    if ([db open]) {
        int i=0;
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        NSMutableArray *connectionMessages = [@[] mutableCopy];
        while ([rs next]) {
            i++;
            NSString * msgId = [rs stringForColumn:@"id"];
            
            NSString * msgRandomId = [StrUtility string:[rs stringForColumn:@"msgRandomId"]];
            
            NSString *senderUser = [rs stringForColumn:@"sendUser"];
            
            NSString *message = [rs stringForColumn:@"message"];
            
            NSString *type= [rs stringForColumn:@"msgType"];
            
            NSString *subjectType = [rs stringForColumn:@"subject"];
            
            NSString *sendStatus = [rs stringForColumn:@"sendStatus"];
            
            
            NSString *sendUTCTime = [rs stringForColumn:@"receiveTime"];
            
            NSDate * sendDate = [Utility getNowDateFromatAnDate:[Utility dateFromUtcString:sendUTCTime]];
            
            
            //NSLog(@"%@",subjectType);
            //图片，语音为json格式，写入数据库时将双引号转成了单引号，出库时须将单引号转回；
            if ([subjectType isEqualToString:@"image"] || [subjectType isEqualToString:@"voice"]) {
                message =  [message stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
            }

            //区分自己和好友
            if ([senderUser isEqualToString:MY_USER_NAME]) {
                UIView *chatView = [self bubbleView:message msgId:msgId msgRandomId:msgRandomId
                                               from:YES type:type subject:subjectType avatar:myAvatarURL sendStatus:sendStatus];
                
                //纪录新加载数据高度用于分页效果
                pageCellHeight+=chatView.frame.size.height;
                [_chatArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId",msgRandomId,@"msgRandomId", message, @"text", senderUser, @"speaker", chatView, @"view",type,@"type",subjectType,@"subject",sendStatus,@"sendStatus",sendDate,@"sendDate", nil] atIndex:0];
            }else {
                //用户头像
                NSString *avatar = [ContactsCRUD queryContactsAvatar:_chatWithJID];
                // 发送后生成泡泡显示出来
                UIView *chatView = [self bubbleView:message msgId:msgId msgRandomId:msgRandomId from:NO type:type subject:subjectType avatar:avatar sendStatus:sendStatus];
                //纪录新加载数据高度用于分页效果
                pageCellHeight+=chatView.frame.size.height;
                [_chatArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId",msgRandomId,@"msgRandomId", message, @"text", senderUser, @"speaker", chatView, @"view",type,@"type",subjectType,@"subject",sendStatus,@"sendStatus",sendDate,@"sendDate", nil] atIndex:0];
            }
            
            if ([sendStatus isEqualToString:@"connection"]) {
                [connectionMessages addObject:self.chatArray[0]];
            }
            
            NSString *current = [Utility stringFromDate:sendDate formatStr:@"yyyy-MM-dd HH:mm:ss"];
            NSString *next = [Utility stringFromDate:lastTime formatStr:@"yyyy-MM-dd HH:mm:ss"];
            
            if(i == 1){
                if([[Utility friendlyTime:current] isEqualToString:[Utility friendlyTime:next]]){
                    [_chatArray removeObjectAtIndex:1];
                    pageCellHeight-=(21+16)*kScreenScale;
                } else {
                    
                }
            } else {
                if (next != nil && ![[Utility friendlyTime:current] isEqualToString:[Utility friendlyTime:next]]) {
                    [_chatArray insertObject:lastTime atIndex:1];
                    pageCellHeight+=(21+16)*kScreenScale;
                }
            }
            
            lastTime = sendDate;
        }
        
        [_chatArray insertObject:lastTime atIndex:0];
        pageCellHeight+=(21+16)*kScreenScale;
        [_chatArray insertObject:@"loading" atIndex:0];
        
        [rs close];
        
        if ([XMPPServer xmppStream].isConnected) {
            //NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            //[queue addOperationWithBlock:^{
                [self vc_resendConnectionMessages:connectionMessages];
            //}];
        }
        
    }else{
        //error
        // [self ErrorReport: (NSString *)selectSqlStr];
    }
    
    [db close];
    
    _currentPage++;
    
    //NSLog(@"********%d",self.chatArray.count);
    //加载定位
    [_chatTableView reloadData];
    if(_chatArray.count>0){
        //[_chatTableView setContentOffset:CGPointMake(0,0) animated:NO];
        
        //        [_chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:beforeChatArrayCount+1 inSection:0]
        //                              atScrollPosition: UITableViewScrollPositionBottom
        //                                      animated:NO];
        
    }
    
    [_tempChatArray removeAllObjects];
    [_beforeChatArray removeAllObjects];
    
    beforeChatArrayCount = _chatArray.count;
    
    
    if(_chatArray.count>0){
        [_chatArray removeObjectAtIndex:0];
    }
    //[_chatTableView deselectRowAtIndexPath:indexPath animated:YES];
    [_chatTableView reloadData];
    //NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:beforeChatArrayCount-currentRow inSection:0];
    //[_chatTableView scrollToRowAtIndexPath:currentIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)messageSendingAbort:(NSArray *)randomIds {
    for (NSString *randomId in randomIds) {
        for (NSDictionary *d in self.chatArray) {
            if ([d[@"msgRandomId"] isEqualToString:randomId]) {
                UIView *view = [d objectForKey:@"view"];
                UIImageView *warningImageView = [[UIImageView alloc] init];
                
                warningImageView.contentMode = UIViewContentModeScaleAspectFit;
                warningImageView.image = [UIImage imageNamed:@"icon_cuation"];
                
                for(UIView *sub in view.subviews){
                    if([sub isKindOfClass:YLImageView.class]){
                        warningImageView.frame = sub.frame;
                        [view addSubview:warningImageView];
                        [sub removeFromSuperview];
                        break;
                    }
                }
            }
        }
    }
}

- (void)reloadMessages:(NSArray *)randomIds {
    NSString *avatarImage = [[NSUserDefaults standardUserDefaults] stringForKey:@"headImage"];
    JLLog_I(@"<randomId=%@>", randomIds);
    for (NSString *aRandomId in randomIds) {
        NSDictionary *d = [ChatMessageCRUD queryMessageWithRandomId:aRandomId];
        NSString *message = d[@"message"];
        NSString *messageId = d[@"messageId"];
        NSString *sendStatus = d[@"sendStatus"];
        NSString *subject = d[@"subject"];
        
        UIView *chatView = [self bubbleView:d[@"message"]
                                      msgId:messageId
                                msgRandomId:aRandomId
                                       from:YES
                                       type:@"chat"
                                    subject:subject
                                     avatar:avatarImage
                                 sendStatus:sendStatus];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:messageId,@"msgId",aRandomId,@"msgRandomId", message, @"text", MY_USER_NAME, @"speaker",@"chat",@"type", subject,@"subject",sendStatus, @"sendStatus",chatView, @"view", nil];
        [self.chatArray addObject:dict];
        
        //[self performSelector:@selector(markAsFailed:) withObject:dict afterDelay:[Utility getMessageTimeout:subject]];
        
    }
    
    [self.chatTableView reloadData];
    NSInteger count = self.chatArray.count;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
}



//加载首页消息
-(void)loadMessage:(int)start total:(int)total flag:(int)flag
{
    JLLog_I(@"start=%d, total=%d, flag=%d", start, total, flag);
    //NSString * myJID =  [NSString stringWithFormat:@"%@@%@",MY_USER_NAME, OpenFireHostName];
    //接收到数据，用泡泡VIEW显示出来
    //NSLog(@"接收之前消息");
    NSString *userName = MY_USER_NAME;
    //NSString *selectSqlStr=[NSString stringWithFormat:@"select count(id) from ChatMessage where flag=\"%d\" and userName=\"%@\" ",0,userName];
    NSString *selectSqlStr=[NSString stringWithFormat:@"select id,msgRandomId,sendUser,message,readMark,receiveUser,msgType,subject,sendStatus,receiveTime from ChatMessage where ((sendUser=\"%@\" and receiveUser=\"%@\") or (sendUser=\"%@\" and receiveUser=\"%@\")) and myJID=\"%@\" order by receiveTime desc, id desc limit %d,%d",_chatWithUser,userName,userName,_chatWithUser,MY_JID,start,total];
    
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        int i=0;
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            i++;
            NSString * msgId = [rs stringForColumn:@"id"];
            
            NSString * msgRandomId = [StrUtility string:[rs stringForColumn:@"msgRandomId"]];
            
            NSString *senderUser = [rs stringForColumn:@"sendUser"];
            
            NSString *message = [StrUtility string:[rs stringForColumn:@"message"]];
            
            NSString *type= [rs stringForColumn:@"msgType"];
            
            NSString *subjectType = [rs stringForColumn:@"subject"];
            
            NSString *sendStatus = [rs stringForColumn:@"sendStatus"];
            
            
            NSString *sendUTCTime = [rs stringForColumn:@"receiveTime"];
            
            NSDate * sendDate = [Utility getNowDateFromatAnDate:[Utility dateFromUtcString:sendUTCTime]];
            
            //图片，语音为json格式，写入数据库时将双引号转成了单引号，出库时须将单引号转回；
            if ([subjectType isEqualToString:@"image"] || [subjectType isEqualToString:@"voice"]) {
                message =  [message stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
            }
            
            //区分自己和好友
            if ([senderUser isEqualToString:MY_USER_NAME]) {
                [_tempChatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId",msgRandomId,@"msgRandomId", message, @"text", senderUser, @"speaker",type,@"type",subjectType,@"subject",sendStatus,@"sendStatus",sendDate,@"sendDate", nil]];
                
            }else{
                
                [_tempChatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId",msgRandomId,@"msgRandomId", message, @"text", senderUser, @"speaker",type,@"type",subjectType,@"subject",sendStatus,@"sendStatus",sendDate,@"sendDate", nil]];
                
            }
            
        }
        
        [rs close];
        
    }else{
        //error
        // [self ErrorReport: (NSString *)selectSqlStr];
    }
    [db close];
    
    JLLog_I(@"stpe2 db close");
    
    for (int i=_tempChatArray.count-1; i>=0; i--) {
        NSDictionary *item = [_tempChatArray objectAtIndex:i];
        NSString *msgId = [item objectForKey:@"msgId"];
        NSString *msgRandomId = [item objectForKey:@"msgRandomId"];
        NSString *sendUser = [item objectForKey:@"speaker"];
        NSString *message = [item objectForKey:@"text"];
        NSString *type = [item objectForKey:@"type"];
        NSString *subject = [item objectForKey:@"subject"];
        NSDate *sendDate = [item objectForKey:@"sendDate"];
        NSString *sendStatus = [item objectForKey:@"sendStatus"];
        
        if (i==self.tempChatArray.count-1) {
            [self.chatArray addObject:sendDate];
            pageCellHeight+=(21+16)*kScreenScale;;
        }else if(i-1>=0){
            NSString *current = [Utility stringFromDate:sendDate formatStr:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *nextDate = [[self.tempChatArray objectAtIndex:i+1]objectForKey:@"sendDate"];
            NSString *next = [Utility stringFromDate:nextDate formatStr:@"yyyy-MM-dd HH:mm:ss"];
            
            if (![[Utility friendlyTime:current] isEqualToString:[Utility friendlyTime:next]]) {
                [self.chatArray addObject:sendDate];
                pageCellHeight+=(21+16)*kScreenScale;
            }
        }else if(i==0){
            NSString *current = [Utility stringFromDate:sendDate formatStr:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *nextDate = [[self.tempChatArray objectAtIndex:i+1]objectForKey:@"sendDate"];
            NSString *next = [Utility stringFromDate:nextDate formatStr:@"yyyy-MM-dd HH:mm:ss"];
            
            if (![[Utility friendlyTime:current] isEqualToString:[Utility friendlyTime:next]]) {
                [self.chatArray addObject:sendDate];
            }
            _lastTime = sendDate;
        }
        
        //区分自己和好友
        if ([sendUser isEqualToString:MY_USER_NAME]) {
            //用户头像
            //NSString *avatar = [ContactsCRUD queryContactsAvatar:myJID];
            
            UIView *chatView = [self bubbleView:message msgId:msgId msgRandomId:msgRandomId
                                           from:YES type:type subject:subject avatar:myAvatarURL sendStatus:sendStatus];
            
            //纪录新加载数据高度用于分页效果
            pageCellHeight+=chatView.frame.size.height;
            
            [_chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId",msgRandomId,@"msgRandomId", message, @"text", sendUser, @"speaker", chatView, @"view",type,@"type",subject,@"subject",sendStatus,@"sendStatus",sendDate,@"sendDate", nil]];
        }else {
            //用户头像
            NSString *avatarImage = [ContactsCRUD queryContactsAvatar:_chatWithJID];
            // 发送后生成泡泡显示出来
            JLLog_I(@"bubbleView start");
            UIView *chatView = [self bubbleView:message msgId:msgId msgRandomId:msgRandomId from:NO type:type subject:subject avatar:avatarImage sendStatus:sendStatus];
            JLLog_I(@"bubbleView stop");
            //纪录新加载数据高度用于分页效果
            pageCellHeight+=chatView.frame.size.height;
            [_chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId",msgRandomId,@"msgRandomId", message, @"text", sendUser, @"speaker", chatView, @"view",type,@"type",subject,@"subject",sendStatus,@"sendStatus",sendDate,@"sendDate", nil]];
        }
    }
    
    //加载定位
    [_chatTableView reloadData];
    if(_chatArray.count>0){
        [_chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_chatArray count]-_start-1 inSection:0]
                              atScrollPosition: UITableViewScrollPositionBottom
                                      animated:YES];
    }
    [_tempChatArray removeAllObjects];
    [_beforeChatArray removeAllObjects];
    
    JLLog_I(@"<load messages> count=%lu", (unsigned long)_chatArray.count);
}




/*---------提示框-----------------------------------------------------------------*/
- (IBAction)showError:(id)sender {
    [CSNotificationView showInViewController:self
                                       style:CSNotificationViewStyleError
                                     message:@"A critical error happened."];
}
- (IBAction)showSuccess:(id)sender {
    [CSNotificationView showInViewController:self
                                       style:CSNotificationViewStyleSuccess
                                     message:@"Great, it works."];
}

- (void)showCustom {
    //[UIColor colorWithRed:0.000 green:0.6 blue:1 alpha:1]
    //录音时间太短!
    [CSNotificationView showInViewController:self
                                   tintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:0.2]
                                       image:nil
                                     message:NSLocalizedString(@"chatviewPublic.recordingShort",@"message")
                                    duration:2.0f];
}





//图片浏览器
#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser clickedLongPressedActionSheetAtIndex:(NSInteger)buttonIndex {
    MWPhoto *photo = _photos[photoBrowser.currentIndex];
    NSDictionary *d = _previewingImageMessages[photoBrowser.currentIndex];
    switch (buttonIndex) {
//        case 0: {
//            NSMutableDictionary *reitem = [NSMutableDictionary dictionary];
//            [reitem setObject:@"image" forKey:@"subject"];
//            [reitem setObject:d[@"message"] forKey:@"text"];
//            AICurrentContactController *controller = [[AICurrentContactController alloc] init];
//            controller.fromUserName = _chatWithUser;
//            controller.delegate = self;        // Delegate for reloading table view case when dismiss 'controller'
//            controller.messages = @[reitem];
//            AINavigationController *navigation = [[AINavigationController alloc] initWithRootViewController:controller];
//            [self presentViewController:navigation animated:YES completion:nil];
//        }
//            break;
//        
//        case 1: {
//            NSMutableDictionary *md = [NSMutableDictionary dictionaryWithDictionary:d];
//            [md setObject:d[@"message"] forKey:@"text"];
//            [md setObject:d[@"sendUser"] forKey:@"speaker"];
//            [md setObject:d[@"id"] forKey:@"msgId"];
//            _collectedMessage = md;
//            [self sendCollectionIQ:md];
//        }
//            break;
            
        case 0:
            UIImageWriteToSavedPhotosAlbum(photo.underlyingImage, nil, nil, nil);
            break;
            
        default:
            break;
    }
}

#pragma mark - Load Assets

- (void)loadAssets {
    
    // Initialise
    _assets = [NSMutableArray new];
    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // Run in the background as it takes a while to get all assets from the library
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
        NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
        
        // Process assets
        void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result != nil) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                    NSURL *url = result.defaultRepresentation.url;
                    [_assetLibrary assetForURL:url
                                   resultBlock:^(ALAsset *asset) {
                                       if (asset) {
                                           @synchronized(_assets) {
                                               [_assets addObject:asset];
                                               if (_assets.count == 1) {
                                                   // Added first asset so reload data
                                                   [_chatTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                               }
                                           }
                                       }
                                   }
                                  failureBlock:^(NSError *error){
                                      NSLog(@"operation was not successfull!");
                                  }];
                    
                }
            }
        };
        
        // Process groups
        void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                [assetGroups addObject:group];
            }
        };
        
        // Process!
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                         usingBlock:assetGroupEnumerator
                                       failureBlock:^(NSError *error) {
                                           NSLog(@"There is an error");
                                       }];
        
    });
    
}

//跳转到用户详细页
- (void)queryUserInfo:(id)sender{
    ContactInfo *contactInfo = [[ContactInfo alloc] initWithNibName:@"ContactInfo" bundle:nil];
    contactInfo.jid = _chatWithJID;
    contactInfo.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:contactInfo animated:YES];
}

- (void)textViewDidChange:(UITextView *)_textView {
    
    CGSize size = textView.contentSize;
    size.height -= 2;
    
    if ([_textView.text isEqualToString:@""]) {
        size.height = 32;
        
    }
    
    if ( size.height >= 68 ) {
        
        size.height = 68;
    }
    else if ( size.height <= 32 ) {
        
        size.height = 32;
    }
    
    //if ( size.height != textView.frame.size.height ) {
    
    CGFloat span = size.height - textView.frame.size.height;
    
    CGRect frame = containerView.frame;
    frame.origin.y -= span;
    frame.size.height += span;
    containerView.frame = frame;
    
    CGFloat centerY = frame.size.height / 2;
    
    frame = textView.frame;
    frame.size = size;
    textView.frame = frame;
    
    CGPoint center = textView.center;
    center.y = centerY;
    textView.center = center;
    
    //    }
    
    
    CGRect h = underlineView.frame;
    // h.size.height = 1;
    
    h.origin.y = textView.frame.origin.y + size.height;
    underlineView.frame = h;
    
}

- (void)textViewDidChangeCustom:(UITextView *)_textView {
    
    CGRect textFrame=[[textView layoutManager]usedRectForTextContainer:[textView textContainer]];
    
    CGSize size = textView.contentSize;
    size.height = textFrame.size.height;
    size.height -= 2;
    
    if ([_textView.text isEqualToString:@""]) {
        size.height = 32;
        
    }
    
    if ( size.height >= 68 ) {
        
        size.height = 68;
    }
    else if ( size.height <= 32 ) {
        
        size.height = 32;
    }
    
    //if ( size.height != textView.frame.size.height ) {
    
    CGFloat span = size.height - textView.frame.size.height;
    
    CGRect frame = containerView.frame;
    frame.origin.y -= span;
    frame.size.height += span;
    containerView.frame = frame;
    
    CGFloat centerY = frame.size.height / 2;
    
    frame = textView.frame;
    frame.size = size;
    textView.frame = frame;
    
    CGPoint center = textView.center;
    center.y = centerY;
    textView.center = center;
    
    //    }
    
    
    CGRect h = underlineView.frame;
    // h.size.height = 1;
    
    h.origin.y = textView.frame.origin.y + size.height;
    underlineView.frame = h;
    
}



#pragma mark -

- (void)label:(PPLabel *)label didBeginTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:charIndex];
}

- (void)label:(PPLabel *)label didMoveTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:charIndex];
}

- (void)label:(PPLabel *)label didEndTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:NSNotFound];
    UITableViewCell * cell;
    //NSLog(@"*********%li",charIndex);
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=8.0)) {
        cell  = (UITableViewCell *)[[[[[[touch view] superview] superview] superview] superview] superview];
    }else{
        cell  = (UITableViewCell *)[[[[[[[touch view] superview] superview] superview] superview] superview] superview];
    }
    NSIndexPath * path = [_chatTableView indexPathForCell:cell];
    NSLog(@"*********%@",path);
    
    NSDictionary *chatInfo = [self.chatArray objectAtIndex:path.row];
    
    NSString *msg = [chatInfo objectForKey:@"text"];
    
    // NSLog(@"*********%@",msg);
    
    NSError *error;
    
    
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:&error];
    
    self.matches3 = [detector matchesInString:msg options:0 range:NSMakeRange(0, msg.length)];
    
    
    for (NSTextCheckingResult *match in self.matches3) {
        
        if ([match resultType] == NSTextCheckingTypePhoneNumber) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:charIndex inRange:matchRange]) {
                
                _phoneNum  = match.phoneNumber;
                NSLog(@"******%@",_phoneNum);
                [self clickPhoneNumMsg];
                break;
            }
        }
    }
    
    NSDataDetector *detector1 = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    
    self.matches3 = [detector1 matchesInString:msg options:0 range:NSMakeRange(0, msg.length)];
    
    for (NSTextCheckingResult *match in self.matches3) {
        
        if([match resultType] == NSTextCheckingTypeLink){
            
            [[UIApplication sharedApplication] openURL:match.URL];
            
        }
    }
    
    
    
    //    NSTextCheckingResult *match = [self.chatArray objectAtIndex:charIndex];
    //
    //       // NSLog(@"*********%@",path);
    //
    //        if ([match resultType] == NSTextCheckingTypeLink) {
    //
    //            NSRange matchRange = [match range];
    //
    //            if ([self isIndex:charIndex inRange:matchRange]) {
    //
    //                [[UIApplication sharedApplication] openURL:match.URL];
    //
    //            }
    //        }
    //
    
}

- (void)label:(PPLabel *)label didCancelTouch:(UITouch *)touch {
    
    [self highlightLinksWithIndex:NSNotFound];
}

#pragma mark -

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range {
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [_ppLabel.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in self.matches) {
        
        if ([match resultType] == NSTextCheckingTypeLink || [match resultType] == NSTextCheckingTypePhoneNumber) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:index inRange:matchRange]) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
            }
            else {
                [attributedString addAttribute:NSForegroundColorAttributeName value:kMainColor range:matchRange];
            }
            
            // [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
        }
    }
    
    
    
    
    _ppLabel.attributedText = attributedString;
}

- (void)highlightLinksWithIndex2:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [_ppLabel.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in self.matches2) {
        
        if ([match resultType] == NSTextCheckingTypePhoneNumber) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:index inRange:matchRange]) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
            }
            else {
                [attributedString addAttribute:NSForegroundColorAttributeName value:kMainColor range:matchRange];
            }
            
            // [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
        }
    }
    
    _ppLabel.attributedText = attributedString;
}



- (void)savePhoneNum
{
    _picker = [[ABNewPersonViewController alloc] init];
    CFErrorRef error =NULL;
    ABRecordRef personRef=ABPersonCreate();
    ABMutableMultiValueRef multi=ABMultiValueCreateMutable(kABMultiStringPropertyType);
    //电话号码属于具有多个值的项（除此还有email、地址类）
    CFStringRef aCFString = (__bridge_retained CFStringRef) _phoneNum;
    (void)aCFString;
    ABMultiValueAddValueAndLabel(multi, aCFString, kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(personRef, kABPersonPhoneProperty, multi, &error);
    _picker.displayedPerson = personRef;
    _picker.newPersonViewDelegate = self;
    [self.navigationController pushViewController:_picker animated:YES];
    //正确的做法应该执行CFRelease
    CFRelease(multi);
    CFRelease(aCFString);
    CFRelease(personRef);
    
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    
    //    [newPersonView dismissViewControllerAnimated:YES
    //                             completion:^(void){
    //                                 // Code
    //                             }];
    [[self navigationController] popViewControllerAnimated:YES];
    NSLog(@"_________!!!!!!________");
}


-(BOOL)navigationShouldPopOnBackButton ///在这个方法里写返回按钮的事件处理
{
    if(![StrUtility isBlankString:[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"]] ){
        [[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:[NSString stringWithFormat:@"NSUD_Text_%@",_chatWithJID]];
    }
    return YES;
}


// ui 替换********************************************

// ui 替换********************************************

- (void)setup
{
    self.messageDisplayView = [[UITableView alloc]initWithFrame:CGRectMake(0.0f,0.0f,KCurrWidth, self.messageToolView.frame.origin.y) style:UITableViewStylePlain];
    [self.view addSubview:self.messageDisplayView];
    self.messageDisplayView.delegate = self;
    self.messageDisplayView.dataSource = self;
    
}


/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecording{
    NSLog(@"发送语音消息");
    UIImage *activityImage = [UIImage imageNamed:@"input_mic"];
    [DejalBezelActivityView activityViewForRecord:self.view withLabel:@"录音中" withLabel2:@"60"  width:100 image:activityImage];
    
    [self recordStart:nil];
}
- (void)didCancelRecording{
    NSLog(@"取消发送语音消息");
    
    //UIImage *activityImage = [UIImage imageNamed:@"input_mic"];
    [DejalBezelActivityView activityViewForRecordCancel:self.view withLabel:@"录音取消" withLabel2:@"60" width:100 flag:@"cancel"];
    
    [self recordCancel:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [DejalBezelActivityView removeViewAnimated:YES];
    });

    
}
- (void)didFinishRecoing{
    NSLog(@"完成发送语音消息");
    
    [DejalBezelActivityView removeViewAnimated:YES];
    
    [self recordStop:nil];
}

-(void)didDragExitRecoing{
    NSLog(@"滑动取消录音");
    [DejalBezelActivityView activityViewForRecordCancel:self.view withLabel:@"录音取消" withLabel2:@"60" width:100 flag:@"dragExit"];
    
}

-(void)didDragEnterRecoing{
    NSLog(@"继续录音");
    [DejalBezelActivityView activityViewForRecordCancel:self.view withLabel:@"录音中" withLabel2:@"60" width:100 flag:@"dragEnter"];
    
}

//更多每个item 点击事件
-(void)didSelecteShareMenuItem:(NSInteger)index{
    switch (index) {
        case 0:
            [self launchTTImagePicker];
            break;
        case 1:
            [self photoFromCamera];
            break;
        case 2:
            [self playDial];
            break;
        case 3:
            [self sendLocation];
            break;
        case 4:
            [self sendCard];
        default:
            break;
    }
}

#pragma mark - ZBMessageShareMenuViewDelegate
-(void)didShareButton:(BOOL)flag{
    if (flag) {
        [self autoMovekeyBoard:self.shareMenuView.frame.size.height];
    }else{
        //[self autoMovekeyBoard:0];
        
    }
    
}

-(void)didFaceButton:(BOOL)sendFace{
    if(sendFace){
        [self autoMovekeyBoard:self.shareMenuView.frame.size.height];
        
    }else{
        
    }
    
}


//表情发送
-(void)didSendFaceButton{
    [self sendMessage_Click:nil];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return NO;
    
}

-(void)tempMultiPlayTalkViewController:(TempMultiPlayTalkViewController2 *)ControllerView SuccessWithDeleteChatMsg:(NSString *)success{
    [_chatArray removeAllObjects];
    [_chatTableView reloadData];
}


-(void)sendLocationMessage:(NSDictionary *)locationInfo
{
    NSString *msgRandomId = [IdGenerator next];
    
    NSDate *nowTime = [Utility getCurrentDate:@"yyy-MM-dd HH:mm:ss"];
    
    NSString *locationJsonStr = [NSString stringWithFormat:@"{\"cover\":\"%@\",\"latitude\":%lf,\"longitude\":%lf,\"locationName\":\"%@\",\"address\":\"%@\"}",
    locationInfo[@"cover"], [locationInfo[@"latitude"] floatValue], [locationInfo[@"longitude"] floatValue], locationInfo[@"locationName"], locationInfo[@"address"]];
    
    if ([self.chatArray lastObject] == nil) {
        [self.chatArray addObject:nowTime];
    } else {
        NSString *current = [Utility stringFromDate:nowTime formatStr:@"yyyy-MM-dd HH:mm:ss"];
        NSString *next = [Utility stringFromDate:self.lastTime formatStr:@"yyyy-MM-dd HH:mm:ss"];
        
        if (![[Utility friendlyTime:current] isEqualToString:[Utility friendlyTime:next]]) {
            [self.chatArray addObject:nowTime];
        }
    }
    
    self.lastTime = nowTime;
    
    [self.chatTableView reloadData];
    //检测网络情况
    NSString *network = @"connection";
    NSString *sendTimeStr =[Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    NSString *sendUTCTimeStr = [Utility getUTCFormateLocalDate:sendTimeStr];
    
    
    [ChatMessageCRUD insertChatMessage:MY_USER_NAME msg:locationJsonStr receiveUser:_chatWithUser msgType:@"chat" subject:@"location" sendTime:sendUTCTimeStr receiveTime:sendUTCTimeStr readMark:1 sendStatus:network msgRandomId:msgRandomId myJID:MY_JID];

    NSString *msgId = [ChatMessageCRUD queryIdByUserName:MY_USER_NAME chatWithUser:_chatWithUser];
    NSString *avatarImage = [[NSUserDefaults standardUserDefaults] stringForKey:@"headImage"];
    
    UIView *chatView = [self bubbleView:locationJsonStr msgId:msgId msgRandomId:msgRandomId from:YES type:@"chat" subject:@"location" avatar:avatarImage sendStatus:network];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId",msgRandomId,@"msgRandomId", locationJsonStr, @"text", MY_USER_NAME, @"speaker",@"chat",@"type", @"location",@"subject",network, @"sendStatus",chatView, @"view", nil];
    
    [self.chatArray addObject:dict];
    [self.chatTableView reloadData];
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                              atScrollPosition: UITableViewScrollPositionBottom
                                      animated:YES];
    
    
    //查询聊天列表是否存在
    Contacts *contacts = [ChatBuddyCRUD queryBuddyByJID:_chatWithJID myJID:MY_JID];
    UserInfo *userinfo = [UserInfoCRUD queryUserInfo:_chatWithJID myJID:MY_JID];
    NSString *lastMsgTime = [Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    NSString *lastMsg = @"您发送了一个地理位置";
    if(!self.chatBuddyFlag){
        [ChatBuddyCRUD insertChatBuddyTable:_chatWithUser jid:_chatWithJID name:self.remarkName nickName:userinfo.nickName phone:userinfo.phone avatar:userinfo.avatar myUserName:MY_USER_NAME type:@"chat" lastMsg:lastMsg msgType:@"chat" msgSubject:@"location" lastMsgTime:lastMsgTime tag:@""];
        self.chatBuddyFlag = YES;
    }else{
        [ChatBuddyCRUD updateChatBuddy:_chatWithUser name:contacts.remarkName nickName:userinfo.nickName lastMsg:lastMsg msgType:@"chat" msgSubject:@"location" lastMsgTime:sendTimeStr];
    }
    
    [self sendMessageXMLContruct:locationJsonStr
                        randomId:msgRandomId
                         subject:@"location"
                        chatType:@"chat"
                              to:_chatWithJID];
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    self.playNumber--;
    
    if(_playNumber == 0){
        
        if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
            
            if(![UIDevice currentDevice].proximityState){
                [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            }
            
        }

    }
}

//不能删除该方法
-(void)removeRemindBlock:(ZBMessageTextView*)_textView {
}

//不能删除该方法
- (void)callRemindViewController:(ZBMessageTextView*)_textView {
}

- (void) alertViewShowAttention:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==10000) {
        if (buttonIndex==1) {
            [self resendMessage];
        }
    }
    
}

#pragma mark - UISrcrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.chatTableView.frame.size.height < KCurrHeight - 113) {
        [self tapOnce];
    }
}

 @end
