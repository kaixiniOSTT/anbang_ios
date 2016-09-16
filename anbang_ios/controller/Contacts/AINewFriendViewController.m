//
//  AINewFriendViewController.m
//  anbang_ios
//
//  Created by rooter on 15-6-16.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AINewFriendViewController.h"
#import "AINewFriendsCRUD.h"
#import "AINewFriendCell.h"
#import "MBProgressHUD.h"
#import "AIControllersTool.h"
#import "UserInfo.h"
#import "ContactInfo.h"
#import "UserInfoCRUD.h"

@interface AINewFriendViewController ()<UITableViewDataSource, UITableViewDelegate, AINewFriendCellDelegate>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIButton *rightBarButton;
@end

@implementation AINewFriendViewController {
    NSMutableArray *_newFriends;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self removeNotifications];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // update read status flag @"1"
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [AINewFriendsCRUD updateReadStatuses];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // setup notifications
    [self setupNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationItem];
    [self setupInterface];
    [self setupDatasource];
}

- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setupNavigationItem {
    self.title = @"新的朋友";
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"通讯录"
                                                                                   target:self
                                                                                   action:@selector(pop)]];
    
    UIButton *other = [UIButton buttonWithType:UIButtonTypeCustom];
    other.frame = CGRectMake(0, 0, 40, 30);
    other.titleLabel.font = [UIFont systemFontOfSize:16];
    [other setTitle:@"编辑" forState:UIControlStateNormal];
    other.titleLabel.font = [UIFont systemFontOfSize:18];
    [other addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * right = [[UIBarButtonItem alloc] initWithCustomView:other];
    self.rightBarButton = other;
    self.navigationItem.rightBarButtonItems = @[right];
}

- (void)setupInterface {
    UITableView *t = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height - Both_Bar_Height) style:UITableViewStylePlain];
    t.dataSource = self;
    t.delegate = self;
    t.separatorColor = Buddy_Table_Separator_color;
    t.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:t];
    self.tableView = t;
    self.view.backgroundColor = AB_Color_f6f2ed;
    self.tableView.backgroundColor = AB_Color_f6f2ed;
}

- (void)setupDatasource {
    _newFriends = [[AINewFriendsCRUD requestItems] mutableCopy];
}

- (void)setupNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(refreshStatus)
                   name:@"AI_New_Friend_Acception_Return"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(acceptionError)
                   name:@"AI_New_Friend_Acception_Error"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(contactInfoReturn:)
                   name:@"AI_Contact_Info_Return"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(contactInfoError:)
                   name:@"AI_Contact_Info_Error"
                 object:nil];
}

- (void)removeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:@"AI_New_Friend_Acception_Return"
                    object:nil];
    [center removeObserver:self
                      name:@"AI_New_Friend_Acception_Error"
                    object:nil];
    [center removeObserver:self
                      name:@"AI_Contact_Info_Return"
                    object:nil];
    [center removeObserver:self
                      name:@"AI_Contact_Info_Error"
                    object:nil];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _newFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AINewFriendCell *cell = [AINewFriendCell cellForTableView:tableView];
    cell.item = _newFriends[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AINewFriendCell cellHeight];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

-   (void)tableView:(UITableView *)tableView
 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
  forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [AINewFriendsCRUD deleteAItem:_newFriends[indexPath.row]];
        [_newFriends removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)refreshTableView {
    _newFriends = [[AINewFriendsCRUD requestItems] mutableCopy];
    [self.tableView reloadData];
}

- (void)accessoryButtonBeenTappedInCell:(AINewFriendCell *)newFriendCell {
    [self sendAcceptionIQ:newFriendCell.item.requester action:@"1"];
}

- (void)iconViewBeenTappedInCell:(AINewFriendCell *)newFriendCell {
    NSString *jid = [NSString stringWithFormat:@"%@@%@", newFriendCell.item.requester, OpenFireHostName];
    int count = [UserInfoCRUD queryUserInfoTableCountId:jid myJID:MY_JID];
    if (count == 0) {
        [self sendContactInfoIQ:newFriendCell.item.requester];
    }else {
        UserInfo *userInfo = [UserInfoCRUD queryUserInfo:jid myJID:MY_JID];
        ContactInfo* contactinfoVC = [[ContactInfo alloc] initWithNibName:@"ContactInfo" bundle:[NSBundle mainBundle]];
        contactinfoVC.jid = jid;
        contactinfoVC.userinfo = userInfo;
        contactinfoVC.rightBarButtonHidden = YES;
        [self.navigationController pushViewController:contactinfoVC animated:YES];
    }
}

- (void)sendContactInfoIQ:(NSString *)requester {
    NSString *jid = [NSString stringWithFormat:@"%@@%@", requester, OpenFireHostName];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"id"
                     stringValue:@"AI_Contact_Info"];
        [iq addAttributeWithName:@"type"
                     stringValue:@"get"];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query"
                                                      xmlns:kUserInfoNameSpace];
        NSXMLElement *user = [NSXMLElement elementWithName:@"user"];
        [user addAttributeWithName:@"jid"
                       stringValue:jid];
        
        [query addChild:user];
        [iq addChild:query];
        
        JLLog_I(@"Contact info=%@", iq);
        [[XMPPServer xmppStream] sendElement:iq];
    });
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self performSelector:@selector(afterDelay) withObject:nil afterDelay:60.0];
}


- (void)sendAcceptionIQ:(NSString *)requester action:(NSString *)action {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"id"
                     stringValue:@"AI_New_Friend_Acception"];
        [iq addAttributeWithName:@"type"
                     stringValue:@"set"];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query"
                                                      xmlns:kXmppValidateNameSpace];
        NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
        [item addAttributeWithName:@"requester"
                       stringValue:requester];
        [item addAttributeWithName:@"action"
                       stringValue:action];
        
        [query addChild:item];
        [iq addChild:query];
        JLLog_I(@"%@", iq);
        [[XMPPServer xmppStream] sendElement:iq];
    });
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self performSelector:@selector(afterDelay) withObject:nil afterDelay:60.0];
}

- (void)contactInfoReturn:(NSNotification *)notification {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSDictionary *dict = notification.userInfo;
    UserInfo *userinfo = dict[@"result"];
    ContactInfo* contactinfoVC = [[ContactInfo alloc] init];
    contactinfoVC.jid = userinfo.jid;
    contactinfoVC.userinfo = userinfo;
    contactinfoVC.rightBarButtonHidden = YES;
    [self.navigationController pushViewController:contactinfoVC animated:YES];
}

- (void)contactInfoError:(NSNotification *)notification {
    [self errorReport];
}

- (void)edit:(UIButton *)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    NSString *title = self.tableView.editing ? @"取消" : @"编辑";
    [sender setTitle:title forState:UIControlStateNormal];
}

- (void)refreshStatus {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self refreshTableView];
}

- (void)acceptionError {
    [self errorReport];
}

- (void)errorReport {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [AIControllersTool tipViewShow:@"服务器出错"];
}

- (void)afterDelay {
    MBProgressHUD *hub = [MBProgressHUD HUDForView:self.view];
    if (hub) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [AIControllersTool tipViewShow:@"请求超时，请稍后重试"];
    }
}

@end
