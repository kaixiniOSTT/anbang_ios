//
//  AIBindEmailSucceedViewController.h
//  anbang_ios
//
//  Created by rooter on 15-4-2.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBaseViewController.h"
#import "UserInfo.h"

@interface AIBindEmailSucceedViewController : AIBaseViewController {
    
    UserInfo *mUserInfo;
}

@property (copy, nonatomic) NSString *email;

@end
