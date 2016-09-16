//
//  SendSMSViewController.h
//  anbang_ios
//
//  Created by seeko on 14-4-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ChooseCircleViewDelegate.h"
@interface SendSMSViewController : UIViewController<MFMessageComposeViewControllerDelegate,ChooseCircleViewDelegate,UIAlertViewDelegate>
{
    NSString *name;
    NSString *phoneNum;
}
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *phoneNum;
@end
