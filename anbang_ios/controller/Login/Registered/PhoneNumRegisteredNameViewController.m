//
//  PhoneNumRegisteredNameViewController.m
//  anbang_ios
//
//  Created by seeko on 14-5-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "PhoneNumRegisteredNameViewController.h"
#import "LoadingViewController.h"
#import "XMPPServer+Add.h"
#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface PhoneNumRegisteredNameViewController ()

@end

@implementation PhoneNumRegisteredNameViewController
@synthesize strphoneNum;
@synthesize strCode;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registeredSuccess) name:@"NSN_Registered_Success" object:nil];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"phoneNumRegistered.nickname.title",@"title");
    int heightdvi;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        heightdvi=64;
    }else{
        heightdvi=0;
    }
    //下一步
    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"public.nextStep",@"action") style:UIBarButtonItemStylePlain target:self action:@selector(registeredRequset)];
    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];
    txtNickname=[[UITextField alloc]initWithFrame:CGRectMake(10, 45, KCurrWidth-20, 45)];
    [txtNickname setReturnKeyType:UIReturnKeyNext];
    //输入昵称
    txtNickname.placeholder=NSLocalizedString(@"phoneNumRegistered.nickname.inputTitle",@"title");
    txtNickname.delegate=self;
    txtNickname.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtNickname.textAlignment = NSTextAlignmentCenter;
    [txtNickname becomeFirstResponder];
    
    UIImageView *textFileldLineView = [[UIImageView alloc]initWithFrame:CGRectMake(10, txtNickname.frame.origin.y+45, KCurrWidth-20, 1)];
    textFileldLineView.image = [UIImage imageNamed:@"textfield_ bottom.png"];
    
    
    [self.view addSubview:textFileldLineView];
    [self.view addSubview:txtNickname];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//发送手机号码注册请求
-(void)registeredRequset{
    if (txtNickname.text.length>0) {
        if (txtNickname.text.length<13) {
            NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/anonymous/register"];
            NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
            NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:strphoneNum];
            NSXMLElement *code=[NSXMLElement elementWithName:@"validateCode" stringValue:strCode];
            NSXMLElement *nickname=[NSXMLElement elementWithName:@"name" stringValue:txtNickname.text];
            [phone addAttributeWithName:@"countryCode" stringValue:[[NSUserDefaults standardUserDefaults]stringForKey:@"countrycode"]];
            [iq addAttributeWithName:@"type" stringValue:@"set"];
            [iq addAttributeWithName:@"id" stringValue:@"phoneNumCode"];
            [queryElement addChild:nickname];
            [queryElement addChild:phone];
            [queryElement addChild:code];
            [iq addChild:queryElement];
            [[XMPPServer xmppStream] sendElement:iq];
            


        }else{
            //昵称太长
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"public.maximum",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
            [alert show];
        }
    }else{
        //昵称不能为空
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"phoneNumRegistered.nickname.nicknameNotEmpty",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"message") otherButtonTitles:nil, nil];
        [alert show];
    }
    
}


-(void)registeredSuccess{
    LoadingViewController *load=[[LoadingViewController alloc]init];
    //    [self presentModalViewController:load animated:YES];
    [self presentViewController:load animated:YES completion:^{}];

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self registeredRequset];
    return YES;
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NSN_Registered_Success" object:nil];
}
@end
