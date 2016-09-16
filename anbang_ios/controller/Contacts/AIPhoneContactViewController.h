//
//  AIPhoneContactViewController.h
//  anbang_ios
//
//  Created by Kim on 15/4/21.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "sqlite3.h"

@interface AIPhoneContactViewController : UITableViewController<MFMessageComposeViewControllerDelegate>
{
    sqlite3 *database;
}
@property (nonatomic, retain) NSMutableArray *sectionHeadsKeys;
@end
