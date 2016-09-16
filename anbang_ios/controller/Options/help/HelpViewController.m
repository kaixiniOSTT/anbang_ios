//
//  HelpViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//
// 帮助与反馈
#define fontSize @"20"
#import "HelpViewController.h"
#import "CHAppDelegate.h"
@interface HelpViewController ()
{
    UIActivityIndicatorView *activityIndicator;
    
}
@end

@implementation HelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    //CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate hideTabBar:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    // 帮助与反馈
    self.title=NSLocalizedString(@"helpFeedback.title",@"title");
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIWebView *helpWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-Both_Bar_Height)];
    helpWebView.delegate=self;
    
    
    //    helpWebView.scalesPageToFit=YES;
    [self.view addSubview:helpWebView];
    NSURL* url = [NSURL URLWithString:@"http://www.anbanggroup.com/introduction.html"];//创建URL
    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
    [helpWebView loadRequest:request];//加载
    [helpWebView setScalesPageToFit:YES];
    //    [helpWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '200%'"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UIWebViewDelegate
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KCurrWidth, self.view.bounds.size.height)];
    [view setTag:108];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.1];
    [self.view addSubview:view];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:view.center];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [view addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
}
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
    [activityIndicator stopAnimating];
    UIView *view = (UIView*)[self.view viewWithTag:108];
    [view removeFromSuperview];
}
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError:%@", error);
    [activityIndicator stopAnimating];
    UIView *view = (UIView*)[self.view viewWithTag:108];
    [view removeFromSuperview];
}
-(void)dealloc{
}

@end
