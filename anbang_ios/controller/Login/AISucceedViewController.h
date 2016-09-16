//
//  AISucceedViewController.h
//  anbang_ios
//
//  Created by rooter on 15-3-26.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBaseViewController.h"

@interface AISucceedViewController : AIBaseViewController<UITextFieldDelegate> {
    
    NSTimer *mTimer;
    int      mTicks;
    
    UILabel  *mTicksLabel;
    UIButton *mButton;
}

@property (assign, nonatomic) BOOL isRegisterSucceed;   //YES: register  NO:retreieve password
@property (copy, nonatomic) NSString *employeeName;

@end
