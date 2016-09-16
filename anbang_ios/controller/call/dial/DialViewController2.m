//
//  ViewController.m
//  StrapButton
//
//  Created by Oskur on 2013-09-29.
//  Copyright (c) 2013 Oskar Groth. All rights reserved.
//

#import "DialViewController2.h"
#import "UIButton+Bootstrap.h"
#import "VoipModule.h"
#import "APPRTCViewController.h"
#import "CallRecordsViewController.h"
#import "ChatBuddyViewController.h"
#import "AsynImageView.h"
#import "JSMessageSoundEffect.h"
#import "UIImageView+WebCache.h"
#import "CallContactsViewController.h"
#import "CSNotificationView.h"

//static SystemSoundID shake_sound_male_id = 0;

#define dtmf_1 1201
#define dtmf_2 1202
#define dtmf_3 1203
#define dtmf_4 1204
#define dtmf_5 1205
#define dtmf_6 1206
#define dtmf_7 1207
#define dtmf_8 1208
#define dtmf_9 1209
#define dtmf_0 1200
#define dtmf_start 1210


#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface DialViewController2 ()



@end

@implementation DialViewController2



- (void)didReceiveMemoryWarning
{
    
    NSLog(@"内存警告－拨号");
    [super didReceiveMemoryWarning];
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
            self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
        }
        
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        //self.edgesForExtendedLayout = UIRectEdgeNone;
        //self.extendedLayoutIncludesOpaqueBars = NO;
        //self.modalPresentationCapturesStatusBarAppearance = YES;
        self.navigationController.navigationBar.translucent = NO;
        //self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDial2:) name:@"NNC_Is_Have_Userinfo" object:nil];
    
    
    //摇一摇
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    [self becomeFirstResponder];
    
    segmentedControl = [ [ UISegmentedControl alloc ]
                        initWithItems: nil ];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [ segmentedControl insertSegmentWithTitle:
     NSLocalizedString(@"call.call",@"action") atIndex: 0 animated: NO ];
    [ segmentedControl insertSegmentWithTitle:
     NSLocalizedString(@"call.callRecords",@"action") atIndex: 1 animated: NO ];
    [ segmentedControl insertSegmentWithTitle:
     NSLocalizedString(@"call.callContacts",@"action") atIndex: 2 animated: NO ];
    
    [segmentedControl setSelectedSegmentIndex:0];
    
    self.navigationItem.titleView = segmentedControl;
    
    [segmentedControl addTarget:self
                         action: @selector(controllerPressed:)
               forControlEvents: UIControlEventValueChanged
     ];
    
    segmentedControl.tintColor = [UIColor whiteColor];
    
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 40.0, self.defaultButton.frame.size.width, 20)];
    UILabel *label11 = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 50.0, 30, 30)];
    label1.text = @"abc";
    label1.textAlignment = NSTextAlignmentCenter;
    
    label11.textColor = [UIColor blackColor];
    
    //label1.backgroundColor = [UIColor redColor];
    //label11.backgroundColor = [UIColor redColor];
    [self.defaultButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:28.0f]];
    self.defaultButton.titleLabel.textColor = [UIColor whiteColor];
    self.defaultButton.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    //[self.defaultButton.titleLabel addSubview:label1];
    //[self.defaultButton addSubview:label1];
    
    if (kIsPad) {
        [self.defaultButton customStyle];
        [self.defaultButton2 customStyle];
        [self.defaultButton3 customStyle];
        [self.defaultButton4 customStyle];
        [self.defaultButton5 customStyle];
        [self.defaultButton6 customStyle];
        [self.defaultButton7 customStyle];
        [self.defaultButton8 customStyle];
        [self.defaultButton9 customStyle];
        [self.defaultButton0 customStyle];
        
        [self.calendarButton customImgStyle];
        
        [self.favoriteButton customImgStyle];
        
    }else{
        [self.defaultButton defaultStyle];
        [self.defaultButton2 defaultStyle];
        [self.defaultButton3 defaultStyle];
        [self.defaultButton4 defaultStyle];
        [self.defaultButton5 defaultStyle];
        [self.defaultButton6 defaultStyle];
        [self.defaultButton7 defaultStyle];
        [self.defaultButton8 defaultStyle];
        [self.defaultButton9 defaultStyle];
        [self.defaultButton0 defaultStyle];
        
        [self.calendarButton infoStyle];
        //[self.calendarButton addAwesomeIcon:FAIconCalendar beforeTitle:NO];
        
        [self.favoriteButton warningStyle];
        
        //[self.favoriteButton addAwesomeIcon:FAIconStar beforeTitle:NO];
    }
    [self.defaultButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:28.0f]];
    [self.defaultButton2.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:28.0f]];
    [self.defaultButton3.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:28.0f]];
    [self.defaultButton4.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:28.0f]];
    [self.defaultButton5.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:28.0f]];
    [self.defaultButton6.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:28.0f]];
    [self.defaultButton7.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:28.0f]];
    [self.defaultButton8.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:28.0f]];
    [self.defaultButton9.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:28.0f]];
    [self.defaultButton0.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:28.0f]];
    //[self.favoriteButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:28.0f]];
    //[self.calendarButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:28.0f]];
    self.defaultButton.tag = 1;
    self.defaultButton2.tag = 2;
    self.defaultButton3.tag = 3;
    self.defaultButton4.tag = 4;
    self.defaultButton5.tag = 5;
    self.defaultButton6.tag = 6;
    self.defaultButton7.tag = 7;
    self.defaultButton8.tag = 8;
    self.defaultButton9.tag = 9;
    self.defaultButton0.tag = 0;
    self.calendarButton.tag = 11;
    self.favoriteButton.tag = 12;
    
    self.favoriteButton.imageView.frame = CGRectMake(0, 0, 30, 30);
    //    self.defaultButton.backgroundColor =  [UIColor orangeColor];
    //    self.defaultButton2.backgroundColor = [UIColor orangeColor];
    //    self.defaultButton3.backgroundColor = [UIColor orangeColor];
    //    self.defaultButton4.backgroundColor = [UIColor orangeColor];
    //    self.defaultButton5.backgroundColor = [UIColor orangeColor];
    //    self.defaultButton6.backgroundColor = [UIColor orangeColor];
    //    self.defaultButton7.backgroundColor = [UIColor orangeColor];
    //    self.defaultButton8.backgroundColor = [UIColor orangeColor];
    //    self.defaultButton9.backgroundColor = [UIColor orangeColor];
    //    self.defaultButton0.backgroundColor = [UIColor orangeColor];
    //    self.calendarButton.backgroundColor = [UIColor orangeColor];
    //    self.favoriteButton.backgroundColor = [UIColor orangeColor];
    
    int topHeight = 63;

    
    int iphoneButHeight = 100;
    int iphoneButWidth = 100;
    
    if (NO) {
        
        self.defaultButton.frame =CGRectMake((KCurrWidth-250)/2-10, topHeight, iphoneButWidth, iphoneButHeight);
        self.defaultButton2.frame =CGRectMake((KCurrWidth-250)/2+95, topHeight, iphoneButWidth, iphoneButHeight);
        self.defaultButton3.frame=CGRectMake((KCurrWidth-250)/2+(95*2)+10, topHeight, iphoneButWidth, iphoneButHeight);
        
        self.defaultButton4.frame=CGRectMake((KCurrWidth-250)/2-10, topHeight+(KCurrHeight/6), iphoneButWidth, iphoneButHeight);
        self.defaultButton5.frame=CGRectMake((KCurrWidth-250)/2+95,topHeight+(KCurrHeight/6), iphoneButWidth, iphoneButHeight);
        self.defaultButton6.frame=CGRectMake((KCurrWidth-250)/2+(95*2)+10, topHeight+(KCurrHeight/6), iphoneButWidth, iphoneButHeight);
        
        self.defaultButton7.frame=CGRectMake((KCurrWidth-250)/2-10, topHeight+(KCurrHeight/6)*2, iphoneButWidth, iphoneButHeight);
        self.defaultButton8.frame=CGRectMake((KCurrWidth-250)/2+95,topHeight+(KCurrHeight/6)*2, iphoneButWidth, iphoneButHeight);
        self.defaultButton9.frame=CGRectMake((KCurrWidth-250)/2+(95*2)+10,topHeight+(KCurrHeight/6)*2, iphoneButWidth, iphoneButHeight);
        
        self.calendarButton.frame= CGRectMake((KCurrWidth-250)/2-10, topHeight+(KCurrHeight/6)*3, iphoneButWidth, iphoneButHeight);
        self.defaultButton0.frame=CGRectMake((KCurrWidth-250)/2+95, topHeight+(KCurrHeight/6)*3, iphoneButWidth, iphoneButHeight);
        self.favoriteButton.frame=CGRectMake((KCurrWidth-250)/2+(95*2)+10, topHeight+(KCurrHeight/6)*3, iphoneButWidth, iphoneButHeight);
    }
    
    
    if (kIsPad) {
        self.view.frame = CGRectMake(0, 0, KCurrWidth, KCurrHeight);
        int ipadButHeight = 100;
        int ipadButWidth = 100;
        int ipadButWidthGap = 150;
        int ipadButheightGap = 200;
        int ipadWidth = 400;
        
        self.defaultButton.frame =CGRectMake((KCurrWidth-ipadWidth)/2, ipadButheightGap, ipadButWidth, ipadButHeight);
        self.defaultButton2.frame =CGRectMake((KCurrWidth-ipadWidth)/2+ipadButWidthGap, ipadButheightGap, ipadButWidth, ipadButHeight);
        self.defaultButton3.frame=CGRectMake((KCurrWidth-ipadWidth)/2+(ipadButWidthGap*2), ipadButheightGap, ipadButWidth, ipadButHeight);
        
        self.defaultButton4.frame=CGRectMake((KCurrWidth-ipadWidth)/2, ipadButheightGap+(KCurrHeight/8), ipadButWidth, ipadButHeight);
        self.defaultButton5.frame=CGRectMake((KCurrWidth-ipadWidth)/2+ipadButWidthGap,ipadButheightGap+(KCurrHeight/8), ipadButWidth, ipadButHeight);
        self.defaultButton6.frame=CGRectMake((KCurrWidth-ipadWidth)/2+(ipadButWidthGap*2), ipadButheightGap+(KCurrHeight/8), ipadButWidth, ipadButHeight);
        
        self.defaultButton7.frame=CGRectMake((KCurrWidth-ipadWidth)/2, ipadButheightGap+(KCurrHeight/8)*2, ipadButWidth, ipadButHeight);
        self.defaultButton8.frame=CGRectMake((KCurrWidth-ipadWidth)/2+ipadButWidthGap,ipadButheightGap+(KCurrHeight/8)*2, ipadButWidth, ipadButHeight);
        self.defaultButton9.frame=CGRectMake((KCurrWidth-ipadWidth)/2+(ipadButWidthGap*2),ipadButheightGap+(KCurrHeight/8)*2, ipadButWidth, ipadButHeight);
        
        self.defaultButton0.frame=CGRectMake((KCurrWidth-ipadWidth)/2+ipadButWidthGap, ipadButheightGap+(KCurrHeight/8)*3, ipadButWidth, ipadButHeight);
        self.calendarButton.frame= CGRectMake((KCurrWidth-ipadWidth)/2, ipadButheightGap+(KCurrHeight/8)*3, ipadButWidth, ipadButHeight);
        self.favoriteButton.frame=CGRectMake((KCurrWidth-ipadWidth)/2+(ipadButWidthGap*2), ipadButheightGap+(KCurrHeight/8)*3, ipadButWidth, ipadButHeight);
        
    }
    
    
    [self.defaultButton addTarget:self action:@selector(dial:) forControlEvents:
     UIControlEventTouchUpInside];
    [self.defaultButton2 addTarget:self action:@selector(dial:) forControlEvents:UIControlEventTouchUpInside];
    [self.defaultButton3 addTarget:self action:@selector(dial:) forControlEvents:UIControlEventTouchUpInside];
    [self.defaultButton4 addTarget:self action:@selector(dial:) forControlEvents:UIControlEventTouchUpInside];
    [self.defaultButton5 addTarget:self action:@selector(dial:) forControlEvents:UIControlEventTouchUpInside];
    [self.defaultButton6 addTarget:self action:@selector(dial:) forControlEvents:UIControlEventTouchUpInside];
    [self.defaultButton7 addTarget:self action:@selector(dial:) forControlEvents:UIControlEventTouchUpInside];
    [self.defaultButton8 addTarget:self action:@selector(dial:) forControlEvents:UIControlEventTouchUpInside];
    [self.defaultButton9 addTarget:self action:@selector(dial:) forControlEvents:UIControlEventTouchUpInside];
    [self.defaultButton0 addTarget:self action:@selector(dial:) forControlEvents:UIControlEventTouchUpInside];
    [self.calendarButton addTarget:self action:@selector(playDial) forControlEvents:UIControlEventTouchUpInside];
    [self.favoriteButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    
    //    [self.primaryButton primaryStyle];
    //    [self.successButton successStyle];
    //    [self.infoButton infoStyle];
    //    [self.warningButton warningStyle];
    //    [self.dangerButton dangerStyle];
    //
    //    [self.bookmarkButton primaryStyle];
    //    [self.bookmarkButton addAwesomeIcon:FAIconBookmark beforeTitle:YES];
    //
    //    [self.doneButton successStyle];
    //    [self.doneButton addAwesomeIcon:FAIconCheck beforeTitle:NO];
    //
    //    [self.deleteButton dangerStyle];
    //    [self.deleteButton addAwesomeIcon:FAIconRemove beforeTitle:YES];
    //
    //    [self.downloadButton defaultStyle];
    //    [self.downloadButton addAwesomeIcon:FAIconDownloadAlt beforeTitle:NO];
    
    
    
    if (kIsPad) {
        numText = [[UITextField alloc]initWithFrame:CGRectMake(30, 50, KCurrWidth-66, 50)];
    }else if(kIsiPhone6p){
        numText = [[UITextField alloc]initWithFrame:CGRectMake(30, 18, KCurrWidth-66, 50)];
    }else if(kIsiPhone6){
        numText = [[UITextField alloc]initWithFrame:CGRectMake(30, 10, KCurrWidth-66, 50)];
    }else{
        numText = [[UITextField alloc]initWithFrame:CGRectMake(30, 8, KCurrWidth-66, 50)];
    }
    //设置边框样式，只有设置了才会显示边框样式
    // text.borderStyle = UITextBorderStyleRoundedRect;
    // numText.clearButtonMode = UITextFieldViewModeAlways;
    
    
    //设置字体颜色
    //numText.textColor = [UIColor blueColor];
    [numText resignFirstResponder];
    
    if (kIsiPhone6) {
        numText.font=[UIFont fontWithName:@"Helvetica" size:35.0f];
    }else if(kIsiPhone6p){
        numText.font=[UIFont fontWithName:@"Helvetica" size:38.0f];
        
    }else{
        numText.font=[UIFont fontWithName:@"Helvetica" size:32.0f];
        
    }
    
    numText.textAlignment = NSTextAlignmentCenter;
    [numText setPlaceholder:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"call.myNumber",@"title"),MY_USER_NAME]];
    
    //设置为YES时文本会自动缩小以适应文本窗口大小.默认是保持原来大小,而让长文本滚动
    numText.adjustsFontSizeToFitWidth = YES;
    //设置自动缩小显示的最小字体大小
    numText.minimumFontSize = 12;
       _deleteBut = [[UIButton alloc]initWithFrame:CGRectMake(numText.frame.size.width+32, numText.frame.origin.y+10
                                                           , 35, 29)
                  ];
    [_deleteBut setImage:[UIImage imageNamed:@"delete_call"]
                forState:UIControlStateNormal];
    [_deleteBut addTarget:self action:@selector(deleteNum)
         forControlEvents:UIControlEventTouchUpInside];
    //长按
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteAllNum)];
    longPress.minimumPressDuration = 0.3; //定义按的时间
    [_deleteBut addGestureRecognizer:longPress];
    
    //[_deleteBut setFrame:CGRectMake(numText.frame.size.width+32, 16, 35, 29)];
    [_deleteBut setContentMode:UIViewContentModeCenter];
    
    [self.view addSubview:_deleteBut];
    _deleteBut.hidden = YES;
    
    //[userNameText becomeFirstResponder ];
    [self.view addSubview:numText];
    
    numText.delegate = self;
    
    //[numText addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"login_bg"] ];
    
    callRecordsVC = [[CallRecordsViewController alloc] init];
    callRecordsVC.view.tag = 10001;
    
    callContactsVC = [[CallContactsViewController alloc] init];
    callContactsVC.view.tag = 10002;
    self.view.backgroundColor = [UIColor whiteColor];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //外置声音播放模式
    
    // [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Is_Have_Userinfo" object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Is_Have_Userinfo" object:nil];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    //弹出UIDatePicker 代码
    
    
    return NO;
    
}

-(void)dial:(UIButton *) btn
{
    
    if (numText.text.length==0) {
        _deleteBut.hidden = NO;
    }
    if (kIsiPhone6) {
        btn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:35.0f];
    }else if(kIsiPhone6p){
        btn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:38.0f];
    }else{
        btn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:32.0f];
    }
    
    //numText.font = [UIFont fontWithName:@"Helvetica" size:38.0f];
    if (btn.tag==1) {
        numText.text = [NSString stringWithFormat:@"%@%@",numText.text,@"1"];
        //NSURL *filePath  = [[NSBundle mainBundle] URLForResource:@"dtmf-1" withExtension:@"caf"];
        //AudioServicesCreateSystemSoundID( (CFURLRef)objc_unretainedPointer(filePath), &shake_sound_male_id);
        //AudioServicesPlaySystemSound(shake_sound_male_id);
        //[JSMessageSoundEffect playSound:@"1201" type:@"caf"];
        //[btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        AudioServicesPlaySystemSound(dtmf_1);
    }else if(btn.tag==2){
        numText.text = [NSString stringWithFormat:@"%@%@",numText.text,@"2"];
        //[JSMessageSoundEffect playSound:@"dtmf-2" type:@"caf"];
        //[btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        //btn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:38.0f];
        AudioServicesPlaySystemSound(dtmf_2);
    }else if(btn.tag==3){
        numText.text = [NSString stringWithFormat:@"%@%@",numText.text,@"3"];
        //[JSMessageSoundEffect playSound:@"dtmf-3" type:@"caf"];
        //[btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        //btn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:38.0f];
        AudioServicesPlaySystemSound(dtmf_3);
    }else if(btn.tag==4){
        numText.text = [NSString stringWithFormat:@"%@%@",numText.text,@"4"];
        // [JSMessageSoundEffect playSound:@"dtmf-4" type:@"caf"];
        //[btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        //btn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:38.0f];
        AudioServicesPlaySystemSound(dtmf_4);
    }else if(btn.tag==5){
        numText.text = [NSString stringWithFormat:@"%@%@",numText.text,@"5"];
        //[JSMessageSoundEffect playSound:@"dtmf-5" type:@"caf"];
        // [btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        //btn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:38.0f];
        AudioServicesPlaySystemSound(dtmf_5);
    }else if(btn.tag==6){
        numText.text = [NSString stringWithFormat:@"%@%@",numText.text,@"6"];
        //[JSMessageSoundEffect playSound:@"dtmf-6" type:@"caf"];
        //[btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        //btn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:38.0f];
        AudioServicesPlaySystemSound(dtmf_6);
    }else if(btn.tag==7){
        numText.text = [NSString stringWithFormat:@"%@%@",numText.text,@"7"];
        //[JSMessageSoundEffect playSound:@"dtmf-7" type:@"caf"];
        // [btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        //btn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:38.0f];
        AudioServicesPlaySystemSound(dtmf_7);
    }else if(btn.tag==8){
        numText.text = [NSString stringWithFormat:@"%@%@",numText.text,@"8"];
        AudioServicesPlaySystemSound(dtmf_8);
        // [btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        //btn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:38.0f];
    }else if(btn.tag==9){
        numText.text = [NSString stringWithFormat:@"%@%@",numText.text,@"9"];
        //[JSMessageSoundEffect playSound:@"dtmf-9" type:@"caf"];
        //[btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        //btn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:38.0f];
        AudioServicesPlaySystemSound(dtmf_9);
    }else if(btn.tag==0){
        numText.text = [NSString stringWithFormat:@"%@%@",numText.text,@"0"];
        //[JSMessageSoundEffect playSound:@"dtmf-0" type:@"caf"];
        //[btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        //btn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:38.0f];
        AudioServicesPlaySystemSound(dtmf_0);
    }
}


-(void)recoverButTitle{
    self.defaultButton0.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:28.0f];
    self.defaultButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:28.0f];
    self.defaultButton2.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:28.0f];
    self.defaultButton3.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:28.0f];
    self.defaultButton4.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:28.0f];
    self.defaultButton5.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:28.0f];
    self.defaultButton6.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:28.0f];
    self.defaultButton7.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:28.0f];
    self.defaultButton8.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:28.0f];
    self.defaultButton9.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:28.0f];
}

-(void)defaultButtonShowAndHidden:(BOOL)flag{
    [self.defaultButton0 setEnabled:flag];
    [self.defaultButton  setEnabled:flag];
    [self.defaultButton2 setEnabled:flag];
    [self.defaultButton3 setEnabled:flag];
    [self.defaultButton4 setEnabled:flag];
    [self.defaultButton5 setEnabled:flag];
    [self.defaultButton6 setEnabled:flag];
    [self.defaultButton7 setEnabled:flag];
    [self.defaultButton8 setEnabled:flag];
    [self.defaultButton9 setEnabled:flag];
    [self.calendarButton setEnabled:flag];
    [self.favoriteButton setEnabled:flag];
    
    self.defaultButton0.frame = CGRectMake(0, 0, 0, 0);
}

/*---视频语音start-----------------------------------------------------------------------------------*/
/*<iq type=”get”>
 <query xmlns=”http://www.nihualao.com/xmpp/userinfo“ >
 <user jid=””/>
 <user jid=””/> </query>
 </iq>*/
//获取用户信息，检测用户是否存在
-(void)userinfoRequest:(NSString *)userName{
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *userJid=[NSXMLElement elementWithName:@"user"];
    [userJid addAttributeWithName:@"jid" stringValue:userName];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"Is_Have_Userinfo"];
    [queryElement addChild:userJid];
    [iq addChild:queryElement];
    [[XMPPServer xmppStream] sendElement:iq];
}


//打电话
-(void)playDial{
    _deleteBut.hidden=YES;
    [self.calendarButton  setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [self.favoriteButton setImage:[UIImage imageNamed:@"user_call_s_blue.png"] forState:UIControlStateHighlighted];
    
    [self recoverButTitle];
    //NSLog(@"开始拨打电话");
    //[JSMessageSoundEffect playSound:@"dtmf-pound" type:@"caf"];
    AudioServicesPlaySystemSound(dtmf_start);
    
    isPhone=YES;
    if (numText.text.length>0) {
        NSString  * userJID = [numText.text stringByAppendingFormat:@"@%@",OpenFireHostName];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self userinfoRequest:userJID];
        });
        
    }else{
        //请输入号码
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:NSLocalizedString(@"call.callMsg2",@"message")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action")  otherButtonTitles:nil, nil];
        [alert show];
        
    }
}

//开视频
-(void)playVideo{
    _deleteBut.hidden = YES;
    [self.favoriteButton  setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [self.favoriteButton setImage:[UIImage imageNamed:@"user_call_s_blue.png"] forState:UIControlStateHighlighted];
    [self recoverButTitle];
    // NSLog(@"开始语音视频");
    //[JSMessageSoundEffect playSound:@"dtmf-star" type:@"caf"];
    AudioServicesPlaySystemSound(dtmf_start);
    isPhone=NO;
    if (numText.text.length>0) {
        NSString  * userJID = [numText.text stringByAppendingFormat:@"@%@",OpenFireHostName];
        [self userinfoRequest:userJID];
        
    }else{
        //请输入号码
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:NSLocalizedString(@"call.callMsg2",@"message")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action")  otherButtonTitles:nil, nil];
        [alert show];
    }
}



/*-(void)addressbookPhoneNum:(NSNotification *)phoneNum{
 txtPhoneNum.text=[NSString stringWithFormat:@"%@",[phoneNum object]];*/
-(void)playDial2:(NSNotification *)have{
    
    NSString *isHave=[NSString stringWithFormat:@"%@",[have object]];
    
    NSLog(@"********%@",isHave);
    if (isHave!=nil&&![isHave isEqualToString:@"(null)"]) {
        NSString  * jid = [numText.text stringByAppendingFormat:@"@%@",OpenFireHostName];
        if ([jid isEqualToString:MY_JID]) {
            [CSNotificationView showInViewController:self
                                           tintColor:[UIColor colorWithRed:255.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:0]
                                               image:nil
                                             message:NSLocalizedString(@"call.callMsg5",@"message")
                                            duration:5.0f];
            return;
        }
        if (isPhone==YES) { //语音通话
#if !TARGET_IPHONE_SIMULATOR
            
            
            //[CallRecordsCRUD insertCallRecordsMyUserName:myUserName userName:_txtNumber.text callWay:@"呼出音频电话" data:week];
            
            XMPPJID *to = [XMPPJID jidWithString:jid resource:@"Hisuper"];
            
            NSString *toStrJID = [jid stringByAppendingFormat:@"%@",@"/Hisuper"];
            
            NSString* sessionID = [XMPPStream generateUUID];
            NSLog(@"******%@",sessionID);
            if(YES)
            {
                APPRTCViewController *appView = [[APPRTCViewController alloc]init];
                NSLog(@"******%@",toStrJID);
                appView.from = toStrJID;
                appView.isCaller = YES;
                appView.isVideo = NO;
                appView.msessionID = sessionID;
                
                [self.view.window.rootViewController presentViewController:appView animated:YES completion:^{
                    
                    //  CHAppDelegate *app = [UIApplication sharedApplication].delegate;
                    
                    [appView.lbname setText:to.user];
                    NSString *photoImage=[[NSUserDefaults standardUserDefaults]objectForKey:@"NSUD_PhoneImage"];
                    UIImage *image = [UIImage imageNamed:@"defaultUser.png"];
                    if (![photoImage isEqualToString:@""]) {
                        NSString *photoImageUrl=[NSString stringWithFormat:@"%@/%@",ResourcesURL,photoImage];
                        AsynImageView *photoView=[[AsynImageView alloc]initWithFrame:CGRectMake(240, 5, 50, 50)];
                        //[photoView setImageWithURL:[NSURL URLWithString:photoImageUrl]
                        //          placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
                        photoView.imageURL = photoImageUrl;
                        if (photoView.image) {
                            [appView.ivavatar setImage:photoView.image];
                        }else{
                            [appView.ivavatar setImage:image];
                        }
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
                //呼叫失败
                [self showAlert:NSLocalizedString(@"public.callFailure",@"message")];
            }
            
#endif
        }else{  //视频通话
            
#if !TARGET_IPHONE_SIMULATOR
            
            //            [CallRecordsCRUD insertCallRecordsMyUserName:myUserName userName:_txtNumber.text callWay:@"呼出视频电话" data:week];
            
            XMPPJID *to = [XMPPJID jidWithString:jid resource:@"Hisuper"];
            NSString* sessionID = [XMPPStream generateUUID];
            if(YES)
            {
                APPRTCViewController *appView = [[APPRTCViewController alloc]init];
                appView.from = [to full];
                appView.isCaller = YES;
                appView.isVideo = YES;
                appView.msessionID = sessionID;
                
                [self.view.window.rootViewController presentViewController:appView animated:YES completion:^{
                    
                    [appView.lbname setText:to.user];
                    NSString *photoImage=[[NSUserDefaults standardUserDefaults]objectForKey:@"NSUD_PhoneImage"];
                    UIImage *image = [UIImage imageNamed:@"defaultUser.png"];
                    if (![photoImage isEqualToString:@""]) {
                        NSString *photoImageUrl=[NSString stringWithFormat:@"%@/%@",ResourcesURL,photoImage];
                        AsynImageView *photoView=[[AsynImageView alloc]initWithFrame:CGRectMake(240, 5, 50, 50)];
                        //[photoView setImageWithURL:[NSURL URLWithString:photoImageUrl]
                        //         placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
                        photoView.imageURL = photoImageUrl;
                        
                        if (photoView.image) {
                            [appView.ivavatar setImage:photoView.image];
                        }else{
                            [appView.ivavatar setImage:image];
                        }
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
                //呼叫失败
                [self showAlert:NSLocalizedString(@"public.callFailure",@"message")];
            }
            
#endif
            
        }
    }else{
        //您拨打的邦邦社区号码不存在
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"call.callMsg",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    numText.text=@"";
    
}


-(void)showAlert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") otherButtonTitles:nil, nil];
    [alert show];
}

/*---视频语音end-----------------------------------------------------------------------------------*/



//分段控制器
- (void)controllerPressed:(id)sender {
    
    
    int selectedSegmentIndex = segmentedControl.selectedSegmentIndex;
    
    NSLog(@"*******%d",selectedSegmentIndex);
    if (selectedSegmentIndex==0) {
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDial2:) name:@"NNC_Is_Have_Userinfo" object:nil];
        callRecordsVC.receiveUserJID = @"";
        if ([self.view viewWithTag:10001] || [self.view viewWithTag:10002]) {
            [[self.view viewWithTag:10001] removeFromSuperview];
            [[self.view viewWithTag:10002] removeFromSuperview];
        }
        
    }else if(selectedSegmentIndex==1){
        
        //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Is_Have_Userinfo" object:nil];
        if ( [self.view viewWithTag:10002]) {
            [[self.view viewWithTag:10002] removeFromSuperview];
        }
        
        
        [self.view addSubview:callRecordsVC.view];
        
        
    }else{
        // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Is_Have_Userinfo" object:nil];
        if ( [self.view viewWithTag:10001]) {
            [[self.view viewWithTag:10001] removeFromSuperview];
        }
        
        [self.view addSubview:callContactsVC.view];
        
    }
    
}

-(void)deleteNum{
    if (numText.text.length==1) {
        _deleteBut.hidden = YES;
    }
    
    if(![StrUtility isBlankString:numText.text]){
        numText.text= [numText.text substringToIndex:numText.text.length-1];
    }
}

-(void)deleteAllNum{
    if (![StrUtility isBlankString:numText.text]) {
        numText.text = @"";
        _deleteBut.hidden = YES;
    }
}

- (void) textFieldDidChange:(UITextField *) TextField{
    
    if ([numText.text isEqualToString:@""]) {
        if (kIsiPhone6) {
            numText.font=[UIFont fontWithName:@"Helvetica" size:35.0f];
        }else if(kIsiPhone6p){
            numText.font=[UIFont fontWithName:@"Helvetica" size:38.0f];
            
        }else{
            numText.font=[UIFont fontWithName:@"Helvetica" size:32.0f];
            
        }
        
    }
}


- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event

{
    
    //检测到摇动
    NSLog(@"*****%@",@"检测到摇动");
    
}



- (void) motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event

{
    
    //摇动取消
    NSLog(@"*****%@",@"摇动取消");

    
}



- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event

{
    
    //摇动结束
    
    if (event.subtype == UIEventSubtypeMotionShake) {
        
        //something happens
        NSLog(@"*****%@",@"摇动结束");
        //动画结束
        numText.text=@"";
        _deleteBut.hidden = YES;
       
        
    }
    
}
@end
