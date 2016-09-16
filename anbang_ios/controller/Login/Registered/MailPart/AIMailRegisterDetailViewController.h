//
//  AIMailRegisterDetailViewController.h
//  anbang_ios
//
//  Created by rooter on 15-3-17.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTextField.h"

@interface AIMailRegisterDetailViewController : UIViewController {
    
    UIScrollView *mScrollView;
    UITextField  *mActiveField;
    UILabel      *mTicksLabel;
    UIButton     *mBtnGetCode;
    
    UITextField  *mPasswordTextField;
    UITextField  *mReinPasswordTextField;
    UITextField  *mCodeTextField;
    UITextField  *mNickNameField;
    
    BOOL  mKeyboardHidden;
    
    int mTicks;
    NSTimer *mTimer;
}

@property (copy, nonatomic) NSString *mailAddress;

@end
