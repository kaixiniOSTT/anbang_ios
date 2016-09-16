//
//  InformationViewController.h
//  anbang_ios
//
//  Created by seeko on 14-3-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "InformationViewDelegate.h"
#import "UserInfo.h"

@interface InformationViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,ASIHTTPRequestDelegate>
{
    IBOutlet UITableView *informationTableView;
    NSURLConnection *connection;
    UIImage *imageHead;
    
}
@property (nonatomic, assign) id <InformationViewDelegate> delegate;

//图片对应的缓存在沙河中的路径
@property (nonatomic, retain) NSString *fileName;
@property(retain,nonatomic)NSArray *informationList;

@property (strong, nonatomic) UserInfo *userInfo;

-(void)loadData;
@end
