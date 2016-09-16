//
//  AddressBookViewController.h
//  anbang_ios
//
//  Created by seeko on 14-4-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "sqlite3.h"
@interface AddressBookViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, UISearchDisplayDelegate>
{
    sqlite3 *database;
}
@property (nonatomic, retain) NSMutableArray *sectionsArray;
@property (nonatomic, retain) UILocalizedIndexedCollation *collation;
@property(nonatomic, strong, readonly) UISearchBar *searchBar;
@end
