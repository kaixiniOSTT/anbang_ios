//
//  PhoneNumValidationViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-29.
//  Copyright (c) 2014年 ch. All rights reserved.
//
//  手机找回密码验证码

#import "PhoneNumValidationViewController.h"
#import "LoginViewController.h"
#import "CHAppDelegate.h"
#import "PublicCURD.h"
#import "DejalActivityView.h"
@interface PhoneNumValidationViewController ()
{
    UIButton *button;
    NSTimer *timer;
    int countDownTime;
    UIButton *lab;
    int heightdvi;
    UILabel *count;
}
@end
@implementation PhoneNumValidationViewController
@synthesize tableView = _tableView;
@synthesize countryCode = _countryCode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"passwordBackSuccess" object:nil];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(verificationSuccess) name:@"passwordBackSuccess" object:nil];
    
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        heightdvi=64;
    }else{
        heightdvi=0;
    }
    
    //验证码
    self.title = NSLocalizedString(@"forgetPassword.phone.verificationCode.title",@"title");
    _tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollsToTop = YES;
    [self.view addSubview:_tableView];
    //[_tableView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
    [self setExtraCellLineHidden:_tableView];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [_tableView setSeparatorInset:(UIEdgeInsetsMake(0, 0, 0, 0))];
    }
    
    //确定
    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"public.nav.ok",@"title") style:UIBarButtonItemStylePlain target:self action:@selector(queryValidationPhoneNumCode)];
    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];
    
    
    textFieldVerificationCode = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, 280, 50)];
    
    [self countDown];
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
}


- (void)countDown{
    
    countDownTime=60;
    timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerSendPhoneNume) userInfo:self repeats:YES];
    button=[UIButton buttonWithType:UIButtonTypeSystem];
    CGSize butSize = [NSLocalizedString(@"phoneNumRegistered.verificationCode.receiveInformation",@"title") sizeWithAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:12]}];
    button.frame=CGRectMake((KCurrWidth-butSize.width-40)/2, heightdvi+80, butSize.width+30, 30);
    //接收信息中
    [button setTitle:NSLocalizedString(@"forgetPassword.phone.verificationCode.receiveInformation",@"title") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    count=[[UILabel alloc]initWithFrame:CGRectMake(butSize.width+25, 0, 20, 30)];
    [count setTextColor:[UIColor colorWithRed:0 green:0.5 blue:1.0 alpha:1.0]];
    count.text=[NSString stringWithFormat:@"%d",countDownTime];
    [button addSubview:count];
    lab=[UIButton buttonWithType:UIButtonTypeCustom];
    lab.frame=CGRectMake(55, heightdvi+125, 210, 40);
    [self.view addSubview:lab];
    
}


//-(void)ui{
//    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
//        heightdvi=64;
//    }else{
//        heightdvi=0;
//    }
//    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(queryValidationPhoneNumCode)];
//    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];
//
//    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(20, heightdvi+10, 260, 20)];
//    label.text=@"我们已经发送了验证码给您的手机：";
//    label.font=[UIFont fontWithName:nil size:14];
//    [self.view addSubview:label];
//    labPhoneNum=[[UILabel alloc]initWithFrame:CGRectMake(40, heightdvi+30, 220, 20)];
//    labPhoneNum.text=[[NSUserDefaults standardUserDefaults]stringForKey:@"phonenum"];
//    //拿到值删除数据
//    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"phonenum"];
//    [[NSUserDefaults standardUserDefaults]synchronize];
//
//    labPhoneNum.font=[UIFont fontWithName:nil size:14];
//    [self.view addSubview:labPhoneNum];
//    txtCode=[[UITextField alloc]initWithFrame:CGRectMake(15, heightdvi+50, 290, 40)];
//    txtCode.placeholder=@"请输入验证码";
//    [txtCode setBorderStyle:UITextBorderStyleRoundedRect];
//    [txtCode setKeyboardType:UIKeyboardTypePhonePad];
//    [txtCode becomeFirstResponder];
//    [self.view addSubview:txtCode];
//
//    [label release];
//    i=60;
//    timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerSendPhoneNume) userInfo:self repeats:YES];
//    button=[UIButton buttonWithType:UIButtonTypeSystem];
//    button.frame=CGRectMake(60, heightdvi+130, 200, 30);
//    [button setTitle:@"接收信息中      秒" forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
//    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
//    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.view addSubview:button];
//    count=[[UILabel alloc]initWithFrame:CGRectMake(120, 0, 20, 30)];
//    [count setTextColor:[UIColor colorWithRed:0 green:0.5 blue:1.0 alpha:1.0]];
//    count.text=[NSString stringWithFormat:@"%d",i];
//    [button addSubview:count];
//    [count release];
//    lab=[UIButton buttonWithType:UIButtonTypeCustom];
//    lab.frame=CGRectMake(55, heightdvi+125, 210, 40);
//    [self.view addSubview:lab];
//
//}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ([cell viewWithTag:10001]) {
        [[cell viewWithTag:10001] removeFromSuperview];
    }
    
    if (indexPath.row==0) {
        //我们已经发送了验证码给您的手机
        cell.textLabel.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"forgetPassword.phone.verificationCode.tableViewTitle",@"title"),[[NSUserDefaults standardUserDefaults]stringForKey:@"NSUD_phonenum"]];
        cell.textLabel.numberOfLines = 0;
        
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.frame = CGRectMake(0 , 0, 300, 50);
        cell.textLabel.numberOfLines =0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        
        
        
    }else if(indexPath.row==1){
        
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        [textFieldVerificationCode setKeyboardType:UIKeyboardTypeEmailAddress];
        textFieldVerificationCode.clearButtonMode = UITextFieldViewModeWhileEditing;
        //验证码
        [textFieldVerificationCode setPlaceholder:NSLocalizedString(@"forgetPassword.phone.verificationCode.verificationCode",@"title")];
        //设置字体颜色
        textFieldVerificationCode.textColor = [UIColor blueColor];
        textFieldVerificationCode.font = [UIFont fontWithName:@"Helvetica" size:22.0f];
        [textFieldVerificationCode becomeFirstResponder ];
        [cell addSubview:textFieldVerificationCode];
        cell.layer.borderWidth = 0;
        
        
    }else if(indexPath.row==2){
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        
    }else{
        
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}


//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 55;
    }else if (indexPath.row==2) {
        return 15;
    }else if(indexPath.row==3){
        return 40;
    }else{
        return 50;
    }
}


- (void)LoginButtonTouchDown{
    btnLogin.backgroundColor = kMainColor5;
}




-(void)timerSendPhoneNume{
    countDownTime--;
    count.text=[NSString stringWithFormat:@"%d",countDownTime];
    if (countDownTime==0) {
        //关闭定时器
        [timer setFireDate:[NSDate distantFuture]];
        //重新获取验证码
        [button setTitle:NSLocalizedString(@"forgetPassword.phone.verificationCode.resend",@"title") forState:UIControlStateNormal];
        count.alpha=0;
        lab.frame=CGRectMake(55, heightdvi+210, 110, 40);
    }
}
//重新请求发送验证码
-(void)buttonClick{
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/anonymous/phone/validate"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:[[NSUserDefaults standardUserDefaults]stringForKey:@"NSUD_phonenum"]];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"phonenum"];
    [phone addAttributeWithName:@"countryCode" stringValue:[[NSUserDefaults standardUserDefaults]stringForKey:@"NSUD_countryCode"]];
    [queryElement addChild:phone];
    [iq addChild:queryElement];
    //NSLog(@"*******%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    lab.frame=CGRectMake(55, heightdvi+95, 210, 40);
    countDownTime=60;
    //开启定时器
    [timer setFireDate:[NSDate distantPast]];
    count.alpha=1;
    //接收信息中
    CGSize butSize = [NSLocalizedString(@"phoneNumRegistered.verificationCode.receiveInformation",@"title") sizeWithAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:12]}];
    button.frame=CGRectMake((KCurrWidth-butSize.width-40)/2, heightdvi+80, butSize.width+30, 30);
    [button setTitle:NSLocalizedString(@"forgetPassword.phone.verificationCode.receiveInformation",@"title") forState:UIControlStateNormal];
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//发送发送手机号码＋验证码
-(void)queryValidationPhoneNumCode{
    /*
     <iq type=”set”>￼￼
     <query xmlns=”http://www.nihualao.com/xmpp/anonymous/phone/validate”>
     <phone countryCode=”国家码”>手机号</phone>
     </query>
     </iq>
     */
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/anonymous/auth"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:[[NSUserDefaults standardUserDefaults]stringForKey:@"NSUD_phonenum"]];
    NSXMLElement *code=[NSXMLElement elementWithName:@"validateCode" stringValue:textFieldVerificationCode.text];
    [phone addAttributeWithName:@"countryCode" stringValue:_countryCode];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"pswPhoneNumCode"];
    [queryElement addChild:phone];
    [queryElement addChild:code];
    [iq addChild:queryElement];
    // NSLog(@"******%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
}

-(void)sendRequset{
    
}
-(void)verificationSuccess{
    
    NSString *username=[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    NSString *password=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    //用户名密码
    //    NSString *name_psd=[NSString stringWithFormat:@"%@:%@ %@:%@",NSLocalizedString(@"public.userName",@"title"),NSLocalizedString(@"public.password",@"title"),username,password];
    //    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"" message:name_psd delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"public.logBackIn",@"title"), nil];
    //    [alertView show];
    //    [alertView release];
    //    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"password"];
    //    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [DejalBezelActivityView activityViewForView:self.view];
    [textFieldVerificationCode resignFirstResponder];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username forKey:@"userName"];
    [defaults setObject:password forKey:@"password"];
    [defaults synchronize];//保存
    //数据库初始化
    [PublicCURD createDataBase];
    [PublicCURD createAllTable];
    [PublicCURD updateTable];
    
    [[XMPPServer sharedServer]connect];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    LoginViewController *loginView=[[LoginViewController alloc]init];
    [self.navigationController pushViewController:loginView animated:YES];
}


-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"passwordBackSuccess" object:nil];
}

@end
