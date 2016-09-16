//
//  GroupAddContactsViewController
//  Icicall_ios
//
//  Created by silenceSky  on 14-04-13.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "GroupAddMemberViewController.h"
#import "PullingRefreshTableView.h"
#import "XMPPHelper.h"
#import "sqlite3.h"
#import "UIImageView+WebCache.h"
#import <AudioToolbox/AudioToolbox.h>
#import "GBPathImageView.h"
#import "UserCenterViewController.h"
#import "Utility.h"
#import "ChatBuddyCRUD.h"
#import "CHAppDelegate.h"
#import "ChatViewController2.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "GroupViewController.h"
#import "DejalActivityView.h"
#import "AddressBookCRUD.h"
#import "IdGenerator.h"
#import "GroupMembersCRUD.h"
#import "ContactsCRUD.h"
#import "GroupCRUD.h"
#import "GroupQrCodeViewController.h"
#import "GroupChatViewController2.h"
#import "AIUsersUtility.h"
#import "NSString+Chinese.h"
#import "PublicCURD.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface GroupAddMemberViewController(){
    
    NSString *chatUserName;
    NSString *chatNickName;
    int fromSegmentedFlag;
}

@property (retain,nonatomic) UITableView *tableView;
@property(nonatomic,retain) NSMutableArray *contactsArray;
@property(nonatomic,retain) NSMutableArray *subscriptionUserInfo;
@property(nonatomic,retain) NSMutableArray *buddyNickNameArray;

@property (nonatomic, strong) NSMutableArray *sectionIndexTitles;

@end

@implementation GroupAddMemberViewController
@synthesize contactsArray;
@synthesize subscriptionUserInfo;
@synthesize buddyNickNameArray;
@synthesize tableView = _tableView;
@synthesize groupName = _groupName;
@synthesize fromViewFlag = _fromViewFlag;
@synthesize groupJID = _groupJID;
@synthesize groupMucId = _groupMucId;
@synthesize groupMembers = _groupMembers;
@synthesize lastIndexPath = _lastIndexPath;
@synthesize selectedAddressBookResults = _selectedAddressBookResults;
@synthesize selectedAddressBookJIDResults = _selectedAddressBookJIDResults;
@synthesize selectedAddressBookNickNameResults = _selectedAddressBookNickNameResults;



@synthesize avtarURL = _avtarURL;


//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//
//    }
//    return self;
//}

- (void)dealloc{
    
}


- (NSMutableArray *)sectionIndexTitles
{
    if (!_sectionIndexTitles) {
        _sectionIndexTitles = [@[] mutableCopy];
    }
    return _sectionIndexTitles;
}

#pragma mark - life circle
-(void)loadView{
    [super loadView];
    //设置通知中心，接收邀请圈子成员链接；
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendSMS:)
    //											 name:@"NNC_Received_Group_InviteUrl" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toGroupChat:) name:@"NNC_Received_GroupCreate" object:nil];
     
     
    int cutHeight=0;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
        self.navigationController.navigationBar.translucent = NO;
        
        cutHeight=44;
        
    }else  {
        cutHeight=113;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-cutHeight-65) style:UITableViewStylePlain];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.allowsMultipleSelection = NO;
    [_tableView setEditing:!self.tableView.isEditing animated:YES];
    self.tableView.tag = UITableViewCellAccessoryCheckmark ;
    
    [self.view addSubview:_tableView];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"addCircleMembers.title",@"title");
    selectedResults = [[NSMutableArray alloc]init];
    fromSegmentedFlag = 0;
    
    
//    UIBarButtonItem* btnQR=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"public.qr.name",@"action") style:UIBarButtonItemStylePlain target:self action:@selector(toGroupQR)];
//    [self.navigationItem setRightBarButtonItem:btnQR];
//    
    
    //segmentedControl
    segmentedControl = [[ UISegmentedControl alloc ]
                        initWithItems: nil ];
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        segmentedControl.segmentedControlStyle =
        UISegmentedControlStyleBar;
        segmentedControl.tintColor = kMainColor5;
        segmentedControl.backgroundColor = [UIColor clearColor];
        
    }else{
        segmentedControl.segmentedControlStyle =
        UISegmentedControlStyleBar;
        segmentedControl.tintColor = [UIColor blueColor];
        segmentedControl.backgroundColor = [UIColor clearColor];
        
    }
    [ segmentedControl insertSegmentWithTitle:
     NSLocalizedString(@"public.contacts",@"title") atIndex: 0 animated: NO ];
    [ segmentedControl insertSegmentWithTitle:
     NSLocalizedString(@"public.addressBook",@"title") atIndex: 1 animated: NO ];
    
    [segmentedControl setSelectedSegmentIndex:0];
    
    //self.navigationItem.titleView = segmentedControl;
    
    [segmentedControl addTarget: self
                         action: @selector(controllerPressed:)
               forControlEvents: UIControlEventValueChanged
     ];
    

//    mySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
//    mySearchBar.delegate = self;
//    mySearchBar.barTintColor = AB_Color_f6f2ed;
   
    
    
    mySearchBar = [[UISearchBar alloc] init];
    mySearchBar.delegate = self;
    mySearchBar.barTintColor = AB_Color_f6f2ed;
    [mySearchBar setContentMode:UIViewContentModeScaleAspectFill];
    [mySearchBar setPlaceholder:NSLocalizedString(@"public.search",@"title")];
    
    
    UITextField *txfSearchField = [mySearchBar valueForKey:@"_searchField"];
    txfSearchField.borderStyle = UITextBorderStyleRoundedRect;
    txfSearchField.layer.cornerRadius = 3.0f;
    txfSearchField.layer.masksToBounds = YES;
    txfSearchField.layer.borderWidth = .5;
    txfSearchField.layer.borderColor = [[UIColor colorWithRed:214.0f/255.0f green:200.0f/255.0f blue:179.0f/255.0f alpha:1.0f] CGColor];
    
    
    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:mySearchBar contentsController:self];
    searchDisplayController.active = NO;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView .tableHeaderView = mySearchBar;
    self.tableView.backgroundColor = AB_Color_ffffff;
    self.tableView.tableFooterView = [[UIView alloc] init];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    
    self.contactsArray = [NSMutableArray array];
    self.buddyNickNameArray = [NSMutableArray array];
    
    [self.tableView  reloadData];
    
    [self addToolbar];
    
}

-(void)toGroupQR{
    GroupQrCodeViewController *groupQrCode=[[GroupQrCodeViewController alloc]init];
    groupQrCode.groupJID=_groupJID;
    groupQrCode.groupName=_groupName;
    [self.navigationController pushViewController:groupQrCode animated:YES];
}

//分段控制器
- (void)controllerPressed:(id)sender {
    int selectedSegment = segmentedControl.selectedSegmentIndex;
    if(selectedSegment == 0){
        if ([self.view viewWithTag:200]) {
            [[self.view viewWithTag:200] removeFromSuperview];
        }
        
        [self.contactsArray removeAllObjects];
        [selectedResults removeAllObjects];
        fromSegmentedFlag = 0;
        //[self queryBuddyList:MY_JID];
        self.contactsArray = [ContactsCRUD queryContactsListForAddGroupMembers:MY_JID groupMembers:_groupMembers];
        [_tableView reloadData];
    }else if(selectedSegment == 1){
        //[DejalBezelActivityView activityViewForView:self.view];
        
        if ([self.view viewWithTag:200]) {
            [[self.view viewWithTag:200] removeFromSuperview];
        }
        
        fromSegmentedFlag = 1;
        
        [self.contactsArray removeAllObjects];
        [_tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contactsArray = [AddressBookCRUD queryAddressBookList:MY_JID groupMembers:_groupMembers];
            [_tableView reloadData];
        });
        // [DejalBezelActivityView removeViewAnimated:YES];
        
    }else{
        //    fromSegmentedFlag = 2;
        //
        //        GroupAddMemberByAccountTableViewController *groupAddMemberByAccountNameVC = [[[GroupAddMemberByAccountTableViewController alloc]init]autorelease];
        //        groupAddMemberByAccountNameVC.tableView.tag = 200;
        //
        //        [self.view addSubview:groupAddMemberByAccountNameVC.tableView];
        
        
    }
    
    // NSLog(@"Segment %d selected\n", selectedSegment);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    return self.contactsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        self.searchDisplayController.searchResultsTableView.allowsMultipleSelection = YES;
        [self.searchDisplayController.searchResultsTableView setEditing:YES];
        return searchResults.count;
    }
    else {
        return [self.contactsArray[section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    static NSString *CellIdentifier = @"Cell";
    //    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //    if (cell == nil) {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //    }
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifier2 = @"Cell2";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *cell2 = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    if (fromSegmentedFlag==0) {
        
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        if ([cell viewWithTag:100]) {
            [[cell viewWithTag:100] removeFromSuperview];
        }
        if ([cell viewWithTag:101]) {
            [[cell viewWithTag:101] removeFromSuperview];
        }
        if ([cell viewWithTag:102]) {
            [[cell viewWithTag:102] removeFromSuperview];
        }
        if ([cell viewWithTag:103]) {
            [[cell viewWithTag:103] removeFromSuperview];
        }
        if ([cell viewWithTag:104]) {
            [[cell viewWithTag:104] removeFromSuperview];
        }
        if ([cell viewWithTag:105]) {
            [[cell viewWithTag:105] removeFromSuperview];
        }
        
        
        
        
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            NSDictionary *searchContactsDic = [searchResults objectAtIndex:[indexPath row]];
            //cell.textLabel.text = searchResults[indexPath.row];
            
            //判断搜索结果是否是群组成员
            if ([GroupMembersCRUD group:_groupJID existsMember:searchContactsDic[@"jid"]] ) {
                cell.selectionStyle= UITableViewCellSelectionStyleNone;
                UIImageView * selectedImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 17.0, 22.0, 22.0)];
                selectedImgView.tag = 105;
                selectedImgView.image = [UIImage imageNamed:@"selected_gray.png"];
                [cell addSubview:selectedImgView];
            }
            
            //是否选中
            [selectedResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                // NSLog(@"遍历array：%zi-->%@",idx,obj);
                if([[searchContactsDic objectForKey:@"jid"] isEqualToString:obj]){
                    //UITableViewScrollPositionTop
                    [self.searchDisplayController.searchResultsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:NO];
                }
            }];
            
            cell.textLabel.text = [searchContactsDic objectForKey:@"name"];
            
        }
        else {
            // cell.textLabel.text = dataArray[indexPath.row];
            [cell removeFromSuperview];
            
            //接收到数据，用泡泡VIEW显示出来
            //发送者
            
            NSString *contactsUserName = nil;
            
            NSDictionary *contactsDic = self.contactsArray[indexPath.section][indexPath.row];
            NSString *jidStr = [contactsDic objectForKey:@"jid"];
            NSString*str_character =[NSString stringWithFormat:@"%@",@"@"];
            
            NSRange jidRange = [jidStr rangeOfString:str_character];
            
            if ([jidStr rangeOfString:str_character].location != NSNotFound) {
                contactsUserName = [jidStr substringToIndex:jidRange.location];
            }
            
//            if (indexPath.section ==0) {
            
                // cell.textLabel.text = [self.onlineUsers objectAtIndex:[indexPath row]];
                
                //NSLog(@"name%@",[contactsDic objectForKey:@"name"]);
                // NSLog(@"nickName%@",[contactsDic objectForKey:@"nickName"]);
                if (![[contactsDic objectForKey:@"name"] isEqualToString:@"(null)"] && [contactsDic objectForKey:@"name"] !=NULL && ![[contactsDic objectForKey:@"name"] isEqualToString:@""]){
                    
                    cell.textLabel.text = [contactsDic objectForKey:@"name"];
                    
                }else if (![[contactsDic objectForKey:@"nickName"] isEqualToString:@"(null)"] && [contactsDic objectForKey:@"nickName"]!=NULL && ![[contactsDic objectForKey:@"nickName"] isEqualToString:@""]) {
                    cell.textLabel.text = [contactsDic objectForKey:@"nickName"];
                    
                }else{
                    cell.textLabel.text = contactsUserName;
                    
                }
//            }
            
            UIImageView*photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 50.0, 50.0)];
            
            NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [contactsDic objectForKey:@"avatar"]];
            [photoView setImageWithURL:[NSURL URLWithString:avatarURL]
                      placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
            
            
            CGSize itemSize = CGSizeMake(40, 40);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [photoView.image  drawInRect:imageRect];
            cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            //判断是否是群组成员
            if ([[contactsDic objectForKey:@"isGroupMemebers"] isEqualToString:@"yes"] ) {
                // cell.selectionStyle= UITableViewCellSelectionStyleNone;
                UIImageView * selectedImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 15.0, 22.0, 22.0)];
                selectedImgView.tag = 103;
                selectedImgView.image = [UIImage imageNamed:@"selected_gray.png"];
                [cell addSubview:selectedImgView];
            }
            
            
            
            //是否选中
            [selectedResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                // NSLog(@"遍历array：%zi-->%@",idx,obj);
                if([jidStr isEqualToString:obj]){
                    //UITableViewScrollPositionTop
                    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:NO];
                }
            }];
        }
        cell.backgroundColor = AB_Color_ffffff;
        cell.separatorInset = UIEdgeInsetsMake(0, 37, 0, 0);
        return cell;
    }else if(fromSegmentedFlag==1){
        
        //
        // NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", [indexPath section], [indexPath row]];//以indexPath来唯一确定cell
        //NSString *CellIdentifier=@"Cell2";
        //cell2 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //出列可重用的cell
        
        if (cell2 == nil) {
            cell2 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        
        if ([cell2 viewWithTag:100]) {
            [[cell2 viewWithTag:100] removeFromSuperview];
        }
        if ([cell2 viewWithTag:101]) {
            [[cell2 viewWithTag:101] removeFromSuperview];
        }
        if ([cell2 viewWithTag:102]) {
            [[cell2 viewWithTag:102] removeFromSuperview];
        }
        if ([cell2 viewWithTag:103]) {
            [[cell2 viewWithTag:103] removeFromSuperview];
        }
        if ([cell2 viewWithTag:104]) {
            [[cell2 viewWithTag:104] removeFromSuperview];
        }
        
        if ([cell2 viewWithTag:105]) {
            [[cell2 viewWithTag:105] removeFromSuperview];
        }
        
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            NSDictionary *searchContactsDic = [searchResults objectAtIndex:[indexPath row]];
            //cell.textLabel.text = searchResults[indexPath.row];
            
            //判断搜索结果是否是群组成员
            if ([[searchContactsDic objectForKey:@"isGroupMemebers"] isEqualToString:@"yes"]){
                //cell2.selectionStyle= UITableViewCellSelectionStyleNone;
                UIImageView * selectedImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 15.0, 22.0, 22.0)];
                selectedImgView.tag = 105;
                selectedImgView.image = [UIImage imageNamed:@"selected_gray.png"];
                [cell2 addSubview:selectedImgView];
            }
            
            if ([[searchContactsDic objectForKey:@"phoneNum"]  isEqualToString:_selectedAddressBookResults]) {
                [self.searchDisplayController.searchResultsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:NO];
            }
            
            cell2.textLabel.text = [searchContactsDic objectForKey:@"searchName"];
        }
        else {
            
            //通过通讯录添加圈子成员
            //[cell2 removeFromSuperview];
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,  5, 230, 30)];
            UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,  36, 230, 20)];
            //UILabel *statusLabel = [[[UILabel alloc] initWithFrame:CGRectMake(250, 20, 80, 20)]autorelease];
            
            nameLabel.tag = 100;
            phoneLabel.tag = 101;
            
            
            nameLabel.text = nil;
            phoneLabel.text = nil;
            phoneLabel.font =[UIFont fontWithName:@"Arial" size:12.0f];
            nameLabel.font =[UIFont fontWithName:@"Arial" size:16.0f];
            
            //statusLabel.font =[UIFont fontWithName:@"Arial" size:12.0f];
            //statusLabel.textColor = [UIColor blueColor];
            
            //接收到数据，用泡泡VIEW显示出来
            //发送者
            
            NSDictionary *contactsDic = [self.contactsArray objectAtIndex:[indexPath row]];
            NSString *phoneNum = [contactsDic objectForKey:@"phoneNum"];
            
            if (indexPath.section ==0) {
                // cell.textLabel.text = [self.onlineUsers objectAtIndex:[indexPath row]];
                // NSLog(@"name%@",[contactsDic objectForKey:@"name"]);
                //cell2.textLabel.text = [contactsDic objectForKey:@"name"];
                nameLabel.text = [contactsDic objectForKey:@"name"];
                phoneLabel.text = [contactsDic objectForKey:@"phoneNum"];
                
                [cell2 addSubview:nameLabel];
                [cell2 addSubview:phoneLabel];
                
                
            }
            
            UIImageView*photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 50.0, 50.0)];
            
            if ([contactsDic objectForKey:@"avatar"]!=NULL && ![[contactsDic objectForKey:@"avatar"] isEqualToString:@""]) {
                NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [contactsDic objectForKey:@"avatar"]];
                [photoView setImageWithURL:[NSURL URLWithString:avatarURL]
                          placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
            }
            
            if (photoView.image){
                //NSLog(@"recevice message!");
                //GBPathImageView *squareImage = [[GBPathImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 50.0, 50.0) image:photoView.image pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor whiteColor] pathWidth:0.0];
                
                //cell2.imageView.image=squareImage.image;
                //[squareImage release];
                CGSize itemSize = CGSizeMake(40, 40);
                UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
                CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                [photoView.image  drawInRect:imageRect];
                cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                
            }else{
                UIImage *userImage =[UIImage imageNamed:@"defaultUser.png"];
                //GBPathImageView *squareImage = [[GBPathImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 50.0, 50.0) image:userImage pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor whiteColor] pathWidth:0.0];
                //cell2.imageView.image = squareImage.image;
                //[squareImage release];
                
                CGSize itemSize = CGSizeMake(40, 40);
                UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
                CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                [userImage  drawInRect:imageRect];
                cell2.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                //[userImage release];
                
            }
            // NSLog(@"**********%@",[contactsDic objectForKey:@"isGroupMemebers"]);
            
            
            //判断是否是群组成员
            if ([[contactsDic objectForKey:@"isGroupMemebers"] isEqualToString:@"yes"] ) {
                cell2.selectionStyle= UITableViewCellSelectionStyleNone;
                UIImageView * selectedImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 20.0, 22.0, 22.0)];
                selectedImgView.tag = 104;
                selectedImgView.image = [UIImage imageNamed:@"selected_gray.png"];
                [cell2 addSubview:selectedImgView];
                
            }
            
            if (![[contactsDic objectForKey:@"jid"] isEqualToString:@""]) {
                UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(KCurrWidth-45, 15, 20, 20)];
                imageView.image=[UIImage imageNamed:@"Icon.png"];
                imageView.layer.masksToBounds = YES;
                imageView.layer.cornerRadius = 3.0;
                [cell2 addSubview:imageView];
                
            }
            
            //是否已注册
            //            if (![[contactsDic objectForKey:@"jid"] isEqualToString:@""] && [contactsDic objectForKey:@"jid"]!=NULL && ![[contactsDic objectForKey:@"jid"] isEqualToString:@"(null)"] ) {
            //                //statusLabel.text = @"正在使用";
            //                UIImageView *statusView = [[UIImageView alloc] initWithFrame:CGRectMake(280, 20, 20, 20)];
            //
            //                statusView.tag = 102;
            //                statusView.backgroundColor = [UIColor greenColor];
            //
            //                statusView.image = [UIImage imageNamed:@"AppIcon57x57"];
            //                [cell2 addSubview:statusView];
            //            }
            
            
            //是否选中
            //            [selectedAddressBookResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            //                if([phoneNum isEqualToString:obj]){
            //                    //UITableViewScrollPositionTop
            //                    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:NO];
            //                }
            //            }];
            
            [selectedResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                // NSLog(@"遍历array：%zi-->%@",idx,obj);
                if([phoneNum isEqualToString:obj]){
                    //UITableViewScrollPositionTop
                    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:NO];
                }
            }];
            
            
            
        }
        return cell2;
    }
    
    return cell;
}



//选中一行数据
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (fromSegmentedFlag==0) {
        
        
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            //NSLog(@"选中搜索好友");
            NSDictionary *contactsDic = [searchResults objectAtIndex:[indexPath row]];
            // NSLog(@"%@********",contactsDic);
            [selectedResults addObject:[contactsDic objectForKey:@"jid"]];
            
        }else{
            //NSLog(@"选中好友");
            NSDictionary *contactsDic = self.contactsArray[indexPath.section][indexPath.row];
            [selectedResults addObject:[contactsDic objectForKey:@"jid"]];
            //NSLog(@"$$$$$$$%d",selectedResults.count);
            
        }
    }else if(fromSegmentedFlag==1){
        //注意这要添加手机号码，jid也许为null
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            NSDictionary *contactsDic = [searchResults objectAtIndex:[indexPath row]];
            // NSLog(@"%@********",contactsDic);
            [selectedResults addObject:[contactsDic objectForKey:@"phoneNum"]];
            
            
            
        }else{
            
            NSDictionary *contactsDic = [self.contactsArray objectAtIndex:[indexPath row]];
            [selectedResults addObject:[contactsDic objectForKey:@"phoneNum"]];
            
        }
        
        
        
    }
}

-  (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0.0;
    }
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionIndexTitles[section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionIndexTitles;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = AB_Color_f6f2ed;
}

//取消选中
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (fromSegmentedFlag==0) {
        
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            //NSLog(@"取消选中搜索好友");
            NSDictionary *contactsDic = [searchResults objectAtIndex:[indexPath row]];
            [selectedResults removeObject:[contactsDic objectForKey:@"jid"]];
        }else{
            // NSLog(@"取消选中好友");
            NSDictionary *contactsDic = self.contactsArray[indexPath.section][indexPath.row];
            [selectedResults removeObject:[contactsDic objectForKey:@"jid"]];
            
        }
    }else if(fromSegmentedFlag==1){
        
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            // NSLog(@"取消选中搜索通讯录好友");
            NSDictionary *contactsDic = [searchResults objectAtIndex:[indexPath row]];
            [selectedResults removeObject:[contactsDic objectForKey:@"phoneNum"]];
            
        }else{
            // NSLog(@"取消选中通讯录好友");
            NSDictionary *contactsDic = [self.contactsArray objectAtIndex:[indexPath row]];
            [selectedResults removeObject:[contactsDic objectForKey:@"phoneNum"]];
            
            
        }
        
    }
}



//每次设置为编辑模式之前，都会访问这个方法：
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    if (fromSegmentedFlag==0) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            NSDictionary *searchContactsDic = [searchResults objectAtIndex:[indexPath row]];
            if ([GroupMembersCRUD group:_groupJID existsMember:searchContactsDic[@"jid"]] ) {
                return UITableViewCellEditingStyleNone;
            }
            
        }else{
            NSDictionary *contactsDic = self.contactsArray[indexPath.section][indexPath.row];
            if ([[contactsDic objectForKey:@"isGroupMemebers"] isEqualToString:@"yes"] ) {
                return UITableViewCellEditingStyleNone;
            }
        }
        return self.tableView.tag;
    }
    
    
    if(fromSegmentedFlag==1){
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            NSDictionary *searchContactsDic = [searchResults objectAtIndex:[indexPath row]];
            if ([[searchContactsDic objectForKey:@"isGroupMemebers"] isEqualToString:@"yes"] ) {
                return UITableViewCellEditingStyleNone;
            }
            
        }else{
            NSDictionary *contactsDic = self.contactsArray[indexPath.section][indexPath.row];
            if ([[contactsDic objectForKey:@"isGroupMemebers"] isEqualToString:@"yes"] ) {
                return UITableViewCellEditingStyleNone;
            }
        }
        
        return self.tableView.tag;
        
    }
    return self.tableView.tag;
    
}



//编辑模式的时候，拖动的时候会调用这个方法：
//-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
//    //TODO
//}


//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (kIOS_VERSION>=7.0) {
        return 55;
        
    }else{
        return 60;
    }
}


-(void)addToolbar
{
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                  target:nil action:nil];
    //取消选中
    UIBarButtonItem *cancelBuddyItem = [[UIBarButtonItem alloc]
                                        initWithTitle:NSLocalizedString(@"public.cancelSelected",@"action") style:UIBarButtonItemStyleBordered
                                        target:self action:@selector(cancelSelected)];
    cancelBuddyItem.width = 100;
    cancelBuddyItem.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *saveBuddyItem;
    //区分来源
    // [self.fromViewFlag isEqualToString:@"GroupDetailsViewController"]
    if (_isAddMem) {
        //确定
        saveBuddyItem = [[UIBarButtonItem alloc]
                         initWithTitle:NSLocalizedString(@"public.alert.ok",@"action") style:UIBarButtonItemStyleDone
                         target:self action:@selector(addGroupMember)];
        saveBuddyItem.width = 100;
    }else{
        //确定
        saveBuddyItem = [[UIBarButtonItem alloc]
                         initWithTitle:NSLocalizedString(@"public.alert.ok",@"action") style:UIBarButtonItemStyleDone
                         target:self action:@selector(createGroup)];
        saveBuddyItem.width = 100;
        
    }
    saveBuddyItem.tintColor = [UIColor whiteColor];
    
    
    
    NSArray *toolbarItems = [NSArray arrayWithObjects:
                             cancelBuddyItem,spaceItem, saveBuddyItem, nil];
    UIToolbar *toolbar = nil;
    
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
        
        toolbar = [[UIToolbar alloc]initWithFrame:
                   CGRectMake(0, KCurrHeight-110, KCurrWidth, 50)];
    }else{
        toolbar = [[UIToolbar alloc]initWithFrame:
                   CGRectMake(0, KCurrHeight-110, KCurrWidth, 50)];
    }
    [toolbar setBackgroundImage:[UIImage new]forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [toolbar setShadowImage:[UIImage new]
         forToolbarPosition:UIToolbarPositionAny];
    
    //[toolbar setBarStyle:UIBarStyleDefault];
    toolbar.backgroundColor = AB_Red_Color;
    [self.view addSubview:toolbar];
    [toolbar setItems:toolbarItems];
}


#pragma UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    NSArray *friends = [PublicCURD searchFriendsWithKeyword:searchText];
    
    
    searchResults = [friends mutableCopy];
    [searchDisplayController.searchResultsTableView reloadData];
    
    
//    searchResults = [[NSMutableArray alloc]init];
//    if (mySearchBar.text.length>0&&![ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
//        for (int i=0; i<self.contactsArray.count; i++) {
//            NSDictionary *searchBuddyDic = [self.contactsArray objectAtIndex:i];
//            NSString *userName = nil;
//            
//            NSString *jidStr = [searchBuddyDic objectForKey:@"jid"];
//            //是否群组成员
//            NSString *isGroupMemebers = [searchBuddyDic objectForKey:@"isGroupMemebers"];
//            NSString *phoneNum = [searchBuddyDic objectForKey:@"phoneNum"];
//            
//            NSString*str_character = @"@";
//            NSRange jidRange = [jidStr rangeOfString:str_character];
//            
//            if ([jidStr rangeOfString:str_character].location != NSNotFound) {
//                userName = [jidStr substringToIndex:jidRange.location];
//            }
//            
//            NSString *searchName = @"";
//            if ([searchBuddyDic objectForKey:@"name"]!=NULL && ![[searchBuddyDic objectForKey:@"name"] isEqualToString:@""] && ![[searchBuddyDic objectForKey:@"name"] isEqualToString:@"(null)"]) {
//                searchName = [searchBuddyDic objectForKey:@"name"];
//            }else if ([searchBuddyDic objectForKey:@"nickName"]!=NULL && ![[searchBuddyDic objectForKey:@"nickName"] isEqualToString:@""] && ![[searchBuddyDic objectForKey:@"nickName"] isEqualToString:@"(null)"]) {
//                searchName= [searchBuddyDic objectForKey:@"nickName"];
//                
//            }else{
//                searchName = userName;
//            }
//            
//            if ([ChineseInclude isIncludeChineseInString:searchName]) {
//                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:searchName];
//                NSRange titleResult=[tempPinYinStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
//                if (titleResult.length>0) {
//                    // [searchResults addObject:searchName];
//                    [searchResults addObject:[NSDictionary dictionaryWithObjectsAndKeys:jidStr,@"jid",searchName, @"searchName",phoneNum,
//                                              @"phoneNum",isGroupMemebers,@"isGroupMemebers", nil]];
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
//                    [searchResults addObject:[NSDictionary dictionaryWithObjectsAndKeys:jidStr,@"jid",searchName, @"searchName",phoneNum,
//                                              @"phoneNum",isGroupMemebers,@"isGroupMemebers", nil]];
//                }
//            }
//        }
//    } else if (mySearchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
//        
//        
//        for (NSDictionary *tempDic in self.contactsArray) {
//            NSString *tempStr = @"";
//            NSString *userName = @"";
//            
//            NSString *jidStr = [tempDic objectForKey:@"jid"];
//            //是否群组成员
//            NSString *isGroupMemebers = [tempDic objectForKey:@"isGroupMemebers"];
//            NSString *phoneNum = [ tempDic objectForKey:@"phoneNum"];
//            
//            NSString*str_character = @"@";
//            NSRange jidRange = [jidStr rangeOfString:str_character];
//            
//            if ([jidStr rangeOfString:str_character].location != NSNotFound) {
//                userName = [jidStr substringToIndex:jidRange.location];
//            }
//            
//            if ([tempDic objectForKey:@"name"]!=NULL && ![[tempDic objectForKey:@"name"] isEqualToString:@""] && ![[tempDic objectForKey:@"name"] isEqualToString:@"(null)"]) {
//                tempStr = [tempDic objectForKey:@"name"];
//            }else if ([tempDic objectForKey:@"nickName"]!=NULL && ![[tempDic objectForKey:@"nickName"] isEqualToString:@""] && ![[tempDic objectForKey:@"nickName"] isEqualToString:@"(null)"]) {
//                tempStr= [tempDic objectForKey:@"nickName"];
//                
//            }else{
//                tempStr = userName;
//            }
//            
//            
//            NSRange titleResult=[tempStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
//            if (titleResult.length>0) {
//                //[searchResults addObject:tempStr];
//                [searchResults addObject:[NSDictionary dictionaryWithObjectsAndKeys:jidStr,@"jid",tempStr, @"searchName",phoneNum,
//                                          @"phoneNum",isGroupMemebers,@"isGroupMemebers", nil]];
//            }
//        }
//    }
//    
//    [self.tableView  reloadData];
}



//取消搜索按钮
- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    mySearchBar.text = @"";
    mySearchBar.hidden = NO;
    [self searchBar:mySearchBar activate:NO];
    [self.tableView reloadData];
}


- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active{
    if (!active) {
        [mySearchBar resignFirstResponder];
    }
    
    [mySearchBar setShowsCancelButton:active animated:YES];
    //修改UISearchBar取消按钮字体
    for (id aa in [searchBar subviews]) {
        if ([aa isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)aa;
            [btn setTitle:@"取消" forState:UIControlStateNormal];
        }
    }
}


//改变取消按钮为中文
- (void)searchBarTextDidBeginEditing:(UISearchBar *)hsearchBar
{
    mySearchBar.showsCancelButton = YES;
    for(id cc in [mySearchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
        }
    }
}

//tableview 动画加载效果
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    cell.frame = CGRectMake(-320, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
//    [UIView animateWithDuration:0.7 animations:^{
//        cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
//    } completion:^(BOOL finished) {
//        ;
//    }];
//}


//-(void)queryBuddyList:(NSString *)myJID{
//    [self openDataBase];
//    [self.contactsArray removeAllObjects];
//
//    NSString *selectSqlStr=[NSString stringWithFormat:@"select id,jid,remarkName,nickName,phone,avatar,addTime from Contacts where myJID = \"%@\"",myJID];
//
//    const char *selectSql = [selectSqlStr UTF8String];
//    sqlite3_stmt *statement;
//
//
//    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
//    {
//        NSLog(@"select ok.");
//
//        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
//        {
//
//            // int _id=sqlite3_column_int(statement, 0);
//
//            NSString *jid=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
//
//            NSString *remarkName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
//
//            NSString *nickName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
//
//            NSString *phone=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
//
//            NSString *avatar=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
//
//            NSString *addTime=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 6) encoding:NSUTF8StringEncoding];
//
//            NSString *isGroupMemebers = @"";
//            for (NSDictionary* dic in _groupMembers) {
//
//
//
//                if ([jid isEqualToString:[dic objectForKey:@"jid"]]) {
//                    isGroupMemebers = @"yes";
//                }
//            }
//
//            [self.contactsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",remarkName, @"name",nickName,@"nickName",phone,@"phoneNum",avatar,@"avatar", addTime, @"addTime",isGroupMemebers,@"isGroupMemebers", nil]];
//
//        }
//
//    }
//
//}
//


//取消选中
-(void)cancelSelected{
    [selectedResults removeAllObjects];
    _selectedAddressBookResults = nil;
    [_tableView reloadData];
}

//由临时对话添加成员后转成建群
-(void)createGroup{
    

    
    //    <iq type=”set” to=”circle.nihualao.com”>
    //    <query xmlns=”http://www.nihualao.com/xmpp/circle/create”>
    //    <circle name=””> <members>
    //    <member jid=”” role=”admin” nickname=”” phone=”如果没有开户
    //    可用通讯录中的电话号码”/>
    //    <member jid=”” role=”member” nickname=””/> </members>
    //    </circle> </query>
    //    </iq>
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/create"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
    NSXMLElement *members = [NSXMLElement elementWithName:@"members"];
    
    
    XMPPJID *myJID = [XMPPServer xmppStream].myJID;
    NSString *jid = [NSString stringWithFormat:@"%@",myJID.bareJID];
    NSLog(@"*****%@",jid);
    
    
    [iq addAttributeWithName:@"to" stringValue:GroupDomain];
    
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    
    [circle addAttributeWithName:@"name" stringValue:self.groupName];
    
    NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
    [member addAttributeWithName:@"jid" stringValue:jid];
    [member addAttributeWithName:@"role" stringValue:@"admin"];
    [member addAttributeWithName:@"nickname" stringValue:@""];
    [member addAttributeWithName:@"phone" stringValue:@""];
    [members addChild:member];
    
    NSDictionary* dic = [_groupMembers firstObject];
    NSXMLElement *member1 = [NSXMLElement elementWithName:@"member"];
    [member1 addAttributeWithName:@"jid" stringValue:[dic valueForKey:@"jid"]];
    [member1 addAttributeWithName:@"role" stringValue:@"member"];
    [member1 addAttributeWithName:@"nickname" stringValue:[dic valueForKey:@"nickname"] ];
    [member1 addAttributeWithName:@"phone" stringValue:@""];
    [members addChild:member1];
    
    //遍历
    [selectedResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        // NSLog(@"遍历array：%zi-->%@",idx,obj);
        if(![obj isEqualToString:@""] || obj !=NULL){
            NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
            [member addAttributeWithName:@"jid" stringValue:obj];
            [member addAttributeWithName:@"role" stringValue:@"member"];
            [member addAttributeWithName:@"nickname" stringValue:@""];
            [member addAttributeWithName:@"phone" stringValue:@""];
            [members addChild:member];
            
        }
    }];
    
    [iq addChild:queryElement];
    [queryElement addChild:circle];
    [circle addChild:members];
    
    NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
    //加载动画效果
    [DejalBezelActivityView activityViewForView:self.view];
    
    //[self performSelector:@selector(popToVC:) withObject:@"0" afterDelay:1];
    //1秒后执行
}

-(void)gotoGroupDetailsVC{
    //取消加载动画
    //[DejalBezelActivityView removeViewAnimated:YES];
    //跳转到圈子列表
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    
}


-(void)addGroupMember{
    if(fromSegmentedFlag==0){
        [self addGroupMemberSendIQ];
    }else if(fromSegmentedFlag==1){
        [self sendSMS];
        //        if (![_selectedAddressBookJIDResults isEqualToString:@""] && ![_selectedAddressBookJIDResults isEqualToString:@"null"] && _selectedAddressBookJIDResults != NULL) {
        //            [self addGroupMemberAddressBookSendIQ];
        //        }else{
        //        [self addGroupMemberSendSMS];
        //        }
    }else if(fromSegmentedFlag==2){
        
    }
}

-(void)addGroupMemberSendIQ{
    //    <iq type=”set”>
    //    <query xmlns=”http://www.nihualao.com/xmpp/circle/admin”>
    //    <circle jid=”” name=””remove=”true”>
    //    <!--
    //    remove=true 属性,表示删除圈子
    //    如果仅仅是修改名称,而没有修改成员,则没有 members 元素,members 元素下只包含发送变动的 成员,变动方式可以是添加成员,删除成员,或是修改成员的属性(昵称)
    //    -->
    //    <members>
    //    ￼￼￼￼￼
    //    <member jid=”” nickname=”” remove=”true”/>
    //    <member jid=”” nickname=”” role=”” phone=”如果没有开户可以使
    //    用通讯录中的电话号码”/> </members>
    //    </circle> </query>
    //    </iq>
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/admin"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
    NSXMLElement *members = [NSXMLElement elementWithName:@"members"];
    
    [iq addAttributeWithName:@"to" stringValue:GroupDomain];
    
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    
    [circle addAttributeWithName:@"jid" stringValue:self.groupJID];
    //[circle addAttributeWithName:@"name" stringValue:self.groupName];
    [circle addAttributeWithName:@"name" stringValue:@""];
    
    //遍历
    [selectedResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        // NSLog(@"遍历array：%zi-->%@",idx,obj);
        if(![obj isEqualToString:@""] || obj !=NULL){
            NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
            [member addAttributeWithName:@"jid" stringValue:obj];
            [member addAttributeWithName:@"role" stringValue:@"member"];
            [member addAttributeWithName:@"nickname" stringValue:@""];
            //[member addAttributeWithName:@"phone" stringValue:@""];
            [members addChild:member];
            
        }
    }];
    
    [iq addChild:queryElement];
    [queryElement addChild:circle];
    [circle addChild:members];
    
   // NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
    //加载动画效果
    [DejalBezelActivityView activityViewForView:self.view];
    
    [self performSelector:@selector(popToVC:) withObject:@"0" afterDelay:2];//1秒后执行
    
}

-(void)addGroupMemberAddressBookSendIQ{
    //    <iq type=”set”>
    //    <query xmlns=”http://www.nihualao.com/xmpp/circle/admin”>
    //    <circle jid=”” name=””remove=”true”>
    //    <!--
    //    remove=true 属性,表示删除圈子
    //    如果仅仅是修改名称,而没有修改成员,则没有 members 元素,members 元素下只包含发送变动的 成员,变动方式可以是添加成员,删除成员,或是修改成员的属性(昵称)
    //    -->
    //    <members>
    //    ￼￼￼￼￼
    //    <member jid=”” nickname=”” remove=”true”/>
    //    <member jid=”” nickname=”” role=”” phone=”如果没有开户可以使
    //    用通讯录中的电话号码”/> </members>
    //    </circle> </query>
    //    </iq>
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/admin"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
    NSXMLElement *members = [NSXMLElement elementWithName:@"members"];
    
    [iq addAttributeWithName:@"to" stringValue:GroupDomain];
    
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    
    [circle addAttributeWithName:@"jid" stringValue:self.groupJID];
    [circle addAttributeWithName:@"name" stringValue:self.groupName];
    
    NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
    [member addAttributeWithName:@"jid" stringValue:_selectedAddressBookJIDResults];
    [member addAttributeWithName:@"role" stringValue:@"member"];
    //[member addAttributeWithName:@"nickname" stringValue:_selectedAddressBookNickNameResults];
    [member addAttributeWithName:@"nickname" stringValue:@""];
    //[member addAttributeWithName:@"phone" stringValue:@""];
    [members addChild:member];
    
    [iq addChild:queryElement];
    [queryElement addChild:circle];
    [circle addChild:members];
    
    NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
    //加载动画效果
    [DejalBezelActivityView activityViewForView:self.view];
    
    [self performSelector:@selector(popToVC:) withObject:nil afterDelay:1];//1秒后执行
}

- (void)popToVC:(NSString *)index{
    
    if ([_delegate respondsToSelector:@selector(groupAddMemberViewController:Success:)]) {
        [_delegate groupAddMemberViewController:self Success:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}


-(void)addGroupMemberSendSMS{
    //id 随机生成（须确保无重复）
    NSLog(@"*******%@",[IdGenerator next]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[IdGenerator next] forKey:@"IQ_Query_Group_InvitationURL"];
    
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/admin"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
    NSXMLElement *members = [NSXMLElement elementWithName:@"members"];
    
    [iq addAttributeWithName:@"id" stringValue:[defaults stringForKey:@"IQ_Query_Group_InvitationURL"]];
    
    [iq addAttributeWithName:@"to" stringValue:GroupDomain];
    
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    
    [circle addAttributeWithName:@"jid" stringValue:self.groupJID];
    [circle addAttributeWithName:@"name" stringValue:self.groupName];
    
    
    NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
    [member addAttributeWithName:@"phone" stringValue:_selectedAddressBookResults];
    [member addAttributeWithName:@"role" stringValue:@"member"];
    //[member addAttributeWithName:@"nickname" stringValue:_selectedAddressBookNickNameResults];
    [member addAttributeWithName:@"nickname" stringValue:@""];
    //[member addAttributeWithName:@"phone" stringValue:@""];
    [members addChild:member];
    
    
    [iq addChild:queryElement];
    [queryElement addChild:circle];
    [circle addChild:members];
    
    NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
}


/*---发送短信 start--------------------------------------------------------------------------*/
- (void)sendSMS
{
    // _avtarURL = [NSString stringWithFormat:@"%@/%@",ResourcesURL, avatarURL]
    //加载动画效果
    [DejalBezelActivityView activityViewForView:self.view];
    
    NSLog(@"****%d",selectedResults.count);
    NSString *groupUrl=[[GroupCRUD queryOneMyChatGroup:_groupJID myJID:MY_JID] objectForKey:@"inviteUrl"];
    
    BOOL canSendSMS = [MFMessageComposeViewController canSendText];
    NSLog(@"can send SMS [%d]", canSendSMS);
    if (canSendSMS) {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        picker.navigationBar.tintColor = [UIColor blackColor];
        picker.body = [NSString stringWithFormat:@"点击 %@ 下载,我在邦邦社区等着你呢",groupUrl];
        NSArray *array = selectedResults;
        picker.recipients = array;
        [picker setTitle:@"邀请圈子成员"];//修改短信界面标题
        [self presentViewController:picker animated:YES completion:nil];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                        message:@"该设备不支持短信功能"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    // Notifies users about errors associated with the interface
    //加载动画效果
    [DejalBezelActivityView removeViewAnimated:YES];
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Result: canceled");
            [selectedResults removeAllObjects];
            break;
        case MessageComposeResultSent:
            NSLog(@"Result: Sent");
            [selectedResults removeAllObjects];
            break;
        case MessageComposeResultFailed:
            NSLog(@"Result: Failed");
            [selectedResults removeAllObjects];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    //重新加载数据
    _groupMembers =[GroupMembersCRUD queryChatRoomByGroupJID:_groupJID myJID:MY_JID];
    [self.contactsArray removeAllObjects];
    self.contactsArray = [AddressBookCRUD queryAddressBookList:MY_JID groupMembers:_groupMembers];
    
    [_tableView reloadData];
}


/*---发送短信 end----------------------------------------------------------------------*/


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.contactsArray = [ContactsCRUD queryContactsListForAddGroupMembers:MY_JID groupMembers:_groupMembers];
    
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSDictionary *contact in self.contactsArray) {
        NSMutableDictionary *d = [contact mutableCopy];
        NSString *name = [AIUsersUtility nameForShowWithJID:contact[@"jid"]];
        [d setObject:name forKey:@"name"];
        [temp addObject:d];
    }
    
    NSArray *sortedArray = [self sort:temp];
    NSMutableArray *anotherTemp = [@[] mutableCopy];
    for (NSArray *array in sortedArray) {
        if (array.count) {
            NSDictionary *d = [array lastObject];
            NSString *indexTitile = [[d[@"name"] getPrenameAbbreviation] substringToIndex:1];
            [self.sectionIndexTitles addObject:[indexTitile uppercaseString]];
            [anotherTemp addObject:array];
        }
    }
    self.contactsArray = anotherTemp;
    
    [self.tableView reloadData];
}

- (NSArray *)sort:(NSArray *)array {
    NSDictionary *preletters = @{@"A": @0, @"B": @1, @"C": @2, @"D": @3, @"E": @4, @"F": @5, @"G":@6,
                                 @"H": @7, @"I": @8, @"J": @9, @"K": @10, @"L": @11, @"M": @12,
                                 @"N": @13, @"O": @14, @"P": @15, @"Q": @16, @"R": @17, @"S": @18,
                                 @"T": @19, @"U": @20, @"V": @21, @"W": @22, @"X": @23,@"Y": @24,
                                 @"Z": @25};
    
    NSMutableArray *sortedContacts = [NSMutableArray array];
    for (NSInteger i = 0; i < preletters.allKeys.count; ++i) {
        [sortedContacts addObject:[@[] mutableCopy]];
    }
    
    for (NSDictionary *d in array) {
        NSString *headerLetter = [[d[@"name"] getPrenameAbbreviation] substringToIndex:1];
        NSInteger index = [preletters[headerLetter.uppercaseString] integerValue];
        NSMutableArray *subarray = sortedContacts[index];
        [subarray addObject:d];
    }
    return sortedContacts;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


-(void)toGroupChat:(NSNotification*) cent{
    
    NSMutableArray *array =  cent.object;
    
    GroupChatViewController2 *groupChatVC = [[GroupChatViewController2 alloc] init];
   
    ChatGroup* group = [array firstObject];
    groupChatVC.roomName = group.groupMucId;
    groupChatVC.roomNickName = group.name;
    groupChatVC.hidesBottomBarWhenPushed = YES;
    

    [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0],groupChatVC] animated:YES];
    //[self.navigationController pushViewController:groupChatVC animated:YES];
}


-(void)dismissVC{
      
      [self.navigationController popToRootViewControllerAnimated:YES];
      CHAppDelegate *delegate=(CHAppDelegate*)[[UIApplication sharedApplication]delegate];
      delegate.tabBarController.tabBar.hidden = NO;
      [delegate.tabBarController setSelectedIndex:0];
      
 }



@end
