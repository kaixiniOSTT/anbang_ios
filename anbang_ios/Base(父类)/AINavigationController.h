//
//  AINavigationController.h
//  anbang_ios
//
//  Created by rooter on 15-3-24.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AINavigationController : UINavigationController<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

@end
