//
//  ChangePasswordViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-31.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "CHAppDelegate.h"
#import "LoginViewController.h"


@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController
@synthesize tableView=_tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSuccess) name:@"changeSuccess" object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"changeSuccess" object:nil];
    //[super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        //self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    
    self.title=NSLocalizedString(@"changePassword.title",@"title");
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
    
    oldPas = [[UITextField alloc]initWithFrame:CGRectMake(20, 0,  KCurrWidth-40, 40)];
    newPas1 = [[UITextField alloc]initWithFrame:CGRectMake(20, 0, KCurrWidth-40, 40)];
    newPas2 = [[UITextField alloc]initWithFrame:CGRectMake(20, 0, KCurrWidth-40, 40)];
    oldPas.delegate=self;
    newPas1.delegate=self;
    newPas2.delegate=self;
}


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
    return 6;
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
        
        cell.textLabel.text =[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"changePassword.tableTitle",@"title")
                              ,[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"]];
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.frame = CGRectMake(20 , 0, 300, 50);
        cell.textLabel.numberOfLines =0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    }else if(indexPath.row==1){
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        oldPas.clearButtonMode = UITextFieldViewModeWhileEditing;
        [oldPas setPlaceholder:NSLocalizedString(@"changePassword.oldPassword",@"title")];
        //设置字体颜色
        oldPas.textColor = [UIColor blueColor];
        oldPas.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
        [oldPas becomeFirstResponder ];
        
        NSString *oncepaw=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"oncePassword"]];
        if (![oncepaw isEqualToString:@"(null)"]) {
            oldPas.alpha=0;
            oldPas.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"oncePassword"];
        }
        oldPas.secureTextEntry = YES;
        [cell addSubview:oldPas];
        cell.layer.borderWidth = 0;
        
    }else if(indexPath.row==2){
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        newPas1.clearButtonMode = UITextFieldViewModeWhileEditing;
        [newPas1 setPlaceholder:NSLocalizedString(@"changePassword.newPassword",@"title")];
        //设置字体颜色
        newPas1.textColor = [UIColor blueColor];
        newPas1.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
        newPas1.secureTextEntry = YES;
        [cell addSubview:newPas1];
        cell.layer.borderWidth = 0;
        
    }else if(indexPath.row==3){
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        newPas2.clearButtonMode = UITextFieldViewModeWhileEditing;
        [newPas2 setPlaceholder:NSLocalizedString(@"changePassword.newPasswordAgain",@"title")];
        //设置字体颜色
        newPas2.textColor = [UIColor blueColor];
        newPas2.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
        newPas2.secureTextEntry = YES;
        [cell addSubview:newPas2];
        cell.layer.borderWidth = 0;
        
    }else if(indexPath.row==4){
        
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        
    }else{
        btnLogin=[UIButton buttonWithType:UIButtonTypeCustom];
        btnLogin.frame=CGRectMake(0, 0, KCurrWidth, 35);
        [btnLogin setTitle:NSLocalizedString(@"public.alert.ok",@"action") forState:UIControlStateNormal];
        [btnLogin setTitle:NSLocalizedString(@"public.alert.ok",@"action") forState:UIControlStateHighlighted];
        [btnLogin setBackgroundColor:kMainColor5];
        //[btnLogin setBackgroundImage:[UIImage imageNamed:@"v2_btn_big_01_nomal.9.png"] forState:UIControlStateNormal];
        [btnLogin setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.5] forState:UIControlStateHighlighted];
        
        btnLogin.titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [btnLogin addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
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
        return 30;
    }else if (indexPath.row==1) {
        return 35;
    }else if(indexPath.row==2){
        return 35;
    }else if(indexPath.row==3){
        return 35;
    }else if(indexPath.row==4){
        return 15;
    }else{
        return 35;
    }
}



- (void)LoginButtonTouchDown{
    btnLogin.backgroundColor = kMainColor5;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{  //string就是此时输入的那个字符textField就是此时正在输入的那个输入框返回YES就是可以改变输入框的值NO相反
    
    if ([string isEqualToString:@"\n"])  //按会车可以改变
    {
        return NO;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    //判断是否时我们想要限定的那个输入框
    
    if ([toBeString length] > 50) {
        //如果输入框内容大于20则弹出警告
        textField.text = [toBeString substringToIndex:50];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"public.maximum",@"message") delegate:nil cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    return YES;
}

-(IBAction)btnClick:(id)sender{
    if (newPas1.text.length<6 ) {
        //"密码至少6个字符的长度";
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"changePassword.passwordLengthMsg",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    if (oldPas.text.length>0&&newPas1.text.length>0&&newPas2.text.length>0) {
        if ([oldPas.text isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"confirmPassword"]]) {
            if ([newPas1.text isEqualToString:newPas2.text]) {
                //fa送改密码请求
                [self sendQuest];
                
            }
            else{
                //新密码不一致
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"changePassword.notMatchNewPassword",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
                [alert show];
                
            }
        }else{
            //旧密码错误
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"changePassword.oldPasswordError",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
            [alert show];
            
        }
    }else{
        //密码不能为空
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"changePassword.passwordCannotBeEmpty",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
        [alert show];
        
    }
}

-(void)sendQuest{
    /*<iq id="Q63r7-24" type="set”>
     <query xmlns="http://nihualao.com/protocol/coustom#password”>
     <action >3</action>
     <password>111111</password>
     </query></iq>*/
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://nihualao.com/protocol/coustom#password"];
    NSXMLElement *action=[NSXMLElement elementWithName:@"action" stringValue:@"3"];
    NSXMLElement *password=[NSXMLElement elementWithName:@"password" stringValue:newPas2.text];
    [iq addAttributeWithName:@"id" stringValue:@"ChangePassword"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [queryElement addChild:action];
    [queryElement addChild:password];
    [iq addChild:queryElement];
    //    NSLog(@"%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
}

-(void)changeSuccess{
    [[XMPPServer sharedServer]getOffline];
    [[XMPPServer sharedServer]disconnect];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"password"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"confirmPassword"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"oncePassword"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"public.modifySuccess",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.logBackIn",@"action") otherButtonTitles:nil, nil];
    alert.tag=1009;
    [alert show];
}

-(IBAction)backgroundTop:(id)sender{
    [oldPas resignFirstResponder];
    [newPas1 resignFirstResponder];
    [newPas2 resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField;{
    return [textField resignFirstResponder];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1009) {
        //修改密码重新登录，需注销；
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_Logout" object:nil userInfo:nil];
        
        LoginViewController *loginView=[[LoginViewController alloc]init];
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:loginView];
        [self presentViewController:nav animated:NO completion:nil];
        
    }
}


#pragma mark--TextFieldDelegate

@end
