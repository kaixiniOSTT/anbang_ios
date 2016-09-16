//
//  FirstLoadDataProgressViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 15-1-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "FirstLoadDataProgressViewController.h"
#import "CHAppDelegate.h"

@interface FirstLoadDataProgressViewController (){
    UIProgressView *proView;
    UILabel * progressValueLabel;
   UILabel * loadingLabel;
    double proValue;
    
    NSTimer *timer;
}

@end

@implementation FirstLoadDataProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeProValue:) name:@"NNC_Received_UserInfoPercentage" object:nil];
    proValue=0;
    loadingLabel=[[UILabel alloc] initWithFrame:CGRectMake((KCurrWidth-200)/2, KCurrHeight/2-100, 200, 50)];
    loadingLabel.font = [UIFont systemFontOfSize:20];
    loadingLabel.textColor = [UIColor blackColor];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    [loadingLabel setText:NSLocalizedString(@"loading.startting",@"message")];
    
    progressValueLabel = [[UILabel alloc] initWithFrame:CGRectMake((KCurrWidth-200)/2, KCurrHeight/2-50, 200, 50)];
    progressValueLabel.font = [UIFont systemFontOfSize:28];
    progressValueLabel.textColor = [UIColor blackColor];
    progressValueLabel.textAlignment = NSTextAlignmentCenter;
    [progressValueLabel setText:[NSString stringWithFormat:@"%.0f%%", proValue]];
    proView = [[UIProgressView alloc] initWithFrame:CGRectMake((KCurrWidth-200)/2, KCurrHeight/2, 200, 20)];
    [proView setProgressViewStyle:UIProgressViewStyleDefault]; //设置进度条类型
    
    [self.view addSubview:proView];
    [self.view addSubview:progressValueLabel];
    [self.view addSubview:loadingLabel];
   
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changeProgress) userInfo:nil repeats:YES]; //利用计时器，每隔1秒调用一次（changeProgress）

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)changeProValue:(NSNotification *)notify{
     NSString *percentageStr = [notify object];
    int percentageInt = [percentageStr intValue];
    if (proValue<percentageInt) {
         proValue += percentageInt;
        if (proValue>100) {
            proValue = 99;
        }
    }
   
    NSLog(@"*****%d",percentageInt);
}


-(void)changeProgress
{
      // dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"***%@%f",@"数据加载中",proValue);
    proValue += 1; //改变proValue的值
       if(proValue > 100)
        
    {
        [timer invalidate];
        timer = nil;
        if (proValue>101) {
            return;
        }
      
        //加载主界面
        [[self appDelegate] ui];
        //停用计时器
        
    
        
    }else
        
    {
        [progressValueLabel setText:[NSString stringWithFormat:@"%.0f%%", proValue]];

        [proView setProgress:(proValue / 100)];//重置进度条
       
    }
       //}
        //              );
}

- (CHAppDelegate *)appDelegate
{
    return (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
}


@end
