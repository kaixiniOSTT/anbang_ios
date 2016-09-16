//
//  AIPerssionSettingViewController.m
//  anbang_ios
//
//  Created by rooter on 15-4-8.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIPerssionSettingViewController.h"
#import "AISetBackupNameViewController.h"
#import "ContactsCRUD.h"
#import "DejalActivityView.h"
#import "AICurrentContactController.h"
#import "AIPersonalCard.h"
#import "AINavigationController.h"
#import "MJExtension.h"
#import "ChatViewController2.h"
#import "GroupChatViewController2.h"
#import "AIHttpTool.h"
#import "AIFriendPrivilegeCRUD.h"

@interface AIPerssionSettingViewController () <XMPPRosterDelegate>

@end

@implementation AIPerssionSettingViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_Delete_Friend_Success" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self setupController];
    [self setupInterface];
    [self setupNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupController {
    
    self.title = @"权限设置";
}

- (void)setupNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(success:) name:@"AI_Delete_Friend_Success" object:nil];
}
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setupInterface {
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(back)]];
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 60)];
    view.userInteractionEnabled = YES;
    
    CGFloat w = view.frame.size.width - MARGIN_LEFT_RIGHT * 2;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(MARGIN_LEFT_RIGHT, 10, w, 45);
    button.titleLabel.font = AB_FONT_16;
    [button setTitle:@"删除好友" forState:UIControlStateNormal];
    [button setTitleColor:AB_White_Color forState:UIControlStateNormal];
    button.backgroundColor = AB_Red_Color;
    button.layer.cornerRadius = 6.0;
    [button addTarget:self action:@selector(deleteFriend) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    CGRect rect = CGRectMake(0, 0, Screen_Width, Screen_Height);
    UITableView *tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    tableView.backgroundColor = Controller_View_Color;
    tableView.separatorColor = AB_Color_f4f0eb;
    tableView.scrollEnabled = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 50;
    tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    tableView.tableFooterView = view;
    [self.view addSubview:tableView];
    mTableView = tableView;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark
#pragma mark Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch (section) {
        case 0:
        case 1:
            rows = 1;
            break;
        
        case 2:
            rows = 2;
            break;
            
        default:
            break;
    }
      return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Friend_Setting_Detail_Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = AB_FONT_16;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.section == 2) {
            UISwitch *switchControl = [[UISwitch alloc] init];
            switchControl.frame = CGRectMake(0, 0, 70, 30);
            switch (indexPath.row) {
                case 0: {
                    NSString *isOn = [AIFriendPrivilegeCRUD valueWithColumnKey:kPrivilegeColumnMyCircleLock
                                                                         whose:self.jid];
                    switchControl.on = [isOn boolValue];
                    [switchControl addTarget:self
                                      action:@selector(notAllowedToShowMine:)
                            forControlEvents:UIControlEventValueChanged];
                }
                    break;
                case 1: {
                    NSString *isOn = [AIFriendPrivilegeCRUD valueWithColumnKey:kPrivilegeColoumnHisCircleMark
                                                                         whose:self.jid];
                    switchControl.on = [isOn boolValue];
                    [switchControl addTarget:self
                                      action:@selector(dontShowHis:)
                            forControlEvents:UIControlEventValueChanged];
                }
                    break;
                    
                default:
                    break;
            }
            cell.accessoryView = switchControl;
        }
    }
    cell.textLabel.textColor = AB_Color_403b36;
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"设置备注";
            break;
        case 1:
            cell.textLabel.text = @"把他推荐给朋友";
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"不让他看我的朋友圈";
                    break;
                
                case 1:
                    cell.textLabel.text = @"不看他的朋友圈";
                    break;
                    
                default:
                    break;
            }
        default:
            break;
    }
    
    return cell;
}

#pragma mark
#pragma mark Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0: {
                    UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
                    item.title = @"";
                    self.navigationItem.backBarButtonItem = item;
                    
                    AISetBackupNameViewController *c = [[AISetBackupNameViewController alloc] init];
                    c.jid = self.jid;
                    [self.navigationController pushViewController:c animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 1: {
            AICurrentContactController *controller = [[AICurrentContactController alloc] init];
            UIViewController *superViewController = self.navigationController.viewControllers[1];
            if ([superViewController isKindOfClass:[ChatViewController2 class]]) {
                ChatViewController2 *chat = (ChatViewController2 *)superViewController;
                controller.fromUserName = chat.chatWithUser;
                controller.delegate = chat;
            }else if([superViewController isKindOfClass:[GroupChatViewController2 class]]) {
                GroupChatViewController2 *group = (GroupChatViewController2 *)superViewController;
                controller.fromUserName = group.roomName;
                controller.delegate = group;
            }
            
            AIPersonalCard * card = [[AIPersonalCard alloc] initWithJID:self.jid];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:card.keyValues options:NSJSONWritingPrettyPrinted error:nil];
            NSString *text = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSArray *array = @[@{@"text" : text, @"subject" : @"card"}];
            controller.messages = array;
            AINavigationController *navigation = [[AINavigationController alloc] initWithRootViewController:controller];
            [self presentViewController:navigation animated:YES completion:nil];
        }
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}


- (void)deleteFriend
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRemoveRequesrt];
    });
    
    [self loadViewShow];
}

- (void)sendRemoveRequesrt
{
    // <iq type="set" id="abfea">
    //     <query xmlns="jabber:iq:roster">
    //         <item subscription="remove" jid="10003@ab-insurance.com"/>
    //     </query>
    // </iq>
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"AI_Delete_Friend"];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"subscription" stringValue:@"remove"];
    [item addAttributeWithName:@"jid" stringValue:self.jid];
    
    [query addChild:item];
    [iq addChild:query];
    
    [[XMPPServer xmppStream] sendElement:iq];
    
    JLLog_I(@"delete friend req=%@", iq);
}

- (void)success:(NSNotification *)n
{
    [self loadViewHide];
    
    NSString *s = [n object];
    
    if ([@"yes" isEqualToString:s]) {
        
        [ContactsCRUD deleteContactsByChatUserName:self.jid];
        [self tipViewShow:@"删除好友成功"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [self tipViewShow:@"删除失败，请稍后重试"];
    }
    
}

- (void)loadViewShow
{
    [self.view endEditing:YES];
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)loadViewHide
{
    [self.view endEditing:NO];
    [DejalBezelActivityView removeViewAnimated:YES];
}

- (void)tipViewShow:(NSString *)tip
{
    JLTipsView *t = [[JLTipsView alloc] initWithTip:tip];
    [t showInView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

#pragma mark Actions

- (void) notAllowedToShowMine:(UISwitch *)aSwitch
{
    NSString *friendCircle = [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUD_FRIENDCIRCLE_ADDRESS"];
    NSString *userdest = [self.jid componentsSeparatedByString:@"@"][0];
    NSMutableString *urlString = [NSMutableString string];
    [urlString appendString:[NSString stringWithFormat:@"%@%@",friendCircle, @"privilege"]];
    [urlString appendString:@"?"];
    [urlString appendFormat:@"usersrc=%@&", MY_USER_NAME];
    [urlString appendFormat:@"userdest=%@&", userdest];
    [urlString appendString:@"pritype=1&"];
    [urlString appendFormat:@"privalue=%d", aSwitch.on];

    
    NSString *URLString = [NSString stringWithFormat:@"%@?usersrc=%@&userdest=%@&pritype=1&privalue=%d",
                           AIFriendCirclePrivilegeURLString, MY_USER_NAME, userdest, aSwitch.on];
//    NSMutableString *urlString = [NSMutableString string];
//    [urlString appendString:AIFriendCirclePrivilegeURLString];
//    [urlString appendString:@"?"];
//    [urlString appendFormat:@"usersrc=%@&", MY_USER_NAME];
//    [urlString appendFormat:@"userdest=%@&", userdest];
//    [urlString appendString:@"pritype=1&"];
//    [urlString appendFormat:@"privalue=%d", aSwitch.on];
    
    [AIHttpTool getWithURL:URLString
                    params:nil
                   success:^(id json) {
                       [AIFriendPrivilegeCRUD setValue:[NSString stringWithFormat:@"%d", aSwitch.on]
                                         withColumnKey:kPrivilegeColumnMyCircleLock
                                                 whose:self.jid];
                       
                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                           message:json[@"data"]
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"确定"
                                                                 otherButtonTitles:nil, nil];
                       [alertView show];
                       
                   } failure:^(NSError *error) {
                       
                   }];
}

- (void)dontShowHis:(UISwitch *)aSwitch
{
    NSString *friendCircle = [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUD_FRIENDCIRCLE_ADDRESS"];
    NSString *userdest = [self.jid componentsSeparatedByString:@"@"][0];
    NSString *URLString = [NSString stringWithFormat:@"%@?usersrc=%@&userdest=%@&pritype=0&privalue=%d",
                           AIFriendCirclePrivilegeURLString, MY_USER_NAME, userdest, aSwitch.on];
    
    
//    NSMutableString *urlString = [NSMutableString string];
//    [urlString appendString:AIFriendCirclePrivilegeURLString];
//    [urlString appendString:@"?"];
//    [urlString appendFormat:@"usersrc=%@&", MY_USER_NAME];
//    [urlString appendFormat:@"userdest=%@&", userdest];
//    [urlString appendString:@"pritype=0&"];
//    [urlString appendFormat:@"privalue=%d", aSwitch.on];

    NSMutableString *urlString = [NSMutableString string];
    [urlString appendString:[NSString stringWithFormat:@"%@%@",friendCircle, @"privilege"]];
    [urlString appendString:@"?"];
    [urlString appendFormat:@"usersrc=%@&", MY_USER_NAME];
    [urlString appendFormat:@"userdest=%@&", userdest];
    [urlString appendString:@"pritype=0&"];
    [urlString appendFormat:@"privalue=%d", aSwitch.on];
    
    [AIHttpTool getWithURL:URLString
                    params:nil
                   success:^(id json) {
                       [AIFriendPrivilegeCRUD setValue:[NSString stringWithFormat:@"%d", aSwitch.on]
                                         withColumnKey:kPrivilegeColoumnHisCircleMark
                                                 whose:self.jid];
                       
                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                           message:json[@"data"]
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"确定"
                                                                 otherButtonTitles:nil, nil];
                       [alertView show];
                       
                   } failure:^(NSError *error) {
                       
                   }];
}

@end
