//
//  PhoneNumCodeViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-28.
//  Copyright (c) 2014年 ch. All rights reserved.
//  手机注册验证码

#import "PhoneNumCodeViewController.h"
#import "PhoneNumRegisteredViewController.h"
#import "CHAppDelegate.h"
#import "LoadingViewController.h"
#import "PhoneNumRegisteredNameViewController.h"
@interface PhoneNumCodeViewController ()
{
    int heightdvi;
    UILabel *labPhoneNum;
    UITextField *txtCode;
    int i;
    UIButton *button;
    NSTimer *timer;
    UIButton *lab;
    UILabel *count;
}
@end

@implementation PhoneNumCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self ui];
    
}

-(void)ui{
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        heightdvi=64;
    }else{
        heightdvi=0;
    }
    //验证码
    self.title=NSLocalizedString(@"phoneNumRegistered.verificationCode.title",@"title");
    //下一步
    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"phoneNumRegistered.nextStep",@"action") style:UIBarButtonItemStylePlain target:self action:@selector(queryRosterPhoneNumCode)];
    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(10, heightdvi-20, KCurrWidth-20, 20)];
    //我们已经发送了验证码给您的手机
    label.text=NSLocalizedString(@"phoneNumRegistered.verificationCode.tableTitle",@"title");
    label.font=[UIFont boldSystemFontOfSize:14];
    label.lineBreakMode=NSLineBreakByCharWrapping;
    label.numberOfLines=0;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    labPhoneNum=[[UILabel alloc]initWithFrame:CGRectMake(10, heightdvi, KCurrWidth-10, 20)];
    labPhoneNum.text=[[NSUserDefaults standardUserDefaults]stringForKey:@"phonenum"];
    labPhoneNum.font=[UIFont boldSystemFontOfSize:14];
    labPhoneNum.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labPhoneNum];
    
    txtCode=[[UITextField alloc]initWithFrame:CGRectMake(15, heightdvi+40, KCurrWidth-20, 45)];
    //请输入验证码
    txtCode.placeholder=NSLocalizedString(@"phoneNumRegistered.verificationCode.enterVerificationCode",@"title");
    [txtCode setKeyboardType:UIKeyboardTypeNumberPad];
    txtCode.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtCode.delegate=self;
    txtCode.textAlignment = NSTextAlignmentCenter;
    [txtCode becomeFirstResponder] ;
    
    UIImageView *textFileldLineView = [[UIImageView alloc]initWithFrame:CGRectMake(10, txtCode.frame.origin.y+45, KCurrWidth-20, 1)];
    textFileldLineView.image = [UIImage imageNamed:@"textfield_ bottom.png"];
    [self.view addSubview:textFileldLineView];
    
    
    [self.view addSubview:txtCode];
    
    i=60;
    timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerSendPhoneNume) userInfo:self repeats:YES];
    button=[UIButton buttonWithType:UIButtonTypeSystem];
    
    CGSize butSize = [NSLocalizedString(@"phoneNumRegistered.verificationCode.receiveInformation",@"title") sizeWithAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:12]}];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"NSUD_language"] isEqualToString:@"en"]) {
        button.frame=CGRectMake((KCurrWidth-butSize.width-80)/2, heightdvi+110, butSize.width+60, 30);
        count=[[UILabel alloc]initWithFrame:CGRectMake(butSize.width+55, 0, 20, 30)];
        
    }else{
        button.frame=CGRectMake((KCurrWidth-butSize.width-80)/2, heightdvi+110, butSize.width+60, 30);
        count=[[UILabel alloc]initWithFrame:CGRectMake(butSize.width+40, 0, 20, 30)];
        
    }
    //    [button setTitle:[NSString stringWithFormat:@"接收信息中%d秒",i] forState:UIControlStateNormal];
    //接收信息中
    [button setTitle:NSLocalizedString(@"phoneNumRegistered.verificationCode.receiveInformation",@"title") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.view addSubview:button];
    
    [count setTextColor:[UIColor colorWithRed:0 green:0.5 blue:1.0 alpha:1.0]];
    count.text=[NSString stringWithFormat:@"%d",i];
    [button addSubview:count];
    
    lab=[UIButton buttonWithType:UIButtonTypeCustom];
    lab.frame=CGRectMake(KCurrWidth-240, heightdvi+125, butSize.width, 40);
    [self.view addSubview:lab];
}

-(void)timerSendPhoneNume{
    i--;
    //    [button setTitle:[NSString stringWithFormat:@"接收信息中%d秒",i] forState:UIControlStateNormal];
    count.text=[NSString stringWithFormat:@"%d",i];
    if (i==0) {
        //[timer invalidate];
        //关闭定时器
        [timer setFireDate:[NSDate distantFuture]];
        //重新获取验证码
        CGSize butSize = [NSLocalizedString(@"phoneNumRegistered.verificationCode.resend",@"title") sizeWithAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:12]}];
        button.frame=CGRectMake((KCurrWidth-butSize.width-80)/2, heightdvi+110, butSize.width+60, 30);
        [button setTitle:NSLocalizedString(@"phoneNumRegistered.verificationCode.resend",@"action") forState:UIControlStateNormal];
        count.alpha=0;
        lab.frame=CGRectMake(70, heightdvi+250, 110, 40);
    }
}


//重新请求发送验证码
-(void)buttonClick{
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/anonymous/phone/validate"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:[[NSUserDefaults standardUserDefaults]stringForKey:@"phonenum"]];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"phonenum"];
    [phone addAttributeWithName:@"countryCode" stringValue:[[NSUserDefaults standardUserDefaults]stringForKey:@"countrycode"]];
    [queryElement addChild:phone];
    [iq addChild:queryElement];
    [[XMPPServer xmppStream] sendElement:iq];
    lab.frame=CGRectMake(55, heightdvi+250, 210, 40);
    i=60;
    //开启定时器
    [timer setFireDate:[NSDate distantPast]];
    count.alpha=1;
    CGSize butSize = [NSLocalizedString(@"phoneNumRegistered.verificationCode.receiveInformation",@"title") sizeWithAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:12]}];
    button.frame=CGRectMake((KCurrWidth-butSize.width-80)/2, heightdvi+110, butSize.width+60, 30);
    //接收信息中
    [button setTitle:NSLocalizedString(@"phoneNumRegistered.verificationCode.receiveInformation",@"title") forState:UIControlStateNormal];
    
    // timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerSendPhoneNume) userInfo:self repeats:YES];
    
}



-(void)validateCode
{
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"validate_code"];
    XMPPElement *query = [XMPPElement elementWithName:@"query" URI:@"http://www.nihualao.com/xmpp/anonymous/phone/validateCode"];
    XMPPElement *phone = [XMPPElement elementWithName:@"phone" stringValue:[[NSUserDefaults standardUserDefaults]stringForKey:@"phonenum"]];
    [phone addAttributeWithName:@"countryCode" stringValue:[[NSUserDefaults standardUserDefaults]stringForKey:@"countrycode"]];
    XMPPElement *validateCode  = [XMPPElement elementWithName:@"validateCode" stringValue:txtCode.text];
    [query addChild:phone];
    [query addChild:validateCode];
    [iq addChild:query];
    //NSLog(@"****%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    //NSLog(@"fighting:%@",iq);
    
}


-(void)actionNotify:(NSNotification *)notify
{
    //NSLog(@"NODI:%@",notify.object);
    NSMutableDictionary * dic = (NSMutableDictionary*)notify.object;
    if (dic==nil) {
        return;
    }
    if ([@"yes" isEqualToString:[dic objectForKey:@"validate"]] ) {
        PhoneNumRegisteredNameViewController *phoneNumRegisteredNameme=[[PhoneNumRegisteredNameViewController alloc]init];
        phoneNumRegisteredNameme.strphoneNum=[[NSUserDefaults standardUserDefaults]stringForKey:@"phonenum"];
        phoneNumRegisteredNameme.strCode=txtCode.text;
        [self.navigationController pushViewController:phoneNumRegisteredNameme animated:YES];
    }
    else
    {
        NSString *text = [dic objectForKey:@"text"];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:text delegate:nil cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
        [alertView show];
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"validate_code" object:nil];
    
}


//发送手机号码和验证码进行注册
-(void)queryRosterPhoneNumCode{
    if (txtCode.text.length<1) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"phoneNumRegistered.verificationCode.enterVerificationCode",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.prompt",@"title") otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionNotify:) name:@"validate_code" object:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self validateCode];
            
        });
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [timer invalidate];
    PhoneNumRegisteredNameViewController *phoneNumRegisteredNameme=[[PhoneNumRegisteredNameViewController alloc]init];
    [self.navigationController pushViewController:phoneNumRegisteredNameme animated:YES];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)backgroundTop:(id)sender{
    [txtCode resignFirstResponder];
}

-(void)dealloc{
    
}
@end
