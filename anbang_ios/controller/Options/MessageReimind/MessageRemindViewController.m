//
//  MessageRemindViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//
#define btnHeight 40
#import "MessageRemindViewController.h"
#import "CHAppdelegate.h"
@interface MessageRemindViewController ()
{
    UISwitch *stSound;
    UISwitch *stVibration;
}
@property(nonatomic,copy)NSArray *ar;
@end

@implementation MessageRemindViewController
@synthesize ar;
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
    
    self.title=NSLocalizedString(@"messageRemind.title",@"title");
    
    ar=[[NSArray alloc]initWithObjects:NSLocalizedString(@"messageRemind.voice",@"action")
        ,NSLocalizedString(@"messageRemind.vibration",@"action"), nil];
    
    [self ui];
}

-(void)viewWillAppear:(BOOL)animated{
    
}

-(void)viewWillDisappear:(BOOL)animated{
}

-(void)ui{
    UITableView *tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight) style:UITableViewStyleGrouped];
    tableView.scrollEnabled=NO;
    [self.view addSubview:tableView];
    tableView.delegate=self;
    tableView.dataSource=self;
}


-(BOOL)switchSound{
    if (stSound.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"play" forKey:@"NSUD_Sound_Play_Mark"];
        return YES;
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"stop" forKey:@"NSUD_Sound_Play_Mark"];
        return NO;
    }
}

-(BOOL)switchVibration{
    if (stVibration.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"play" forKey:@"NSUD_Vibrate_Play_Mark"];
        return YES;
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"stop" forKey:@"NSUD_Vibrate_Play_Mark"];
        
        return NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -UITableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ar count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if ([indexPath section]==0) {
        cell.textLabel.text=[ar objectAtIndex:[indexPath row]];
        if ([indexPath row]==0) {           //  声音
            stSound=[[UISwitch alloc]initWithFrame:CGRectMake(KCurrWidth-70, 6, 50, 20)];
            [stSound setOn:YES];
            
            [stSound addTarget:self action:@selector(switchSound) forControlEvents:UIControlEventValueChanged];
            if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Sound_Play_Mark"] isEqualToString:@"play"]) {
                [stSound setOn:YES];
            }else if([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Sound_Play_Mark"] isEqualToString:@"stop"]){
                [stSound setOn:NO];
            }
            
            [cell addSubview:stSound];
        }else if ([indexPath row]==1){      //震动
            stVibration=[[UISwitch alloc]initWithFrame:CGRectMake(KCurrWidth-70, 6, 50, 20)];
            [stVibration addTarget:self action:@selector(switchVibration) forControlEvents:UIControlEventValueChanged];
            [stVibration setOn:YES];
            [stSound addTarget:self action:@selector(switchSound) forControlEvents:UIControlEventValueChanged];
            if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Vibrate_Play_Mark"] isEqualToString:@"play"]) {
                [stVibration setOn:YES];
            }else if([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Vibrate_Play_Mark"] isEqualToString:@"stop"]){
                [stVibration setOn:NO];
            }
            
            [cell addSubview:stVibration];
        }
    }
    return cell;
}

#pragma make -UITableView datasoure
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section==0) {
//        return 20;
//    }else{
//        return 5;
//    }
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 5;
//}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//
//}

-(void)dealloc{
    
}
@end
