//
//  GroupNameTableViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 14-4-24.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupNameTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{

    UITextField *text;
}
@property(nonatomic,retain)NSString * groupName;
@end
