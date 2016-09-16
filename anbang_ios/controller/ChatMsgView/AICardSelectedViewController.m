//
//  AICardSelectedViewController.m
//  anbang_ios
//
//  Created by rooter on 15-6-3.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AICardSelectedViewController.h"
#import "Contacts.h"
#import "ChineseString.h"
#import "ContactsCRUD.h"
#import "AIFriendContactCell.h"
#import "NSString+Chinese.h"
#import "AIPersonalCard.h"
#import "MJExtension.h"
#import "GroupCRUD.h"
#import "ChatGroup.h"

@interface AICardSelectedViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate,UISearchDisplayDelegate>
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UISearchBar *searchBar;
@end

@implementation AICardSelectedViewController {
    
    NSArray *mFriends;
    NSMutableArray *mSearchResults;
    NSMutableArray *mSectionIndexTitles;
    Contacts *mSelectedContact;
    UISearchDisplayController *searchDisplayController;
}

#pragma mark
#pragma mark private

- (void)back
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

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
    return arrayForArrays;
}

#pragma end


#pragma mark
#pragma mark setup

- (void)setupController {
    mSectionIndexTitles = [NSMutableArray array];
    NSArray *tmp = [ContactsCRUD queryContactsListTwo:MY_JID];
    mFriends = [self getChineseStringArr:tmp];
//        JLLog_I(@"mfriends=%@", mFriends);
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationItem];
    [self setupController];
    [self setupInterface];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([self isSelfTableView:tableView]){
        return mFriends.count;
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
        return [mFriends[section] count];
    }else {
        return mSearchResults.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AIFriendContactCell *cell = [AIFriendContactCell cellWithTableView:tableView];
    cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorFromHexString:@"#e7e2dd"];
    BOOL fromSelf = [self isSelfTableView:tableView] ? YES : NO;
    NSArray *arr = fromSelf ? mFriends[indexPath.section] : nil;
    Contacts *contact = fromSelf ? (Contacts *)arr[indexPath.row] : mSearchResults[indexPath.row];
    cell.contact = contact;
    return cell;
}

-    (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
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
        return 30.0;
    }
    return 0.0;
}

-  (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
    if ([self isSelfTableView:tableView])
    {
        if (mSectionIndexTitles.count > 1) {
            
            CGRect rect = CGRectMake(0, 0, Screen_Width, 30);
            UIView *view = [[UIView alloc] init];
            view.frame = section == 0 ? rect : CGRectZero;
            
            UILabel *extralLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 30)];
            extralLabel.backgroundColor = Controller_View_Color;
            [view addSubview:extralLabel];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, Screen_Width - 15, 30)];
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
    
    BOOL fromSelf = [self isSelfTableView:tableView] ? YES : NO;
    NSArray *arr = fromSelf ? mFriends[indexPath.section] : nil;
    Contacts *contact = fromSelf ? (Contacts *)arr[indexPath.row] : mSearchResults[indexPath.row];
    mSelectedContact = contact;
    NSString *name = mSelectedContact.remarkName ? mSelectedContact.remarkName : mSelectedContact.nickName;
    NSString *tip = [NSString stringWithFormat:@"发送\"%@\"的名片到当前聊天？", name];
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
            AIPersonalCard *card = [[AIPersonalCard alloc] initWithJID:mSelectedContact.jid];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:card.keyValues options:NSJSONWritingPrettyPrinted error:nil];
            NSString *text = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSArray *array = @[@{@"text" : text, @"subject" : @"card"}];
            
            NSString *userName = nil;
            switch (self.chatType) {
                case AIChatTypeChat:
                    userName = [self.oppositeJID componentsSeparatedByString:@"@"][0];
                    break;
                case AIChatTypeGroup:
                    userName = self.oppositeJID;
                    break;
                default:
                    break;
            }
            
            AIMessageSendAssisstant *assisstant = [[AIMessageSendAssisstant alloc] initWithFromUserName:userName];
            assisstant.delegate = self.delegate;
            assisstant.messages = array;
            
            switch (self.chatType) {
                case AIChatTypeChat: {
                    [contact setObject:[self userNameFromJID:self.oppositeJID] forKey:@"userName"];
                    [contact setObject:@"chat" forKey:@"type"];
                }
                    break;
                case AIChatTypeGroup: {
                    [contact setObject:self.oppositeJID forKey:@"userName"];
                    [contact setObject:@"groupchat" forKey:@"type"];
                }
                    break;
                default:
                    break;
            }
            
            [assisstant sendMessagesTo:contact];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

#pragma end

@end
