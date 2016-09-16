//
//  UseAndPrivacyViewController.m
//  anbang_ios
//
//  Created by seeko on 14-4-17.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "UseAndPrivacyViewController.h"
#import "CHAppDelegate.h"
@interface UseAndPrivacyViewController ()
{
    UIActivityIndicatorView *activityIndicator;
    
}
@end

@implementation UseAndPrivacyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        //self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    self.title =  NSLocalizedString(@"aboutIcircall.item",@"title");
    int height;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        height=64;
    }else{
        height=64;
    }
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIWebView *clauseWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-height)];
    clauseWebView.delegate=self;
    
    //    helpWebView.scalesPageToFit=YES;
    [self.view addSubview:clauseWebView];
    NSURL* url = [NSURL URLWithString:@"http://www.anbanggroup.com/contact.html"];//创建URL
    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
    [clauseWebView loadRequest:request];//加载
    [clauseWebView setScalesPageToFit:YES];
    //    [helpWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '200%'"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    //CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate hideTabBar:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark UIWebViewDelegate
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
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
    [activityIndicator stopAnimating];
    UIView *view = (UIView*)[self.view viewWithTag:108];
    [view removeFromSuperview];
}
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activityIndicator stopAnimating];
    UIView *view = (UIView*)[self.view viewWithTag:108];
    [view removeFromSuperview];
}
-(void)dealloc{
    
}
@end
