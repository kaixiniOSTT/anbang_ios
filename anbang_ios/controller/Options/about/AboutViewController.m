//
//  AboutViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//
#import "AboutViewController.h"
#import "CHAppDelegate.h"
#import "AboutUsViewController.h"
#import "UseAndPrivacyViewController.h"
#import "MyServices.h"
#import "JSONKit.h"
#import "Utility.h"
#import "SuggestionViewController.h"
#import "AIUIWebViewController.h"

@interface AboutViewController ()
{
    UITableView *table;
    NSString *trackViewUrl;
}
@end

@implementation AboutViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
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
    
    self.title=NSLocalizedString(@"aboutIcircall.title",@"title");
    [self ui];
    table.delegate=self;
    table.dataSource=self;
}
-(void)ui{
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(pop)]];
    table=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight - Both_Bar_Height) style:UITableViewStylePlain];
    table.backgroundColor = Controller_View_Color;
    table.separatorColor = UserCenter_Table_Separator_Color;
    [self.view addSubview:table];
    
    [self setExtraCellLineHidden:table];
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    return [array count];
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==0){
        return 135;
    }
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.textColor = AB_Color_403b36;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];
    }
    if(indexPath.row==0){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = nil;
        cell.contentView.backgroundColor = Controller_View_Color;
        UIImageView *aboutImageView = [[UIImageView alloc]initWithFrame:CGRectMake(KCurrWidth/2-33, 20, 60,60)];
        aboutImageView.image = [UIImage imageNamed:@"AppIcon40x40"];
        UILabel * versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, KCurrWidth, 30)];
        // NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        // app版本
        NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        // app build版本
        NSString *appBuild = [infoDictionary objectForKey:@"CFBundleVersion"];
        NSString *currentVersion = [NSString stringWithFormat:@"v%@(%@)",appVersion,appBuild];
        versionLabel.font = [UIFont systemFontOfSize:18];
        versionLabel.textColor = AB_Color_c3bdb4;
        versionLabel.textAlignment = NSTextAlignmentCenter;
        versionLabel.text= currentVersion;
        [cell.contentView addSubview:aboutImageView];
        [cell.contentView addSubview:versionLabel];
    }else if(indexPath.row==1){
        //关于我们
        cell.textLabel.text=@"常见问题";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if(indexPath.row==2){
        //关于我们
        cell.textLabel.text=@"意见反馈";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (indexPath.row==3){
        cell.textLabel.text=NSLocalizedString(@"aboutIcircall.checkVersion",@"title");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        
    }else if (indexPath.row==1) {
        AIUIWebViewController *controller = [[AIUIWebViewController alloc] init];
        controller.url = [[NSUserDefaults standardUserDefaults]stringForKey:@"NSUD_QUESTION_ADDRESS"];
        controller.usingToken = NO;
        controller.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        controller.webViewTitle = @"常见问题";
        [self.navigationController pushViewController:controller animated:YES];
    }else if (indexPath.row==2) {
//        [Utility showAlert:@"提示" message:@"开发中..." btn:@"确定" btn2:@"取消"];
        SuggestionViewController *suggest = [[SuggestionViewController alloc] init];
        [self.navigationController pushViewController:suggest animated:YES];
    }else if(indexPath.row==3){
        //检测新版本   版本号比价
        // NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        //        NSString *appVersion = [infoDic objectForKey:@"CFBundleVersion"];
        //        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示" message:@"当前为最新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        //        [alert show];
        //        [alert release];
        
        //检测版本
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"" forKey:@"NSUD_CheckUpdate_Method"];
        [MyServices onCheckVersion];
        
    }else if (indexPath.row==3){

    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}


-(void)dealloc{
}
@end
