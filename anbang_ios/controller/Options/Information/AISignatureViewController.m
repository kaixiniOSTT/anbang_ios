//
//  AISignatureViewController.m
//  anbang_ios
//
//  Created by rooter on 15-6-15.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AISignatureViewController.h"
#import "MBProgressHUD.h"
#import "AIControllersTool.h"
#import "UserInfoCRUD.h"
#import "StrUtility.h"

@interface AISignatureViewController () <UITextViewDelegate>
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, weak) UILabel *placeHolderLabel;
@end

@implementation AISignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setups
    [self setupNavigationItem];
    [self setupInterface];
    [self setupNotifications];
}

- (void)setupNavigationItem {
    self.title = @"个性签名";
    
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(pop)]];
    
    self.navigationItem.rightBarButtonItem = [[AITitleBarButtonItem alloc]initWithTitle:@"保存" target:self action:@selector(saveSignature)];
    
}

- (void)setupInterface {
    UITextView *textView = [[UITextView alloc] init];
    textView.frame = (CGRect){CGPointMake(15, 21), CGSizeMake(Screen_Width - 30, 150)};
    textView.backgroundColor = AB_Color_ffffff;
    textView.tintColor = AB_Color_9c958a;
    textView.layer.masksToBounds = YES;
    textView.layer.cornerRadius = 3.0;
    textView.layer.borderColor = AB_Color_d1c0a5.CGColor;
    textView.layer.borderWidth = 0.5;
    textView.textColor = AB_Color_9c958a;
    textView.font =  AB_FONT_15;
    textView.textContainerInset = UIEdgeInsetsMake(15, 12, 0, 0);
    textView.delegate = self;
    [textView becomeFirstResponder];
    
    NSString *mySignature = [self mySignature];
    if ([StrUtility isBlankString:mySignature]) {
        NSString *text = @"个性签名长度限制在30字以内";
        CGSize size = [text sizeWithFont:AB_FONT_15];
        UILabel *label = [[UILabel alloc] init];
        label.frame = (CGRect){CGPointMake(15, 15), size};
        label.text = text;
        label.font = AB_FONT_15;
        label.textColor = AB_Color_9c958a;
        [textView addSubview:label];
        self.placeHolderLabel = label;
    }else {
        textView.text = mySignature;
    }
    [self.view addSubview:textView];
    self.textView = textView;
    
    self.view.backgroundColor = AB_Color_f6f2ed;
}

- (void)setupNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(saveSignatureReturn)
                   name:@"AI_Save_Signature_Return"
                 object:nil];
    [center addObserver:self
               selector:@selector(saveSignatureError)
                   name:@"AI_Save_Signature_Error"
                 object:nil];
}

#pragma mark
#pragma mark private (AISignatureViewController)

- (NSString *)mySignature {
    return [UserInfoCRUD signatureWithJID:MY_JID];
}

#pragma mark
#pragma mark private (Actions)

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveSignature {
    [self.textView resignFirstResponder];
    if (self.textView.text.length >30) {
        [AIControllersTool tipViewShow:@"个性签名限制在30字以内"];
        return;
    }
    [self sendIQ];
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    [self performSelector:@selector(afterDelay)
               withObject:nil
               afterDelay:30.0];
}

/**
 *      <!-- 请求：设置邦邦号，只能设置一次 -->
 *      <iq type="set" id="">
 *          <query xmlns="http://www.nihualao.com/xmpp/userinfo">
 *              <signature>xxx</signature>
 *          </query>
 *      </iq>
 */
- (void)sendIQ {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // IQ contruct
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"type"
                     stringValue:@"set"];
        [iq addAttributeWithName:@"id"
                     stringValue:@"AI_Set_Signature"];
        NSXMLElement *query = [NSXMLElement elementWithName:@"query"
                                                      xmlns:kUserInfoNameSpace];
        NSXMLElement *signature = [NSXMLElement elementWithName:@"signature"
                                                    stringValue:self.textView.text];
        
        [query addChild:signature];
        [iq addChild:query];
        [[XMPPServer xmppStream] sendElement:iq];
    });
}

- (void)afterDelay {
    MBProgressHUD *progress = [MBProgressHUD HUDForView:self.view];
    if (progress) {
        [progress hide:YES];
        [AIControllersTool tipViewShow:@"请求超时，请稍后重试"];
    }
}

#pragma mark
#pragma mark prvite (Notifications)

- (void)saveSignatureReturn {
    [MBProgressHUD hideAllHUDsForView:self.view
                             animated:YES];
    [UserInfoCRUD saveSignature:self.textView.text
                      targetJID:MY_JID];
    [self pop];
}

- (void)saveSignatureError {
    [MBProgressHUD hideAllHUDsForView:self.view
                             animated:YES];
    [AIControllersTool tipViewShow:@"服务器出错"];
}

#pragma mark
#pragma mark Delegate

// UITextView
- (void)textViewDidChange:(UITextView *)textView {
    BOOL flag = textView.text.length > 0;
    self.placeHolderLabel.hidden = flag;
}

-        (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
        replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


@end
