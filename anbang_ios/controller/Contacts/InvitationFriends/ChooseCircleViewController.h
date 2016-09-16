//
//  ChooseCircleViewController.h
//  anbang_ios
//
//  Created by seeko on 14-4-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseCircleViewDelegate.h"
@interface ChooseCircleViewController : UIViewController<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain)id<ChooseCircleViewDelegate> delegate;
@property(nonatomic,retain) NSString *fromFlag;

@end
