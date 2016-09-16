//
//  GroupViewController.m


#import "GroupViewController.h"

#import "GroupCRUD.h"
#import "GroupMembersCRUD.h"
#import "GroupDetailsViewController.h"
#import "KKChatDelegate.h"
#import "GroupChatViewController2.h"
#import "GroupAddContactsViewController.h"
#import "GroupNameTableViewController.h"
#import "CHAppDelegate.h"
#import "ChatInit.h"
#import "UIImageView+WebCache.h"
#import "ImageUtility.h"
#import "AsynImageView.h"



@interface GroupViewController (){
    NSMutableArray *groups;
}

@end

@implementation GroupViewController
@synthesize groupArray;


-(void)loadView{
    [super loadView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-Both_Bar_Height) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self.view addSubview:_tableView];
    
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CNN_Group_Load_OK" object:nil];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //设置通知中心，刷新邦邦社区子；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllGroupVC)
                                                 name:@"CNN_Group_Load_OK" object:nil];
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    
    self.title=NSLocalizedString(@"circle.myCircle",@"title");
    
    // _groupArray = [NSMutableArray array];
    
    groups = [NSMutableArray array];
    //设定在线用户委托
    // [XMPPServer sharedServer].groupChatDelegate = self;
    // [self queryRoom];
    
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval: 3
                                             target: self
                                           selector: @selector(FirstShowGroup)
                                           userInfo: nil
                                            repeats: NO];
    
    
    //删除好友
    //    UIBarButtonItem *deleteBuddyItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain  target:self action:@selector(toDeleteButty)];
    //    [self.navigationItem setLeftBarButtonItem:deleteBuddyItem];
    
    
    
    //自定义表头
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
    
    // UILabel * headerLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero ];
    
    // headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = YES;
    headerLabel.textColor = [UIColor lightGrayColor];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.frame = CGRectMake(80.0, 0.0, 300.0, 44.0);
    
    
    //UIImageView *headerImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 3, 30, 30)] autorelease];
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 3, 35, 35)];
    [headerImageView setImage:[UIImage imageNamed:@"group2.png"]];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    //[btn  addTarget:self action:@selector() forControlEvents:UIControlEventTouchUpInside];
    //[btn  addTarget:self action:@selector(showPopupMenu2:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor clearColor];
    btn.frame = CGRectMake(0,0,300,40);
    [btn  addTarget:self action:@selector(createGroupAddContacts) forControlEvents:UIControlEventTouchUpInside];
    
    //headerLabel.text =  @"创建一个邦邦社区";
    [customView addSubview:headerImageView];
    [customView addSubview:headerLabel];
    [customView addSubview:btn];
    
    // self.tableView.tableHeaderView = customView;
    _tableView.tag = 1;//删除状态：以tag值来传递编辑状态
    
    //[self setExtraCellLineHidden:self.tableView];
    
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
}
#pragma mark - private
//删除好友
-(void)toDeleteButty{
    _tableView.tag = UITableViewCellEditingStyleDelete;//删除状态：以tag值来传递编辑状态
    [_tableView setEditing:!_tableView.isEditing animated:YES];
}


-(void)FirstShowGroup{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults stringForKey:@"userName"];
    NSString *myJID = [NSString stringWithFormat:@"%@@%@",userName, OpenFireHostName];
    self.groupArray =[GroupCRUD queryAllChatGroupByMyJID:myJID];
    
    [_tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    
    self.groupArray =[GroupCRUD queryAllChatGroupByMyJID:MY_JID];
    
    [_tableView reloadData];
    
    
    NSLog(@"******%d",self.groupArray.count);
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSLog(@"******%d",self.groupArray.count);
    
    return self.groupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *groupDic = [self.groupArray objectAtIndex:[indexPath row]];
    cell.textLabel.text = [groupDic objectForKey:@"groupName"];
    
    NSMutableArray *groupMembersArray = [groupDic objectForKey:@"groupMembersArray"];
    
    // UIImageView*photoView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 40.0, 40.0)] autorelease];
    
    UIImage *avatarImage1 = [[UIImage alloc]init];
    UIImage *avatarImage2 = [[UIImage alloc]init];
    UIImage *avatarImage3 = [[UIImage alloc]init];
    UIImage *avatarImage4 = [[UIImage alloc]init];
    
    for (int i=0; i<groupMembersArray.count; i++) {
        
        // NSLog(@"######%@",[groupMembersArray objectAtIndex:i]);
        
        if (i==0) {
            //UIImageView*photoView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 30.0, 30.0)] autorelease];
            AsynImageView*photoView  = [[AsynImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 30.0, 30.0)];
            
            if([[groupMembersArray objectAtIndex:i] isEqualToString:@""] || [groupMembersArray objectAtIndex:i]==nil){
                photoView.image = [UIImage imageNamed:@"defaultUser.png"];
                avatarImage1=photoView.image;
                
                continue;
            }
            // [photoView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]] ] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]options:indexPath.row == 0 ? SDWebImageRefreshCached : 0 ];
            photoView.placeholderImage = [UIImage imageNamed:@"defaultUser.png"];
            photoView.imageURL = [NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]];
            avatarImage1=photoView.image;
            
            
        }else if(i==1){
            // UIImageView*photoView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 20.0, 20.0)] autorelease];
            AsynImageView*photoView  = [[AsynImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 30.0, 30.0)];
            
            if([[groupMembersArray objectAtIndex:i] isEqualToString:@""] || [groupMembersArray objectAtIndex:i]==nil){
                
                photoView.image = [UIImage imageNamed:@"defaultUser.png"];
                avatarImage2= photoView.image ;
                continue;
            }
            //  [photoView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]] ] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]options:indexPath.row == 0 ? SDWebImageRefreshCached : 0 ];
            photoView.placeholderImage = [UIImage imageNamed:@"defaultUser.png"];
            photoView.imageURL = [NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]];
            avatarImage2=photoView.image;
            
        }else if(i==2){
            //UIImageView*photoView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 30.0, 30.0)] autorelease];
            AsynImageView*photoView  = [[AsynImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 30.0, 30.0)];
            
            if([[groupMembersArray objectAtIndex:i] isEqualToString:@""] || [groupMembersArray objectAtIndex:i]==nil){
                // photoView.image = [UIImage imageNamed:@"defaultUser.png"];
                avatarImage3=[UIImage imageNamed:@"defaultUser.png"];
                
                continue;
            }
            //[photoView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]] ] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
            photoView.placeholderImage = [UIImage imageNamed:@"defaultUser.png"];
            photoView.imageURL = [NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]];
            avatarImage3=photoView.image;
            
        }else if(i==3){
            //UIImageView*photoView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 30.0, 30.0)] autorelease];
            AsynImageView*photoView  = [[AsynImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 30.0, 30.0)];
            
            if([[groupMembersArray objectAtIndex:i] isEqualToString:@""] || [groupMembersArray objectAtIndex:i]==nil){
                photoView.image = [UIImage imageNamed:@"defaultUser.png"];
                avatarImage4=photoView.image;
                
                
                continue;
            }
            
            //[photoView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]] ] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
            photoView.placeholderImage = [UIImage imageNamed:@"defaultUser.png"];
            photoView.imageURL = [NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]];
            avatarImage4=photoView.image;
        }
    }
    
    
    if(groupMembersArray.count==2){
        UIImageView*photoView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 5.0, 30.0, 30.0)];
        photoView3.image = [UIImage imageNamed:@"placeholder.png"];
        avatarImage3=photoView3.image;
        
        UIImageView*photoView4 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 5.0, 30.0, 30.0)];
        photoView4.image = [UIImage imageNamed:@"placeholder.png"];
        avatarImage4=photoView4.image;
    }else if(groupMembersArray.count==3){
        
        UIImageView*photoView4 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 5.0, 30.0, 30.0)];
        photoView4.image = [UIImage imageNamed:@"placeholder.png"];
        avatarImage4=photoView4.image;
        
    }
    
    
    cell.imageView.image =[ImageUtility addImage:avatarImage1 toImage:avatarImage2 threeImage:avatarImage3 four:avatarImage4];
    cell.imageView.backgroundColor = [UIColor whiteColor];
    cell.imageView.layer.borderWidth = 0;
    
    //cell.imageView.image = [UIImage imageNamed:@"defaultGroup.png"];
    
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UIButton *button = [ UIButton buttonWithType:UIButtonTypeCustom ];
    button. backgroundColor = [UIColor clearColor ];
    [button addTarget:self action:@selector(toDeleteButty) forControlEvents:UIControlEventValueChanged];
    // cell. accessoryView = button;
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *groupDic = [self.groupArray objectAtIndex:[indexPath row]];
    GroupDetailsViewController *groupDetailsVC = [[GroupDetailsViewController alloc]init];
    groupDetailsVC.groupJID = [groupDic objectForKey:@"groupJID"];
    
    //self.tabBarController.tabBar.hidden = YES;
    //UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:groupDetailsVC];
    // navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
        //隐藏tabbar
        groupDetailsVC.hidesBottomBarWhenPushed=YES;
        // self.tabBarController.tabBar.hidden = YES;
        
    }else{
        //隐藏tabbar
        groupDetailsVC.hidesBottomBarWhenPushed=YES;
    }
    
    [self.navigationController pushViewController:groupDetailsVC animated:YES];
    
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    GroupChatViewController2 *multiChatCtl = [[GroupChatViewController2 alloc] init];
    NSDictionary *buddyDic = [self.groupArray objectAtIndex:[indexPath row]];
    NSLog(@"%@",[buddyDic objectForKey:@"groupMucId"]);
    multiChatCtl.roomName = [buddyDic objectForKey:@"groupMucId"];
    multiChatCtl.roomNickName = [buddyDic objectForKey:@"groupName"];
    multiChatCtl.title = [buddyDic objectForKey:@"groupName"];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
        //隐藏tabbar
        //self.tabBarController.tabBar.hidden = YES;
        //隐藏tabbar
        multiChatCtl.hidesBottomBarWhenPushed=YES;
        
    }else{
        //隐藏tabbar
        multiChatCtl.hidesBottomBarWhenPushed=YES;
    }
    [self.navigationController pushViewController:multiChatCtl animated:YES];
    
    
    //    MultiUserChatViewCtl *multiChatCtl = [[MultiUserChatViewCtl alloc] init];
    //     NSDictionary *buddyDic = [self.onlineUsers objectAtIndex:[indexPath row]];
    //    multiChatCtl.roomName = [buddyDic objectForKey:@"jid"];
    //    [self.navigationController presentModalViewController:multiChatCtl animated:YES];
    //    [multiChatCtl release];
}


//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
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
        [self deleteGroup:[buddyDic objectForKey:@"groupJID"]];
        
        if (indexPath.section == 0) {
            [self.groupArray removeObjectAtIndex:indexPath.row];
        }else{
            [self.groupArray removeObjectAtIndex:indexPath.row];
        }
        NSLog(@"delete!");
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    }
    
}



-(void)createGroupAddContacts{
    
    GroupNameTableViewController *groupNameTableVC = [[GroupNameTableViewController alloc]init];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
    }else{
        //隐藏tabbar
        self.hidesBottomBarWhenPushed=YES;
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
    // [GroupCRUD deleteMyGroup:groupJID myJID:jid];
    
}


//订阅关系好友
-(void)userInfoReceived:(NSString *)jid nickName:(NSString *)nickName phone:(NSString *)phone avatar:(NSString *)avatar{
    
    NSLog(@"*******************%@",nickName);
    
}

-(void)refreshAllGroupVC{
    self.groupArray =[GroupCRUD queryAllChatGroupByMyJID:MY_JID];
    [_tableView reloadData];
    
}



@end
