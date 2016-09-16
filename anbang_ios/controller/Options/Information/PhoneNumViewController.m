//
//  PhoneNumViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-20.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "PhoneNumViewController.h"
#import "CHAppDelegate.h"
#import "FKRHeaderSearchBarTableViewController.h"
#import "PhoneNumBindingCodeViewController.h"
@interface PhoneNumViewController ()
{
    UITextField *textFieldName;
    UIButton *btnLogin;
    UIButton *btnCode;
    UIButton *btnCountries;
    
}
@property(strong,nonatomic)UITextField *txtFieldName;
@end


@implementation PhoneNumViewController
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


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Country_Code" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Country_Name" object:nil];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countryCode:) name:@"NNC_Country_Code" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countryName:) name:@"NNC_Country_Name" object:nil];
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        //self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    
    self.title=NSLocalizedString(@"personalInformation.bindingPhoneNumber.title",@"title");
    
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
    
    textFieldName = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, 280, 50)];
    
    [_tableView reloadData];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}


- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{  //string就是此时输入的那个字符textField就是此时正在输入的那个输入框返回YES就是可以改变输入框的值NO相反
    
    if ([string isEqualToString:@"\n"])  //按会车可以改变
    {
        return NO;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    //判断是否时我们想要限定的那个输入框
    
    if ([toBeString length] > 20) { //如果输入框内容大于20则弹出警告
        textField.text = [toBeString substringToIndex:20];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"public.maximum",@"message") delegate:nil cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    return YES;
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
        
        cell.textLabel.text = NSLocalizedString(@"personalInformation.bindingPhoneNumber.tableTitle",@"title");
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.frame = CGRectMake(0 , 0, 300, 50);
        cell.textLabel.numberOfLines =0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        
        
    }else if(indexPath.row==1){
        //NSLocalizedString(@"personalInformation.bindingPhoneNumber.countryCode",@"title");
        cell.textLabel.text=[NSString stringWithFormat:@"%@%@",@"+ ",_countryCode];
        cell.textLabel.textColor = [UIColor blackColor];
        
        UILabel *countryLabel = [[UILabel alloc]initWithFrame:CGRectMake(KCurrWidth-260, 0, KCurrWidth-(KCurrWidth-260), 55)];
        //NSLog(@"$$$$$$$$%@",_countryCode);
        countryLabel.text= [NSString stringWithFormat:@"%@",_countryName];
        countryLabel.textAlignment = NSTextAlignmentCenter;
        countryLabel.tag= 10001;
        [cell addSubview:countryLabel];
        [[NSUserDefaults standardUserDefaults]setObject:_countryCode forKey:@"countryCode"];
        //        cell.detailTextLabel.text = @"国家和地区区号";
        //        cell.detailTextLabel.textColor = [UIColor blackColor];
        //        cell.detailTextLabel.frame = CGRectMake(KCurrWidth-150, 5, 150, cell.frame.size.height);
        //        cell.detailTextLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
    }else if(indexPath.row==2){
        
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        [textFieldName setKeyboardType:UIKeyboardTypeNumberPad];
        textFieldName.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textFieldName setPlaceholder:NSLocalizedString(@"personalInformation.bindingPhoneNumber.mobilePhoneNumber",@"title")];
        //设置字体颜色
        textFieldName.textColor = [UIColor blueColor];
        textFieldName.font = [UIFont fontWithName:@"Helvetica" size:22.0f];
        
        [textFieldName becomeFirstResponder ];
        [cell addSubview:textFieldName];
        cell.layer.borderWidth = 0;
        
    }else if(indexPath.row==3){
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        
    }else{
        btnLogin=[UIButton buttonWithType:UIButtonTypeCustom];
        btnLogin.frame=CGRectMake(0, 0, KCurrWidth, 40);
        [btnLogin setTitle:NSLocalizedString(@"public.nextStep",@"action") forState:UIControlStateNormal];
        [btnLogin setTitle:NSLocalizedString(@"public.nextStep",@"action") forState:UIControlStateHighlighted];
        [btnLogin setBackgroundColor:kMainColor8];
        //[btnLogin setBackgroundImage:[UIImage imageNamed:@"v2_btn_big_01_nomal.9.png"] forState:UIControlStateNormal];
        [btnLogin setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.5] forState:UIControlStateHighlighted];
        
        btnLogin.titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [btnLogin addTarget:self action:@selector(sendPhoneNum) forControlEvents:UIControlEventTouchUpInside];
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



-(void)sendPhoneNum{
    if (textFieldName.text.length>0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:textFieldName.text forKey:@"phonenum"];
        [defaults synchronize];//保存
        
        //        if (![self isMobileNumber:textFieldName.text]) {
        //            //输入正确的手机号码
        //            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")message:NSLocalizedString(@"personalInformation.bindingPhoneNumber.phoneNumberError",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil,nil];
        //            alertView.tag=10001;
        //            [alertView show];
        //            [alertView release];
        //            return;
        //        }
        NSString *url=[NSString stringWithFormat:@"%@/retrieve-auth?phone=%@&countryCode=%@",httpRequset,textFieldName.text,_countryCode];
        //NSLog(@"%d",[textFieldName retainCount]);
        NSLog(@"%@",url);
        
        NSError *error;
        //加载一个NSURL对象
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        //将请求的url数据放到NSData对象中
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if (response==nil) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"public.alert.networkConnectionFailure",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
            [alert show];
        }else{
            //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
            NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
            // NSString *msgInfo = [weatherDic objectForKey:@"msg"];
            NSString *code = [weatherDic objectForKey:@"code"];
            
            if (![code isEqual:@"3"]) {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:NSLocalizedString(@"personalInformation.bindingPhoneNumber.phoneNumberUsed",@"message") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"public.alert.cancel",@"action"),NSLocalizedString(@"personalInformation.bindingPhoneNumber.continueBind",@"action"),nil];
                alertView.tag=10002;
                [alertView show];
                
                //            return;
            }else{
                [self queryBindingPhoneNum];
                PhoneNumBindingCodeViewController *phoneNumCodevView=[[PhoneNumBindingCodeViewController alloc]init];
                [self.navigationController pushViewController:phoneNumCodevView animated:YES];
            }
        }
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"personalInformation.bindingPhoneNumber.enterPhoneNumber",@"message")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title")  otherButtonTitles:nil, nil];
        [alert show];
    }
}
//发送发送手机号码
-(void)queryBindingPhoneNum{
    /*
     <iq type=”set”>￼￼
     <query xmlns=”http://www.nihualao.com/xmpp/anonymous/phone/validate”>
     <phone countryCode=”国家码”>手机号</phone>
     </query>
     </iq>
     */
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/anonymous/phone/validate"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:textFieldName.text];
    
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"phoneNum"];
    [phone addAttributeWithName:@"countryCode" stringValue:_countryCode];
    [queryElement addChild:phone];
    [iq addChild:queryElement];
    NSLog(@"******%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
}

//-(IBAction)backgroundTop:(id)sender{
//    [txtFieldName resignFirstResponder];
//}
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


//通知调用方法
- (void)countryCode:(NSNotification *)message{
    _countryCode= [message object];
    NSLog(@"******%@",_countryCode);
    
    [_tableView reloadData];
}
- (void)countryName:(NSNotification *)message{
    _countryName= [message object];
    NSLog(@"******%@",_countryName);
    [_tableView reloadData];
}



#pragma mark -UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==10002) {
        if (buttonIndex==1) {
            [self queryBindingPhoneNum];
            PhoneNumBindingCodeViewController *phoneNumCodevView=[[PhoneNumBindingCodeViewController alloc]init];
            [self.navigationController pushViewController:phoneNumCodevView animated:YES];
        }
    }
}


@end
