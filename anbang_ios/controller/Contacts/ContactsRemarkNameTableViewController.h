//
//  ContactsRemarkNameTableViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 14-5-13.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsRemarkNameTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    
    UITextField *text;
}
@property (retain,nonatomic) NSString *contactsJID;
@end
