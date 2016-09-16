//
//  AboutUsViewController.m
//  anbang_ios
//
//  Created by seeko on 14-4-17.
//  Copyright (c) 2014年 ch. All rights reserved.
//


#import "AboutUsViewController.h"
#import "CHAppDelegate.h"
@interface AboutUsViewController ()
{
    UIActivityIndicatorView *activityIndicator;
    
}
@end

@implementation AboutUsViewController

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
        //self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    
    self.title = NSLocalizedString(@"aboutIcircall.aboutUs",@"title");
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIWebView *aboutUsWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-Both_Bar_Height)];
    aboutUsWebView.delegate=self;
    
    //    helpWebView.scalesPageToFit=YES;
    [self.view addSubview:aboutUsWebView];
    
    NSURL* url = [NSURL URLWithString:@"http://www.anbanggroup.com/about.html"];//创建URL
    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
    [aboutUsWebView loadRequest:request];//加载
    [aboutUsWebView setScalesPageToFit:YES];
    //    [helpWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '200%'"];
    // [aboutUsWebView release];
    
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    // CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
    // [appDelegate hideTabBar:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
