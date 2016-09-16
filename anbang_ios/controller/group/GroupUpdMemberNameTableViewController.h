//
//  GroupUpdMemberNameTableViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 14-5-29.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupUpdMemberNameTableViewController : UITableViewController<UITextFieldDelegate>
{
    
    UITextField *groupMemberNameText;
}
@property (retain,nonatomic) NSString *groupMemberJID;
@property (retain,nonatomic) NSString *groupJID;
@property (retain,nonatomic) NSString *groupMucJID;
@property (retain,nonatomic) NSString *groupMemberName;
@end

