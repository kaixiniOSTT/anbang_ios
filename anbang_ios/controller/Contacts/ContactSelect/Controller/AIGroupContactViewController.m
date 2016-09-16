//
//  AIGroupContactViewController.m
//  anbang_ios
//
//  Created by rooter on 15-5-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIGroupContactViewController.h"
#import "AIGroupCell.h"
#import "GroupCRUD.h"
#import "NSString+Chinese.h"
#import "StrUtility.h"
#import "AIMessageSendAssisstant.h"

@interface AIGroupContactViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate,UISearchDisplayDelegate>
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UISearchBar *searchBar;
@end

@implementation AIGroupContactViewController {
    
    UISearchDisplayController *searchDisplayController;
    
    NSMutableArray *searchResults;
    NSArray *mGroups;
    NSDictionary *mSelectedGroup;
}

#pragma mark
#pragma mark private

- (BOOL)isSelfTableView:(UITableView *)tableView {
    return tableView == self.tableView ? YES : NO;
}

-(NSMutableArray*) queryAllGroupsWithAvatarAndName
{
    NSMutableArray *result = [NSMutableArray array];
    NSMutableArray *origins = [GroupCRUD queryAllChatGroupByMyJID:MY_JID];
    for(NSDictionary *origin in origins){
        NSMutableDictionary *new = [NSMutableDictionary dictionaryWithDictionary:origin];
        
        NSMutableArray *groupMembersArray = [NSMutableArray arrayWithArray: origin[@"groupMembersArray"]];
        NSString *groupName = origin[@"groupName"];
        NSString *groupTempName = @"";
        NSMutableArray *avatarArray = [NSMutableArray array];
        
        int groupMembersCount = groupMembersArray.count;
        
        if (groupMembersCount>9) {
            groupMembersCount=9;
        }
        
        for (int i=0; i<groupMembersCount; i++) {
            NSDictionary *groupDic = [groupMembersArray objectAtIndex:i];
            if ([StrUtility isBlankString:groupName] || [@"(null)" isEqualToString:groupName]) {
                if(i==0){
                    groupTempName = [NSString stringWithFormat:@"%@%@",groupTempName, [groupDic objectForKey:@"nickName"]];
                }else{
                    groupTempName = [NSString stringWithFormat:@"%@,%@",groupTempName, [groupDic objectForKey:@"nickName"]];
                }
                
            }
            
            [avatarArray addObject:[groupDic objectForKey:@"avatar"]];
        }
        
        new[@"groupTempName"] = [StrUtility string:groupName defaultValue: groupTempName];
        new[@"avatarArray"] = avatarArray;
        
        [result addObject:new];
    }
    
    return result;
}

#pragma end

#pragma mark
#pragma mark actions

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma end

#pragma mark
#pragma mark setup

- (void)setupController {
    mGroups = [self queryAllGroupsWithAvatarAndName];
    JLLog_I(@"groups=%@", mGroups);
}

- (void)setupNavigationItem {
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(back)]];
}

- (void)setupInterface {
    self.view.backgroundColor = Controller_View_Color;
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.bounds = CGRectMake(0, 0, Screen_Width, 40);
    searchBar.delegate = self;
    [searchBar setPlaceholder:NSLocalizedString(@"chat.search",@"action")];
    searchBar.keyboardType=UIKeyboardTypeNamePhonePad;
    searchBar.barTintColor = [UIColor colorFromHexString:@"#e7e2dd"];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Both_Bar_Height);
    tableView.separatorColor = Buddy_Table_Separator_color;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableHeaderView = searchBar;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.sectionIndexColor = AB_Gray_Color;
    if (IS_iOS7) {
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    [self.view addSubview:tableView];
    
    self.searchBar = searchBar;
    self.tableView = tableView;
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                                                contentsController:self];
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
}

#pragma end


#pragma mark
#pragma mark controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationItem];
    [self setupController];
    [self setupInterface];
}

#pragma end

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDatasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the sections
    if ([self isSelfTableView:tableView]) {
        return mGroups.count;
    }
    return searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AIGroupCell *cell = [AIGroupCell cellWithTableView:tableView];
    NSDictionary *group = nil;
    if ([self isSelfTableView:tableView]) {
        group = [mGroups objectAtIndex:indexPath.row];
    }else{
        group = [searchResults objectAtIndex:indexPath.row];
    }
    cell.group = group;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [AIGroupCell cellHeight];
}

-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    BOOL fromSelf = tableView == self.tableView ? YES : NO;
    NSArray *datasource = fromSelf ? mGroups : searchResults;
    mSelectedGroup = datasource[indexPath.row];
    NSString *groupName = mSelectedGroup[@"groupName"];
    NSString *name = [StrUtility isBlankString:groupName] ? @"群聊" : groupName;
    NSString *tip = [NSString stringWithFormat:@"是否转发到\"%@\"", name];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:tip
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma end

#pragma mark
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (!searchResults) {
        searchResults = [NSMutableArray array];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchResults removeAllObjects];
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    
    [searchResults removeAllObjects];
    if (!searchText || [searchText isEqualToString:@""]) return;
    
    NSString *search_format = [[searchText transformToPinyin] lowercaseString];
    for (NSDictionary *group in mGroups) {
        NSString *format_01 = [[group[@"name"] transformToPinyin] lowercaseString];
        NSString *format_02 = [[group[@"groupTempName"] transformToPinyin] lowercaseString];
        
        if ([format_01 hasPrefix:search_format] || [format_02 hasPrefix:search_format]) {
            [searchResults addObject:group];
        }
    }
    [searchDisplayController.searchResultsTableView reloadData];
}

#pragma end

#pragma mark
#pragma mark UIAlertViewDelegate

-    (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            mSelectedGroup = nil;
            break;
            
        case 1: {
            NSMutableDictionary *contact = [NSMutableDictionary dictionary];
            [contact setObject:mSelectedGroup[@"groupMucId"] forKey:@"userName"];
            [contact setObject:@"groupchat" forKey:@"type"];
            [self.assisstant sendMessagesTo:contact];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

#pragma end

@end
