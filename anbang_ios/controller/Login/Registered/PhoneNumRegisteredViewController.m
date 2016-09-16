//
//  PhoneNumRegisteredViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//
//  手机号码注册

#import "PhoneNumRegisteredViewController.h"
#import "RegisteredViewController.h"
#import "FKRHeaderSearchBarTableViewController.h"
#import "CHAppDelegate.h"
#import "PhoneNumCodeViewController.h"
#import "PhoneNumValidationViewController.h"
#import "LoadingViewController.h"
#import "AISucceedViewController.h"
#import "AIRegex.h"
#import "DejalActivityView.h"

#import "AIMailRegisterViewController.h"
#import "AIRetrievePasswordViewController.h"
#import "AIUIWebViewController.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
#define kText_Font  [UIFont systemFontOfSize:13.0]

#define MARGIN_LEFT_RIGHT  16
#define MARGIN_TOP_BOTTOM  15
#define INPUT_TEXT_FIELD_HEIGHT   40
#define ROW_HEIGHT (INPUT_TEXT_FIELD_HEIGHT + MARGIN_TOP_BOTTOM * 1.0)
///////////////////////////////////////////////////////////////////////////////////////////////////

@interface PhoneNumRegisteredViewController ()
{
}
@end

@implementation PhoneNumRegisteredViewController
///////////////////////////////////////////////////////////////////////////////////////////////////
{
    UITextField *mPhoneTextField;
    UITextField *mCodeTextField;
    UITextField *mSecretTextField;
    UITextField *mReScrectTextField;
    UILabel     *mTicksLabel;
    UITextField *mNickNameField;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
@synthesize tableView=_tableView;
@synthesize countryCode=_countryCode;
@synthesize countryName=_countryName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iphoneNumUse) name:@"theRegister" object:nil];
    }
    return self;
}

- (void)backMove2:(UIButton *)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    JLLog_D("Loading phone number register view controller");
    
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"header_button_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backMove2:)];
    
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countryCode:) name:@"NNC_Country_Code" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countryName:) name:@"NNC_Country_Name" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(validatePhoneNumError:) name:@"NNC_Validate_PhoneNum_Error" object:nil];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(nextPhoneCodeVC:) name:@"NNC_Validate_PhoneNum_Success" object:nil];
    
    
    
    //手机号码注册
    self.title=NSLocalizedString(@"phoneNumRegistered.title",@"title");
    strarrayCode=NSLocalizedString(@"phoneNumRegistered.title",@"title");
    
//    [self ui];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"anonymouss" forKey:@"userName"];
    [defaults setObject:nil forKey:@"password"];
    [[XMPPServer sharedServer]connect];

///////////////////////////////////////////////////////////////////////////////////////////////////
    [self setupController];
///////////////////////////////////////////////////////////////////////////////////////////////////
    
    
//    _tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight) style:UITableViewStylePlain];
//    _tableView.dataSource = self;
//    _tableView.delegate = self;
//    _tableView.scrollsToTop = YES;
//    [self.view addSubview:_tableView];
//    //[_tableView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
//    [self setExtraCellLineHidden:_tableView];
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        [_tableView setSeparatorInset:(UIEdgeInsetsMake(0, 0, 0, 0))];
//    }
//    
//    //86
//    _countryCode = NSLocalizedString(@"public.defaultConuntryCode",@"title");
//    //中国
//    _countryName = NSLocalizedString(@"public.defaultCountry",@"title");
    
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark By me
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)){
        self.navigationController.navigationBar.translucent = NO;
    }
    
}

- (void)setupController {
    
    self.countryCode = @"86";
    [[NSUserDefaults standardUserDefaults] setObject:_countryCode forKey:@"countrycode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setupNavigationPreference];
    
    [self keyboardNotificaitonInitialize];
    
    CGRect rect = CGRectMake(0, 0, Screen_Width, Screen_Height - 64);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:rect];
    scrollView.contentSize = CGSizeMake(Screen_Width, Screen_Height - 49);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = Controller_View_Color;
    [self.view addSubview:scrollView];
    mScrollView = scrollView;
    mScrollView.delegate = self;
    
    UIView *contentView = [self contentListView];
    [mScrollView addSubview:contentView];
}

- (void)setupNavigationPreference {
    
    self.title = NSLocalizedString(@"phoneNumRegistered.title",@"title");
//    self.navigationItem.hidesBackButton = YES;
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.bounds = CGRectMake(0, 0, 30, 30);
//    [button setImage:[UIImage imageNamed:@"header_button_back"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(backForword:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
//    [self.navigationItem setBackBarButtonItem:item];
}

- (void)backForword:(UIButton *)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardNotificaitonInitialize {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)note {
    
    mKeyboardHidden = NO;
    
    CGFloat selectedRow = (mActiveField.frame.origin.y + INPUT_TEXT_FIELD_HEIGHT) / (ROW_HEIGHT);
    if (selectedRow < 2) {
        return;
    }
    CGPoint contentOffset = CGPointMake(0, ROW_HEIGHT * (selectedRow - 2));
    if (IS_3_5Inch) {
        
        [mScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)note {
    
    mKeyboardHidden = YES;
}

- (UIView *)contentListView {
    
    UIView * contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - 64);
    
    UITextField *textField_row_1 = [self createInRow:1 leftImage:@"regist_icon_phonenumber" holder:@"请输入您的手机号"];
    textField_row_1.keyboardType = UIKeyboardTypeNumberPad;
    [contentView addSubview:textField_row_1];
    mPhoneTextField = textField_row_1;
    
    UITextField *textField_row_2 = [self codeAuthentiateRowViewInView:contentView row:2];
    textField_row_2.keyboardType = UIKeyboardTypeNumberPad;
    [contentView addSubview:textField_row_2];
    mCodeTextField = textField_row_2;
    
    UITextField *textfield_row_3 = [self createInRow:3 leftImage:@"login_icon_password" holder:@"设置您的密码"];
    textfield_row_3.secureTextEntry = YES;
    [contentView addSubview:textfield_row_3];
    mSecretTextField = textfield_row_3;
    
    UITextField *textField_row_4 = [self createInRow:4 leftImage:@"login_icon_password" holder:@"再次输入密码"];
    textField_row_4.secureTextEntry = YES;
    [contentView addSubview:textField_row_4];
    mReScrectTextField = textField_row_4;
    
    UITextField *textField_row_5 = [self createInRow:5 leftImage:@"login_icon_user" holder:@"设置您的昵称"];
    [contentView addSubview:textField_row_5];
    mNickNameField = textField_row_5;
    
    UIButton *btnRegister_row_5 = [self buttonRegisterInRow:6];
    [contentView addSubview:btnRegister_row_5];
    
    UIView *view_row_6 = [self tipForProtocolView:7];
    [contentView addSubview:view_row_6];
    
    UIButton* btnFooter = [self btnToMailRegisterInView:contentView];
    [contentView addSubview:btnFooter];
    
    return contentView;
}

- (UITextField *)createInRow:(int)row leftImage:(NSString *)image holder:(NSString *)holder {
    
    CGFloat row_y = ROW_HEIGHT * (row - 1);
    CGFloat tf_y = row_y + MARGIN_TOP_BOTTOM;
    CGFloat tf_w = Screen_Width - MARGIN_LEFT_RIGHT * 2;
    CGRect tf_rect = CGRectMake(MARGIN_LEFT_RIGHT, tf_y, tf_w, INPUT_TEXT_FIELD_HEIGHT);
    
    UIImageView * imageView = [[UIImageView alloc] init];
    //imageView.frame = CGRectMake(0, 0, 30, 20);
    //imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageWithName:image];
    [imageView sizeToFit];
    
    BBTextField * textField = [[BBTextField alloc] initWithFrame:tf_rect Icon:imageView];
    textField.delegate = self;
    //textField.leftView = imageView;
   // textField.leftViewMode = UITextFieldViewModeAlways;
    textField.font = kText_Font;
    textField.backgroundColor = AB_White_Color;
    textField.textColor = AB_Gray_Color;
    textField.layer.borderWidth = 0.5;
    textField.layer.cornerRadius = 3.0;
    textField.layer.borderColor = Normal_Border_Color.CGColor;
    [textField setCustomPlaceholder:holder];
    textField.returnKeyType = UIReturnKeyDefault;
    textField.enablesReturnKeyAutomatically = YES;
    
    return textField;
}

- (UITextField *)codeAuthentiateRowViewInView:(UIView *)view row:(int)row {
    
    CGFloat row_y = ROW_HEIGHT * (row - 1);
    
    // Firstly, right view .
    
    NSString *string = @"60秒后重新发送";
    CGSize size = [string sizeWithFont:kText_Font
                     constrainedToSize:CGSizeMake(MAXFLOAT, 0.0)
                         lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat lb_w = size.width + 5;
    CGFloat lb_x = Screen_Width - MARGIN_LEFT_RIGHT - lb_w;
    CGFloat lb_y = row_y + MARGIN_TOP_BOTTOM;
    CGRect rect = CGRectMake(lb_x, lb_y, lb_w, INPUT_TEXT_FIELD_HEIGHT);
    
    UIButton *btnGetCode = [UIButton buttonWithType:UIButtonTypeCustom];
    btnGetCode.frame = rect;
    btnGetCode.backgroundColor = kAppStyleColor;
    btnGetCode.layer.masksToBounds = YES;
    btnGetCode.layer.cornerRadius = 3.0;
    [btnGetCode setTitle:NSLocalizedString(@"phoneNumRegistered.verificationCode.title",@"title") forState:UIControlStateNormal];
    btnGetCode.titleLabel.font = kText_Font;
    [btnGetCode setTitleColor:AB_White_Color forState:UIControlStateNormal];
    btnGetCode.backgroundColor = AB_Red_Color;
    [btnGetCode addTarget:self action:@selector(getCode:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnGetCode];
    mBtnGetCode = btnGetCode;
    
    // Then, Left view - UITextField.
    
    CGFloat tf_w = Screen_Width - MARGIN_LEFT_RIGHT * 3 - lb_w;
    rect = CGRectMake(MARGIN_LEFT_RIGHT, lb_y, tf_w, INPUT_TEXT_FIELD_HEIGHT);
    
    BBTextField * textField = [[BBTextField alloc] init];
    textField.frame = rect;
    //textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.font = kText_Font;
    [textField setCustomPlaceholder:NSLocalizedString(@"phoneNumRegistered.verificationCode.enterVerificationCode",@"title")];
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyDefault;
    textField.enablesReturnKeyAutomatically = YES;
    textField.backgroundColor = AB_White_Color;
    textField.textColor = AB_Gray_Color;
    textField.layer.borderWidth = 0.5;
    textField.layer.cornerRadius = 3.0;
    textField.layer.borderColor = Normal_Border_Color.CGColor;
    
    return textField;
}

- (UIButton *)buttonRegisterInRow:(int)row {
    
    CGFloat row_y = ROW_HEIGHT * (row - 1);
    CGFloat tf_y = row_y + MARGIN_TOP_BOTTOM;
    CGFloat tf_w = Screen_Width - MARGIN_LEFT_RIGHT * 2;
    CGRect tf_rect = CGRectMake(MARGIN_LEFT_RIGHT, tf_y, tf_w, INPUT_TEXT_FIELD_HEIGHT);
    
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btnRegister.frame = tf_rect;
    btnRegister.layer.masksToBounds = YES;
    btnRegister.layer.cornerRadius = 3.0;
    btnRegister.backgroundColor = AB_Red_Color;
    [btnRegister setTitleColor:AB_White_Color forState:UIControlStateNormal];
    [btnRegister setTitle:@"注册" forState:UIControlStateNormal];
    [btnRegister addTarget:self action:@selector(registerIn:) forControlEvents:UIControlEventTouchUpInside];
    
    return btnRegister;
}

- (UIButton *)btnToMailRegisterInView:(UIView *)view {
    
    CGFloat view_h = view.frame.size.height;
    CGFloat view_w = view.frame.size.width;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake(0, 0, 100, 30);
    CGPoint center = CGPointMake(view_w / 2, view_h - 30);
    button.center = center;
    [button setTitle:@"邮箱注册" forState:UIControlStateNormal];
    button.titleLabel.font = kText_Font;
    button.layer.borderWidth = 0.5;
    button.layer.borderColor = Normal_Border_Color.CGColor;
    button.layer.cornerRadius = 3.0;
    [button setTitleColor:AB_Gray_Color forState:UIControlStateNormal];
    button.backgroundColor = AB_White_Color;
    [button addTarget:self action:@selector(mailToRegister:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)registerIn:(UIButton *)sender {
    
    if (![self checkSecret]) {
        
        [self tipViewShow:@"两次密码输入不一致"];
        return;
    }
    else if (![AIRegex isPasswordFormat:mSecretTextField.text]) {
        return;
    }
    else if (mSecretTextField.text.length == 0) {
        
        [self tipViewShow:@"请输入您的密码"];
        return;
    }
    else if (mNickNameField.text.length == 0) {

        [self tipViewShow:@"请设置您的昵称"];
        return;
    }

    [self loadViewShow];
    
    [mScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    [self queryRosterPhoneNumCode];
}

- (void)tipViewShow:(NSString *)tip {
    
    JLTipsView * tipView = [[JLTipsView alloc] initWithTip:tip];
    [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES autoRelease:YES];
}

- (void)mailToRegister:(UIButton *)sender {
    
    UIBarButtonItem*backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    
    AIMailRegisterViewController *controller = [[AIMailRegisterViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)getCode:(UIButton *)sender {
    
    if (![AIRegex isPhoneNumberFromat:mPhoneTextField.text]) {
        
        JLTipsView *tipView = [[JLTipsView alloc]initWithTip:@"您输入的手机号码无效"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES autoRelease:YES];
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self clickRightButton];
    });
    
    [self changeToShowTicks:sender];
    
//    [self sendVerificationCode];
}

- (void)changeToShowTicks:(UIButton *)sender {
    
    sender.userInteractionEnabled = NO;
    
    CGRect rect = sender.frame;
    
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.layer.masksToBounds = YES;
    label.backgroundColor = Label_Back_Color;
    label.font = kText_Font;
    label.textColor = AB_Gray_Color;
    label.layer.cornerRadius = 3.0;
    label.layer.borderWidth = 0.5;
    label.layer.borderColor = AB_Gray_Color.CGColor;
    label.text = @"60秒后重新发送";
    label.textAlignment = NSTextAlignmentCenter;
    [sender.superview addSubview:label];
    mTicksLabel = label;
    
    mTicks = 60;
    mTimer =[NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(startTicks:)
                                           userInfo:self
                                            repeats:YES];
}

- (void)startTicks:(NSTimer *)timer {
    
    --mTicks;
    if (mTicks < 0 ) {
        [mTimer invalidate];
        [mTicksLabel removeFromSuperview];
        mBtnGetCode.userInteractionEnabled = YES;
        return;
    }
    
    mTicksLabel.text = [NSString stringWithFormat:@"%d秒后重新发送", mTicks];
}

- (void)ticksFinished {
    
    [mTimer invalidate];
    [mTicksLabel removeFromSuperview];
    mBtnGetCode.userInteractionEnabled = YES;
}

- (UIView *)tipForProtocolView:(int)row {
    
    NSString *string = @"点击注册代表您已同意邦邦社区注册协议";
    CGSize view_size = [string sizeWithFont:kText_Font
                          constrainedToSize:CGSizeMake(MAXFLOAT, 0.0)
                              lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat view_y = ROW_HEIGHT * (row - 1) + MARGIN_TOP_BOTTOM;
    CGFloat view_x = Screen_Width / 2 - view_size.width / 2;
    CGRect rect = CGRectMake(view_x, view_y, view_size.width, view_size.height);
    UIView *view = [[UIView alloc] initWithFrame:rect];
    
    string = @"点击注册代表您已同意";
    CGSize label_size = [string sizeWithFont:kText_Font
                           constrainedToSize:CGSizeMake(MAXFLOAT, 0.0)
                               lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, label_size.width, label_size.height)];
    label.text = string;
    label.font = kText_Font;
    label.textColor = AB_Gray_Color;
    [view addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGFloat btn_x = CGRectGetMaxX(label.frame);
    CGFloat btn_w = view_size.width - label_size.width;
    button.frame = CGRectMake(btn_x, 1, btn_w, label_size.height);
    [button setTitle:@"邦邦社区注册协议" forState:UIControlStateNormal];
    button.titleLabel.font = kText_Font;
    [button setTitleColor:AB_Blue_Color forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showRegisterAgreement:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    return view;
}

- (void) showRegisterAgreement:(id)sender
{
    AIUIWebViewController *controller = [[AIUIWebViewController alloc] init];
    controller.resource = @"clause_zh";
    controller.webViewTitle = @"邦邦社区注册协议";
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [mScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    mActiveField = nil;
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if(textField == mActiveField || mActiveField == nil) {
        mActiveField = textField;
        return YES;
    }
    
    mActiveField = textField;
    if (!mKeyboardHidden) {
        [self keyboardWillShow:nil];
    }
    
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    mKeyboardHidden = YES;
    [mActiveField resignFirstResponder];
    mActiveField = nil;
    [mScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
//    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (BOOL)checkSecret {
    
    return [mSecretTextField.text isEqualToString:mReScrectTextField.text] ? YES : NO;
}

- (void)registeredSuccess {
    
    JLLog_D(@"Register succeed <phone=%@>", mPhoneTextField.text);
    
    [self loadViewHide];
    
    JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"注册完成"];
    [tipView showInView:self.view.window animated:YES];
    
//    LoadingViewController *load=[[LoadingViewController alloc]init];
//    //    [self presentModalViewController:load animated:YES];
//    [self presentViewController:load animated:YES completion:^{}];
    
    [[NSUserDefaults standardUserDefaults] setObject:mPhoneTextField.text forKey:@"account"];
    
    AISucceedViewController *controller = [[AISucceedViewController alloc] init];
    controller.isRegisterSucceed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)loadViewShow {
    
    [self.view endEditing:YES];
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)loadViewHide {
    
    [self.view endEditing:NO];
    [DejalBezelActivityView removeViewAnimated:YES];
}

#pragma mark
#pragma mark Copy

//发送手机号码和验证码进行注册
-(void)queryRosterPhoneNumCode{
    if (mCodeTextField.text.length<1) {
        
        [self loadViewHide];
        
        [self ticksFinished];
        
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"phoneNumRegistered.verificationCode.enterVerificationCode",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.prompt",@"title") otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionNotify:) name:@"validate_code" object:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self validateCode];
            
        });
    }
}

-(void)actionNotify:(NSNotification *)notify
{
    [self loadViewHide];
    
    NSMutableDictionary * dic = (NSMutableDictionary*)notify.object;
    if (dic==nil) {
        return;
    }
    if ([@"yes" isEqualToString:[dic objectForKey:@"validate"]] ) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registeredSuccess) name:@"NSN_Registered_Success" object:nil];
        [self registerRequest];
    }
    else
    {
        NSString *text = [dic objectForKey:@"text"];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:text delegate:nil cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
        [alertView show];
    }
     
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"validate_code" object:nil];
    
}

-(void)validateCode
{
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"validate_code"];
    XMPPElement *query = [XMPPElement elementWithName:@"query" URI:@"http://www.nihualao.com/xmpp/anonymous/phone/validateCode"];
    XMPPElement *phone = [XMPPElement elementWithName:@"phone" stringValue:[[NSUserDefaults standardUserDefaults]stringForKey:@"phonenum"]];
    [phone addAttributeWithName:@"countryCode" stringValue:[[NSUserDefaults standardUserDefaults]stringForKey:@"countrycode"]];
    XMPPElement *validateCode  = [XMPPElement elementWithName:@"validateCode" stringValue:mCodeTextField.text];
    [query addChild:phone];
    [query addChild:validateCode];
    [iq addChild:query];
    //NSLog(@"****%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    //NSLog(@"fighting:%@",iq);
}

- (void)registerRequest {
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/anonymous/register/phone"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:mPhoneTextField.text];
    NSXMLElement *password = [NSXMLElement elementWithName:@"password" stringValue:mSecretTextField.text];
    NSXMLElement *code=[NSXMLElement elementWithName:@"validateCode" stringValue:mCodeTextField.text];
    NSXMLElement *nickname=[NSXMLElement elementWithName:@"name" stringValue:mNickNameField.text];
    [phone addAttributeWithName:@"countryCode" stringValue:[[NSUserDefaults standardUserDefaults]stringForKey:@"countrycode"]];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"phoneNumCode"];
    [queryElement addChild:nickname];
    [queryElement addChild:phone];
    [queryElement addChild:password];
    [queryElement addChild:code];
    [iq addChild:queryElement];
    [[XMPPServer xmppStream] sendElement:iq];
}

#pragma mark
#pragma mark End copy



///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark end
///////////////////////////////////////////////////////////////////////////////////////////////////


- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
}

-(void)ui{
    int height =64;
    
    //下一步
    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"phoneNumRegistered.nextStep",@"action") style:UIBarButtonItemStylePlain target:self action:@selector(clickRightButton)];
    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];
    
    //[self.view addSubview:label];
    
    /*******************国际手机区号*************************
     codeView=[[UIView alloc]initWithFrame:CGRectMake(10, height+60, 300, 30)];
     [codeView setBackgroundColor:[UIColor lightGrayColor]];
     [self.view addSubview:codeView];
     btnCode=[[UIButton alloc]initWithFrame:CGRectMake(1, 1, 80, 28)];
     btnCode.backgroundColor=[UIColor whiteColor];
     [btnCode addTarget:self action:@selector(clickCodeButton) forControlEvents:UIControlEventTouchUpInside];
     
     [btnCode setTitle:@"86" forState:UIControlStateNormal];
     [[NSUserDefaults standardUserDefaults]setObject:btnCode.titleLabel.text forKey:@"btnCode"];
     [[NSUserDefaults standardUserDefaults]synchronize];
     [btnCode setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1] forState:UIControlStateNormal];
     [codeView addSubview:btnCode];
     btnCountries=[[UIButton alloc]initWithFrame:CGRectMake(82, 1, 217, 28)];
     btnCountries.backgroundColor=[UIColor whiteColor];
     
     
     [btnCountries setTitle:@"中国" forState:UIControlStateNormal];
     [btnCountries setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1] forState:UIControlStateNormal];
     [btnCountries addTarget:self action:@selector(clickCodeButton) forControlEvents:UIControlEventTouchUpInside];
     [codeView addSubview:btnCountries];
     */
    //
    //
    txtFieldName.delegate = self;
    txtFieldName=[[UITextField alloc]initWithFrame:CGRectMake(10, 10, KCurrWidth-30, 30)];
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
    return 3;
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
        //选择国家地区区号，输入手机号码
        cell.textLabel.text = NSLocalizedString(@"phoneNumRegistered.tableViewTItle",@"title");
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.frame = CGRectMake(0 , 0, 300, 80);
        cell.textLabel.numberOfLines =0;
        cell.textLabel.lineBreakMode= NSLineBreakByCharWrapping;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        
        
        
    }else if(indexPath.row==1){
        //国家区号
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@",@"+", _countryCode];
        UILabel *countryLabel = [[UILabel alloc]initWithFrame:CGRectMake(KCurrWidth-250, 0, 200, 55)];
        countryLabel.text= _countryName;
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
        
        [txtFieldName setKeyboardType:UIKeyboardTypeNumberPad];
        txtFieldName.clearButtonMode = UITextFieldViewModeWhileEditing;
        //手机号码
        [txtFieldName setPlaceholder:NSLocalizedString(@"phoneNumRegistered.phoneNumber",@"title")];
        //设置字体颜色
        txtFieldName.textColor = [UIColor blackColor];
        txtFieldName.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        [txtFieldName becomeFirstResponder] ;
        
        [cell addSubview:txtFieldName];
        
        cell.layer.borderWidth = 0;
        
    }else if(indexPath.row==3){
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        
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
        [self clickCodeButton];
    }else if (section==0 && row==2) {
    }
}


//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 60;
    }else if (indexPath.row==3) {
        return 40;
    }else if(indexPath.row==4){
        return 40;
    }else{
        return 50;
    }
}



-(void)iphoneNumUse{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:mPhoneTextField.text forKey:@"phonenum"];
    [defaults setObject:_countryCode forKey:@"countrycode"];
    
    [defaults synchronize];//保存
//    if (![self isMobileNumber:txtFieldName.text]) {
//        //手机号码错误
//        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"phoneNumRegistered.mobilePhoneNumberInputErrors",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil,nil];
//        alertView.tag=10001;
//        [alertView show];
//        [alertView release];
//        return;
//    }
    NSString *url=[NSString stringWithFormat:@"%@/retrieve-auth?phone=%@&countryCode=%@",httpRequset,mPhoneTextField.text,_countryCode];
    NSLog(@"*******%@",url);
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (response==nil) {
        //网络为连接
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:NSLocalizedString(@"public.alert.networkConnectionFailure",@"message")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
            [alert show];
        });
        
        return;
    }else{
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        //NSString *msgInfo = [weatherDic objectForKey:@"msg"];
        int code = [[weatherDic objectForKey:@"code"] intValue];
        //NSLog(@"%d**********",code);
        if (code==0) {
            //您的号码已使 取回密码 继续注册
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//           AMSmoothAlertView *alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")
//                                                                               andText:@"用户已存在！"
//                                                                       andCancelButton:YES
//                                                                          forAlertType:AlertSuccess];
//            [alert.defaultButton setTitle:@"取回密码" forState:UIControlStateNormal];
//            alert.completionBlock = ^void (AMSmoothAlertView *alertObj, UIButton *button) {
//                if(button == alertObj.defaultButton) {
//                    
//                    AIRetrievePasswordViewController *controller = [[AIRetrievePasswordViewController alloc] init];
//                    [self.navigationController pushViewController:controller animated:YES];
//                    
//                }
//            };
//            alert.cornerRadius = 3.0;
//            
//            [alert show];
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")   message:NSLocalizedString(@"phoneNumRegistered.phoneNumberUsed",@"message")   delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"phoneNumRegistered.retrievePassword",@"action"), @"知道了", nil];
                alertView.tag=10002;
                [alertView show];
                [self ticksFinished];
            });
            
            return;
        }else{
            [self queryRosterPhoneNum];
            
        }
    }
}

-(void)validatePhoneNumError:(NSNotification *)message {
    
    [self ticksFinished];

    NSString *msg = [message object];
    
    JLTipsView *tipView = [[JLTipsView alloc] initWithTip:msg];
    [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

- (void)nextPhoneCodeVC:(NSNotification *)message{
    PhoneNumCodeViewController *phoneNumCodevView=[[PhoneNumCodeViewController alloc]init];
    [self.navigationController pushViewController:phoneNumCodevView animated:YES];
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
//发送发送手机号码, 获取验证码。
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
    NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:mPhoneTextField.text];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"phoneNum"];
    [phone addAttributeWithName:@"countryCode" stringValue:_countryCode];
    [queryElement addChild:phone];
    [iq addChild:queryElement];
    [[XMPPServer xmppStream] sendElement:iq];
}


//发送验证码
-(void)sendVerificationCode{
    /*
     <iq type=”set”>￼￼
     <query xmlns=”http://www.nihualao.com/xmpp/anonymous/phone/validate”>
     <phone countryCode=”国家码”>手机号</phone>
     </query>
     </iq>
     */
    NSXMLElement *queryElement =
        [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/anonymous/phone/validate"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:mPhoneTextField.text];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"verificationCode"];
    [phone addAttributeWithName:@"countryCode" stringValue:_countryCode];
    [queryElement addChild:phone];
    [iq addChild:queryElement];
    
    // NSLog(@"******%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
}

#pragma mark -Click
//返回注册页面
-(void)clickLeftButton
{
    RegisteredViewController *registeredView=[[RegisteredViewController alloc]init];
    [self presentViewController:registeredView animated:NO completion:nil];
    
}

//跳转国际手机区号
-(void)clickCodeButton{
    FKRHeaderSearchBarTableViewController *tableViewController = [[FKRHeaderSearchBarTableViewController alloc] initWithSectionIndexes:YES];
    [self.navigationController pushViewController:tableViewController animated:YES];
}

//注册进入服务
-(void)clickRightButton{
    [self iphoneNumUse]; //现检测手机号是否已经绑定用户
    
}
//键盘处理
- (IBAction)backgroundTop:(id)sender {
    [txtFieldName resignFirstResponder];
}

#pragma mark -NSNotificationCenter


//通知调用方法
- (void)countryCode:(NSNotification *)message{
    _countryCode= [message object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"back" object:nil];
    [_tableView reloadData];
}
- (void)countryName:(NSNotification *)message{
    _countryName= [message object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"back" object:nil];
    [_tableView reloadData];
}


#pragma mark - AlartView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==10002) {
        if (buttonIndex==0) {
            //通过手机找回密码
//            [self sendVerificationCode];
//            PhoneNumValidationViewController *phoneNumValidationView=[[PhoneNumValidationViewController alloc]init];
//            phoneNumValidationView.countryCode = _countryCode;
//            //phoneNumValidationView.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//            [self.navigationController pushViewController:phoneNumValidationView animated:YES];
            
///////////////////////////////////////////////////////////////////////////////////////////////////
            AIRetrievePasswordViewController *controller = [[AIRetrievePasswordViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
///////////////////////////////////////////////////////////////////////////////////////////////////
                  }
        else if (buttonIndex==1) {
//            [self sendVerificationCode];
//            PhoneNumCodeViewController *phoneNumCodevView=[[PhoneNumCodeViewController alloc]init];
//            
//            //phoneNumCodevView.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//            [self.navigationController pushViewController:phoneNumCodevView animated:YES];
          
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"theRegister" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NNC_Country_Code" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NNC_Country_Name" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NNC_Validate_PhoneNum_Error" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NNC_Validate_PhoneNum_Success" object:nil];

///////////////////////////////////////////////////////////////////////////////////////////////////
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NSN_Registered_Success" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
///////////////////////////////////////////////////////////////////////////////////////////////////
}
@end
