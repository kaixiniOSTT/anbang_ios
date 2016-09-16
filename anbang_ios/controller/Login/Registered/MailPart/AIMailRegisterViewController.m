//
//  AIFaxRegisterViewController.h
//  anbang_ios
//
//  Created by rooter on 15-3-17.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIMailRegisterViewController.h"
#import "AIMailRegisterDetailViewController.h"
#import "AIRetrievePasswordViewController.h"

#import "AIRegex.h"
#import "AIRegisterAssitant.h"
#import "DejalActivityView.h"

#import "JLTipsView.h"
#import "BBTextField.h"


#define MARGIN_LEFT_RIGHT  16
#define MARGIN_TOP_BOTTOM  15
#define INPUT_TEXT_FIELD_HEIGHT   40
#define ROW_HEIGHT (INPUT_TEXT_FIELD_HEIGHT + MARGIN_TOP_BOTTOM * 1.0)

@interface AIMailRegisterViewController ()<UITextFieldDelegate, UIAlertViewDelegate>

@end

@implementation AIMailRegisterViewController {
    
    UITextField *mTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupController];
}

- (void)setupController {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupNavigation];
    
    [self setupViewInterface];
}

- (void)setupNavigation {
    
    self.title = @"邮箱注册";
    self.view.backgroundColor = Controller_View_Color;
//    self.navigationItem.hidesBackButton = YES;
//    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.bounds = CGRectMake(0, 0, 30, 30);
//    [button setImage:[UIImage imageNamed:@"header_button_back"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(backMove:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationItem.leftBarButtonItem = item;
    
      self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"header_button_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backMove3:)];
}

- (void)backMove3:(UIButton *)sender {
    
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
    textField.font = kText_Font;
    [textField setCustomPlaceholder:@"请输入您的邮箱"];
    textField.textColor = AB_Gray_Color;
    textField.backgroundColor = AB_White_Color;
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
    btnNextStep.layer.cornerRadius = 3.0;
    btnNextStep.backgroundColor = AB_Red_Color;
    [btnNextStep setTitleColor:AB_White_Color forState:UIControlStateNormal];
    [btnNextStep setTitle:@"下一步" forState:UIControlStateNormal];
    [btnNextStep addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btnNextStep];
}

- (void)nextStep:(UIButton *)sender {
    
    if (![AIRegex isEmailFormat:mTextField.text]) {
        
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"请输入正确的邮箱" ];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES autoRelease:YES];
        
        return;
    }
    
    [self loadViewShow];
    
    [AIRegisterAssitant checkEmail:mTextField.text success:^(BOOL used) {
        
        [self loadViewHide];
        
        if (used) {
            
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")
                                                             message:@"用户已存在"
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:NSLocalizedString(@"phoneNumRegistered.retrievePassword",@"action"), @"知道了", nil];
            [alertView show];
            
        }else {
            
            UIBarButtonItem*backItem = [[UIBarButtonItem alloc] init];
            backItem.title = @"";
            self.navigationItem.backBarButtonItem = backItem;
            
            AIMailRegisterDetailViewController *controller = [[AIMailRegisterDetailViewController alloc] init];
            controller.mailAddress = mTextField.text;
            [self.navigationController pushViewController:controller animated:YES];
        }
        
    } failure:^(NSError *error) {
        
        [self loadViewHide];
        
        JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"网络错误，请稍后重试"];
        [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }];
    
//    AIMailRegisterDetailViewController *controller = [[AIMailRegisterDetailViewController alloc] init];
//    controller.mailAddress = mTextField.text;
//    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        AIRetrievePasswordViewController *controller = [[AIRetrievePasswordViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
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
