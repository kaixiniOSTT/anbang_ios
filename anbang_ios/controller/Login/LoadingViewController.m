//
//  LoadingViewController.m
//  anbang_ios
//
//  Created by seeko on 14-4-5.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "LoadingViewController.h"
#import "CHAppDelegate.h"
#import "DejalActivityView.h"
#import "TKAddressBook.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "AddressBookCRUD.h"
#import "PublicCURD.h"
@interface LoadingViewController ()
{
    //-通讯录----------------
    NSMutableArray *addressBookTemp;
    TKAddressBook *addressBook;
    NSMutableArray *arrName;
    __block BOOL accessGranted;
    NSMutableArray *arrPhoneNum;
    //-----------------------
    int registeredCount;
}
@end

@implementation LoadingViewController
- (CHAppDelegate *)appDelegate
{
	return (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeActivity) name:@"Notification_Load_OK" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookVer) name:@"NCC_AddressBook_Ver" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onecObtainAddressBook) name:@"NCC_AddressBooK_Success" object:nil];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
 
    
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"AppIcon57x57.png"]];
    imageView.frame=CGRectMake(KCurrWidth/2-30, Both_Bar_Height+30, 60, 60);
    [self.view addSubview:imageView];
    
    UILabel *labID=[[UILabel alloc]initWithFrame:CGRectMake(0, Both_Bar_Height+90, KCurrWidth, 20)];
    labID.textColor=[UIColor redColor];
    labID.textAlignment = NSTextAlignmentCenter;
    labID.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    [self.view addSubview:labID];
  
    UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(10, Both_Bar_Height+110, KCurrWidth-20, 100)];
   // NSString *str=[NSString stringWithFormat:NSLocalizedString(@"loading.message",@"message"),labID.text];
    NSString *str=[NSString stringWithFormat:NSLocalizedString(@"loading.message",@"message"),labID.text];
    
    lab.text=str;
    lab.font = [UIFont boldSystemFontOfSize:14.0f];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.numberOfLines = 0;// 不可少Label属性之一
    lab.lineBreakMode = NSLineBreakByCharWrapping;// 不可少Label属性之二
    [self.view addSubview:lab];
   

    
    UIButton *login=[UIButton buttonWithType:UIButtonTypeCustom];
    login.frame=CGRectMake(KCurrWidth/2-90, Both_Bar_Height+260, 180, 35);
    [login setTitle:NSLocalizedString(@"loading.beginToUse",@"action") forState:UIControlStateNormal];
    //[login setBackgroundImage:[UIImage imageNamed:@"startBtn.png"] forState:UIControlStateNormal];
    [login setBackgroundColor:kMainColor5];
    [login setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [login setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [login setBackgroundColor:kMainColor];
    login.titleLabel.font=[UIFont boldSystemFontOfSize:16];
    [login addTarget:self action:@selector(btnLoginClick) forControlEvents:UIControlEventTouchUpInside];
    [login.layer setMasksToBounds:YES];
    [login.layer setCornerRadius:3.0]; //设置矩形四个圆角半径
    [login.layer setBorderWidth:0.0]; //边框宽度
    [self.view addSubview:login];
    accessGranted=NO;  //初始化访问通讯录权限
    
}


-(void)checkboxClick:(UIButton*)btn{
    
    btn.selected=!btn.selected;//每次点击都改变按钮的状态
    
    if(btn.selected){
    }else{
        
        //在此实现打勾时的方法
        
    }
    //在此实现不打勾时的方法
 
}



- (void)removeActivity
{
//    [self permissionsAddressBook];//通讯录权限
//    [self obtainAddressBook];

    //数据初始化等待时间

    [self performSelector:@selector(loginLoadOK) withObject:nil afterDelay:5];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"Notification_Load_OK" object:nil];
    
}

- (void)loginLoadOK{
    [DejalBezelActivityView removeViewAnimated:YES];
    [[self appDelegate]ui];
}


-(void)btnLoginClick{
  [DejalBezelActivityView activityViewForView:self.view];
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"registeredCount"]);
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"registeredCount"]isEqualToString:@"1"]) {
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"registeredCount"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        NSString* date;
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
        date = [formatter stringFromDate:[NSDate date]];
        [[NSUserDefaults standardUserDefaults]setObject:date forKey:@"firstDate"];
        [[NSUserDefaults standardUserDefaults]synchronize];

       
    }else{
        
        [[NSUserDefaults standardUserDefaults]setObject:@"2" forKey:@"registeredCount"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }
   //[DejalBezelActivityView activityViewForView:self.view];
    
//    //数据库初始化
    [PublicCURD createDataBase];
    [PublicCURD createAllTable];
    [PublicCURD updateTable];
    [self load_next];
    //连接服务器
    [[XMPPServer sharedServer]connect];
    
    
}

//登录成功加载完数据跳转
-(void)load_next{


   
    NSTimer *timer;
    int timeInt = 15;
    timer=[NSTimer scheduledTimerWithTimeInterval:timeInt
                                           target:self
                                         selector:@selector(loginReconnection:)
                                         userInfo:nil
                                          repeats:NO];
}


//15秒后未连接
- (void)loginReconnection:(NSTimer *)timer {
 
    if ([XMPPServer sharedServer].isLogin) {
        [timer invalidate];
        timer = nil;
        return;
    }else{
        [[XMPPServer sharedServer]connect];
    }
}



-(void)permissionsAddressBook{
    //----------------xiong 访问通讯录------------------------
    ABAddressBookRef addressBooks = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBooks =  ABAddressBookCreateWithOptions(NULL, NULL);
        //获取通讯录权限
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error){
            dispatch_semaphore_signal(sema);
            accessGranted=granted;
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        //dispatch_release(sema);
    }
    else
    {
        addressBooks = ABAddressBookCreate();
    }
    
    //silencesky upd
    if (addressBooks) {
        CFRelease(addressBooks);
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
