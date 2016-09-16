//
//  AISetBackupNameViewController.h
//  anbang_ios
//
//  Created by rooter on 15-4-8.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBaseViewController.h"

@interface AISetBackupNameViewController : AIBaseViewController <UITextFieldDelegate>
{
    UITextField *mTextField;
}

@property (copy, nonatomic) NSString *jid;

@end
