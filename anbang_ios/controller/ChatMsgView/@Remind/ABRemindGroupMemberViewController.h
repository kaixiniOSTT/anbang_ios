//
//  ABRemindGroupMemberViewController.h
//  anbang_ios
//
//  Created by Kim on 15/4/21.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ABRemindGroupMemberViewController : UITableViewController<UISearchBarDelegate,UISearchDisplayDelegate>
{
    UISearchBar *mySearchBar;
    UISearchDisplayController *searchDisplayController;
}
@property (nonatomic, retain) NSString *groupJID;
@property(nonatomic,retain) UISearchBar *mySearchBar;
@end
