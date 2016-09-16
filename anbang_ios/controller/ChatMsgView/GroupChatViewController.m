

#import "GroupChatViewController.h"

#import "ChatCustomCell.h"
//#import "AppDelegate.h"

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

#import "CHAppDelegate.h"

#import "ChatStatic.h"
#import "KKMessageCell.h"
#import "XMPPStream.h"
#import "XMPPRoom.h"
#import "XMPPRoomCoreDataStorage.h"

#import "VoiceConverter.h"
#import "ChatCacheFileUtil.h"
#import "VoiceBody.h"

#import "ASIFormDataRequest.h"

#import "GLBucket.h"

#import "CSNotificationView.h"

#import "GroupChatMessageCRUD.h"

#import  "GroupCRUD.h"

#define G_TOOLBARTAG		200
#define G_TABLEVIEWTAG	300


#define G_BEGIN_FLAG @"[/"
#define G_END_FLAG @"]"

static NSString *kAnimationNameKey = @"animation_name";
static NSString *kScrapDriveUpAnimationName = @"scrap_drive_up_animation";
static NSString *kScrapDriveDownAnimationName = @"scrap_drive_down_animation";
static NSString *kBucketDriveUpAnimationName = @"bucket_drive_up_animation";
static NSString *kBucketDriveDownAnimationName = @"bucket_drive_down_animation";

static const CGFloat kScrapDriveUpAnimationHeight = 200;
static const CGFloat kScrapYOffsetFromBase = 7;



@interface GroupChatViewController (){
    XMPPRoom *_xmppRoom;
    NSString * _voiceLink;
    
    
}
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) CALayer *scrapLayer;
@property (nonatomic, strong) CALayer *bucketContainerLayer;
@property (nonatomic, strong) GLBucket *bucket;
@property (nonatomic, assign) CFTimeInterval duration;
@property (nonatomic, assign) CGFloat baseviewYOrigin;
@property (nonatomic, assign) CGFloat bucketContainerLayerActualYPos;
- (void)bounceOutAnimationStopped;
- (void)bounceInAnimationStopped;

@end

@implementation GroupChatViewController
@synthesize roomName = _roomName;
@synthesize roomNickName = _roomNickName;
@synthesize myUserName;

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

@synthesize tempSendImage = _tempSendImage;
@synthesize tempSendImageArray = _tempSendImageArray;

NSString *G_UPLOAD_PATH=@"";

#pragma mark - life circle
-(void)loadView{
    [super loadView];
    self.tempSendImageArray = [[NSMutableArray alloc]init];

    //初始化分页
    _pageSize =5;
    _start =0;
    myUserName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
    [self openDataBase];
    _total =[GroupChatMessageCRUD queryGroupChatMessageCount:_roomName];
    
    CGRect bounds = self.view.bounds;
    //bounds.size.height -= 80.f;
    //bounds.origin.y = 44.f;
    _chatTableView = [[PullingRefreshTableView alloc] initWithFrame:bounds pullingDelegate:self];
    _chatTableView.dataSource = self;
    _chatTableView.delegate = self;
    _chatTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    // _chatTableView.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.2 alpha:1];
    [_chatTableView setAllowsSelection:NO];
    
    [self.view addSubview:_chatTableView];
    self.chatTableView.tag = G_TABLEVIEWTAG;
    _chatTableView.headerOnly = YES;
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        NSLog(@"ios7");
        // self.edgesForExtendedLayout=UIRectEdgeNone;
        // self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        
    }
    
    //文字输入
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(-1, self.view.frame.size.height - 49, 322, 49)];
    containerView.layer.borderWidth = 1;
    containerView.layer.borderColor = [[UIColor grayColor] CGColor];
    
	textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(60, 6, 200, 30)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    //textView.backgroundColor = [UIColor blackColor];
    
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
	//textView.returnKeyType = UIReturnKeyGo; //just as an example
	textView.font = [UIFont systemFontOfSize:15.0f];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    //textView.internalTextView.backgroundColor = [UIColor whiteColor];
    //textView.backgroundColor = [UIColor clearColor];
    textView.placeholder = @"请输入文字";
    
    // textView.text = @"test\n\ntest";
	// textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:containerView];
	
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(60, 0, 200, 49);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:44];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = 1.0f;
    textView.layer.cornerRadius =5.0;
    
    // view hierachy
    //[containerView addSubview:imageView];
    
    [containerView addSubview:textView];
    
    //[containerView addSubview:entryImageView];
    
    //切换语音
    UIImage *voiceBtnBackground = [UIImage imageNamed:@"mic_button.png"];
    // UIImage *voiceSelectedBtnBackground = [[UIImage imageNamed:@"ToolViewInputVoiceHL@2x.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    //[voiceBtn setFrame:CGRectMake(8, 0, 20, 45)];
	voiceBtn.frame = CGRectMake(8, 0, 45, 45);
    voiceBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	//[doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    // [doneBtn setBackgroundImage:[UIImage imageNamed:@"TypeSelectorBtn_Black@2x.png"] forState:UIControlStateNormal];
    
    [voiceBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    //doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    // doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    //[doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[voiceBtn addTarget:self action:@selector(voiceOrText) forControlEvents:UIControlEventTouchUpInside];
    [voiceBtn setImage:voiceBtnBackground forState:UIControlStateNormal];
    [voiceBtn setTintColor:[UIColor grayColor]];
    //[voiceBtn setBackgroundImage:voiceBtnBackground forState:UIControlStateNormal];
    // [voiceBtn setBackgroundImage:voiceSelectedBtnBackground forState:UIControlStateSelected];
	[containerView addSubview:voiceBtn];
    
    UIImage *sendBtnBackground = [UIImage imageNamed:@"more_button.png"];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"TypeSelectorBtnHL_Black@2x.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
	doneBtn.frame = CGRectMake(containerView.frame.size.width - 55, 0, 45, 45);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	//[doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    // [doneBtn setBackgroundImage:[UIImage imageNamed:@"TypeSelectorBtn_Black@2x.png"] forState:UIControlStateNormal];
    
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    //doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    // doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    //[doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[doneBtn addTarget:self action:@selector(clickImageView:) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setImage:sendBtnBackground forState:UIControlStateNormal];
    //[doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    // [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
    [doneBtn setTintColor:[UIColor grayColor]];
	[containerView addSubview:doneBtn];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    containerView.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:textView];
    
    /*语音工具toolbar*******************************************************************************************************************/
    //文字输入
    
    voiceView = [[UIView alloc] initWithFrame:CGRectMake(-1, self.view.frame.size.height - 49, 322, 49)];
    voiceView.layer.borderWidth = 1;
    voiceView.layer.borderColor = [[UIColor grayColor] CGColor];
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(60, 6, 200, 35);
    // btn.backgroundColor = [UIColor lightGrayColor];
    
    [btn setTitle:@"按住  说话" forState:UIControlStateNormal];
    [btn setTitle:@"松开  发送" forState:UIControlEventTouchDown];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    //[btn setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //[btn setTitleShadowOffset:CGSizeMake(1, 1)];
    [btn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
    [btn.layer setBorderWidth:1.0]; //边框
    [btn.layer setBorderColor:[[UIColor colorWithRed:0.200 green:0.6 blue:1 alpha:1]CGColor] ];
    
    [btn addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(recordStop:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(recordCancel:) forControlEvents:UIControlEventTouchUpOutside];
    btn.selected = NO;
    _recordBtn = btn;
    _recordBtn.hidden = NO;
    
    [voiceView addSubview:_recordBtn];
    
    
    [self.view addSubview:voiceView];
	
    UIImage *rawEntryBackground2 = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground2 = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView2 = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView2.frame = CGRectMake(60, 0, 200, 49);
    entryImageView2.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground2 = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background2 = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:44];
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:background];
    imageView2.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    imageView2.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    //切换文字
    UIImage *textBtnBackground = [UIImage imageNamed:@"text_button.png"];
    // UIImage *textSelectedBtnBackground = [[UIImage imageNamed:@"ToolViewKeyboardHL@2x.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	UIButton *textBtn = [UIButton buttonWithType:UIButtonTypeSystem];
	textBtn.frame = CGRectMake(8, 0, 45, 45);
    textBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	//[doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    // [doneBtn setBackgroundImage:[UIImage imageNamed:@"TypeSelectorBtn_Black@2x.png"] forState:UIControlStateNormal];
    
    [textBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    //doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    // doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    //[doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[textBtn addTarget:self action:@selector(voiceOrText) forControlEvents:UIControlEventTouchUpInside];
    [textBtn setImage:textBtnBackground forState:UIControlStateNormal];
    //[textBtn setBackgroundImage:textBtnBackground forState:UIControlStateNormal];
    //[textBtn setBackgroundImage:textSelectedBtnBackground forState:UIControlStateSelected];
    [textBtn setTintColor:[UIColor grayColor]];
	[voiceView addSubview:textBtn];
    
    UIImage *voiceSelectorBtnBackground = [[UIImage imageNamed:@"more_button.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    // UIImage *voiceSelectedSendBtnBackground = [[UIImage imageNamed:@"TypeSelectorBtnHL_Black@2x.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	UIButton *voiceSelectorBtn = [UIButton buttonWithType:UIButtonTypeSystem];
	voiceSelectorBtn.frame = CGRectMake(containerView.frame.size.width - 55, 0, 45, 45);
    voiceSelectorBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	//[doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    // [doneBtn setBackgroundImage:[UIImage imageNamed:@"TypeSelectorBtn_Black@2x.png"] forState:UIControlStateNormal];
    
    [voiceSelectorBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    //doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    // doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    //[doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[voiceSelectorBtn addTarget:self action:@selector(clickImageView:) forControlEvents:UIControlEventTouchUpInside];
    //[voiceSelectorBtn setBackgroundImage:voiceSelectorBtnBackground forState:UIControlStateNormal];
    //[voiceSelectorBtn setBackgroundImage:voiceSelectedSendBtnBackground forState:UIControlStateSelected];
	[voiceSelectorBtn setImage:voiceSelectorBtnBackground forState:UIControlStateNormal];
    [voiceSelectorBtn setTintColor:[UIColor grayColor]];
    
    voiceView.backgroundColor = [UIColor whiteColor];
    [voiceView addSubview:voiceSelectorBtn];
    
    
    //删除语音
    // set base view y origin
    CGRect rect = [self CGRectIntegralCenteredInRect:CGRectMake(0, 0, 200, 40) withRect:self.view.frame];
    self.baseviewYOrigin = rect.origin.y + 100;
    
    
    // animation start button
    rect.origin.y = self.baseviewYOrigin;
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = rect;
    [self.button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.button.backgroundColor = [UIColor grayColor];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.button setTitle:@"Move to trash" forState:UIControlStateNormal];
    [self.button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    //[self.view addSubview:self.button];
    
    
    // scrap layer
    UIImage *img = [UIImage imageNamed:@"input_mic.png"];
    rect = [self CGRectIntegralCenteredInRect:CGRectMake(0, 0, img.size.width - 5, img.size.height - 5) withRect:self.view.frame];
    rect.origin.y = self.baseviewYOrigin - CGRectGetHeight(rect) - kScrapYOffsetFromBase;
    
    self.scrapLayer = [CALayer layer];
    self.scrapLayer.frame = rect;
    self.scrapLayer.bounds = rect;
    self.scrapLayer.hidden = YES;
    [self.scrapLayer setContents:(id)img.CGImage];
    [self.view.layer addSublayer:self.scrapLayer];
    
    
    // trash layer
    rect = [self CGRectIntegralCenteredInRect:CGRectMake(0, 0, 50, CGRectGetHeight(self.button.bounds)) withRect:self.view.frame];
    rect.origin.y = self.baseviewYOrigin;
    
    self.bucketContainerLayer = [CALayer layer];
    self.bucketContainerLayer.frame = rect;
    self.bucketContainerLayer.bounds = rect;
    self.bucketContainerLayer.hidden = YES;
    [self.view.layer addSublayer:self.bucketContainerLayer];
    
    
    // bucket layer
    CGRect centeredRect = [self CGRectIntegralCenteredInRect:CGRectMake(0, 0, 22, 20 + 12) withRect:rect]; //image size(20x32)
    centeredRect.origin.x = CGRectGetMinX(rect) + CGRectGetMinX(centeredRect);
    centeredRect.origin.y = CGRectGetMinY(rect);
    
    self.bucket = [[GLBucket alloc] initWithFrame:centeredRect inLayer:self.bucketContainerLayer];
    self.bucket.bucketStyle = BucketStyle2OpenFromRight;
    
    
    // set bucket-container-layer actual y origin
    self.bucketContainerLayerActualYPos = self.baseviewYOrigin - (self.bucket.actualHeight / 2) - kScrapYOffsetFromBase; //    [voiceView.layer addSublayer:self.scrapLayer];
    // [voiceView.layer addSublayer:self.bucketContainerLayer];
    
    voiceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    voiceView.hidden = YES;
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
    [self.view addGestureRecognizer:tap];//添加手势到View中
}

-(void)tapOnce//手势方法
{
    [textView resignFirstResponder];
    
}





// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.duration = 0.6;
    
    // configure zindex of each and every layers/views
    self.button.layer.zPosition = 99;
    self.bucketContainerLayer.zPosition = 98;
    self.scrapLayer.zPosition = 97;
    
    
    
    
    [self tapBackground];
    textView.keyboardType = UIKeyboardTypeDefault;
    
    textView.returnKeyType=UIReturnKeySend;
    
    self.voiceToolbar.hidden=YES;
    
    
    // self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainViewBg.png"]];
    
    self.messages = [NSMutableArray array];
    //    [_messageTextField becomeFirstResponder];
    
    
    //设置信息代理
    //[XMPPServer sharedServer].messageDelegate = self;
    
    //创建一个导航栏
    //    UINavigationBar *navigationBar = nil;
    //    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
    //        navigationBar= [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    //        self.chatTableView.frame = CGRectMake(0, 64, 320, viewHight-64-44);
    //    }else{
    //        navigationBar= [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    //        self.chatTableView.frame = CGRectMake(0, 44, 320, viewHight-64-44);
    //    }
    //
    //    //创建个导航栏集合
    //    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:nil];
    //    //创建一个左边按钮
    //    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"   style:UIBarButtonItemStyleDone       target:self action:@selector(clickLeftButton)];
    //    //设置导航栏内容
    //    [navigationItem setTitle:_chatWithNick];
    //    [navigationItem setLeftBarButtonItem:leftButton];
    //
    //    //把导航栏集合添加入导航栏中，设置动画关闭
    //    [navigationBar pushNavigationItem:navigationItem animated:NO];
    //    //    navigationBar.tintColor = [UIColor underPageBackgroundColor];
    //    //设置navigationbar为半透明状
    //    navigationBar.barStyle = UIBarStyleBlack;
    //    navigationBar.backgroundColor = [UIColor blackColor];
    //
    //
    //    //navigationBar.translucent = YES;
    //    // navigationBar.barStyle = UIBarStyleBlack;
    //    [self.view addSubview:navigationBar];
    //
    //    UIImage *image = [UIImage imageNamed:@"backitem.png"];
    //    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    backBtn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    //    [backBtn setBackgroundImage:image forState:UIControlStateNormal];
    //    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    //    [backBtn addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    //    UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:backBtn ];
    //    self.navigationItem.leftBarButtonItem = backItem;
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
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    NSString *userName = [userDefaults stringForKey:@"userName"];
    NSString *myJID = [NSString stringWithFormat:@"%@@%@",myUserName, OpenFireHostName];
    
    if ([ChatBuddyCRUD queryChatBuddyTableCountId:_roomName myUserName:myUserName]>0){
        
        self.chatBuddyFlag = YES;
    }else{
         self.chatBuddyFlag = NO;
    }
    
    
    
    
    
    //初始化群组
    [self initRoom];
}



//删除
-(IBAction)deleteCellFromTableView{
    int index = self.deleteIndexPath.row;
    //
    //    NSLog(@"*****%d",index);
    //
    //    NSDictionary *item = [self.chatArray objectAtIndex:index];
    //
    //    NSString *msgId = [item objectForKey:@"msgId"];
    //
    //
    //    [self openDataBase];
    //
    //    if (index>0) {
    //        if ([[self.chatArray objectAtIndex:index-1] isKindOfClass:[NSDate class]]) {
    //
    //            [self deleteTable:msgId];
    //            [self.chatArray removeObjectAtIndex:index-1];
    //            [self.chatArray removeObjectAtIndex:index-1];
    //
    //        }else{
    //
    //            [self deleteTable:msgId];
    //            [self.chatArray removeObjectAtIndex:index];
    //        }
    //    }else{
    //        [self deleteTable:msgId];
    //        [self.chatArray removeObjectAtIndex:index];
    //    }
    //    [self.chatTableView reloadData];
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
   	NSString *messageStr = textView.text;
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
	textView.text = @"";
    // self.messageString = self.messageTextField.text;
    self.messageString = nil;
	[textView resignFirstResponder];
    
}
//发送文本消息
-(void)sendMassage:(NSString *)message
{
    NSLog(@"发送消息@%@",message);
	NSDate *nowTime = [NSDate date];
	NSMutableString *sendString=[NSMutableString stringWithCapacity:100];
	[sendString appendString:message];
    
    NSString *timeString=Utility.getCurrentDate;
    
    // NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
    
	//开始发送
    
    //本地输入框中的信息
    if (message.length > 0) {

        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        //生成<subject>文档
        NSXMLElement *mtype = [NSXMLElement elementWithName:@"mtype"  xmlns:@"message:type"];
        [mtype setStringValue:@"chat"];
        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message" xmlns:@"jabber:client"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"groupchat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_roomName];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:myUserName];
        //发送时间
        [mes addAttributeWithName:@"id" stringValue:@"textMessage"];
        //组合
        
        [mes addChild:mtype];
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
        
	}
    //检测网络情况
    NSString *network = [[NSUserDefaults standardUserDefaults] stringForKey:@"Network_Status"];
     NSString *sendTimeStr =[Utility getCurrentTime:@"YY-MM-dd hh:mm"];
    //消息写入数据库
    if ([_messgaeFlag isEqualToString:@"UpdateMessageFlag"]) {
       
        // [GroupChatMessageCRUD insertGroupChatMessage:_roomName sendUser:myUserName msg:message type:@"groupChat" msgType:@"chat" sendTime:sendTimeStr readMark:1 sendStatus:network msgRandomId:@""];
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
    
    //    [self insertTable:userName sencond:message third:_chatWithUser msgType:@"chat" subject:@"text" sendTime:timeString];
    //    [self updateTable:userName];
    
    NSLog(@"#######%@",message);
    
    //  NSString *msgId = [self queryIdByUserName:myUserName chatWithUser:_chatWithUser];
    
    UIView *chatView = [self bubbleView:message from:YES type:@"groupchat" subject:@"text" historyFlag:NO];
    
    NSLog(@"#######%@",chatView);
    
	[self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"msgId", message, @"text", @"self", @"speaker",@"text",@"type", chatView, @"view", nil]];
    
    NSLog(@"*****%d",self.chatArray.count);
    
	[self.chatTableView reloadData];
	[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
							  atScrollPosition: UITableViewScrollPositionBottom
									  animated:YES];
    
    // NSLog(@"播放提示音%@",msgId);
    AudioServicesPlaySystemSound(1105);
    
    //查询聊天列表是否存在
    if(self.chatBuddyFlag == NO){
        NSString * myJID =  [NSString stringWithFormat:@"%@@%@",myUserName, OpenFireHostName];
        ChatGroup *chatGroup = [[ChatGroup alloc]init];
        chatGroup = [GroupCRUD queryChatGroupByJID:_roomName myJID:myJID];
        
        [ChatBuddyCRUD insertChatBuddyTable:_roomName name:@"" nickName:_roomNickName phone:@"" avatar:@"" myUserName:myUserName type:@"groupchat"lastMsg:message msgType:@"groupchat" msgSubject:@"chat" lastMsgTime:sendTimeStr];
        self.chatBuddyFlag = YES;
    }
    
    
    
    //更新消息状态
    [GroupChatMessageCRUD updateGroupChatMessage:_roomName];
}

//选择系统表情
-(IBAction)showPhraseInfo:(id)sender
{
    //    self.messageString =[NSMutableString stringWithFormat:@"%@",self.messageTextField.text];
    //	[self.messageTextField resignFirstResponder];
    //	if (self.phraseViewController == nil) {
    //		FaceViewController *temp = [[FaceViewController alloc] initWithNibName:@"FaceViewController" bundle:nil];
    //		self.phraseViewController = temp;
    //		//[temp release];
    //	}
    //	[self presentModalViewController:self.phraseViewController animated:YES];
}


- (IBAction)clickAddBtn:(id)sender {
    _shareMoreView.hidden = NO;
    [textView setInputView: textView.inputView?nil: _shareMoreView];
    [textView becomeFirstResponder];
    [textView reloadInputViews];
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
    
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"bubble-flat-outgoing-selected":@"bubble-flat-incoming" ofType:@"png"]];
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:20 topCapHeight:14]];
    
    UIImageView *headImageView = [[UIImageView alloc] init];
    
    if(fromSelf){
        if (self.myPhoto == NULL) {
            //            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //            NSString *userName = [defaults stringForKey:@"userName"];
            NSLog(@"userId%@",myUserName);
            XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@"OpenFireHostName,myUserName]];
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
        
        returnView.frame= CGRectMake(9.0f, 15.0f, returnView.frame.size.width, returnView.frame.size.height);
        
        //发送语音时
        if([subject isEqualToString:@"voice"]){
            // UIImage *voiceImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"voice" ofType:@"png"]];
            // UIImageView *voiceImageView = [[UIImageView alloc] initWithImage:[voiceImage stretchableImageWithLeftCapWidth:20 topCapHeight:14]];
            //  voiceImageView.frame = CGRectMake(0.0f, 14.0f, 24.0f, 24.0f);
            UILabel * voiceLabel = [[UILabel alloc]init];
            //  voiceLabel.frame = CGRectMake(5.0f, -3.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height);
            voiceLabel.frame = CGRectMake(5.0f, 3.0f, 20, 25);
            voiceLabel.text =@"(((";
            voiceLabel.backgroundColor = [UIColor clearColor];
            
            bubbleImageView.frame = CGRectMake(0.0f, 14.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height);
            [bubbleImageView addSubview:voiceLabel];
            
        }else if([subject isEqualToString:@"image"]){
            
            //bubbleImageView.frame = CGRectMake(0.0f, 0.0f, returnView.frame.size.width+20, returnView.frame.size.height );
            bubbleImageView.image =nil;
            returnView.frame= CGRectMake(-60.0f, -10.0f, returnView.frame.size.width, returnView.frame.size.height);
        }else{
            
            bubbleImageView.frame = CGRectMake(0.0f, 14.0f, returnView.frame.size.width+25.0f, returnView.frame.size.height+40.0f );
            
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
        
        returnView.frame= CGRectMake(65.0f, 15.0f, returnView.frame.size.width, returnView.frame.size.height);
        //发送语音时
        if([subject isEqualToString:@"voice"]){
            UILabel * voiceLabel = [[UILabel alloc]init];
            voiceLabel.frame = CGRectMake(returnView.frame.size.width+2,3.0f, 20, 25);
            voiceLabel.text =@")))";
            
            bubbleImageView.frame = CGRectMake(50.0f, 14.0f,  returnView.frame.size.width+24.0f, returnView.frame.size.height);
            [bubbleImageView addSubview:voiceLabel];
            
        }else if([subject isEqualToString:@"image"]){
            
            //bubbleImageView.frame = CGRectMake(0.0f, 0.0f, returnView.frame.size.width+20, returnView.frame.size.height );
            bubbleImageView.image =nil;
            returnView.frame= CGRectMake(55.0f, -10.0f, returnView.frame.size.width, returnView.frame.size.height);
            
        }else{
            
            bubbleImageView.frame = CGRectMake(50.0f, 14.0f, returnView.frame.size.width+25.0f, returnView.frame.size.height+40.0f);
            
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
		return chatView.frame.size.height+20;
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
        
        NSLog(@"*****%d",[indexPath row]);
        
        NSLog(@"*****%@",chatInfo);
        
        NSLog(@"*****%d",self.chatArray.count);
        
		UIView *chatView = [chatInfo objectForKey:@"view"];
        
        NSLog(@"%@",chatView);
        
        
		[cell.contentView addSubview:chatView];
	}
    return cell;
}


#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self.messageTextField resignFirstResponder];
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
        //        UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:G_TOOLBARTAG];
        //        toolbar.frame = CGRectMake(0.0f, (float)(viewHight-h-44.0), 320.0f, 44.0f);
        UITableView *tableView = (UITableView *)[self.view viewWithTag:G_TABLEVIEWTAG];
        tableView.frame = CGRectMake(0.0f, 64.0f, 320.0f,(float)(viewHight-h-64-44.0));
        
        if (self.chatArray.count>0) {
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                             atScrollPosition: UITableViewScrollPositionBottom
                                     animated:NO];
        }
        
    }else{
        //        UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:G_TOOLBARTAG];
        //    	toolbar.frame = CGRectMake(0.0f, (float)(viewHight-h-64.0), 320.0f, 44.0f);
    	UITableView *tableView = (UITableView *)[self.view viewWithTag:G_TABLEVIEWTAG];
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
//- (void)keyboardWillShow:(NSNotification *)notification {
//
//    /*
//     Reduce the size of the text view so that it's not obscured by the keyboard.
//     Animate the resize so that it's in sync with the appearance of the keyboard.
//     */
//
//    NSDictionary *userInfo = [notification userInfo];
//
//    // Get the origin of the keyboard when it's displayed.
//    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//
//    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
//    CGRect keyboardRect = [aValue CGRectValue];
//
//    // Get the duration of the animation.
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//
//    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
//    [self autoMovekeyBoard:keyboardRect.size.height];
//}
//
//
//- (void)keyboardWillHide:(NSNotification *)notification {
//
//    NSDictionary* userInfo = [notification userInfo];
//
//    /*
//     Restore the size of the text view (fill self's view).
//     Animate the resize so that it's in sync with the disappearance of the keyboard.
//     */
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//    [self autoMovekeyBoard:0];
//}





//图文混排

-(void)getImageRange:(NSString*)message : (NSMutableArray*)array {
    NSRange range=[message rangeOfString: G_BEGIN_FLAG];
    NSRange range1=[message rangeOfString: G_END_FLAG];
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
    
    message =[message stringByReplacingOccurrencesOfString:@"<br>" withString:@" "];

    [self getImageRange:message :array];
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    NSArray *data = array;
    UIFont *fon = [UIFont systemFontOfSize:15.0f];
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat X = 0;
    CGFloat Y = 0;
    if (data) {
        for (int i=0;i < [data count];i++) {
            NSString *s=[data objectAtIndex:i];
            
            //  NSLog(@"str--->%@",str);
            
            if ([s hasPrefix: G_BEGIN_FLAG] && [s hasSuffix: G_END_FLAG])
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
                    NSLog(@"---------------%@",subject);
                    
                    if ([type isEqualToString:@"groupchat"]) {
                        
                        if ([subject isEqualToString:@"image"]) {
                            
                            //                            if (historyFlag) {
                            //                                UIImageView *imgv = [[UIImageView alloc]initWithFrame:CGRectMake(upX,upY+10,100,100)];
                            //                                UIImage *img = [Photo string2Image:message];
                            //                                imgv.image = img;
                            //
                            //                                [returnView addSubview:imgv];
                            //                                //   [imgv release];
                            //                            }else{
                            
                            NSLog(@"**********%@",s);
                            
                            NSString *imageJsonStr  =[s stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
                            //imageJsonStr = [imageJsonStr stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];
                            NSLog(@"imageJsonStr:%@",imageJsonStr);
                            NSDictionary *imageData = [imageJsonStr objectFromJSONString];
                            NSLog(@"imageJsonStr.link:%@",[imageData objectForKey:@"link"]);
                            NSLog(@"imageJsonStr.data:%@",[imageData objectForKey:@"data"]);
                            
                            //  [imageJsonStr release];
                            
                            UIImage *img = [Photo string2Image:[imageData objectForKey:@"data"]];
                            UIImageView *imgv = [[UIImageView alloc]initWithFrame:CGRectMake(upX,upY+10,100,80)];
                            
                            imgv.image = img;
                            
                            [returnView addSubview:imgv];
                            //  [imgv release];
                            
                            //                            }
                            
                            X = 100;
                            Y = 100;
                            break;
                            
                        }else if ([subject isEqualToString:@"voice"]){
                            
                            //  NSData *voiceData = [s base64DecodedData];
                            
                            NSLog(@"**********%@",s);
                            
                            NSString *vocieJsonStr = [s stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
                            NSLog(@"imageJsonStr:%@",vocieJsonStr);
                            NSDictionary *voiceData = [vocieJsonStr objectFromJSONString];
                            NSLog(@"imageJsonStr.link:%@",[voiceData objectForKey:@"link"]);
                            NSLog(@"imageJsonStr.data:%@",[voiceData objectForKey:@"time"]);
                            
                            int voiceTime = [[voiceData objectForKey:@"time"] intValue];
                            
                            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn.tag = self.chatArray.count;
                            
                            NSLog(@"voice length:%d",btn.tag);
                            
                            Y =KFacialSizeHeight+15;
                            X = 45;
                            X+= voiceTime*3;
                            btn.frame = CGRectMake(0,0,X,Y+25);
                            
                            [btn  addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
                            //[btn  addTarget:self action:@selector(showPopupMenu2:) forControlEvents:UIControlEventTouchUpInside];
                            btn.backgroundColor = [UIColor clearColor];
                            
                            //[self.msgButArray addObject:btn];
                            //btn.hidden = YES;
                            [returnView addSubview:btn];
                            break;
                            
                        }else{
                            
                            UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY+5,size.width,size.height)];
                            la.font = fon;
                            if(fromself)
                            la.textColor = [UIColor whiteColor];
                            temp =[temp stringByReplacingOccurrencesOfString:@"<br>" withString:@"/n"];
                            la.lineBreakMode = UILineBreakModeWordWrap;
                            // la.numberOfLines = 0 ;
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
                        if(fromself)
                        la.textColor = [UIColor whiteColor];
                        temp =[temp stringByReplacingOccurrencesOfString:@"<br>" withString:@"/n"];
                        la.text = temp;
                        la.backgroundColor = [UIColor clearColor];
                        la.numberOfLines = 0 ;
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


//接收之前消息
-(void)receiveBeforeMessage:(int)start total:(int)total{
    //接收到数据，用泡泡VIEW显示出来
    NSLog(@"接收之前消息");
    NSString *selectSqlStr=[NSString stringWithFormat:@"select id,room, sendUser,message,readMark,type,msgType,sendTime from GroupChatMessage where room=\"%@\" order by id desc limit \"%d\",\"%d\"",self.roomName,start,total];
    const char *selectSql = [selectSqlStr UTF8String];
    NSLog(@"********%@",selectSqlStr);
    
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
            
            NSString *room=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            
            NSString *sendUser=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            
            NSString *message=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            
            //   int _readMark=sqlite3_column_int(statement, 4);
            
            NSString *type=[[NSString alloc] initWithCString:(char *) sqlite3_column_text(statement, 5)
                                                    encoding:NSUTF8StringEncoding];
            
            NSString *msgType=[[NSString alloc] initWithCString:(char *) sqlite3_column_text(statement, 6)
                                                       encoding:NSUTF8StringEncoding];
            
            NSString *sendTime=[[NSString alloc] initWithCString:(char *) sqlite3_column_text(statement, 7)
                                                        encoding:NSUTF8StringEncoding];
            
            NSLog(@"row>>id %i, room>>%@,sendUser>>%@,message>>%@,type>>%@,msgType>>%@,sendtime>>%@",_id,room,sendUser,message,type,msgType,sendTime);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            
            [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm"];
            
            NSDate *sendDate= [dateFormatter dateFromString:sendTime];
            
            // [dateFormatter release];
            
            //图片，语音为json格式，写入数据库时将双引号转成了单引号，出库时须将单引号转回；
            if ([msgType isEqualToString:@"image"] || [msgType isEqualToString:@"voice"]) {
                message =  [message stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
            }
            
            //区分自己和好友
            NSLog(@"----------sendUser:%@,myUserName:%@",sendUser,myUserName);
            if ([sendUser isEqualToString:myUserName]) {
                
                [self.tempChatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", message, @"text", sendUser, @"speaker",type,@"type",msgType,@"msgType", sendDate,@"sendDate", nil]];
                
            }else{
                
                [self.tempChatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", message, @"text", sendUser, @"speaker",type,@"type",msgType,@"msgType",sendDate,@"sendDate",  nil]];
            }
            
        }
        
        NSLog(@"********%d",self.tempChatArray.count);
        NSLog(@"********%d",self.beforeChatArray.count);
        
        for (int i=self.tempChatArray.count-1; i>=0; i--) {
            NSDictionary *item = [self.tempChatArray objectAtIndex:i];
            NSString *msgId = [item objectForKey:@"msgId"];
            NSString *sendUser = [item objectForKey:@"speaker"];
            NSString *message = [item objectForKey:@"text"];
            NSString *type = [item objectForKey:@"type"];
            NSString *msgType = [item objectForKey:@"msgType"];
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
            
            //区分自己和好友
            if ([sendUser isEqualToString:myUserName]) {
                UIView *chatView = [self bubbleView:message
                                               from:YES type:type subject:msgType historyFlag:YES];
                [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", message, @"text", sendUser, @"speaker", chatView, @"view",type,@"type",msgType,@"msgType", nil]];
            }else {
                // 发送后生成泡泡显示出来
                UIView *chatView = [self bubbleView:message from:NO type:type subject:msgType historyFlag:YES];
                [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", message, @"text", sendUser, @"speaker", chatView, @"view",type,@"type",msgType,@"msgType", nil]];
                
            }
        }
        
        for (int i=0; i<self.beforeChatArray.count;i++) {
            if ([[self.beforeChatArray objectAtIndex:i] isKindOfClass:[NSDate class]]) {
                [self.chatArray addObject:[self.beforeChatArray objectAtIndex:i] ];
            }else{
                NSDictionary *item = [self.beforeChatArray objectAtIndex:i];
                NSString *msgId = [item objectForKey:@"msgId"];
                NSString *sendUser = [item objectForKey:@"speaker"];
                NSString *message = [item objectForKey:@"text"];
                NSString *type = [item objectForKey:@"type"];
                NSString *msgType = [item objectForKey:@"msgType"];
                //NSDate *sendDate = [item objectForKey:@"sendDate"];
                
                NSLog(@"#######%@",type);
                
                //区分自己和好友
                if ([sendUser isEqualToString:myUserName]) {
                    
                    UIView *chatView = [self bubbleView:message
                                                   from:YES type:type subject:msgType historyFlag:YES];
                    [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", message, @"text", sendUser, @"speaker", chatView, @"view",type,@"type",msgType,@"msgType", nil]];
                }else {
                    // 发送后生成泡泡显示出来
                    UIView *chatView = [self bubbleView:message from:NO type:type subject:msgType historyFlag:YES];
                    [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId", message, @"text", sendUser, @"speaker", chatView, @"view",type,@"type",msgType,@"msgType", nil]];
                    
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
        // [self ErrorReport: (NSString *)selectSqlStr];
    }
    sqlite3_finalize(statement);
    
    //更新消息状态
    [GroupChatMessageCRUD updateGroupChatMessage:_roomName];
    return;
}


-(void) clickLeftButton {
    [self dismissViewControllerAnimated:NO completion:nil];
    _messgaeFlag=@"NoUpdateMessageFlag";
}


- (void)clickImageView:(UIButton *) btn
{
    UIActionSheet *menu=[[UIActionSheet alloc] initWithTitle:@"天空为什么那么蓝" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"选择拍照",@"选择图片" ,nil];
    menu.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
    [menu showInView:self.view.window];
    
}

#pragma mark -
#pragma mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"click at index %d，确定操作", buttonIndex);
            break;
        case 1:
            NSLog(@"click at index %d，其他操作", buttonIndex);
            [self pickPhoto];
            break;
        case 2:
            NSLog(@"click at index %d，取消操作", buttonIndex);
            break;
        default:
            NSLog(@"unknown： click at index %d", buttonIndex);
            break;
    }
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
    UIImage* chosedImage=[info objectForKey:@"UIImagePickerControllerEditedImage"];
    
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
    
    NSArray *nameAry=[G_UPLOAD_PATH componentsSeparatedByString:@"/"];
    NSLog(@"===new fullPathToFile===%@",fullPathToFile);
    NSLog(@"===new FileName===%@",[nameAry objectAtIndex:[nameAry count]-1]);
    
    [imageData writeToFile:fullPathToFile atomically:NO];
    
}


-(void)sendImage:(UIImage *)aImage {
    NSString * myJID =  [NSString stringWithFormat:@"%@@%@",myUserName, OpenFireHostName];
    NSLog(@"准备发送图片%@",aImage);
    NSString *message = [Photo image2String:aImage];
    
    if (message.length==0) {
        return;
    }
    // NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
    NSDate *nowTime = [NSDate date];
    NSString *timeString = Utility.getCurrentDate;
    NSString *bodyJsonStr =  [NSString stringWithFormat:@"%@%@%@",@"{\"data\":\"", message,@"\",\"src\":\"\",\"link\":\"no url\"}"];
    
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
    //检测网络情况
    NSString *network = [[NSUserDefaults standardUserDefaults] stringForKey:@"Network_Status"];

    NSString *sendTimeStr =[Utility getCurrentTime:@"YY-MM-dd hh:mm"];
    //消息写入数据库
    if (![message isEqualToString:@""]){
        //  NSString *imageBodyJsonStr =  [[NSString stringWithFormat:@"%@%@%@",@"{\"data\":\"", info,@"\",\"src\":\"\",\"link\":\"no url\"}"] autorelease];
        NSString *imageJsonStr = [bodyJsonStr stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
             //  [GroupChatMessageCRUD insertGroupChatMessage:_roomName sendUser:myUserName msg:imageJsonStr type:@"groupchat" msgType:@"image" sendTime:sendTimeStr readMark:1 sendStatus:network msgRandomId:@""];
        
    }
    
    //    [self insertTable:myUserName sencond:message third:_chatWithUser msgType:@"chat" subject:@"image" sendTime:timeString];
    //    [self updateTable:myUserName];
    // NSString *msgId = [self queryIdByUserName:myUserName chatWithUser:_chatWithUser];
    
    UIView *chatView = [self bubbleView:bodyJsonStr	from:YES type:@"groupchat" subject:@"image" historyFlag:NO];
    
	[self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"msgId", bodyJsonStr, @"text", @"self", @"speaker",@"image",@"type", chatView, @"view", nil]];
    
    [self.chatTableView reloadData];
    
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
							  atScrollPosition: UITableViewScrollPositionBottom
                                      animated:YES];
    
    NSLog(@"播放提示音");
    AudioServicesPlaySystemSound(1105);
    
    //查询聊天列表是否存在
     NSString *lastMsg = @"［图片］";
    if(self.chatBuddyFlag == NO){
        
        ChatGroup *chatGroup = [[ChatGroup alloc]init];
        chatGroup = [GroupCRUD queryChatGroupByJID:_roomName myJID:myJID];
        
        [ChatBuddyCRUD insertChatBuddyTable:_roomName name:@"" nickName:_roomNickName phone:@"" avatar:@"" myUserName:myUserName type:@"groupchat"lastMsg:lastMsg msgType:@"groupchat" msgSubject:@"image" lastMsgTime:sendTimeStr];
        self.chatBuddyFlag = YES;
    }else{
        [ChatBuddyCRUD updateChatBuddy:_roomName name:@"" nickName:_roomNickName lastMsg:lastMsg msgType:@"groupchat" msgSubject:@"image" lastMsgTime:sendTimeStr];
        
    }
    //上传图片
    [self upLoadImageData:aImage];
    
    // [[WCXMPPManager sharedInstance]sendFile:nil toJID:[XMPPJID jidWithUser:[NSString stringWithFormat:@"%@",_chatPerson.userId] domain:@"hcios.com" resource:@"ios"]]; //重新刷新tableView
}


-(void)sendImageLink:(int)imageTag link:(NSString *)imageLink{
    
    NSLog(@"*******%d",self.tempSendImageArray.count);
    
    UIImage * aImage = [self.tempSendImageArray objectAtIndex:imageTag-1];
    NSString *message = [Photo image2String:aImage];
    
    if (message.length==0) {
        return;
    }
    // NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
    NSDate *nowTime = [NSDate date];
    NSString *timeString = Utility.getCurrentDate;
    NSString *bodyJsonStr =  [NSString stringWithFormat:@"%@%@%@%@%@",@"{\"data\":\"", message,@"\",\"src\":\"\",\"link\":\"",imageLink,@"\"}"];
    
    if (message.length > 0) {
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:bodyJsonStr];
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型：群聊
        [mes addAttributeWithName:@"type" stringValue:@"groupchat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_roomName];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:myUserName];
        
        NSXMLElement *mtype = [NSXMLElement elementWithName:@"mtype"];
        [mtype addAttributeWithName:@"xmlns" stringValue:@"message:type"];
        [mtype setStringValue:@"image"];
        
        //组合
        [mes addChild:body];
        [mes addChild:mtype];
        
        NSLog(@"%@",mes);
        //发送消息
        [[XMPPServer xmppStream] sendElement:mes];
        
        //重新刷新tableView
        [self.chatTableView reloadData];
        
        //更新消息状态
        [GroupChatMessageCRUD updateGroupChatMessage:_roomName];
    }
}


//--------------语音功能－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
#pragma mark - 录制语音
- (IBAction)recordStart:(UIButton *)sender {
    
    
    UIButton *button = (UIButton *)sender;
    button.enabled = NO;
    [NSTimer scheduledTimerWithTimeInterval:2
                                     target:self
                                   selector:@selector(updateVoiceBtn:)
                                   userInfo:button
                                    repeats:NO];
    
    button.backgroundColor = [UIColor colorWithRed:0.200 green:0.6 blue:1 alpha:1];
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
    NSString *fileName = [NSString stringWithFormat:@"rec_%@_%@.wav",myUserName,[dateFormater stringFromDate:now]];
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
    
    [[ChatCacheFileUtil sharedInstance] deleteWithContentPath:pathURL.path];
    [[ChatCacheFileUtil sharedInstance] deleteWithContentPath:amrPath];
    _lastRecordFile = [[amrPath lastPathComponent] copy];
    
    NSLog(@"音频文件路径:%@\n%@",pathURL.path,amrPath);
    //    if (_timeLen<1) {
    //        [g_App showAlert:@"录的时间过短"];
    //        return;
    //    }
    [self upLoadVoiceData:recordData];
    // [audioRecorder release];
    recording = NO;
    
}


-(void) updateVoiceBtn:(NSTimer *)timer
{
    //your other code...
    UIButton *button = (UIButton *)[timer userInfo];
    [button setTitle:@"按住  说话" forState:UIControlStateNormal];
    [button setEnabled:YES];
    button.layer.borderColor=[[UIColor colorWithRed:0.200 green:0.6 blue:1 alpha:1] CGColor];
    //your other code
}


- (IBAction)recordCancel:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    [button setTitle:@"已取消" forState:UIControlStateNormal];
    button.layer.borderColor = [[UIColor grayColor]CGColor];
    button.backgroundColor = [UIColor whiteColor];
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

-(void)sendVoice:(NSString *)link {
    NSString * myJID =  [NSString stringWithFormat:@"%@@%@",myUserName, OpenFireHostName];
    //上传声音文件
    int voiceTime = [[Utility decimalwithFormat:@"0" floatV:_timeLen]intValue];
    //生成消息对象
    VoiceBody *body=[[VoiceBody alloc]init];
    body.path = @"";
    body.time = [NSNumber numberWithInt:voiceTime];
    body.src = @"";
    body.link =link;
    NSDictionary *dic = [body toDictionary];
    NSString * bodyJsonStr = [dic JSONString];
    NSString *timeString=Utility.getCurrentDate;
    
	//开始发送
    if (link.length > 0) {
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:bodyJsonStr];
        //生成<subject>文档
        NSXMLElement *mtype = [NSXMLElement elementWithName:@"mtype"  xmlns:@"message:type"];
        [mtype setStringValue:@"voice"];
        
        NSXMLElement *delay = [NSXMLElement elementWithName:@"delay" xmlns:@"im.icircall.com" ];
        [delay addAttributeWithName:@"from" stringValue:@"im.icircall.com"];
        [delay addAttributeWithName:@"stamp" stringValue:timeString];
        
        NSXMLElement *req = [NSXMLElement elementWithName:@"req" xmlns:@"urn:xmpp:receipts" ];
        [req addAttributeWithName:@"id" stringValue:@"33"];
        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message" xmlns:@"jabber:client"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"groupchat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_roomName];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:myUserName];
        //发送时间
        [mes addAttributeWithName:@"id" stringValue:@"voiceMessage"];
        //组合
        [mes addChild:req];
        [mes addChild:delay];
        [mes addChild:mtype];
        [mes addChild:body];
        
        NSLog(@"%@",mes);
        //发送消息
        [[XMPPServer xmppStream] sendElement:mes];
        
    }
    //检测网络情况
    NSString *network = [[NSUserDefaults standardUserDefaults] stringForKey:@"Network_Status"];
     NSString *sendTimeStr =[Utility getCurrentTime:@"YY-MM-dd hh:mm"];
    //消息写入数据库
    if (![bodyJsonStr isEqualToString:@""]){
        //  NSString *imageBodyJsonStr =  [[NSString stringWithFormat:@"%@%@%@",@"{\"data\":\"", info,@"\",\"src\":\"\",\"link\":\"no url\"}"] autorelease];
        
        NSString *voiceJsonStr = [bodyJsonStr stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
       
       // [GroupChatMessageCRUD insertGroupChatMessage:_roomName sendUser:myUserName msg:voiceJsonStr type:@"groupchat" msgType:@"voice" sendTime:sendTimeStr readMark:1 sendStatus:network msgRandomId: @""];
    }
    
    // [body release];
    
    NSDate *nowTime = [NSDate date];
    
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
    
    //  [self insertTable:userName sencond:message third:_chatWithUser  msgType:@"chat" subject:@"voice" sendTime:timeString];
    //  [self updateTable:userName];
    // NSString *msgId = [self queryIdByUserName:userName chatWithUser:_chatWithUser];
    UIView *chatView = [self bubbleView:bodyJsonStr from:YES type:@"groupchat" subject:@"voice" historyFlag:NO];
	[self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"11",@"msgId", bodyJsonStr, @"text", @"self", @"speaker",@"voice",@"type", chatView, @"view", nil]];
    
	
	[self.chatTableView reloadData];
	[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
							  atScrollPosition: UITableViewScrollPositionBottom
									  animated:YES];
    
    NSLog(@"播放提示音");
    AudioServicesPlaySystemSound(1105);
    
    //查询聊天列表是否存在
    NSString *lastMsg = @"［语音］";
    if(self.chatBuddyFlag == NO){
        
        ChatGroup *chatGroup = [[ChatGroup alloc]init];
        chatGroup = [GroupCRUD queryChatGroupByJID:_roomName myJID:myJID];
        
        [ChatBuddyCRUD insertChatBuddyTable:_roomName name:@"" nickName:_roomNickName phone:@"" avatar:@"" myUserName:myUserName type:@"groupchat"lastMsg:lastMsg msgType:@"groupchat" msgSubject:@"voice" lastMsgTime:sendTimeStr];
        self.chatBuddyFlag = YES;
    }else{
        [ChatBuddyCRUD updateChatBuddy:_roomName name:@"" nickName:_roomNickName  lastMsg:lastMsg msgType:@"groupchat" msgSubject:@"voice" lastMsgTime:sendTimeStr];
        
    }
    
    //更新消息状态
    [GroupChatMessageCRUD updateGroupChatMessage:_roomName];
}

-(void) upLoadVoiceData:(NSData *)data
{
    NSString *urlstr = ResourcesURL;
	NSURL *myurl = [NSURL URLWithString:urlstr];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:myurl];
	//设置表单提交项
    [request setPostBody:data];
	[request setDelegate:self];
    [request buildRequestHeaders];
    [request setDidFinishSelector:@selector(GetVoiceResult:)];
	[request setDidFailSelector:@selector(GetErr:)];
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
    //判断是否登陆成功
    [self sendVoice:voiceLink];
   	
}

int imageCount=0;
-(void) upLoadImageData:(UIImage *)image
{
    imageCount++;
    //self.tempSendImage = image;
    [self.tempSendImageArray addObject:image];
    NSLog(@"%d",self.tempSendImageArray.count);
    NSData *imageData = UIImagePNGRepresentation(image);
    NSLog(@"*****%@",imageData);
    
    NSString *urlstr = ResourcesURL;
	NSURL *myurl = [NSURL URLWithString:urlstr];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:myurl];
	//设置表单提交项
    [request setPostBody:imageData];
	//[request setPostValue:data forKey:@""];
    //[request setFile: amrPath forKey: @"this_is_file"];
	//[request setPostValue:username.text forKey:@"password"];
	[request setDelegate:self];
    [request buildRequestHeaders];
    [request setDidFinishSelector:@selector(GetImageResult:)];
	[request setDidFailSelector:@selector(GetErr:)];
    request.tag=imageCount;
	[request startAsynchronous];
}


//获取请求结果
- (void)GetImageResult:(ASIHTTPRequest *)request {
    NSData *jsonData =[request responseData];
    //输出接收到的字符串
    NSDictionary *d = [jsonData objectFromJSONData];
    voiceLink = [d objectForKey:@"TFS_FILE_NAME"];
    // NSString *str = [NSString stringWithUTF8String:[jsonData bytes]];
    NSLog(@"%@",voiceLink);
    //判断是否登陆成功
    [self sendImageLink:request.tag link:voiceLink];
}


//连接错误调用这个函数
- (void) GetErr:(ASIHTTPRequest *)request{
    NSLog(@"error%@",request);
}


- (void) playVoice:(UIButton *)btn{
    
    NSInteger index = btn.tag;
    NSDictionary *item = [self.chatArray objectAtIndex:index];
    
    NSString * voiceMessageJson= [item objectForKey:@"text"];
    
    NSLog(@"******%@",voiceMessageJson);
    
    NSDictionary *voiceDic = [voiceMessageJson objectFromJSONString];
    NSLog(@"voice.link:%@",[voiceDic objectForKey:@"link"]);
    NSLog(@"voice.time:%@",[voiceDic objectForKey:@"time"]);
    
    //voiceLink = @"T1iyETBydT1RCvBVdK";
    //  voiceLink=@"T1YRJTByxT1RCvBVdK";
    NSString *urlstr = ResourcesURL;
    voiceLink =[voiceDic objectForKey:@"link"];
	NSURL *voiceUrl = [NSURL URLWithString:urlstr];
    NSLog(@"%@",voiceLink);
    
    NSString *filePath = [self DownloadTextFile:urlstr fileName:voiceLink];
    NSLog(@"%@",filePath);
    
    NSString *amrPath = [VoiceConverter amrToWav:filePath];
    NSLog(@"*******%@",amrPath);
    NSMutableData *voiceData = [NSMutableData dataWithContentsOfFile:amrPath];
    
    NSLog(@"%@",voiceData);
    
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
    
    //    ASIHTTPRequest *r = [ASIHTTPRequest requestWithURL:voiceUrl];
    //    //r.delegate = self;
    //    r.tag =1;
    //    r.timeOutSeconds = 15;
    //    r.responseEncoding = NSUTF8StringEncoding;
    //    //[r startSynchronous];
    //    [r setDelegate:self];
    //    // 开始异步请求
    //    [r startAsynchronous ];
    
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


-(NSString*)DownloadTextFile:(NSString*)fileUrl   fileName:(NSString*)fileNameStr
{
    NSLog(@"*****%@",fileNameStr);
    fileUrl = [NSString stringWithFormat:@"%@/%@",fileUrl,fileNameStr ];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    if (!docDir) {
        NSLog(@"Documents 目录未找到");
    }
    
    fileNameStr = [NSString stringWithFormat:@"%@.%@",fileNameStr,@"amr"];
    NSString *filePath = [docDir stringByAppendingPathComponent:fileNameStr];
    
    NSURL *url = [NSURL URLWithString:fileUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSLog(@"%@",data);
    
    [data writeToFile:filePath atomically:YES];//将NSData类型对象data写入文件，文件名为FileName
    
    return filePath;
}


-(void) voiceOrText
{
    if (containerView.hidden) {
        voiceView.hidden = YES;
        containerView.hidden = NO;
    }else{
        containerView.hidden = YES;
        voiceView.hidden = NO;
    }
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
    
    NSLog(@"******%d,%d,%d",_start,_pageSize,_total);
    
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


/*------群组初始化------------------------------------------------------------*/
//初始化聊天室
-(void)initRoom{
    NSLog(@"******%@",self.roomName);
    XMPPRoomCoreDataStorage *rosterstorage = [[XMPPRoomCoreDataStorage alloc] init];
    if (rosterstorage ==nil){
        rosterstorage=  [XMPPRoomCoreDataStorage sharedInstance];
    }
    XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:rosterstorage jid:[XMPPJID jidWithString:self.roomName] dispatchQueue:dispatch_get_main_queue()];
    // [rosterstorage release];
    _xmppRoom = room;
    XMPPStream *stream = [XMPPServer xmppStream];
    [room activate:stream];
    [room joinRoomUsingNickname:myUserName history:nil];
    [room configureRoomUsingOptions:nil];
    //[room fetchConfigurationForm];
    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
}


#pragma mark - private
- (IBAction)sendButton:(id)sender {
    //本地输入框中的信息
    NSString *message = textView.text;
    if (message.length > 0) {
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型：群聊
        [mes addAttributeWithName:@"type" stringValue:@"groupchat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_roomName];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:myUserName];
        //组合
        [mes addChild:body];
        //发送消息
        [[XMPPServer xmppStream] sendElement:mes];
        
        textView.text = @"";
        [textView resignFirstResponder];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        [dictionary setObject:message forKey:@"msg"];
        [dictionary setObject:@"me" forKey:@"sender"];
        //加入发送时间
        [dictionary setObject:[ChatStatic getCurrentTime] forKey:@"time"];
        
        [self.messages addObject:dictionary];
        
        //重新刷新tableView
        [self.tView reloadData];
    }
}

#pragma mark - XMPPRoom delegate
//创建结果
-(void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"xmppRoomDidCreate");
}

//是否已经加入房间
-(void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"xmppRoomDidJoin");
}

//是否已经离开
-(void)xmppRoomDidLeave:(XMPPRoom *)sender{
    NSLog(@"xmppRoomDidLeave");
}

//收到群聊消息
-(void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID{
    NSLog(@"xmppRoom:didReceiveMessage:fromOccupant:");
    //    NSLog(@"%@,%@,%@",occupantJID.user,occupantJID.domain,occupantJID.resource);
    
    NSLog(@"*****%@",sender);
    
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    NSString *mtype =[[message elementForName:@"mtype"] stringValue];
    NSString *type =[[message attributeForName:@"type"] stringValue];
    NSLog(@"*****%@",from);
    
    //  NSString *
    if ([from isEqualToString:[NSString stringWithFormat:@"%@/%@",_roomName,myUserName]]) {
        return;
    }
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat: @"yy-MM-dd HH:mm"];
    
    NSDate *  sendDate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YY-MM-dd hh:mm"];
    NSString *  sendTimeStr=[dateformatter stringFromDate:sendDate];
    
    // [dateformatter release];
    
    NSString *senderStr=@"";
    
    NSString*str_character = @"/";
    NSRange senderRange = [from rangeOfString:str_character];
    if ([from rangeOfString:str_character].location != NSNotFound) {
        senderStr= [from substringToIndex:senderRange.location];
    }
    NSArray *arry=[from componentsSeparatedByString:@"/"];
    
    if (arry.count==2) {
        senderStr = [arry objectAtIndex:1];
    }
    
    /*
     //消息写入数据库
     if ([_messgaeFlag isEqualToString:@"UpdateMessageFlag"]) {
     
     if ([mtype isEqualToString:@"image"]){
     //  NSString *imageBodyJsonStr =  [[NSString stringWithFormat:@"%@%@%@",@"{\"data\":\"", info,@"\",\"src\":\"\",\"link\":\"no url\"}"] autorelease];
     
     NSString *imageJsonStr = [msg stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
     //            NSLog(@"imageJsonStr:%@",imageJsonStr);
     //            NSDictionary *imageData = [imageJsonStr objectFromJSONString];
     //            NSLog(@"imageJsonStr.link:%@",[imageData objectForKey:@"link"]);
     //            NSLog(@"imageJsonStr.data:%@",[imageData objectForKey:@"data"]);
     [GroupChatMessageCRUD insertGroupChatMessage:_roomName sendUser:senderStr msg:imageJsonStr type:type msgType:mtype sendTime:sendTimeStr];
     
     }else if([mtype isEqualToString:@"voice"]){
     NSString *imageJsonStr = [msg stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
     [GroupChatMessageCRUD insertGroupChatMessage:_roomName sendUser:senderStr msg:imageJsonStr type:type msgType:mtype sendTime:sendTimeStr];
     
     
     }else{
     [GroupChatMessageCRUD insertGroupChatMessage:_roomName sendUser:senderStr msg:msg type:type msgType:mtype sendTime:sendTimeStr];
     }
     
     }
     */
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
    UIView *chatView = [self bubbleView:msg
                                   from:NO type:type subject:mtype historyFlag:NO];
    
    [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"msgId", msg, @"text", @"other", @"speaker",type,@"type",mtype,@"subject", chatView, @"view", nil]];
    [self.chatTableView reloadData];
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                              atScrollPosition: UITableViewScrollPositionBottom
                                      animated:YES];
    
    NSLog(@"更新标记%@",_messgaeFlag);
    if ([_messgaeFlag isEqualToString:@"UpdateMessageFlag"]) {
        
        // [self updateTable:_chatWithUser];
        NSLog(@"播放提示音");
        AudioServicesPlaySystemSound(1109);
        
    }
    
    //查询聊天列表是否存在
    NSString *lastMsg = @"";
    if ([type isEqualToString:@"chat"] && [mtype isEqualToString:@"chat"]) {
        lastMsg = msg;
    }else if([type isEqualToString:@"chat"] && [mtype isEqualToString:@"image"]){
        lastMsg = @"［图片］";
    }else if([type isEqualToString:@"chat"] && [mtype isEqualToString:@"voice"]){
        lastMsg = @"［语音］";
    }

    if(self.chatBuddyFlag == NO){
        NSString * myJID =  [NSString stringWithFormat:@"%@@%@",myUserName, OpenFireHostName];
        ChatGroup *chatGroup = [[ChatGroup alloc]init];
        chatGroup = [GroupCRUD queryChatGroupByJID:_roomName myJID:myJID];
        [ChatBuddyCRUD insertChatBuddyTable:_roomName name:@"" nickName:_roomNickName phone:@"" avatar:@"" myUserName:myUserName type:@"groupchat"lastMsg:lastMsg msgType:type msgSubject:mtype lastMsgTime:sendTimeStr];
        self.chatBuddyFlag = YES;
    }else{
        [ChatBuddyCRUD updateChatBuddy:_roomName name:@"" nickName:_roomNickName lastMsg:lastMsg msgType:type msgSubject:mtype lastMsgTime:sendTimeStr];
    }
    
    //更新消息状态
    [GroupChatMessageCRUD updateGroupChatMessage:_roomName];
}

//房间人员加入
- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSLog(@"occupantDidJoin");
    NSString *jid = occupantJID.user;
    NSString *domain = occupantJID.domain;
    NSString *resource = occupantJID.resource;
    NSString *presenceType = [presence type];
    NSString *userId = [sender myRoomJID].user;
    NSString *presenceFromUser = [[presence from] user];
    
    NSLog(@"occupantDidJoin----jid=%@,domain=%@,resource=%@,当前用户:%@ ,出席用户:%@,presenceType:%@",jid,domain,resource,userId,presenceFromUser,presenceType);
    
    if (![presenceFromUser isEqualToString:userId]) {
        //对收到的用户的在线状态的判断在线状态
        
        //在线用户
        if ([presenceType isEqualToString:@"available"]) {
            //   NSString *buddy = [[NSString stringWithFormat:@"%@@%@", presenceFromUser, OpenFireHostName] retain];
            NSString *buddy = [NSString stringWithFormat:@"%@@%@", presenceFromUser, OpenFireHostName];
            //            [chatDelegate newBuddyOnline:buddy];//用户列表委托
        }
        
        //用户下线
        else if ([presenceType isEqualToString:@"unavailable"]) {
            //            [chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, OpenFireHostName]];//用户列表委托
        }
    }
}

//房间人员离开
-(void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSString *jid = occupantJID.user;
    NSString *domain = occupantJID.domain;
    NSString *resource = occupantJID.resource;
    NSString *presenceType = [presence type];
    NSString *userId = [sender myRoomJID].user;
    NSString *presenceFromUser = [[presence from] user];
    NSLog(@"occupantDidLeave----jid=%@,domain=%@,resource=%@,当前用户:%@ ,出席用户:%@,presenceType:%@",jid,domain,resource,userId,presenceFromUser,presenceType);
}

//房间人员加入
-(void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSString *jid = occupantJID.user;
    NSString *domain = occupantJID.domain;
    NSString *resource = occupantJID.resource;
    NSString *presenceType = [presence type];
    NSString *userId = [sender myRoomJID].user;
    NSString *presenceFromUser = [[presence from] user];
    NSLog(@"occupantDidUpdate----jid=%@,domain=%@,resource=%@,当前用户:%@ ,出席用户:%@,presenceType:%@",jid,domain,resource,userId,presenceFromUser,presenceType);
}


/*-------------提示框---------------------------------------------------------------------*/
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
    
    [CSNotificationView showInViewController:self
                                   tintColor:[UIColor colorWithRed:0.200 green:0.6 blue:1 alpha:1]
                                       image:nil
                                     message:@" 录音时间太短!"
                                    duration:2.0f];
}


-(void)openDataBase
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return NO;
    
}
@end
