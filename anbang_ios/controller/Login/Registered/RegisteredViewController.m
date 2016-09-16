//
//  RegisteredViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#define btnWidth 290
#define btnHeight 30

#import "RegisteredViewController.h"
#import "LoginViewController.h"
#import "AKeyRegisteredViewController.h"
#import "AKeyRegisteredTableViewController2.h"

#import "PhoneNumRegisteredViewController.h"
#import "CHAppDelegate.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface RegisteredViewController ()
{
    
}
@end

@implementation RegisteredViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    JLLog_D("Loading Register ViewController");

//    int height;
//    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
//        height=64;
//    }else{
//        height=0;
//    }
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if ( result.height==480) {
        self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"login_background_480.png"]];
    }else if(result.height==568){
        self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"login_background_568.png"]];
    }
    
    btnLogin.frame= CGRectMake(15, result.height-180, btnWidth, btnHeight);
    [btnLogin setTitle:@"登录" forState:UIControlStateNormal];
    [btnLogin setBackgroundImage:[UIImage imageNamed:@"v2_btn_big_01_nomal.9.png"] forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.5] forState:UIControlStateHighlighted];
    
    btnAKeyRegistered.frame=CGRectMake(15, result.height-140,btnWidth, btnHeight);
    [btnAKeyRegistered setTitle:@"一键注册(免费)" forState:UIControlStateNormal];
    [btnAKeyRegistered setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] forState:UIControlStateNormal];
    [btnAKeyRegistered setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.5] forState:UIControlStateNormal];
    [btnAKeyRegistered setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.5] forState:UIControlStateHighlighted];
    btnPhoneNumRegistered.frame=CGRectMake(15, result.height-100,btnWidth, btnHeight);
    [btnPhoneNumRegistered setTitle:@"手机号注册" forState:UIControlStateNormal];
    [btnPhoneNumRegistered setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.5] forState:UIControlStateNormal];    [btnPhoneNumRegistered setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] forState:UIControlStateNormal];
    [btnPhoneNumRegistered setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.5] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{

}

- (IBAction)clickBtnLogin:(id)sender {
    NSLog(@"clickBtnLogin");
    LoginViewController *loginView=[[LoginViewController alloc]init];
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:loginView];
    //    nav.navigationBar.barStyle=UIBarStyleBlack;
    self.view.window.rootViewController=nav;
}


- (IBAction)clickBtnAKeyRegistered:(id)sender {
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"registeredCount"]);
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"registeredCount"] isEqualToString:@"2"]) {
        NSString* date;
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
        date = [formatter stringFromDate:[NSDate date]];
        NSString *firstDate=[[NSUserDefaults standardUserDefaults]objectForKey:@"firstDate"];
        if ([[self intervalFromLastDate:firstDate toTheDate:date]intValue]>1||[[self intervalFromLastDate:firstDate toTheDate:date]intValue]<(-1)) {
            AKeyRegisteredTableViewController2 *aKeyRegisteredView=[[AKeyRegisteredTableViewController2 alloc]init];
            UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:aKeyRegisteredView];
            nav.navigationBar.barStyle = UIBarStyleBlack;
            self.view.window.rootViewController=nav;
        }else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"邦邦社区提醒" message:@"注册太多,两小时后再注册" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else{
        AKeyRegisteredTableViewController2 *aKeyRegisteredView=[[AKeyRegisteredTableViewController2 alloc]init];
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:aKeyRegisteredView];
        nav.navigationBar.barStyle = UIBarStyleBlack;
        self.view.window.rootViewController=nav;
    }
}


- (IBAction)clickBtnPhoneNumRegistered:(id)sender {
    PhoneNumRegisteredViewController *phoneNumView=[[PhoneNumRegisteredViewController alloc]init];
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:phoneNumView];
    self.view.window.rootViewController=nav;
}


//比较两时间
- (NSString *)intervalFromLastDate: (NSString *) dateString1 toTheDate:(NSString *) dateString2
{
    NSArray *timeArray1=[dateString1 componentsSeparatedByString:@"."];
    dateString1=[timeArray1 objectAtIndex:0];
    
    
    NSArray *timeArray2=[dateString2 componentsSeparatedByString:@"."];
    dateString2=[timeArray2 objectAtIndex:0];
    
    NSLog(@"%@.....%@",dateString1,dateString2);
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    NSDate *d1=[date dateFromString:dateString1];
    
    NSTimeInterval late1=[d1 timeIntervalSince1970]*1;
    
    
    
    NSDate *d2=[date dateFromString:dateString2];
    
    NSTimeInterval late2=[d2 timeIntervalSince1970]*1;
    
    
    
    NSTimeInterval cha=late2-late1;
    NSString *timeString=@"";
    NSString *house=@"";
   // NSString *min=@"";
   // NSString *sen=@"";
    
   // sen = [NSString stringWithFormat:@"%d", (int)cha%60];
    // min = [min substringToIndex:min.length-7];
    // 秒
   // sen=[NSString stringWithFormat:@"%@", sen];
    
    
    
   // min = [NSString stringWithFormat:@"%d", (int)cha/60%60];
    // min = [min substringToIndex:min.length-7];
    // 分
    //min=[NSString stringWithFormat:@"%@", min];
    
    
    // 小时
    house = [NSString stringWithFormat:@"%d", (int)cha/3600];
    // house = [house substringToIndex:house.length-7];
    house=[NSString stringWithFormat:@"%@", house];
    
    timeString=[NSString stringWithFormat:@"%@",house];
    
    
    return timeString;
}

@end
