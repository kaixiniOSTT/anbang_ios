//
//  AIFriendsContactViewController.m
//  anbang_ios
//
//  Created by rooter on 15-5-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIFriendsContactViewController.h"
#import "AIGroupContactViewController.h"
#import "ContactsCRUD.h"
#import "Contacts.h"
#import "ChineseString.h"
//#import "UIImageView+WebCache.h"
#import "StrUtility.h"
#import "AIFriendContactCell.h"
#import "NSString+Chinese.h"
#import "AIMessageSendAssisstant.h"

#define Cell_Icon_Tag 1335
#define Cell_Label_Tag 1333
#define Cell_ABIcon_Tag 1331

@interface AIFriendsContactViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate,UISearchDisplayDelegate>
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UISearchBar *searchBar;
@end

@implementation AIFriendsContactViewController {
    
    NSArray *mFriends;
    NSMutableArray *mSearchResults;
    NSMutableArray *mSectionIndexTitles;
    Contacts *mSelectedContact;
    UISearchDisplayController *searchDisplayController;
}

#pragma mark
#pragma mark private

- (BOOL)isSelfTableView:(UITableView *)tableView {
    return tableView == self.tableView ? YES : NO;
}

- (NSString *)userNameFromJID:(NSString *)jid {
    return [jid componentsSeparatedByString:@"@"][0];
}

- (NSMutableArray *)getChineseStringArr:(NSArray *)arrToSort {
    NSMutableArray *chineseStringsArray = [NSMutableArray array];
    for(int i = 0; i < [arrToSort count]; i++) {
        Contacts *contacts=[[Contacts alloc]init];
        NSDictionary *sortDic = [arrToSort objectAtIndex:i];
        contacts.string = [NSString stringWithString:[sortDic objectForKey:@"name"] ];
        
        NSString*str_character = @"@";
        NSString*chatUserName = @"";
        
        NSRange senderRange = [[sortDic objectForKey:@"userName"]  rangeOfString:str_character];
        
        if ([[sortDic objectForKey:@"userName"]  rangeOfString:str_character].location != NSNotFound) {
            chatUserName = [[sortDic objectForKey:@"userName"] substringToIndex:senderRange.location];
        }
        
        
        if ([[sortDic objectForKey:@"name"] isEqualToString:@""] || [[sortDic objectForKey:@"name"] isEqualToString:@"(null)"]) {
            contacts.string = [NSString stringWithString:[sortDic objectForKey:@"nickName"]];
        }else if([[sortDic objectForKey:@"nickName"] isEqualToString:@""] || [[sortDic objectForKey:@"name"] isEqualToString:@"(null)"]){
            contacts.string = chatUserName;
            
        }
        
        contacts.jid = [NSString stringWithString:[sortDic objectForKey:@"userName"] ];
        contacts.remarkName = [NSString stringWithString:[sortDic objectForKey:@"name"]];
        contacts.nickName = [NSString stringWithString:[sortDic objectForKey:@"nickName"]];
        contacts.avatar = [NSString stringWithString:[sortDic objectForKey:@"avatar"] ];
        contacts.accountType = [sortDic[@"accountType"] intValue];
        
        if(contacts.string==nil || [contacts.string isEqualToString:@""]){
            contacts.string=@"";
        }
        
        if(![contacts.string isEqualToString:@""]){
            //join the pinYin
            NSString *pinYinResult = [NSString string];
            for(int j = 0;j < contacts.string.length; j++) {
                NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c",
                                                 pinyinFirstLetter([contacts.string characterAtIndex:j])]uppercaseString];
                
                pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
            }
            contacts.pinYin = pinYinResult;
        } else {
            contacts.pinYin = contacts.jid;
            // continue;
        }
        [chineseStringsArray addObject:contacts];
        
    }
    
    //sort the ChineseStringArr by pinYin
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    
    NSMutableArray *arrayForArrays = [NSMutableArray array];
    BOOL checkValueAtIndex= NO;  //flag to check
    NSMutableArray *TempArrForGrouping = nil;
    
    for(int index = 0; index < [chineseStringsArray count]; index++)
    {
        ChineseString *chineseStr = (ChineseString *)[chineseStringsArray objectAtIndex:index];
        NSMutableString *strchar= [NSMutableString stringWithString:chineseStr.pinYin];
        //       NSLog(@"*******%@",[strchar substringToIndex:1]);
        
        NSString *sr= [strchar substringToIndex:1];
        // NSLog(@"%@",sr);        //sr containing here the first character of each string
        if(![mSectionIndexTitles containsObject:[sr uppercaseString]])//here I'm checking whether the character already in the selection header keys or not
        {
            [mSectionIndexTitles addObject:[sr uppercaseString]];
            TempArrForGrouping = [[NSMutableArray alloc] initWithObjects:nil];
            checkValueAtIndex = NO;
        }
        if([mSectionIndexTitles containsObject:[sr uppercaseString]])
        {
            [TempArrForGrouping addObject:[chineseStringsArray objectAtIndex:index]];
            if(checkValueAtIndex == NO)
            {
                if (TempArrForGrouping !=nil) {
                    [arrayForArrays addObject:TempArrForGrouping];
                }
                
                checkValueAtIndex = YES;
            }
        }
    }
    [mSectionIndexTitles insertObject:@" " atIndex:0];
    return arrayForArrays;
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
    mSectionIndexTitles = [NSMutableArray array];
    NSArray *tmp = [ContactsCRUD queryContactsListTwo:MY_JID];
    mFriends = [self getChineseStringArr:tmp];
//    JLLog_I(@"mfriends=%@", mFriends);
}

- (void)setupNavigationItem {
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(back)]];
}

- (void)setupInterface {
//    self.view.backgroundColor = Controller_View_Color;
//    
//    UISearchBar *searchBar = [[UISearchBar alloc] init];
//    searchBar.bounds = CGRectMake(0, 0, Screen_Width, 40);
//    searchBar.delegate = self;
//    [searchBar setPlaceholder:NSLocalizedString(@"chat.search",@"action")];
//    searchBar.keyboardType=UIKeyboardTypeNamePhonePad;
//    searchBar.barTintColor = [UIColor colorFromHexString:@"#e7e2dd"];
//    
//    UITableView *tableView = [[UITableView alloc] init];
//    tableView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Both_Bar_Height);
//    tableView.separatorColor = Buddy_Table_Separator_color;
//    tableView.backgroundColor = [UIColor clearColor];
//    tableView.dataSource = self;
//    tableView.delegate = self;
//    tableView.tableHeaderView = searchBar;
//    tableView.tableFooterView = [[UIView alloc] init];
//    tableView.sectionIndexColor = AB_Gray_Color;
//    if (IS_iOS7) {
//        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
//    }
//    [self.view addSubview:tableView];
//    
//    self.searchBar = searchBar;
//    self.tableView = tableView;
//    
//    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
//                                                                contentsController:self];
//    searchDisplayController.searchResultsDataSource = self;
//    searchDisplayController.searchResultsDelegate = self;
//    searchDisplayController.delegate = self;
//    searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    
    self.view.backgroundColor = Controller_View_Color;
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.bounds = CGRectMake(0, 0, Screen_Width, 44);
    searchBar.delegate = self;
    [searchBar setPlaceholder:NSLocalizedString(@"chat.search",@"action")];
    searchBar.keyboardType=UIKeyboardTypeNamePhonePad;
    searchBar.barTintColor = [UIColor colorFromHexString:@"#e7e2dd"];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
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
#pragma mark controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationItem];
    [self setupController];
    [self setupInterface];
}

#pragma end

#pragma mark
#pragma mark UITableViewDatasource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([self isSelfTableView:tableView]){
        return mFriends.count + 1;
    }else{
        if (mSearchResults.count == 0) {
            for (UIView *view in tableView.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)view;
                    label.text = @"很抱歉，查无此人";
                    label.textColor = AB_Color_9c958a;
                }
            }
        }
        return 1;
    }
}

-   (NSInteger)tableView:(UITableView *)tableView
   numberOfRowsInSection:(NSInteger)section {
    
    if([self isSelfTableView:tableView]) {
        if(section == 0) {
            return 1;
        }else {
            return [mFriends[section - 1] count];
        }
    }else {
        return mSearchResults.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    static NSString *ID = @"friends_contact_cell";
//    AIFriendContactCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ID];
//    if (!cell) {
//        cell = [[AIFriendContactCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                      reuseIdentifier:ID];
//        cell.imageView.layer.cornerRadius = 3.0;
//        cell.imageView.layer.masksToBounds = YES;
//    }
    BOOL fromSelf = [self isSelfTableView:tableView] ? YES : NO;
    if (indexPath.section == 0 && fromSelf) {
        static NSString *firstCellID = @"Forward_To_Create_Chat_Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:firstCellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:firstCellID];
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];
        cell.textLabel.text = @"群聊";
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = [UIColor colorFromHexString:@"#5b5752"];//AB_Color_403b36;
        cell.imageView.image = nil;
        return cell;
    }else {
        AIFriendContactCell *cell = [AIFriendContactCell cellWithTableView:tableView];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
        
       
        NSArray *arr = fromSelf ? mFriends[indexPath.section - 1] : nil;
        Contacts *contact = fromSelf ? (Contacts *)arr[indexPath.row] : mSearchResults[indexPath.row];
        cell.contact = contact;

////        NSString *urlString =[NSString stringWithFormat:@"%@/%@", ResourcesURL, contact.avatar];
//        NSURL *url = [NSURL URLWithString:urlString];
//        [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
//        cell.textLabel.text = [StrUtility isBlankString:contact.remarkName] ? contact.nickName : contact.remarkName;
//        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0)
    return 47.0;
    else
        return 43.0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self isSelfTableView:tableView] ? mSectionIndexTitles : nil;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    
    return [self isSelfTableView:tableView] ? mSectionIndexTitles[section] : nil;
}

-     (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    
    if ([self isSelfTableView:tableView]) {
       return section == 0 ? 0.0 : 20.0;
    }
    return 0.0;
}

-  (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
    if ([self isSelfTableView:tableView])
    {
        if (mSectionIndexTitles.count > 1) {
            
            CGRect rect = CGRectMake(0, 0, Screen_Width, 20);
            UIView *view = [[UIView alloc] init];
            view.frame = section == 0 ? rect : CGRectZero;
            
            UILabel *extralLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
            extralLabel.backgroundColor = Controller_View_Color;
            [view addSubview:extralLabel];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, Screen_Width - 15, 20)];
            label.font = kText_Font;
            label.textAlignment = NSTextAlignmentLeft;
            label.backgroundColor = Controller_View_Color;
            label.textColor = AB_Gray_Color;
            label.text = [mSectionIndexTitles objectAtIndex:section];
            [view addSubview:label];
            
            return view;
        }
        
    }
    return nil;
}

-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL fromSelf = tableView == self.tableView ? YES : NO;
    if (fromSelf) {
        if (indexPath.section == 0) {
            AIGroupContactViewController *controller = [[AIGroupContactViewController alloc] init];
            controller.assisstant = self.assisstant;
            [self.navigationController pushViewController:controller animated:YES];
            return;
        }else {
            Contacts *contact = mFriends[indexPath.section - 1][indexPath.row];
            mSelectedContact = contact;
        }
    }else {
        Contacts * contact = mSearchResults[indexPath.row];
        mSelectedContact = contact;
    }
    NSString *name = mSelectedContact.remarkName ? mSelectedContact.remarkName : mSelectedContact.nickName;
    NSString *tip = [NSString stringWithFormat:@"是否转发到\"%@\"", name];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:tip
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
}

#pragma end

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
    
    NSString *searchFormat = [[searchText transformToPinyin] lowercaseString];
    for (NSArray *contacts in mFriends) {
        for (Contacts *contact in contacts) {
            NSString *format_01 = [[contact.remarkName transformToPinyin] lowercaseString];
            NSString *format_02 = [[contact.nickName transformToPinyin] lowercaseString];
            
            if ([format_01 hasPrefix:searchFormat] || [format_02 hasPrefix:searchFormat]) {
                [mSearchResults addObject:contact];
            }
        }
    }
    [searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark
#pragma mark UIAlertViewDelegate

-    (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            mSelectedContact = nil;
            break;
            
        case 1: {
            NSMutableDictionary *contact = [NSMutableDictionary dictionary];
            [contact setObject:[self userNameFromJID:mSelectedContact.jid] forKey:@"userName"];
            [contact setObject:@"chat" forKey:@"type"];
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
