//
//  ToProblemViewController2.m
//  anbang_ios
//
//  Created by silenceSky  on 14-7-17.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "ToProblemViewController2.h"
#import "FKRHeaderSearchBarTableViewController.h"
#import "ToAnswerViewController.h"
#import "Utility.h"

@interface ToProblemViewController2 (){
    
    NSInteger count;
    
    NSString *prompt;
    int cellCount;
    NSString *type;
    NSString *placeholder;
}

@end

@implementation ToProblemViewController2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Country_Code" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Country_Name" object:nil];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countryCode:) name:@"NNC_Country_Code" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countryName:) name:@"NNC_Country_Name" object:nil];
    // Do any additional setup after loading the view from its nib.
    //@"手机",@"I D",@"邮箱"
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects: NSLocalizedString(@"forgetPassword.securityQuestion.mobilePhone",@"title")
                               , NSLocalizedString(@"forgetPassword.securityQuestion.id",@"title")
                               , NSLocalizedString(@"forgetPassword.securityQuestion.email",@"title"),nil];
    segmentedRetrievePassword=[[UISegmentedControl alloc]initWithItems:segmentedArray];
    segmentedRetrievePassword.frame=CGRectMake(0, 0, 150, 30);
    self.navigationItem.titleView = segmentedRetrievePassword;
    
    segmentedRetrievePassword.selectedSegmentIndex = 0;
    [segmentedRetrievePassword addTarget:self
                                  action:@selector(chooseWay:)
                        forControlEvents:UIControlEventValueChanged];
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d",segmentedRetrievePassword.selectedSegmentIndex] forKey:@"NSUD_Problem_Way"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
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
    
    _countryCode = NSLocalizedString(@"public.defaultConuntryCode",@"action");
    _countryName = NSLocalizedString(@"public.defaultCountry",@"action");
    
    textFieldName = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, KCurrWidth-40, 50)];
    
    [self uiPhoneNum];
    
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
}



-(void)uiPhoneNum{
    textFieldName.text=@"";
    [textFieldName becomeFirstResponder ];
    
    cellCount = 5;
    //通过手机找回密码
    prompt = NSLocalizedString(@"forgetPassword.securityQuestion.tableViewTitle",@"title");
    placeholder = NSLocalizedString(@"forgetPassword.securityQuestion.mobilePhoneNum",@"title");
    type = @"phone";
    [_tableView reloadData];
    
}


-(void)uiID{
    textFieldName.text=@"";
    [textFieldName becomeFirstResponder ];
    cellCount = 5;
    //通过ID找回密码
    prompt = NSLocalizedString(@"forgetPassword.securityQuestion.tableViewTitle2",@"title");;
    placeholder = NSLocalizedString(@"forgetPassword.securityQuestion.id",@"title");
    type = @"ID";
    [_tableView reloadData];
}


-(void)uiEmail{
    textFieldName.text=@"";
    [textFieldName becomeFirstResponder ];
    cellCount = 5;
    //通过绑定的邮箱找回密码
    prompt = NSLocalizedString(@"forgetPassword.securityQuestion.tableViewTitle3",@"title");
    placeholder = NSLocalizedString(@"forgetPassword.securityQuestion.email",@"title");
    type = @"email";
    [_tableView reloadData];
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return cellCount;
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
        
        cell.textLabel.text = prompt;
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.frame = CGRectMake(0 , 0, 300, 50);
        cell.textLabel.numberOfLines =0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        
        
        
    }else if(indexPath.row==1){
        if ([type isEqualToString:@"phone"]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@%@",@"+",_countryCode];
            UILabel *countryLabel = [[UILabel alloc]initWithFrame:CGRectMake(KCurrWidth-220, 0, KCurrWidth-(KCurrWidth-220), 55)];
            countryLabel.text= _countryName;
            countryLabel.textAlignment = NSTextAlignmentCenter;
            countryLabel.tag= 10001;
            [cell addSubview:countryLabel];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }else{
            cell.accessoryType = NO;
        }
        
        
    }else if(indexPath.row==2){
        
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        if ([type isEqualToString:@"email"]) {
            [textFieldName setKeyboardType:UIKeyboardTypeEmailAddress];
            
        }else{
            [textFieldName setKeyboardType:UIKeyboardTypeNumberPad];
            
        }
        textFieldName.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textFieldName setPlaceholder:placeholder];
        //设置字体颜色
        textFieldName.textColor = [UIColor blueColor];
        textFieldName.font = [UIFont fontWithName:@"Helvetica" size:22.0f];
        
        [cell addSubview:textFieldName];
        cell.layer.borderWidth = 0;
        
    }else if(indexPath.row==3){
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        
    }else{
        btnLogin=[UIButton buttonWithType:UIButtonTypeCustom];
        btnLogin.frame=CGRectMake(0, 0, KCurrWidth, 40);
        //下一步
        [btnLogin setTitle:NSLocalizedString(@"public.nextStep",@"title") forState:UIControlStateNormal];
        [btnLogin setTitle:NSLocalizedString(@"public.nextStep",@"title") forState:UIControlStateHighlighted];
        [btnLogin setBackgroundColor:kMainColor5];
        //[btnLogin setBackgroundImage:[UIImage imageNamed:@"v2_btn_big_01_nomal.9.png"] forState:UIControlStateNormal];
        [btnLogin setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.5] forState:UIControlStateHighlighted];
        
        btnLogin.titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [btnLogin addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
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


//Change the cell height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 30;
    }else if (indexPath.row==1) {
        if (![type isEqualToString:@"phone"]) {
            return 0;
        }else{
            return 50;
        }
    }else if(indexPath.row==2){
        return 50;
    }else if(indexPath.row==3){
        return 15;
    }else if(indexPath.row==4){
        return 40;
    } else{
        return 50;
    }
}


- (void)LoginButtonTouchDown{
    btnLogin.backgroundColor = kMainColor5;
}


//Jump international mobile phone area code view
-(void)clickCodeButton{
    FKRHeaderSearchBarTableViewController *tableViewController = [[FKRHeaderSearchBarTableViewController alloc] initWithSectionIndexes:YES];
    [self.navigationController pushViewController:tableViewController animated:YES];
}

//Notification method is called
- (void)countryCode:(NSNotification *)message{
    _countryCode= [message object];
    [_tableView reloadData];
}


- (void)countryName:(NSNotification *)message{
    _countryName= [message object];
    [_tableView reloadData];
}


-(void)chooseWay:(id)sender{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"NSUD_Problem_Way"];
    if (segmentedRetrievePassword.selectedSegmentIndex==0) {
        count=0;
        [self uiPhoneNum];
    }else if(segmentedRetrievePassword.selectedSegmentIndex==1){
        count=1;
        [self uiID];
    }else if(segmentedRetrievePassword.selectedSegmentIndex==2){
        count=2;
        [self uiEmail];
    }
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d",segmentedRetrievePassword.selectedSegmentIndex] forKey:@"NSUD_Problem_Way"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


-(void)nextStep{
    //    AnswerViewController *answerView=[[AnswerViewController alloc]init];
    //    [self.navigationController pushViewController:answerView animated:YES];
    if (segmentedRetrievePassword.selectedSegmentIndex==0) {
        //手机号码验证
        //  if ([Utility isMobileNumber:textFieldName.text]) {
        [self phoneNumRequeset];
        //        }else{
        //            //请输入正确手机号码
        //            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"forgetPassword.securityQuestion.promptMsg",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
        //            [alertView show];
        //            [alertView release];
        //        }
    }else if(segmentedRetrievePassword.selectedSegmentIndex==1){
        //用户名验证
        [self IDHTTPRequset];
    }else if(segmentedRetrievePassword.selectedSegmentIndex==2){
        //邮箱验证
        if ([Utility isEmail:textFieldName.text]) {
            [self EmailHTTPRequest];
        }else{
            //请输入正确的邮箱
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:NSLocalizedString(@"forgetPassword.securityQuestion.promptMsg2",@"message")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}


-(void)phoneNumRequeset{
    
    // NSLog(@"******%@",textFieldName.text);
    NSString *url=[NSString stringWithFormat:@"%@/security-question?countryCode=%@&phone=%@",httpRequset,_countryCode,textFieldName.text];
    
    //NSLog(@"****%@",url);
    
    [[NSUserDefaults standardUserDefaults] setObject:textFieldName.text forKey:@"txtphonenum"];
    [[NSUserDefaults standardUserDefaults] setObject:_countryCode forKey:@"code"];
    
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (response==nil) {
        //请检查网络
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"public.alert.networkConnectionFailure",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
        [alert show];
    }else{
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        NSString *nameInfo = [weatherDic objectForKey:@"msg"];
        int code = [[weatherDic objectForKey:@"code"] intValue];
        // NSLog(@"*****%d",code);
        //code=3 手机号未注册
        //code=10 没有设置安全问题
        if(code==0){
            NSArray *questions=[weatherDic objectForKey:@"questions"];
            NSString *question1=[questions[0] objectForKey:@"question"];
            NSString *question2=[questions[1] objectForKey:@"question"];
            //NSString *question3=[questions[2] objectForKey:@"question"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:question1 forKey:@"question1"];
            [defaults setObject:question2 forKey:@"question2"];
            //[defaults setObject:question3 forKey:@"question3"];
            [defaults synchronize];//保存
            [self toAnswerView];
        }else{
            //其他问题
            UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nameInfo delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
            [alerView show];
            
        }
    }
    
}


-(void)IDHTTPRequset{
    NSString *url=[NSString stringWithFormat:@"%@/security-question?username=%@",httpRequset,textFieldName.text];
    [[NSUserDefaults standardUserDefaults] setObject:textFieldName.text forKey:@"txtid"];
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (response==nil) {
        //请检查网络
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:NSLocalizedString(@"public.alert.networkConnectionFailure",@"message")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.prompt",@"title")  otherButtonTitles:nil, nil];
        [alert show];
    }else{
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        NSString *nameInfo = [weatherDic objectForKey:@"msg"];
        int code = [[weatherDic objectForKey:@"code"] intValue];
        if(code==0){
            NSArray *questions=[weatherDic objectForKey:@"questions"];
            NSString *question1=[questions[0] objectForKey:@"question"];
            NSString *question2=[questions[1] objectForKey:@"question"];
            //NSString *question3=[questions[2] objectForKey:@"question"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:question1 forKey:@"question1"];
            [defaults setObject:question2 forKey:@"question2"];
            //[defaults setObject:question3 forKey:@"question3"];
            [defaults synchronize];//保存
            [self toAnswerView];
        }else{
            //其他问题
            UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nameInfo delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
            [alerView show];
            
        }
    }
}


-(void)EmailHTTPRequest{
    NSString *url=[NSString stringWithFormat:@"%@/security-question?email=%@",httpRequset,textFieldName.text];
    //NSLog(@"******%@",url);
    [[NSUserDefaults standardUserDefaults] setObject:textFieldName.text forKey:@"txtemail"];
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (response==nil) {
        //请检查网络
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:NSLocalizedString(@"public.alert.networkConnectionFailure",@"message")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.prompt",@"title")  otherButtonTitles:nil, nil];
        [alert show];
    }else{
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        NSString *nameInfo = [weatherDic objectForKey:@"msg"];
        int code = [[weatherDic objectForKey:@"code"] intValue];
        //code=10 没有设置安全问题
        //code=6 邮箱未注册
        if(code==0){
            NSArray *questions=[weatherDic objectForKey:@"questions"];
            NSString *question1=[questions[0] objectForKey:@"question"];
            NSString *question2=[questions[1] objectForKey:@"question"];
            //NSString *question3=[questions[2] objectForKey:@"question"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:question1 forKey:@"question1"];
            [defaults setObject:question2 forKey:@"question2"];
            //[defaults setObject:question3 forKey:@"question3"];
            [defaults synchronize];//保存
            [self toAnswerView];
        }else{
            //其他问题
            UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nameInfo delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
            [alerView show];
            
        }
    }
}


-(void)toAnswerView{
    ToAnswerViewController *answerView=[[ToAnswerViewController alloc]init];
    [self.navigationController pushViewController:answerView animated:YES];
}


@end
