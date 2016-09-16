//
//  ContactInfo.h
//  anbang_ios
//
//  Created by appdor on 3/26/15.
//  Copyright (c) 2015 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@interface ContactInfo : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet NSLayoutConstraint *height;
}

@property (nonatomic, assign) BOOL rightBarButtonHidden;

@property (nonatomic, retain) NSString *jid;
@property (nonatomic, retain) UserInfo* userinfo;
@end
