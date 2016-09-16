//
//  VoipViewController.h
//  Icircall_ios
//
//  Created by fighting on 14-4-6.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoipModule.h"
#import "APPRTCViewController.h"


@interface VoipViewController : UIViewController<VoipDelegate>

@property(nonatomic,retain) VoipModule* voipModule;


@end
