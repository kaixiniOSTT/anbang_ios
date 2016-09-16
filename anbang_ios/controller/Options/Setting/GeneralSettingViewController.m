//
//  GeneralSettingViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 15-3-24.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "GeneralSettingViewController.h"
#import "PhoneNumViewController.h"
#import "EmailViewController.h"
#import "InformationCell.h"
#import "PhoneBindingViewController.h"

#import "AISetBBIdViewController.h"
#import "AIBindPhoneViewController.h"
#import "AIUnbindPhoneViewController.h"
#import "AIBindEmailViewController.h"
#import "AIUnbindEmailController.h"
#import "AIChangePasswordController.h"
#import "ChatMessageCRUD.h"
#import "GroupChatMessageCRUD.h"
#import "SystemMessageCRUD.h"
#import "ChatBuddyCRUD.h"
#import "UserInfoCRUD.h"

@interface GeneralSettingViewController (){
    UISwitch *stSound;
    UISwitch *stVibration;
    UISwitch *handsFreeSwitch;
}

@end

@implementation GeneralSettingViewController

-(void)dealloc{
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NNC_PersonalInfomation_Loaded" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"bindingEmails_ok" object:nil];
}
- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通用设置";
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"target:self action:@selector(pop)]];
    self.userInfo = [UserInfo loadArchive];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"NNC_PersonalInfomation_Loaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendsSuccess) name:@"bindingEmails_ok" object:nil];

    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        //self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }

    // Do any additional setup after loading the view from its nib.
    generalSettingTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-Both_Bar_Height) style:UITableViewStyleGrouped];
    generalSettingTableView.backgroundColor = Controller_View_Color;
    generalSettingTableView.separatorColor = AB_Color_f6f2ed;
    generalSettingTableView.delegate=self;
    generalSettingTableView.dataSource=self;
    generalSettingTableView.showsVerticalScrollIndicator = NO;
    //[informationTableView setAutoresizesSubviews:YES];
    [self.view bringSubviewToFront:generalSettingTableView];
    [self.view addSubview:generalSettingTableView];
    

    
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    self.userInfo = [UserInfo loadArchive];
    
//    JLLog_I(@"self.userInfo=%@", self.userInfo);
    
    [generalSettingTableView reloadData];
    
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //这个方法告诉表格第section个分组有多少行
    int row=0;
    if(section==0)
        row=2;
    else if(section==1)
        row=1;
    else if(section==2)
        row=4;
    else
        row = 1;
    return row;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 31)];
    headView.backgroundColor = [UIColor clearColor];
    
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 150, 31)];
    nameLab.textColor = AB_Color_9c958a;
    nameLab.font = AB_FONT_12;
    nameLab.backgroundColor = [UIColor clearColor];
    if (section==0) {
        nameLab.text = @"新消息通知设置";
    }
    else if(section==1){
        nameLab.text = @"聊天系统设置";
    }
    else if(section==2){
        nameLab.text = @"隐私设置";
    }
    
    [headView addSubview:nameLab];
    
    return headView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 31;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    static NSString *identifier = @"TableSampleIdentifier";
 
     InformationCell *cell = [[InformationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    
    if (cell == nil) {
        cell = cell;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
    }else{
        
        cell = [[InformationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
    }

    
    
//    if (section==0 && row==0) {
//        cell.textLabel.text =NSLocalizedString(@"personalInformation.profilePhoto",@"action");
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.textLabel.text = @"通知显示消息详情";
//        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
//        cell.detailTextLabel.textColor = [UIColor grayColor];
//        [cell.detailTextLabel setNumberOfLines:3];//可以显示3行
//        cell.detailTextLabel.text = @"若关闭，当收到邦邦社区消息时，通知提示将不显示发言人和内容摘要。";
//        
//    }
//    else
    
        if (section ==0 && row==0) {
        cell.LeftText= @"声音";
        stSound=[[UISwitch alloc]initWithFrame:CGRectMake(KCurrWidth-70, 6, 50, 20)];
        [stSound setOn:YES];
        
        [stSound addTarget:self action:@selector(switchSound) forControlEvents:UIControlEventValueChanged];
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Sound_Play_Mark"] isEqualToString:@"play"]) {
            [stSound setOn:YES];
        }else if([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Sound_Play_Mark"] isEqualToString:@"stop"]){
            [stSound setOn:NO];
        }
        
        [cell addSubview:stSound];
        
    }else if(section==0 && row==1) {
        cell.LeftText = @"振动";
        stVibration=[[UISwitch alloc]initWithFrame:CGRectMake(KCurrWidth-70, 6, 50, 20)];
        [stVibration addTarget:self action:@selector(switchVibration) forControlEvents:UIControlEventValueChanged];
        [stVibration setOn:YES];
 
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Vibrate_Play_Mark"] isEqualToString:@"play"]) {
            [stVibration setOn:YES];
        }else if([[[NSUserDefaults standardUserDefaults] stringForKey:@"NSUD_Vibrate_Play_Mark"] isEqualToString:@"stop"]){
            [stVibration setOn:NO];
        }
        
        [cell addSubview:stVibration];


    //}else if (section==1 && row==0){
    //    cell.textLabel.text = @"聊天背景";
    //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //    cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];

    //    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    //    cell.detailTextLabel.textColor = [UIColor grayColor];
    //    [cell.detailTextLabel setNumberOfLines:3];//可以显示3行
    //    cell.detailTextLabel.text = @"聊天背景将应用至全局，不会覆盖已经单独设置的聊天背景。";

        
    }else if (section==1 && row==0){
        cell.LeftText = @"听筒模式";
        handsFreeSwitch=[[UISwitch alloc]initWithFrame:CGRectMake(KCurrWidth-70, 6, 50, 20)];
        
        [handsFreeSwitch addTarget:self action:@selector(handsFreeSwitchSetting) forControlEvents:UIControlEventValueChanged];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL voice_play_mode_record = [[defaults objectForKey:kBool_Voice_Mode_Play_Record] boolValue];
        handsFreeSwitch.on =  voice_play_mode_record ? YES : NO;
        
        [cell addSubview:handsFreeSwitch];
        
    }else if (section==2 && row==0){
        cell.LeftText = @"社区ID";
        
        if (self.userInfo.accountName) {
            cell.RigitText = self.userInfo.accountName;
        }else {
            cell.RigitText = @"未设定";
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];

        
    }else if (section==2 && row==1){
        cell.LeftText = @"手机号";
        if (self.userInfo.phone.length <= 0 || !self.userInfo.phone) {
             cell.RigitText = @"未设定";
        }else{
            cell.RigitText = self.userInfo.phone;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];

    }else if (section==2 && row==2){
        cell.LeftText = @"邮箱";
        if(self.userInfo.accountType == 2){
            if (self.userInfo.email.length <= 0 || !self.userInfo.email) {
                cell.RigitText = @"未设定";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];

            } else {
                cell.RigitText = self.userInfo.email;
            }
        } else {
            if(self.userInfo.secondEmail.length <= 0 || !self.userInfo.secondEmail){
                cell.RigitText = @"未设定";
            } else {
                cell.RigitText = self.userInfo.secondEmail;
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];

        }
    }
    else if (section==2 && row==3){
        cell.LeftText = @"修改密码";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];

    }
    else if (section==2 && row==4){
        cell.LeftText = @"黑名单";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];

    }else if(section==3 && row==0){
        UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeleChatInfoTableViewCell"];
        cell.textLabel.textAlignment =NSTextAlignmentCenter;
        cell.textLabel.text = @"清除聊天记录";
        cell.textLabel.textColor = AB_Color_403b36;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return  cell;

    }
    

    return  cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (section==0 && row==0) {
    }else if (section==1 && row==0){
    }else if (section==2 && row==0){
        
    if (self.userInfo.accountName.length <= 0 || !self.userInfo.accountName) {
        
        AISetBBIdViewController *controller = [[AISetBBIdViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
        
        
    }else if(section==2 && row==1){
        if (self.userInfo.phone.length > 0) {
//            NSString *msg = [NSString stringWithFormat:@"%@%@%@%@",NSLocalizedString(@"personalInformation.phoneBindingMsg",@"message"),[[NSUserDefaults standardUserDefaults]stringForKey:@"phone" ],@",",NSLocalizedString(@"personalInformation.phoneBindingMsg2",@"message")];
//            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"public.alert.no",@"action"),NSLocalizedString(@"public.alert.yes",@"action"),nil];
//            alertView.tag=1004;
//            [alertView show];
            AIUnbindPhoneViewController *controller = [[AIUnbindPhoneViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        

        }else{
            //手机号绑定
//            PhoneNumViewController*phoneBindingVC=[[PhoneNumViewController alloc]init];
//            [self.navigationController pushViewController:phoneBindingVC animated:YES];
            
            AIBindPhoneViewController *controller = [[AIBindPhoneViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }

    }else if (section==2 && row==2){
        
//        if (self.userInfo.email.length == 0 || !self.userInfo.email) {
        /*
//            if ([@"false" isEqualToString:[[NSUserDefaults standardUserDefaults]stringForKey:@"activated"]]) {
//                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"personalInformation.emailBindingMsg",@"message") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"personalInformation.rebindEmail",@"action"),NSLocalizedString(@"public.alert.yes",@"action"),nil];
//                alert.tag=1005;
//                [alert show];
//                //[alert release];
//            }else{
//                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"personalInformation.emailBindingMsg2",@"message") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"public.alert.no",@"action"),NSLocalizedString(@"public.alert.yes",@"action"),nil];
//                alertView.tag=1003;
//                [alertView show];
//                // [alertView release];
//            }
         */
//            AIBindEmailViewController *controller = [[AIBindEmailViewController alloc] init];
//            [self.navigationController pushViewController:controller animated:YES];
//        }
        
        
        if (self.userInfo.accountType != 2) {
            if (self.userInfo.secondEmail.length <= 0 || !self.userInfo.secondEmail) {
                
                AIBindEmailViewController *controller = [[AIBindEmailViewController alloc] init];
                [self.navigationController pushViewController:controller animated:YES];
            }
            else {
                AIUnbindEmailController *controller = [[AIUnbindEmailController alloc] init];
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
        
    }else if(section==2 && row==3){
        
//        if (self.userInfo.secondEmail.length == 0 || !self.userInfo.secondEmail) {
//            
//            AIBindEmailViewController *controller = [[AIBindEmailViewController alloc] init];
//            [self.navigationController pushViewController:controller animated:YES];
//            
//        }else {
//            
//            AIUnbindEmailController *controller = [[AIUnbindEmailController alloc] init];
//            [self.navigationController pushViewController:controller animated:YES];
//        }
        
        AIChangePasswordController *controller = [[AIChangePasswordController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];

    }else if (section == 2 && row == 4) {
        
        AIChangePasswordController *controller = [[AIChangePasswordController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }else if (section == 3 && row == 0) {
        
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

    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSUInteger section = [indexPath section];
//    
//    if (section ==0 && indexPath.row==0){
//        return 69;
//    }else
    
//    if(section ==1 && indexPath.row==0){
//        return 69;
//    }
    return 44;
}

#pragma mark -UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1003&&buttonIndex==1) {
        EmailViewController *emailView=[[EmailViewController alloc]init];
        [self.navigationController pushViewController:emailView animated:YES];
    }
    else if (alertView.tag==1004&&buttonIndex==1){
        PhoneNumViewController *phoneNumView=[[PhoneNumViewController alloc]init];
        [self.navigationController pushViewController:phoneNumView animated:YES];
    }else if (alertView.tag==1005&&buttonIndex==1){
        [self sendsRequset];
    }else if (alertView.tag==1005&&buttonIndex==0){
        EmailViewController *emailView=[[EmailViewController alloc]init];
        [self.navigationController pushViewController:emailView animated:YES];
    }
}

-(void)sendsRequset{
    /*<iq type=”set”>
     <query xmlns=”http://www.nihualao.com/xmpp/bind”>
     <bind email=”需绑定的邮箱”/> </query>
     </iq>*/
    NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/bind"];
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    NSXMLElement *bind=[NSXMLElement elementWithName:@"bind"];
    [bind addAttributeWithName:@"email" stringValue:[[NSUserDefaults standardUserDefaults]stringForKey:@"email"]];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"bindingEmails"];
    [queryElement addChild:bind];
    [iq addChild:queryElement];
    //    NSLog(@"%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
}

-(void)sendsSuccess{
    
    //    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"bindingEmails_ok" object:nil];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"personalInformation.sendEmailMsg",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
    [alert show];
}

- (void)handsFreeSwitchSetting
{
    /*
    if (handsFreeSwitch.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"play" forKey:@"NSUD_Sound_Play_Mark"];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"stop" forKey:@"NSUD_Sound_Play_Mark"];
    }
     */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *ret = [NSNumber numberWithBool:handsFreeSwitch.on];
    [defaults setObject:ret forKey:kBool_Voice_Mode_Play_Record];
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

-(void)deleteChatMsg{
     //删除单聊
    [ChatMessageCRUD deleteAllChatMessage:MY_USER_NAME];
    //删除群聊
    [GroupChatMessageCRUD deleteAllGroupChatWithMyJid:MY_JID];
    //删除系统
    [SystemMessageCRUD deleteAllSytemMessage];
    //删除音频
    [ChatBuddyCRUD deleteChatBuddy];
    //删除录音
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray* jidArr = [UserInfoCRUD queryUserInfoForJid];
    for (NSString* jid in jidArr) {
        NSString *chatWithUserName = @"";
        NSString*str_character = @"@";
        NSRange senderRange = [jid rangeOfString:str_character];
        if ([jid rangeOfString:str_character].location != NSNotFound) {
            chatWithUserName = [jid substringToIndex:senderRange.location];
        }
        NSString *videoDir = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), chatWithUserName];
        if([fileManager fileExistsAtPath:videoDir]){
            [fileManager removeItemAtPath:videoDir error:nil];
        }
       
    }
    

    
}


@end
