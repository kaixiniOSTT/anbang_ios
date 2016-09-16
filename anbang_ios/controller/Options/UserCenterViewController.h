//
//  UserCenterViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 14-3-25.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "sqlite3.h"
#import <AudioToolbox/AudioToolbox.h>

#import "InformationViewDelegate.h"
@interface UserCenterViewController :  UIViewController<UITableViewDataSource,UITableViewDelegate,InformationViewDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>{
    
    UIImage *imageHead;
    NSURLConnection *connection;

}
@property (nonatomic, retain) NSString *fileName;

@property (retain, nonatomic) UIImage *myPhoto;
@property (retain, nonatomic) UIImage *tempMyPhoto;
@property (retain,nonatomic) UITableView *myTableView;
@property (retain,nonatomic) UIActivityIndicatorView *activityIndicator;



@end

