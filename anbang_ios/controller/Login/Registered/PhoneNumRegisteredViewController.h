//
//  PhoneNumRegisteredViewController.h
//  anbang_ios
//
//  Created by seeko on 14-3-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTextField.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
@class PhoneNumCodeViewController;
///////////////////////////////////////////////////////////////////////////////////////////////////

@interface PhoneNumRegisteredViewController : UIViewController<XMPPStreamDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate, UIScrollViewDelegate>
{

    UITextField *txtFieldName;
    NSString *strarrayCode;
    UIView *codeView;
    XMPPStream *xmppStream;
    
///////////////////////////////////////////////////////////////////////////////////////////////////
    UIScrollView *mScrollView;
    UITextField  *mActiveField;
    UIButton     *mBtnGetCode;
    
    BOOL  mKeyboardHidden;
    
    NSTimer  *mTimer;
    int mTicks;
///////////////////////////////////////////////////////////////////////////////////////////////////
    
}
@property (retain,nonatomic) UITableView *tableView;
@property (retain,nonatomic) NSString *countryCode;
@property (retain,nonatomic) NSString *countryName;
@end
