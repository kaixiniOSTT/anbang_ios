//
//  AISetBackupNameViewController.m
//  anbang_ios
//
//  Created by rooter on 15-4-8.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AISetBackupNameViewController.h"
#import "ContactsCRUD.h"
#import "ChatBuddyCRUD.h"
#import "MBProgressHUD.h"

@interface AISetBackupNameViewController ()

@end

@implementation AISetBackupNameViewController

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"AI_Set_Backup_Name_Succeed" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self setupNavigationItem];
    [self setupInterface];
    [self setupNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [mTextField resignFirstResponder];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupNavigationItem
{
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(back)]];
    
        
    self.title = @"备注设置";
}

- (void)setupNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(success:) name:@"AI_Set_Backup_Name_Succeed" object:nil];
}

- (void)setupInterface
{
    NSString *text = [ContactsCRUD queryContactsRemarkName:self.jid];
    
    CGFloat w = Screen_Width - MARGIN_LEFT_RIGHT * 2;
    UITextField *textField = [[UITextField alloc] init];
    textField.frame = CGRectMake(MARGIN_LEFT_RIGHT, MARGIN_TOP_BOTTOM, w, 40);
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.layer.borderWidth = 0.5;
    textField.layer.cornerRadius = 6.0;
    textField.layer.borderColor = Normal_Border_Color.CGColor;
    textField.backgroundColor = AB_White_Color;
    [textField setCustomPlaceholder:@"请输入备注"];
    if(text != NULL && ![text isEqualToString:(@"(null)")]) {
        textField.text = text;
    }
    textField.font = [UIFont systemFontOfSize:14.8];
    [textField becomeFirstResponder];
    [self.view addSubview:textField];
    mTextField = textField;
    
    CGFloat y = CGRectGetMaxY(textField.frame) + MARGIN_TOP_BOTTOM;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(MARGIN_LEFT_RIGHT, y, w, 40);
    button.layer.cornerRadius = 6.0;
    button.backgroundColor = AB_Red_Color;
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:AB_White_Color forState:UIControlStateNormal];
    [button addTarget:self action:@selector(sure) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)sure
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
//    });
    
    [self loadViewShow];
}

- (void)sendRequest
{
//    <iq type="set" id="aac0a">
//        <query xmlns="jabber:iq:roster">
//            <item name="汉能" jid="10003@ab-insurance.com">
//                <group>我的好友</group>
//            </item>
//        </query>
//    </iq>
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"AI_Set_Backup_Name"];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"name" stringValue:mTextField.text];
    [item addAttributeWithName:@"jid" stringValue:self.jid];
    
    [query addChild:item];
    [iq addChild:query];
    
    JLLog_I(@"set backup name(%@)", iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
    [self performSelector:@selector(afterDelay) withObject:nil afterDelay:30.0];
}

- (void)afterDelay {
    MBProgressHUD *hub = [MBProgressHUD HUDForView:self.view];
    if (hub) {
        [hub hide:YES];
        [self tipViewShow:@"网络不佳，请稍后再试"];
    }
}

- (void)success:(NSNotification *)n
{
    [self loadViewHide];
    
    NSString *s = [n object];
    if ([s isEqualToString:@"yes"]) {
        
        [self tipViewShow:@"设置成功"];
        [ContactsCRUD updateContactsRemarkName:self.jid remarkName:mTextField.text myJID:MY_JID];
        
        //修改对话列表里的备注名称
        NSString *chatUserName = [self.jid componentsSeparatedByString:@"@"][0];
        [ChatBuddyCRUD updateChatBuddyName:mTextField.text chatUserName:chatUserName];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self tipViewShow:@"设置失败，请稍后重试"];
    }
}

- (void)loadViewShow
{
    [self.view endEditing:YES];
    // [DejalBezelActivityView activityViewForView:self.view];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)loadViewHide
{
    [self.view endEditing:NO];
    // [DejalBezelActivityView removeViewAnimated:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)tipViewShow:(NSString *)tip
{
    JLTipsView *t = [[JLTipsView alloc] initWithTip:tip];
    [t showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
