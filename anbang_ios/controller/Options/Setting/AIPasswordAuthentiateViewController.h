//
//  AIPasswordAuthentiateViewController.h
//  anbang_ios
//
//  Created by rooter on 15-4-2.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBaseViewController.h"

@interface AIPasswordAuthentiateViewController : AIBaseViewController
{
    UITextField *mTextField;
}

/**
 * 1 - 解绑手机、 2 - 更换手机、 3 - 解绑邮箱、 4 - 更换邮箱
 */
@property (assign, nonatomic) NSInteger operationType;

@end
