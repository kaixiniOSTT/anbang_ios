//
//  AIBindEmailViewController.m
//  anbang_ios
//
//  Created by rooter on 15-3-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBindEmailViewController.h"
#import "AIBindEmailDetailController.h"
#import "AIRegex.h"

@implementation AIBindEmailViewController {
    
    UITextField *mTextField;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupController];
    [self setupInterface];
}
- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setupController
{
    self.title = @"绑定邮箱";
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(pop)]];
}

- (void)setupInterface {
    
    UITextField *textField = [self createInRow:1 leftImage:@"login_icon_user" holder:@"请输入邮箱"];
    [self.view addSubview:textField];
    mTextField = textField;
    [mTextField becomeFirstResponder];
    
    UIButton *button = [self buttonRegisterInRow:2];
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
    
    if (![AIRegex isEmailFormat:mTextField.text]) {
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"您输入的邮箱格式不正确"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        
        return;
    }
    
    AIBindEmailDetailController *controller = [[AIBindEmailDetailController alloc] init];
    controller.mailAddress = mTextField.text;
    [self.navigationController pushViewController:controller animated:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}


@end
