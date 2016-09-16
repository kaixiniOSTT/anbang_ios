//
//  AddFriendVCTableViewController.m
//  anbang_ios
//
//  Created by yangsai on 15/3/27.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AddFriendVCTableViewController.h"
#import "MBProgressHUD.h"
#import "ChatInit.h"
#import "ContactInfo.h"
#import "PublicCURD.h"
#import "PinYinForObjc.h"
#import "AIPhoneContactViewController.h"
#import "ScanViewController.h"
#import "AIBindPhoneViewController.h"

@interface AddFriendVCTableViewController () {
    NSMutableArray *searchResults;
    NSArray *mMenus;
    NSString *searchStr;
    NSString *jidSearching;
}
@property(nonatomic, retain) UISearchBar *mySearchBar;

@end

@implementation AddFriendVCTableViewController
@synthesize mySearchBar = _mySearchBar;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_AddContacts" object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addFriendSuccess) name:@"NNC_AddContacts" object:nil];


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setNavigationBar];

    //搜索栏
    mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 359, 40)];
    mySearchBar.delegate = self;
    mySearchBar.barTintColor = Label_Back_Color;
    [mySearchBar setPlaceholder:@"手机/邮箱/社区ID"];
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:mySearchBar contentsController:self];
    searchDisplayController.active = NO;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.delegate = self;
    self.tableView.tableHeaderView = mySearchBar;
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];

    //添加搜索框文本框的边框
    UITextField *txfSearchField = [mySearchBar valueForKey:@"_searchField"];
    txfSearchField.borderStyle = UITextBorderStyleRoundedRect;
    txfSearchField.layer.cornerRadius = 3.0f;
    txfSearchField.layer.masksToBounds = YES;
    txfSearchField.layer.borderWidth = .5;
    txfSearchField.layer.borderColor = [[UIColor colorWithRed:214.0f/255.0f green:200.0f/255.0f blue:179.0f/255.0f alpha:1.0f] CGColor];//AB_Color_e7e2dd.CGColor;
    
    if (searchResults == nil) {
        searchResults = [NSMutableArray array];
    }

    mMenus = @[@{@"avatar" : @"icon_add_scan", @"name" : @"扫一扫", @"desc" : @"扫描二维码添加好友"},
            @{@"avatar" : @"icon_add_adbook", @"name" : @"手机通讯录", @"desc" : @"添加或邀请手机通讯录中的好友"}];

    //去除多余行
    self.tableView.tableFooterView = [[UIView alloc] init];

    self.view.backgroundColor = Controller_View_Color;

    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 17)];
        [self.tableView setSeparatorColor:Table_View_Separator_Color];
    }


}

- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setNavigationBar {
    self.navigationItem.title = @"添加好友";
    
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"通讯录"
                                                                                   target:self
                                                                                   action:@selector(pop)]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scan QRCode

- (void) scanQRCode
{
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:@"请真机运行！！！" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [myAlert addButtonWithTitle:NSLocalizedString(@"public.alert.ok",@"message")];
        [myAlert show];
        
    }
    
    ScanViewController *scanVC=[[ScanViewController alloc]init];
    scanVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:scanVC animated:YES];
    
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return mMenus.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self scanQRCode];
    } else if (indexPath.row == 1) {
        UserInfo *my = [UserInfo loadArchive];
        if(my.phone == nil || [@"" isEqualToString:my.phone]){
            AIBindPhoneViewController *bind = [[AIBindPhoneViewController alloc] init];
            [self.navigationController pushViewController:bind animated:YES];
            return;
        }
        AIPhoneContactViewController *contactViewController = [[AIPhoneContactViewController alloc] init];
        [self.navigationController pushViewController:contactViewController animated:YES];
    }

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect rect = CGRectMake(0, 0, Screen_Width, 21);
    UIView *view = [[UIView alloc] initWithFrame:rect];

    UILabel *extralLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 21)];
    extralLabel.backgroundColor = AB_Color_f6f2ed;
    [view addSubview:extralLabel];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, Screen_Width - 15, 21)];
    label.font = kText_Font;
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = AB_Color_f6f2ed;
    label.textColor = AB_Color_9c958a;
    [view addSubview:label];

    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"menuCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
    }

    NSDictionary *menu = mMenus[(NSUInteger) indexPath.row];

    UIImage *image = [UIImage imageNamed:menu[@"avatar"]];
    cell.imageView.image = image;
    cell.imageView.contentMode = UIViewContentModeScaleToFill;
    CGSize itemSize = CGSizeMake(34, 34);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 3.0;
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    cell.textLabel.text = menu[@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = AB_Color_403b36;

    cell.detailTextLabel.text = menu[@"desc"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.textColor = AB_Color_9c958a;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 21;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    searchStr = searchText;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //self.searchingFetchedResultsController = nil;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [self.tableView insertSubview:self.searchDisplayController.searchBar aboveSubview:self.tableView];
    }
    return;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/search"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *keytype = [NSXMLElement elementWithName:@"keytype" stringValue:@"Search"];

    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"getContactInfoWithSearch"];

    NSXMLElement *key = [NSXMLElement elementWithName:@"key" stringValue:searchStr];
    NSXMLElement *book = [NSXMLElement elementWithName:@"book"];
    NSXMLElement *agency = [NSXMLElement elementWithName:@"agency"];
    NSXMLElement *branch = [NSXMLElement elementWithName:@"branch"];
    NSXMLElement *orgname = [NSXMLElement elementWithName:@"orgname"];
//
    [queryElement addChild:keytype];
    [queryElement addChild:key];
    [queryElement addChild:book];
    [queryElement addChild:agency];
    [queryElement addChild:branch];
    [queryElement addChild:orgname];
    [iq addChild:queryElement];
    NSLog(@"组装后的xml:%@", iq);
    [[XMPPServer xmppStream] sendElement:iq];


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContactList:)
                                                 name:@"NNS_ContactInfo_Search" object:nil];

}


- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNS_ContactInfo_Search" object:nil];
    [super viewDidDisappear:animated];
}

- (void)showContactInfo:(NSNotificationCenter *)notify {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DB_SAVE_SUCCESS" object:nil];

    ContactInfo *contact = [[ContactInfo alloc] initWithNibName:@"ContactInfo" bundle:nil];
    contact.jid = jidSearching;
    [self.navigationController pushViewController:contact animated:YES];
}

- (void)showContactList:(NSNotificationCenter *)notify {
    NSDictionary *contactsDic = [notify valueForKey:@"object"];
    JLLog_I(@"contactsDic=%@", contactsDic);
    if ([contactsDic count] != 1) {
        return;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContactInfo:)
                                                 name:@"DB_SAVE_SUCCESS" object:nil];
    NSString *jid = [contactsDic[@"0"] objectForKey:@"jid"];
    [ChatInit queryUserInfoWithJid:jid];
    jidSearching = jid;
    return;
}

- (void)addFriendSuccess {
    for (id tmp in self.view.subviews) {
        if ([tmp isMemberOfClass:[MBProgressHUD class]]) {
            ((MBProgressHUD *) tmp).hidden = YES;
            [self.navigationController popViewControllerAnimated:YES];
            JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"添加好友成功 !"];
            [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES autoRelease:YES];
        }
    }

}

@end
