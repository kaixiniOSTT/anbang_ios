//
//  AISearchContactViewController.m
//  anbang_ios
//
//  Created by rooter on 15-7-16.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AISearchContactViewController.h"
#import "PublicCURD.h"
#import "AIContactCell.h"
#import "StrUtility.h"
#import "ChatViewController2.h"
#import "GroupChatViewController2.h"
@interface AISearchContactViewController () <UITableViewDataSource,
                                             UITableViewDelegate,
                                             UISearchDisplayDelegate,
                                             UISearchBarDelegate>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation AISearchContactViewController
{
    NSArray         *_contacts;
    NSMutableArray  *_searchResultSet;
    UISearchDisplayController *mSearchDisplayController;
}

- (void)dealloc {
    JLLog_D(@"<%@, %p> dealloc", [self class], self);
}



- (void)vc_setupNavigationItem
{
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(back)]];
}

- (void)vc_setupInterface
{
    //UISearchBar
    CGRect rect = CGRectMake(0, 0, Screen_Width, 40);
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.bounds = rect;
    searchBar.delegate = self;
    searchBar.barTintColor = SearchBar_Tint_Color;
    searchBar.placeholder = @"搜索";
    
    //UITableView
    UITableView *tableView = [[UITableView alloc] init];
    tableView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Both_Bar_Height);
    tableView.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableHeaderView = searchBar;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    //UISearchDisplayController
    mSearchDisplayController = [[UISearchDisplayController alloc]
                                  initWithSearchBar:searchBar contentsController:self];
    mSearchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    mSearchDisplayController.delegate = self;
    mSearchDisplayController.searchResultsDataSource = self;
    mSearchDisplayController.searchResultsDelegate = self;
}

#pragma mark
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = AB_Color_ffffff;
    [self vc_setupNavigationItem];
    [self vc_setupInterface];
}

#pragma mark
#pragma mark - Actions

- (void) back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _searchResultSet.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_searchResultSet[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AIContactCell *cell = [AIContactCell cellWithTableView:tableView];
    cell.contact = _searchResultSet[indexPath.section][indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [AIContactCell cellHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 30)];
    UIView *marginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 30)];
    
    view.backgroundColor = Controller_View_Color;
    marginView.backgroundColor =  Controller_View_Color;
    
    CGRect frame = CGRectMake(15, 0, Screen_Width - 15, 30);
    UILabel *label = [[UILabel alloc] init];
    label.frame = frame;
    label.font  = [UIFont systemFontOfSize:13.0];
    label.backgroundColor = Controller_View_Color;
    
    switch (section) {
        case 0:
            label.text = @"联系人";
            break;
            
        case 1:
            label.text = @"群聊";
            break;
            
        default:
            break;
    }
    
    [view addSubview:marginView];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *d = _searchResultSet[indexPath.section][indexPath.row];
    UIViewController *viewController = nil;
    NSString *type = d[@"type"];
    if ([type isEqualToString:@"chat"]) {
        ChatViewController2 * chatViewCtl=[[ChatViewController2 alloc] init];
        chatViewCtl.chatWithUser = [d[@"jid"] componentsSeparatedByString:@"@"][0];
        chatViewCtl.chatWithNick = d[@"name"];
        chatViewCtl.remarkName = d[@"name"];
        NSString *ChatWithJID = d[@"jid"];
        chatViewCtl.chatWithJID  = ChatWithJID;
        chatViewCtl.title = d[@"name"];
        viewController = chatViewCtl;
    }else {
        GroupChatViewController2 *groupChatCtl = [[GroupChatViewController2 alloc] init];
        NSString *chatUserName = d[@"groupMucId"];
        groupChatCtl.roomName = chatUserName;
        groupChatCtl.roomNickName = d[@"groupName"];
        viewController = groupChatCtl;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_completedBlock) {
        _completedBlock(viewController);
    }
}

#pragma mark
#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //set current data source (for search results table view)
    [self.searchDisplayController setActive:YES animated:YES];
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if(_searchResultSet == nil){
        _searchResultSet = [NSMutableArray array];
    }
}

- (void) searchBar:(UISearchBar *)searchBar
     textDidChange:(NSString *)searchText {
    
    if ([StrUtility isBlankString:searchText]) { return; }
    _searchResultSet = [[PublicCURD didSearchContactWithKeyword:searchText] mutableCopy];
    [self.tableView reloadData];
}
@end
