//
//  GroupUpdNameTableViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 14-5-26.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupUpdNameTableViewController : UITableViewController<UITextFieldDelegate>
{
    
    UITextField *groupNameText;
}
@property (retain,nonatomic) NSString *groupJID;
@property (retain,nonatomic) NSString *groupName;
@end

