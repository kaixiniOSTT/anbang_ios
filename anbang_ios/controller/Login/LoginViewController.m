
//  LoginViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisteredViewController.h"
#import "ToEmailViewController.h"
#import "ToPhoneNumViewController.h"
#import "ToProblemViewController.h"
#import "ToProblemViewController2.h"

#import "Reachability.h"
#import "DejalActivityView.h"
#import "AddressBookCRUD.h"
#import "UITableView+DataSourceBlocks.h"
#import "TableViewWithBlock.h"
#import "SelectionCell.h"
#import "TKAddressBook.h"
#import "PinYinForObjc.h"
#import "MobileAddressBookCRUD.h"
#import "ContactModule.h"
#import "UserNameCRUD.h"
#import "UserInfoCRUD.h"
#import "PublicCURD.h"

#import "MyDrawRectUtility.h"
#import "UIImageView+WebCache.h"
#import "AKeyRegisteredTableViewController2.h"
#import "PhoneNumRegisteredViewController.h"
#import "FirstLoadDataProgressViewController.h"

#import "AIRetrievePasswordViewController.h"
#import "AIBBIdAssitant.h"
#import "UserInfo.h"

@interface LoginViewController ()
{
    BOOL islogin;
    int heightdvi;
    
    NSMutableArray *userNameArr;
    TableViewWithBlock *tb;
    BOOL isOpen;
    BOOL isDelete;
    BOOL _keyboardIsVisible;
    BOOL isSelect;
    
}
@end

@implementation LoginViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    } return self;
}
#pragma mark - life circle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"login.login",@"title");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeNNC) name:@"NCC_Login_AddressBook" object:nil];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserName) name:@"NNS_Delete_UserName" object:nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center  addObserver:self selector:@selector(keyboardDidShow)  name:UIKeyboardDidShowNotification  object:nil];
    [center addObserver:self selector:@selector(keyboardDidHide)  name:UIKeyboardWillHideNotification object:nil];
    _keyboardIsVisible = NO;
    
    self.hidesBottomBarWhenPushed = YES;
    
    [self ui];
    
    [PublicCURD createPublicDataBase];
    [PublicCURD createPublicTable];
    
    //isOpen=YES;
    isDelete=NO;
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:@"Notification_Load_OK" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailure) name:@"NSN_Login_Failure" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Notification_Load_OK" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NSN_Login_Failure" object:nil];
    
    isSelect = NO;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Notification_Load_OK" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NCC_Login_AddressBook" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NSN_Login_Failure" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNS_Delete_UserName" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (CHAppDelegate *)appDelegate
{
    return (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma mark -UI
-(void)ui{
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        heightdvi=64;
    }else{
        heightdvi=0;
    }
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    
    self.view.backgroundColor = Controller_View_Color;
    
    //登录账号输入框
    userTextField = [[BBTextField alloc]initWithFrame:CGRectMake(20, 30, KCurrWidth - 40, INPUT_TEXT_FIELD_HEIGHT) Icon:[self imageViewForTextField:@"login_icon_user"]];
    userTextField.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    [userTextField setCustomPlaceholder:NSLocalizedString(@"login.userName",@"title")];
    userTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userTextField.font = kText_Font;
    userTextField.backgroundColor = AB_White_Color;
    //userTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //userTextField.textAlignment = NSTextAlignmentLeft;
    userTextField.keyboardType = UIKeyboardTypeASCIICapable;
    //userTextField.leftView = [self imageViewForTextField:@"login_icon_user"];
  
    //userTextField.leftViewMode = UITextFieldViewModeAlways;
    userTextField.delegate = self;
    [userTextField setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"account"]];
    userTextField.textColor = AB_Gray_Color;
    userTextField.layer.cornerRadius = 3.0;
    userTextField.layer.borderWidth = 0.5;
    userTextField.layer.borderColor = Normal_Border_Color.CGColor;
    [self.view addSubview:userTextField];
    
    
//    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom]; //账号记录
//    btn.frame=CGRectMake(KCurrWidth-80, 85, 70, 50);
//    [btn setImage:[UIImage imageNamed:@"v2_bt_titlebar_open.png"] forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(idList:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
    
    
    //密码输入框
    passTextField = [[BBTextField alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(userTextField.frame) + 20, KCurrWidth - 40, INPUT_TEXT_FIELD_HEIGHT) Icon:[self imageViewForTextField:@"login_icon_password"]];
    [passTextField setCustomPlaceholder:NSLocalizedString(@"login.password",@"title")];
    passTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passTextField.font = kText_Font;
    passTextField.backgroundColor = AB_White_Color;
    passTextField.delegate = self;
    passTextField.secureTextEntry = YES;
    //passTextField.leftView = [self imageViewForTextField:@"login_icon_password"];
    //passTextField.leftViewMode = UITextFieldViewModeAlways;
    passTextField.textColor = AB_Gray_Color;
    passTextField.layer.cornerRadius = 3.0;
    passTextField.layer.borderWidth = 0.5;
    passTextField.layer.borderColor = Normal_Border_Color.CGColor;
    [self.view addSubview:passTextField];
    
    //登录按钮
    btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLogin.frame = CGRectMake(20, CGRectGetMaxY(passTextField.frame) + 20, KCurrWidth - 40, INPUT_TEXT_FIELD_HEIGHT);
    btnLogin.layer.cornerRadius = 3.0;
    [btnLogin setTitle:NSLocalizedString(@"login.login",@"title") forState:UIControlStateNormal];
    [btnLogin setBackgroundColor:AB_Red_Color];
    btnLogin.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    btnLogin.titleLabel.textColor = AB_White_Color;
    [btnLogin addTarget:self action:@selector(LoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLogin];
    
    //忘记密码按钮
    btnLab=[UIButton buttonWithType:UIButtonTypeSystem];
    btnLab.frame=CGRectMake(27, CGRectGetMaxY(btnLogin.frame) + 10, KCurrWidth - 40, 20);
    [btnLab setTitle:NSLocalizedString(@"login.forgotPassword",@"title") forState:UIControlStateNormal];
    [btnLab setTitleColor:kMainColor forState:UIControlStateNormal];
    [btnLab addTarget:self action:@selector(clickLab:) forControlEvents:UIControlEventTouchUpInside];
    btnLab.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    btnLab.titleLabel.textColor = AB_Blue_Color;
    [self.view addSubview:btnLab];
    
    //注册按钮
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    registerButton.bounds = CGRectMake(0, 0, 100, 30);
    CGPoint center = CGPointMake(Screen_Width / 2, Screen_Height - 40 - 64);
    registerButton.center = center;
    
    registerButton.layer.cornerRadius = 3.0;
    [registerButton setTitle:NSLocalizedString(@"login.signUp",@"action") forState:UIControlStateNormal];
    registerButton.titleLabel.font = kText_Font;
    registerButton.titleLabel.textColor = AB_Gray_Color;
    registerButton.layer.borderWidth = 0.5;
    [registerButton setTitleColor:kMainColor7 forState:UIControlStateNormal];
    registerButton.layer.borderColor = Normal_Border_Color.CGColor;
    registerButton.backgroundColor = AB_White_Color;
    [registerButton addTarget:self action:@selector(clickRegistered:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:registerButton];
}

- (UIImageView *)imageViewForTextField:(NSString *)imageName {
    
    UIImageView *imageView = [[UIImageView alloc] init];
    //imageView.bounds = CGRectMake(0, 0, 28, 20);
    //imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageWithName:imageName];
    [imageView sizeToFit];
    return imageView;
}

//接收通知，刷新相关信息
-(void)refreshUserName{
    userNameArr = [UserNameCRUD selectIDtable];//查询表数据
}

//- (void)LoginButtonTouchDown{
//    btnLogin.backgroundColor = kMainColor5;
//}


-(void)deleteUserName:(NSString *)cellText{
    isDelete=YES;
    tb.tag = UITableViewCellEditingStyleDelete;//删除状态：以tag值来传递编辑状态
    [tb setEditing:tb.isEditing animated:YES];
}

-(void)deleteSuccess:(NSNotification *)notification{
    NSString *getsendValue = [[notification userInfo] valueForKey:@"sendKey"];
    if ([userTextField.text isEqualToString:getsendValue]) {
        userTextField.text=@"";
    }
}
//登录成功加载完数据跳转
-(void)load_next{
    [DejalBezelActivityView activityViewForView:self.view];
}


//15秒后未连接
- (void)loginReconnection:(NSTimer *)timer {
    
    if ([XMPPServer sharedServer].isLogin) {
        [timer invalidate];
        timer = nil;
        return;
    }else{
        [[XMPPServer sharedServer]connect];
        [timer invalidate];
        timer = nil;
    }
}



-(void)loginSuccess{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Notification_Load_OK" object:nil];

    //[self permissionsAddressBook];

    //数据初始化等待时间
    int timeInt = 0;
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_LoginStatus"] isEqualToString:@"login_out"]) {
        timeInt = 0;
     }
    
    [self performSelector:@selector(loginLoadOK) withObject:nil afterDelay:timeInt];
}

//登录失败
-(void)loginFailure{
    [DejalBezelActivityView removeViewAnimated:YES];
    
    JLTipsView* tipView = [[JLTipsView alloc] initWithTip:@"密码错误"];
    [tipView showInView:self.view animated:YES autoRelease:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"confirmPassword"];
    [defaults removeObjectForKey:@"password"];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"login.userNameOrPasswordError",@"message") delegate:nil cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
//    [alert show];
}

-(void)loginLoadOK{
       [DejalBezelActivityView removeViewAnimated:YES];
   

        //数据加载进度
        //FirstLoadDataProgressViewController *firstLoadDataProgressVC = [[FirstLoadDataProgressViewController alloc] init];
        //[self.navigationController presentViewController:firstLoadDataProgressVC animated:NO completion:nil];

  
      //加载主界面
      [[self appDelegate] ui];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -private
//登录
- (void)LoginButton:(id)sender {
    
    JLLog_D("Start login");
    
    [userTextField resignFirstResponder];
    [passTextField resignFirstResponder];
    
    bool isOk = [self validateWithUser:userTextField.text andPass:passTextField.text];
    
    if(!isOk){
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:NSLocalizedString(@"public.alert.pleaseEnterAccount",@"message")];
        [tipView showInView:self.view animated:YES autoRelease:YES];
        return;
    }
    
    if (![self isConnectionAvailable]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"public.alert.networkConnectionFailure",@"message")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title")  otherButtonTitles:nil , nil];
        [alert show];
        
        return;
    }
    
    [self load_next];
    
    [AIBBIdAssitant bbIdWithAccount:userTextField.text success:^(NSString *bbID) {
        if (bbID) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:bbID forKey:@"userName"];
            [defaults setObject:passTextField.text forKey:@"password"];
            [defaults setObject:userTextField.text forKey:@"account"];
                
            [defaults synchronize];//保存
            //数据库初始化
            [PublicCURD createDataBase];
            [PublicCURD createAllTable];
            [PublicCURD updateTable];
                
            [[XMPPServer sharedServer] connect];
            
        }else {
            [DejalBezelActivityView removeViewAnimated:YES];
            
            JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"用户名不存在"];
            [tipView showInView:self.view animated:YES autoRelease:YES];
        }
        
    } failure:^(NSError *error) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        JLTipsView* tipView = [[JLTipsView alloc] initWithTip:@"登录出现问题，请重试"];
        [tipView showInView:self.view animated:YES autoRelease:YES];
    }];
}

//忘记密码
-(void)clickLab:(UIButton *)sender{
    JLLog_D("Button got password clicked");
    [self retrievePassword];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)retrievePassword {
    
    AIRetrievePasswordViewController *controller = [[AIRetrievePasswordViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}
///////////////////////////////////////////////////////////////////////////////////////////////////

//注册跳转
-(void)clickRegistered:(UIButton *)sender{
    [self clickBtnPhoneNumRegistered];
}


//记录账号下拉
-(void)idList:(id)sender{
    isDelete=YES;
    
    [tb setEditing:tb.isEditing animated:YES];
    
    if ([self keyboardIsVisible]) {
        [userTextField resignFirstResponder];
        [passTextField resignFirstResponder];
    }
    /*
     if (isOpen) {
     [self selectIDtable];//查询表数据
     
     [UIView animateWithDuration:0.3 animations:^{
     tb.tag = UITableViewCellEditingStyleNone;//删除状态：以tag值来传递编辑状态
     [tb setEditing:!tb.isEditing animated:YES];
     
     CGRect frame=tb.frame;
     [tb reloadData];
     frame.size.height=[arr count]*30;
     if (frame.size.height>120) {
     frame.size.height=120;
     }
     [tb setFrame:frame];
     } completion:^(BOOL finished){
     
     isOpen=YES;
     }];
     }else{
     
     [UIView animateWithDuration:0.3 animations:^{
     
     CGRect frame=tb.frame;
     frame.size.height=0;
     [tb setFrame:frame];
     
     } completion:^(BOOL finished){
     
     isOpen=NO;
     }];
     }
     */
    if (isOpen) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame=tb.frame;
            frame.size.height=0;
            [tb setFrame:frame];
            
        } completion:^(BOOL finished){
            
            isOpen=NO;
        }];
    }else{
        
        //只查一次
        if (!isSelect) {
            userNameArr = [UserNameCRUD selectIDtable];//查询表数据
            isSelect = YES;;
        }
        
        
        [UIView animateWithDuration:0.3 animations:^{
            if (isDelete) {
                tb.tag = UITableViewCellEditingStyleNone;//删除状态：以tag值来传递编辑状态
                [tb setEditing:NO animated:YES];
                
                isDelete=NO;
            }
            
            CGRect frame=tb.frame;
            [tb reloadData];
            frame.size.height=[userNameArr count]*55;
            if (frame.size.height>200) {
                frame.size.height=200;
            }
            [tb setFrame:frame];
        } completion:^(BOOL finished){
            
            isOpen=YES;
        }];
    }
    
}

//密码长度校验
-(BOOL)validateWithUser:(NSString *)userText andPass:(NSString *)passText{
    return userText.length > 0 && passText.length > 0;
}

#pragma mark -
#pragma mark 触摸背景来关闭虚拟键盘
-(void)backgroundTap:(id)sender{
    [UIView beginAnimations:@"Curl"context:nil];//动画开始
    [UIView setAnimationDuration:0.30];
    [UIView setAnimationDelegate:self];
    [userTextField resignFirstResponder];
    [passTextField resignFirstResponder];
    [UIView commitAnimations];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{  //string就是此时输入的那个字符 textField就是此时正在输入的那个输入框 返回YES就是可以改变输入框的值 NO相反
    
    if ([string isEqualToString:@"\n"] || [string isEqualToString:@" "])  //按会车可以改变
    {
        return NO;
    }else{
        
        if (userTextField.text.length<=1) {
            [logoView setImage:nil];
        }
        
        return YES;
    }
}

//Email retrieve password
-(void)toEmail{
    ToEmailViewController *toEamilView=[[ToEmailViewController alloc]init];
    [self.navigationController pushViewController:toEamilView animated:YES];
}

//Phone retrieve password
-(void)toPhoneNum{
    ToPhoneNumViewController *toPhoneView=[[ToPhoneNumViewController alloc]init];
    [self.navigationController pushViewController:toPhoneView animated:YES];
}

//Problem retrieve password
-(void)toProblem{
    ToProblemViewController2 *toProblem=[[ToProblemViewController2 alloc]init];
    [self.navigationController pushViewController:toProblem animated:YES];
}

//手机号码注册
- (void)clickBtnPhoneNumRegistered {
    PhoneNumRegisteredViewController *phoneNumView=[[PhoneNumRegisteredViewController alloc]init];
    phoneNumView.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //UINavigationController *nav=[[[UINavigationController alloc]initWithRootViewController:phoneNumView] autorelease];
    //self.view.window.rootViewController=nav;
    
    UIBarButtonItem*backItem = [[UIBarButtonItem alloc] init];
    backItem.title=@""; 
//    [backItem setImage:[UIImage imageNamed:@"header_button_back"]];//更改背景图片
    self.navigationItem.backBarButtonItem=backItem;
    
    [self.navigationController pushViewController:phoneNumView animated:YES];
    
}

//比较两时间
- (NSString *)intervalFromLastDate: (NSString *) dateString1 toTheDate:(NSString *) dateString2
{
    NSArray *timeArray1=[dateString1 componentsSeparatedByString:@"."];
    dateString1=[timeArray1 objectAtIndex:0];
    NSArray *timeArray2=[dateString2 componentsSeparatedByString:@"."];
    dateString2=[timeArray2 objectAtIndex:0];
    //NSLog(@"%@.....%@",dateString1,dateString2);
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d1=[date dateFromString:dateString1];
    NSTimeInterval late1=[d1 timeIntervalSince1970]*1;
    NSDate *d2=[date dateFromString:dateString2];
    NSTimeInterval late2=[d2 timeIntervalSince1970]*1;
    NSTimeInterval cha=late2-late1;
    NSString *timeString=@"";
    NSString *house=@"";
    // NSString *min=@"";
    // NSString *sen=@"";
    
    // sen = [NSString stringWithFormat:@"%d", (int)cha%60];
    // min = [min substringToIndex:min.length-7];
    // 秒
    // sen=[NSString stringWithFormat:@"%@", sen];
    // min = [NSString stringWithFormat:@"%d", (int)cha/60%60];
    // min = [min substringToIndex:min.length-7];
    // 分
    //min=[NSString stringWithFormat:@"%@", min];
    // 小时
    house = [NSString stringWithFormat:@"%d", (int)cha/3600];
    // house = [house substringToIndex:house.length-7];
    house=[NSString stringWithFormat:@"%@", house];
    timeString=[NSString stringWithFormat:@"%@",house];
    return timeString;
}


//检测是否存在网络
-(BOOL) isConnectionAvailable{
    
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            //@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            //@"3G");
            break;
    }
    return isExistenceNetwork;
}



#pragma marm 键盘
- (void)keyboardDidShow
{
    _keyboardIsVisible = YES;
}

- (void)keyboardDidHide
{
    _keyboardIsVisible = NO;
}

- (BOOL)keyboardIsVisible
{
    return _keyboardIsVisible;
}

@end
