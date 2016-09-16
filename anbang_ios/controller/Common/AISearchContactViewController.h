//
//  AISearchContactViewController.h
//  anbang_ios
//
//  Created by rooter on 15-7-16.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DidSelectionCompletedBlock)(UIViewController *viewController);

@interface AISearchContactViewController : UIViewController

@property (copy, nonatomic) DidSelectionCompletedBlock completedBlock;

@end
