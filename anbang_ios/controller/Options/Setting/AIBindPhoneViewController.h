//
//  AIBindViewController.h
//  anbang_ios
//
//  Created by rooter on 15-3-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBaseViewController.h"

@interface AIBindPhoneViewController : AIBaseViewController<UITextFieldDelegate> {
    
    UITextField *mTextField;
    UIButton    *mButtonCode;
    UILabel     *mTicksLabel;
    UITextField *mCodeTextFiled;
    
    NSTimer     *mTimer;
    int          mTicks;
}

@end
