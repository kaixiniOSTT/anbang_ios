//
//  ContactsDetailsViewController.h
//  anbang_ios
//
//  Created by silenceSky  on 14-5-10.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsDetailsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate >{
     UIImage *contactsAvatar;
      NSString *loadData;
     NSURLConnection *connection;
     UIView *moveBubbleView1;
     UIView *moveBubbleView2;
     UIView *moveBubbleView3;
     UIView *moveBubbleView4;
     UIView *moveBubbleView5;

     UIImageView *bubble1;
     UIImageView *bubble2;
     UIImageView *bubble3;
     UIImageView *bubble4;
     UIImageView *bubble5;

}

@property (retain,nonatomic) UITableView *tableView;
@property (retain,nonatomic) NSString *contactsUserName;
@property (retain,nonatomic) NSString *contactsRemarkName;
@property (retain,nonatomic) NSString *contactsNickName;
@property (retain,nonatomic) NSString *contactsAvatarURL;
@property (retain,nonatomic) NSString *contactsJID;

@property (nonatomic, retain) NSString *blackListStatus;

@property (nonatomic, retain) NSString *fileName;

@property (strong, nonatomic) IBOutlet UIButton *defaultButton;

@property (nonatomic, retain) NSString *sourceFlag;

@end
