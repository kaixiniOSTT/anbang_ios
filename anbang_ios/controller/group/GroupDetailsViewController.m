//
//  GroupDetailsViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 14-3-28.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "GroupDetailsViewController.h"
#import "GroupMembersCRUD.h"
#import "CHAppDelegate.h"
#import "GroupAddContactsViewController.h"
#import "GroupCRUD.h"
#import "GroupChatMessageCRUD.h"
#import "GBPathImageView.h"
#import "GroupMembersDetailsViewController.h"
#import "Contacts.h"
#import "ContactsCRUD.h"
#import "ContactsDetailsViewController.h"
#import "GroupUpdNameTableViewController.h"
#import "GroupQrCodeViewController.h"
#import "Utility.h"
#import "UIImageView+WebCache.h"
#import "InformationViewController.h"
#import "GroupChatViewController2.h"
#import "APPRTCViewController.h"
#import "UserInfoCRUD.h"
#import "DejalActivityView.h"
#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface GroupDetailsViewController ()


@end

@implementation GroupDetailsViewController
@synthesize groupMembers = _groupMembers;
@synthesize chatGroups=_chatGroups;
@synthesize groupJID = _groupJID;
@synthesize creator = _creator;
@synthesize myTableView = _myTableView;

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
    
    //将muc 转成 jid
    NSString*str_character = @"@";
    NSRange jidRange = [_groupJID rangeOfString:str_character];
    
    if ([_groupJID rangeOfString:str_character].location != NSNotFound) {
        _groupJID =[NSString stringWithFormat:@"%@%@%@",[_groupJID substringToIndex:jidRange.location],@"@",GroupDomain] ;
    }
    
    
    //圈子更新刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupDetailsVC) name:@"CNN_Group_Load_OK" object:nil];
    
    _groupMembers = [[NSMutableArray alloc]init];
    _chatGroups = [[ChatGroup alloc]init];
    
    
    _myTableView= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-Both_Bar_Height) style:UITableViewStyleGrouped];
    // _myTableView.scrollEnabled = YES;
    // 设置tableView的数据源
    _myTableView.dataSource = self;
    // 设置tableView的委托
    _myTableView.delegate = self;
    [self.view addSubview:_myTableView];
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        //self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    [self.navigationItem setTitle:NSLocalizedString(@"circleInfo.title",@"title")];
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CNN_Group_Load_OK" object:nil];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
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
    else if(section==1){
        row=_groupMembers.count+2;
    } else if(section==2){
        row=1;
    }else
        row=2;
    return row;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return NSLocalizedString(@"circleInfo.circlelMembers",@"title");
    }
    return @"";
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15.0;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    
    if(section == 3){
        NSDate * createDate = [Utility getNowDateFromatAnDate:[Utility dateFromUtcString:_chatGroups.createDate]];
        NSString *createStr = [Utility stringFromDate:createDate formatStr:@"yyyy-MM-dd"];
        return   [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"circleInfo.creationTime",@"title"),createStr];
    }else
        return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //这个方法用来告诉某个分组的某一行是什么数据，返回一个UITableViewCell
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
        if ([StrUtility isBlankString:_chatGroups.name]) {
            cell.textLabel.text =[NSString stringWithFormat:@"%@：%@", NSLocalizedString(@"circleInfo.circleName",@"title"),@"未命名"];

        }else{
            cell.textLabel.text =[NSString stringWithFormat:@"%@：%@", NSLocalizedString(@"circleInfo.circleName",@"title"),_chatGroups.name];

        }
                cell.textLabel.frame = CGRectMake(0, 0, 60, 80);
        cell.textLabel.textColor=kMainColor;
        // cell.imageView.image = [UIImage imageNamed:@"setting_icon_account"];
        //        UILabel *label = [[UILabel alloc]init];
        //        label.frame = CGRectMake(KCurrWidth-150, 0,150, 80);
        //        label.text  = _chatGroups.name;
        //        //label.textColor = kMainColor;
        //        label.backgroundColor = [UIColor clearColor];
        //        [cell.contentView addSubview:label];
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%@",@"创建时间", [_groupDic objectForKey:@"createDate"]];
        // cell.detailTextLabel.frame=CGRectMake(0, 10, 60, 20);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if(section==1 && row!=_groupMembers.count && row!=_groupMembers.count+1){
        //圈子成员
        NSDictionary *memberDic = [_groupMembers objectAtIndex:row];
        
        //圈子成员头像
        NSString *avatar = [memberDic objectForKey:@"avatar"];
        
        
        NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, avatar];
        [cell.imageView setImageWithURL:[NSURL URLWithString:avatarURL]
                       placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
        
        CGSize itemSize = CGSizeMake(40, 40);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [cell.imageView.image drawInRect:imageRect];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //        UIImage *sendBtnBackground = [UIImage imageNamed:@"user_call"];
        //        UIButton* callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        callBtn.frame = CGRectMake(KCurrWidth - 45, 10, 25, 25);
        //        callBtn.imageView.frame = CGRectMake(KCurrWidth - 45, 10, 20, 20);
        //        [callBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
        //        [callBtn addTarget:self action:@selector(playDial:) forControlEvents:UIControlEventTouchUpInside];
        //        [callBtn setImage:sendBtnBackground forState:UIControlStateNormal];
        //        [callBtn setTintColor:[UIColor grayColor]];
        //        callBtn.backgroundColor = [UIColor clearColor];
        //        [callBtn.layer setCornerRadius:5.0];
        //        callBtn.tag = indexPath.row;
        
        if ([[memberDic objectForKey:@"role"] isEqualToString:@"owner"]) {
            cell.detailTextLabel.text = NSLocalizedString(@"circleInfo.circleCreator",@"title");
            cell.detailTextLabel.textColor = [UIColor redColor];
            if ([[memberDic objectForKey:@"jid"] isEqualToString:MY_JID]) {
                //@"我";
                _creator = @"owner";
                cell.textLabel.text = NSLocalizedString(@"circleInfo.me",@"title");
                //cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }else{
                //[cell addSubview:callBtn];
                if ([[memberDic objectForKey:@"businessCard"] length]>0) {
                    cell.textLabel.text = [memberDic objectForKey:@"businessCard"];
                }else{
                    
                    cell.textLabel.text = [memberDic objectForKey:@"nickName"];
                    
                }
            }
            
        }else{
            //[cell addSubview:callBtn];
            
            if ([[memberDic objectForKey:@"businessCard"] length]>0) {
                cell.textLabel.text = [memberDic objectForKey:@"businessCard"];
                NSLog(@"***%@",[memberDic objectForKey:@"businessCard"]);
            }else{
                
                cell.textLabel.text = [memberDic objectForKey:@"nickName"];
                
            }
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        
    }else if(section==1&&row==_groupMembers.count){
        //@"添加成员到圈子";
        cell.textLabel.text = NSLocalizedString(@"circleInfo.addCircleMembers",@"action");
        cell.textLabel.textColor = kMainColor;
        //cell.imageView.image = [UIImage imageNamed:@"setting_icon_account"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if(section==1&&row==_groupMembers.count+1){
        //@"二维码";
        cell.textLabel.text =  NSLocalizedString(@"circleInfo.circleQrCode",@"action");
        cell.textLabel.textColor=kMainColor;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if(section==2&&row==0){
        //发送消息
        cell.textLabel.text =  NSLocalizedString(@"public.sendMsg",@"action");
        cell.textLabel.textColor=kMainColor;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if(section ==3 &&row==0){
        //@"清空聊天纪录";
        cell.textLabel.text = NSLocalizedString(@"circleInfo.removeChatRecord",@"action");
        cell.textLabel.textColor = [UIColor redColor];
        //cell.imageView.image = [UIImage imageNamed:@"setting_icon_clean"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if(section==3&&row==1){
        
        if ([_creator isEqualToString:@"owner"]){
            //@"              删除并退出圈子";
            cell.textLabel.text = NSLocalizedString(@"circleInfo.removeAndExitCircle",@"action");
        }else{
            //@"                   退出圈子";
            cell.textLabel.text =NSLocalizedString(@"circleInfo.exitCircle",@"action");
        }
        cell.textLabel.textColor = [UIColor redColor];
        // cell.imageView.image = [UIImage imageNamed:@"setting_icon_info"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    NSLog(@"%d,%d",section,row);
    NSLog(@"%d",_groupMembers.count);
    if (section==0 && row==0) {
        GroupUpdNameTableViewController *groupUpdVC = [[GroupUpdNameTableViewController alloc]init];
        if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
            //隐藏tabbar
            self.tabBarController.tabBar.hidden = YES;
        }else{
            //隐藏tabbar
            groupUpdVC.hidesBottomBarWhenPushed=YES;
        }
        groupUpdVC.groupName = _chatGroups.name;
        groupUpdVC.groupJID = _chatGroups.jid;
        
        [self.navigationController pushViewController:groupUpdVC animated:YES];
        return;
        
    }else if (section==1) {
        //添加联系人
        if (row==_groupMembers.count) {
            self.title = NSLocalizedString(@"circleInfo.title",@"title");
            GroupAddContactsViewController *groupAddContactsVC = [[GroupAddContactsViewController alloc]init];
            groupAddContactsVC.fromViewFlag = @"GroupDetailsViewController";
            groupAddContactsVC.groupJID = _chatGroups.jid;
            groupAddContactsVC.groupName = _chatGroups.name;
            groupAddContactsVC.groupMucId = _chatGroups.groupMucId;
            groupAddContactsVC.groupMembers = _groupMembers;
            if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
                //隐藏tabbar
                self.tabBarController.tabBar.hidden = YES;
            }else{
                //隐藏tabbar
                groupAddContactsVC.hidesBottomBarWhenPushed=YES;
            }
            [self.navigationController pushViewController:groupAddContactsVC animated:YES];
            return;
        }
        
        if (row==_groupMembers.count+1) {
            GroupQrCodeViewController *groupQrCode=[[GroupQrCodeViewController alloc]init];
            groupQrCode.groupJID=_groupJID;
            groupQrCode.groupName=_chatGroups.name;
            [self.navigationController pushViewController:groupQrCode animated:YES];
            return;
        }
        
        //跳转个人信息页
        NSDictionary *memberDic = [_groupMembers objectAtIndex:row];
        NSString*str_character = @"@";
        NSRange jidRange = [[memberDic objectForKey:@"jid"] rangeOfString:str_character];
        NSString *contactsUserName = @"";
        if ([[memberDic objectForKey:@"jid"] rangeOfString:str_character].location != NSNotFound) {
            contactsUserName = [[memberDic objectForKey:@"jid"] substringToIndex:jidRange.location];
        }
        
        //如果已经是联系人，则跳转到联系人详细页
        if([ContactsCRUD queryContactsCountId:[memberDic objectForKey:@"jid"] myJID:MY_JID]){
            GroupMembersDetailsViewController *membersDetailsVC=[[GroupMembersDetailsViewController alloc] initWithNibName:@"GroupMembersDetailsViewController" bundle:nil];
            membersDetailsVC.groupJID = _chatGroups.jid;
            membersDetailsVC.groupMucJID = _chatGroups.groupMucId;
            membersDetailsVC.groupCreator = _chatGroups.creator;
            membersDetailsVC.contactsJID = [memberDic objectForKey:@"jid"];
            membersDetailsVC.contactsUserName = contactsUserName;
            membersDetailsVC.contactsNickName = [memberDic objectForKey:@"nickName"];
            membersDetailsVC.circleNickName = [memberDic objectForKey:@"businessCard"];
            //用户头像
            NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [memberDic objectForKey:@"avatar"]];
            membersDetailsVC.contactsAvatarURL = avatarURL;
            
            [self.navigationController pushViewController :membersDetailsVC animated:YES];
            
        }else if([[memberDic objectForKey:@"role"] isEqualToString:@"owner"] && [[memberDic objectForKey:@"jid"] isEqualToString:MY_JID]){
            //跳转个人信息页
            InformationViewController *information=[[InformationViewController alloc]init];
            //        [self.navigationController pushViewController:information animated:YES];
            information.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:information animated:YES];
            
            
            return;
        }else{
            
            GroupMembersDetailsViewController *membersDetailsVC=[[GroupMembersDetailsViewController alloc] initWithNibName:@"GroupMembersDetailsViewController" bundle:nil];
            membersDetailsVC.groupMucJID = _chatGroups.groupMucId;
            membersDetailsVC.groupJID = _chatGroups.jid;
            membersDetailsVC.groupCreator = _chatGroups.creator;
            membersDetailsVC.contactsJID = [memberDic objectForKey:@"jid"];
            membersDetailsVC.contactsUserName = contactsUserName;
            membersDetailsVC.contactsNickName = [memberDic objectForKey:@"nickName"];
            //用户头像
            NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [memberDic objectForKey:@"avatar"]];
            membersDetailsVC.contactsAvatarURL = avatarURL;
            
            [self.navigationController pushViewController :membersDetailsVC animated:YES];
        }
        
    }else if(section==2&&row==0){
        //发送消息
        GroupChatViewController2 *groupChatVC = [[GroupChatViewController2 alloc] init];
        groupChatVC.roomName = _chatGroups.groupMucId;
        groupChatVC.roomNickName = _chatGroups.name;
        groupChatVC.title = _chatGroups.name;
        //隐藏tabbar
        groupChatVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:groupChatVC animated:YES];
        
    }else if(section==3&&row==0){
        //删除本群组聊天纪录
        [self deleteGroupChatMsgActionSheet];
        
    }else if(section==3&&row==1){
        // NSLog(@"*****%@",_creator);
        if ([_creator isEqualToString:@"owner"]) {
            //删除并退出群组
            [self deleteGroupActionSheet];
        }else{
            //退出群组
            [self exitGroupActionSheet];
        }
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
        return 68.0;
    else if(section ==1)
        return 60.0;
    else
        return 50;
}

//确定删除群组聊天纪录提示
- (void)deleteGroupChatMsgActionSheet
{
    if (kIOS_VERSION>=8.0) {
        
        UIAlertController *otherLoginAlert = nil;
        if (kIsPad) {
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleAlert];
        }else{
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        }
        
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"circleInfo.sureRemoveChatRecord",@"action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [GroupChatMessageCRUD deleteMyGroupChatMsg:_chatGroups.groupMucId];
                                                              //跳转到圈子列表
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
        UIActionSheet *menu=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"tittle") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"circleInfo.sureRemoveChatRecord",@"action"),nil];
        menu.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
        menu.tag=10000;
        [menu showInView:self.view.window];
    }
}

//确定删除群组提示
- (void)deleteGroupActionSheet
{
    if (kIOS_VERSION>=8.0) {
        
        UIAlertController *otherLoginAlert = nil;
        if (kIsPad) {
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleAlert];
        }else{
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        }
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"circleInfo.sureRemoveAndExitCircle",@"action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self deleteGroup:_chatGroups.jid];
                                                              //跳转到圈子列表
                                                              [self performSelector:@selector(popToVC:) withObject:@"0" afterDelay:1];//1秒后执行
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
        
        UIActionSheet *menu=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"tittle") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"circleInfo.sureRemoveAndExitCircle",@"action"),nil];
        menu.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
        menu.tag=10001;
        [menu showInView:self.view.window];
    }
}


//确定退出群组提示
- (void)exitGroupActionSheet
{
    if (kIOS_VERSION>=8.0) {
        
        UIAlertController *otherLoginAlert = nil;
        if (kIsPad) {
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleAlert];
        }else{
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        }
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"circleInfo.sureExitCircle",@"action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self exitGroup:_chatGroups.jid];
                                                              //跳转到圈子列表
                                                              [self performSelector:@selector(popToVC:) withObject:@"0" afterDelay:1];//1秒后执行
                                                              
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
        
        UIActionSheet *menu=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"tittle") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"circleInfo.sureExitCircle",@"action"),nil];
        menu.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
        menu.tag=10002;
        [menu showInView:self.view.window];
        
    }
}


#pragma mark -
#pragma mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (actionSheet.tag==10000) {
        switch (buttonIndex) {
            case 0:
                //NSLog(@"click at index %d，确定操作", buttonIndex);
                [GroupChatMessageCRUD deleteMyGroupChatMsg:_chatGroups.groupMucId];
                //跳转到圈子列表
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
                break;
            case 1:
                //NSLog(@"click at index %d，取消操作", buttonIndex);
                break;
                
            default:
                //NSLog(@"unknown： click at index %d", buttonIndex);
                break;
        }
        
    }else if(actionSheet.tag==10001){
        switch (buttonIndex) {
            case 0:
                //NSLog(@"click at index %d，确定操作", buttonIndex);
                [self deleteGroup:_chatGroups.jid];
                //跳转到圈子列表
                [self performSelector:@selector(popToVC:) withObject:@"0" afterDelay:1];//1秒后执行
                break;
            case 1:
                //NSLog(@"click at index %d，取消操作", buttonIndex);
                break;
                
            default:
                //NSLog(@"unknown： click at index %d", buttonIndex);
                break;
        }
    }else if(actionSheet.tag==10002){
        switch (buttonIndex) {
            case 0:
                //NSLog(@"click at index %d，确定操作", buttonIndex);
                [self exitGroup:_chatGroups.jid];
                //跳转到圈子列表
                [self performSelector:@selector(popToVC:) withObject:@"0" afterDelay:1];//1秒后执行
                break;
            case 1:
                //NSLog(@"click at index %d，取消操作", buttonIndex);
                break;
                
            default:
                //NSLog(@"unknown： click at index %d", buttonIndex);
                break;
        }
    }
    
}

- (void)popToVC:(NSString *)index{
    [DejalBezelActivityView removeViewAnimated:YES];
    int indexInt = [index intValue];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:indexInt] animated:YES];
    
}



/*---删除群组--------------------------------------------------------------------------------------*/
-(void)deleteGroup:(NSString *)groupJID{
    //加载动画效果
    [DejalBezelActivityView activityViewForView:self.view];
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/admin"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:@"circle.ab-insurance.com"];
    [circle addAttributeWithName:@"jid" stringValue:groupJID];
    [circle addAttributeWithName:@"remove" stringValue:@"true"];
    [iq addChild:queryElement];
    [queryElement addChild:circle];
    // NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    // NSLog(@"*****%@",jid);
    //删除本地圈子数据
    [GroupCRUD deleteMyGroup:groupJID myJID:MY_JID];
}


/*---退出群组--------------------------------------------------------------------------------------*/
-(void)exitGroup:(NSString *)groupJID{
    //加载动画效果
    [DejalBezelActivityView activityViewForView:self.view];
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/admin"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
    NSXMLElement *members = [NSXMLElement elementWithName:@"members"];
    NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"iq_exit_group"];
    [iq addAttributeWithName:@"to" stringValue:@"circle.ab-insurance.com"];
    [circle addAttributeWithName:@"jid" stringValue:groupJID];
    [member addAttributeWithName:@"jid" stringValue:MY_JID];
    [member addAttributeWithName:@"remove" stringValue:@"true"];
    [iq addChild:queryElement];
    [queryElement addChild:circle];
    [circle addChild:members];
    [members addChild:member];
    // NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    //删除本地圈子数据
    //[GroupCRUD deleteMyGroup:groupJID myJID:MY_JID];
}


//收到更新通知刷新(推迟刷新）
-(void)refreshGroupDetailsVC{
    NSTimer *timer;
    int timeInt = 2;
    timer=[NSTimer scheduledTimerWithTimeInterval:timeInt
                                           target:self
                                         selector:@selector(refreshGroupDetailsVCTimer)
                                         userInfo:nil
                                          repeats:NO];
}

- (void)refreshGroupDetailsVCTimer{
    _chatGroups = [GroupCRUD queryOneMyChatGroup2:_groupJID myJID:MY_JID];
    //[_chatGroups retain];
    _groupMembers =[GroupMembersCRUD queryChatRoomByGroupJID2:_chatGroups.jid myJID:MY_JID];
    
    [_myTableView reloadData];
}



/*---视频语音start-----------------------------------------------------------------------------------*/
//打电话
-(void)playDial:(UIButton*)btn{
    //NSLog(@"开始拨打电话");
#if !TARGET_IPHONE_SIMULATOR
    //圈子成员
    NSDictionary *memberDic = [_groupMembers objectAtIndex:btn.tag];
    
    NSString *jid = [memberDic objectForKey:@"jid"];
    
    XMPPJID *to = [XMPPJID jidWithString:jid resource:@"Hisuper"];
    NSString* sessionID = [XMPPStream generateUUID];
    if(YES)
    {
        APPRTCViewController *appView = [[APPRTCViewController alloc]init];
        appView.from = [to full];
        appView.isCaller = YES;
        appView.isVideo = NO;
        appView.msessionID = sessionID;
        
        appView.ivavatar.layer.masksToBounds = YES;
        appView.ivavatar.layer.cornerRadius = 3.0;
        appView.ivavatar.layer.borderWidth = 3.0;
        appView.ivavatar.backgroundColor = kMainColor4;
        appView.ivavatar.layer.borderColor = [[UIColor whiteColor]CGColor];
        
        [self.view.window.rootViewController presentViewController:appView animated:YES completion:^{
            
            //            CHAppDelegate *app = [UIApplication sharedApplication].delegate;
            [appView.lbname setText:[memberDic objectForKey:@"nickName"]];
            
            
            NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [UserInfoCRUD queryUserInfoAvatar:jid]];
            
            UIImageView *headImageView = [[UIImageView alloc]init];
            headImageView.backgroundColor = [UIColor clearColor];
            
            [headImageView setImageWithURL:[NSURL URLWithString:avatarURL]
                          placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
            
            if(headImageView.image){
                [appView.ivavatar setImage:headImageView.image];
            }else{
                [appView.ivavatar setImage:[UIImage imageNamed:@"defaultUser.png"]];
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
        //[self showAlert:@"呼叫失败"];
        
        
    }
#endif
}




- (void)viewWillAppear:(BOOL)animated {
    _chatGroups = [GroupCRUD queryOneMyChatGroup2:_groupJID myJID:MY_JID];
    _groupMembers =[GroupMembersCRUD queryChatRoomByGroupJID2:_chatGroups.jid myJID:MY_JID];
    [_myTableView reloadData];
}


- (void)viewWillDisappear:(BOOL)animated {
    
}


- (BOOL)shouldAutorotate{
    return NO;
}

@end
