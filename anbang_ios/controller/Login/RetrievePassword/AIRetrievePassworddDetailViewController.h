//
//  AIRetrievePassworddDetailViewController.h
//  anbang_ios
//
//  Created by rooter on 15-3-18.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBaseViewController.h"

@interface AIRetrievePassworddDetailViewController : AIBaseViewController <UITextFieldDelegate> {
    
    UIButton *mBtnGetCode;
    UILabel  *mTicksLabel;
    UITextField *mCodeTextField;
    UILabel     *mHeaderLaebl;
    
    int mWayGetCode;            /* 获取验证码的方式 0:手机 1:邮箱 */
    int mTicks;
    NSTimer  *mTimer;
}

@property (copy, nonatomic) NSString *mHeaderTip;

@end
