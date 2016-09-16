//
//  CHAppDeleagteTool.m
//  anbang_ios
//
//  Created by rooter on 15-3-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIAppDeleagteTool.h"
#import "CHNewFeatureController.h"
#import "CHAppDelegate.h"

@implementation AIAppDeleagteTool

+ (void)chooseRootViewController {
    
    // 取出沙盒中存储的上次使用软件的版本号
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hide = [defaults boolForKey:kNew_Feature_Hide];
    
    JLLog_D("Choosing root view controller <show=%d>",hide);
    
    if (!hide) {
        UIApplication *application = [UIApplication sharedApplication];
        application.keyWindow.rootViewController = [[CHNewFeatureController alloc] init];
    }else {
        CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate loadAppConfiguration];
        [appDelegate ui];
    }
}

+ (void)loadConfigureWithUserName:(NSString *)userName {
    /**
     *  User configure files, saved in directory Library/UserConfigures,
     *  They named by userName， typed "plist".
     *  Load to NSUserDefaults when logon, resave when logout.
     */
    NSFileManager *mamager = [NSFileManager defaultManager];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *library = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSString *userConfigureLibrary = [library stringByAppendingPathComponent:@"UserConfigures"];
    
    
}

@end
