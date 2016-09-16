//
//  CommunityViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 15-3-31.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "CommunityViewController.h"
#import "KxMenu.h"
#import "GroupCreateViewController.h"
#import "ScanViewController.h"
#import "AddFriendVCTableViewController.h"

@interface CommunityViewController ()
{
    BOOL  mRightBarButtonSelected;
}
@end

@implementation CommunityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuAutoRelease:)
                                                 name:@"AI_KxMenu_Dismiss"
                                               object:nil];
    
    self.title = @"社区";
    UILabel * myLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, KCurrWidth, 35)];
    UILabel * myLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 120, KCurrWidth, 35)];
    myLabel.textColor = [UIColor redColor];
    myLabel2.textColor = [UIColor redColor];
    myLabel.font = [UIFont systemFontOfSize:20];
    myLabel2.font = [UIFont systemFontOfSize:20];
    myLabel.text = @"努力建设中";
    myLabel2.text = @"敬请期待";
    myLabel.textAlignment = NSTextAlignmentCenter;
    myLabel2.textAlignment = NSTextAlignmentCenter;
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake((KCurrWidth-100)/2, 180, 100,  100)];
    imageView.image = [UIImage imageNamed:@"icon_commu_build"];
    
    [self.view addSubview:myLabel];
    [self.view addSubview:myLabel2];
    [self.view addSubview:imageView];
    self.view.backgroundColor = Controller_View_Color;
    // Do any additional setup after loading the view from its nib.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake(0, 0, 30, 30);
    [button setImage:[UIImage imageNamed:@"header_btn_plus"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:item];
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

/*---快捷菜单start----------------------------------------------*/
- (void)showMenu:(UIBarButtonItem *)sender
{
    
    if (!mRightBarButtonSelected) {
        
        mRightBarButtonSelected = YES;
        
        NSArray *menuItems =
        @[
          
          
          [KxMenuItem menuItem:@"发起群聊"
                         image:[UIImage imageNamed:@"check_icon"]
                        target:self
                        action:@selector(createGroup)],
          
          [KxMenuItem menuItem:@"添加好友"
                         image:[UIImage imageNamed:@"action_icon"]
                        target:self
                        action:@selector(toAddFriendVC)],
          
          [KxMenuItem menuItem:@"扫一扫"
                         image:[UIImage imageNamed:@"reload"]
                        target:self
                        action:@selector(ScanQRCode:)]
          ];
        
        KxMenuItem *first = menuItems[0];
        first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
        first.alignment = NSTextAlignmentCenter;
        
        [KxMenu showMenuInView:self.navigationController.view
                      fromRect:CGRectMake(KCurrWidth-25, self.navigationController.navigationBar.frame.size.height+20, 0, 0)
                     menuItems:menuItems];
        
    }else {
        
        [self dismissMenu];
    }
}

//发起群聊
-(void)createGroup{
    
    [self dismissMenu];
    
    GroupCreateViewController *groupCreateVC=[[GroupCreateViewController alloc]init];
    groupCreateVC.hidesBottomBarWhenPushed=YES;
    groupCreateVC.title =  NSLocalizedString(@"contacts.inviteFridend.urlToInvite",@"title");
    [self.navigationController pushViewController:groupCreateVC animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    [self dismissMenu];
}

- (void) ScanQRCode:(id)sender
{
    [self dismissMenu];
    
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:@"请真机运行！！！" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [myAlert addButtonWithTitle:NSLocalizedString(@"public.alert.ok",@"message")];
        [myAlert show];
        
    }
    
    ScanViewController *scanVC=[[ScanViewController alloc]init];
    scanVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:scanVC animated:YES];
    
}

//跳转到新增好友界面
-(void)toAddFriendVC{
    
    [self dismissMenu];
    
    AddFriendVCTableViewController* addFriendVC = [[AddFriendVCTableViewController alloc]init];
    //    UINavigationController* navigationVC = [[UINavigationController alloc]initWithRootViewController:addFriendVC];
    //    [self presentViewController:navigationVC animated:YES completion:nil];
    addFriendVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addFriendVC animated:YES];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self dismissMenu];
}

- (void)menuAutoRelease:(NSNotification *)n {
    
    mRightBarButtonSelected = NO;
}

- (void)dismissMenu {
    
    [KxMenu dismissMenu:YES complete:^{
        mRightBarButtonSelected = NO;
    }];
}

@end
