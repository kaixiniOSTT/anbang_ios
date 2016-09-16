//
//  FriendNameViewController.h
//  anbang_ios
//
//  Created by seeko on 14-5-29.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseCircleViewDelegate.h"
#import <MessageUI/MessageUI.h>
@interface FriendNameViewController : UIViewController<ChooseCircleViewDelegate,MFMessageComposeViewControllerDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSString *circleName;
    NSString *groupJID;
    
    NSString *phoneCode;
    NSString *phoneNum;

 
}
@property (retain,nonatomic) UITableView *tableView;
@property(nonatomic,copy) NSString *nickName;
@property(nonatomic,copy) NSString *circleName;
@property(nonatomic,copy)NSString *groupJID;
@property(nonatomic,copy)NSString *phoneCode;
@property(nonatomic,copy)NSString *phoneNum;

@end
