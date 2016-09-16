//
//  BBCommunityVC.m
//  anbang_ios
//
//  Created by yangsai on 15/4/13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "BBCommunityVC.h"
#import "MBProgressHUD.h"
#import "ChatInit.h"
#import "BBCommunityRequestHandle.h"
#import <CoreLocation/CoreLocation.h>
#import "Utility.h"

#define kUrlCacheExpiresInSecond 1800
#define kBBCUrl [NSString stringWithFormat:@"%@/list-public",httpRequset]

static NSMutableDictionary *sURLDictionary = nil;
static long firstRequestTime = 0;


@interface BBCommunityVC ()<UIWebViewDelegate, CLLocationManagerDelegate, BBCommunityRequestHandleDelegate>
{
    UIBarButtonItem *mActivityItem;
}
@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic, retain) CLLocation *locInfo;
@property (nonatomic, strong) UIButton* reloadWebBT;
@property (nonatomic, strong) UIButton* backWebBT;
@property (nonatomic, copy) NSString* latitude;
@property (nonatomic, copy) NSString* longitude;
@property (nonatomic, copy) NSString* mytoken;
@property (nonatomic, copy) NSString* singlecode;
@property (nonatomic, copy) NSString* urlTemp;
@property (nonatomic, copy) NSString* mobilesystem;
@property (nonatomic, strong) BBCommunityRequestHandle* requestHandle;
@property (nonatomic, assign) BOOL isEnd;

@end

@implementation BBCommunityVC

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"locInfo"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置navigationBar的标题
    [self.navigationItem setTitle:@"工作台"];
    
    //获得唯一标识
    self.singlecode = [[UIDevice currentDevice].identifierForVendor UUIDString];
    
    CGRect frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Both_Bar_Height);
    //创建webview
    self.webView = [[UIWebView alloc]initWithFrame:frame];
    _webView.delegate = self;
    self.view.backgroundColor = Controller_View_Color;
    _webView.backgroundColor = Controller_View_Color;
    [self.view addSubview:_webView];
    
    
    //加载初始页面
    NSURL *url =[[NSURL alloc] initWithString:kBBCUrl];
    
    BOOL firstTime = NO;
    if(firstRequestTime == 0){
        firstRequestTime = [[NSDate date] timeIntervalSince1970];
        firstTime = YES;
    }
    
    NSURLRequestCachePolicy cachePolicy = 1;
    if(!firstTime && [[NSDate date] timeIntervalSince1970] - firstRequestTime < kUrlCacheExpiresInSecond){
        cachePolicy = 2;
    }
    
    NSMutableURLRequest *request =  [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:cachePolicy timeoutInterval:60];
    [_webView loadRequest:request];
    
    
    AITitleBarButtonItem *close = [[AITitleBarButtonItem alloc]initWithTitle:@"关闭" target:self action:@selector(pop)];
    close.button.hidden = YES;
    self.backWebBT = close.button;
    
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(backWebUrlWithBotton:)],
                                               close];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];//指定进度轮的大小
    [activityIndicatorView startAnimating];
    mActivityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
    self.navigationItem.rightBarButtonItem = mActivityItem;
    
    //获取token
    self.mytoken = [[NSUserDefaults standardUserDefaults] valueForKey:@"mytoken"];
    if (_mytoken == nil || [_mytoken isEqualToString:@""]) {
        
       MBProgressHUD* hub = [[MBProgressHUD alloc]initWithFrame:self.view.frame];
        hub.labelText = @"请点击\"返回\"后重新进入该页面!";
        [self.view addSubview:hub];
        [hub show:YES];
        [hub hide:YES afterDelay:2];
        
    }
    JLLog_D(@"token = %@", self.mytoken);
    
    //获得初始化坐标
    
    self.locInfo = nil;
    
    [self addObserver:self forKeyPath:@"locInfo" options:NSKeyValueObservingOptionNew context:nil];
    
    self.locManager = [[CLLocationManager alloc] init];
    // 设置定位精度：最佳精度
    self.locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    // 设置距离过滤器为50米，表示每移动50米更新一次位置
    self.locManager.distanceFilter = 50;
    self.locManager.delegate = self;
    
    self.mobilesystem = [@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]];
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [self.locManager requestWhenInUseAuthorization];
        [self.locManager requestAlwaysAuthorization];
    }
    
    //初始化变量

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --UIWebViewDelegate

//截取js触发iOS的操作
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType{
    self.navigationItem.rightBarButtonItem = mActivityItem;
    
    NSArray* urlArray = [[request.URL absoluteString] componentsSeparatedByString:@":do//url="];
    
    if(urlArray.count < 2){
        return YES;
    }
    
    
    if([[urlArray firstObject] isEqualToString:@"post"]){
        [self resultDataPost:[urlArray  objectAtIndex:1]];
        return NO;
    }else if([[urlArray firstObject] isEqualToString:@"get"]){
        [self resultURl:[urlArray  objectAtIndex:1]];
        return NO;
    }else if([[urlArray firstObject] isEqualToString:@"forward"]){
        [self resultURl:[urlArray  objectAtIndex:1]];
        return NO;
    }
    
    if([[request.URL absoluteString] hasPrefix:@"closewindow://"]){
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    
    return YES;
}

//页面加载完毕
- (void)webViewDidFinishLoad:(UIWebView *)webView{

    [self renderTitle:webView];
    
    [self registerWeixinJSBridgeObject:webView];
    
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)renderTitle:(UIWebView *)webView
{
    [self.navigationItem setTitle:[webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
}

- (void)registerWeixinJSBridgeObject:(UIWebView *)webView
{
    [webView stringByEvaluatingJavaScriptFromString:
     @"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"var WeixinJSBridge=new Object();WeixinJSBridge.invoke=function(func,options,callback){window.location.href = 'http://'+func;};\";"
     "document.getElementsByTagName('head')[0].appendChild(script);"
     ];
}


//页面加载失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.navigationItem.rightBarButtonItem = nil;
}

//开始定位
- (void)getLocationCoordinate{
    if([CLLocationManager locationServicesEnabled])
    {
        [_locManager startUpdatingLocation];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"无法使用定位服务！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [self.view addSubview:alert];
        [alert show];
    }
}

//定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"定位失败,请重新定位！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [self.view addSubview:alert];
    [alert show];
}


//定位获得地理位置经纬度
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    //获得查询地址信息
    if (!_isEnd) {
        self.locInfo = location;
        self.isEnd = YES;
    }
}


//观察者观察变量变化
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"locInfo"]) {
        
        //经度
        self.longitude = [NSString stringWithFormat:@"%f",self.locInfo.coordinate.longitude] ;
        //纬度
        self.latitude =  [NSString stringWithFormat:@"%f",self.locInfo.coordinate.latitude ];
        
        NSDictionary *paramDict = @{@"longitude":_longitude,
                                           @"latitude":_latitude,
                                           @"singlecode": _singlecode,
                                           @"mobilesystem": _mobilesystem};
        NSError *error = nil;
        NSData *paramData = [NSJSONSerialization dataWithJSONObject:paramDict options:(NSJSONWritingOptions)nil error:&error];
        NSString *paramJson = @"";
        if (error) {
            NSLog(@"error: %@",[error localizedDescription]);
            return;
        }
        
        paramJson = [[NSString alloc] initWithData:paramData encoding:NSUTF8StringEncoding];
        NSLog(@"response : %@",paramData);
        NSLog(@"backData : %@",paramJson);
        
        NSString* param = [NSString stringWithFormat:@"token=%@&param=%@", _mytoken, paramJson];
        
        self.requestHandle = [[BBCommunityRequestHandle alloc]initWithURLString:_urlTemp Param:param Method:@"POST" Header:nil Delegate:self];
      
    }

}


//重新加载页面
-(void) reloadWebViewWithButton:(UIButton*) bt
{
    self.navigationItem.rightBarButtonItem = nil;
    
    NSURL *url =[[NSURL alloc] initWithString:kBBCUrl];
    NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url  cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];

    [_webView loadRequest:request];
}


//返回按钮操作
- (void)backWebUrlWithBotton:(UIButton*)bt{
    if([_webView canGoBack]){
        [self.backWebBT setHidden:NO];
        [_webView goBack];
    }else{
        [self pop];
    }
    
}

- (void)pop
{
   [self.navigationController popViewControllerAnimated:YES];
}

-(void)resultURl:(NSString*)url{
    NSString* tempurl = url;
    if([tempurl componentsSeparatedByString:@"?"].count == 1){
        tempurl = [tempurl stringByAppendingString:[NSString stringWithFormat:@"?token=%@", _mytoken]];
    }else{
        tempurl = [tempurl stringByAppendingString:[NSString stringWithFormat:@"&token=%@", _mytoken]];
    }
    
    NSMutableURLRequest *request =  [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:tempurl] cachePolicy:1 timeoutInterval:120];
    
    [_webView loadRequest:request];
}

-(void)resultDataGet:(NSString*)url{
    self.navigationItem.rightBarButtonItem = mActivityItem;
}

-(void)resultDataPost:(NSString*)url{
    _isEnd = NO;
    [self getLocationCoordinate];
    _urlTemp = url;
}

- (void)requestHandle:(BBCommunityRequestHandle*)requestHandle RequestSuccessWithResponse:(NSHTTPURLResponse*)response
{
}


-(void)requestHandle:(BBCommunityRequestHandle *)requestHandle RequestSuccessWithData:(NSData *)data{
    self.navigationItem.rightBarButtonItem = nil;
    NSDictionary* dataDic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"%@", dataDic);
    NSString* msg = [dataDic objectForKey:@"content"];
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [self.view addSubview:alert];
    [alert show];
}


-(void)requestHandle:(BBCommunityRequestHandle *)requestHandle RequestSuccessWithError:(NSError *)error{
    self.navigationItem.rightBarButtonItem = nil;
    NSString* msg = @"请求失败";
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [self.view addSubview:alert];
    [alert show];
}

@end
