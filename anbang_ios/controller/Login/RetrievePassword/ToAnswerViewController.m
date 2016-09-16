//
//  ToAnswerViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-29.
//  Copyright (c) 2014年 ch. All rights reserved.
//
//  密保找回密码－回答问题

#import "ToAnswerViewController.h"
#import "LoginViewController.h"
#import "CHAppDelegate.h"
@interface ToAnswerViewController ()
{
    UITextField *question1;
    UITextField *question2;
    UITextField *question3;
}
@end

@implementation ToAnswerViewController
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)dealloc{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //密保问题
    self.title = NSLocalizedString(@"forgetPassword.securityQuestion.answer.title",@"title");
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
    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"public.nav.ok",@"title") style:UIBarButtonItemStylePlain target:nil action:@selector(emailIDPhoneNum)];
    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];
    
    
}

//-(void)ui{
//    int height;
//    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
//        height=64;
//    }else{
//        height=0;
//    }
//    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:nil action:@selector(emailIDPhoneNum)];
//    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];
//
//    UILabel *lab1=[[UILabel alloc]initWithFrame:CGRectMake(10, height+10, 300, 20)];
//    lab1.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"question1"];
//    lab1.font=[UIFont fontWithName:nil size:14];
//    lab1.textColor=[UIColor grayColor];
//    [self.view addSubview:lab1];
//    question1=[[UITextField alloc]initWithFrame:CGRectMake(10, height+30, 300, 30)];
//    [question1 setBorderStyle:UITextBorderStyleRoundedRect];
//    question1.placeholder=@"请输入答案";
//    [self.view addSubview:question1];
//    UILabel *lab2=[[UILabel alloc]initWithFrame:CGRectMake(10, height+80, 300, 20)];
//    lab2.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"question2"];
//    lab2.font=[UIFont fontWithName:nil size:14];
//    lab2.textColor=[UIColor grayColor];
//    [self.view addSubview:lab2];
//    question2=[[UITextField alloc]initWithFrame:CGRectMake(10, height+100, 300, 30)];
//    [question2 setBorderStyle:UITextBorderStyleRoundedRect];
//    question2.placeholder=@"请输入答案";
//    [self.view addSubview:question2];
//
//    [lab2 release];
//    [lab1 release];
//}


-(void)emailIDPhoneNum{
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"NSUD_Problem_Way"] isEqual:@"0"]) {
        //手机号
        [self phoneNumSendAnswerHTTTPRequset];
    }else if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"NSUD_Problem_Way"] isEqual:@"1"]){
        //ID
        [self IDSendAnswerHTTTPRequset];
    }else if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"NSUD_Problem_Way"] isEqual:@"2"]){
        //邮箱
        [self emailSendAnswerHTTTPRequset];
    }
}


- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row==0) {
        
        cell.textLabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"question1"];
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.frame = CGRectMake(0 , 0, 300, 50);
        cell.textLabel.numberOfLines =0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        
    }else if(indexPath.row==1){
        
        question1 = [[UITextField alloc]initWithFrame:CGRectMake(20, 5, 280, 50)];
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        question1.clearButtonMode = UITextFieldViewModeWhileEditing;
        [question1 setPlaceholder:NSLocalizedString(@"forgetPassword.securityQuestion.answer.answer",@"title")];
        //设置字体颜色
        question1.textColor = [UIColor blueColor];
        question1.font = [UIFont fontWithName:@"Helvetica" size:20.0f];
        [question1 becomeFirstResponder ];
        [cell addSubview:question1];
        
        cell.layer.borderWidth = 0;
        
    }else if(indexPath.row==2){
        cell.textLabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"question2"];
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.frame = CGRectMake(0 , 0, 300, 50);
        cell.textLabel.numberOfLines =0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        
    }else if(indexPath.row==3){
        
        question2 = [[UITextField alloc]initWithFrame:CGRectMake(20, 5, 280, 50)];
        
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        question2.clearButtonMode = UITextFieldViewModeWhileEditing;
        [question2 setPlaceholder:NSLocalizedString(@"forgetPassword.securityQuestion.answer.answer",@"title")];
        //设置字体颜色
        question2.textColor = [UIColor blueColor];
        question2.font = [UIFont fontWithName:@"Helvetica" size:20.0f];
        [cell addSubview:question2];
        cell.layer.borderWidth = 0;
        
    }else if(indexPath.row==4){
        
        
    }else if(indexPath.row==5){
        
        
    }else{
        
        
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSUInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    if (section==0 && row==1) {
        //[self clickCodeButton];
    }else if (section==0 && row==3) {
        
    }
}


//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 30;
    }else if(indexPath.row==1){
        return 50;
    }else if(indexPath.row==2){
        return 30;
    }else if(indexPath.row==3){
        return 50;
    }else{
        return 40;
    }
}


//发送答案请求 获取密码
-(void)phoneNumSendAnswerHTTTPRequset{
    NSString *code=[[NSUserDefaults standardUserDefaults]objectForKey:@"code"];
    NSString *phoneNum=[[NSUserDefaults standardUserDefaults]objectForKey:@"txtphonenum"];
    NSString *url=[NSString stringWithFormat:@"%@/security-answer?countryCode=%@&phone=%@&0=%@&1=%@",httpRequset,code,phoneNum,[question1.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[question2.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"*****%@",url);
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (response==nil) {
        //网络未连接
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"public.alert.networkConnectionFailure",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
        [alert show];
    }else{
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        NSString *nameInfo = [weatherDic objectForKey:@"msg"];
        int code = [[weatherDic objectForKey:@"code"] intValue];
        NSString *pas=[weatherDic objectForKey:@"password"];
        //code=7 答案不正确
        if (code==0) {
            //牢记你的密码
            NSString * promptMsg = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"forgetPassword.securityQuestion.answer.promptMsg2",@"message"),pas];
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message: promptMsg delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"public.logBackIn",@"title"), nil];
            alertView.tag=1001;
            [alertView show];
        }else{
            //答案不正确
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nameInfo delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    
}
-(void)emailSendAnswerHTTTPRequset{
    NSString *email=[[NSUserDefaults standardUserDefaults]objectForKey:@"txtemail"];
    NSString *url=[NSString stringWithFormat:@"%@/security-answer?email=%@&0=%@&1=%@",httpRequset,email,[question1.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[question2.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"*****%@",url);
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (response==nil) {
        //网络未连接
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"public.alert.networkConnectionFailure",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
        [alert show];
        
    }else{
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        NSString *nameInfo = [weatherDic objectForKey:@"msg"];
        NSString *pas=[weatherDic objectForKey:@"password"];
        int code = [[weatherDic objectForKey:@"code"] intValue];
        if (code==0) {
            //牢记你的密码
            NSString * promptMsg = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"forgetPassword.securityQuestion.answer.promptMsg2",@"message"),pas];
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message: promptMsg delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"public.logBackIn",@"title"), nil];
            alertView.tag=1001;
            [alertView show];
        }else{
            //答案不正确
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nameInfo delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}
-(void)IDSendAnswerHTTTPRequset{
    NSString *ID=[[NSUserDefaults standardUserDefaults]objectForKey:@"txtid"];
    NSString *url=[NSString stringWithFormat:@"%@/security-answer?username=%@&0=%@&1=%@",httpRequset,ID,[question1.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[question2.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (response==nil) {
        //网络未连接
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"public.alert.networkConnectionFailure",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
        [alert show];
        
    }else{
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        NSString *nameInfo = [weatherDic objectForKey:@"msg"];
        NSString *pas=[weatherDic objectForKey:@"password"];
        int code = [[weatherDic objectForKey:@"code"] intValue];
        if (code==0) {
            //牢记你的密码
            NSString * promptMsg = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"forgetPassword.securityQuestion.answer.promptMsg2",@"message"),pas];
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message: promptMsg delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"public.logBackIn",@"title"), nil];
            alertView.tag=1001;
            [alertView show];

        }else{
            //答案不正确
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nameInfo delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//隐藏键盘
-(IBAction)backgroundTop:(id)sender{
    
}
#pragma mark -UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1001) {
        if (buttonIndex==0) {
            LoginViewController *loginView=[[LoginViewController alloc]init];
            [self.navigationController pushViewController:loginView animated:YES];
        }
    }
}



@end
