//
//  ContactsDetailsViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 14-5-10.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "GroupMembersDetailsViewController.h"
#import "CHAppDelegate.h"
#import "GBPathImageView.h"
#import "UIImageView+WebCache.h"
#import "BlackListCRUD.h"
#import "ContactsCRUD.h"
#import "ChatViewController2.h"
#import "APPRTCViewController.h"
#import "ContactsRemarkNameTableViewController.h"
#import "IdGenerator.h"
#import "GroupMembersCRUD.h"
#import "ContactsCRUD.h"
#import "GroupUpdMemberNameTableViewController.h"
#import "PublicCURD.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface GroupMembersDetailsViewController ()

@end

@implementation GroupMembersDetailsViewController
@synthesize tableView = _tableView;
@synthesize contactsUserName = _contactsUserName;
@synthesize contactsNickName = _contactsNickName;
@synthesize contactsAvatarURL = _contactsAvatarURL;
@synthesize contactsJID = _contactsJID;
@synthesize blackListStatus = _blackListStatus;
@synthesize groupJID = _groupJID;
@synthesize groupMucJID = _groupMucJID;
@synthesize groupCreator = _groupCreator;

@synthesize fileName = _fileName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


//NNC_Blacklist

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置通知中心，更新黑名单；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBlackListStatus)
												 name:@"NNC_Blacklist" object:nil];
    
    //修改群组名称后跳转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteLocalGroupMember) name:@"CNN_Group_Delete_GroupMember" object:nil];

    
    _tableView= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-Both_Bar_Height) style:UITableViewStyleGrouped];
    // _myTableView.scrollEnabled = YES;
    // 设置tableView的数据源
    _tableView.dataSource = self;
    // 设置tableView的委托
    _tableView.delegate = self;
    // 设置tableView的背景图
    // tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
    // self.myTableView = tableView;
    
    [self.view addSubview:_tableView];
    //_myTableView.hidden = YES;
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        //self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    
    [self.navigationItem setTitle: NSLocalizedString(@"circleMemberInfo.title",@"title")];
    //返回
    //    UIBarButtonItem *backItem =  [[UIBarButtonItem alloc] initWithTitle:@"返回"   style:UIBarButtonItemStylePlain       target:self action:@selector(backButton)];
    //    [self.navigationItem setLeftBarButtonItem:backItem];
    
    
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
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //这个方法告诉表格第section个分组有多少行
    int row=0;
    if(section==0)
        row=1;
    else if(section==1){
        //没有圈子昵称时就不显示
        if ([StrUtility isBlankString:_circleNickName]) {
            row = 1;
        }else{
            row=2;
        }
      
     
    } else if(section==2){
        row=2;
    }else if(section==3){
        if ([_groupCreator isEqualToString:MY_JID]) {
            row=2;
        }else{
            row=1;
        }
        
    }else if(section==4){
        if([ContactsCRUD queryContactsCountId:_contactsJID myJID:MY_JID]==0){
            row=1;
        }else{
            row=0;
        }
        
    }
    return row;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"";
    }
    return @"";
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    
    if(section == 2){
        
        return @"";
    }else
        return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    //这个方法用来告诉某个分组的某一行是什么数据，返回一个UITableViewCell
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    static NSString *GroupedTableIdentifier = @"TableSampleIdentifier";
    // UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GroupedTableIdentifier] autorelease];
    
    //这种为不复用
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GroupedTableIdentifier];
    if (cell == nil) {
        cell = cell;
    }else{
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GroupedTableIdentifier];
    }
    
    if(section==0&&row==0){
        cell.textLabel.text = @"";
        cell.textLabel.frame = CGRectMake(0, 0, 60, 80);
        // cell.imageView.image = [UIImage imageNamed:@"setting_icon_account"];
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(100, 0,200, 80);
        label.text  = @"";
        label.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:label];
        
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%@",@"创建时间", [_groupDic objectForKey:@"createDate"]];
        // cell.detailTextLabel.frame=CGRectMake(0, 10, 60, 20);
        UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 50.0, 50.0)];
        [photoView setImageWithURL:[NSURL URLWithString:_contactsAvatarURL]
                  placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
        if (_contactsAvatarURL.length>0 ){
            
            CGSize itemSize = CGSizeMake(45, 45);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [photoView.image drawInRect:imageRect];
            cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            
            cell.textLabel.text = _contactsNickName;
            
        }else{
            UIImage *userImage =[UIImage imageNamed:@"defaultUser.png"];
            CGSize itemSize = CGSizeMake(45, 45);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [userImage drawInRect:imageRect];
            cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            //cell.textLabel.textColor=kMainColor;
            cell.textLabel.text = _contactsNickName;
            // [userImage release];
            
        }
        
        UIImage *sendBtnBackground = [UIImage imageNamed:@"user_call"];
        UIButton* callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        callBtn.frame = CGRectMake(KCurrWidth - 80, 15, 45, 45);
        [callBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
        [callBtn addTarget:self action:@selector(playDial) forControlEvents:UIControlEventTouchUpInside];
        [callBtn setImage:sendBtnBackground forState:UIControlStateNormal];
        [callBtn setTintColor:[UIColor grayColor]];
        callBtn.backgroundColor = [UIColor clearColor];
        [callBtn.layer setCornerRadius:5.0];

        [cell addSubview:callBtn];
        // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if(section==1 && row==0){
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(KCurrWidth-185, 0,150, 40);
        label.textColor = [UIColor grayColor];
        label.text = _contactsUserName;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentRight;
        cell.textLabel.textColor=kMainColor;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text =[NSString stringWithFormat:@"%@", NSLocalizedString(@"public.text.number",@"title")];
        [cell addSubview:label];
        // cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", @"邦邦社区",_contactsUserName];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if(section==1&&row==1){
        //圈子昵称
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(KCurrWidth-185, 0,150, 40);
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = _circleNickName;
        label.textAlignment = NSTextAlignmentRight;
        // cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", @"昵称",_contactsNickName];
        //昵称
        cell.textLabel.textAlignment=NSTextAlignmentCenter;
        cell.textLabel.textColor=kMainColor;
        cell.textLabel.text = NSLocalizedString(@"circleMemberInfo.nickName",@"title");
        [cell addSubview:label];
        //cell.imageView.image = [UIImage imageNamed:@"setting_icon_account"];
        if ([_groupCreator isEqualToString:MY_JID]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }else if(section ==2 &&row==0){
        //发送消息
        cell.textLabel.text = NSLocalizedString(@"ContactsDetails.sendMessage",@"action");
        cell.textLabel.textColor = kMainColor;
        //cell.imageView.image = [UIImage imageNamed:@"setting_icon_clean"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if(section==2&&row==1){
        //语音通话
        cell.textLabel.text = NSLocalizedString(@"circleMemberInfo.voiceCall",@"action");
        cell.textLabel.textColor = kMainColor;
        // cell.imageView.image = [UIImage imageNamed:@"setting_icon_info"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if(section==3){
        if (row ==0) {
            cell.textLabel.text =[NSString stringWithFormat:  @"%@",_blackListStatus];
            cell.textLabel.textColor = kMainColor;
            //cell.imageView.image = [UIImage imageNamed:@"setting_icon_account"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }else{
            //删除圈子成员
            cell.textLabel.text = NSLocalizedString(@"circleMemberInfo.removeCircleMembers",@"action");
            cell.textLabel.textColor = kMainColor;
            // cell.imageView.image = [UIImage imageNamed:@"setting_icon_info"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        
    }else if(section==4&&row==0){
        
        if([ContactsCRUD queryContactsCountId:_contactsJID myJID:MY_JID]==0){
            //加入联系人
            cell.textLabel.text = NSLocalizedString(@"circleMemberInfo.addContact",@"action");
            cell.textLabel.textColor = kMainColor;
            // cell.imageView.image = [UIImage imageNamed:@"setting_icon_info"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }else{
            //暂时不处理
            
        }
        
    }
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    NSLog(@"%d,%d",section,row);
    if (section==0 && row==0) {
        
        
    }else if(section==1&&row==1){
        //修改圈子名片(只有创建者有修改权限)
        if ([_groupCreator isEqualToString:MY_JID]) {
        GroupUpdMemberNameTableViewController *groupUpdMemberNameVC = [[GroupUpdMemberNameTableViewController alloc]init];
        groupUpdMemberNameVC.groupJID = _groupJID;
        groupUpdMemberNameVC.groupMemberJID = _contactsJID;
        groupUpdMemberNameVC.groupMemberName = _circleNickName;
        [self.navigationController pushViewController:groupUpdMemberNameVC animated:YES];
        return;
        }
        
        
    }else if(section==2&&row==0){
        //发送消息
        [self sendMsg];
        
    }else if(section==2&&row==1){
        //发送语音
        [self playDial];
        
    }else if(section==3&&row==0){
        //加入黑名单
        if([_blackListStatus isEqualToString: NSLocalizedString(@"circleMemberInfo.addBlacklist",@"title")]){
            //加入黑名单
            [self addBlacklistActionSheet];
            
        }else{
            //解绑黑名单
            [self unbundlingBlacklistActionSheet];
            
        }
    }else if(section==3&&row==1){
        [self deleteGroupMemberActionSheet];
        
    }else if(section==4&&row==0){
        [self addContactsActionSheet];
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10;
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
        return 80.0;
    else
        return 40.0;
}

//发送消息
-(void)sendMsg{
    ChatViewController2 * chatViewCtl=[[ChatViewController2 alloc] initWithNibName:@"ChatViewController2" bundle:nil];
    chatViewCtl.chatWithUser = _contactsUserName;
    chatViewCtl.chatWithNick = _contactsNickName;
    chatViewCtl.chatWithJID  = _contactsJID;
    chatViewCtl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    chatViewCtl.title = _contactsNickName;
    [self.navigationController pushViewController :chatViewCtl animated:YES];
}



//确定加入黑名单提示
- (void)addBlacklistActionSheet
{
    if (kIOS_VERSION>=8.0) {
        UIAlertController *otherLoginAlert = nil;
        if (kIsPad) {
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleAlert];
        }else{
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        }
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"circleMemberInfo.sureAddBlacklist",@"action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                               [self addBlackList:_contactsJID];
                                                          }]];
        
        
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"public.alert.cancel",@"action")                                                               style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                              
                                                          }]];
        
        UIPopoverPresentationController *popover = otherLoginAlert.popoverPresentationController;
        if (popover){
            popover.sourceView = self.view;
            popover.sourceRect = self.view.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        
        [self presentViewController:otherLoginAlert animated:YES completion:nil];
        
    }else{
    UIActionSheet *menu=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"circleMemberInfo.sureAddBlacklist",@"action"),nil];
    menu.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
    menu.tag=0;
    [menu showInView:self.view.window];
    }
}

//解绑黑名单提示
- (void)unbundlingBlacklistActionSheet
{
    if (kIOS_VERSION>=8.0) {
        
        UIAlertController *otherLoginAlert = nil;
        if (kIsPad) {
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleAlert];
        }else{
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        }
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"circleMemberInfo.sureRemoveBlacklist",@"action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self unbundlingBlackList:_contactsJID];

                                                          }]];
        
        
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"public.alert.cancel",@"action")                                                               style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                              
                                                          }]];
        
        UIPopoverPresentationController *popover = otherLoginAlert.popoverPresentationController;
        if (popover){
            popover.sourceView = self.view;
            popover.sourceRect = self.view.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        
        [self presentViewController:otherLoginAlert animated:YES completion:nil];
        
    }else{

    UIActionSheet *menu=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"circleMemberInfo.sureRemoveBlacklist",@"action"),nil];
    menu.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
    menu.tag=1;
    [menu showInView:self.view.window];
    }
}

//确定加入联系人提示
- (void)addContactsActionSheet
{
    if (kIOS_VERSION>=8.0) {
        
        UIAlertController *otherLoginAlert = nil;
        if (kIsPad) {
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleAlert];
        }else{
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        }
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ContactsDetails.sureAddContact",@"action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self queryContactsUserInfo:_contactsJID];
                                                              //跳转到联系人列表
                                                              [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
                                                          }]];
        
        
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"public.alert.cancel",@"action")                                                               style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                              
                                                          }]];
        
        UIPopoverPresentationController *popover = otherLoginAlert.popoverPresentationController;
        if (popover){
            popover.sourceView = self.view;
            popover.sourceRect = self.view.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        
        [self presentViewController:otherLoginAlert animated:YES completion:nil];
        
    }else{

    UIActionSheet *menu=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ContactsDetails.sureAddContact",@"action"),nil];
    menu.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
    menu.tag=2;
    [menu showInView:self.view.window];
    }
}


//确定删除群组成员提示
- (void)deleteGroupMemberActionSheet
{
    
    if (kIOS_VERSION>=8.0) {
        
        UIAlertController *otherLoginAlert = nil;
        if (kIsPad) {
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleAlert];
        }else{
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        }
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"circleMemberInfo.sureRemoveCircleMembers",@"action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self deleteGroupMember:_contactsJID];

                                                          }]];
        
        
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"public.alert.cancel",@"action")                                                               style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                              
                                                          }]];
        
        UIPopoverPresentationController *popover = otherLoginAlert.popoverPresentationController;
        if (popover){
            popover.sourceView = self.view;
            popover.sourceRect = self.view.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        
        [self presentViewController:otherLoginAlert animated:YES completion:nil];
        
    }else{

    UIActionSheet *menu=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"circleMemberInfo.sureRemoveCircleMembers",@"action"),nil];
    menu.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
    menu.tag=3;
    [menu showInView:self.view.window];
    }
}

#pragma mark -
#pragma mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (actionSheet.tag==0) {
        //加入黑名单
        switch (buttonIndex) {
            case 0:
                //NSLog(@"click at index %d，确定操作", buttonIndex);
                [self addBlackList:_contactsJID];
                break;
            case 1:
                // NSLog(@"click at index %d，取消操作", buttonIndex);
                break;
                
            default:
                // NSLog(@"unknown： click at index %d", buttonIndex);
                break;
        }
        
    }else if(actionSheet.tag==1){
        //解绑黑名单
        switch (buttonIndex) {
            case 0:
                //NSLog(@"click at index %d，确定操作", buttonIndex);
                [self unbundlingBlackList:_contactsJID];
                break;
            case 1:
                //NSLog(@"click at index %d，取消操作", buttonIndex);
                break;
                
            default:
                //NSLog(@"unknown： click at index %d", buttonIndex);
                break;
        }
    }else if(actionSheet.tag==2){
        //加入联系人
        switch (buttonIndex) {
            case 0:
                //NSLog(@"click at index %d，确定操作", buttonIndex);
                [self queryContactsUserInfo:_contactsJID];
                //跳转到联系人列表
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
                
                break;
            case 1:
                //NSLog(@"click at index %d，取消操作", buttonIndex);
                break;
                
            default:
                // NSLog(@"unknown： click at index %d", buttonIndex);
                break;
        }
        
    }else if(actionSheet.tag==3){
        switch (buttonIndex) {
            case 0:
                // NSLog(@"click at index %d，确定操作", buttonIndex);
                [self deleteGroupMember:_contactsJID];
                break;
            case 1:
                //NSLog(@"click at index %d，取消操作", buttonIndex);
                break;
                
            default:
                // NSLog(@"unknown： click at index %d", buttonIndex);
                break;
        }
    }
}



//加入黑名单
-(void)addBlackList:(NSString *)contactsJID{
    if([_blackListStatus isEqualToString:NSLocalizedString(@"circleMemberInfo.addBlacklist",@"title")] && [BlackListCRUD queryBlacklistTableCountId:_contactsUserName myUserName:MY_USER_NAME]==0){
        [BlackListCRUD insertBlackListTable:_contactsUserName myUserName:MY_USER_NAME];
    }
    //NSString *myJID = [[NSString alloc] initWithFormat:@"%@", [XMPPServer xmppStream].myJID.bareJID];
    NSMutableArray *contactsUserNameArray = [BlackListCRUD queryMyBlackListByMyUserName:MY_USER_NAME];
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *list = [NSXMLElement elementWithName:@"list"];
    
    //id 随机生成（须确保无重复）
    //NSLog(@"*******%@",[IdGenerator next]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[IdGenerator next] forKey:@"IQ_Add_BlackList"];
    
    [iq addAttributeWithName:@"id" stringValue:[defaults stringForKey:@"IQ_Add_BlackList"]];
    
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"from" stringValue:MY_JID];
    [list addAttributeWithName:@"name" stringValue:@"BlackList"];
    
    //遍历
    [contactsUserNameArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //NSLog(@"遍历array：%zi-->%@",idx,obj);
        
        if(![[obj objectForKey:@"contactsUserName" ] isEqualToString:@""] || [obj objectForKey:@"contactsUserName" ] !=NULL){
            NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
            NSXMLElement *iq2 = [NSXMLElement elementWithName:@"iq"];
            NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
            [item addAttributeWithName:@"action" stringValue:@"deny"];
            [item addAttributeWithName:@"type" stringValue:@"jid"];
            [item addAttributeWithName:@"order" stringValue:@"1"];
            [item addAttributeWithName:@"value" stringValue:[NSString stringWithFormat:@"%@@%@",[obj objectForKey:@"contactsUserName" ], OpenFireHostName]];
            
            [item addChild:iq2];
            [item addChild:message];
            [list addChild:item];
            
        }
    }];
    
    
    [iq addChild:queryElement];
    [queryElement addChild:list];
    //NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    //指定默认黑名单列表
    [self sendDefaultBlacklistName];
    
}


//指定默认黑名单列表
-(void)sendDefaultBlacklistName{
    // NSString *myJID = [[NSString alloc] initWithFormat:@"%@", [XMPPServer xmppStream].myJID.bareJID];
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *defaultBlackListName = [NSXMLElement elementWithName:@"default"];
    [iq addAttributeWithName:@"id" stringValue:@"1011"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"from" stringValue:MY_JID];
    [defaultBlackListName addAttributeWithName:@"name" stringValue:@"BlackList"];
    [iq addChild:queryElement];
    [queryElement addChild:defaultBlackListName];
    [[XMPPServer xmppStream] sendElement:iq];
}



/*---删除群组成员 start--------------------------------------------------------------------------------------------------------*/
-(void)deleteGroupMember:(NSString *)memberJID{
    /*<iq type=”set”>
     <query xmlns=”http://www.nihualao.com/xmpp/circle/admin”>
     <circle jid=”” name=””remove=”true”>
     <members>
     <member jid=”” nickname=”” remove=”true”/>
     <member jid=”” nickname=”” role=”” phone=”如果没有开户可以使
     用通讯录中的电话号码”/> </members>
     </circle> </query>
     </iq>
     */
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/admin"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
    NSXMLElement *members = [NSXMLElement elementWithName:@"members"];
    
    [iq addAttributeWithName:@"id" stringValue:IQID_Group_Delete_GroupMember];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:@"circle.ab-insurance.com"];
    [circle addAttributeWithName:@"jid" stringValue:_groupJID];
    
    NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
    [member addAttributeWithName:@"jid" stringValue:memberJID];
    [member addAttributeWithName:@"remove" stringValue:@"true"];
    
    [members addChild:member];
    [iq addChild:queryElement];
    [queryElement addChild:circle];
    [circle addChild:members];
    
    //NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
    //XMPPJID *myJID = [XMPPServer xmppStream].myJID;
    // NSString *jid = [NSString stringWithFormat:@"%@",myJID.bareJID];
    // NSLog(@"*****%@",jid);
    
}

//等待服务器返回结果后，删除本地群组成员并跳转页面
-(void)deleteLocalGroupMember{
    // [GroupMembersCRUD deleteGroupMember:_groupJID memberJID:_contactsJID myJID:MY_JID];
    //跳转到圈子列表
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}
/*---删除群组成员 end----------------------------------------------------------------------------------------------------------*/





//黑名单解绑
-(void)unbundlingBlackList:(NSString *)contactsJID{
    if ([_blackListStatus isEqualToString:NSLocalizedString(@"circleMemberInfo.removeBlacklist",@"action")]) {
        [BlackListCRUD deleteBlackList:_contactsUserName myUserName: MY_USER_NAME];
    }else {
        return;
    }
    //NSString *myJID = [[NSString alloc] initWithFormat:@"%@", [XMPPServer xmppStream].myJID.bareJID];
    
    NSMutableArray *contactsUserNameArray = [BlackListCRUD queryMyBlackListByMyUserName:MY_USER_NAME];
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *list = [NSXMLElement elementWithName:@"list"];
    NSXMLElement *iq2 = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    
    //id 随机生成（须确保无重复）
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[IdGenerator next] forKey:@"IQ_Relieve_BlackList"];
    
    [iq addAttributeWithName:@"id" stringValue:[defaults stringForKey:@"IQ_Relieve_BlackList"]];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"from" stringValue:MY_JID];
    [list addAttributeWithName:@"name" stringValue:@"BlackList"];
    
    //遍历
    [contactsUserNameArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //NSLog(@"遍历array：%zi-->%@",idx,obj);
        
        if(![[obj objectForKey:@"contactsUserName" ] isEqualToString:@""] || [obj objectForKey:@"contactsUserName" ] !=NULL){
            NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
            [item addAttributeWithName:@"action" stringValue:@"deny"];
            [item addAttributeWithName:@"type" stringValue:@"jid"];
            [item addAttributeWithName:@"order" stringValue:@"1"];
            [item addAttributeWithName:@"value" stringValue:[NSString stringWithFormat:@"%@@%@",[obj objectForKey:@"contactsUserName" ], OpenFireHostName]];
            
            [item addChild:iq2];
            [item addChild:message];
            [list addChild:item];
            
        }
    }];
    
    
    [iq addChild:queryElement];
    [queryElement addChild:list];
    //NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
}


//更新黑名单状态
-(void)updateBlackListStatus{
    
    //查询黑名单列表是否已存在
    if ([BlackListCRUD queryBlacklistTableCountId:_contactsUserName myUserName:MY_USER_NAME]>0){
        _blackListStatus = NSLocalizedString(@"circleMemberInfo.removeBlacklist",@"title");
        
    }else{
        _blackListStatus =  NSLocalizedString(@"circleMemberInfo.addBlacklist",@"title");;
    }

    [_tableView reloadData];
    
}


/*
 method 添加好友建立订阅关系
 */
/*
 -(void)addContacts:(NSString *)jid{
 XMPPPresence *presence = [XMPPPresence presence];
 [presence addAttributeWithName:@"type" stringValue:@"subscribe"];
 [presence addAttributeWithName:@"to" stringValue:jid];
 [presence addAttributeWithName:@"id" stringValue:@"1003"];
 NSLog(@"组装后的xml:%@",presence);
 [[XMPPServer xmppStream] sendElement:presence];
 
 [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-1] animated:YES];
 
 //更新联系人列表
 //  [self queryUserInfo];
 }
 */



/*
 Created by silenceSky  on 14-4-28.
 method 添加好友第一步查询好友信息并写入本地数据库
 */
-(void)queryContactsUserInfo:(NSString *)jid{
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *userJid=[NSXMLElement elementWithName:@"user"];
    NSLog(@"jid:%@",[[NSUserDefaults standardUserDefaults]stringForKey:@"jid"]);
    
    //id 随机生成（须确保无重复）
    NSLog(@"*******%@",[IdGenerator next]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[IdGenerator next] forKey:@"IQ_Add_Roster"];
    
    [userJid addAttributeWithName:@"jid" stringValue:jid];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[defaults stringForKey:@"IQ_Add_Roster"]];
    
    [queryElement addChild:userJid];
    [iq addChild:queryElement];
    NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
    self.tabBarController.selectedIndex = 1;
    
    //  [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    
}


/*---------------------------------所有订阅用户数据初始化--------------------------------------------*
 //查询有更新的订阅用户信息并更新联系人列表
 -(void)queryUserInfo{
 //id 随机生成（须确保无重复）
 NSLog(@"*******%@",[IdGenerator next]);
 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
 [defaults setObject:[IdGenerator next] forKey:@"IQ_Query_UserInfo"];
 
 NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
 NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
 
 [iq addAttributeWithName:@"id" stringValue:[defaults stringForKey:@"IQ_Query_UserInfo"]];
 [iq addAttributeWithName:@"type" stringValue:@"get"];
 [queryElement addAttributeWithName:@"ver" stringValue:[defaults stringForKey:@"Ver_Query_UserInfo"]];
 [iq addChild:queryElement];
 NSLog(@"组装后的xml:%@",iq);
 [[XMPPServer xmppStream] sendElement:iq];
 }
 */

/*------
 //删除联系人
 - (void)removeContacts:(NSString *)contactsUserName
 {
 XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",contactsUserName]];
 [[XMPPServer xmppRoster] removeUser:jid];
 [ContactsCRUD deleteChatBuddyByChatUserName:contactsUserName];
 }
 */


/*---视频语音start-----------------------------------------------------------------------------------*/
//打电话
-(void)playDial{
    NSLog(@"开始拨打电话");
#if !TARGET_IPHONE_SIMULATOR
    NSString  * jid = _contactsJID;
    XMPPJID *to = [XMPPJID jidWithString:jid resource:@"Hisuper"];
    NSString* sessionID = [XMPPStream generateUUID];
    if(YES)
    {
        APPRTCViewController *appView = [[APPRTCViewController alloc]init];
        appView.from = [to full];
        appView.isCaller = YES;
        appView.isVideo = NO;
        appView.msessionID = sessionID;
        [self.navigationController presentViewController:appView animated:YES completion:^{
            
            CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.tabBarBG.hidden=YES;
            
            [appView.lbname setText:to.user];
            UIImage *image = [UIImage imageNamed:@"defaultUser.png"];
            if (![StrUtility isBlankString:_contactsAvatarURL]) {
                //                NSString *photoImageUrl=[NSString stringWithFormat:@"%@/%@",ResourcesURL,_contactsAvatarURL];
                UIImageView *photoView=[[UIImageView alloc]initWithFrame:CGRectMake(240, 5, 50, 50)];
                [photoView setImageWithURL:[NSURL URLWithString:_contactsAvatarURL]
                          placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
                if (photoView.image) {
                    [appView.ivavatar setImage:photoView.image];
                }else{
                    [appView.ivavatar setImage:image];
                }
            }else{
                [appView.ivavatar setImage:image];
            }
            
            appView.ivavatar.layer.masksToBounds = YES;
            appView.ivavatar.layer.cornerRadius = 3.0;
            appView.ivavatar.layer.borderWidth = 3.0;
            appView.ivavatar.backgroundColor = kMainColor4;
            appView.ivavatar.layer.borderColor = [[UIColor whiteColor]CGColor];
        }];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"呼叫失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alert show];
        
    }
#endif
}

//开视频
-(void)playVideo{
    NSLog(@"开始语音视频");
#if !TARGET_IPHONE_SIMULATOR
    
    NSString  * jid = _contactsJID;
    XMPPJID *to = [XMPPJID jidWithString:jid resource:@"Hisuper"];
    NSString* sessionID = [XMPPStream generateUUID];
    if(YES)
    {
        APPRTCViewController *appView = [[APPRTCViewController alloc]init];
        appView.from = [to full];
        appView.isCaller = YES;
        appView.isVideo = YES;
        appView.msessionID = sessionID;
        [self.navigationController presentViewController:appView animated:YES completion:^{
            CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.tabBarBG.hidden=YES;
            
            [appView.lbname setText:to.user];
            UIImage *image = [UIImage imageNamed:@"defaultUser.png"];
            appView.ivavatar.layer.masksToBounds = YES;
            if (![StrUtility isBlankString:_contactsAvatarURL]) {
                //                NSString *photoImageUrl=[NSString stringWithFormat:@"%@/%@",ResourcesURL,_contactsAvatarURL];
                UIImageView *photoView=[[UIImageView alloc]initWithFrame:CGRectMake(240, 5, 50, 50)];
                [photoView setImageWithURL:[NSURL URLWithString:_contactsAvatarURL]
                          placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
                if (photoView.image) {
                    [appView.ivavatar setImage:photoView.image];
                }else{
                    [appView.ivavatar setImage:image];
                }
            }else{
                [appView.ivavatar setImage:image];
            }

            appView.ivavatar.layer.cornerRadius = 3.0;
            appView.ivavatar.layer.borderWidth = 3.0;
            appView.ivavatar.backgroundColor = kMainColor4;
            appView.ivavatar.layer.borderColor = [[UIColor whiteColor]CGColor];
        }];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"呼叫失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alert show];
        
    }
#endif
}
/*---视频语音end-----------------------------------------------------------------------------------*/


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //查询黑名单列表是否已存在
    if ([BlackListCRUD queryBlacklistTableCountId:_contactsUserName myUserName:MY_USER_NAME]>0){
        _blackListStatus = NSLocalizedString(@"circleMemberInfo.removeBlacklist",@"title");
    }else{
        _blackListStatus = NSLocalizedString(@"circleMemberInfo.addBlacklist",@"title");
    }
    [_tableView reloadData];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}


- (BOOL)shouldAutorotate

{
    
    return NO;
    
}



@end
