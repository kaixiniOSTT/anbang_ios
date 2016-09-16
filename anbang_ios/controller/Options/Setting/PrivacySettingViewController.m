//
//  PrivacySettingViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 15-3-25.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "PrivacySettingViewController.h"

@interface PrivacySettingViewController (){
    UISwitch *addressSwitch;
    UISwitch *phoneSwitch;
    UISwitch *emailSwitch;
}

@end

@implementation PrivacySettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"隐私设置";
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        //self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }

    // Do any additional setup after loading the view from its nib.
    privacySettingTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-Both_Bar_Height) style:UITableViewStyleGrouped];
    privacySettingTableView.backgroundColor = Controller_View_Color;
    privacySettingTableView.delegate=self;
    privacySettingTableView.dataSource=self;
    //[informationTableView setAutoresizesSubviews:YES];
    [self.view bringSubviewToFront:privacySettingTableView];
    [self.view addSubview:privacySettingTableView];
    
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


#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //这个方法用来告诉表格有几个分组
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //这个方法告诉表格第section个分组有多少行
    int row=0;
    if(section==0)
        row=3;
    else
        row = 1;
    return row;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    static NSString *identifier = @"TableSampleIdentifier";
    
    static NSString *GroupedTableIdentifier = @"TableSampleIdentifier";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:GroupedTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    if (section==0 && row==0) {
        cell.textLabel.text=@"对好友显示地区";
        addressSwitch=[[UISwitch alloc]initWithFrame:CGRectMake(KCurrWidth-70, 6, 50, 20)];
        [addressSwitch addTarget:self action:@selector(addressSwitch) forControlEvents:UIControlEventValueChanged];
        [addressSwitch setOn:YES];
        
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Setting_AddressSwitch"] isEqualToString:@"on"]) {
            [addressSwitch setOn:YES];
        }else if([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Setting_AddressSwitch"] isEqualToString:@"close"]){
            [addressSwitch setOn:NO];
        }
        [cell addSubview:addressSwitch];
        
    }
    else if (section ==0 && row==1) {
        cell.textLabel.text=@"对好友显示手机号";
        phoneSwitch=[[UISwitch alloc]initWithFrame:CGRectMake(KCurrWidth-70, 6, 50, 20)];
        [phoneSwitch addTarget:self action:@selector(phoneSwitch) forControlEvents:UIControlEventValueChanged];
        [phoneSwitch setOn:YES];
        
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Setting_PhoneSwitch"] isEqualToString:@"on"]) {
            [phoneSwitch setOn:YES];
        }else if([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Setting_PhoneSwitch"] isEqualToString:@"close"]){
            [phoneSwitch setOn:NO];
        }
        [cell addSubview:phoneSwitch];
  
    }else if(section==0 && row==2) {
        cell.textLabel.text=@"对好友显示邮箱";
        emailSwitch=[[UISwitch alloc]initWithFrame:CGRectMake(KCurrWidth-70, 6, 50, 20)];
        [emailSwitch addTarget:self action:@selector(emailSwitch) forControlEvents:UIControlEventValueChanged];
        [emailSwitch setOn:YES];
        
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Setting_EmailSwitch"] isEqualToString:@"on"]) {
            [emailSwitch setOn:YES];
        }else if([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Setting_EmailSwitch"] isEqualToString:@"close"]){
            [emailSwitch setOn:NO];
        }

        [cell addSubview:emailSwitch];
    }
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor=[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1];
    return  cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (section==0 && row==0) {
    }else if (section==0 && row==1){
    }else if (section==0 && row==2){
    }
}


-(BOOL)addressSwitch{
    if (addressSwitch.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"on" forKey:@"NSUD_Setting_AddressSwitch"];
        return YES;
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"close" forKey:@"NSUD_Setting_AddressSwitch"];
        return NO;
    }
}

-(BOOL)phoneSwitch{
    if (phoneSwitch.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"on" forKey:@"NSUD_Setting_PhoneSwitch"];
        return YES;
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"close" forKey:@"NSUD_Setting_PhoneSwitch"];
        
        return NO;
    }
}

-(BOOL)emailSwitch{
    if (emailSwitch.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"on" forKey:@"NSUD_Setting_EmailSwitch"];
        return YES;
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"close" forKey:@"NSUD_Setting_EmailSwitch"];
        
        return NO;
    }
}

@end
