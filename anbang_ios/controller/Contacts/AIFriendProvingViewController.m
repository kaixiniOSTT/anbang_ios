//
//  AIFriendProvingViewController.m
//  anbang_ios
//
//  Created by rooter on 15-6-12.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIFriendProvingViewController.h"
#import "MBProgressHUD.h"
#import "AIControllersTool.h"

#define MARGIN_LEFT_RIGHT  16
#define MARGIN_TOP_BOTTOM  15
#define INPUT_TEXT_FIELD_HEIGHT   40
#define ROW_HEIGHT (INPUT_TEXT_FIELD_HEIGHT + MARGIN_TOP_BOTTOM * 1.0)

@interface AIFriendProvingViewController ()
@property (weak, nonatomic) UITextField *textField;
@property (weak, nonatomic) UIButton *rightBarButton;
@end

@implementation AIFriendProvingViewController

- (void)removeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:@"AI_Friend_Proving_Return"
                    object:nil];
    [center removeObserver:self
                      name:@"AI_Friend_Proving_Error"
                    object:nil];
    [center removeObserver:self
                      name:@"CNN_Contacts_LoadFinish"
                    object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // clean up
    [self removeNotifications];
}

#pragma mark
#pragma mark setup

- (void)setupNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    // Add friend first step: sending proving IQ
    // Then send presence
    [center addObserver:self
               selector:@selector(sendPresence)
                   name:@"AI_Friend_Proving_Return"
                 object:nil];
    [center addObserver:self
               selector:@selector(provingError)
                   name:@"AI_Friend_Proving_Error"
                 object:nil];
    [center addObserver:self
               selector:@selector(makeFriendSecondIQReturn:)
                   name:@"NNC_Received_Contacts_Database_Ready"
                 object:nil];
}

- (void)setupInterface {
    UITextField *textField = [self createInRow:1 holder:@"我是。。。"];
    [textField becomeFirstResponder];
    
    UILabel *label = [[UILabel alloc] init];
    CGRect frame = textField.frame;
    frame.origin.y = CGRectGetMaxY(frame);
    label.frame = frame;
    label.text = @"请输入信息以便对方确认你的身份";
    label.font = AB_FONT_13;
    label.textAlignment = NSTextAlignmentCenter;
    
    self.textField = textField;
    
    [self.view addSubview:textField];
    [self.view addSubview:label];
    
    self.view.backgroundColor = Controller_View_Color;
}

- (void)setupNavigationItem {
    
    self.title = @"好友验证";
    
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix, [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                         target:self
                                                                                         action:@selector(pop)]];
    
    AITitleBarButtonItem *right = [[AITitleBarButtonItem alloc]initWithTitle:@"发送" target:self action:@selector(sendProvingIQ)];
    
    self.navigationItem.rightBarButtonItems = @[right, flix];
    self.rightBarButton = right.button;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setups
    [self setupNavigationItem];
    [self setupInterface];
    [self setupNotifications];
}

#pragma mark
#pragma mark Private (Views)

- (UITextField *)createInRow:(int)row holder:(NSString *)holder {
    
    CGFloat row_y = ROW_HEIGHT * (row - 1);
    CGFloat tf_y = row_y + MARGIN_TOP_BOTTOM;
    CGFloat tf_w = Screen_Width - MARGIN_LEFT_RIGHT * 2;
    CGRect tf_rect = CGRectMake(MARGIN_LEFT_RIGHT, tf_y, tf_w, INPUT_TEXT_FIELD_HEIGHT);
    
    UITextField * textField = [[UITextField alloc] initWithFrame:tf_rect];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.delegate = self;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.font = kText_Font;
    textField.layer.cornerRadius = 6.0;
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = Normal_Border_Color.CGColor;
    textField.font = kText_Font;
    [textField setCustomPlaceholder:holder];
    textField.textColor = AB_Gray_Color;
    textField.backgroundColor = AB_White_Color;
    textField.returnKeyType = UIReturnKeyDefault;
    textField.enablesReturnKeyAutomatically = YES;
  
    return textField;
}

#pragma mark
#pragma mark Privatie (Actions)

- (void)refreshInterface {
//    self.rightBarButton.userInteractionEnabled = !self.rightBarButton.userInteractionEnabled;
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendProvingIQ {
    
    if (self.textField.text.length == 0) {
        [AIControllersTool tipViewShow:@"请输入信息以便对方确认你的身份"];
        return;
    }
    
    [self refreshInterface];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"id" stringValue:@"AI_Friend_Proving"];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:kIQRosterNameSpace];
        NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
        [item addAttributeWithName:@"jid" stringValue:self.jid];
        [item addAttributeWithName:@"name" stringValue:@""];
        
        NSXMLElement *group = [NSXMLElement elementWithName:@"group" stringValue:@"我的好友"];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message" stringValue:self.textField.text];
        
        [item addChild:group];
        [item addChild:message];
        [query addChild:item];
        [iq addChild:query];
        JLLog_I(@"<friend proving=%@>", iq);
        [[XMPPServer xmppStream] sendElement:iq];
    });
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.textField resignFirstResponder];
    [self performSelector:@selector(afterDelay)
               withObject:nil
               afterDelay:60.0];
}

- (void)sendPresence {
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addAttributeWithName:@"type" stringValue:@"subscribe"];
    [presence addAttributeWithName:@"to" stringValue:self.jid];
    [presence addAttributeWithName:@"id" stringValue:@"1003"];
    JLLog_I(@"%@", presence);
    [[XMPPServer xmppStream] sendElement:presence];
}

- (void)provingError {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [AIControllersTool tipViewShow:@"服务器出错，请稍后重试"];
    [self refreshInterface];
}

- (void)afterDelay {
    MBProgressHUD *progress = [MBProgressHUD HUDForView:self.view];
    if (progress) {
        [progress hide:YES];
        [AIControllersTool tipViewShow:@"请求超时，请稍后重试"];
        [self refreshInterface];
    }
}

- (void)makeFriendSecondIQReturn:(NSNotification *)n {
    NSArray *array = [n object];
    if (array.count) {
       NSDictionary *d = array[0];
        NSString *subscription = d[@"subscription"];
        if ([subscription isEqualToString:@"both"] || [subscription isEqualToString:@"to"]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [AIControllersTool tipViewShow:@"发送成功，等待对方回复"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark
#pragma mark UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
