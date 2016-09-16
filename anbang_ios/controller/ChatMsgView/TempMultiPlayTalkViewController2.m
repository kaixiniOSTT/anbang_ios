//
//  GroupDetailViewController.m
//  anbang_ios
//
//  Created by yangsai on 15/3/29.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "TempMultiPlayTalkViewController2.h"
#import "DejalActivityView.h"
#import "MultiplayerTalkCRUD.h"
#import "TempMultiPlayTalkCellContact.h"
#import "TempMultiPlayTalkCellSwitch.h"
#import "Contacts.h"
#import "ContactsCRUD.h"
#import "UserInfoCRUD.h"
#import "GroupAddMemberViewController.h"
#import "ChatMessageCRUD.h"
#import "DndInfoCRUD.h"
#import "ContactInfo.h"


@interface TempMultiPlayTalkViewController2 ()<TempMultiPlayTalkCellContactDelegate,UIActionSheetDelegate>
{
    UIButton *leftNavigationItemButton;
}
@property (nonatomic, retain) NSMutableArray* multiplayerTalkArray;


@end

@implementation TempMultiPlayTalkViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _multiplayerTalkArray = [NSMutableArray array];
    
    Contacts* contact = [[Contacts alloc]init];
    UserInfo *userInfo = [UserInfoCRUD queryUserInfo:_memberJID myJID:MY_JID];
    NSString *remarkName = [ContactsCRUD queryContactsRemarkName:_memberJID];
    contact.nickName  = [StrUtility isBlankString:remarkName] ? userInfo.nickName : remarkName;
    contact.jid = _memberJID;
    contact.avatar = [UserInfoCRUD queryUserInfoAvatar:_memberJID];
    contact.accountType = userInfo.accountType;
    
    [_multiplayerTalkArray addObject: contact];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = Buddy_Table_Separator_color;
    UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = view;
    self.view.backgroundColor = Controller_View_Color;
    
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(pop)]];
    self.navigationItem.title = @"聊天详情";
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    if(section == 0 || section == 2){
        return 1;
    }else if(section == 1 ){
        return 2;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0 ) {
        TempMultiPlayTalkCellContact* cell = [[TempMultiPlayTalkCellContact alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, [self setHightCollectionView])];
        [cell setRestorationIdentifier:@"TempMultiPlayTalkCellContact"];
        cell.multiplayerTalkArray = _multiplayerTalkArray;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        return  cell;
        
    }else if(indexPath.section == 1){
        
        TempMultiPlayTalkCellSwitch* cell= [[TempMultiPlayTalkCellSwitch alloc] initWithStyle:UITableViewCellStyleDefault
                                                                              reuseIdentifier:@"TempMultiPlayTalkCellSwitch"];
        UITableViewCell* cell1 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TempMultiPlayTalkTableViewCell"];
        cell1.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch(indexPath.row){
            case 0: {
                cell.textLabel.text = @"置顶聊天";
                cell.opType = @"置顶聊天";
                cell.jid = _memberJID;
                NSString *stickie_time = [UserInfoCRUD queryStickieTimeWithJID:_memberJID];
                cell.isOn = ([stickie_time isEqualToString:@"0"]) ? NO : YES;
            }
                break;
            case 1: {
                cell.textLabel.text = @"消息免打扰";
                cell.opType = @"消息免打扰";
                cell.jid = _memberJID;
                cell.isOn = [DndInfoCRUD queryOfRosterExtWithJid:_memberJID];
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
    }else if(indexPath.section == 2){
        
        UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TempMultiPlayTalkTableViewCell"];
        cell.textLabel.textAlignment =NSTextAlignmentCenter;
        cell.textLabel.text = @"清空聊天记录";
       // cell.textLabel.textColor = [UIColor blueColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else{
        
        UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TempMultiPlayTalkTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    
}




-(CGFloat)setHightCollectionView{
    
    NSInteger count = _multiplayerTalkArray.count + 1;
    
    if (count % 4 == 0){
        return count / 4 * 68 + 30 + (count / 4 - 1 ) * 21;
    }else{
        return count / 4 * 68 + 68 + 30 + count / 4  * 21;
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 2 && indexPath.row == 0){
        [self deleteMultiPlayTalkChatMsgActionSheet];
    }
    
}

-(void)tempMultiPlayTalkCellContact:(TempMultiPlayTalkCellContact *)cellContact addMemberSuccess:(NSString *)MemberJid{
    
    GroupAddMemberViewController *groupAddContactsVC = [[GroupAddMemberViewController alloc]init];
   
    Contacts* contact = (Contacts*)[_multiplayerTalkArray objectAtIndex:0];
    
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:contact.jid,@"jid", contact.nickName, @"nickName", contact.avatar, @"avatar", nil];
    
    groupAddContactsVC.groupMembers = [NSMutableArray arrayWithObject:dic];
    groupAddContactsVC.isAddMem = NO;
    groupAddContactsVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:groupAddContactsVC animated:YES];
}

-(void)showContactInfo:(TempMultiPlayTalkCellContact*) cellContact
{
    ContactInfo *contactInfo = [[ContactInfo alloc] init];
    contactInfo.jid = _memberJID;
    contactInfo.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:contactInfo animated:YES];
}


- (void)deleteMultiPlayTalkChatMsgActionSheet
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
                                                              [self deleteChatMsg];
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


-(void)deleteChatMsg{
    NSString *chatWithUserName = @"";
    NSString*str_character = @"@";
    NSRange senderRange = [_memberJID rangeOfString:str_character];
    if ([_memberJID rangeOfString:str_character].location != NSNotFound) {
        chatWithUserName = [_memberJID substringToIndex:senderRange.location];
    }
    [ChatMessageCRUD deleteChatWithUserMessage2:MY_USER_NAME chatWithUserName:chatWithUserName];
    
    if([_delegate respondsToSelector:@selector(tempMultiPlayTalkViewController:SuccessWithDeleteChatMsg:)]){
        [_delegate tempMultiPlayTalkViewController:self SuccessWithDeleteChatMsg:nil];
    }
    
    
}

#pragma mark -
#pragma mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (actionSheet.tag==10000) {
        switch (buttonIndex) {
            case 0:
                [self deleteChatMsg];
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

    }

}

@end
