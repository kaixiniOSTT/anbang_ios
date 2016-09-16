//
//  AISetNewPasswprdViewController.m
//  anbang_ios
//
//  Created by rooter on 15-3-18.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AISetNewPasswprdViewController.h"
#import "AISucceedViewController.h"

#import "AIRegex.h"

#import "DejalActivityView.h"
#import "BBTextField.h"

@interface AISetNewPasswprdViewController () <UITextFieldDelegate>

@end

@implementation AISetNewPasswprdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupController];
}

- (void)setupController {
    
    JLLog_D("<account=%@, code=%@>", self.account, self.validateCode);
    
    [self notificationInitailize];
    
    [self setupNavigationPreference];
    
    [self setupInterface];
}

- (void)notificationInitailize {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(resetSucceed:) name:@"changeSuccess" object:nil];
}

- (void)resetSucceed:(NSNotification *)note {
    
    [self loadViewHide];
    
    NSDictionary *dict = [note userInfo];
    NSString *isChange = dict[@"isChange"];
    
    JLLog_I("<dict=%@, isChange=%@>",dict, isChange);
    
    if ([isChange isEqualToString:@"true"]) {
        
        AISucceedViewController *controller = [[AISucceedViewController alloc] init];
        controller.isRegisterSucceed = NO;
        [self.navigationController pushViewController:controller animated:YES];
        
    }else if([isChange isEqualToString:@"false"]) {
        
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"重置密码失败"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        
    }else {
        
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"验证码错误"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }
}

- (void)setupNavigationPreference {
    
    self.title = @"重设密码";
    
      self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"header_button_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backMove:)];
    
//    self.navigationItem.hidesBackButton = YES;
//    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.bounds = CGRectMake(0, 0, 30, 30);
//    [button setImage:[UIImage imageNamed:@"header_button_back"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(backMove:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationItem.leftBarButtonItem = item;
}

- (void)backMove:(UIButton *)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setupInterface {
    
    UIView *contentView = [self contentListView];
    [self.view addSubview:contentView];
}

- (UIView *)contentListView {
    
    UIView * contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Both_Bar_Height);
    
    UITextField *textField_row_1 = [self createInRow:1 leftImage:@"login_icon_password" holder:@"请输入新密码"];
    [textField_row_1 becomeFirstResponder];
    [contentView addSubview:textField_row_1];
    mPasswordTextField = textField_row_1;
    
    UITextField *view_row_2 = [self createInRow:2 leftImage:@"login_icon_password" holder:@"再次输入新密码"];
    [contentView addSubview:view_row_2];
    mReinPasswordTextField = view_row_2;
    
    UIButton *btnRegister_row_3 = [self buttonNextStepInRow:3];
    [contentView addSubview:btnRegister_row_3];
    
    return contentView;
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
    //textField.leftViewMode = UITextFieldViewModeAlways;
    textField.backgroundColor = AB_White_Color;
    textField.font = kText_Font;
    [textField setCustomPlaceholder:holder];
    textField.layer.cornerRadius = 3.0;
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = Normal_Border_Color.CGColor;
    textField.textColor = AB_Gray_Color;
    textField.returnKeyType = UIReturnKeyDefault;
    textField.enablesReturnKeyAutomatically = YES;
    textField.secureTextEntry = YES;
    
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
    
    if (![mPasswordTextField.text isEqualToString:mReinPasswordTextField.text]) {
        
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"两次密码输入不一致"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        
        return;
    }
    else if (![AIRegex isPasswordFormat:mPasswordTextField.text]) {
        return;
    }
    
    [self changePasswordRequest];
}

- (void)changePasswordRequest {
    
    [self loadViewShow];
    
    if ([AIRegex isPhoneNumberFromat:self.account]) {
        
        NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:kResetPasswordNamesPace];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        NSXMLElement *phone=[NSXMLElement elementWithName:@"account" stringValue:self.account];
        [phone addAttributeWithName:@"countryCode" stringValue:@"86"];
        NSXMLElement *password = [NSXMLElement elementWithName:@"password" stringValue:mPasswordTextField.text];
        NSXMLElement *code=[NSXMLElement elementWithName:@"validateCode" stringValue:self.validateCode];
        NSXMLElement *keyType = [NSXMLElement elementWithName:@"keyType" stringValue:@"phone"];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        [iq addAttributeWithName:@"id" stringValue:@"ChangePassword"];
        [queryElement addChild:phone];
        [queryElement addChild:password];
        [queryElement addChild:code];
        [queryElement addChild:keyType];
        [iq addChild:queryElement];
        
        [[XMPPServer xmppStream] sendElement:iq];
        
        JLLog_I(@"Change pwd req (phone=%@, iq=%@)", self.account, iq);
        
    }else {
        
        NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:kResetPasswordNamesPace];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        NSXMLElement *phone=[NSXMLElement elementWithName:@"account" stringValue:self.account];
        NSXMLElement *password = [NSXMLElement elementWithName:@"password" stringValue:mPasswordTextField.text];
        NSXMLElement *code=[NSXMLElement elementWithName:@"validateCode" stringValue:self.validateCode];
        NSXMLElement *keyType = [NSXMLElement elementWithName:@"keyType" stringValue:@"email"];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        [iq addAttributeWithName:@"id" stringValue:@"ChangePassword"];
        [queryElement addChild:phone];
        [queryElement addChild:password];
        [queryElement addChild:code];
        [queryElement addChild:keyType];
        [iq addChild:queryElement];
        
        [[XMPPServer xmppStream] sendElement:iq];
        
        JLLog_I(@"Change pwd req (email=%@, iq=%@)", self.account, iq);
    }
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
