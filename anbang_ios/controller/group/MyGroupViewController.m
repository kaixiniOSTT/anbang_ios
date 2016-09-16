//
//  GroupViewController.m


#import "MyGroupViewController.h"
#import "GroupCRUD.h"
#import "GroupMembersCRUD.h"
#import "GroupDetailsViewController.h"
#import "KKChatDelegate.h"
#import "GroupAddContactsViewController.h"
#import "GroupNameTableViewController.h"
#import "GroupChatViewController2.h"
#import "UIImageView+WebCache.h"
#import "ImageUtility.h"
#import "ChatInit.h"
#import "ChineseInclude.h"
#import "ChatGroup.h"
#import "PinYinForObjc.h"
#import "GroupDetailViewController2.h"
#import "AINavigationController.h"
#import "AIGroupCell.h"
#import "NSString+Chinese.h"


#define AB_Icon_Tag 1564

@interface MyGroupViewController ()<UISearchDisplayDelegate, UINavigationControllerDelegate>{
    UIBarButtonItem *deleteBuddyItem;
    NSMutableArray *groups;
    NSMutableArray *searchResults;
}

@end

@implementation MyGroupViewController
@synthesize groupArray;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CNN_Group_Load_OK" object:nil];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"内存警告－我的圈");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];//即使没有显示在window上，也不会自动的将self.view释放。
    // Add code to clean up any of your own resources that are no longer necessary.
    
    // 此处做兼容处理需要加上ios6.0的宏开关，保证是在6.0下使用的,6.0以前屏蔽以下代码，否则会在下面使用self.view时自动加载viewDidUnLoad
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        
        //需要注意的是self.isViewLoaded是必不可少的，其他方式访问视图会导致它加载 ，在WWDC视频也忽视这一点。
        
        if (self.isViewLoaded && !self.view.window)// 是否是正在使用的视图
        {
            // Add code to preserve data stored in the views that might be
            // needed later.
            
            // Add code to clean up other strong references to the view in
            // the view hierarchy.
            self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
        }
        
    }
    
}
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)loadView{
    [super loadView];
    
    int cutHeight=0;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
        cutHeight=113;
    }else  {
        cutHeight=113;
    }
    
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"通讯录"
                                                                                   target:self
                                                                                   action:@selector(back)]];
    
//    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-cutHeight) style:UITableViewStylePlain];
    //Buddy_Table_Separator_color;
    //self.tableView.separatorInset = UIEdgeInsetsMake(0, 8, 0, 0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //设置通知中心，刷新邦邦社区子；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMyGroupVC)
                                                 name:@"CNN_Group_Load_OK" object:nil];
    
    
    // _groupArray = [NSMutableArray array];
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    [self.navigationItem setTitle:NSLocalizedString(@"circle.myCircle",@"title")];
    
    groups = [NSMutableArray array];
    //设定在线用户委托
    // [XMPPServer sharedServer].groupChatDelegate = self;
    // [self queryRoom];
    
    
    //删除好友
    //    deleteBuddyItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"circle.edit",@"action") style:UIBarButtonItemStylePlain  target:self action:@selector(toDeleteButty)];
    //    deleteBuddyItem.tintColor = [UIColor whiteColor];
    //    [self.navigationItem setLeftBarButtonItem:deleteBuddyItem];
    
    
    
    
    //自定义表头
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, KCurrWidth, 45.0)];
    
    // UILabel * headerLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero ];
    
    // headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = YES;
    //headerLabel.textColor = [UIColor lightGrayColor];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.frame = CGRectMake(20.0, 0.0, KCurrWidth, 45.0);
    //headerLabel.backgroundColor = [UIColor colorFromHexString:@"#87a96b"];
    headerLabel.backgroundColor = kMainColor4;
    
    
    //UIImageView *headerImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 3, 30, 30)] autorelease];
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 3, 35, 35)];
    [headerImageView setImage:[UIImage imageNamed:@"group2.png"]];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    //[btn  addTarget:self action:@selector() forControlEvents:UIControlEventTouchUpInside];
    //[btn  addTarget:self action:@selector(showPopupMenu2:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor clearColor];
    btn.frame = CGRectMake(0,0,300,40);
    [btn  addTarget:self action:@selector(createGroupAddContacts) forControlEvents:UIControlEventTouchUpInside];
    
    headerLabel.text =  NSLocalizedString(@"circle.createCircle",@"action");
    //[customView addSubview:headerImageView];
    [customView addSubview:headerLabel];
    [customView addSubview:btn];
    customView.backgroundColor = kMainColor4;
    
    self.tableView.tableHeaderView = customView;
//    self.tableView.separatorColor = AB_Color_e7e2dd;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.tag = 1;//删除状态：以tag值来传递编辑状态
    
    [self setExtraCellLineHidden:self.tableView];
    //[btn release];
    
    //图片异步加载
    [SDWebImageManager.sharedManager.imageDownloader setValue:@"anbang_ios" forHTTPHeaderField:@"AppName"];
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    
    
    //下拉刷新
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor lightGrayColor];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"   "];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    //搜索栏
    mySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    mySearchBar.delegate = self;
    mySearchBar.barTintColor = [UIColor colorWithRed:246.0/255.0 green:242.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    [mySearchBar setPlaceholder:NSLocalizedString(@"chat.search",@"action")];
    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:mySearchBar contentsController:self];
    searchDisplayController.active = NO;
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    self.tableView .tableHeaderView = mySearchBar;
    //添加搜索框文本框的边框
    UITextField *txfSearchField = [mySearchBar valueForKey:@"_searchField"];
    txfSearchField.borderStyle = UITextBorderStyleRoundedRect;
    txfSearchField.layer.cornerRadius = 3.0f;
    txfSearchField.layer.masksToBounds = YES;
    txfSearchField.layer.borderWidth = .5;
    txfSearchField.layer.borderColor = [[UIColor colorWithRed:214.0f/255.0f green:200.0f/255.0f blue:179.0f/255.0f alpha:1.0f] CGColor];//AB_Color_e7e2dd.CGColor;
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc]init];
    if (IS_iOS7) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 8, 0, 0);
    }
    self.view.backgroundColor = Controller_View_Color;
}



- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
    view.backgroundColor = Controller_View_Color;
    [tableView setTableFooterView:view];
}



#pragma mark - private
//删除好友
-(void)toDeleteButty{
    if ([deleteBuddyItem.title isEqualToString:NSLocalizedString(@"circle.edit",@"action")]) {
        deleteBuddyItem.title = NSLocalizedString(@"circle.complete",@"action");
        
    }else{
        deleteBuddyItem.title = NSLocalizedString(@"circle.edit",@"action");
    }
    self.tableView.tag = UITableViewCellEditingStyleDelete;//删除状态：以tag值来传递编辑状态
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
}


-(void)FirstShowGroup{
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    NSString *userName = [userDefaults stringForKey:@"userName"];
    //    NSString *myJID = [NSString stringWithFormat:@"%@@%@",userName, OpenFireHostName];
    //    self.groupArray =[GroupCRUD queryMyChatGroupByMyJID:myJID];
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.groupArray = [self queryAllGroupsWithAvatarAndName];
    
//    JLLog_I(@"groupArray=%@", self.groupArray);
    
    [self.tableView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


-(void)refreshMyGroupVC{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.groupArray = [self queryAllGroupsWithAvatarAndName];
        [self.tableView reloadData];
        
    });
}


#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (self.tableView == tableView) {
        return self.groupArray.count;
    }
    
    return searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AIGroupCell *cell = [AIGroupCell cellWithTableView:tableView];
    NSDictionary *group = nil;
    if (self.tableView == tableView) {
        group = [self.groupArray objectAtIndex:indexPath.row];
    }else{
        group = [searchResults objectAtIndex:indexPath.row];
        
    }
    
    cell.group = group;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *groupDic = [self.groupArray objectAtIndex:[indexPath row]];
    GroupDetailsViewController *groupDetailsVC = [[GroupDetailsViewController alloc]init];
    //NSLog(@"*********%@",[groupDic objectForKey:@"groupJID"]);
    groupDetailsVC.groupJID = [groupDic objectForKey:@"groupJID"];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
        //隐藏tabbar
        groupDetailsVC.hidesBottomBarWhenPushed=YES;
    }else{
        //隐藏tabbar
        groupDetailsVC.hidesBottomBarWhenPushed=YES;
    }
    [self.navigationController pushViewController:groupDetailsVC animated:YES];
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupChatViewController2 *groupChatVC = [[GroupChatViewController2 alloc] init];
    NSDictionary *buddyDic = [self.groupArray objectAtIndex:[indexPath row]];
    groupChatVC.roomName = [buddyDic objectForKey:@"groupMucId"];
    groupChatVC.groupJID = buddyDic[@"groupJID"];
    groupChatVC.roomNickName = [buddyDic objectForKey:@"groupName"];
    groupChatVC.title = [buddyDic objectForKey:@"groupName"];
    int memberCount = [[buddyDic objectForKey:@"groupMembersArray"] count];
    
    if ([StrUtility isBlankString:groupChatVC.title]) {
        groupChatVC.title = [NSString stringWithFormat:@"群聊(%d)", memberCount];
    }else {
        groupChatVC.title = [NSString stringWithFormat:@"%@(%d)", groupChatVC.title, memberCount];
    }


#pragma mark
#pragma mark start transition

    GroupChatViewController2 *groupChatVC_02 = [[GroupChatViewController2 alloc] init];
    groupChatVC_02.roomName = groupChatVC.roomName;
    groupChatVC_02.groupJID = groupChatVC.groupJID;
    groupChatVC_02.roomNickName = groupChatVC.roomNickName;
    groupChatVC_02.title = groupChatVC.title;

    groupChatVC.hidesBottomBarWhenPushed = YES;
    groupChatVC_02.hidesBottomBarWhenPushed = YES;
    
    self.navigationController.delegate = self;
    AINavigationController *controller = self.tabBarController.viewControllers[0];
    [controller pushViewController:groupChatVC_02 animated:YES];
    [self.navigationController pushViewController:groupChatVC animated:YES];
    
#pragma mark ending to excute navigaiton controller delegate
    
     //   [groupChatVC release];
    
//    if(1==2){
//        ChatGroup* group = [[ChatGroup alloc]init];
//        if(self.tableView == tableView){
//            [group setValuesForKeysWithDictionary:[self.groupArray objectAtIndex:[indexPath row]]];
//        }else{
//            group = [searchResults objectAtIndex:indexPath.row];
//        }
//        GroupDetailsViewController *groupDetailsVC = [[GroupDetailsViewController alloc]init];
//        //NSLog(@"*********%@",[groupDic objectForKey:@"groupJID"]);
//        groupDetailsVC.groupJID =  group.jid;
//        groupDetailsVC.hidesBottomBarWhenPushed=YES;
//         [self.navigationController pushViewController:groupDetailsVC animated:YES];
//    }else{
//        ChatGroup *group = [[ChatGroup alloc]init];
//        
//        if (self.tableView == tableView) {
//            [group setValuesForKeysWithDictionary: [self.groupArray objectAtIndex:indexPath.row]];
//            
//        }else{
//            group = [searchResults objectAtIndex:indexPath.row];
//            
//        }
//        GroupDetailViewController2*  groupDetailsVC = [[GroupDetailViewController2 alloc]init];
//        groupDetailsVC.group = group;
//        
//        
//        [self.navigationController pushViewController:groupDetailsVC animated:YES];
//    }
//    
    
    
    
    
}

#pragma mark
#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    self.navigationController.delegate = NULL;
    self.tabBarController.selectedIndex = 0;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma end

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [AIGroupCell cellHeight];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
    //不能是UITableViewCellEditingStyleNone
}


//点击删除按钮后, 会触发如下事件. 在该事件中做响应动作就可以了
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle  forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSDictionary *buddyDic = [self.groupArray objectAtIndex:[indexPath row]];
        NSLog(@"%@",[buddyDic objectForKey:@"groupJID"]);
        //是否是创建者
        NSString *creator = [buddyDic objectForKey:@"creator"];
        if ([creator isEqualToString:MY_JID]) {
            [self deleteGroup:[buddyDic objectForKey:@"groupJID"]];
            
        }else{
            [self exitGroup:[buddyDic objectForKey:@"groupJID"]];
            
        }
        if (indexPath.section == 0) {
            [self.groupArray removeObjectAtIndex:indexPath.row];
        }else{
            [self.groupArray removeObjectAtIndex:indexPath.row];
        }
        NSLog(@"delete!");
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
    
}



-(void)createGroupAddContacts{
    
    GroupNameTableViewController *groupNameTableVC = [[GroupNameTableViewController alloc]init];
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
        //隐藏tabbar
        groupNameTableVC.hidesBottomBarWhenPushed=YES;
    }else{
        
    }
    [self.navigationController pushViewController:groupNameTableVC animated:YES];
    
}


/*---删除群组--------------------------------------------------------------------------------------*/
-(void)deleteGroup:(NSString *)groupJID{
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/admin"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
    
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:@"circle.ab-insurance.com"];
    [circle addAttributeWithName:@"jid" stringValue:groupJID];
    [circle addAttributeWithName:@"remove" stringValue:@"true"];
    
    [iq addChild:queryElement];
    [queryElement addChild:circle];
    
    NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
    XMPPJID *myJID = [XMPPServer xmppStream].myJID;
    NSString *jid = [NSString stringWithFormat:@"%@",myJID.bareJID];
    NSLog(@"*****%@",jid);
    
    //删除本地圈子数据
    //[GroupCRUD deleteMyGroup:groupJID myJID:jid];
    
}


/*---退出群组--------------------------------------------------------------------------------------*/
-(void)exitGroup:(NSString *)groupJID{
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/admin"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
    NSXMLElement *members = [NSXMLElement elementWithName:@"members"];
    NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:@"circle.ab-insurance.com"];
    [circle addAttributeWithName:@"jid" stringValue:groupJID];
    [member addAttributeWithName:@"jid" stringValue:MY_JID];
    [member addAttributeWithName:@"remove" stringValue:@"true"];
    [iq addChild:queryElement];
    [queryElement addChild:circle];
    [circle addChild:members];
    [members addChild:member];
    // NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    //删除本地圈子数据
    //[GroupCRUD deleteMyGroup:groupJID myJID:MY_JID];
}






//订阅关系好友
-(void)userInfoReceived:(NSString *)jid nickName:(NSString *)nickName phone:(NSString *)phone avatar:(NSString *)avatar{
    NSLog(@"*******************%@",nickName);
}


//下拉刷新
-(void)handleData
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm:ss a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"refresh.text2",@"title"),[formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    // self.count++;
    //[self.countArr addObject:[NSString stringWithFormat:@"%d. %@, code4app.com",self.count,[formatter stringFromDate:[NSDate date]]]];
    
    [self.refreshControl endRefreshing];
    self.groupArray = [self queryAllGroupsWithAvatarAndName];
    [self.tableView reloadData];
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
//            if ([StrUtility isBlankString:groupName] || [@"(null)" isEqualToString:groupName]) {
//                if(i==0){
//                    groupTempName = [NSString stringWithFormat:@"%@%@",groupTempName, [groupDic objectForKey:@"nickName"]];
//                }else{
//                    groupTempName = [NSString stringWithFormat:@"%@,%@",groupTempName, [groupDic objectForKey:@"nickName"]];
//                }
//                
//            }
            
            [avatarArray addObject:[groupDic objectForKey:@"avatar"]];
        }

//        new[@"groupTempName"] = [StrUtility string:groupName defaultValue: groupTempName];
        new[@"avatarArray"] = avatarArray;
        
        [result addObject:new];
    }
    
    return result;
}


-(void)refreshView:(UIRefreshControl *)refresh
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *groupMembersVer = [NSString stringWithFormat:@"%@_%@",@"Ver_GroupMembersComplete",MY_USER_NAME];
    if (![[defaults objectForKey:@"Ver_Query_GroupMembers"] isEqualToString:groupMembersVer]) {
//        [GroupCRUD deleteAllMyGroup];
        [ChatInit queryRoom];
    }
    if (refresh.refreshing) {
        refresh.attributedTitle = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"refresh.text",@"title")];
        [self performSelector:@selector(handleData) withObject:nil afterDelay:2];
    }
}


//- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
//    if (self.tableView != self.searchDisplayController.searchBar.superview) {
//        [self.tableView insertSubview:self.searchDisplayController.searchBar aboveSubview:self.tableView];
//    }
//}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //self.searchingFetchedResultsController = nil;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [self.tableView insertSubview:self.searchDisplayController.searchBar aboveSubview:self.tableView];
    }
    return;
}

#pragma mark
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if(searchResults == nil){
        searchResults = [NSMutableArray array];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchResults = [NSMutableArray array];
}

- (void) searchBar:(UISearchBar *)searchBar
     textDidChange:(NSString *)searchText{

    [searchResults removeAllObjects];
    if (!searchText || [searchText isEqualToString:@""]) return;
    
    NSString *search_format = [[searchText transformToPinyin] lowercaseString];
    for (NSDictionary *group in self.groupArray) {
        NSString *format_01 = [[group[@"name"] transformToPinyin] lowercaseString];
        NSString *format_02 = [[group[@"groupTempName"] transformToPinyin] lowercaseString];
        
        if ([format_01 hasPrefix:search_format] || [format_02 hasPrefix:search_format]) {
            [searchResults addObject:group];
        }
    }
    [searchDisplayController.searchResultsTableView reloadData];
    
    
//    if(searchBar.text == nil || [searchBar.text isEqualToString: @""] ){
//        return;
//    }
//    if (mySearchBar.text.length>0 && ![ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
//        for (int i=0; i<self.groupArray.count; i++) {
//            ChatGroup * group = [[ChatGroup alloc]init];
//            [group setValuesForKeysWithDictionary:self.groupArray[i]];
//            
//            if (group.name == nil || [group.name isEqualToString: @""]) {
//                continue;
//            }
//            
//            NSString *searchName = group.name;
//            
//            if ([ChineseInclude isIncludeChineseInString:searchName]) {
//                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:searchName];
//                NSRange titleResult=[tempPinYinStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
//                
//                if (titleResult.length>0) {
//                    // [searchResults addObject:searchName];
//                    
//                    [searchResults addObject:group];
//                }
//                //                NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:searchName];
//                //                NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
//                //                if (titleHeadResult.length>0) {
//                //                    [searchResults addObject:searchName];
//                //                }
//            }
//            else {
//                NSRange titleResult=[searchName rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
//                if (titleResult.length>0) {
//                    //[searchResults addObject:searchName];
//                    [searchResults addObject:group];
//                }
//            }
//            
//        }
//    } else if (mySearchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
//        for (int i=0; i<self.groupArray.count; i++) {
//            ChatGroup * group = [[ChatGroup alloc]init];
//            [group setValuesForKeysWithDictionary:self.groupArray[i]];
//            
//            NSString *searchName = group.name;
//            
//            
//            NSRange titleResult=[searchName rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
//            //contact.pinYin = searchName;
//            if (titleResult.length>0) {
//                //[searchResults addObject:searchName];
//                [searchResults addObject:group];
//            }
//        }
//    }
//    
//    
//    [self.searchDisplayController.searchResultsTableView  reloadData];
    
    
}



@end
