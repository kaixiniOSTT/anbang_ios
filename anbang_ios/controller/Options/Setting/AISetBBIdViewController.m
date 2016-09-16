//
//  AISetBBIdViewController.m
//  anbang_ios
//
//  Created by rooter on 15-3-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AISetBBIdViewController.h"
#import "UserInfo.h"
#import "AIRegex.h"
#import "DejalActivityView.h"

@implementation AISetBBIdViewController {
    
    UIButton *mButton;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_Set_BBId_Result" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_Set_BBId_Error" object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupController];
    [self setupInterface];
    [self notifiationInitailize];
}
- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setupController {
    
    self.title = @"设置社区ID";
    
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"target:self action:@selector(pop)]];
    UITapGestureRecognizer *tp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:tp];
}

- (void)setupInterface {
    
    CGFloat tf_w = Screen_Width - MARGIN_LEFT_RIGHT * 2;
    
    UITextField *textField = [[UITextField alloc] init];
    textField.frame = CGRectMake(MARGIN_LEFT_RIGHT, MARGIN_TOP_BOTTOM, tf_w, 40);
    textField.borderStyle = UITextBorderStyleRoundedRect;
    [textField setCustomPlaceholder:@"只能由英文、数字、下划线组成"];
    textField.textColor = AB_Gray_Color;
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = Normal_Border_Color.CGColor;
    textField.layer.cornerRadius = 6.0;
    textField.font = kText_Font;
    textField.backgroundColor = AB_White_Color;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.delegate = self;
    [self.view addSubview:textField];
    [textField becomeFirstResponder];
    mTextField = textField;
    
    CGFloat btn_y = CGRectGetMaxY(textField.frame) + MARGIN_TOP_BOTTOM;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(MARGIN_LEFT_RIGHT, btn_y, tf_w, 40);
    button.backgroundColor = AB_Red_Color;
    [button setTitle:@"下一步" forState:UIControlStateNormal];
    [button setTitleColor:AB_White_Color forState:UIControlStateNormal];
    button.layer.cornerRadius = 6.0;
    [button addTarget:self action:@selector(setBBId:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    mButton = button;
    
    CGFloat lb_y = CGRectGetMaxY(button.frame) + MARGIN_TOP_BOTTOM;
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(MARGIN_LEFT_RIGHT, lb_y, tf_w, 40);
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:12.0];
    label.text = @"社区ID一经设置不可更改";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

- (void)keyboardHide:(UIGestureRecognizer *)gesture
{
    [mTextField resignFirstResponder];
}

- (void)notifiationInitailize {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(setBBIdSuccess:) name:@"AI_Set_BBId_Result" object:nil];
    [center addObserver:self selector:@selector(setBBIdOccurError:) name:@"AI_Set_BBId_Error" object:nil];
}

- (void)setBBIdSuccess:(NSNotification *)note {
    
    [self loadViewHide];
    
    NSNumber *result = [note object];
    BOOL isSucceed = [result boolValue];
    
    if (isSucceed) {
        
        UserInfo *userInfo = [UserInfo loadArchive];
        userInfo.accountName = mTextField.text;
        [userInfo save];
        
        UIAlertView* alerView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                           message:@"设置成功"
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"确定", nil];
        [alerView show];
        
//        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"设置成功"];
//        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        
    }else {
        
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"社区id已存在，请重新输入"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }
}

- (void)setBBIdOccurError:(NSNotification *)n
{
    [self loadViewHide];
    [AIControllersTool tipViewShow:@"网络错误，请稍后重试"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)setBBId:(UIButton *)sender {
    
    if (mTextField.text.length <= 0) {
        
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"请输入您的社区ID"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        return;
    }
    
    if (![AIRegex isBBIdFormat:mTextField.text]) {
        
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"社区ID格式不正确"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        [self sendSettingBBIdRequest];
    });
    
    [self loadViewShow];
}

- (void)sendSettingBBIdRequest {
    
    /**
     *      <!-- 请求：设置邦邦号，只能设置一次 -->
     *      <iq type="set">
     *          <query xmlns="http://www.nihualao.com/xmpp/userinfo">
     *              <accountName>xxx</accountName>
     *          </query>
     *      </iq>
     */
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
    NSXMLElement *accountName = [NSXMLElement elementWithName:@"accountName" stringValue:mTextField.text];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"AIuserinfo_set_bbid"];
    [queryElement addChild:accountName];
    [iq addChild:queryElement];
    
    [[XMPPServer xmppStream] sendElement:iq];
    
    JLLog_I(@"<setBBID=%@>", iq);
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
