//
//  SettingViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 15-3-24.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "SettingViewController.h"
#import "GeneralSettingViewController.h"
#import "PrivacySettingViewController.h"
#import "LoginViewController.h"
#import "ChangePasswordViewController.h"
#import "UserInfo.h"
#import "Utility.h"
#import "ASIHTTPRequest.h"

@interface SettingViewController ()


@end

@implementation SettingViewController
@synthesize myTableView = _myTableView;
- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"target:self action:@selector(pop)]];
    
    // Do any additional setup after loading the view from its nib.
    _myTableView= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight) style:UITableViewStyleGrouped];
    // _myTableView.scrollEnabled = YES;
    // 设置tableView的数据源
    _myTableView.dataSource = self;
    // 设置tableView的委托
    _myTableView.delegate = self;
    // 设置tableView的背景图
    // tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
    // self.myTableView = tableView;
    _myTableView.separatorColor = AB_Color_f4f0eb;
    [self.view bringSubviewToFront:_myTableView];
    [self.view addSubview:_myTableView];
    
    UILabel *versionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 260, KCurrWidth,30)];
    versionLabel.text = @"邦邦社区 V1.0";
    versionLabel.font = [UIFont systemFontOfSize:12];
    versionLabel.textColor = [UIColor grayColor];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    //[_myTableView addSubview:versionLabel];
    
    self.myTableView.backgroundColor = Controller_View_Color;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //这个方法用来告诉表格有几个分组
    return 2;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //这个方法告诉表格第section个分组有多少行
    int row=0;
    if(section==0)
        row=1;//临时隐藏隐私设置，以后确认了再打开
    else
        row=1;
    
    return row;
}

#pragma make -UITableView datasoure
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    //这个方法用来告诉某个分组的某一行是什么数据，返回一个UITableViewCell
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    static NSString *GroupedTableIdentifier = @"TableSampleIdentifier";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:GroupedTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GroupedTableIdentifier];
        cell.textLabel.textColor = AB_Color_403b36;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
    }
    
    if(section==0&&row==0){
        //通用设置
        cell.textLabel.text = @"通用设置";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];

    }else if(section==0&&row==1){
        //隐私设置
        cell.textLabel.text = @"隐私设置";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];

        
    }else if(section==1&&row==0){
        //退出登录
        cell.textLabel.text = @"退出登录";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSUInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    if (section==0 && row==0) {
        //通用设置
        GeneralSettingViewController *generalSettingVC=[[GeneralSettingViewController alloc]init];
        generalSettingVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:generalSettingVC animated:YES];
        
    }else if(section==0 && row==1){
        //隐私设置
//        PrivacySettingViewController *privacySettingVC=[[PrivacySettingViewController alloc]init];
//        privacySettingVC.hidesBottomBarWhenPushed=YES;
//        [self.navigationController pushViewController:privacySettingVC animated:YES];
        [Utility showAlert:@"提示" message:@"开发中..." btn:@"确定" btn2:@"取消"];
    }else if(section==1 && row==0){
        //退出登录
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"accountManagement.exit",@"message") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"public.alert.cancel",@"action"),NSLocalizedString(@"public.alert.ok",@"action"),nil];
            alert.tag=1007;
            [alert show];
            
//        }
    }
    
}

//
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 0.000001;
//}


#pragma mark -UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
   if (alertView.tag==1007&&buttonIndex==1){  //退出登录
       
       [[NSNotificationCenter defaultCenter] postNotificationName:@"NNC_Received_Logout" object:nil userInfo:nil];
        
        LoginViewController *loginView=[[LoginViewController alloc]init];

        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:loginView];
        
        [self presentViewController:nav animated:NO completion:nil];
    }else if (alertView.tag==1008&&buttonIndex==1){     //修改密码
        ChangePasswordViewController *changPaw=[[ChangePasswordViewController alloc]init];
        [self.navigationController pushViewController:changPaw animated:YES];
    }
}


@end
