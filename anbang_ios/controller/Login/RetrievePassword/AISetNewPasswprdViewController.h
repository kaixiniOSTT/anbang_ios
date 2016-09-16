//
//  AISetNewPasswprdViewController.h
//  anbang_ios
//
//  Created by rooter on 15-3-18.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBaseViewController.h"

@interface AISetNewPasswprdViewController : AIBaseViewController {
    
    UITextField *mPasswordTextField;
    UITextField *mReinPasswordTextField;
}

@property (copy, nonatomic) NSString *account;
@property (copy, nonatomic) NSString *validateCode;

@end
