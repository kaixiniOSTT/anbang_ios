//
//  ToProblemViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-28.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "ToProblemViewController.h"
#import "FKRHeaderSearchBarTableViewController.h"
#import "ToAnswerViewController.h"
#import "CHAppDelegate.h"
@interface ToProblemViewController ()
{
    UIView *codeView;
    UITextField *txtPhoneNum;
    UITextField *txtID;
    UITextField *txtEmail;
    NSInteger count;
}
@end

@implementation ToProblemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self ui];
}

-(void)ui{
    int height;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        height=64;
    }else{
        height=0;
    }
    
    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextStep)];
    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"手机",@"I D",@"邮箱",nil];
    segmentedBackPassword=[[UISegmentedControl alloc]initWithItems:segmentedArray];
    segmentedBackPassword.frame=CGRectMake(-3, 0, 325, 30);
    [self.view addSubview:segmentedBackPassword];
    segmentedBackPassword.selectedSegmentIndex = 0;
    [segmentedBackPassword addTarget:self
                              action:@selector(chooseWay:)
                    forControlEvents:UIControlEventValueChanged];
    phoneNumView=[[UIView alloc]initWithFrame:CGRectMake(0, height+60, 320,80)];
    [self.view addSubview:phoneNumView];
    //***************************************
    codeView=[[UIView alloc]initWithFrame:CGRectMake(10, 10, 300, 30)];
    codeView.backgroundColor=[UIColor grayColor];
    [phoneNumView addSubview:codeView];
    btnCode=[[UIButton alloc]initWithFrame:CGRectMake(1, 1, 80, 28)];
    btnCode.backgroundColor=[UIColor whiteColor];
    [btnCode addTarget:self action:@selector(clickCodeButton) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(arraycode:) name:@"arraycode" object:nil];
    [btnCode setTitle:@"86" forState:UIControlStateNormal];
    
    [btnCode setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [codeView addSubview:btnCode];
    btnCountries=[[UIButton alloc]initWithFrame:CGRectMake(82, 1, 217, 28)];
    btnCountries.backgroundColor=[UIColor whiteColor];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(arrayname:) name:@"arrayname" object:nil];
    
    [btnCountries setTitle:@"中国" forState:UIControlStateNormal];
    [btnCountries setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [btnCountries addTarget:self action:@selector(clickCodeButton) forControlEvents:UIControlEventTouchUpInside];
    [codeView addSubview:btnCountries];
    //***************************************
    txtPhoneNum=[[UITextField alloc]initWithFrame:CGRectMake(10, 60, 300, 30)];
    [txtPhoneNum setBorderStyle:UITextBorderStyleRoundedRect];
    txtPhoneNum.placeholder=@"请输入手机号码";
    [[NSUserDefaults standardUserDefaults]setObject:txtPhoneNum.text forKey:@"phoneNum"];
    [[NSUserDefaults standardUserDefaults]superclass];
    [phoneNumView addSubview:txtPhoneNum];
    count=[phoneNumView.subviews count];

}
-(void)uiPhoneNum{
    for(int i = 0;i<count;i++){
        [ [ phoneNumView.subviews objectAtIndex:0] removeFromSuperview];
    }
    //***************************************
    codeView=[[UIView alloc]initWithFrame:CGRectMake(10, 10, 300, 30)];
    codeView.backgroundColor=[UIColor grayColor];
    [phoneNumView addSubview:codeView];
    btnCode=[[UIButton alloc]initWithFrame:CGRectMake(1, 1, 80, 28)];
    btnCode.backgroundColor=[UIColor whiteColor];
    [btnCode addTarget:self action:@selector(clickCodeButton) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(arraycode:) name:@"arraycode" object:nil];
    [btnCode setTitle:@"86" forState:UIControlStateNormal];
    
    [btnCode setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [codeView addSubview:btnCode];
    btnCountries=[[UIButton alloc]initWithFrame:CGRectMake(82, 1, 217, 28)];
    btnCountries.backgroundColor=[UIColor whiteColor];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(arrayname:) name:@"arrayname" object:nil];
    
    [btnCountries setTitle:@"中国" forState:UIControlStateNormal];
    [btnCountries setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [btnCountries addTarget:self action:@selector(clickCodeButton) forControlEvents:UIControlEventTouchUpInside];
    [codeView addSubview:btnCountries];
    //***************************************
    txtPhoneNum=[[UITextField alloc]initWithFrame:CGRectMake(10, 60, 300, 30)];
    [txtPhoneNum setBorderStyle:UITextBorderStyleRoundedRect];
    txtPhoneNum.placeholder=@"请输入手机号码";
    [phoneNumView addSubview:txtPhoneNum];
    
}
-(void)uiID{
    for(int i = 0;i<count;i++){
        [ [ phoneNumView.subviews objectAtIndex:0] removeFromSuperview];
    }
    txtID=[[UITextField alloc]initWithFrame:CGRectMake(10, 20, 300, 30)];
    txtID.placeholder=@"请输入你的邦邦社区账号";
    [txtID setBorderStyle:UITextBorderStyleRoundedRect];
    [phoneNumView addSubview:txtID];
}
-(void)uiEmail{
    for(int i = 0;i<count;i++){
        [ [ phoneNumView.subviews objectAtIndex:0] removeFromSuperview];
    }
    txtEmail=[[UITextField alloc]initWithFrame:CGRectMake(10, 20, 300, 30)];
    txtEmail.placeholder=@"请输入你的绑定的邮箱";
    [txtEmail setBorderStyle:UITextBorderStyleRoundedRect];
    [phoneNumView addSubview:txtEmail];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)EmailHTTPRequest{
    NSString *url=[NSString stringWithFormat:@"%@/security-question?email=%@",httpRequset,txtEmail.text];
    [[NSUserDefaults standardUserDefaults] setObject:txtEmail.text forKey:@"txtemail"];
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (response==nil) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"错误" message:@"请检查网络" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        NSString *nameInfo = [weatherDic objectForKey:@"msg"];
        if ([nameInfo isEqual:@"邮箱未注册"]) {
            UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"邮箱未绑定" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alerView show];
        }else{
            NSArray *questions=[weatherDic objectForKey:@"questions"];
            NSString *question1=[questions[0] objectForKey:@"question"];
            NSString *question2=[questions[1] objectForKey:@"question"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:question1 forKey:@"question1"];
            [defaults setObject:question2 forKey:@"question2"];
            [defaults synchronize];//保存
            [self toAnswerView];
        }
    }
}

-(void)IDHTTPRequset{
    NSString *url=[NSString stringWithFormat:@"%@/security-question?username=%@",httpRequset,txtID.text];
    [[NSUserDefaults standardUserDefaults] setObject:txtID.text forKey:@"txtid"];
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (response==nil) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"错误" message:@"请检查网络" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        NSString *nameInfo = [weatherDic objectForKey:@"msg"];
        if ([nameInfo isEqual:@"用户不存在"]) {
            UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"用户不存在" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alerView show];

        }else if([nameInfo isEqual:@"没有设置安全问题"]){
            UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"没有设置密保" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alerView show];
        }
        else{
            NSArray *questions=[weatherDic objectForKey:@"questions"];
            NSString *question1=[questions[0] objectForKey:@"question"];
            NSString *question2=[questions[1] objectForKey:@"question"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:question1 forKey:@"question1"];
            [defaults setObject:question2 forKey:@"question2"];
            [defaults synchronize];//保存
            
            [self toAnswerView];
        }
    }
}

-(void)phoneNumRequeset{
    NSString *url=[NSString stringWithFormat:@"%@/security-question?countryCode=%@&phone=%@",httpRequset,btnCode.titleLabel.text,txtPhoneNum.text];
    [[NSUserDefaults standardUserDefaults] setObject:txtPhoneNum.text forKey:@"txtphonenum"];
    [[NSUserDefaults standardUserDefaults] setObject:btnCode.titleLabel.text forKey:@"code"];
    
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (response==nil) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"错误" message:@"请检查网络" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        NSString *nameInfo = [weatherDic objectForKey:@"msg"];
        if ([nameInfo isEqual:@"没有设置安全问题"]) {
            UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"没有设置安全问题" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alerView show];
        }else{
            NSArray *questions=[weatherDic objectForKey:@"questions"];
            NSString *question1=[questions[0] objectForKey:@"question"];
            NSString *question2=[questions[1] objectForKey:@"question"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:question1 forKey:@"question1"];
            [defaults setObject:question2 forKey:@"question2"];
            [defaults synchronize];//保存
            
            [self toAnswerView];
        }
    }
    
}

-(void)toAnswerView{
    ToAnswerViewController *answerView=[[ToAnswerViewController alloc]init];
    [self.navigationController pushViewController:answerView animated:YES];
}
#pragma mark -Click

-(void)nextStep{
    //    AnswerViewController *answerView=[[AnswerViewController alloc]init];
    //    [self.navigationController pushViewController:answerView animated:YES];
    if (segmentedBackPassword.selectedSegmentIndex==0) {
        //手机号码验证
        // if ([self isMobileNumber:txtPhoneNum.text]) {
        [self phoneNumRequeset];
        //       // }else{
        //            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"请输入正确手机号码" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //            [alertView show];
        //            [alertView release];
        //        }
    }else if(segmentedBackPassword.selectedSegmentIndex==1){
        //用户名验证
        [self IDHTTPRequset];
    }else if(segmentedBackPassword.selectedSegmentIndex==2){
        //邮箱验证
        if ([self isEmail:txtEmail.text]) {
            [self EmailHTTPRequest];
        }else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"请输入正确的邮箱" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}
//UISegmentedControl
-(void)chooseWay:(id)sender{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"count"];
    if (segmentedBackPassword.selectedSegmentIndex==0) {
        count=[phoneNumView.subviews count];
        [self uiPhoneNum];
    }else if(segmentedBackPassword.selectedSegmentIndex==1){
        count=[phoneNumView.subviews count];
        [self uiID];
    }else if(segmentedBackPassword.selectedSegmentIndex==2){
        count=[phoneNumView.subviews count];
        [self uiEmail];
    }
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d",segmentedBackPassword.selectedSegmentIndex] forKey:@"count"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

//邮箱格式判断
- (BOOL) isEmail: (NSString *) email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
//手机号码格式检测
- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
//跳转国际手机区号
-(void)clickCodeButton{
    
    
    FKRHeaderSearchBarTableViewController *tableViewController = [[FKRHeaderSearchBarTableViewController alloc] initWithSectionIndexes:YES];
    [self.navigationController pushViewController:tableViewController animated:YES];
}
//键盘隐藏
- (IBAction)backgroundTop:(id)sender {
    if (segmentedBackPassword.selectedSegmentIndex==0) {
        [txtPhoneNum resignFirstResponder];
    }else if(segmentedBackPassword.selectedSegmentIndex==1){
        [txtID resignFirstResponder];
    }else if(segmentedBackPassword.selectedSegmentIndex==2){
        [txtEmail resignFirstResponder];
    }
}

#pragma mark - NSNotificationCenter
- (void)arraycode:(NSNotification *)message{
    [btnCode setTitle:[NSString stringWithFormat:@"%@",[message object]]forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"back" object:nil];
    
}
- (void)arrayname:(NSNotification *)message{
    [btnCountries setTitle:[message object] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"back" object:nil];
}
#pragma mark

- (void)dealloc {

}

@end
