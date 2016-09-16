//
//  AIControllersTool.h
//  anbang_ios
//
//  Created by rooter on 15-4-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIControllersTool : NSObject

// Loading view
+ (void)loadingViewShow:(UIViewController *)controller;
+ (void)loadingVieHide:(UIViewController *)controller;

// Tips view
+ (void)tipViewShow:(NSString *)tip;

@end
