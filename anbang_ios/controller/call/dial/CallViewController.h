//
//  CallViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 14-12-23.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallRecordsViewController.h"
#import "CallContactsViewController.h"
#import "DialViewController2.h"

@interface CallViewController : UIViewController{
    UISegmentedControl *segmentedControl;
    CallRecordsViewController *callRecordsVC;
    CallContactsViewController *callContactsVC;
    DialViewController2 *dialVC;
}

@end
