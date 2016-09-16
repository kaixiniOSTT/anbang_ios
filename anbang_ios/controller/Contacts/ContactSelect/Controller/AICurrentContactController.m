//
//  AICurrentContactController.m
//  anbang_ios
//
//  Created by rooter on 15-5-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AICurrentContactController.h"
#import "AIFriendsContactViewController.h"
#import "ChatBuddyCRUD.h"
#import "AIChatBuddyCell.h"
#import "UIImageView+WebCache.h"
#import "AIFriendContactCell.h"
#import "AIMessageSendAssisstant.h"
#import "NSString+Chinese.h"
#import "AIRemessage.h"
#import "StrUtility.h"
#import "BBTableViewCell.h"

@interface AICurrentContactController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate ,UIAlertViewDelegate>
@property (weak, nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) UITableView *tableView;
@end

@implementation AICurrentContactController
{
    NSArray         *mCurrentContacts;
    NSMutableArray  *mSearchResults;
    NSArray         *mSearchFormats;
    NSDictionary    *mSelectedContact;
    
    AIMessageSendAssisstant *mAssisstant;
    
    UISearchDisplayController *searchDisplayController;
}

#pragma mark
#pragma mark setter & getter

- (void)setMessages:(NSArray *)messages {
    mAssisstant = [[AIMessageSendAssisstant alloc] initWithFromUserName:self.fromUserName];
    mAssisstant.delegate = self.delegate;
    mAssisstant.messages = messages;
}

#pragma mark


#pragma mark
#pragma mark actions

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma end

#pragma mark
#pragma mark setup

- (NSArray *)currentContacts {
    NSMutableArray *currentContacts = [NSMutableArray array];
    NSArray *contacts = [ChatBuddyCRUD queryChatContactsList:MY_USER_NAME];
    for (NSDictionary *contact in contacts) {
        NSString *type = contact[@"type"];
        if ([type isEqualToString:@"chat"] || [type isEqualToString:@"groupchat"]) {
            [currentContacts addObject:contact];
        }
    }
    return currentContacts;
}

- (NSArray *)searchFormats {
    NSMutableArray *formats = [NSMutableArray array];
    for (NSDictionary *contact in mCurrentContacts) {
        NSMutableDictionary *recombine = [NSMutableDictionary dictionaryWithDictionary:contact];
        
        NSString *name = contact[@"name"];
        NSString *nickName = contact[@"nickName"] ? contact[@"nickName"] : @"";
        NSString *groupTempName = contact[@"groupTempName"] ? contact[@"groupTempName"] : @"";
        
        NSString *format_01 = [[name transformToPinyin] lowercaseString];
        NSString *format_02 = [[nickName transformToPinyin] lowercaseString];
        NSString *format_03 = [[groupTempName transformToPinyin] lowercaseString];
        
        //        JLLog_I(@"<format_01=%@, format_02=%@, format_03=%@>", format_01, format_02, format_03);
        if ([format_01 isEqualToString:@"gongzuotai"]) {
            continue;
        }
        
        [recombine setObject:format_01 forKey:@"format_01"];
        [recombine setObject:format_02 forKey:@"format_02"];
        [recombine setObject:format_03 forKey:@"format_03"];
        [formats addObject:recombine];
    }
    //    JLLog_I(@"formats.count=%d", formats.count);
    return formats;
}

- (void)setupController {
    mCurrentContacts = [self currentContacts];
    mSearchFormats = [self searchFormats];
}

- (void)setupNavigationItem {
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AITitleBarButtonItem alloc] initWithTitle:@"取消"
                                                                                    target:self
                                                                                    action:@selector(back)]];
}

- (void)setupInterface {
    self.view.backgroundColor = Controller_View_Color;
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.bounds = CGRectMake(0, 0, Screen_Width, 44);
    searchBar.delegate = self;
    [searchBar setPlaceholder:NSLocalizedString(@"chat.search",@"action")];
    searchBar.keyboardType=UIKeyboardTypeNamePhonePad;
    searchBar.barTintColor = [UIColor colorFromHexString:@"#e7e2dd"];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Both_Bar_Height);
    tableView.separatorColor = Buddy_Table_Separator_color;
    tableView.backgroundColor = AB_Color_f6f2ed;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableHeaderView = searchBar;
    tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableView];
    
    UITextField *txfSearchField = [searchBar valueForKey:@"_searchField"];
    txfSearchField.borderStyle = UITextBorderStyleRoundedRect;
    txfSearchField.layer.cornerRadius = 3.0f;
    txfSearchField.layer.masksToBounds = YES;
    txfSearchField.layer.borderWidth = .5;
    txfSearchField.layer.borderColor = [[UIColor colorWithRed:214.0f/255.0f green:200.0f/255.0f blue:179.0f/255.0f alpha:1.0f] CGColor];

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
#pragma mark controller live round

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupController];
    [self setupNavigationItem];
    [self setupInterface];
}

#pragma end

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/**
 *  Data source: mCurrentContact
 *  But index 1 for creating new chat
 *
 *  Returning mCurrentContact.count + 1;
 */
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return tableView == self.tableView ?  mCurrentContacts.count + 1 : mSearchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL fromSelf = tableView == self.tableView ? YES : NO;
    if (indexPath.row == 0 && fromSelf) {
        static NSString *firstCellID = @"Forward_To_Create_Chat_Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:firstCellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:firstCellID];
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = [UIColor colorFromHexString:@"#e7e2dd"];//Table_View_Cell_Selection_Color;
        }
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];
        cell.textLabel.text = @"创建新聊天";
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = [UIColor colorFromHexString:@"#5b5752"];//AB_Color_403b36;
        return cell;
    }else {
        NSDictionary *contactsDic = fromSelf ? mCurrentContacts[indexPath.row - 1] : mSearchResults[indexPath.row];
        BBTableViewCell *cell = [BBTableViewCell cellWithTableView:self.tableView];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
        cell.timeLabel.text = @"";
        cell.detailTextLabel.text = @"";
        cell.abIcon.hidden = YES;
        cell.dndIcon.hidden = YES;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = [UIColor colorFromHexString:@"#5b5752"];
        NSString *type = contactsDic[@"type"];
        NSString *name = contactsDic[@"name"];
        NSString *nickName = contactsDic[@"nickName"];
        
        if ([type isEqualToString:@"groupchat"]) {
            cell.groupMemebers = contactsDic[@"groupMembersArray"];
            cell.abIcon.hidden = [@"department" isEqualToString:contactsDic[@"groupType"]] ? NO : YES;
            NSString *groupTempName = contactsDic[@"groupTempName"];
            cell.groupMemebers = contactsDic[@"groupMembersArray"];
            cell.textLabel.text = [StrUtility string:name defaultValue:nickName];
            cell.textLabel.text = [StrUtility string:cell.textLabel.text defaultValue:groupTempName];
        }else {
            cell.abIcon.hidden = [contactsDic[@"accountType"] intValue] == 2 ? NO : YES;
            cell.textLabel.text = ![StrUtility isBlankString:name] ? name : nickName;
            NSString *avatar = contactsDic[@"avatar"];
            NSURL *url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", ResourcesURL, avatar]];
            [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
        }
        return cell;
    }
}

-    (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL fromSelf = (tableView == self.tableView) ? YES : NO;
    if (fromSelf) {
        return indexPath.row == 0 ? 47.0 : 42.0;
    }
    return 68.0;
}

-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BOOL fromSelf = tableView == self.tableView ? YES : NO;
    if (fromSelf && indexPath.row == 0) {
        AIFriendsContactViewController *controller = [[AIFriendsContactViewController alloc] init];
        controller.assisstant = mAssisstant;
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    NSInteger index = fromSelf ? indexPath.row - 1 : indexPath.row;
    NSArray *datasource = fromSelf ? mCurrentContacts : mSearchResults;
    NSDictionary *contact = datasource[index];
    mSelectedContact = contact;
    NSString *name = nil;
    NSString *type = contact[@"type"];
    if ([type isEqualToString:@"groupchat"]) {
        name = [StrUtility isBlankString:contact[@"name"]] ? @"群聊" : contact[@"name"];
    }else {
        name = contact[@"name"];
    }
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
    if (!mSearchResults) {
        mSearchResults = [NSMutableArray array];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [mSearchResults removeAllObjects];
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    [mSearchResults removeAllObjects];
    
    if (!searchText || [searchText isEqualToString:@""]) return;
    NSString *search_format = [[searchText transformToPinyin] lowercaseString];
    for (NSDictionary *contact in mSearchFormats) {
        
        NSString *format_01 = contact[@"format_01"];
        NSString *format_02 = contact[@"format_02"];
        NSString *format_03 = contact[@"format_03"];
        
        if ([format_01 hasPrefix:search_format] || [format_02 hasPrefix:search_format] || [format_03 hasPrefix:search_format]) {
            [mSearchResults addObject:contact];
        }
    }
    //    JLLog_I(@"result=%@", searchResults);
    [searchDisplayController.searchResultsTableView reloadData];
}


#pragma end

#pragma mark
#pragma mark UIAlertViewDelegate

-       (void)alertView:(UIAlertView *)alertView
   clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            mSelectedContact = nil;
            break;
        
        case 1: {
            // 这里的数据源格式和接着的好友通讯录跟群聊的数据格式不一样，为了复用assisstant， 统一格式
            NSMutableDictionary * recontact = [NSMutableDictionary dictionaryWithDictionary:mSelectedContact];
            if ([@"groupchat" isEqualToString:mSelectedContact[@"type"]]) {
                NSString *chatUserName = mSelectedContact[@"chatUserName"];
                [recontact setObject:chatUserName forKey:@"chatUserName"];
            }
            [recontact setObject:recontact[@"chatUserName"] forKey:@"userName"];
            [mAssisstant sendMessagesTo:recontact];
            [self back];
        }
            break;
            
        default:
            break;
    }
}

#pragma end

@end
