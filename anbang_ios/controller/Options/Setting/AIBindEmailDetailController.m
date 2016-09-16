//
//  AIBindEmailDetailController.m
//  anbang_ios
//
//  Created by rooter on 15-3-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBindEmailDetailController.h"
#import "UserInfo.h"
#import "DejalActivityView.h"
#import "AIBindEmailSucceedViewController.h"

@implementation AIBindEmailDetailController {
    
    UITextField *mCodeTextField;
    UIButton    *mBtnGetCode;
    UILabel     *mTicksLabel;
    
    int  mTicks;
    NSTimer *mTimer;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_Bind_Email_Succeed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_Bind_Email_Error" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_After_Bind_Succeed" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupController];
    
}

- (void)setupController {
    
    [self setupNavigation];
    [self setupInterface];
    [self notificationInitailize];
}

- (void)setupNavigation
{
    self.title = @"绑定邮箱";
}

- (void)setupInterface {
    
    UIView *contentView = [self contentListView];
    [self.view addSubview:contentView];
}

- (void)notificationInitailize {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindSuccess:) name:@"AI_Bind_Email_Succeed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindFailure:) name:@"AI_Bind_Email_Error" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdate:) name:@"AI_After_Bind_Succeed" object:nil];
}

- (void)bindSuccess:(NSNotification *)note {
    [self loadViewHide];
    
    NSString *text = [note object];
    
    if ([text isEqualToString:@"true"]) {
        UserInfo *userinfo = [UserInfo loadArchive];
        NSString *namespace = [[self.mailAddress componentsSeparatedByString:@"@"] lastObject];
        if ([namespace isEqualToString:OpenFireHostName]) {
            userinfo.email = self.mailAddress;
        }else {
            userinfo.secondEmail = self.mailAddress;
        }
        [userinfo save];
        
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"绑定邮箱成功"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        [self.navigationController popToViewController:self.navigationController.viewControllers[2] animated:YES];
    }else {

        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"绑定邮箱失败，请稍后重试"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }
}

- (void)userInfoUpdate:(NSNotification *) n {
    
    [self loadViewHide];
    
    NSArray *infos = [n object];
    NSDictionary *dict = infos[0];
    NSString *employeeName = dict[@"employeeNme"];
    int accountType = [dict[@"accountType"] intValue];
    
    UserInfo *userInfo = [UserInfo loadArchive];
    if (accountType == 2) {
        userInfo.email = self.mailAddress;
        userInfo.employeeName = employeeName;
    }else {
        userInfo.secondEmail = self.mailAddress;
    }
    userInfo.accountType = accountType;
    [userInfo save];
    
    AIBindEmailSucceedViewController *controller = [[AIBindEmailSucceedViewController alloc] init];
    controller.email = self.mailAddress;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)bindFailure:(NSNotification *)note {
    
    [self loadViewHide];
    
    JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"请求失败，请稍后重试"];
    [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

- (UIView *)contentListView {
    
    UIView * contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Both_Bar_Height);
    
    UILabel *textField_row_1 = [self headerLabel];
    [contentView addSubview:textField_row_1];
    
    UITextField *textField_row_2 = [self codeAuthentiateRowViewInView:contentView row:2];
    [contentView addSubview:textField_row_2];
    textField_row_2.textColor = AB_Gray_Color;
    mCodeTextField = textField_row_2;
    [mCodeTextField becomeFirstResponder];
    
    UIButton *btnRegister_row_3 = [self buttonRegisterInRow:3];
    [contentView addSubview:btnRegister_row_3];
    
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
    btnGetCode.layer.cornerRadius = 5.0;
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
    
    UITextField * textField = [[UITextField alloc] init];
    textField.frame = rect;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.backgroundColor = AB_White_Color;
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = Normal_Border_Color.CGColor;
    textField.textColor = AB_Gray_Color;
    textField.layer.cornerRadius = 6.0;
    textField.font = kText_Font;
    [textField setCustomPlaceholder:@" 输入验证码"];
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
    btnRegister.layer.cornerRadius = 5.0;
    btnRegister.backgroundColor = AB_Red_Color;
    [btnRegister setTitleColor:AB_White_Color forState:UIControlStateNormal];
    [btnRegister setTitle:@"绑定" forState:UIControlStateNormal];
    [btnRegister addTarget:self action:@selector(bindEmial:) forControlEvents:UIControlEventTouchUpInside];
    
    return btnRegister;
}

- (NSString *)headerTipHandle {
    
    NSMutableString *string = [NSMutableString string];
    
    NSRange range = [self.mailAddress rangeOfString:@"@"];
    NSString *emailNumber = [self.mailAddress substringToIndex:range.location];
    NSString *emailCom = [self.mailAddress substringFromIndex:range.location];
    
    [string appendString:[emailNumber substringToIndex:4]];
    [string appendString:@"****"];
    [string appendString:emailCom];
    
    NSString *reString = [NSString stringWithFormat:@"我们已向%@发送了一封邮件，请注意查收", string];
    
    return  reString;
}

- (void)getCode:(UIButton *)sender {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self sendCodeRequest];
    });
    
    CGRect rect = sender.frame;
    
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 6.0;
    label.layer.borderColor = AB_Gray_Color.CGColor;
    label.layer.borderWidth = 0.5;
    label.backgroundColor = Label_Back_Color;
    label.textColor = AB_Gray_Color;
    label.font = kText_Font;
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

- (void)bindEmailRequest {
   /*
    <!-- ========= 绑定主邮箱 ========== -->
    <!-- 请求 -->
    <iq type="set">
    <query xmlns="http://www.nihualao.com/xmpp/email/bind">
    <email>xxx</email>
    <validateCode>xxx<alidateCode>
    </query>
    </iq>
    
    <iq type="result">
    <query xmlns="http://www.nihualao.com/xmpp/email/bind">
    <isBind>true/false</isBind> <!-- 是否绑定了主邮箱，true/false -->
    </query>
    </iq>
    */
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/email/bind"];
    NSXMLElement *phone = [NSXMLElement elementWithName:@"email" stringValue:self.mailAddress];
    NSXMLElement *validateCode = [NSXMLElement elementWithName:@"validateCode" stringValue:mCodeTextField.text];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"AIbind_email"];
    [queryElement addChild:phone];
    [queryElement addChild:validateCode];
    [iq addChild:queryElement];
    
    [[XMPPServer xmppStream] sendElement:iq];
    
    JLLog_I("(Bind Phone Req = %@)", iq);
    
}

- (void)bindEmial:(UIButton *)sender {
    
    [self loadViewShow];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self bindEmailRequest];
    });
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
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
