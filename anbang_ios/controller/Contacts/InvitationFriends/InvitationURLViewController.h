//
//  InvitationURLViewController.h
//  anbang_ios
//
//  Created by seeko on 14-5-30.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseCircleViewDelegate.h"
@interface InvitationURLViewController : UIViewController<ChooseCircleViewDelegate>
{

}
@property(nonatomic ,retain)NSString *strGroupJID;
@end
