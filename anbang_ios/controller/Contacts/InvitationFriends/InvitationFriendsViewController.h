//
//  InvitationFriendsViewController.h
//  anbang_ios
//
//  Created by seeko on 14-4-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//
#import <MessageUI/MessageUI.h>

#import <UIKit/UIKit.h>
#import "ChooseCircleViewDelegate.h"
@interface InvitationFriendsViewController : UIViewController<MFMessageComposeViewControllerDelegate,ChooseCircleViewDelegate>


@end
@protocol JidNameDelegate <NSObject>

-(id)passValue:(NSString *)jidName;

@end