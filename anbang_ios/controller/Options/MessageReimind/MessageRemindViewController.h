//
//  MessageRemindViewController.h
//  anbang_ios
//
//  Created by seeko on 14-3-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MessageRemindViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

-(BOOL)switchSound;
-(BOOL)switchVibration;
@end
@protocol MessageRemindViewControllerDelegate <NSObject>

-(BOOL)messageRemind;

@end