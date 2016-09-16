//
//  PrivacySettingViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 15-3-25.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivacySettingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>{
    UITableView *privacySettingTableView;
}

@end
