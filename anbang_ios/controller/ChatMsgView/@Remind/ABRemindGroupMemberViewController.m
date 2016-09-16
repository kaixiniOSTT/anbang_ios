//
//  ABRemindGroupMemberViewController.m
//  anbang_ios
//
//  Created by Kim on 15/4/21.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "ABRemindGroupMemberViewController.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "GroupMembersCRUD.h"
#import "GroupChatViewController2.h"
#import "AIRemindContactCell.h"

@interface ABRemindGroupMemberViewController ()
{
    NSMutableArray *searchResults;
    UIView* superview;
    NSString* searchStr;
    NSString *jidSearching;
}

@end

@implementation ABRemindGroupMemberViewController

@synthesize mySearchBar = _mySearchBar;

- (void)setJid:(NSString *)groupJID
{
    _groupJID = groupJID;
}

-(void)excludeSelf{
    for(NSDictionary *result in searchResults){
        if([MY_JID isEqualToString:result[@"jid"]]){
            [searchResults removeObject:result];
            break;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNavigationBar];
    searchResults = [GroupMembersCRUD queryChatRoomByGroupJID:_groupJID myJID:MY_JID];
    
    [self excludeSelf];
    
    //搜索栏
    mySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 359, 40)];
    mySearchBar.delegate = self;
    [mySearchBar setPlaceholder: @"请输入群成员昵称"];
    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:mySearchBar contentsController:self];
    searchDisplayController.active = NO;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.delegate = self;
    mySearchBar.barTintColor = [UIColor colorFromHexString:@"#e7e2dd"];
    
    self.view.backgroundColor = Controller_View_Color;
    self.tableView.backgroundColor = [UIColor clearColor];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 17)];
        [self.tableView setSeparatorColor:AB_Color_f4f0eb];
    }
    
    self.tableView .tableHeaderView = mySearchBar;

    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc]init];

    
    //去除多余行
    self.tableView.tableFooterView = [[UIView alloc]init];
 

    
    [self.searchDisplayController.searchResultsTableView reloadData];
    
    self.view.backgroundColor = Controller_View_Color;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationBar{
    self.navigationItem.title =@"选择回复的人";
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancle target:self action:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    if (searchResults.count == 0) {
        return 0;
    }
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchResults count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:@"remindGroupMemberCell"];
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:@"remindGroupMemberCell"];
//    }
//    
//
//    if(searchResults.count == 0){
//        cell.textLabel.text = @"无搜索结果";
//    }else{
//        NSMutableDictionary *member = [searchResults objectAtIndex:indexPath.row];
//        cell.textLabel.font = [UIFont systemFontOfSize:15];
//        cell.textLabel.text = [member objectForKey:@"nickName"];
//        NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [member objectForKey:@"avatar"]];
//            
//        [cell.imageView setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
//        cell.imageView.contentMode = UIViewContentModeScaleToFill;
//        CGSize itemSize = CGSizeMake(29, 29);
//        UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
//        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
//        [cell.imageView.image drawInRect:imageRect];
//        cell.imageView.layer.masksToBounds = YES;
//        cell.imageView.layer.cornerRadius = 3.0;
//        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//    }
    
    AIRemindContactCell *cell = [AIRemindContactCell cellWithTableView:tableView];
    cell.contact = searchResults[indexPath.row];
    return cell;
}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [AIRemindContactCell cellHeight];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *controllers = [self.navigationController viewControllers];
    NSMutableDictionary *member = [searchResults objectAtIndex:indexPath.row];
            
    GroupChatViewController2 *groupController = (GroupChatViewController2*)controllers[controllers.count - 2];
    groupController.keepingKeyboard = YES;
    [groupController addRemindGroupMemberWithMemberJID:member[@"jid"] source:1];
            
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    searchStr = searchText;
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    searchResults = [GroupMembersCRUD queryMembersByKeyword:searchStr groupJID:_groupJID myJID:MY_JID];
    [self excludeSelf];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //self.searchingFetchedResultsController = nil;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [self.tableView insertSubview:self.searchDisplayController.searchBar aboveSubview:self.tableView];
    }
    return;
}

@end
