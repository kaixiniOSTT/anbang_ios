//
//  GroupAddContactsTableViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 14-4-23.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface GroupAddContactsTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>
{
    sqlite3 *database;
    
    // NSMutableArray *dataArray;
    NSMutableArray *searchResults;
    NSMutableArray *selectedResults;
    UISearchBar *mySearchBar;
    UISearchDisplayController *searchDisplayController;
}
@property(nonatomic,retain) UIImageView *imageView;
@property(nonatomic,retain)NSString * avtarURL;
@end

