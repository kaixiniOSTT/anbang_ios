//
//  AKeyRegisteredViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "AKeyRegisteredViewController.h"
#import "RegisteredViewController.h"
#import "CHAppDelegate.h"
#import "LoadingViewController.h"
@interface AKeyRegisteredViewController ()
{
    UITextField *txtFieldName;
    BOOL isRegistered;
    int registeredCount;
}
@end

@implementation AKeyRegisteredViewController
@synthesize prompt = _prompt;
@synthesize userSource = _userSource;

- (CHAppDelegate *)appDelegate
{
    return (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
}
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(load_next) name:@"NSN_Registered_Success" object:nil];
    self.title=@"设置昵称";
    [self ui];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"anonymouss" forKey:@"userName"];
    [defaults setObject:nil forKey:@"password"];
    [defaults synchronize];
    [[XMPPServer sharedServer]connect];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NSN_Registered_Success" object:nil];
    
}
-(void)ui{
    int height;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        height=64;
    }else{
        height=0;
    }
    UIBarButtonItem *btnLeft=[[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(clickLeftButton)];
    [self.navigationItem setLeftBarButtonItem:btnLeft];
    
    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(clickRightButton)];
    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];
    
    txtFieldName=[[UITextField alloc]initWithFrame:CGRectMake(10, height+20, 300, 30)];
    [txtFieldName setBorderStyle:UITextBorderStyleRoundedRect];
    txtFieldName.placeholder=@"输入想好的昵称";
    [self.view addSubview:txtFieldName];
    
    UILabel *promptLabel = [[UILabel alloc]init];
    promptLabel.frame = CGRectMake(30, 130, 280, 80);
    promptLabel.lineBreakMode = UILineBreakModeWordWrap;
    promptLabel.numberOfLines = 0;
    if (_prompt !=nil) {
        promptLabel.text=_prompt;
    }
    
    promptLabel.textColor = [UIColor blackColor];
    //promptLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:promptLabel];
}

-(void)load_next{
    
    LoadingViewController *load=[[LoadingViewController alloc]init];
    [self presentViewController:load animated:YES completion:^{}];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clickLeftButton
{
    RegisteredViewController *registeredView=[[RegisteredViewController alloc]init];
    [self presentViewController:registeredView animated:NO completion:nil];
}

-(void)queryRosterRegister{
    /*
     <iq type=”set” id＝“1”>
     <query xmlns=”http://www.nihualao.com/xmpp/annoymous/register”>
     <name>昵称</name>
     <phone countryCode=”国家码”>绑定的手机号</phone>
     <validateCode>绑定手机号的验证码</validateCode> </query>
     </iq>
     <iq type="set"><query xmlns="http://www.nihualao.com/xmpp/anonymous/register"><name>111</name></query></iq>
     */
    //    NSLog(@"------                                   ------");
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/anonymous/register"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *name=[NSXMLElement elementWithName:@"name" stringValue:txtFieldName.text];
    NSXMLElement *souce=[NSXMLElement elementWithName:@"souce" stringValue:_userSource];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"aKey"];
    
    [queryElement addChild:name];
    [queryElement addChild:souce];
    [iq addChild:queryElement];
    //    NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
}

//进行注册
-(void)clickRightButton{
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults setObject:@"anonymous" forKey:@"userName"];
    //    [defaults setObject:nil forKey:@"password"];
    //    [[XMPPServer sharedServer]connect];
    [self queryRosterRegister];
}

- (IBAction)backgroundTop:(id)sender {
    [txtFieldName resignFirstResponder];
}



-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NSN_Registered_Success" object:nil];
}

@end
