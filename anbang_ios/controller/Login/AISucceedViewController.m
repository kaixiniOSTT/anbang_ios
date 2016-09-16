//
//  AISucceedViewController.m
//  anbang_ios
//
//  Created by rooter on 15-3-26.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AISucceedViewController.h"
#import "CHAppDelegate.h"
#import "PublicCURD.h"

#import "UserInfo.h"

#import "DejalActivityView.h"

#define Ticks_Label_Tag  1031

@implementation AISucceedViewController {
    
    UIView *mView;
    CGRect  mViewFrame;
    
    UITextField *mNickNameField;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Notification_Load_OK" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupController];
}

- (void)setupController {
    
    UIView *view = [self interfaceView];
    CGPoint center = CGPointMake(Screen_Width / 2, Screen_Height / 2 - 20);
    view.center = center;
    [self.view addSubview:view];
    mView = view;
    
    [self setupNavigationBarTheme];
    
    [self notificationsInitailize];
    
}

- (void)notificationsInitailize {
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(removeActivity) name:@"Notification_Load_OK" object:nil];
//    [defaultCenter addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
//    [defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)note {
    
    NSDictionary *userInfo = note.userInfo;
    CGRect k_frame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGRect v_frame = mView.frame;
    mViewFrame = v_frame;
    CGFloat keyboard_y = k_frame.origin.y;
    CGFloat view_max_y = CGRectGetMaxY(v_frame);
    CGRect rect = v_frame;
    
    if (keyboard_y < view_max_y) {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        
        rect.origin.y -= (view_max_y - keyboard_y);
        mView.frame = rect;
        
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)note {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    mView.frame = mViewFrame;
    
    [UIView commitAnimations];
}


- (void)setupNavigationBarTheme {
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationItem.hidesBackButton = YES;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 20)];
    view.backgroundColor = AB_Red_Color;
    [self.view addSubview:view];
}

- (void)removeActivity
{
    //    [self permissionsAddressBook];//通讯录权限
    //    [self obtainAddressBook];
    
    //数据初始化等待时间
    
    [self performSelector:@selector(loginLoadOK) withObject:nil afterDelay:5];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"Notification_Load_OK" object:nil];
    
}

- (void)loginLoadOK{
    [DejalBezelActivityView removeViewAnimated:YES];
    [[self appDelegate]ui];
}

- (CHAppDelegate *)appDelegate
{
    return (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (UIView *)interfaceView {
    
    CGFloat view_w = Screen_Width - MARGIN_LEFT_RIGHT * 2;
    UIView *view = [[UIView alloc] init];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, view_w, 90);
    imageView.image = [UIImage imageWithName:@"regist_icon_success"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:imageView];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame), view_w, 50);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor colorWithRed:91.0/255.0 green:87.0/255.0 blue:82.0/255.0 alpha:1];//5b5752
    [view addSubview:tipLabel];
    tipLabel.text = [self headerTip];
    
    UILabel *actionLabel = [[UILabel alloc] init];
    actionLabel.frame = CGRectMake(0, CGRectGetMaxY(tipLabel.frame), view_w, 50);
    actionLabel.textAlignment = NSTextAlignmentCenter;
    actionLabel.font = self.isRegisterSucceed ? [UIFont systemFontOfSize:18] : [UIFont systemFontOfSize:10.0];
    actionLabel.textColor = self.isRegisterSucceed ? AB_Red_Color : AB_Gray_Color;
    actionLabel.tag = Ticks_Label_Tag;
    actionLabel.text = [self detailTip];
    [view addSubview:actionLabel];
    mTicksLabel = actionLabel;

    UIButton *reloginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reloginBtn.bounds = CGRectMake(0, 0, 120, 30);
    CGPoint center = CGPointMake(view_w / 2, CGRectGetMaxY(actionLabel.frame) + 30);
    reloginBtn.center = center;
    reloginBtn.backgroundColor = AB_White_Color;
    reloginBtn.titleLabel.font = [UIFont systemFontOfSize:14.5];
    [reloginBtn setTitle:[self bottomButtonTitle] forState:UIControlStateNormal];
    [reloginBtn setTitleColor:AB_Gray_Color forState:UIControlStateNormal];
    reloginBtn.layer.masksToBounds = YES;
    reloginBtn.layer.cornerRadius = 3.0;
    reloginBtn.layer.borderWidth = 0.5;
    reloginBtn.layer.borderColor = Normal_Border_Color.CGColor;
    [reloginBtn addTarget:self action:@selector(bottomButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:reloginBtn];
    mButton = reloginBtn;
    
    CGFloat view_h = CGRectGetMaxY(reloginBtn.frame);
    view.bounds = CGRectMake(0, 0, view_w, view_h);
    
    return view;
}

- (NSString *)headerTip {
    
    return self.isRegisterSucceed ? @"注册成功" : @"重设密码成功，请重新登录";
}

- (NSString *)detailTip {
    
    if (self.isRegisterSucceed) {
        
        if (self.employeeName) {   //Yes 代表是安邦人
            return [NSString stringWithFormat:@"我是安邦人：%@", self.employeeName];
        }
        
    }else {
        
        mTicks = 10;
        mTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(startTicks:)
                                                userInfo:self
                                                 repeats:YES];
        
        return @"页面将在10秒后跳转到登录页面";
    }
    
    return nil;
}

- (NSString *)bottomButtonTitle {
    
    return self.isRegisterSucceed ? @"进入对话" : @"重新登录";
}

- (void)startTicks:(NSTimer *)timer {
    
    --mTicks;
    if (mTicks < 0) {
        [mTimer invalidate];
        [self bottomButtonClicked:nil];
    }
    
    mTicksLabel.text = [NSString stringWithFormat:@"页面将在%d秒后跳转到登录页面", mTicks];
}

- (void)bottomButtonClicked:(UIButton *)sender {
    
    if (self.isRegisterSucceed) {
        
        [self btnLoginClick];
        
    }else {
        
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

- (void)setNickName {
    
    UserInfo *userInfo = [UserInfo loadArchive];
    userInfo.nickName = mNickNameField.text;
    [userInfo save];
    
    /**
     *   <iq type="set">
     *   <query xmlns="http://www.nihualao.com/xmpp/userinfo">
     *   <name>xxx</name>
     *   </query>
     *   </iq>
     */
    
//    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
//    [iq addAttributeWithName:@"type" stringValue:@"set"];
//    [iq addAttributeWithName:@"id" stringValue:@"setName"];
//    
//    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
//    NSXMLElement *name = [NSXMLElement elementWithName:@"name" stringValue:mNickNameField.text];
//    
//    [query addChild:name];
//    [iq addChild:query];
//    
//    [[XMPPServer xmppStream] sendElement:iq];
}

- (BOOL)checkNickNameInput {
    
    return mNickNameField.text.length == 0 ? NO : YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

-(void)btnLoginClick{
    [DejalBezelActivityView activityViewForView:self.view];
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"registeredCount"]);
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"registeredCount"]isEqualToString:@"1"]) {
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"registeredCount"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        NSString* date;
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
        date = [formatter stringFromDate:[NSDate date]];
        [[NSUserDefaults standardUserDefaults]setObject:date forKey:@"firstDate"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        
    }else{
        
        [[NSUserDefaults standardUserDefaults]setObject:@"2" forKey:@"registeredCount"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }
    //[DejalBezelActivityView activityViewForView:self.view];
    
    //    //数据库初始化
    [PublicCURD createDataBase];
    [PublicCURD createAllTable];
    [PublicCURD updateTable];
    [self load_next];
    //连接服务器
    [[XMPPServer sharedServer]connect];
    
    
}

//登录成功加载完数据跳转
-(void)load_next{
    
    
    
    NSTimer *timer;
    int timeInt = 15;
    timer=[NSTimer scheduledTimerWithTimeInterval:timeInt
                                           target:self
                                         selector:@selector(loginReconnection:)
                                         userInfo:nil
                                          repeats:NO];
}


//15秒后未连接
- (void)loginReconnection:(NSTimer *)timer {
    
    if ([XMPPServer sharedServer].isLogin) {
        [timer invalidate];
        timer = nil;
        return;
    }else{
        [[XMPPServer sharedServer]connect];
    }
}



@end
