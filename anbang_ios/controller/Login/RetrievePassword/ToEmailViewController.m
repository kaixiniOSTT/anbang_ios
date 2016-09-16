//
//  ToEmailViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-28.
//  Copyright (c) 2014年 ch. All rights reserved.
//
// 邮箱找回密码

#import "ToEmailViewController.h"
#import "LoginViewController.h"
#import "CHAppDelegate.h"
#import "Utility.h"
#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface ToEmailViewController ()
{
    UITextField *textEmail;
    UIButton *btnLogin;
}
@end

@implementation ToEmailViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)dealloc{
    //[textEmail release];
    //[btnLogin release];
    //[_tableView release];
    
    //[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //邮箱找回密码
    
    self.title = NSLocalizedString(@"forgetPassword.email.title",@"title");
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
    textEmail = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, KCurrWidth-40, 50)];
    
    [_tableView reloadData];
}


- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
    //[view release];
}


/*
-(void)ui{
    int heightdvi;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        heightdvi=64;
    }else{
        heightdvi=0;
    }
    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sendEmailToServer)];
    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];
    textEmail=[[UITextField alloc]initWithFrame:CGRectMake(10, heightdvi+20, 300, 30)];
    [textEmail setBorderStyle:UITextBorderStyleRoundedRect];
    textEmail.placeholder=@"请输入绑定邮箱";
    [self.view addSubview:textEmail];
    [textEmail release];
}
*/

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
    
    if ([cell viewWithTag:10001]) {
        [[cell viewWithTag:10001] removeFromSuperview];
    }
    
    if (indexPath.row==0) {
        //请输入绑定邮箱
        cell.textLabel.text = NSLocalizedString(@"forgetPassword.email.tableViewTitle",@"title");
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.frame = CGRectMake(0 , 0, 300, 50);
        cell.textLabel.numberOfLines =0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        
        
        
    }else if(indexPath.row==1){
        
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        [textEmail setKeyboardType:UIKeyboardTypeEmailAddress];
        textEmail.clearButtonMode = UITextFieldViewModeWhileEditing;
        //邮箱
        [textEmail setPlaceholder:NSLocalizedString(@"forgetPassword.email.email",@"title")];
        //设置字体颜色
        textEmail.textColor = [UIColor blueColor];
        textEmail.font = [UIFont fontWithName:@"Helvetica" size:22.0f];
        [textEmail becomeFirstResponder ];
        [cell addSubview:textEmail];
        cell.layer.borderWidth = 0;

        
    }else if(indexPath.row==2){
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        
    }else{
        btnLogin=[UIButton buttonWithType:UIButtonTypeCustom];
        btnLogin.frame=CGRectMake(0, 0, KCurrWidth, 40);
        //确定
        [btnLogin setTitle:NSLocalizedString(@"public.button.ok",@"action") forState:UIControlStateNormal];
        [btnLogin setTitle:NSLocalizedString(@"public.button.ok",@"action") forState:UIControlStateHighlighted];
        [btnLogin setBackgroundColor:kMainColor5];
        //[btnLogin setBackgroundImage:[UIImage imageNamed:@"v2_btn_big_01_nomal.9.png"] forState:UIControlStateNormal];
        [btnLogin setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.5] forState:UIControlStateHighlighted];
        
        btnLogin.titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [btnLogin addTarget:self action:@selector(sendEmailToServer) forControlEvents:UIControlEventTouchUpInside];
        [btnLogin addTarget:self action:@selector(LoginButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [btnLogin.layer setMasksToBounds:YES];
        
        [cell addSubview:btnLogin];
        
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
        return 35;
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



-(void)sendEmailToServer{
    if ([Utility validateEmail:textEmail.text]) {
        NSString *url=[NSString stringWithFormat:@"%@/retrieve-password-by-email?email=%@",httpRequset,textEmail.text];
        //NSLog(@"*****%@",url);
        NSError *error;
        //加载一个NSURL对象
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        //将请求的url数据放到NSData对象中
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if (response==nil) {
            //请检查网络
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"public.alert.networkConnectionFailure",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
            [alert show];
            //[alert release];
        }else{
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        //NSString *nameInfo = [weatherDic objectForKey:@"msg"];
        NSString *code = [weatherDic objectForKey:@"code"];
        //邮箱未注册 code=6;
        if ([code isEqual:@"6"]) {
            //邮箱未注册
            UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"forgetPassword.email.promptMsg",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
            [alerView show];
            //[alerView release];
        }else{
            //密码已发送邮箱，请查看邮箱
            UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"forgetPassword.email.promptMsg2",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.logBackIn",@"action") otherButtonTitles:nil, nil];
            alerView.tag=1005;
            [alerView show];
            //[alerView release];
        }
        }
    }else{
        //请输入正确的邮箱
        UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"forgetPassword.email.promptMsg3",@"title") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
        [alerView show];
        //[alerView release];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backgroundTop:(id)sender{
    [textEmail resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1005) {
        LoginViewController *loginView=[[LoginViewController alloc]init];
        [self.navigationController pushViewController:loginView animated:YES];
       // [loginView release];
    }
}


@end
