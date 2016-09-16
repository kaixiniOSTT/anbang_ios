//
//  DialViewController.h
//  anbang_ios
//
//  Created by seeko on 14-4-23.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "RoyaDialViewDelegate.h"
#import "VoipModule.h"

@interface DialViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,RoyaDialViewDelegate,VoipDelegate,UITextFieldDelegate,UIActionSheetDelegate>
{
    sqlite3 *database;
//    id<dialdelegate> delegate;
}
//@property(assign,nonatomic)id<dialdelegate> delegate;
@property(nonatomic,retain) VoipModule* voipModule;
@property(nonatomic,retain)  UITableView *tbBuddy;
@end
