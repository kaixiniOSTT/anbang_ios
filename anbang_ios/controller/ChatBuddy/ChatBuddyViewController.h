//
//  ChatBuddyViewController.h
//  anbang_ios
//
//  Created by rooter on 15-7-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "sqlite3.h"
#import "JSBadgeView.h"
#import "WXApiObject.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#if !TARGET_IPHONE_SIMULATOR
#import <TencentOpenAPI/TencentOAuth.h>
#endif

#import "TencentOpenAPI/QQApiInterface.h"

@interface ChatBuddyViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,MFMessageComposeViewControllerDelegate,WXApiDelegate,WBHttpRequestDelegate,QQApiInterfaceDelegate,UIGestureRecognizerDelegate
#if !TARGET_IPHONE_SIMULATOR
,TencentSessionDelegate
#endif
>

{
    sqlite3 *database;
    NSMutableArray *searchResults;
    NSMutableArray *selectedResults;
    UISearchBar *mySearchBar;
    UIView* customView;
    //UIView* customView2;
    NSTimer* titleTimer;
    
    UISearchDisplayController *searchDisplayController;
    
    //    WeiboApi *wbapi;
    enum WXScene _scene;
#if !TARGET_IPHONE_SIMULATOR
    TencentOAuth *_tencentOAuth;
#endif
    
    NSTimer *loginTimer;
    
    //左上角图像
    UIButton *myButton;
    
    //水泡动画
    UIView *moveBubbleView1;
    UIView *moveBubbleView2;
    UIView *moveBubbleView3;
    UIView *moveBubbleView4;
    UIView *moveBubbleView5;
    
    UIImageView *bubble1;
    UIImageView *bubble2;
    UIImageView *bubble3;
    UIImageView *bubble4;
    UIImageView *bubble5;
    //长按位置
    float bubblePonitY;
    NSString *networkType;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, retain)NSString *myUserName;
@property(nonatomic,retain)NSMutableArray *messages;
@property(nonatomic,retain)NSDictionary *chatDic;
@property(nonatomic,retain) JSBadgeView *badgeView;
@property(nonatomic,retain) UIImageView *imageView;
@property(nonatomic,retain) NSMutableArray *badgeViewArray;
@property(nonatomic,retain)NSString * chatBuddyMessageFlag;//控制通知中心是否处理
@property(nonatomic,retain)NSString * avtarURL;
@property(nonatomic,retain)NSString * navigationItemTitle;

@property (strong, nonatomic) NSArray *options;
#if !TARGET_IPHONE_SIMULATOR
@property(nonatomic,retain) VoipModule* voipModule;
#endif

@end

