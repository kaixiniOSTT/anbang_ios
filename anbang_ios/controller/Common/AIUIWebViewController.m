//
//  AIUIWebViewController.m
//  anbang_ios
//
//  Created by Kim on 15/5/7.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIUIWebViewController.h"
#import "MBProgressHUD.h"
#import <ShareSDK/ShareSDK.h>
#import "AICustomShareView.h"
#import "StrUtility.h"
#import "AIHttpTool.h"
#import "ImageUtility.h"
#import "AIArticle.h"
#import "AICurrentContactController.h"
#import "Photo.h"
#import "AINavigationController.h"
#import "AITitleBarButtonItem.h"
#import "AIFlixBarButtonItem.h"
#import "AIImageBarButtonItem.h"
#import "AIBackBarButtonItem.h"

@interface AIUIWebViewController ()

@property (nonatomic, strong) AICustomShareView *customView;

@end

@implementation AIUIWebViewController

- (void)setupNavigationItem
{
    AITitleBarButtonItem *closeItem = [[AITitleBarButtonItem alloc]initWithTitle:@"关闭" target:self action:@selector(close)];
    closeItem.button.hidden = YES;
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(back)],
                                               closeItem];
    
    mCloseButton = closeItem.button;
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];//指定进度轮的大小
    [activityIndicatorView startAnimating];
    mActivityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
    self.navigationItem.rightBarButtonItem = mActivityItem;
    
    mMoreItem = [[AIImageBarButtonItem alloc]initWithImageNamed:@"header_button_set" target:self action:@selector(moreAction)];
}

- (void)setupInterface
{
    CGRect frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Both_Bar_Height);
    mWebView = [[UIWebView alloc] initWithFrame:frame];
    mWebView.backgroundColor = Controller_View_Color;
    mWebView.delegate = self;
    mWebView.scalesPageToFit = YES;
    [self.view addSubview:mWebView];
}

- (id) init {
    if(self = [super init]){
        _usingToken = NO;
        _usingCache = YES;
        _usingCookie = YES;
        _cachePolicy = 0;
        _usingPost = NO;
        _mode = AIUIWebViewModePush;
    }
    
    return  self;
}

- (AICustomShareView *)customView
{
    if (!_customView) {
        _customView = [[AICustomShareView alloc] init];
    }
    return _customView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationItem];
    [self setupInterface];
    
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    
    if(self.html != nil && ![@"" isEqualToString:self.html]){
        [mWebView loadHTMLString:self.html baseURL:nil];
    } else if(self.url != nil && ![@"" isEqualToString:self.url]) {
        
        BOOL hasParam = NO;
        NSRange range = [self.url rangeOfString:@"?"];
        if(range.length > 0){
            hasParam = YES;
        }
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"mytoken"];
        //传token
        if(self.usingToken){
            [params setObject:token forKey:@"token"];
        }
        
        //传param
        if(self.params){
            NSError *error = nil;
            NSData *paramData = [NSJSONSerialization dataWithJSONObject:self.params options:(NSJSONWritingOptions)nil error:&error];
            NSString *paramJson = @"";
            if (error) {
                NSLog(@"error: %@",[error localizedDescription]);
                return;
            }
            
            paramJson = [[NSString alloc] initWithData:paramData encoding:NSUTF8StringEncoding];
            
            [params setObject:paramJson forKey:@"param"];
        }
        
        NSString *paramStr = @"";
        for(NSString *key in params.allKeys)
        {
            NSString *param = [NSString stringWithFormat:@"%@=%@", key, params[key]];
            paramStr = [paramStr isEqualToString:@""] ? param : [NSString stringWithFormat:@"%@&%@", paramStr, param];
        }
        
        if(!_usingPost && ![StrUtility isBlankString:paramStr]){
            self.url = [self.url stringByAppendingFormat:@"%@%@", hasParam?@"&":@"?", paramStr];
        }
        
        self.url = [self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *url =[NSURL URLWithString:self.url];
        NSInteger cachePolicy = _usingCache ? _cachePolicy : 1;
        JLLog_D(@"cachePolicy = %d", cachePolicy);
        
        homeRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:120];
        
        homeRequest.HTTPShouldHandleCookies = _usingCookie;
        
        if(_usingPost){
            [homeRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [homeRequest setHTTPMethod:@"POST"];
            NSData *postData = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
            [homeRequest setHTTPBody:postData];
        }
        
        [mWebView loadRequest:homeRequest];
    } else if(self.resource != nil && ![@"" isEqualToString:self.resource]) {
        NSString * htmlPath = [[NSBundle mainBundle] pathForResource:self.resource ofType:@"html"];
        NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
        [mWebView loadHTMLString:htmlCont baseURL:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark
#pragma mark Actions

- (void)back
{
    if ([mWebView canGoBack]) {
        mCloseButton.hidden = NO;
        [mWebView goBack];
    }else {
        
        [self close];
    }
}

- (void)close
{
    if (_mode == AIUIWebViewModePresent) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if(_mode == AIUIWebViewModeRoot){
        self.tabBarController.selectedIndex = 0;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)moreAction
{
    UIImage *shareImage = nil;
    
    
    if(mShareImage == nil){
        shareImage = [UIImage imageNamed:@"icon_link"];
    } else {
        NSURL* url = [NSURL URLWithString:[mShareImage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];//网络图片url
        NSData* data = [NSData dataWithContentsOfURL:url];//获取网咯图片数据
        if(data!=nil)
        {
            
            shareImage = [ImageUtility imageWithImageSimple:[[UIImage alloc] initWithData:data]
                                               scaledToSize:CGSizeMake(128, 128)];
        }
    }
    
    if(shareImage == nil){
        shareImage = [UIImage imageNamed:@"icon_link"];
    }
    
    NSDictionary *contentDict = @{@"content": [StrUtility string: mShareContent defaultValue:mWebView.request.URL.absoluteString],
                                  @"image": shareImage,
                                  @"title": [StrUtility string: mShareTitle defaultValue:mWebView.request.URL.absoluteString],
                                  @"url": mWebView.request.URL.absoluteString,
                                  @"description": [StrUtility string: mShareContent defaultValue:mWebView.request.URL.absoluteString],
                                  @"mediaType": [NSNumber numberWithInt:SSPublishContentMediaTypeNews]};
    
    __weak typeof(self)wself = self;
    [self.customView shareWithContent:contentDict
                             complete:^(AISharePlatform platform, NSDictionary *publishContent) {
        switch (platform) {
            case AISharePlatformBBFriends:
                [wself shareToBBFriends:publishContent];
                break;
                
            default:
                break;
        }
    }];
    
}

- (void)shareToBBFriends:(NSDictionary *)publishContent
{
    AIArticle *article = [[AIArticle alloc] init];
    article.title = publishContent[@"title"];
    article.cover = [Photo image2String:publishContent[@"image"]];
    article.src = publishContent[@"url"];
    article.abstract = publishContent[@"content"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:article.keyValues
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *text = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
    
    NSArray *messages = @[@{@"text" : text, @"subject" : @"article"}];
    
    AICurrentContactController *controller = [[AICurrentContactController alloc] init];
    controller.messages = messages;
    AINavigationController *navigation =
    [[AINavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navigation animated:YES completion:nil];
}

#pragma end

#pragma mark
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    return [self handleJSBridgeEvent:request];
}

- (BOOL)handleJSBridgeEvent:(NSURLRequest *)request
{
    if([@"closewindow://" isEqualToString:request.URL.absoluteString]){
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.navigationItem.rightBarButtonItem = mActivityItem;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.url = webView.request.URL.absoluteString;
    [self renderTitle:webView];
    
    [self runReadability:webView];
    
    [self registerWeixinJSBridgeObject:webView];

    self.navigationItem.rightBarButtonItem = mMoreItem;
}

- (void)renderTitle:(UIWebView *)webView
{
    if(![StrUtility isBlankString:self.webViewTitle]){
        mShareTitle = self.webViewTitle;
    } else {
        mShareTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    
    [self.navigationItem setTitle:mShareTitle];
}

- (NSString *)flattenHTML:(NSString *)html trimWhiteSpace:(BOOL)trim
{
    NSScanner *theScanner = [NSScanner scannerWithString:html];
    NSString *text = nil;
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                  [ NSString stringWithFormat:@"%@>", text]
                  withString:@""];
        }
    return trim ? [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : html;
}

- (NSString*)truncateString:(NSString*)origin max:(int)max
{
    if(origin == nil){
        return @"";
    }
    
    return origin.length > 50?[origin substringToIndex:50]:origin;
}

- (void)runReadability:(UIWebView *)webView
{
    NSString *readabilityAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_READABILITY_ADDRESS"];
    //NSString *readabilityAddress = @"http://10.10.10.132:9081/readability/";
    if([StrUtility isBlankString:readabilityAddress]) return;
    
    NSString *readabilityUrl = [NSString stringWithFormat:@"%@%@parse",readabilityAddress,[readabilityAddress hasSuffix:@"/"]?@"":@"/"];
    
    //contentType:@"application/x-www-form-urlencoded"
    [AIHttpTool postWithURL:readabilityUrl params:@{@"url":webView.request.URL.absoluteString} success:^(id json) {
        NSDictionary * response = (NSDictionary *)json;
        if(response && [@"0" isEqualToString:response[@"retcode"]]){
            mShareTitle = response[@"title"];
            mShareImage = response[@"imageUrl"];
            mShareContent = response[@"text"];
        }
    } failure:^(NSError *error) {
        JLLog_D(@"error:%@", error.description);
    }];
}

- (void)registerWeixinJSBridgeObject:(UIWebView *)webView
{
    [webView stringByEvaluatingJavaScriptFromString:
            @"var script = document.createElement('script');"
                    "script.type = 'text/javascript';"
                    "script.text = \"var WeixinJSBridge=new Object();WeixinJSBridge.invoke=function(func,options,callback){window.location.href = func+'://';};\";"
                    "document.getElementsByTagName('head')[0].appendChild(script);"
    ];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    JLLog_I(@"web view fail loading (error=%@)", error);
    
    self.navigationItem.rightBarButtonItem = nil;
    
    if([mWebView canGoBack]){
        [mWebView goBack];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (void)setUsingToken:(BOOL)usingToken
//{
//    _usingToken = usingToken;
//}
//
//- (void)setUsingLoading:(BOOL)usingLoading
//{
//    _usingLoading = usingLoading;
//}
//
//- (void)setUsingCache:(BOOL)usingCache
//{
//    _usingCache = usingCache;
//}
//
//- (void)setUsingCookie:(BOOL)usingCookie
//{
//    _usingCookie = usingCookie;
//}
//
//- (void)setLoadingOnce:(BOOL)loadingOnce
//{
//    _loadingOnce = loadingOnce;
//}
//
//- (void)setCachePolicy:(NSInteger)cachePolicy
//{
//    _cachePolicy = cachePolicy;
//}
//
//- (void)setUsingPost:(BOOL)usingPost
//{
//    _usingPost = usingPost;
//}

- (void)viewWillAppear:(BOOL)animated
{
    if(_mode == AIUIWebViewModeRoot){
        self.tabBarController.tabBar.hidden = YES;
    }
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(_mode == AIUIWebViewModeRoot){
        self.tabBarController.tabBar.hidden = NO;
    }
}

@end
