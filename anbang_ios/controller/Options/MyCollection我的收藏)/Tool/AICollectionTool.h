//
//  AICollectionTool.h
//  anbang_ios
//
//  Created by rooter on 15-5-7.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AICollection;

@interface AICollectionTool : UIView

+ (void)registerNotificationsInController:(UIViewController *)viewController;
+ (void)removeNotificationsInContorller:(UIViewController *)viewContorller;

+ (void)retweet:(NSArray *)collections presentDetailControllerWithController:(UIViewController *)aController;
+ (void)trash:(NSArray *)collections loadingInViewController:(UIViewController *)controller;
+ (void)getCollectionList;

@end
