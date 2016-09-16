//
//  VoipViewController.m
//  Icircall_ios
//
//  Created by fighting on 14-4-6.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "VoipViewController.h"
#import "XMPPServer.h"
#import "APPRTCViewController.h"
#import "CHAppDelegate.h"
#import "VoipUtils.h"

@interface VoipViewController ()

@end

@implementation VoipViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)init
{
    self = [super init];
    if(self != nil)
    {
        
        XMPPServer* server = [XMPPServer sharedServer];
        _voipModule = [VoipModule shareVoipModule];
        _voipModule.voipDelegate = self;
        [_voipModule activate:server.xmppStream];
       
    }
    return self;
}

-(void)loadView
{
    UIView *view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].applicationFrame] ;
    
    UITextField *field = [[UITextField alloc]initWithFrame:CGRectMake(80, 150, 160, 40)];
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.tag = 100;
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(80, 220, 160, 40);
    [button setTitle:@"CALL" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor greenColor];
    [button addTarget:self action:@selector(callTo:) forControlEvents:UIControlEventTouchDown];
        
                         
   
    
    
                    self.view = view;
    
    [self.view addSubview:field];
    [self.view addSubview:button];
    
   
                    

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)callTo:(id)sender
{
       NSLog(@"ff:%@",_voipModule.xmppStream);
}


-(void)viewDidLayoutSubviews
{
    NSLog(@"--------------------------");
}
-(void)dealloc
{
    
    [super dealloc];
}
#pragma mark -- VoipDelegate

-(void) voipJson:(NSString *) from json:(NSString*) msg
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self)
        {
            @autoreleasepool {
                NSLog(@"fighting:%@",msg);
                NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding ];
                NSError * error = nil;
                NSDictionary * jsonStr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error ];
                if (error ) {
                    return;
                }
                
                if ([[jsonStr objectForKey:@"type"] isEqualToString:@"call"]) {
                    
//                    UILocalNotification *notification=[[UILocalNotification alloc] init];
//                    if (notification!=nil) {
//                        
//                        NSDate *now=[NSDate new];
//                        notification.fireDate=[now dateByAddingTimeInterval:10]; //触发通知的时间
//                        notification.repeatInterval=0; //循环次数，kCFCalendarUnitWeekday一周一次
//                        
//                        notification.timeZone=[NSTimeZone defaultTimeZone];
//                        notification.soundName = UILocalNotificationDefaultSoundName;
//                        notification.alertBody=@"该去吃晚饭了！";
//                        
//                        notification.alertAction = @"打开";  //提示框按钮
//                        notification.hasAction = YES; //是否显示额外的按钮，为no时alertAction消失
//                        
//                        notification.applicationIconBadgeNumber = 1; //设置app图标右上角的数字
//                        
//                        //下面设置本地通知发送的消息，这个消息可以接受
//                        NSDictionary* infoDic = [NSDictionary dictionaryWithObject:@"value" forKey:@"key"];
//                        notification.userInfo = infoDic;
//                        //发送通知
//                        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//                    }
//                    
//                    //发送通知
//                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                   
                    APPRTCViewController *appView = [[APPRTCViewController alloc]init];
                   
                    
                    appView.from = from;
                    [self presentViewController:appView animated:YES completion:^{
                        NSArray *firstSplit = [from componentsSeparatedByString:@"@"];
                        [appView.lbname setText:[firstSplit objectAtIndex:0]];
                        UIImage *image = [UIImage imageNamed:@"Icon"];
                        [appView.ivavatar setImage:image];
                    }];
                    CHAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                    appDelegate.tabBarBG.hidden = YES;
////
//                      [[[VoipUtils alloc]init]inComingRing];
                    
                }
                else
                {
                    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
                    [notifyCenter postNotificationName:@"voip" object:msg];
                    
                }

            }
            
        }

        
    });
    
    
}
@end
