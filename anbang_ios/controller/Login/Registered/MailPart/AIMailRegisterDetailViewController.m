//
//  AIMailRegisterDetailViewController.m
//  anbang_ios
//
//  Created by rooter on 15-3-17.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIMailRegisterDetailViewController.h"
#import "LoadingViewController.h"
#import "AISucceedViewController.h"
#import "AIRegex.h"
#import "DejalActivityView.h"
#import "AIUIWebViewController.h"
#import "BBTextField.h"

#define kText_Font  [UIFont systemFontOfSize:13.0]

#define MARGIN_LEFT_RIGHT  16
#define MARGIN_TOP_BOTTOM  15
#define INPUT_TEXT_FIELD_HEIGHT   40
#define ROW_HEIGHT (INPUT_TEXT_FIELD_HEIGHT + MARGIN_TOP_BOTTOM * 1.0)

@interface AIMailRegisterDetailViewController () <UITextFieldDelegate, UIScrollViewDelegate>

@end

@implementation AIMailRegisterDetailViewController

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NSN_Mail_Registered_Success" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NSN_Mail_Registered_Fail" object:nil];
}

- (void)backMove2:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupController];
    
      self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"header_button_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backMove2:)];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)){
        self.navigationController.navigationBar.translucent = NO;
    }
    
}

- (void)setupController {
    
    self.view.backgroundColor = Controller_View_Color;
    
    [self setupNavigationPreference];
    
    [self notificaitonInitialize];
    
    CGRect rect = CGRectMake(0, 0, Screen_Width, Screen_Height - Both_Bar_Height);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:rect];
    scrollView.contentSize = CGSizeMake(Screen_Width, Screen_Height - 49);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = AB_Color_f6f2ed;
    [self.view addSubview:scrollView];
    mScrollView = scrollView;
    mScrollView.delegate = self;
    
    UIView *contentView = [self contentListView];
    [mScrollView addSubview:contentView];
}

- (void)setupNavigationPreference {
    
    self.title = @"邮箱注册";
//    self.navigationItem.hidesBackButton = YES;
//    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.bounds = CGRectMake(0, 0, 30, 30);
//    [button setImage:[UIImage imageNamed:@"header_button_back"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(backForword:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationItem.leftBarButtonItem = item;
}

- (void)backForword:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)notificaitonInitialize {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [center addObserver:self selector:@selector(registerSuccess:) name:@"NSN_Mail_Registered_Success" object:nil];
    [center addObserver:self selector:@selector(registerFail:) name:@"NSN_Mail_Registered_Fail" object:nil];
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
    contentView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Both_Bar_Height);
    
    UILabel *textField_row_1 = [self headerLabel];
    [contentView addSubview:textField_row_1];
    
    UITextField *textField_row_2 = [self codeAuthentiateRowViewInView:contentView row:2];
    [contentView addSubview:textField_row_2];
    mCodeTextField = textField_row_2;
    
    UITextField *textfield_row_3 = [self createInRow:3 leftImage:@"login_icon_password" holder:@"设置您的密码"];
    textfield_row_3.secureTextEntry = YES;
    [contentView addSubview:textfield_row_3];
    mPasswordTextField = textfield_row_3;
    
    UITextField *textField_row_4 = [self createInRow:4 leftImage:@"login_icon_password" holder:@"再次输入密码"];
    textField_row_4.secureTextEntry = YES;
    [contentView addSubview:textField_row_4];
    mReinPasswordTextField = textField_row_4;
    
    UITextField *textField_row_5 = [self createInRow:5 leftImage:@"login_icon_user" holder:@"请设置您的昵称"];
    [contentView addSubview:textField_row_5];
    mNickNameField = textField_row_5;
    
    UIButton *btnRegister_row_5 = [self buttonRegisterInRow:6];
    [contentView addSubview:btnRegister_row_5];
    
    UIView *view_row_6 = [self tipForProtocolView:7];
    [contentView addSubview:view_row_6];
    
    return contentView;
}

- (UILabel *)headerLabel {
    
    NSString *headerTip = [self headerTipHandle];
    
    CGFloat lb_w = Screen_Width - 4 * MARGIN_LEFT_RIGHT;
    CGFloat lc_x = MARGIN_LEFT_RIGHT * 2;
    CGRect rect = CGRectMake(lc_x, MARGIN_TOP_BOTTOM, lb_w, INPUT_TEXT_FIELD_HEIGHT);
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.font = kText_Font;
    label.textColor = AB_Gray_Color;
    label.numberOfLines = 0;
    label.text = headerTip;
    label.textColor = AB_Gray_Color;
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    return label;
}

- (NSString *)headerTipHandle {
    
    NSMutableString *string = [NSMutableString string];
    
    NSRange range = [self.mailAddress rangeOfString:@"@"];
    NSString *emailNumber = [self.mailAddress substringToIndex:range.location];
    NSString *emailCom = [self.mailAddress substringFromIndex:range.location];
    
    [string appendString:[emailNumber substringToIndex:4]];
    [string appendString:@"****"];
    [string appendString:emailCom];
    
    NSString *reString = [NSString stringWithFormat:@"我们已向%@发送了一封包含验证码的邮件，请注意查收", string];
    
    return  reString;
}

- (UITextField *)createInRow:(int)row leftImage:(NSString *)name holder:(NSString *)holder {
    
    CGFloat row_y = ROW_HEIGHT * (row - 1);
    CGFloat tf_y = row_y + MARGIN_TOP_BOTTOM;
    CGFloat tf_w = Screen_Width - MARGIN_LEFT_RIGHT * 2;
    CGRect tf_rect = CGRectMake(MARGIN_LEFT_RIGHT, tf_y, tf_w, INPUT_TEXT_FIELD_HEIGHT);
    
    UIImageView * imageView = [[UIImageView alloc] init];
   // imageView.frame = CGRectMake(0, 0, 30, 20);
    //imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageWithName:name];
    [imageView sizeToFit];
    
    BBTextField * textField = [[BBTextField alloc] initWithFrame:tf_rect Icon:imageView];
    textField.delegate = self;
    //textField.leftView = imageView;
   // textField.leftViewMode = UITextFieldViewModeAlways;
    textField.font = kText_Font;
    textField.layer.cornerRadius = 3.0;
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = Normal_Border_Color.CGColor;
    textField.font = kText_Font;
    [textField setCustomPlaceholder:holder];
    textField.textColor = AB_Gray_Color;
    [textField setCustomPlaceholder:holder];
    textField.backgroundColor = AB_White_Color;
    textField.returnKeyType = UIReturnKeyDefault;
    textField.enablesReturnKeyAutomatically = YES;
    
    return textField;
}

- (UITextField *)codeAuthentiateRowViewInView:(UIView *)view row:(int)row {
    
    CGFloat row_y = ROW_HEIGHT * (row - 1);
    
    // Firstly, right view .
    
    NSString *string = @"120秒后重新发送";
    CGSize size = [string sizeWithFont:kText_Font
                     constrainedToSize:CGSizeMake(MAXFLOAT, 0.0)
                         lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat lb_w = size.width + 5;
    CGFloat lb_x = Screen_Width - MARGIN_LEFT_RIGHT - lb_w;
    CGFloat lb_y = row_y + MARGIN_TOP_BOTTOM;
    CGRect rect = CGRectMake(lb_x, lb_y, lb_w, INPUT_TEXT_FIELD_HEIGHT);
    
    UIButton *btnGetCode = [UIButton buttonWithType:UIButtonTypeCustom];
    btnGetCode.frame = rect;
    btnGetCode.backgroundColor = AB_Red_Color;
    btnGetCode.layer.masksToBounds = YES;
    btnGetCode.layer.cornerRadius = 3.0;
    [btnGetCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    btnGetCode.titleLabel.font = kText_Font;
    [btnGetCode setTitleColor:AB_White_Color forState:UIControlStateNormal];
    [btnGetCode addTarget:self action:@selector(getCode:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnGetCode];
    mBtnGetCode = btnGetCode;
    
    //开始倒计时
    mBtnGetCode.userInteractionEnabled = NO;
    [self getCode:mBtnGetCode];
    
    // Then, Left view - UITextField.
    
    CGFloat tf_w = Screen_Width - MARGIN_LEFT_RIGHT * 3 - lb_w;
    rect = CGRectMake(MARGIN_LEFT_RIGHT, lb_y, tf_w, INPUT_TEXT_FIELD_HEIGHT);
    
    BBTextField * textField = [[BBTextField alloc] init];
    textField.frame = rect;
    //textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.backgroundColor = AB_White_Color;
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = Normal_Border_Color.CGColor;
    textField.textColor = AB_Gray_Color;
    textField.layer.cornerRadius = 3.0;
    textField.font = kText_Font;
    [textField setCustomPlaceholder:@"输入验证码"];
    textField.delegate = self;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.returnKeyType = UIReturnKeyDefault;
    textField.enablesReturnKeyAutomatically = YES;
    
    return textField;
}

- (UIButton *)buttonRegisterInRow:(int)row {
    
    CGFloat row_y = ROW_HEIGHT * (row - 1);
    CGFloat tf_y = row_y + MARGIN_TOP_BOTTOM;
    CGFloat tf_w = Screen_Width - MARGIN_LEFT_RIGHT * 2;
    CGRect tf_rect = CGRectMake(MARGIN_LEFT_RIGHT, tf_y, tf_w, INPUT_TEXT_FIELD_HEIGHT);
    
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeSystem];
    
    btnRegister.frame = tf_rect;
    btnRegister.layer.masksToBounds = YES;
    btnRegister.layer.cornerRadius = 3.0;
    btnRegister.backgroundColor = AB_Red_Color;
    [btnRegister setTitleColor:AB_White_Color forState:UIControlStateNormal];
    [btnRegister setTitle:@"注册" forState:UIControlStateNormal];
    [btnRegister addTarget:self action:@selector(registerIn:) forControlEvents:UIControlEventTouchUpInside];
    
    return btnRegister;
}

- (void)registerIn:(UIButton *)sender {
    
    if (![self checkSecret]) {
        
        [self tipViewShow:@"两次密码输入不一致"];
        return;
    }
    else if (![AIRegex isPasswordFormat:mPasswordTextField.text]) {
        return;
    }
    else if (mPasswordTextField.text.length == 0) {
        
        [self tipViewShow:@"请输入您的密码"];
        return;
    }
    else if (mNickNameField.text.length == 0) {
        
        [self tipViewShow:@"请设置您的昵称"];
        return;
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self sendRegisterRequest];
    });

    [self loadViewShow];
    [mScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (BOOL)checkSecret {
    
    return [mPasswordTextField.text isEqualToString:mReinPasswordTextField.text] ? YES : NO;
}

- (void)tipViewShow:(NSString *)tip {
    
    JLTipsView * tipView = [[JLTipsView alloc] initWithTip:tip];
    [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES autoRelease:YES];
}

- (void)sendRegisterRequest {
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/anonymous/register/email"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *phone=[NSXMLElement elementWithName:@"email" stringValue:self.mailAddress];
    NSXMLElement *password = [NSXMLElement elementWithName:@"password" stringValue:mPasswordTextField.text];
    NSXMLElement *code=[NSXMLElement elementWithName:@"validateCode" stringValue:mCodeTextField.text];
    NSXMLElement *name = [NSXMLElement elementWithName:@"name" stringValue:mNickNameField.text];
    NSXMLElement *source = [NSXMLElement elementWithName:@"source" stringValue:@""];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"emailRegister"];
    [queryElement addChild:phone];
    [queryElement addChild:password];
    [queryElement addChild:code];
    [queryElement addChild:name];
    [queryElement addChild:source];
    [iq addChild:queryElement];

    [[XMPPServer xmppStream] sendElement:iq];
    
    JLLog_I("(iq reg=%@)", iq);
}

- (void)registerSuccess:(NSNotification *)notification {
    
    [self loadViewHide];
    
//    LoadingViewController *load=[[LoadingViewController alloc]init];
//    [self presentViewController:load animated:YES completion:^{}];
    
    NSString *employeeName = [notification object];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.mailAddress forKey:@"account"];
    
    AISucceedViewController *controller = [[AISucceedViewController alloc] init];
    controller.isRegisterSucceed = YES;
    controller.employeeName = employeeName;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)registerFail:(NSNotification *)note {
    
    [self loadViewHide];
    
    NSDictionary *dict = [note object];
    NSString *errorMsg = dict[@"errorMsg"];
    
    JLTipsView *tipView = [[JLTipsView alloc] initWithTip:errorMsg];
    [tipView showInView:self.view animated:YES];
}

- (void)getCode:(UIButton *)sender {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self sendCodeRequest];
    });
    
    CGRect rect = sender.frame;
    
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 3.0;
    label.layer.borderColor = AB_Gray_Color.CGColor;
    label.layer.borderWidth = 0.5;
    label.backgroundColor = Label_Back_Color;
    label.textColor = AB_Gray_Color;
    label.font = kText_Font;
    label.text = @"120秒后重新发送";
    label.textAlignment = NSTextAlignmentCenter;
    [sender.superview addSubview:label];
    mTicksLabel = label;
    
    mTicks = 120;
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
        mBtnGetCode.userInteractionEnabled = YES;
        [mTicksLabel removeFromSuperview];
        return;
    }
    
    mTicksLabel.text = [NSString stringWithFormat:@"%d秒后重新发送", mTicks];
}

- (void)sendCodeRequest {
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/anonymous/email/validate"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *phone=[NSXMLElement elementWithName:@"email" stringValue:self.mailAddress];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"email"];
    [queryElement addChild:phone];
    [iq addChild:queryElement];
    [[XMPPServer xmppStream] sendElement:iq];
    
    JLLog_I("<IQ Req=%@>",iq);
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
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)loadViewShow {
    
    [self.view endEditing:YES];
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)loadViewHide {
    
    [self.view endEditing:NO];
    [DejalBezelActivityView removeViewAnimated:YES];
}

@end
