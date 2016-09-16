//
//  GroupQrCodeViewController.h
//  anbang_ios
//
//  Created by seeko on 14-5-29.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
//#import "WeiboApi.h"
#import "WXApiObject.h"
#import "WXApi.h"
#import "WeiboSDK.h"

#if !TARGET_IPHONE_SIMULATOR
#import <TencentOpenAPI/TencentOAuth.h>
#endif

#import "TencentOpenAPI/QQApiInterface.h"
#import "LXActivity.h"

@interface GroupQrCodeViewController : UIViewController<MFMessageComposeViewControllerDelegate,WXApiDelegate,WBHttpRequestDelegate,QQApiInterfaceDelegate ,LXActivityDelegate
#if !TARGET_IPHONE_SIMULATOR
,TencentSessionDelegate
#endif
>

{
    UIImageView *headImage;
    UIImageView *QrCoedeImage;
    
    NSString *groupName;
    UIAlertView *saveAlert;
    //    WeiboApi *wbapi;
    enum WXScene _scene;
#if !TARGET_IPHONE_SIMULATOR
    TencentOAuth *_tencentOAuth;
#endif
}
//@property(nonatomic,retain)WeiboApi *wbapi;
@property(nonatomic,retain)NSString *labNmaetext;
@property(nonatomic,retain)UIImage *hearImage;
@property(nonatomic,retain)NSString *groupJID;
@property(nonatomic,retain)NSString *groupName;

- (void) sendTextContent;
@end