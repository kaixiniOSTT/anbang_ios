//
//  SettingNameController.h
//  anbang_ios
//
//  Created by seeko on 14-3-20.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingNameController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,XMPPStreamDelegate,UIAlertViewDelegate>
{
    UITextField *textFild;
    
    XMPPStream *xmppStream;
}
@property (retain,nonatomic) UITableView *tableView;

@end
