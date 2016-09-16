//
//  CallRecordsViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 14-6-25.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"


@interface CallRecordsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    sqlite3 *database;
         BOOL isPhone;

    //    id<dialdelegate> delegate;
}
//@property(assign,nonatomic)id<dialdelegate> delegate;

@property(nonatomic,retain)  UITableView *tbBuddy;
@property(nonatomic,retain)  NSString *receiveUserJID;
-(void)refreshData;
@end
