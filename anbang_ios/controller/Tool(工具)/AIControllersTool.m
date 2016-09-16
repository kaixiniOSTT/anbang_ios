//
//  AIControllersTool.m
//  anbang_ios
//
//  Created by rooter on 15-4-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIControllersTool.h"
#import "DejalActivityView.h"
#import "JLTipsView.h"
#import "MBProgressHUD.h"

@implementation AIControllersTool

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Status view
////////////////////////////////////////////////////////////////////////////////////////////////////

+ (void)loadingViewShow:(UIViewController *)controller
{
    [controller.view endEditing:YES];
    [DejalBezelActivityView activityViewForView:controller.view];
}

+ (void)loadingVieHide:(UIViewController *)controller
{
    [controller.view endEditing:NO];
    [DejalBezelActivityView removeViewAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Tip view
////////////////////////////////////////////////////////////////////////////////////////////////////

+ (void)tipViewShow:(NSString *)tip
{
    JLTipsView *tipView = [[JLTipsView alloc] initWithTip:tip];
    [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

@end
