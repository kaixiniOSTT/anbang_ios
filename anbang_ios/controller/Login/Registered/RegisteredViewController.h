//
//  RegisteredViewController.h
//  anbang_ios
//
//  Created by seeko on 14-3-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisteredViewController : UIViewController
{
    IBOutlet UIButton *btnLogin;
    IBOutlet UIButton *btnAKeyRegistered;
    IBOutlet UIButton *btnPhoneNumRegistered;
}
- (IBAction)clickBtnLogin:(id)sender;
- (IBAction)clickBtnAKeyRegistered:(id)sender;
- (IBAction)clickBtnPhoneNumRegistered:(id)sender;


@end
