//
//  AIChangePasswordController.m
//  anbang_ios
//
//  Created by rooter on 15-3-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIChangePasswordController.h"
#import "DejalActivityView.h"
#import "AIChangePasswordDetailController.h"

@implementation AIChangePasswordController {
    
    UITextField *mTextField;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_Check_Password" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_Check_Password_Error" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupController];
    
    [self setupInterface];
    
    [self notificationInitailize];
}
- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setupController {
    
    self.title = @"修改密码";
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(pop)]];
}

- (void)setupInterface {
    
    UITextField *textField = [self createInRow:1 leftImage:@"login_icon_password" holder:@"请输入旧密码"];
    [self.view addSubview:textField];
    mTextField = textField;
    [mTextField becomeFirstResponder];
    
    UIButton *button = [self buttonRegisterInRow:2];
    [self.view addSubview:button];
}

- (void)notificationInitailize {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(passwordCorrect:) name:@"AI_Check_Password" object:nil];
    [center addObserver:self selector:@selector(occurError:) name:@"AI_Check_Password_Error" object:nil];
}

- (void)passwordCorrect:(NSNotification *)note {
    
    [self loadViewHide];
    
    NSString *text = [note object];
    if ([text isEqualToString:@"true"]) {
        
        AIChangePasswordDetailController *controller = [[AIChangePasswordDetailController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        
    }else {
        
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"密码不正确，请重新输入"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }
}

- (void)occurError:(NSNotification *)note {
    
    [self loadViewHide];
    
    JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"请求出现错误，请稍后重试"];
    [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

- (UITextField *)createInRow:(int)row leftImage:(NSString *)name holder:(NSString *)holder {
    
    CGFloat row_y = ROW_HEIGHT * (row - 1);
    CGFloat tf_y = row_y + MARGIN_TOP_BOTTOM;
    CGFloat tf_w = Screen_Width - MARGIN_LEFT_RIGHT * 2;
    CGRect tf_rect = CGRectMake(MARGIN_LEFT_RIGHT, tf_y, tf_w, INPUT_TEXT_FIELD_HEIGHT);
    
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, 30, 20);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageWithName:name];
    
    UITextField * textField = [[UITextField alloc] initWithFrame:tf_rect];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.delegate = self;
    textField.leftView = imageView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.font = kText_Font;
    textField.layer.cornerRadius = 6.0;
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = Normal_Border_Color.CGColor;
    textField.font = kText_Font;
    [textField setCustomPlaceholder:holder];
    textField.textColor = AB_Gray_Color;
    [textField setCustomPlaceholder:holder];
    textField.backgroundColor = AB_White_Color;
    textField.returnKeyType = UIReturnKeyDefault;
    textField.enablesReturnKeyAutomatically = YES;
    textField.secureTextEntry = YES;
    
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
    btnRegister.layer.cornerRadius = 5.0;
    btnRegister.backgroundColor = AB_Red_Color;
    [btnRegister setTitleColor:AB_White_Color forState:UIControlStateNormal];
    [btnRegister setTitle:@"下一步" forState:UIControlStateNormal];
    [btnRegister addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    
    return btnRegister;
}

- (void)nextStep:(UIButton *)sender {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        [self sendCheckPasswordRequest];
    });
    
    [self loadViewShow];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)sendCheckPasswordRequest {
    /**
     *   <iq id="checkPassword" type="get">
     *       <query xmlns="http://nihualao.com/protocol/coustom#password">
     *           <action >1</action>
     *           <password>123456</password>
     *       </query>
     *   </iq>
     */
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://nihualao.com/protocol/coustom#password"];
    NSXMLElement *action = [NSXMLElement elementWithName:@"action" stringValue:@"1"];
    NSXMLElement *password = [NSXMLElement elementWithName:@"password" stringValue:mTextField.text];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"checkPassword"];
    [queryElement addChild:action];
    [queryElement addChild:password];
    [iq addChild:queryElement];
    
    [[XMPPServer xmppStream] sendElement:iq];
    
    JLLog_I("(Bind Phone Req = %@)", iq);
}

- (void)loadViewShow {
    
    [self.view endEditing:YES];
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)loadViewHide {
    
    [self.view endEditing:NO];
    [DejalKeyboardActivityView removeViewAnimated:YES];
}

@end
