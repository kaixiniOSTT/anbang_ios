//
//  AIRetrievePasswordViewController.m
//  anbang_ios
//
//  Created by rooter on 15-3-18.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIRetrievePasswordViewController.h"
#import "AIRetrievePassworddDetailViewController.h"

#import "JLTipsView.h"
#import "DejalActivityView.h"

#import "AIRegex.h"
#import "AIBBIdAssitant.h"
#import "BBTextField.h"

@implementation AIRetrievePasswordViewController {
    
    UITextField *mTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupController];
}

- (void)setupController {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"anonymouss" forKey:@"userName"];
    [defaults setObject:nil forKey:@"password"];
    [defaults setObject:nil forKey:@"confirmPassword"];
    [[XMPPServer sharedServer]connect];
    
    [self setupNavigation];
    
    [self setupViewInterface];
}

- (void)setupNavigation {
    
    self.title = @"找回密码";
    
//    self.navigationItem.hidesBackButton = YES;
//    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.bounds = CGRectMake(0, 0, 30, 30);
//    [button setImage:[UIImage imageNamed:@"header_button_back"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(backMove:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationItem.leftBarButtonItem = item;
    
    

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"header_button_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backMove:)];
    


}

- (void)backMove:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupViewInterface {
    
    [self addTextField];
    
    [self addNextStepButton];
}

- (void)addTextField {
    
    CGFloat field_w = Screen_Width - 2 * MARGIN_LEFT_RIGHT;
    CGRect rect = CGRectMake(MARGIN_LEFT_RIGHT, MARGIN_TOP_BOTTOM, field_w, INPUT_TEXT_FIELD_HEIGHT);
    
    UIImageView * imageView = [[UIImageView alloc] init];
    //imageView.frame = CGRectMake(0, 0, 30, 20);
    //imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageWithName:@"login_icon_user"];
    [imageView sizeToFit];
    
    BBTextField *textField = [[BBTextField alloc] initWithFrame:rect Icon:imageView];
    textField.delegate = self;
    //textField.leftView = imageView;
    //textField.leftViewMode = UITextFieldViewModeAlways;
    textField.layer.cornerRadius = 3.0;
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = Normal_Border_Color.CGColor;
    textField.backgroundColor = AB_White_Color;
    textField.font = kText_Font;
    textField.textColor = AB_Gray_Color;
    [textField setCustomPlaceholder:@"请输入手机号/邮箱"];
    textField.returnKeyType = UIReturnKeyDefault;
    textField.enablesReturnKeyAutomatically = YES;
    
    [self.view addSubview:textField];
    mTextField = textField;
    [mTextField becomeFirstResponder];
}

- (void)addNextStepButton {
    
    UITextField *textField = (UITextField *)self.view.subviews[0];
    
    CGRect rect = textField.frame;
    CGFloat btn_y = CGRectGetMaxY(rect) + MARGIN_TOP_BOTTOM;
    rect.origin.y = btn_y;
    
    UIButton * btnNextStep = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNextStep.frame = rect;
    btnNextStep.layer.masksToBounds = YES;
    btnNextStep.layer.cornerRadius = 5.0;
    btnNextStep.backgroundColor = AB_Red_Color;
    [btnNextStep setTitleColor:AB_White_Color forState:UIControlStateNormal];
    [btnNextStep setTitle:@"下一步" forState:UIControlStateNormal];
    [btnNextStep addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btnNextStep];
}

- (void)nextStep:(UIButton *)sender {
    
    if (0 == mTextField.text.length) {
        
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"请输入您的手机号或者邮箱" ];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES autoRelease:YES];
        
        return;
    }
    
    if (![AIRegex isRegularFormat:mTextField.text]) {
        
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"请确认输入正确" ];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES autoRelease:YES];
        
        return;
    }
    
    [self loadViewShow];
    
    [AIBBIdAssitant bbIdWithAccount:mTextField.text success:^(NSString *bbId) {
        
        [self loadViewHide];
        
        if (bbId) {
            
            UIBarButtonItem*backItem = [[UIBarButtonItem alloc] init];
            backItem.title = @"";
            self.navigationItem.backBarButtonItem = backItem;
            
            AIRetrievePassworddDetailViewController *controller = [[AIRetrievePassworddDetailViewController alloc] init];
            controller.mHeaderTip = mTextField.text;
            [self.navigationController pushViewController:controller animated:YES];
            
        }else {
            
            JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"用户不存在"];
            [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        }
        
    } failure:^(NSError *error) {
        
        [self loadViewHide];
        
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"网络出现异常"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)loadViewShow {
    
    [DejalBezelActivityView activityViewForView:self.view];
    [self.view endEditing:YES];
}

- (void)loadViewHide {
    
    [DejalBezelActivityView removeViewAnimated:YES];
    [self.view endEditing:NO];
}

@end
