//
//  AIBindEmailDetailController.h
//  anbang_ios
//
//  Created by rooter on 15-3-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBaseViewController.h"

@interface AIBindEmailDetailController : AIBaseViewController<UITextFieldDelegate>

@property (copy, nonatomic) NSString *mailAddress;

@end
