//
//  UserCenterViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 14-3-25.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "UserCenterViewController.h"
#import "XMPPHelper.h"
#import "GBPathImageView.h"
#import "JSONKit.h"
#import "JSBadgeView.h"
#import "UIImageView+WebCache.h"
#import "InformationViewController.h"
//#import "ManagementViewController.h"
#import "MessageRemindViewController.h"
#import "HelpViewController.h"
#import "AboutViewController.h"
#import "LoginViewController.h"
#import "SettingViewController.h"
#import "UserInfoCRUD.h"
#import "ContactsCRUD.h"
#import "PublicCURD.h"
#import "Utility.h"
#import "UserInfo.h"
#import "AIMyCollectionViewController.h"
#import "AIUIWebViewController.h"
#import "ContactImage.h"
//#import "AIWKWebViewController.h"

//#import "FMDBViewController.h"

#define isSimulator (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)



@interface UserCenterViewController ()
{
    GBPathImageView *squareImage;
    NSString *imageUrl;
    NSString *loadData;
    UILabel *label1;
    NSArray *mMenuArray;
    UIImageView *photoView;
}
@property (nonatomic, strong) NSMutableArray *colors;
@end

@implementation UserCenterViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}



@synthesize myPhoto = _myPhoto;
@synthesize tempMyPhoto = _tempMyPhoto;
@synthesize myTableView = _myTableView;
@synthesize activityIndicator = _activityIndicator;

NSString *TMP_UPLOAD_IMG_PATH_Str=@"";



- (void)didReceiveMemoryWarning
{
    NSLog(@"内存警告－设置");
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];//即使没有显示在window上，也不会自动的将self.view释放。
    // Add code to clean up any of your own resources that are no longer necessary.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_PersonalInfomation_Loaded" object:nil];
    
    // 此处做兼容处理需要加上ios6.0的宏开关，保证是在6.0下使用的,6.0以前屏蔽以下代码，否则会在下面使用self.view时自动加载viewDidUnLoad
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        
        //需要注意的是self.isViewLoaded是必不可少的，其他方式访问视图会导致它加载 ，在WWDC视频也忽视这一点。
        
        if (self.isViewLoaded && !self.view.window)// 是否是正在使用的视图
        {
            // Add code to preserve data stored in the views that might be
            // needed later.
            
            // Add code to clean up other strong references to the view in
            // the view hierarchy.
            self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
        }
        
    }
    
}


-(void)laodTabelView{
    [_myTableView reloadData];
}


//请求获取个人信息列表
-(void)sendIQInformationList{
    /*
     <iq type=”get”>
     <query xmlns=”http://www.icircall.com/xmpp/userinfo“ >
     <user jid=””/> </query>
     </iq>
     */
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *userJid=[NSXMLElement elementWithName:@"user"];
    [userJid addAttributeWithName:@"jid" stringValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"jid"]];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"personalInformation"];
    [queryElement addChild:userJid];
    [iq addChild:queryElement];
    [[XMPPServer xmppStream] sendElement:iq];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(laodTabelView) name:@"NNC_PersonalInfomation_Loaded" object:nil];
    
    
    label1 = [[UILabel alloc]init];
    _myTableView= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight) style:UITableViewStyleGrouped];
    // _myTableView.scrollEnabled = YES;
    // 设置tableView的数据源
    _myTableView.dataSource = self;
    // 设置tableView的委托
    _myTableView.delegate = self;
    _myTableView.backgroundColor = [UIColor clearColor];
    _myTableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    _myTableView.separatorColor = UserCenter_Table_Separator_Color;
    // self.myTableView = tableView;
    [self.view bringSubviewToFront:_myTableView];
    [self.view addSubview:_myTableView];
    self.view.backgroundColor = Controller_View_Color;
    //_myTableView.hidden = YES;
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    
    [self.navigationItem setTitle:NSLocalizedString(@"settings.settings",@"title")];
    //加载旋转的风火轮
    self.activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleGray];
    self.activityIndicator.frame = CGRectMake(0, 0, 50, 50);
    self.activityIndicator.center =self.view.center;
    self.activityIndicator.hidden =YES;
    NSDictionary *myAccount = @{@"name":@"邦邦账户",@"avatar":@"my_icon_bbAccount"};
    NSDictionary *myCollection = @{@"name":@"我的收藏",@"avatar":@"my_icon_myCollection"};
    if([UserInfo loadArchive].accountType == 2){
        NSDictionary *abAccount = @{@"name":@"安邦账户",@"avatar":@"my_icon_abAccount"};
        mMenuArray = @[abAccount,myAccount,myCollection];
    } else {
        mMenuArray = @[myAccount,myCollection];
    }
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    if (self.navigationController.viewControllers.count == 1){
//        return NO;
//    } else {
//        return YES;
//    }
//}

//- (void)viewWillDisappear:(BOOL)animated {
//    
//}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self sendIQInformationList];
}

- (void)endLoading{
    //停止动画
    [_activityIndicator stopAnimating];
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_PersonalInfomation_Loaded" object:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    return NO;
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //这个方法用来告诉表格有几个分组
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //这个方法告诉表格第section个分组有多少行
    int row=0;
    if(section==0)
        row=1;
    else if(section==1)
        row = mMenuArray.count;
    else if(section==2)
        row=1;
    else if(section==3){
        row=1;
    }else{
        row=1;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    //这个方法用来告诉某个分组的某一行是什么数据，返回一个UITableViewCell
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    static NSString *GroupedTableIdentifier = @"TableSampleIdentifier";
//    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:GroupedTableIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GroupedTableIdentifier];
//    }
    
    //这种为不复用
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GroupedTableIdentifier];
    if (cell == nil) {
        cell = cell;
    }else{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GroupedTableIdentifier];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];
        cell.textLabel.textColor = AB_Color_5b5752;
    }
    
    if(section==0&&row==0){
        //个人资料
        photoView=[[UIImageView alloc]initWithFrame:CGRectMake(15, 20, 50, 50)];
        photoView.layer.cornerRadius = 2.0;
        photoView.layer.masksToBounds = YES;
        
        if ([[NSUserDefaults standardUserDefaults]stringForKey:@"headImage"].length>0 ){
            NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL,[[NSUserDefaults standardUserDefaults]stringForKey:@"headImage"]];
            [photoView setImageWithURL:[NSURL URLWithString:avatarURL]
                      placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
            if (photoView.image) {
            }else{
                UIImage *userImage =[UIImage imageNamed:@"defaultUser.png"];
                photoView.image=userImage;
            }
        }else{
            UIImage *userImage=[UIImage imageNamed:@"defaultUser.png"];
            photoView.image=userImage;
            
        }
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClicked:)];
        photoView.userInteractionEnabled = YES;
        [photoView addGestureRecognizer:tapGesture];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = AB_FONT_15;
        nameLabel.textColor = AB_Color_5b5752;
        UILabel *accountLabel = [[UILabel alloc] init];
        CGFloat rectX = kIsiPhone6p ? 87 : 80;
        nameLabel.frame = CGRectMake(rectX, 27,200, 15);
        accountLabel.frame = CGRectMake(rectX, 51, 200, 12);
        accountLabel.font = AB_FONT_12;
        nameLabel.textColor = AB_Color_5b5752;
        accountLabel.textColor = AB_Color_9c958a;
        nameLabel.backgroundColor = [UIColor clearColor];
        accountLabel.backgroundColor = [UIColor clearColor];
        
        NSString *myName = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
        if ([StrUtility isBlankString:myName]) {
            myName = MY_USER_NAME;
        }
        nameLabel.text = myName;
        
        UserInfo *aUserInfo = [UserInfo loadArchive];
//        accountLabel.text = [NSString stringWithFormat:@"%@%@",@"社区ID:",MY_USER_NAME];
        
        if (!aUserInfo.accountName || aUserInfo.accountName.length <=0 ) {
            accountLabel.text = @"未设定";
        }else {
            accountLabel.text = [NSString stringWithFormat:@"%@%@",@"社区ID:", aUserInfo.accountName];
        }
        
        //二维码图片
        UIImage *imgCode = [UIImage imageNamed:@"icon_qrcode"];
        UIImageView *abTCode = [[UIImageView alloc] init ];
        abTCode.frame = CGRectMake(0, 0, imgCode.size.width, imgCode.size.height);
        abTCode.center = CGPointMake(Screen_Width - 45, 45);
        abTCode.image = imgCode;
        [cell.contentView addSubview:abTCode];
        
        if (aUserInfo.accountType == 2) {
            //ab图标
            UIImageView *abIcon = [[UIImageView alloc] init];
            CGFloat center_x = CGRectGetMidX(abTCode.frame) - 16 - 12;
            CGFloat center_y = 45;
            abIcon.frame = CGRectMake(0, 0, 16, 11);
            abIcon.center = CGPointMake(center_x, center_y);
            abIcon.image = [UIImage imageNamed:@"icon_ab01"];
            [cell.contentView addSubview:abIcon];
            
        }
        
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview: accountLabel];
        [cell.contentView addSubview:photoView];
    }else if(section==1){
        //邦邦账户,我的收藏
        cell.textLabel.text = mMenuArray[indexPath.row][@"name"];
        cell.imageView.image = [UIImage imageNamed:mMenuArray[indexPath.row][@"avatar"]];
    }else if(section ==2 &&row==0){
        //设置
        cell.textLabel.text = @"设置";
        cell.imageView.image = [UIImage imageNamed:@"my_icon_settings"];
    }else if(section==3&&row==0){
        //关于邦邦社区
        cell.textLabel.text = @"关于邦邦社区";
        cell.imageView.image = [UIImage imageNamed:@"my_icon_about"];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSUInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    if (section==0 && row==0) {
        //跳转个人信息页
        InformationViewController *information=[[InformationViewController alloc]init];
        //        [self.navigationController pushViewController:information animated:YES];
        information.delegate=self;
        information.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:information animated:YES];
        
    }else if(section==1){
        if(mMenuArray.count == 3 && indexPath.row == 0){
            AIUIWebViewController *controller = [[AIUIWebViewController alloc] init];
            controller.usingToken = YES;
            controller.usingCache = NO;
            controller.url = [[NSUserDefaults standardUserDefaults]stringForKey:@"NSUD_ACCOUNT_ADDRESS"];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
            return;
        }
        
        //最后一个则是收藏
        if(indexPath.row == mMenuArray.count - 1){
            AIMyCollectionViewController *controller = [[AIMyCollectionViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
            return;
        }
        
//        if(IS_iOS8){
//            AIWKWebViewController *wkController = [[AIWKWebViewController alloc] init];
//            wkController.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:wkController animated:YES];
//        } else {
            AIUIWebViewController *controller = [[AIUIWebViewController alloc] init];
            controller.usingToken = YES;
            controller.usingCache = NO;
            controller.url = [[NSUserDefaults standardUserDefaults]stringForKey:@"NSUD_MYACCOUNT_ADDRESS"];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
//        }

        
    }else if (section==2 && row==0){
        //设置
        SettingViewController *settingVC=[[SettingViewController alloc]init];
        settingVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:settingVC animated:YES];
        
    }else if(section==3 && row==0){
        AboutViewController *aboutView=[[AboutViewController alloc]init];
        aboutView.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:aboutView animated:YES];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000001;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *nilView=[[UIView alloc]initWithFrame:CGRectZero];
    return nilView;
}


#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1080&&buttonIndex==0) {
        [PublicCURD deleteAllMsg];
    }
}

- (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    
    if ([ indexPath indexAtPosition: 1 ] == 0 && section ==0)
        return 90.0;
    else
        return 44.0;
}

-(void)backButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark -InformationViewDelegate
-(void)setImage:(UIImage *)image{
    squareImage=[[GBPathImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 75.0, 75.0) image:image pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor whiteColor] pathWidth:0.0];
}

- (IBAction)imageClicked:(id)sender
{
    ContactImage *bigImge = [[ContactImage alloc] initWithNibName:@"ContactImage" bundle:nil];
    bigImge.image = photoView.image;
    bigImge.originFrame = photoView.frame;
    
    bigImge.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:bigImge animated:NO];
}

@end
