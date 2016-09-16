//
//  AIUIWebViewController.h
//  anbang_ios
//
//  Created by Kim on 15/5/7.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@class AIImageBarButtonItem;

typedef NS_ENUM(NSInteger, AIUIWebViewMode) {
    AIUIWebViewModePush = 0,
    AIUIWebViewModePresent,
    AIUIWebViewModeRoot,
};

@interface AIUIWebViewController : UIViewController<UIWebViewDelegate>
{
    UIWebView *mWebView;
    MBProgressHUD *mHub;
    BOOL mHasLoaded;
    NSMutableURLRequest *homeRequest;
    NSString *mShareContent;
    NSString *mShareTitle;
    NSString *mShareImage;
    UIButton *mCloseButton;
    UIBarButtonItem *mActivityItem;
    AIImageBarButtonItem *mMoreItem;
}
@property (nonatomic, copy) NSString* url;//链接
@property (nonatomic, copy) NSString* html;//html代码
@property (nonatomic, copy) NSString* resource;//资源路径
@property (nonatomic, copy) NSString* webViewTitle;//webview默认标题
@property(nonatomic) BOOL usingCache;//是否使用缓存，默认使用
@property(nonatomic) NSInteger cachePolicy;//使用缓存策略
@property(nonatomic) BOOL usingToken;//自动拼token参数，默认不使用
@property(nonatomic) BOOL usingLoading;//访问URL时是否有loading，默认有Loading
@property(nonatomic) BOOL loadingOnce;//访问URL时是否只loading一次，默认只加载一次
@property(nonatomic) BOOL usingCookie;//使用cookies, 默认使用
@property(nonatomic) BOOL usingPost;//使用post方式, 默认使用get
@property(nonatomic, strong) NSDictionary *params;//参数，默认拼成param=urlencode({key:value})
@property(nonatomic) AIUIWebViewMode mode;//AIUIWebView模式
@end
