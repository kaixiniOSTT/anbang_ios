//
//  AIRetrievePassworddDetailViewController.m
//  anbang_ios
//
//  Created by rooter on 15-3-18.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIRetrievePassworddDetailViewController.h"
#import "AISetNewPasswprdViewController.h"

#import "DejalActivityView.h"
#import "BBTextField.h"
#import "AIRegex.h"

@interface AIRetrievePassworddDetailViewController ()

@end

@implementation AIRetrievePassworddDetailViewController

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"validate_code" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupController];
}

- (void)setupController {
    
    [self notificationsInitialize];
    
    [self setupNavigationPreference];
    
    [self setupInterface];
}

- (void)notificationsInitialize {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(viewControllerPush:) name:@"validate_code" object:nil];
}

- (void)viewControllerPush:(NSNotification *)note {
    
    [self loadViewHide];
    
    NSDictionary *dict = [note object];
    
    if ([@"yes" isEqualToString:dict[@"validate"]]) {
        
        JLLog_I("<account=%@, code=%@>", self.mHeaderTip, mCodeTextField.text);
        
        UIBarButtonItem*backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"";
        self.navigationItem.backBarButtonItem = backItem;
        
        AISetNewPasswprdViewController *controller = [[AISetNewPasswprdViewController alloc] init];
        controller.account = self.mHeaderTip;
        controller.validateCode = mCodeTextField.text;
        [self.navigationController pushViewController:controller animated:YES];
        
    }else {
    
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:dict[@"text"]];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }
}

- (void)setupNavigationPreference {
    
    self.title = @"找回密码";
    
    
      self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"header_button_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction:)];
    
    
//    self.navigationItem.hidesBackButton = YES;
//    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.bounds = CGRectMake(0, 0, 30, 30);
//    [button setImage:[UIImage imageNamed:@"header_button_back"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationItem.leftBarButtonItem = item;
}

- (void)backAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupInterface {
    
    UIView *contentView = [self contentListView];
    [self.view addSubview:contentView];
}

- (UIView *)contentListView {
    
    UIView * contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Both_Bar_Height);
    
    UILabel *label_row_1 = [self headerLabel];
    [contentView addSubview:label_row_1];
    mHeaderLaebl = label_row_1;
    
    UITextField *textField_row_2 = [self codeAuthentiateRowViewInView:contentView row:2];
    [contentView addSubview:textField_row_2];
    mCodeTextField = textField_row_2;
    
    UIButton *btnRegister_row_5 = [self buttonNextStepInRow:3];
    [contentView addSubview:btnRegister_row_5];
    
    return contentView;
}

- (UILabel *)headerLabel {
    
    NSString *headerTip = [self headerTipHandle];
    
    CGFloat lb_w = Screen_Width - 4 * MARGIN_LEFT_RIGHT;
    CGRect rect = CGRectMake(MARGIN_LEFT_RIGHT * 2, MARGIN_TOP_BOTTOM, lb_w, INPUT_TEXT_FIELD_HEIGHT);
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.font = kText_Font;
    label.numberOfLines = 0;
    label.text = headerTip;
    label.textColor = AB_Gray_Color;
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    return label;
}

- (NSString *)headerTipHandle {
    
    NSMutableString *string = [NSMutableString string];
    NSString *reString = nil;
    
    if ([AIRegex isEmailFormat:self.mHeaderTip]) {
        
        mWayGetCode = 1;
//        self.title = @"邮箱重置";
        
        NSRange range = [self.mHeaderTip rangeOfString:@"@"];
        NSString *emailNumber = [self.mHeaderTip substringToIndex:range.location];
        NSString *emailCom = [self.mHeaderTip substringFromIndex:range.location];
        
        [string appendString:[emailNumber substringToIndex:4]];
        [string appendString:@"****"];
        [string appendString:emailCom];
        
        reString = [NSString stringWithFormat:@"我们已经向您的%@发送了一封邮件，请注意查收", string];
        
    }else {
        
        mWayGetCode = 0;
//        self.title = @"短信重置";
        
        NSString *preString = [self.mHeaderTip substringToIndex:3];
        NSString *tailString = [self.mHeaderTip substringFromIndex:self.mHeaderTip.length - 4];
        reString = [NSString stringWithFormat:@"我们将向您的手机%@****%@发送验证码，请在以下输入框输入", preString, tailString];
    }
    
    return  reString;
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
    
    if (mWayGetCode == 1) {
        [self getCode:mBtnGetCode];
    }
    
    // Then, Left view - UITextField.
    
    CGFloat tf_w = Screen_Width - MARGIN_LEFT_RIGHT * 3 - lb_w;
    rect = CGRectMake(MARGIN_LEFT_RIGHT, lb_y, tf_w, INPUT_TEXT_FIELD_HEIGHT);
    
    BBTextField* textField = [[BBTextField alloc] init];
    textField.frame = rect;
    //textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.font = kText_Font;
    [textField setCustomPlaceholder:@"输入验证码"];
    textField.backgroundColor = AB_White_Color;
    textField.layer.cornerRadius = 3.0;
    textField.layer.borderColor = Normal_Border_Color.CGColor;
    textField.layer.borderWidth = 0.5;
    textField.textColor = AB_Gray_Color;
    textField.backgroundColor = AB_White_Color;
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyDefault;
    textField.enablesReturnKeyAutomatically = YES;
    [textField becomeFirstResponder];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    
    return textField;
}

- (UIButton *)buttonNextStepInRow:(int)row {
    
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
    [btnRegister setTitle:@"下一步" forState:UIControlStateNormal];
    [btnRegister addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    
    return btnRegister;
}

- (void)nextStep:(UIButton *)sender {
    
    if (mCodeTextField.text.length == 0) {
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"验证码不能为空"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        
        return;
    }
    
    [self codeAuthentiate:mCodeTextField.text];
}

- (void)getCode:(UIButton *)sender {
    
    sender.userInteractionEnabled = NO;
    
    if (mWayGetCode == 0) {
        
        NSString *preString = [self.mHeaderTip substringToIndex:3];
        NSString *tailString = [self.mHeaderTip substringFromIndex:self.mHeaderTip.length - 4];
        NSString *reString = [NSString stringWithFormat:@"我们已向您的手机%@****%@发送验证码，\
                              请在以下输入框输入", preString, tailString];
        mHeaderLaebl.text = reString;
    }
    
    [self sendCodeRequest];
    
    CGRect rect = sender.frame;
    
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 3.0;
    label.layer.borderWidth = 0.5;
    label.layer.borderColor = AB_Gray_Color.CGColor;
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
    
    if (mWayGetCode == 0) {
        
        NSLog(@"------------------------------- code request ----------------------------------");
        
        NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query"
                                                             xmlns:kPhoneValidateNameSpace];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:self.mHeaderTip];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        [iq addAttributeWithName:@"id" stringValue:@"phoneNum"];
        [phone addAttributeWithName:@"countryCode" stringValue:@"86"];
        [queryElement addChild:phone];
        [iq addChild:queryElement];
        
        [[XMPPServer xmppStream] sendElement:iq];
        
        JLLog_I("(IQ Req=%@)", iq);
        
    }else {
        
        NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query"
                                                             xmlns:kEmailValidateNameSpace];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        NSXMLElement *phone=[NSXMLElement elementWithName:@"email" stringValue:self.mHeaderTip];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        [iq addAttributeWithName:@"id" stringValue:@"email"];
        [queryElement addChild:phone];
        [iq addChild:queryElement];
        
        [[XMPPServer xmppStream] sendElement:iq];
        
        JLLog_I("(IQ Req=%@)", iq);
    }
}

- (void)codeAuthentiate:(NSString *)code {
    
    [self loadViewShow];
    
    if (mWayGetCode == 0) {
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:kPhoneValidateCodeNameSpace];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        [iq addAttributeWithName:@"id" stringValue:@"validate_code"];
        XMPPElement *phone = [XMPPElement elementWithName:@"phone" stringValue:self.mHeaderTip];
        [phone addAttributeWithName:@"countryCode" stringValue:@"86"];
         XMPPElement *validateCode  = [XMPPElement elementWithName:@"validateCode" stringValue:mCodeTextField.text];
        [query addChild:phone];
        [query addChild:validateCode];
        [iq addChild:query];
        
        [[XMPPServer xmppStream] sendElement:iq];
        
        JLLog_D("<authentiate%@>", iq);
        
    }else {
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:kEmailValidateNameSpace];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        [iq addAttributeWithName:@"id" stringValue:@"validate_code"];
        XMPPElement *email = [XMPPElement elementWithName:@"email" stringValue:self.mHeaderTip];
        XMPPElement *validateCode  = [XMPPElement elementWithName:@"validateCode" stringValue:mCodeTextField.text];
        [query addChild:email];
        [query addChild:validateCode];
        [iq addChild:query];
        
        [[XMPPServer xmppStream] sendElement:iq];
        
        JLLog_D("<authentiate%@>", iq);
    }
}

- (void)loadViewShow {
    
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)loadViewHide {
    
    [DejalBezelActivityView removeViewAnimated:YES];
}

@end
