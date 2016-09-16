//
//  AIPasswordAuthentiateViewController.m
//  anbang_ios
//
//  Created by rooter on 15-4-2.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIPasswordAuthentiateViewController.h"
#import "AIControllersTool.h"
#import "UserInfoCRUD.h"
#import "AIBindEmailViewController.h"
#import "AIBindPhoneViewController.h"

@interface AIPasswordAuthentiateViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@end

@implementation AIPasswordAuthentiateViewController

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:@"AI_Check_Password" object:nil];
    [center removeObserver:self name:@"AI_Check_Password_Error" object:nil];
    [center removeObserver:self name:@"AI_Unbind_Phone_Succeed" object:nil];
    [center removeObserver:self name:@"AI_Unbind_Phone_Error" object:nil];
    [center removeObserver:self name:@"AI_Unbind_Email" object:nil];
    [center removeObserver:self name:@"AI_Unbind_Email_Error" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupController];
    [self setupInterface];
    [self notificationsInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupController {
    
    switch (self.operationType) {
        case 1:
            self.title = @"解绑手机";
            break;
        case 2:
            self.title = @"更换手机";
            break;
        case 3:
            self.title = @"解绑邮箱";
            break;
        case 4:
            self.title = @"更换邮箱";
            break;
        default:
            break;
    }
    
    UIBarButtonItem*backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)notificationsInit
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(passwordCorrect:) name:@"AI_Check_Password" object:nil];
    [center addObserver:self selector:@selector(passwordAuthentiateError:) name:@"AI_Check_Password_Error" object:nil];
    [center addObserver:self selector:@selector(unbindPhoneReturn:) name:@"AI_Unbind_Phone" object:nil];
    [center addObserver:self selector:@selector(unbindPhoneError:) name:@"AI_Unbind_Phone_Error" object:nil];
    [center addObserver:self selector:@selector(unbindEmailReturn:) name:@"AI_Unbind_Email" object:nil];
    [center addObserver:self selector:@selector(unbindEmailError:) name:@"AI_Unbind_Email_Error" object:nil];
}

- (void)setupInterface
{
    CGFloat text_w = Screen_Width - 2 * MARGIN_LEFT_RIGHT;

    UITextField *textField = [[UITextField alloc] init];
    textField.frame = CGRectMake(MARGIN_LEFT_RIGHT, MARGIN_TOP_BOTTOM, text_w, 40);
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.layer.cornerRadius = 6.0;
    textField.layer.borderColor = Normal_Border_Color.CGColor;
    textField.layer.borderWidth = 0.5;
    textField.backgroundColor = AB_White_Color;
    textField.font = [UIFont systemFontOfSize:14.5];
    [textField setCustomPlaceholder:@"请输入密码"];
    textField.delegate = self;
    textField.secureTextEntry = YES;
    [self.view addSubview:textField];
    mTextField = textField;
    
    
    CGFloat btn_y = CGRectGetMaxY(textField.frame) + MARGIN_TOP_BOTTOM;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(MARGIN_LEFT_RIGHT, btn_y, text_w, 40);
    button.layer.cornerRadius = 6.0;
    button.backgroundColor = AB_Red_Color;
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:AB_White_Color forState:UIControlStateNormal];
    [button addTarget:self action:@selector(sureTo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)sureTo:(UIButton *)sender {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendPasswordAuthentiate];
    });
    
    [AIControllersTool loadingViewShow:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)sendPasswordAuthentiate
{
    /**
     *   <iq id="Y1Msc-19" type="get">
     *       <query xmlns="http://nihualao.com/protocol/coustom#password">
     *           <action >1</action>
     *           <password>a000000</password>
     *       </query>
     *   </iq>
     */
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://nihualao.com/protocol/coustom#password"];
    NSXMLElement *action = [NSXMLElement elementWithName:@"action" stringValue:@"1"];
    NSXMLElement *password = [NSXMLElement elementWithName:@"password" stringValue:mTextField.text];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"checkPassword"];
    [queryElement addChild:action];
    [queryElement addChild:password];
    [iq addChild:queryElement];
    
    [[XMPPServer xmppStream] sendElement:iq];
    
    JLLog_I(@"Code Authentiate=%@", iq);
}

- (void)sendOperationRequest
{
    switch (self.operationType) {
        case 1: {
            [self sendUnbindPhoneRequest];
        }
            break;
        
        case 2: {
            [self push];
        }
            break;
        
        case 3: {
            [self sendUnbindEmailRequest];
        }
            break;
            
        case 4: {
            [self push];
        }
            break;
            
        default:
            break;
    }
}

- (void)sendUnbindPhoneRequest
{
    
    /*
     *   <!-- ========= 解绑手机 ========== -->
     *   <!-- 请求 -->
     *   <iq type="set">
     *      <query xmlns="http://www.nihualao.com/xmpp/phone/unbind">
     *          <phone>xxx</phone>
     *      </query>
     *   </iq>
     *
     *   <!-- 响应 -->
     *   <iq type="result">
     *      <query xmlns="http://www.nihualao.com/xmpp/phone/unbind">
     *          <isUnbind>true/false</isUnbind> <!-- 是否解绑了手机，true/false -->
     *   </query>
     *   </iq>
     */
    
    UserInfo *userInfo = [UserInfo loadArchive];
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query"
                                                         xmlns:@"http://www.nihualao.com/xmpp/phone/unbind"];
    NSXMLElement *phone = [NSXMLElement elementWithName:@"phone" stringValue:userInfo.phone];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"unbindPhone"];
    [queryElement addChild:phone];
    [iq addChild:queryElement];
    [[XMPPServer xmppStream] sendElement:iq];
    
    JLLog_I("Unbind phone request=%@", iq);
}

- (void)sendUnbindEmailRequest {
    
    //    <!-- ========= 解绑主邮箱 ========== -->
    //    <!-- 请求 -->
    //    <iq type="set">
    //    <query xmlns="http://www.nihualao.com/xmpp/email/unbind">
    //    <email>xxx</email>
    //    </query>
    //    </iq>
    
    //    <iq type="result">
    //    <query xmlns="http://www.nihualao.com/xmpp/email/unbind">
    //    <isUnbind>true/false</isUnbind> <!-- 是否解绑了主邮箱，true/false -->
    //    </query>
    //    </iq>
    
    
    UserInfo *userInfo = [UserInfo loadArchive];
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/email/unbind"];
    NSXMLElement *phone = [NSXMLElement elementWithName:@"email" stringValue:userInfo.secondEmail];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"UnbindEmail"];
    [queryElement addChild:phone];
    [iq addChild:queryElement];
    
    [[XMPPServer xmppStream] sendElement:iq];
    
    JLLog_I("Unbind email re=%@", iq);
}

- (void)push
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [AIControllersTool loadingVieHide:self];
        
        switch (self.operationType) {
            case 2: {
                AIBindPhoneViewController *controller = [[AIBindPhoneViewController alloc] init];
                [self.navigationController pushViewController:controller animated:YES];
            }
                break;
            case 4: {
                AIBindEmailViewController *controller = [[AIBindEmailViewController alloc] init];
                [self.navigationController pushViewController:controller animated:YES];
            }
                break;
            default:
                break;
        }
    });
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Notification response
////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)passwordCorrect:(NSNotification *)n
{
    NSString *ret = [n object];
    
    if([ret isEqualToString:@"true"])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendOperationRequest];
        });
    }
    else {
        [AIControllersTool loadingVieHide:self];
        [AIControllersTool tipViewShow:@"密码错误，请重新输入"];
    }
}

- (void)unbindPhoneReturn:(NSNotification *)n
{
    [AIControllersTool loadingVieHide:self];
    
    NSDictionary *dict = [n object];
    NSString *text = [dict objectForKey:@"result"];
    
    if ([text isEqualToString:@"true"])
    {
        UserInfo *userInfo = [UserInfo loadArchive];
        userInfo.phone = nil;
        [userInfo save];
        
        [AIControllersTool tipViewShow:@"解绑成功"];
        UIViewController *controller = self.navigationController.viewControllers[2];
        [self.navigationController popToViewController:controller animated:YES];
    }
    else
    {
        [AIControllersTool tipViewShow:@"解绑失败，请稍后重试"];
    }
}

- (void)unbindPhoneError:(NSNotification *)n
{
    [AIControllersTool loadingVieHide:self];
    
    NSDictionary *dict = [n object];
    NSString *text = [dict objectForKey:@"error"];
    
    if (text) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:text delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
    }else {
        [AIControllersTool tipViewShow:@"请求失败，请稍后重试"];
    }
}

- (void)unbindEmailReturn:(NSNotification *)n
{
    [AIControllersTool loadingVieHide:self];
    
    NSDictionary *dict = [n object];
    NSString *text = [dict objectForKey:@"result"];
    
    if ([text isEqualToString:@"true"])
    {
        UserInfo *userInfo = [UserInfo loadArchive];
        userInfo.secondEmail = nil;
        [userInfo save];
        
        [AIControllersTool tipViewShow:@"解绑成功"];
        UIViewController *controller = self.navigationController.viewControllers[2];
        [self.navigationController popToViewController:controller animated:YES];
    }
    else
    {
        [AIControllersTool tipViewShow:@"解绑失败，请稍后重试"];
    }
}

- (void)unbindEmailError:(NSNotification *)n
{
    [AIControllersTool loadingVieHide:self];
    
    NSDictionary *dict = [n object];
    NSString *text = [dict objectForKey:@"error"];
    
    if (text) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:text delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
    }else {
        [AIControllersTool tipViewShow:@"请求失败，请稍后重试"];
    }
}

- (void)passwordAuthentiateError:(NSNotification *)n
{
    [AIControllersTool loadingVieHide:self];
    [AIControllersTool tipViewShow:@"网络错误，请稍后重试"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
