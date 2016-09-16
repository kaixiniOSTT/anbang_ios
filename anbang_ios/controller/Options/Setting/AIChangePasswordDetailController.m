//
//  AIChangePasswordDetailController.m
//  anbang_ios
//
//  Created by rooter on 15-3-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIChangePasswordDetailController.h"
#import "DejalActivityView.h"
#import "AIChangePasswordSuccessController.h"
#import "AIRegex.h"

@implementation AIChangePasswordDetailController

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_Change_Password" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_Change_Password_Error" object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupController];
    
    [self setupInterface];
    
    [self notificationInitailize];
}

- (void)setupController {
    
    self.title = @"修改密码";
      self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"header_button_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backMove2:)];
}

- (void)backMove2:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupInterface {
    
    UITextField *textField = [self createInRow:1 leftImage:@"login_icon_password" holder:@"请输入密码"];
    [self.view addSubview:textField];
    mTextField = textField;
    [mTextField becomeFirstResponder];
    
    UITextField *textField_row_2 = [self createInRow:2 leftImage:@"login_icon_password" holder:@"再次输入密码"];
    [self.view addSubview:textField_row_2];
    mReTextField = textField_row_2;
    
    UIButton *button = [self buttonRegisterInRow:3];
    [self.view addSubview:button];
}

- (void)notificationInitailize {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(changePasswordSuccess:) name:@"AI_Change_Password" object:nil];
    [center addObserver:self selector:@selector(occurError:) name:@"AI_Change_Password_Error" object:nil];
}

- (void)changePasswordSuccess:(NSNotification *)note {
    
    [self loadViewHide];
    
    NSString *text = [note object];
    if ([text isEqualToString:@"true"]) {
        
        [[XMPPServer sharedServer]disconnect];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"password"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"confirmPassword"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"oncePassword"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        AIChangePasswordSuccessController *controller = [[AIChangePasswordSuccessController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        
    }else {
        
        [self tipViewShow:@"修改密码失败，请稍后重试"];
    }
}

- (void)occurError:(NSNotification *)note {
    
    [self loadViewHide];
    
    [self tipViewShow:@"修改出现错误，请稍后再试"];
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
    [btnRegister setTitle:@"确定" forState:UIControlStateNormal];
    [btnRegister addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    
    return btnRegister;
}

- (void)nextStep:(UIButton *)sender {
    
    if (mTextField.text.length == 0) {
        
        [self tipViewShow:@"请输入新密码"];
        return;
    }
    
    if (![mReTextField.text isEqualToString:mTextField.text]) {
        
        [self tipViewShow:@"两次密码输入不一致，请重新输入"];
        return;
    }
    
    if (![AIRegex isPasswordFormat:mReTextField.text]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        [self sendChangePasswordRequest];
    });
    
    [self loadViewShow];
}

- (void)tipViewShow:(NSString *)tip {
    
    JLTipsView *tipView = [[JLTipsView alloc] initWithTip:tip];
    [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

- (void)sendChangePasswordRequest {
    
    /**
     *   <iq id="N0tUn-25" type="set">
     *       <query xmlns="http://nihualao.com/protocol/coustom#password">
     *           <action >3</action>
     *           <password>321654</password>
     *       </query>
     *   </iq>
    **/
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://nihualao.com/protocol/coustom#password"];
    NSXMLElement *action = [NSXMLElement elementWithName:@"action" stringValue:@"3"];
    NSXMLElement *password = [NSXMLElement elementWithName:@"password" stringValue:mTextField.text];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"changeCurrentPassword"];
    [queryElement addChild:action];
    [queryElement addChild:password];
    [iq addChild:queryElement];
    
    [[XMPPServer xmppStream] sendElement:iq];
    
    JLLog_I("(Bind Phone Req = %@)", iq);
}

#pragma mark
#pragma mark UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (!textField.text || textField.text.length == 0) {
        return;
    }
    if (![AIRegex isPasswordFormat:textField.text]) {
        return;
    }
}

#pragma end

- (void)loadViewShow {
    
    [self.view endEditing:YES];
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)loadViewHide {
    
    [self.view endEditing:NO];
    [DejalKeyboardActivityView removeViewAnimated:YES];
}




@end
