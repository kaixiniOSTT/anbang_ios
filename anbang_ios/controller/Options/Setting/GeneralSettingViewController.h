//
//  GeneralSettingViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 15-3-24.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@interface GeneralSettingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>{
   UITableView *generalSettingTableView;
}

@property (strong, nonatomic) UserInfo *userInfo;

@end
