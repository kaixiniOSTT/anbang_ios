//
//  RoyaDialView.m
//  anbang_ios
//
//  Created by seeko on 14-4-23.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "RoyaDialView.h"
#import "RoyaDialViewDelegate.h"
#import "APPRTCViewController.h"
#import "CHAppDelegate.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"

#define CONFIGURE_BUTTON(BTN,X,Y,TITLE,TAG) {\
self.BTN = [UIButton buttonWithType:UIButtonTypeCustom];\
[self.BTN setFrame:CGRectMake(X, Y, widthOfButton, heightOfButton)];\
[self.BTN setShowsTouchWhenHighlighted:YES];\
[self.BTN setTintColor:[UIColor whiteColor]];\
[self.BTN setBackgroundColor:[UIColor darkGrayColor]];\
[self.BTN setTag:TAG];\
[self.BTN addTarget:self action:@selector(onKeyPressed:) \
forControlEvents:UIControlEventTouchUpInside];\
[self addSubview:self.BTN];\
}

#define PULL_DOWN_OFFSET 100.0

#define TAG_KEY_DIAL     111

#define TAG_KEY_UNDO     444


//private
@interface RoyaDialView(private)

-(void)setLayOn:(BOOL) isLayOn;

-(void)handleCall:(NSString *) phoneNum;

@end

@implementation RoyaDialView(private)
-(void)setLayOn:(BOOL)isLayOn
{
    //5s 456  *7-3.5-383
    NSLog(@"----%f",self.frame.size.height);
    if (self.frame.size.height>400) {
        height=15;
        height2=55;
    }else{
        height=-5;
        height2=5;
    }
    CGFloat adjustOffset =self.frame.size.height-90-height;
    if (isLayOn == NO) {
        adjustOffset=self.frame.size.height+140+height2;
        NSLog(@"%f",adjustOffset);
    }
    
    CGPoint center = self.center;
    center.y= adjustOffset;
    self.center = center;
}

@end

//public
@implementation RoyaDialView
@synthesize delegate;
-(id)init
{
    
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDial2:) name:@"NNC_Is_Have_Userinfo" object:nil];
    
    CGRect frame = [[UIScreen mainScreen]applicationFrame];
    frame.size.height /= 1.2;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGFloat heightOfTextField = 30.0;
        CGFloat widthOfButtonOnOff = 50.0;
        self.btnOffOn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnOffOn setFrame:CGRectMake(0, 0, widthOfButtonOnOff, heightOfTextField)];
        [self.btnOffOn setShowsTouchWhenHighlighted:YES];
        [self.btnOffOn setImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateNormal];
        [self.btnOffOn addTarget:self
                          action:@selector(onButtonOnOffPressed:)
                forControlEvents:UIControlEventTouchUpInside];
        self.btnOffOn.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [self addSubview:self.btnOffOn];
        
        self.txtNumber = [[[UITextField alloc]initWithFrame:CGRectMake(self.btnOffOn.frame.size.width + 10,1,frame.size.width - self.btnOffOn.frame.size.width-10,heightOfTextField-1)] autorelease];
        [self.txtNumber setBorderStyle:UITextBorderStyleNone];
        [self.txtNumber setBackgroundColor:[UIColor whiteColor]];
        [self.txtNumber setEnabled:NO];
        [self.txtNumber setPlaceholder:@"拨打iCirCall电话"];
        self.txtNumber.text = @"";
        self.txtNumber.delegate = self;
        [self addSubview:self.txtNumber];
        
        CGFloat heightOfButton = frame.size.height / 5.0 - heightOfTextField;
        CGFloat widthOfButton = frame.size.width / 3.0;
        
        //configure the number key
        CONFIGURE_BUTTON(btn1, 0, heightOfTextField, @"1",1);
        [self.btn1 setBackgroundImage:[UIImage imageNamed:@"dial_num_1_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn2, widthOfButton , heightOfTextField, @"2",2);
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"dial_num_2_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn3, widthOfButton*2, heightOfTextField, @"3",3);
        [self.btn3 setBackgroundImage:[UIImage imageNamed:@"dial_num_3_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn4, 0, heightOfButton + heightOfTextField, @"4",4);
        [self.btn4 setBackgroundImage:[UIImage imageNamed:@"dial_num_4_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn5, widthOfButton, heightOfButton + heightOfTextField, @"5",5);
        [self.btn5 setBackgroundImage:[UIImage imageNamed:@"dial_num_5_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn6, widthOfButton*2, heightOfButton + heightOfTextField, @"6",6);
        [self.btn6 setBackgroundImage:[UIImage imageNamed:@"dial_num_6_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn7, 0, heightOfButton*2 + heightOfTextField, @"7",7);
        [self.btn7 setBackgroundImage:[UIImage imageNamed:@"dial_num_7_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn8, widthOfButton, heightOfButton*2 + heightOfTextField, @"8",8);
        [self.btn8 setBackgroundImage:[UIImage imageNamed:@"dial_num_8_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn9, widthOfButton*2, heightOfButton*2 + heightOfTextField, @"9",9);
        [self.btn9 setBackgroundImage:[UIImage imageNamed:@"dial_num_9_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn0, widthOfButton, heightOfButton*3 + heightOfTextField, @"0",0);
        [self.btn0 setBackgroundImage:[UIImage imageNamed:@"dial_num_11_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn_, 0, heightOfButton*3 + heightOfTextField, @"#",111);
        
        [self.btn_ setBackgroundImage:[UIImage imageNamed:@"dial_num_#_normal.png"]
                             forState:UIControlStateNormal];
        [self.btn_ addTarget:self action:@selector(_btn)forControlEvents:UIControlEventTouchUpInside];
        
        CONFIGURE_BUTTON(btnUndo, widthOfButton*2, heightOfButton*3 + heightOfTextField, @"Undo",TAG_KEY_UNDO);
        [self.btnUndo setBackgroundImage:[UIImage imageNamed:@"dial_num_12_normal.png"]
                                forState:UIControlStateNormal];
        //configure the funcion key
        CONFIGURE_BUTTON(btnDial,0,heightOfButton*4 + heightOfTextField, @"Dial",TAG_KEY_DIAL);
        [self.btnDial addTarget:self
                         action:@selector(playDial)
               forControlEvents:UIControlEventTouchUpInside];
        [self.btnDial setBackgroundImage:[UIImage imageNamed:@"dial_num_10_normal.png"]
                                forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btnDown,widthOfButton,heightOfButton*4 + heightOfTextField, @"Down",TAG_KEY_DIAL);
        [self.btnDown setBackgroundImage:[UIImage imageNamed:@"dial_bar_down.png"]
                                forState:UIControlStateNormal];
        [self.btnDown addTarget:self action:@selector(onButtonOnOffPressed:)forControlEvents:UIControlEventTouchUpInside];
        CONFIGURE_BUTTON(btnVideo,widthOfButton*2,heightOfButton*4 + heightOfTextField, @"Video",TAG_KEY_DIAL);
        [self.btnVideo addTarget:self
                          action:@selector(playVideo)
                forControlEvents:UIControlEventTouchUpInside];
        [self.btnVideo setBackgroundImage:[UIImage imageNamed:@"dial_bar_audio.png"]
                                 forState:UIControlStateNormal];
        
        mIsLayOn = YES;
        [self setLayOn:mIsLayOn];
        self.backgroundColor = [UIColor darkGrayColor];
    }
    return self;
    
}

-(void)_btn{
    self.txtNumber.text=[self.txtNumber.text stringByAppendingString:@"#"];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
-(void)onKeyPressed:(id)sender
{
    NSInteger tag = [sender tag];
    //NSString *tit=[sender title];
    NSString *text = self.txtNumber.text;
    switch (tag) {
        case TAG_KEY_DIAL:
            //            [self handleCall:text];
            break;
        case TAG_KEY_UNDO:
            if (text.length) {
                self.txtNumber.text = [text stringByReplacingCharactersInRange:NSMakeRange(text.length-1, 1)withString:@""];
            }
            break;
        default:
            self.txtNumber.text = [NSString stringWithFormat:@"%@%d",text,tag];
            break;
    }
    if ([self.delegate respondsToSelector:@selector(onDialView:dialNumber:withKey:)]) {
        [self.delegate onDialView:self dialNumber:text withKey:tag];
    }
    [delegate txtNum:self.txtNumber.text];
}

-(void)onButtonOnOffPressed:(id)sender
{
    UIImage *image = [UIImage imageNamed:@"down.png"];
    if (mIsLayOn) {
        image = [UIImage imageNamed:@"up.png"];
    }
    mIsLayOn ? (mIsLayOn = NO) : (mIsLayOn = YES);
    [self.btnOffOn setImage:image forState:UIControlStateNormal];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self setLayOn:mIsLayOn];
    [UIView commitAnimations];
    //    self.txtNumber.text = @"";
}
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
    NSLog(@"开始拨打电话");
    isPhone=YES;
    if (_txtNumber.text.length>0) {
        NSString  * userJID = [_txtNumber.text stringByAppendingFormat:@"@%@",OpenFireHostName];
        [self userinfoRequest:userJID];
        
    }else{
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示" message:@"请输入邦邦社区号码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}


/*-(void)addressbookPhoneNum:(NSNotification *)phoneNum{
 txtPhoneNum.text=[NSString stringWithFormat:@"%@",[phoneNum object]];*/
-(void)playDial2:(NSNotification *)have{
    NSString *isHave=[NSString stringWithFormat:@"%@",[have object]];
    if (isHave!=nil&&![isHave isEqualToString:@"(null)"]) {
        
        if (isPhone==YES) { //语音通话
#if !TARGET_IPHONE_SIMULATOR
            
            NSString  * jid = [_txtNumber.text stringByAppendingFormat:@"@%@",OpenFireHostName];
            //            [CallRecordsCRUD insertCallRecordsMyUserName:myUserName userName:_txtNumber.text callWay:@"呼出音频电话" data:week];
            
            XMPPJID *to = [XMPPJID jidWithString:jid resource:@"Hisuper"];
            if([[VoipModule shareVoipModule]call:to isvideo:false])
            {
                APPRTCViewController *appView = [[APPRTCViewController alloc]init];
                appView.from = [to full];
                appView.isCaller = YES;
                appView.isVideo = NO;

                [self.window.rootViewController presentViewController:appView animated:YES completion:^{
                    
                    //            CHAppDelegate *app = [UIApplication sharedApplication].delegate;
                    CHAppDelegate *app = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
                    app.tabBarBG.hidden = YES;
                    [appView.lbname setText:to.user];
                    appView.ivavatar.layer.masksToBounds = YES;
                    appView.ivavatar.layer.cornerRadius = 3.0;
                    appView.ivavatar.layer.borderWidth = 3.0;
                    appView.ivavatar.backgroundColor = kMainColor4;
                    appView.ivavatar.layer.borderColor = [[UIColor whiteColor]CGColor];
                    
                    NSString *photoImage=[[NSUserDefaults standardUserDefaults]objectForKey:@"NSUD_PhoneImage"];
                    UIImage *image = [UIImage imageNamed:@"NSUD_PhoneImage"];
                    if (![photoImage isEqualToString:@""]) {
                        NSString *photoImageUrl=[NSString stringWithFormat:@"%@/%@",ResourcesURL,photoImage];
                        UIImageView *photoView=[[[UIImageView alloc]initWithFrame:CGRectMake(240, 5, 50, 50)]autorelease];
            
                        [photoView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",photoImageUrl]]
                                       placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
                        
                        
                        if (photoView.image) {
                            [appView.ivavatar setImage:photoView.image];
                        }else{
                            [appView.ivavatar setImage:image];
                        }
                    }else{
                        [appView.ivavatar setImage:image];
                        
                    }
                }];
                [appView release];
            }
            else
            {
                [self showAlert:@"呼叫失败"];
            }
            
#endif
        }else{  //视频通话
            
#if !TARGET_IPHONE_SIMULATOR
            
            NSString  * jid = [_txtNumber.text stringByAppendingFormat:@"@%@",OpenFireHostName];
            //            [CallRecordsCRUD insertCallRecordsMyUserName:myUserName userName:_txtNumber.text callWay:@"呼出视频电话" data:week];
            
            XMPPJID *to = [XMPPJID jidWithString:jid resource:@"Hisuper"];
            if( [[VoipModule shareVoipModule]call:to isvideo:true])
            {
                APPRTCViewController *appView = [[APPRTCViewController alloc]init];
                appView.from = [to full];
                appView.isCaller = YES;
                appView.isVideo = YES;
                [self.window.rootViewController presentViewController:appView animated:YES completion:^{
                    
                    CHAppDelegate *app = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
                    app.tabBarBG.hidden = YES;
                    [appView.lbname setText:to.user];
                    appView.ivavatar.layer.masksToBounds = YES;
                    appView.ivavatar.layer.cornerRadius = 3.0;
                    appView.ivavatar.layer.borderWidth = 3.0;
                    appView.ivavatar.backgroundColor = kMainColor4;
                    appView.ivavatar.layer.borderColor = [[UIColor whiteColor]CGColor];
                    
                    NSString *photoImage=[[NSUserDefaults standardUserDefaults]objectForKey:@"NSUD_PhoneImage"];
                    UIImage *image = [UIImage imageNamed:@"defaultUser.png"];
                    if (![photoImage isEqualToString:@""]) {
                        NSString *photoImageUrl=[NSString stringWithFormat:@"%@/%@",ResourcesURL,photoImage];
                        UIImageView *photoView=[[[UIImageView alloc]initWithFrame:CGRectMake(240, 5, 50, 50)]autorelease];
                        
                        [photoView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",photoImageUrl]]
                                       placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
                        if (photoView.image) {
                            [appView.ivavatar setImage:photoView.image];
                        }else{
                            [appView.ivavatar setImage:image];
                        }
                    }else{
                        [appView.ivavatar setImage:image];
                        
                    }
                }];
                //[appView release];
            }
            else
            {
                
                [self showAlert:@"呼叫失败"];
            }
            
#endif
            
        }
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示" message:@"您拨打的邦邦社区号码不存在" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
    self.txtNumber.text=@"";
    [delegate txtNum:self.txtNumber.text];
  
}

//开视频
-(void)playVideo{
    NSLog(@"开始语音视频");
    isPhone=NO;
    if (_txtNumber.text.length>0) {
        NSString  * userJID = [_txtNumber.text stringByAppendingFormat:@"@%@",OpenFireHostName];
        [self userinfoRequest:userJID];
        
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示" message:@"请输入邦邦社区号码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}
-(void)showAlert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
}
-(void)dealloc
{
    //[self.btn0 release];
    //[self.btn1 release];
    //[self.btn2 release];
    //[self.btn3 release];
    //[self.btn4 release];
    //[self.btn5 release];
    // [self.btn6 release];
    //[self.btn7 release];
    // [self.btn8 release];
    //[self.btn9 release];
    //[self.btnDial release];
    //[self.btnUndo release];
    //[self.btn_ release];
    //[self.btnVideo release];
    //[self.btnDown release];
    // [self.txtNumber release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Is_Have_Userinfo" object:nil];

    [super dealloc];
}

-(void)showInView:(UIView *)view
{
    CGPoint center = self.center;
    //    center.y =(self.frame.size.height - self.txtNumber.frame.size.height)/2.0 + 120;
    self.center = center;
    [view addSubview:self];
    NSLog(@"%f",view.frame.size.height);
}
-(void)showNum:(NSString *)num{
    self.txtNumber.text=num;
}

#pragma Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    mIsLayOn ? (mIsLayOn = YES) : (mIsLayOn = NO);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self setLayOn:mIsLayOn];
    [UIView commitAnimations];
    //    self.txtNumber.text = @"";
}

@end