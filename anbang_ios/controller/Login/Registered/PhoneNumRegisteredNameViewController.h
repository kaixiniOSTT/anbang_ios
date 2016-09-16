//
//  PhoneNumRegisteredNameViewController.h
//  anbang_ios
//
//  Created by seeko on 14-5-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneNumRegisteredNameViewController : UIViewController<UITextFieldDelegate>
{
    UITextField *txtNickname;
    NSString *strphoneNum;
    NSString *strCode;
}
@property(nonatomic,copy)NSString *strphoneNum;
@property(nonatomic,copy)NSString *strCode;
@end
