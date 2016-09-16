//
//  AIBindViewController.m
//  anbang_ios
//
//  Created by rooter on 15-3-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBindPhoneViewController.h"
#import "UserInfo.h"
#import "AIRegex.h"
#import "DejalActivityView.h"

@implementation AIBindPhoneViewController

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_Bind_Phone" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_Bind_Phone_Error" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Validate_PhoneNum_Error" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupController];
    
    [self setupInterface];
    
    [self notifiationInitailize];
}

- (void)setupController {
    
    self.title = @"绑定手机";
}

- (void)setupInterface {
    
    UITextField *textField = [self createInRow:1 leftImage:@"regist_icon_phonenumber" holder:@"请输入手机号"];
    [self.view addSubview:textField];
    textField.textColor = AB_Gray_Color;
    mTextField = textField;
    [mTextField becomeFirstResponder];
    
    UITextField *textField_row_2 = [self codeAuthentiateRowViewInView:self.view row:2];
    [self.view addSubview:textField_row_2];
    mCodeTextFiled = textField_row_2;
    
    UIButton *button = [self buttonRegisterInRow:3];
    [self.view addSubview:button];
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
    textField.delegate = self;
    textField.leftView = imageView;
    textField.leftViewMode = UITextFieldViewModeAlways;
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
    textField.keyboardType = UIKeyboardTypeNumberPad;
    
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
    btnGetCode.backgroundColor = AB_Red_Color;
    btnGetCode.layer.masksToBounds = YES;
    btnGetCode.layer.cornerRadius = 3.0;
    [btnGetCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    btnGetCode.titleLabel.font = kText_Font;
    [btnGetCode setTitleColor:AB_White_Color forState:UIControlStateNormal];
    [btnGetCode addTarget:self action:@selector(getCode:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnGetCode];
    mButtonCode = btnGetCode;
    
    // Then, Left view - UITextField.
    
    CGFloat tf_w = Screen_Width - MARGIN_LEFT_RIGHT * 3 - lb_w;
    rect = CGRectMake(MARGIN_LEFT_RIGHT, lb_y, tf_w, INPUT_TEXT_FIELD_HEIGHT);
    
    UITextField * textField = [[UITextField alloc] init];
    textField.frame = rect;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.backgroundColor = AB_White_Color;
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = Normal_Border_Color.CGColor;
    textField.textColor = AB_Gray_Color;
    textField.layer.cornerRadius = 3.0;
    textField.font = kText_Font;
    [textField setCustomPlaceholder:@" 输入验证码"];
    //textField.placeholder = @"输入验证码";
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
    
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btnRegister.frame = tf_rect;
    btnRegister.layer.masksToBounds = YES;
    btnRegister.layer.cornerRadius = 3.0;
    btnRegister.backgroundColor = AB_Red_Color;
    [btnRegister setTitleColor:AB_White_Color forState:UIControlStateNormal];
    [btnRegister setTitle:@"绑定" forState:UIControlStateNormal];
    [btnRegister addTarget:self action:@selector(bindPhone:) forControlEvents:UIControlEventTouchUpInside];
    
    return btnRegister;
}

- (void)getCode:(UIButton *)sender {
    
    if (![AIRegex isPhoneNumberFromat:mTextField.text]) {
        
        JLTipsView *tipView = [[JLTipsView alloc]initWithTip:@"您输入的手机号码无效"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES autoRelease:YES];
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self sendCodeRequest];
    });

     [self changeToShowTicks:sender];
}

- (void)changeToShowTicks:(UIButton *)sender {
    
    mButtonCode.userInteractionEnabled = NO;
    
    CGRect rect = sender.frame;
    
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.layer.masksToBounds = YES;
    label.backgroundColor = Label_Back_Color;
    label.font = kText_Font;
    label.textColor = AB_Gray_Color;
    label.layer.cornerRadius = 3.0;
    label.layer.borderWidth = 0.5;
    label.layer.borderColor = AB_Gray_Color.CGColor;
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
        [mTicksLabel removeFromSuperview];
        mButtonCode.userInteractionEnabled = YES;
        return;
    }
    
    mTicksLabel.text = [NSString stringWithFormat:@"%d秒后重新发送", mTicks];
}

- (void)sendCodeRequest {
    
    /**
     *  <iq type=”set”>￼￼
     *      <query xmlns=”http://www.nihualao.com/xmpp/anonymous/phone/validate”>
     *          <phone countryCode=”国家码”>手机号</phone>
     *      </query>
     *  </iq>
     */
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query"
                                                         xmlns:@"http://www.nihualao.com/xmpp/anonymous/phone/validate"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:mTextField.text];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"phoneNum"];
    [phone addAttributeWithName:@"countryCode" stringValue:@"86"];
    [queryElement addChild:phone];
    [iq addChild:queryElement];
    [[XMPPServer xmppStream] sendElement:iq];
    
    JLLog_I("(Phone Code Req=%@)", iq);
}

- (void)notifiationInitailize {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(bindSuccess:) name:@"AI_Bind_Phone" object:nil];
    [center addObserver:self selector:@selector(bindError:) name:@"AI_Bind_Phone_Error" object:nil];
    [center addObserver:self selector:@selector(validatePhoneNumError:) name:@"NNC_Validate_PhoneNum_Error" object:nil];
}

-(void)validatePhoneNumError:(NSNotification *)message {
    
    [mTimer invalidate];
    [mTicksLabel removeFromSuperview];
    mButtonCode.userInteractionEnabled = YES;
    
    NSString *msg = [message object];
    
    JLTipsView *tipView = [[JLTipsView alloc] initWithTip:msg];
    [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

- (void)bindSuccess:(NSNotification *)note {
    
    [self loadViewHide];
    
    NSDictionary *result = [note object];
    NSString *text = [result objectForKey:@"result"];
    
    if ([@"true" isEqualToString:text]) {
        
        UserInfo *userInfo = [UserInfo loadArchive];
        userInfo.phone = [NSString stringWithFormat:@"+86%@", mTextField.text];
        [userInfo save];
        
        UIViewController *controller = self.navigationController.viewControllers[2];
        [self.navigationController popToViewController:controller animated:YES];
        
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"绑定手机成功"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }else {
        
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"绑定手机失败，请稍后重试"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }
}

- (void)bindError:(NSNotification *)n
{
    [self loadViewHide];
    
    NSDictionary *dict = [n object];
    NSString *text = [dict objectForKey:@"error"];
    
    if (text.length > 0) {
        JLTipsView *tipview = [[JLTipsView alloc] initWithTip:text];
        [tipview showInView:self.view.window animated:YES];
    }else {
        JLTipsView *tipview = [[JLTipsView alloc] initWithTip:@"服务器出错，请稍后重试"];
        [tipview showInView:self.view.window animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)bindPhone:(UIButton *)sender {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self sendBindRequest];
    });
    
    [self loadViewShow];
    
}

- (void)sendBindRequest {
    
    /**
     *   <iq type="set">
     *   <query xmlns="http://www.nihualao.com/xmpp/phone/bind">
     *   <phone countryCode="xxx">xxx</phone>
     *   <validateCode>xxx<alidateCode>
     *   </query>
     *
     *   </iq>
     *   <!-- 响应 -->
     *   <iq type="result">
     *   <query xmlns="http://www.nihualao.com/xmpp/phone/bind">
     *   <isBind>true/false</isBind> <!-- 是否绑定了手机，true/false -->
     *   </query>
     *   </iq>
     */
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/phone/bind"];
    NSXMLElement *phone = [NSXMLElement elementWithName:@"phone" stringValue:mTextField.text];
    NSXMLElement *validateCode = [NSXMLElement elementWithName:@"validateCode" stringValue:mCodeTextFiled.text];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"bindPhoneNumber"];
    [phone addAttributeWithName:@"countryCode" stringValue:@"86"];
    [queryElement addChild:phone];
    [queryElement addChild:validateCode];
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
