//
//  ToPhoneNumViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-28.
//  Copyright (c) 2014年 ch. All rights reserved.
//
// 手机号找回密码

#import "ToPhoneNumViewController.h"
#import "FKRHeaderSearchBarTableViewController.h"
#import "PhoneNumValidationViewController.h"
#import "PhoneNumCodeViewController.h"
#import "Utility.h"
@interface ToPhoneNumViewController ()

@end

@implementation ToPhoneNumViewController
@synthesize tableView=_tableView;
@synthesize countryCode=_countryCode;
@synthesize countryName=_countryName;

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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"anonymouss" forKey:@"userName"];
    [defaults setObject:nil forKey:@"password"];
    [[XMPPServer sharedServer]connect];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countryCode:) name:@"NNC_Country_Code" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countryName:) name:@"NNC_Country_Name" object:nil];
    
    //手机号找回密码
    self.title = NSLocalizedString(@"forgetPassword.phone.title",@"title");

    // Do any additional setup after loading the view from its nib.
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
    
    //默认86 中国
    _countryCode = NSLocalizedString(@"public.defaultConuntryCode",@"title");
    _countryName = NSLocalizedString(@"public.defaultCountry",@"title");
   
}

//-(void)ui{
//    int height;
//    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
//        height=64;
//    }else{
//        height=0;
//    }
//    
//    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(clickRightButton)];
//    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];
//    
//    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(10, height+20, 300, 30)];
//    label.text=@"请确认您的国家并输入您的手机号码";
//    label.textColor=[UIColor lightGrayColor];
//    [self.view addSubview:label];
//    
//    //*******************国际手机区号*************************
//    codeView=[[UIView alloc]initWithFrame:CGRectMake(10, height+60, 300, 30)];
//    [codeView setBackgroundColor:[UIColor lightGrayColor]];
//    [self.view addSubview:codeView];
//    btnCode=[[UIButton alloc]initWithFrame:CGRectMake(1, 1, 80, 28)];
//    btnCode.backgroundColor=[UIColor whiteColor];
//    [btnCode addTarget:self action:@selector(clickCodeButton) forControlEvents:UIControlEventTouchUpInside];
//    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(arraycode:) name:@"arraycode" object:nil];
//    [btnCode setTitle:@"86" forState:UIControlStateNormal];
//    [[NSUserDefaults standardUserDefaults]setObject:btnCode.titleLabel.text forKey:@"btnCode"];
//    [[NSUserDefaults standardUserDefaults]synchronize];
//    [btnCode setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1] forState:UIControlStateNormal];
//    [codeView addSubview:btnCode];
//    btnCountries=[[UIButton alloc]initWithFrame:CGRectMake(82, 1, 217, 28)];
//    btnCountries.backgroundColor=[UIColor whiteColor];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(arrayname:) name:@"arrayname" object:nil];
//    
//    [btnCountries setTitle:@"中国" forState:UIControlStateNormal];
//    [btnCountries setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1] forState:UIControlStateNormal];
//    [btnCountries addTarget:self action:@selector(clickCodeButton) forControlEvents:UIControlEventTouchUpInside];
//    [codeView addSubview:btnCountries];
//    //*******************国际手机区号*************************
//    //
//    //
//    txtFieldName=[[UITextField alloc]initWithFrame:CGRectMake(10, height+100, 300, 30)];
//    [txtFieldName setBorderStyle:UITextBorderStyleRoundedRect];
//    [txtFieldName setKeyboardType:UIKeyboardTypePhonePad];
//    txtFieldName.placeholder=@"手机号";
//    [txtFieldName becomeFirstResponder];
//    [self.view addSubview:txtFieldName];
//    
//    [label release];
//    //    [btnLeft release];
//    [btnRight release];
//    [txtFieldName release];
//    [btnCode release];
//    [btnCountries release];
//    [codeView release];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 5;
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
        //输入绑定的手机号码
        cell.textLabel.text = NSLocalizedString(@"forgetPassword.phone.tableViewTitle",@"title");
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.frame = CGRectMake(0 , 0, 300, 50);
        cell.textLabel.numberOfLines =0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
     
    }else if(indexPath.row==1){
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@",@"+",_countryCode];
        UILabel *countryLabel = [[UILabel alloc]initWithFrame:CGRectMake(KCurrWidth-220, 0, KCurrWidth-(KCurrWidth-220), 55)];
        countryLabel.text= _countryName;
        countryLabel.textAlignment = NSTextAlignmentCenter;
        countryLabel.tag= 10001;
        [cell addSubview:countryLabel];;
  
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [[NSUserDefaults standardUserDefaults]setObject:_countryCode forKey:@"NSUD_countryCode"];

        
    }else if(indexPath.row==2){
        txtFieldName = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, KCurrWidth-40, 50)];
        
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        [txtFieldName setKeyboardType:UIKeyboardTypeNumberPad];
        txtFieldName.clearButtonMode = UITextFieldViewModeWhileEditing;
        //手机号码
        [txtFieldName setPlaceholder:NSLocalizedString(@"forgetPassword.phone.phoneNum",@"title")];
        //设置字体颜色
        txtFieldName.textColor = [UIColor blueColor];
        txtFieldName.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        
        [txtFieldName becomeFirstResponder ];
        [cell addSubview:txtFieldName];
        cell.layer.borderWidth = 0;
        
    }else if(indexPath.row==3){
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        
    }else{
        btnLogin=[UIButton buttonWithType:UIButtonTypeCustom];
        btnLogin.frame=CGRectMake(0, 0, KCurrWidth, 40);
        //下一步
        [btnLogin setTitle:NSLocalizedString(@"public.nextStep",@"action") forState:UIControlStateNormal];
        [btnLogin setTitle:NSLocalizedString(@"public.nextStep",@"action") forState:UIControlStateHighlighted];
        [btnLogin setBackgroundColor:kMainColor5];
        //[btnLogin setBackgroundImage:[UIImage imageNamed:@"v2_btn_big_01_nomal.9.png"] forState:UIControlStateNormal];
        [btnLogin setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.5] forState:UIControlStateHighlighted];
        
        btnLogin.titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [btnLogin addTarget:self action:@selector(clickRightButton) forControlEvents:UIControlEventTouchUpInside];
        [btnLogin addTarget:self action:@selector(LoginButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [btnLogin.layer setMasksToBounds:YES];
        
        [cell addSubview:btnLogin];
        
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSUInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    if (section==0 && row==1) {
        [self clickCodeButton];
    }else if (section==0 && row==3) {
        
    }
}


//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 30;
    }else if (indexPath.row==3) {
        return 15;
    }else if(indexPath.row==4){
        return 40;
    }else{
        return 50;
    }
}


- (void)LoginButtonTouchDown{
    btnLogin.backgroundColor = kMainColor5;
}



//发送手机号码
-(void)queryRosterPhoneNum{
    /*
     <iq type=”set”>￼￼
     <query xmlns=”http://www.nihualao.com/xmpp/anonymous/phone/validate”>
     <phone countryCode=”国家码”>手机号</phone>
     </query>
     </iq>
     */
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/anonymous/phone/validate"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:txtFieldName.text];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"pswPhoneNum"];
    [phone addAttributeWithName:@"countryCode" stringValue:_countryCode];
    [queryElement addChild:phone];
    [iq addChild:queryElement];
    [[XMPPServer xmppStream] sendElement:iq];
    
}
//手机号码检测
-(void)iphoneNumUse{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:txtFieldName.text forKey:@"NSUD_phonenum"];

    [defaults synchronize];//保存
    //    long phoneNum=[txtFieldName.text intValue];
//    if (![Utility isMobileNumber:txtFieldName.text]) {
//        //请输入正确手机号码
//        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:NSLocalizedString(@"forgetPassword.phone.promptMsg",@"message")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action")  otherButtonTitles:nil,nil];
//        alertView.tag=10001;
//        [alertView show];
//        [alertView release];
//        return;
//    }
    NSString *url=[NSString stringWithFormat:@"%@/retrieve-auth?phone=%@&countryCode=%@",httpRequset,txtFieldName.text,_countryCode];
    //NSLog(@"******%@",url);
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (response==nil) {
        //网络未连接
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:NSLocalizedString(@"public.alert.networkConnectionFailure",@"message")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action")  otherButtonTitles:nil, nil];
        [alert show];
    }else{
    //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
    NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
   // NSString *nameInfo = [weatherDic objectForKey:@"username"];
    //NSString *msgInfo = [weatherDic objectForKey:@"msg"];
        NSString *code = [weatherDic objectForKey:@"code"];
     //code=3 手机号未注册
    if ([code isEqual:@"3"]) {
        //手机号未注册
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:NSLocalizedString(@"forgetPassword.phone.promptMsg2",@"message")  delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"login.signUp",@"action") ,nil];
        alertView.tag=10002;
        [alertView show];
    }else{
        [self queryRosterPhoneNum];
        [self intoPhoneNumValidationViewController];
    }
    }
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Country_Code" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Country_Name" object:nil];
}

#pragma mark -Click
//发送手机号请求
-(void)clickRightButton{
    
    JLLog_D("Next step to change password");
    
    [self iphoneNumUse];
}
//进入验证码界面
-(void)intoPhoneNumValidationViewController{
    PhoneNumValidationViewController *phoneNumValidationView=[[PhoneNumValidationViewController alloc]init];
    phoneNumValidationView.countryCode = _countryCode;
    [self.navigationController pushViewController:phoneNumValidationView animated:YES];
}
//跳转国际手机区号
-(void)clickCodeButton{
    FKRHeaderSearchBarTableViewController *tableViewController = [[FKRHeaderSearchBarTableViewController alloc] initWithSectionIndexes:YES];
    [self.navigationController pushViewController:tableViewController animated:YES];
}

//键盘隐藏
- (IBAction)backgroundTop:(id)sender {
    [txtFieldName resignFirstResponder];
}


//通知调用方法
- (void)countryCode:(NSNotification *)message{
    _countryCode= [message object];
    [_tableView reloadData];
}
- (void)countryName:(NSNotification *)message{
    _countryName= [message object];
    [_tableView reloadData];
}


#pragma mark - AlartView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==10002) {
        if (buttonIndex==0) {
            //发送注册请求
            [self queryRosterPhoneNum];
            PhoneNumCodeViewController *phoneNumCodevView=[[PhoneNumCodeViewController alloc]init];
            [self.navigationController pushViewController:phoneNumCodevView animated:YES];
        }
    }
}

@end
