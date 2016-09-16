//
//  PhoneNumBindingCodeViewController.m
//  anbang_ios
//
//  Created by seeko on 14-4-3.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "PhoneNumBindingCodeViewController.h"
#import "CHAppDelegate.h"
#import "InformationViewController.h"
@interface PhoneNumBindingCodeViewController ()
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

@implementation PhoneNumBindingCodeViewController
- (CHAppDelegate *)appDelegate
{
    return (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindingSuccess) name:@"bindingPhone_ok" object:nil];
    }
    return self;
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"bindingPhone_ok" object:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self ui];
}

-(void)ui{
    
    self.title=NSLocalizedString(@"personalInformation.bindingPhoneNumberVerificationCode.title",@"title");
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        //self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
        
        heightdvi=0;
        
    }else{
        heightdvi=0;
    }
    
    
    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"public.alert.ok",@"title") style:UIBarButtonItemStylePlain target:self action:@selector(queryBindPhoneNumCode)];
    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(20, heightdvi+10, 280, 40)];
    label.text=NSLocalizedString(@"personalInformation.bindingPhoneNumberVerificationCode.tableTitle",@"title");
    label.font=[UIFont fontWithName:@"Arial-BoldItalicMT" size:14];
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.numberOfLines = 0;
    [self.view addSubview:label];
    labPhoneNum=[[UILabel alloc]initWithFrame:CGRectMake(20, heightdvi+50, 220, 20)];
    labPhoneNum.text=[[NSUserDefaults standardUserDefaults]stringForKey:@"phonenum"];
    labPhoneNum.font=[UIFont fontWithName:@"Arial-BoldItalicMT" size:14];
    [self.view addSubview:labPhoneNum];
    txtCode=[[UITextField alloc]initWithFrame:CGRectMake(15, heightdvi+70, 290, 35)];
    txtCode.placeholder=NSLocalizedString(@"personalInformation.bindingPhoneNumberVerificationCode.enterVerificationCode",@"title");
    
    [txtCode setBorderStyle:UITextBorderStyleRoundedRect];
    [txtCode setKeyboardType:UIKeyboardTypePhonePad];
    [txtCode becomeFirstResponder];
    [self.view addSubview:txtCode];
    i=60;
    timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerSendPhoneNume) userInfo:self repeats:YES];
    button=[UIButton buttonWithType:UIButtonTypeSystem];
    button.frame=CGRectMake(60, heightdvi+120, 200, 30);
    [button setTitle:NSLocalizedString(@"personalInformation.bindingPhoneNumberVerificationCode.receivingInformation",@"title") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldItalicMT" size:14]];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    [button.layer setBorderWidth:1.0]; //边框宽度
    [self.view addSubview:button];
    lab=[UIButton buttonWithType:UIButtonTypeCustom];
    lab.frame=CGRectMake(55, heightdvi+95, 210, 40);
    [self.view addSubview:lab];
    count=[[UILabel alloc]initWithFrame:CGRectMake(90, 0, 20, 30)];
    [count setTextColor:[UIColor colorWithRed:0 green:0.5 blue:1.0 alpha:1.0]];
    count.text=[NSString stringWithFormat:@"%d",i];
    [button addSubview:count];
    
}

-(void)timerSendPhoneNume{
    i--;
    count.text=[NSString stringWithFormat:@"%d",i];
    if (i==0) {
        //关闭定时器
        [timer setFireDate:[NSDate distantFuture]];
        count.alpha=0;
        [button setTitle:NSLocalizedString(@"personalInformation.bindingPhoneNumberVerificationCode.resend",@"action") forState:UIControlStateNormal];
        [button setTitle:NSLocalizedString(@"personalInformation.bindingPhoneNumberVerificationCode.resend",@"action") forState:UIControlStateHighlighted];
        lab.frame=CGRectMake(55, heightdvi+210, 110, 40);
    }
}

-(void)buttonClick{
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/anonymous/phone/validate"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:labPhoneNum.text];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"phoneNum"];
    [phone addAttributeWithName:@"countryCode" stringValue:[[NSUserDefaults standardUserDefaults]stringForKey:@"countryCode"]];
    [queryElement addChild:phone];
    [iq addChild:queryElement];
    [[XMPPServer xmppStream] sendElement:iq];
    // NSLog(@"***%@",iq);
    lab.frame=CGRectMake(55, heightdvi+95, 210, 40);
    i=60;
    //开启定时器
    [timer setFireDate:[NSDate distantPast]];
    count.alpha=1;
    [button setTitle:@"" forState:UIControlStateNormal];
    
    timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerSendPhoneNume) userInfo:self repeats:YES];
}

//发送手机号码和验证码进行绑定
-(void)queryBindPhoneNumCode{
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/phone/bind"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:labPhoneNum.text];
    NSXMLElement *code=[NSXMLElement elementWithName:@"validateCode" stringValue:txtCode.text];
    [phone addAttributeWithName:@"countryCode" stringValue:[[NSUserDefaults standardUserDefaults]stringForKey:@"countryCode"]];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"phonenumbinding"];
    [queryElement addChild:phone];
    [queryElement addChild:code];
    [iq addChild:queryElement];
    // NSLog(@"***%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
-(void)bindingSuccess{
    [timer invalidate];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"bindingPhone_ok" object:nil];
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"personalInformation.bindingPhoneNumberVerificationCode.bindingSuccess",@"message") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles: nil];
    alertView.tag=1020;
    [alertView show];
}
//-(IBAction)backgroundTop:(id)sender{
//    [txtCode resignFirstResponder];
//}
-(void)load_next{
    [timer invalidate];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"bindingPhone_ok" object:nil];
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"personalInformation.bindingPhoneNumberVerificationCode.bindingSuccess",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
    [alert show];
}
#pragma mark UIAlearView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1020) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-3] animated:YES];
    }
}


@end
