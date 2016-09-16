//
//  AddressBookViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 14-4-23.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "sqlite3.h"
@interface AddressBookViewController3 : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, UISearchDisplayDelegate,UIActionSheetDelegate>
{
    sqlite3 *database;
     BOOL isVideo;

}
@property(nonatomic,retain)  NSString *receiveUserJID;
@property(nonatomic,retain)  NSString *receiveName;
@property (nonatomic, retain) UILocalizedIndexedCollation *collation;
@property(nonatomic, strong, readonly) UISearchBar *searchBar;

@property(nonatomic,retain)NSString * phoneNum;
@property (nonatomic, retain) NSMutableArray *dataArr;
@property (nonatomic, retain) NSMutableArray *sortedArrForArrays;
@property (nonatomic, retain) NSMutableArray *sectionHeadsKeys;

@end
