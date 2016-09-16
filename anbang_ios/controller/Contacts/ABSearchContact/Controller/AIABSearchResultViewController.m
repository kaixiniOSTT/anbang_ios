//
//  AIABSearchResultViewController.m
//  anbang_ios
//
//  Created by rooter on 15-5-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIABSearchResultViewController.h"
#import "AIABSearchContactCell.h"
#import "MJRefresh.h"
#import "AISearchAssistant.h"
#import "AIABSearchContact.h"
#import "AIControllersTool.h"
#import "AIControllersTool.h"
#import "ContactInfo.h"
#import "UserInfo.h"
#import "UserInfoCRUD.h"

@interface AIABSearchResultViewController()<MJRefreshBaseViewDelegate>
@property (nonatomic, strong) MJRefreshFooterView *footer;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation AIABSearchResultViewController

- (void)dealloc
{
    [self.footer free];
}

- (void)pop
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupNavigationItem
{
    self.title = @"安邦通讯录";
    self.view.backgroundColor = AB_Color_f6f2ed;
    
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                    target:self
                                                                                   action:@selector(pop)]];
}

- (void)setupInterface
{
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, Screen_Width, [AIABSearchContactCell cellHeight]);
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(15, 0, Screen_Width - 15, [AIABSearchContactCell cellHeight]);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = AB_FONT_15;
    headerLabel.textColor = AB_Color_9c958a;
    headerLabel.text = [NSString stringWithFormat:@"搜索结果：%@", self.assistant.searchKey];
    [headerView addSubview:headerLabel];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Both_Bar_Height);
    tableView.separatorColor = AB_Color_f4f0eb;
    tableView.backgroundColor = AB_Color_f6f2ed;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.tableHeaderView = headerView;
    [self.view addSubview:tableView];
    
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = tableView;
    footer.delegate = self;
    
    self.footer = footer;
    self.tableView = tableView;

}

- (void)setupNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(abContactReturn:) name:@"AI_AB_Contact_Search_Return" object:nil];
    [center addObserver:self selector:@selector(abContactReturnError:) name:@"AI_AB_Contact_Search_Error" object:nil];
    [center addObserver:self selector:@selector(abContactInfoReturn:) name:@"AI_Contact_Info_Return" object:nil];
    [center addObserver:self selector:@selector(abContactInfoError:) name:@"AI_Contact_Info_Error" object:nil];
}

- (void)tearNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:@"AI_AB_Contact_Search_Return" object:nil];
    [center removeObserver:self name:@"AI_AB_Contact_Search_Error" object:nil];
    [center removeObserver:self name:@"AI_Contact_Info_Return" object:nil];
    [center removeObserver:self name:@"AI_Contact_Info_Error" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavigationItem];
    [self setupInterface];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self tearNotifications];
}

#pragma mark
#pragma mark UITableView datesource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.employees.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AIABSearchContactCell *cell = [AIABSearchContactCell cellWithTableView:tableView];
    cell.contact = self.employees[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [AIABSearchContactCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AIABSearchContactCell *cell = (AIABSearchContactCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.canSelected) {
        AIABSearchContact *contact = (AIABSearchContact *)self.employees[indexPath.row];
        [self.assistant sendABContactInfoIQ:contact.userName];
        [AIControllersTool loadingViewShow:self];
    }
}

#pragma end

#pragma mark
#pragma mark MJRefreshBaseViewDelegate

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    self.assistant.after = [NSString stringWithFormat:@"%d", self.employees.count];
    [self.assistant sendSearchIQ];
}

#pragma end

#pragma mark
#pragma mark Notifications

- (void)abContactReturn:(NSNotification *)notify
{
    NSDictionary *userInfo = [notify userInfo];
    self.employees = [self.employees arrayByAddingObjectsFromArray:userInfo[@"result"]];
    [self.footer endRefreshing];
    [self.tableView reloadData];
}

- (void)abContactReturnError:(NSNotification *)notify
{
    [self.footer endRefreshing];
    [AIControllersTool tipViewShow:@"服务器出错，请稍后重试"];
}

- (void)abContactInfoReturn:(NSNotification *)notify
{
    [AIControllersTool loadingVieHide:self];
    NSDictionary *dict = [notify userInfo];
    UserInfo *userinfo = dict[@"result"];
    ContactInfo* contactinfoVC = [[ContactInfo alloc] init];
    [UserInfoCRUD addAnUserInfo:userinfo];
    contactinfoVC.jid = userinfo.jid;
    contactinfoVC.userinfo = userinfo;
    contactinfoVC.rightBarButtonHidden = YES;
    [self.navigationController pushViewController:contactinfoVC animated:YES];
}

- (void)abContactInfoError:(NSNotification *)notify
{
    [AIControllersTool loadingVieHide:self];
    [AIControllersTool tipViewShow:@"服务器出错，请稍后重试"];
}

#pragma end

@end
