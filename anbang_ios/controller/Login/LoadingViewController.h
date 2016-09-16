//
//  LoadingViewController.h
//  anbang_ios
//
//  Created by seeko on 14-4-5.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "TencentOpenAPI/QQApiInterface.h"

@interface LoadingViewController : UIViewController<WXApiDelegate>
{
    sqlite3 *database;
    UIButton*checkbox;
}
@end
