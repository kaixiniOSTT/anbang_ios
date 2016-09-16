//
//  EmailBindingViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-31.
//  Update by silencesky on 14-07-18
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "EmailBindingViewController.h"
#import "Utility.h"
@interface EmailBindingViewController ()
{
    UITextField *textEmail;
    UIButton *btnLogin;
}
@end

@implementation EmailBindingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindingSuccess) name:@"bindingEmail_ok" object:nil];
    }
    return self;
}

-(void)dealloc{
    //[btnLogin release];
    //[super dealloc];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=NSLocalizedString(@"personalInformation.bindingEmail.title",@"title");
    
    _tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollsToTop = YES;
    [self.view addSubview:_tableView];
    // [_tableView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
    [self setExtraCellLineHidden:_tableView];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [_tableView setSeparatorInset:(UIEdgeInsetsMake(0, 0, 0, 0))];
    }
    textEmail = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, 280, 50)];
    textEmail.delegate = self;
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
 int height;
 if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
 height=64;
 }else{
 height=0;
 }
 UIBarButtonItem *rightBut=[[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sendBindingEmail)];
 [self.navigationItem setRightBarButtonItem:rightBut];
 [rightBut release];
 
 textEmail=[[UITextField alloc]initWithFrame:CGRectMake(10, height+10, 300, 35)];
 textEmail.borderStyle=UITextBorderStyleRoundedRect;
 textEmail.placeholder=@"你的新邮箱地址";
 [textEmail setKeyboardType:UIKeyboardTypeEmailAddress];
 [textEmail becomeFirstResponder];
 [self.view addSubview:textEmail];
 [textEmail release];
 UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(10, height+50, 300, 50)];
 lab.lineBreakMode = UILineBreakModeWordWrap;
 lab.numberOfLines = 0;
 lab.text=@"邮箱能帮助你找回密码，同时可以使用邮箱作为用户名登录";
 [lab setTextColor:[UIColor lightGrayColor]];
 lab.font=[UIFont boldSystemFontOfSize:15];
 lab.textAlignment=1;
 lab.textColor=[UIColor lightGrayColor];
 [self.view addSubview:lab];
 [lab release];
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
        cell.textLabel.text = NSLocalizedString(@"personalInformation.bindingEmail.message",@"message");
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
        [textEmail setPlaceholder:NSLocalizedString(@"personalInformation.bindingEmail.emailAddress",@"title")];
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
        [btnLogin setTitle:NSLocalizedString(@"public.alert.ok",@"action") forState:UIControlStateNormal];
        [btnLogin setTitle:NSLocalizedString(@"public.alert.ok",@"action") forState:UIControlStateHighlighted];
        [btnLogin setBackgroundColor:kMainColor5];
        //[btnLogin setBackgroundImage:[UIImage imageNamed:@"v2_btn_big_01_nomal.9.png"] forState:UIControlStateNormal];
        [btnLogin setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.5] forState:UIControlStateHighlighted];
        
        btnLogin.titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [btnLogin addTarget:self action:@selector(sendBindingEmail) forControlEvents:UIControlEventTouchUpInside];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{  //string就是此时输入的那个字符textField就是此时正在输入的那个输入框返回YES就是可以改变输入框的值NO相反
    
    if ([string isEqualToString:@"\n"])  //按会车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    //判断是否时我们想要限定的那个输入框
    
    if ([toBeString length] > 50) { //如果输入框内容大于20则弹出警告
        textField.text = [toBeString substringToIndex:50];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"personalInformation.bindingEmail.maximum",@"message") delegate:nil cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    return YES;
}


-(void)sendBindingEmail{
    if (textEmail.text.length>0) {
        if ([Utility isEmail:textEmail.text]) {
            [self sendRequset];
        }else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"personalInformation.bindingEmail.emailFormatError",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
            [alertView show];
            //[alertView release];
        }
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"personalInformation.bindingEmail.enterEmail",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
        [alertView show];
        //[alertView release];
    }
}

//绑定邮箱请求
-(void)sendRequset{
    /*<iq type=”set”>
     <query xmlns=”http://www.nihualao.com/xmpp/bind”>
     <bind email=”需绑定的邮箱”/> </query>
     </iq>*/
    NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/bind"];
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    NSXMLElement *bind=[NSXMLElement elementWithName:@"bind"];
    [bind addAttributeWithName:@"email" stringValue:textEmail.text];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"bindingEmail"];
    [queryElement addChild:bind];
    [iq addChild:queryElement];
    NSLog(@"%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
}


-(void)bindingSuccess{
    //    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"bindingEmail_ok" object:nil];
    
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"personalInformation.sendEmailMsg",@"message") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles: nil];
    alertView.tag=1021;
    [alertView show];
    //[alertView release];
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
    if (alertView.tag==1021) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
