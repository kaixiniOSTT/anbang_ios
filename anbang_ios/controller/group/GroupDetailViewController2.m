//
//  GroupDetailViewController.m
//  anbang_ios
//
//  Created by yangsai on 15/3/29.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "GroupDetailViewController2.h"
#import "GroupDetailCellSwitch.h"
#import "GroupDetailCellContact.h"
#import "Contacts.h"
#import "UserInfo.h"
#import "GroupCRUD.h"
#import "GroupDetailUpdateGroupNameVC.h"
#import "GroupDetailUpdateMemNameVC.h"
#import "GroupAddMemberViewController.h"
#import "GroupQrCodeViewController.h"
#import "GroupChatMessageCRUD.h"
#import "GroupMembersCRUD.h"
#import "DejalActivityView.h"
#import "GroupChatMessageCRUD.h"
#import "ContactInfo.h"
#import "DndInfoCRUD.h"
#import "ContactsCRUD.h"
#import "UserInfoCRUD.h"
#import "GroupMembersCRUD.h"
#import "AIUsersUtility.h"

@interface GroupDetailViewController2 ()<GroupDetailUpdateNameDelegate,GroupDetailUpdateMemNameDelegate, GroupDetailCellContactDelegate, GroupAddMemberViewControllerDelegate, UIActionSheetDelegate >
{
    UILabel *titleLabel;
}
@property (nonatomic, retain) NSString* creator;
@property (nonatomic, retain) NSMutableArray* groupContacts;
@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic, assign) BOOL isAB;
@property (nonatomic, retain) NSString* membName;
@property (nonatomic, assign) BOOL isDele;

@end

@implementation GroupDetailViewController2

- (void)resetGroupMembers {
    if (!self.groupContacts) {
        self.groupContacts = [NSMutableArray array];
    }
    for (NSDictionary *d in _group.groupMembersArray) {
        NSMutableDictionary *md = [NSMutableDictionary dictionaryWithDictionary:d];
        NSString *gNickName = [AIUsersUtility gnameForShowWithJID:d[@"jid"] inGroup:_group.jid];
        [md setObject:gNickName forKey:@"nickName"];
        [self.groupContacts addObject:md];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     _isDele = NO;
    self.creator = _group.creator;

    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self resetGroupMembers];

    if ([MY_JID isEqualToString:_creator]) {
        _isAdmin = YES;
    }else{
        _isAdmin = NO;
    }
    
    if([_group.groupType isEqualToString:@"department"]){
       _isAB = YES;
    }else{
       _isAB = NO;
    }
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if(!_isAB){
        UIButton* bt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        bt.frame = CGRectMake(15, 15, self.view.bounds.size.width-30, 43);
        bt.layer.cornerRadius = 3.0f;
        bt.backgroundColor = RGBCOLOR(229.0, 90.0, 57.0);
        
        if ([_group.creator isEqualToString: MY_JID]) {
            [bt setTitle:@"解散并退出" forState:UIControlStateNormal];
        }else{
            [bt setTitle:@"删除并退出" forState:UIControlStateNormal];
        }
        
        [bt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [bt.titleLabel setFont:AB_FONT_17];
        UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 73)];
        //view.backgroundColor = [UIColor blueColor];
        [bt addTarget:self action:@selector(exitThisGroup) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:bt];
        
        self.tableView.tableFooterView = view;
    }else{
        self.tableView.tableFooterView = [[UIView alloc]init];
    }
   
//    [self.tableView registerClass:[GroupDetailContactsCell class] forCellReuseIdentifier:@"GroupDetailContactCell"];
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"GroupDetailVCTableViewCell"];
    
    for(int i = 0; i< _groupContacts.count; i++){
        
        Contacts* contact = [[Contacts alloc]init];
        
        [contact setValuesForKeysWithDictionary:_groupContacts[i]];
        
        if ([contact.jid isEqualToString:_creator]) {
            [_groupContacts exchangeObjectAtIndex:i withObjectAtIndex:0];
            break;
        }
    }
    
    for(int i = 0; i< _groupContacts.count; i++){
        
        Contacts* contact = [[Contacts alloc]init];
        
        [contact setValuesForKeysWithDictionary:_groupContacts[i]];
        
        if ([contact.jid isEqualToString:MY_JID]) {
            NSMutableDictionary* tempDic =  _groupContacts[i];
            if([StrUtility isBlankString:[tempDic valueForKey:@"nickName"]]){
                _membName = @"";
            } else {
                _membName = [tempDic valueForKey:@"nickName"];
            }
            break;
        }
    }

    self.view.backgroundColor = Controller_View_Color;
    
    [self setupNavigationItem];
    
}

- (void)setupNavigationItem
{
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(pop)]];
    
    titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, Screen_Width - 50 -100, 30.0f)];
    titleLabel.backgroundColor= [UIColor clearColor];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = AB_FONT_18_B;
    titleLabel.textColor = AB_Color_ffffff;
    [self reloadGroupTitle];
    self.navigationItem.titleView = titleLabel;
}

- (void)pop
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, tableView.frame.size.width, 15);
    view.backgroundColor = self.view.backgroundColor;
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 15;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
      return  [self setHightCollectionView];
        
    }
    
    return 43;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    if(section == 0 || section == 3){
        return 1;
    }else if(section == 1){
        return _isAB? 2:3;
    }
    else if(section == 2){
        return _isAB?1:2;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.separatorColor = [UIColor colorWithRed:246.0/255.0 green:242.0/255.0 blue:237.0/255.0 alpha:1];
    
    if (indexPath.section == 0 ) {
//    GroupDetailCellContact* cell = [[GroupDetailCellContact alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupDetailContactCell"];
        GroupDetailCellContact* cell = [[GroupDetailCellContact alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, [self setHightCollectionView])];
        [cell setRestorationIdentifier:@"GroupDetailContactCell"];
        cell.contacts = _groupContacts;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.isAdmin = _isAdmin;
        cell.isAB = _isAB;
        cell.isDele = _isDele;
        cell.groupJid = _group.jid;
        cell.delegate = self;
        return  cell;
    }else if(indexPath.section == 1){
        UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"GroupDetailVCTableViewCell"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];
        
        cell.textLabel.textColor = UIColorFromRGB(0x403b36);
        switch(indexPath.row){
            case 0: cell.textLabel.text = @"群聊名称";
                if ([StrUtility isBlankString:_group.name]) {
                     cell.detailTextLabel.text= @"未命名";
                }else{
                     cell.detailTextLabel.text= _group.name;
                }
             
                break;
            case 1:
                {
                    if(_isAB){
                        cell.textLabel.text = @"我在本群的昵称";
                        cell.detailTextLabel.text = _membName;
                    } else {
                        cell.textLabel.text = @"群二维码";
                        UIImageView *qrCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(Screen_Width - 60, 12, 20, 20)];
                        qrCodeImageView.image = [UIImage imageNamed:@"icon_qrcode"];
                        [cell.contentView addSubview:qrCodeImageView];
                    }
                }
                break;
            case 2:
                cell.textLabel.text = @"我在本群的昵称";
                cell.detailTextLabel.text = _membName;
                break;
            default:
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if(indexPath.section == 2){
        
        GroupDetailCellSwitch* cell = [[GroupDetailCellSwitch alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupDetailCellSwitch"];
         UITableViewCell* cell1 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"GroupDetailVCTableViewCell"];
         cell1.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
         cell.textLabel.textColor = UIColorFromRGB(0x403b36);
        switch(indexPath.row){
            case 0: {
                if (!_isAB) {
                    cell.textLabel.text = @"置顶聊天";
                    cell.opType = @"置顶聊天";
                    cell.jid = _group.groupMucId;
                    NSString *stickie_time = [GroupCRUD queryStickieTimeWithJID:_group.groupMucId];
                    cell.isOn = ([stickie_time isEqualToString:@"0"]) ? NO : YES;
                } else {
                    cell.textLabel.text = @"消息免打扰";
                    cell.opType = @"消息免打扰";
                    cell.jid = _group.groupMucId;
                    cell.isOn = [DndInfoCRUD queryOfRosterExtWithJid:_group.groupMucId];
                }
            }
                break;
            case 1:{
                cell.textLabel.text = @"消息免打扰";
                cell.opType = @"消息免打扰";
                cell.jid = _group.groupMucId;
                cell.isOn = [DndInfoCRUD queryOfRosterExtWithJid:_group.groupMucId];
            }
                
                break;
            case 2:
                cell1.textLabel.text = @"设置当前聊天背景";
                cell1.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell1;
                break;
            default:
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if(indexPath.section == 3){
        
        UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupDetailVCTableViewCell"];
        cell.textLabel.textAlignment =NSTextAlignmentCenter;
        cell.textLabel.text = @"清空聊天记录";
        cell.textLabel.textColor = UIColorFromRGB(0x403b36);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else{
        
        UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupDetailVCTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(CGFloat)setHightCollectionView{
    
    NSInteger count = _groupContacts.count;
    if(!_isAB){
        if (_isAdmin) {
            count += 2;
        }else{
            count += 1;
        }
    }
    
    if (count % 4 == 0){
        return count / 4 * 66 + 30 + (count / 4 - 1 ) * 21;
    }else{
        return count / 4 * 66 + 68 + 20 + count / 4  * 21;
    }

}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_isAB && indexPath.section == 1 && indexPath.row == 0) {
        [self updateGroupName];
    }else if(!_isAB && indexPath.section == 1 && indexPath.row == 2){
        [self updateGroupMembName];
    }else if(!_isAB && indexPath.section == 1 && indexPath.row == 1){
        [self toGroupQrCodeView];
    }else if(indexPath.section == 3 && indexPath.row == 0){
        [self deleteGroupChatMsgActionSheet];
    }
    
}


-(void)updateGroupName{
    GroupDetailUpdateGroupNameVC* updateGroupNameVC = [[GroupDetailUpdateGroupNameVC alloc]init];
    updateGroupNameVC.groupJid = _group.jid;
    updateGroupNameVC.groupMucId = _group.groupMucId;
    updateGroupNameVC.groupName =_group.name;
    updateGroupNameVC.delegate = self;
    updateGroupNameVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:updateGroupNameVC animated:YES];
}

-(void)updateGroupMembName{
    GroupDetailUpdateMemNameVC* updateGroupMembNameVC = [[GroupDetailUpdateMemNameVC alloc]init];
    updateGroupMembNameVC.groupJid = _group.jid;
    updateGroupMembNameVC.groupMembJid = MY_JID;
    updateGroupMembNameVC.groupMembName = _membName;
    updateGroupMembNameVC.delegate = self;
    [self.navigationController pushViewController:updateGroupMembNameVC animated:YES];
    
}


-(void)groupDetailUpdateNameVC:(GroupDetailUpdateGroupNameVC *)viewController UpdateSuccess:(NSString *)newGroupName{
    _group.name = newGroupName;
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
    cell.detailTextLabel.text = newGroupName;

    [self reloadGroupTitle];
    
    [self UpdateNavigationTitleGroupChatMsg:newGroupName];
}

-(void)groupDetailUpdateMemNameVC:(GroupDetailUpdateMemNameVC *)viewController UpdateSuccess:(NSString *)newGroupMembName{
    
    
    for(int i = 0; i< _groupContacts.count; i++){
        
        Contacts* contact = [[Contacts alloc]init];
        
        [contact setValuesForKeysWithDictionary:_groupContacts[i]];
        
        if ([contact.jid isEqualToString:MY_JID]) {
            NSMutableDictionary* tempDic =[NSMutableDictionary dictionaryWithDictionary:_groupContacts[i]];

            [tempDic setObject:newGroupMembName forKey:@"nickName"];
            _groupContacts[i] = [NSDictionary dictionaryWithDictionary:tempDic];
            //_group.groupMembersArray[i] = _groupContacts[i];
            _membName = newGroupMembName;
            break;
        }
    }
    
    [self.tableView reloadData];
}


-(void)groupDetailCellContact:(GroupDetailCellContact *)cellContact deleMemberSuccess:(NSString *)MemberJid{
    
    for(int i = 0; i< _groupContacts.count; i++){
        
        Contacts* contact = [[Contacts alloc]init];
        
        [contact setValuesForKeysWithDictionary:_groupContacts[i]];
        
        if ([contact.jid isEqualToString:MemberJid]) {
            [_groupContacts removeObjectAtIndex:i];
            break;
        }
    }
    if (MemberJid != nil || [MemberJid isEqualToString:@""] ) {
        _isDele = YES;
    }else{
        _isDele = NO;
    }
    
    [self.tableView reloadData];

}


-(void)groupDetailCellContact:(GroupDetailCellContact *)cellContact addMemberSuccess:(NSString *)MemberJid{
    
    GroupAddMemberViewController *groupAddContactsVC = [[GroupAddMemberViewController alloc]init];
    groupAddContactsVC.fromViewFlag = @"GroupDetailViewController2";
    groupAddContactsVC.groupJID =_group.jid;
    groupAddContactsVC.groupName = _group.name;
    groupAddContactsVC.groupMucId = _group.groupMucId;
    groupAddContactsVC.groupMembers = _groupContacts;
    groupAddContactsVC.isAddMem = YES;
    groupAddContactsVC.hidesBottomBarWhenPushed=YES;
    groupAddContactsVC.delegate = self;
    [self.navigationController pushViewController:groupAddContactsVC animated:YES];
    return;
}

-(void)groupMemberClicked:(NSString *)jid
{
    ContactInfo *contact = [[ContactInfo alloc] initWithNibName:@"ContactInfo" bundle:nil];
    contact.jid = jid;
    [self.navigationController pushViewController:contact animated:YES];
}

-(void)groupAddMemberViewController:(GroupAddMemberViewController *)controllerView Success:(NSString *)success{
 
    _groupContacts = [GroupMembersCRUD queryChatRoomByGroupJID2:_group.jid myJID:MY_JID];
    
    for (int i = 0 ; i < _groupContacts.count; i++) {
        if ([[_groupContacts[i] valueForKey:@"jid"] isEqualToString:_group.creator]) {
            [_groupContacts exchangeObjectAtIndex:0 withObjectAtIndex:i];
            break;
        }
    }
    
    [self.tableView reloadData];
}


-(void)toGroupQrCodeView{
    GroupQrCodeViewController* qrCodeView = [[GroupQrCodeViewController alloc]init];
    qrCodeView.groupJID=_group.jid;
    qrCodeView.groupName=_group.name;
    qrCodeView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:qrCodeView animated:YES];
}


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
                                                              [self deleteGroupChatMsg];
                                                              //跳转到圈子列表
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                              
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


-(void)deleteGroupChatMsg{
    [GroupChatMessageCRUD deleteMyGroupChatMsgByGroupMucId:_group.groupMucId];
    
    if([_delegate respondsToSelector:@selector(groupDetailViewController:SuccessWithDeteleGroupChatMsg:)]){
        [_delegate groupDetailViewController:self SuccessWithDeteleGroupChatMsg:nil];
    }
    
    
}

-(void)UpdateNavigationTitleGroupChatMsg:(NSString*) title{
    if([_delegate respondsToSelector:@selector(groupDetailViewController:SuccessWithUpdateTitleGroupChatMsg:)]){
        [_delegate groupDetailViewController:self SuccessWithUpdateTitleGroupChatMsg:title];
    }
}


-(void)exitThisGroup{
    if ([_group.creator isEqualToString:MY_JID]) {
        //删除并退出群组
        [self deleteGroupActionSheet];
    }else{
        //退出群组
        [self exitGroupActionSheet];
    }
}

- (void)deleteGroupActionSheet
{
    if (kIOS_VERSION>=8.0) {
        
        UIAlertController *otherLoginAlert = nil;
        if (kIsPad) {
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleAlert];
        }else{
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        }
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:@"解散并退出"                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self deleteGroup:_group.jid];
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

- (void)exitGroupActionSheet
{
    if (kIOS_VERSION>=8.0) {
        
        UIAlertController *otherLoginAlert = nil;
        if (kIsPad) {
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:nil preferredStyle:UIAlertControllerStyleAlert];
        }else{
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        }
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:@"删除并退出"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self exitGroup:_group.jid];
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
                [GroupChatMessageCRUD deleteMyGroupChatMsgByGroupMucId:_group.groupMucId];
                //跳转到对话列表
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
                [self deleteGroup:_group.jid];
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
                [self exitGroup:_group.jid];
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
    [GroupChatMessageCRUD deleteMyGroupChatMsgByGroupMucId2:_group.groupMucId];
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
    [GroupCRUD deleteMyGroup:groupJID myJID:MY_JID];
     [GroupChatMessageCRUD deleteMyGroupChatMsgByGroupMucId2:_group.groupMucId];
}

-(void)reloadGroupTitle
{
    ChatGroup *group = [GroupCRUD queryOneMyChatGroup2:_group.jid myJID:MY_JID];
    
    if(group){
        group.name = [StrUtility string:group.name defaultValue:@"群聊"];
        titleLabel.text = [NSString stringWithFormat:@"%@(%d)", group.name, group.groupMembersArray.count];
    }
}


@end
