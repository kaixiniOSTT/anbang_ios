//
//  ContactsViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 14-4-26.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "ContactsViewController2.h"
#import "pinyin.h"
#import "ChineseString.h"
#import "Contacts.h"
#import "ChatViewController2.h"
#import "ContactsDetailsViewController.h"
#import "GroupViewController.h"
#import "GBPathImageView.h"
#import "ContactsCRUD.h"
#import "UserInfoCRUD.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "InvitationFriendsViewController.h"
#import "AddressBookViewController.h"
#import "IdGenerator.h"
#import "InvitationURLViewController.h"
#import "InvitationFriendsViewControllerNew.h"
#import "InvitationURLViewControllerNew.h"
#import "AddressBookViewController3.h"

#import "DejalActivityView.h"
#import "ChatInit.h"

#import "UIButton+Bootstrap.h"
#import "ChatBuddyCRUD.h"
#import "ChatMessageCRUD.h"
#import "JSMessageSoundEffect.h"
#import "UIImageView+WebCache.h"
#import "UIColor+CustomColors.h"
#import "GroupCRUD.h"
#import "ImageUtility.h"
#import "GroupDetailsViewController.h"
#import "GroupNameTableViewController.h"
#import "GroupAddContactsViewController.h"
#import "GroupQrCodeViewController.h"
#import "APPRTCViewController.h"
#import "KxMenu.h"
#import "ScanViewController.h"
#import "MyServices.h"
#import "ABContactSelectedVC.h"
#import "AddFriendVCTableViewController.h"
#import "MyGroupViewController.h"
#import "GroupCreateViewController.h"
#import "UserInfo.h"
#import "ContactInfo.h"
#import "AIUIWebViewController.h"
#import "ContactsCell.h"
#import "NSString+Chinese.h"
#import "AINewFriendViewController.h"
#import "AINewFriendsCRUD.h"
#import "JSBadgeView.h"
#import "PublicCURD.h"
#import "AISearchContactViewController.h"
#import "MDNomalQuanViewController.h"
#define AB_Icon_Tag 1546

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface ContactsViewController2 ()<UISearchDisplayDelegate>
{
    NSTimer* contactsTitleTimer;
    NSString * addFriendsCount;
    NSMutableArray *searchResults;
    int accountType;
    BOOL  mRightBarButtonSelected;
    NSArray *mSearchFormats;
}
@property (nonatomic, strong) dispatch_queue_t dispathQueue;
@end

@implementation ContactsViewController2

@synthesize myJID = _myJID;
@synthesize dataArr = _dataArr;
@synthesize sortedArrForArrays = _sortedArrForArrays;
@synthesize sectionHeadsKeys = _sectionHeadsKeys;
@synthesize groupArray;
@synthesize groupName;
@synthesize clickGroupFlag ;


- (void)didReceiveMemoryWarning
{
    NSLog(@"内存警告-联系人");
    // NSLog(@"~~~~~~~~~~~~~~level~~~~~~~~~~~~~~~ %d", (int)OSMemoryNotificationCurrentLevel());
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
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_AddContacts" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_KxMenu_Dismiss" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_Get_Organization_List_Return" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_New_Friends_List_Load_Finished" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_New_Friend_Request" object:nil];
    
    mTimer = nil;
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newFriendsListLoadFinished)
                                                     name:@"AI_New_Friends_List_Load_Finished"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(aNewFriendRequest)
                                                     name:@"AI_New_Friend_Request"
                                                   object:nil];
    }
    return self;
}

- (void)newFriendsListLoadFinished {
    [self setTabBarItemBadgeValue];
}

- (void)aNewFriendRequest {
    [self setTabBarItemBadgeValue];
    // reload "New Friend" index path
    [self.tableView reloadData];
}

- (void)abOrganizationListReturn:(NSNotification *)nitfy
{
    [mTimer invalidate];
    mIsSendOrganizationIQ = NO;
}

- (void)sendOrganizationIQ
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *ver = [defaults objectForKey:kOrganization_Contact_Ver];
        if (!ver) { ver = @"0"; }
        NSXMLElement * iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"id" stringValue:@"AI_Get_Organization_List"];
        [iq addAttributeWithName:@"type" stringValue:@"get"];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:kOrganizationSpace];
        [query addAttributeWithName:@"ver" stringValue:ver];
        
        [iq addChild:query];
        
        JLLog_I(@"<Organizations IQ=%@>", iq);
        [[XMPPServer xmppStream] sendElement:iq];
    });
}

- (void)countDown:(NSTimer *)timer
{
    if(mTimeout <= 0) {
        mIsSendOrganizationIQ = NO;
        [mTimer invalidate];
        return;
    }
    --mTimeout;
}

- (void)startSendOrganizationIQ
{
    if(mIsSendOrganizationIQ) return;
    
    mIsSendOrganizationIQ = YES;
    mTimeout = 90;
    mTimer = [NSTimer timerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(countDown:)
                                   userInfo:nil
                                    repeats:YES];
    [self sendOrganizationIQ];
}

- (void)setupNavigationItem {
    [self.navigationItem setTitle:NSLocalizedString(@"contacts.contacts",@"title")];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake(0, 0, 30, 30);
    [button setImage:[UIImage imageNamed:@"header_btn_plus"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:item];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuAutoRelease:)
                                                 name:@"AI_KxMenu_Dismiss"
                                               object:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
    //设置通知中心，刷新数据
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(contactsLoadFinish) name:@"CNN_Contacts_LoadFinish" object:nil];
    
    //设置通知中心，添加好友时刷新；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addFriendsSuccess:)
                                                 name:@"NNC_AddContacts" object:nil];
    
    //设置通知中心，修改好友备注时刷新；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactsLoadFinish)
                                                 name:@"NNC_UpdateContact" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(abOrganizationListReturn:)
                                                 name:@"AI_Get_Organization_List_Return"
                                               object:nil];
}

- (void)setTabBarItemBadgeValue {
    dispatch_async(self.dispathQueue, ^{
        NSInteger count = [AINewFriendsCRUD unreadCount];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *value = count ? [NSString stringWithFormat:@"%d", count] : nil;
            // self.tabBarItem would not work
            // because parent controller is the navigationController
            self.navigationController.tabBarItem.badgeValue = value;
        });
    });
}

- (dispatch_queue_t)dispathQueue {
    if (!_dispathQueue) {
        _dispathQueue = dispatch_queue_create("contact_view_controller_queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _dispathQueue;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigationItem];
    [self setupNotifications];
    
    UserInfo * userInfo = [UserInfo loadArchive];
    accountType = userInfo.accountType;

    //[self initData];

    NSTimer *timer;
    int timeInt = 1;
    timer=[NSTimer scheduledTimerWithTimeInterval:timeInt
                                           target:self
                                         selector:@selector(contactsLoadFinish)
                                         userInfo:nil
                                          repeats:NO];
    
    // [self contactsLoadFinish];
    
    //下拉刷新
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor lightGrayColor];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"  "];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    
    self.view.backgroundColor = Controller_View_Color;
    self.tableView.backgroundColor = [UIColor clearColor];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 17)];
        [self.tableView setSeparatorColor:Table_View_Separator_Color];
    }

    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorColor = AB_Color_f4f0eb;
    //添加搜索栏
    
    mySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0,Screen_Width, 40)];
    mySearchBar.delegate = self;
    [mySearchBar setPlaceholder:NSLocalizedString(@"chat.search",@"action")];
    mySearchBar.barTintColor = AB_Color_f6f2ed;
    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:mySearchBar contentsController:self];
    searchDisplayController.active = NO;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.delegate = self;
    
    self.tableView.tableHeaderView = mySearchBar;
//    mySearchBar.backgroundImage = [UIImage imageNamed:@"chat_group_back"];
    [mySearchBar setImage:[UIImage imageNamed:@"icon_search01"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc]init];
    //添加搜索框文本框的边框
    UITextField *txfSearchField = [mySearchBar valueForKey:@"_searchField"];
    txfSearchField.borderStyle = UITextBorderStyleRoundedRect;
    txfSearchField.layer.cornerRadius = 3.0f;
    txfSearchField.layer.masksToBounds = YES;
    txfSearchField.layer.borderWidth = .5;
    txfSearchField.layer.borderColor = [[UIColor colorWithRed:214.0f/255.0f green:200.0f/255.0f blue:179.0f/255.0f alpha:1.0f] CGColor];//AB_Color_e7e2dd.CGColor;
    
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    if (self.navigationController.viewControllers.count == 1){
//        return NO;
//    } else {
//        return YES;
//    }
//}

- (void)dismissSearchViewController {
    if (searchDisplayController.active) {
        [searchDisplayController setActive:NO animated:NO];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self dismissMenu];
    [self dismissSearchViewController];
}

#pragma mark -
#pragma mark create method

- (void)initData {
    
    _dataArr = nil;
    _sortedArrForArrays = nil;
    _sectionHeadsKeys = nil;
    
    _dataArr = [[NSMutableArray alloc] init];
    _sortedArrForArrays = [[NSMutableArray alloc] init];
    _sectionHeadsKeys = [[NSMutableArray alloc] init];
    
    _dataArr = [ContactsCRUD queryContactsListTwo:MY_JID];
    
    _sortedArrForArrays = [self getChineseStringArr:_dataArr];
    
    UserInfo * userInfo = [UserInfo loadArchive];
    accountType = userInfo.accountType;
    if(accountType == 2) {
        self.contactOtherArray =  @[@"新的朋友" ,@"安邦通讯录", @"我的资源", @"群聊"];
        [self startSendOrganizationIQ];
    } else {
        self.contactOtherArray =  @[@"新的朋友" , @"群聊"];
    }
    
    //    _sectionHeadsKeysAll = [NSMutableArray arrayWithObjects:
    //                            @"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tableView){
        
        if(section == 0){
            
            return self.contactOtherArray.count;
        }else{
            return  [[self.sortedArrForArrays objectAtIndex:section-1] count];
        }
    }else{
        return  searchResults.count;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == self.tableView){
        return [self.sortedArrForArrays count] + 1;
    }else{
        if (searchResults.count == 0) {
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.0;
    }
    return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView)
    {
        if (_sectionHeadsKeys.count > 1) {
            
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
            label.text = [_sectionHeadsKeys objectAtIndex:section];
            [view addSubview:label];
            
            return view;
        }
        
    }
    
    return nil;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    if(tableView == self.tableView)
//    {
//        if (section == 0 ) {
//            return @"";
//            
//        }else{
//            if(_sectionHeadsKeys.count>1){
    return self.sectionHeadsKeys[section];
//            }
//        }
//    }
//    
//    return @"";
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if(tableView == self.tableView){
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
            //tableView.sectionIndexBackgroundColor = [UIColor colorFromHexString:@"#f6f2ed"];
            tableView.sectionIndexBackgroundColor = [UIColor clearColor];
            tableView.sectionIndexColor = AB_Gray_Color;

        }
        return self.sectionHeadsKeys;
    }
    return nil;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"CellId";
    ContactsCell *cell = [[ContactsCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:cellId];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
    // cell would not be nil, because every cell is allocated for a row.
    if (cell == nil) {
        cell = [[ContactsCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:cellId];
        
    }
    
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        Contacts* contact = (Contacts*)searchResults[indexPath.row];
        NSString *text = nil;
        if (contact.remarkName.length > 0) {
            text = [NSString stringWithFormat:@"%@(%@)", contact.remarkName, contact.nickName];
        }else {
            text = contact.nickName;
        }
        cell.lableName.text = text;
        NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, contact.avatar];
        [cell.pictureImage  setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
        return cell;
    }
    
    if(indexPath.section == 0){
        NSString* tempStr = [_contactOtherArray objectAtIndex:indexPath.row];
        if([tempStr isEqualToString:@"新的朋友"]){
            dispatch_async(self.dispathQueue, ^{
                NSInteger count = [AINewFriendsCRUD unreadCount];
                JSBadgeView *badgeView = (JSBadgeView *)[cell viewWithTag:5641];
                [badgeView removeFromSuperview];
                if (count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                    // Because every cell is new, so just go ahead alloc
                  JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:cell.lableName
                                                                         alignment:JSBadgeViewAlignmentCenterLeft];
                        
                      
                        badgeView.badgePositionAdjustment = CGPointMake(badgeView.badgePositionAdjustment.x+ 75, badgeView.badgePositionAdjustment.y);
                        badgeView.tag = 5641;
                        badgeView.badgeText = [NSString stringWithFormat:@"%d", count];
                    });
                }
            });
            cell.pictureImage.image = [UIImage imageNamed:@"adbook_icon_newfriend"];
        }else if([tempStr isEqualToString:@"安邦通讯录"]){
            cell.pictureImage.image = [UIImage imageNamed:@"adbook_icon_abAddr"];
        }else if([tempStr isEqualToString:@"我的资源"]){
            cell.pictureImage.image = [UIImage imageNamed:@"adbook_icon_mySource"];
        }else if([tempStr isEqualToString:@"群聊"]){
            cell.pictureImage.image = [UIImage imageNamed:@"adbook_icon_group"];
        }
        
        cell.pictureImage.layer.masksToBounds = YES;
        cell.pictureImage.layer.cornerRadius = 3.0;
        
        cell.lableName.text = tempStr;
        
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
        
        return cell;
    }
    
    if ([_sortedArrForArrays count] > indexPath.section-1) {
        NSArray *arr = [_sortedArrForArrays objectAtIndex:indexPath.section-1];
        if ([arr count] > indexPath.row) {
            Contacts *str = (Contacts *) [arr objectAtIndex:indexPath.row];
            //cell.textLabel.text = str.string;
            NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, str.avatar];
            [cell.pictureImage  setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
           
            
            UIImageView *icon = (UIImageView *)[cell.imageView viewWithTag:AB_Icon_Tag];
            if (!icon) {
                UIImageView *abIcon = [[UIImageView alloc] init];
                CGFloat imgWidth = CGRectGetWidth(cell.pictureImage.frame);
                CGFloat ratio = imgWidth/45.0;
                CGFloat w = 16 * ratio;
                CGFloat h = 11 * ratio;
                abIcon.frame = CGRectMake(imgWidth-w, imgWidth-h, w, h);
                abIcon.image = [UIImage imageNamed:@"icon_ab01"];
                abIcon.tag = AB_Icon_Tag;
                [cell.pictureImage addSubview:abIcon];
                icon = abIcon;
            }
            icon.hidden = str.accountType == 2 ? NO : YES;
            
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 2, 200, 30)];
            nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [nameLabel setText:str.string];
            nameLabel.font = [UIFont systemFontOfSize:16];
            nameLabel.textColor = [UIColor blackColor];
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.backgroundColor = [UIColor clearColor];
            
            // [cell.contentView addSubview:nameLabel];
            cell.lableName.text = str.string;
            cell.pictureImage.layer.masksToBounds = YES;
            cell.pictureImage.layer.cornerRadius = 3.0;
            
            UIImage *sendBtnBackground = [UIImage imageNamed:@"user_call"];
            UIButton* callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            callBtn.frame = CGRectMake(80, 35, 25, 25);
            callBtn.imageView.frame = CGRectMake(KCurrWidth - 45, 10, 20, 20);
            [callBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
            [callBtn addTarget:self action:@selector(playDial:) forControlEvents:UIControlEventTouchUpInside];
            [callBtn setImage:sendBtnBackground forState:UIControlStateNormal];
            [callBtn setTintColor:[UIColor grayColor]];
            callBtn.backgroundColor = [UIColor clearColor];
            [callBtn.layer setCornerRadius:5.0];
            callBtn.tag = indexPath.row;
            
        } else {
            NSLog(@"arr out of range");
        }
    } else {
        NSLog(@"sortedArrForArrays out of range");
    }
    
//    cell.imageView.layer.masksToBounds = YES;
//    cell.imageView.layer.cornerRadius = 3.0;
//    cell.imageView.layer.borderWidth = 0.0;
//    cell.imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
//    
//    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
//    cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
    
    return cell;
}



//发送文本消息
-(void)sendMassage:(NSString *)message jid:(NSString *)jid
{
    //随机ID
    NSString * msgRandomId = [IdGenerator next];
    NSString *timeString=Utility.getCurrentDate;
    //开始发送
    if (message.length > 0) {
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        //消息类型
        NSXMLElement *subject = [NSXMLElement elementWithName:@"subject"];
        [subject setStringValue:@"chat"];
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息ID
        [mes addAttributeWithName:@"id" stringValue:msgRandomId];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:jid];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:MY_USER_NAME];
        //发送时间
        [mes addAttributeWithName:@"time" stringValue:timeString];
        //组合
        [mes addChild:subject];
        [mes addChild:body];
        //NSLog(@"%@",mes);
        //发送消息
        [[XMPPServer xmppStream] sendElement:mes];
    }
    NSString *userName = @"";
    NSString*str_character = @"@";
    NSRange senderRange = [jid rangeOfString:str_character];
    if ([jid rangeOfString:str_character].location != NSNotFound) {
        userName =[jid substringToIndex:senderRange.location];
    }
    
    //检测网络情况
    NSString *network = @"connection";
    NSString *sendTimeStr =[Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    NSString *sendUTCTimeStr = [Utility getUTCFormateLocalDate:sendTimeStr];
    //消息写入数据库
    //发送消息时 receiveTime 与 sendTime 一致
    [ChatMessageCRUD insertChatMessage:MY_USER_NAME msg:message receiveUser:userName msgType:@"chat" subject:@"chat" sendTime:sendUTCTimeStr receiveTime:sendUTCTimeStr readMark:1 sendStatus:network msgRandomId:msgRandomId myJID:MY_JID];

    //查询聊天列表是否存在
    Contacts *contacts = nil;
    contacts = [ChatBuddyCRUD queryBuddyByJID:jid myJID:MY_JID];
    NSString *lastMsgTime = [Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    //查询聊天列表是否已存在
    if ([ChatBuddyCRUD queryChatBuddyTableCountId:userName myUserName:MY_USER_NAME]==0){
        
        [ChatBuddyCRUD insertChatBuddyTable:userName jid:contacts.jid name:contacts.remarkName nickName:contacts.nickName phone:contacts.phone avatar:contacts.avatar myUserName:MY_USER_NAME type:@"chat" lastMsg:message msgType:@"chat" msgSubject:@"chat" lastMsgTime:lastMsgTime tag:@""];
        
    }else{
        [ChatBuddyCRUD updateChatBuddy:userName name:contacts.remarkName nickName:contacts.nickName lastMsg:message msgType:@"chat" msgSubject:@"chat" lastMsgTime:lastMsgTime];
    }
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //start a Chat
    
    // [self updateTable:chatUserName];
    //   [self.tableView reloadRowsAtIndexPaths:indexPath.row withRowAnimation:YES];
    
    
    if(tableView == self.searchDisplayController.searchResultsTableView){
        Contacts* contact = (Contacts*)searchResults[indexPath.row];
        ContactInfo *contactInfo = [[ContactInfo alloc] initWithNibName:@"ContactInfo" bundle:nil];
        contactInfo.jid = contact.jid;
        contactInfo.hidesBottomBarWhenPushed = YES;
       
        [self.navigationController pushViewController:contactInfo animated:YES];
        [searchDisplayController setActive:NO animated:NO];
        
    }else{
        NSString* otherStr = ((ContactsCell*)[tableView cellForRowAtIndexPath:indexPath]).lableName.text;
        
        if (indexPath.section == 0 && [otherStr isEqualToString:@"新的朋友"]  ) {
            AINewFriendViewController *controller = [[AINewFriendViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
            return;
        }
        
        if (indexPath.section == 0 && [otherStr isEqualToString:@"安邦通讯录"]) {
            ABContactSelectedVC* selectVC = [[ABContactSelectedVC alloc]init];
            selectVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:selectVC animated:YES];
            return;
        }
        
        if (indexPath.section == 0 && [otherStr isEqualToString:@"我的资源"]) {
            AIUIWebViewController *controller = [[AIUIWebViewController alloc] init];
            controller.usingToken = YES;
            controller.usingCache = NO;
            controller.url = [[NSUserDefaults standardUserDefaults]stringForKey:@"NSUD_RESOURCE_ADDRESS"];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
            return;
        }
        
        if (indexPath.section == 0 && [otherStr isEqualToString:@"群聊"]) {
            MDNomalQuanViewController * fvc = [[MDNomalQuanViewController alloc]init];
            fvc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:fvc animated:YES];

            
            
            //[self addContactsActionSheet];
            //[self invitationFriends];
//            MyGroupViewController* myGroupVC = [[MyGroupViewController alloc] initWithStyle:UITableViewStylePlain];
//            myGroupVC.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:myGroupVC animated:YES];
            
            return;
        }
        
        
        //    if (self.groupArray.count>0) {
        //        if (indexPath.section==0 && indexPath.row!=0) {
        //
        //            NSDictionary *groupDic = [self.groupArray objectAtIndex:[indexPath row]-1];
        //            GroupDetailsViewController *groupDetailsVC = [[GroupDetailsViewController alloc]init];
        //            groupDetailsVC.groupJID = [groupDic objectForKey:@"groupJID"];
        //            groupDetailsVC.hidesBottomBarWhenPushed=YES;
        //            [self.navigationController pushViewController:groupDetailsVC animated:YES];
        //            return;
        //        }
        //    }
        
        NSString *contactsJID = @"";
        NSString *contactsUserName = @"";
        NSString *contactsRemarkName = @"";
        NSString *contactsNickName = @"";
        NSString *contactsAvatarURL = @"";
        
        if ([self.sortedArrForArrays count] > indexPath.section-1) {
            NSArray *arr = [self.sortedArrForArrays objectAtIndex:indexPath.section-1];
            if ([arr count] > indexPath.row) {
                Contacts *contacts = (Contacts *) [arr objectAtIndex:indexPath.row];
                
                //NSLog(@"******%@",contacts.userName);
                
                contactsJID = contacts.jid;
                contactsUserName = contacts.jid;
                contactsRemarkName = contacts.remarkName;
                contactsNickName = contacts.nickName;
                
                if (contacts.avatar!=NULL && ![contacts.avatar isEqualToString:@""]) {
                    contactsAvatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, contacts.avatar];
                }
                
                
                NSString*str_character = @"@";
                NSRange senderRange = [contactsUserName rangeOfString:str_character];
                
                if ([contactsUserName rangeOfString:str_character].location != NSNotFound) {
                    contactsUserName = [contactsUserName substringToIndex:senderRange.location];
                }
                //            if (![contacts.string isEqualToString:@""] || contacts.string != NULL) {
                //                contactsRemarkName = contacts.string;
                //            }else{
                //
                //            }
                // ChatViewController2 * chatViewCtl=[[ChatViewController2 alloc] initWithNibName:@"ChatViewController2" bundle:nil];
                // chatViewCtl.chatWithUser = chatUserName;
                // chatViewCtl.chatWithNick = chatNickName;
                //这里usrName 为 jid  以后将作更改
                //chatViewCtl.chatWithJID  = str.userName;
                //chatViewCtl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                //chatViewCtl.title = chatNickName;
                
                ContactInfo *contactInfo = [[ContactInfo alloc] initWithNibName:@"ContactInfo" bundle:nil];
                contactInfo.jid = contacts.jid;
                contactInfo.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:contactInfo animated:YES];
                
                //            [self.navigationController pushViewController:contactInfo animated:YES];
                //            ContactsDetailsViewController *contactsDetailsVC=[[ContactsDetailsViewController alloc] initWithNibName:@"ContactsDetailsViewController" bundle:nil];
                //            contactsDetailsVC.contactsJID = contactsJID;
                //            contactsDetailsVC.contactsUserName = contactsUserName;
                //            contactsDetailsVC.contactsRemarkName = contactsRemarkName;
                //            contactsDetailsVC.contactsNickName = contactsNickName;;
                //            contactsDetailsVC.contactsAvatarURL = contactsAvatarURL;
                //            //隐藏tabbar
                //            contactsDetailsVC.hidesBottomBarWhenPushed=YES;
                //            [self.navigationController pushViewController :contactsDetailsVC animated:YES];
                
            } else {
                NSLog(@"arr out of range");
            }
        } else {
            NSLog(@"sortedArrForArrays out of range");
        }

    }

}

// 指定tableview可删除的区域
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section==0?NO:YES;
}
//可删除的cell
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView
//          editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
////    NSUInteger row = [indexPath row];
////    if (row == [groups count]) {
////        return UITableViewCellEditingStyleNone;
////    }else {
////        return UITableViewCellEditingStyleDelete;
////    }
//
//    return UITableViewCellEditingStyleDelete;
//}

//tableView的编辑模式中当提交一个编辑操作时候调用：比如删除，添加等
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSArray *arr = [self.sortedArrForArrays objectAtIndex:indexPath.section-1];
        Contacts *contacts = (Contacts *) [arr objectAtIndex:indexPath.row];
        NSString *contactsUserName = contacts.jid;
        // NSLog(@"contactsUserName:%@",contacts.jid);
        [self removeContacts:contactsUserName];
        //  NSLog(@"*****%d",indexPath.section);
        //  NSLog(@"*****%d",indexPath.row);
        
        [[self.sortedArrForArrays objectAtIndex:indexPath.section-1]  removeObjectAtIndex:indexPath.row];
        
        NSLog(@"delete!");
        //NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:indexPath.row inSection:1];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationTop];
    
        
        if([[self.sortedArrForArrays objectAtIndex:indexPath.section-1] count] == 0){
            
            [self.sortedArrForArrays removeObjectAtIndex:indexPath.section - 1];
            NSIndexSet* indexset = [NSIndexSet indexSetWithIndex:indexPath.section];
            
            [self.tableView deleteSections:indexset withRowAnimation:UITableViewRowAnimationTop];
            
            [_sectionHeadsKeys removeObjectAtIndex:indexPath.section - 1];
        }
        
        
        [ContactsCRUD deleteContactsByChatUserName:contactsUserName];
        //刷新
        // [_tableView reloadData];
        
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        return 50;
    }
    
    return 42.0;
}


//删除好友，name为好友账号
- (void)removeContacts:(NSString *)contactsUserName
{
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",contactsUserName]];
    [[XMPPServer xmppRoster] removeUser:jid];
}


- (void)addContactsActionSheet
{
    UIActionSheet *menu=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"contacts.inviteFridend.actionSheetTitle",@"title") delegate:self cancelButtonTitle:NSLocalizedString(@"contacts.inviteFridend.cancel",@"action") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"contacts.inviteFridend.mobilePhoneNumberToInvite",@"action"),NSLocalizedString(@"contacts.inviteFridend.urlToInvite",@"action"),nil];
    menu.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
    [menu showInView:self.view.window];
    
}


#pragma mark -UIAlearView delegate
-(void)addFriendsAlerview{
    UIAlertView* addFriendsAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"contacts.addContacts.addContact",@"title")
                                                              message:NSLocalizedString(@"contacts.addContacts.enterUserID",@"title")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"contacts.addContacts.cancel",@"action")
                                                    otherButtonTitles:NSLocalizedString(@"contacts.addContacts.add",@"action"), nil];
    addFriendsAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    addFriendsAlert.tag=30000;
    [addFriendsAlert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==30000) {
        if (buttonIndex==1) {
            UITextField *tf = [alertView textFieldAtIndex:0];
            addFriendsCount = tf.text;
            [tf setKeyboardType:UIKeyboardTypeNumberPad];  //调用键盘格式
            if ([tf.text isEqual:@""]) {
                return;
            }
            unichar single=[tf.text characterAtIndex:0];
            if (single >='0' && single<='9'){
                [DejalBezelActivityView activityViewForView:self.view];
                /*判断用户是否存在*/
                NSString *url=[NSString stringWithFormat:@"%@/security-question?username=%@",httpRequset,tf.text];
                
                NSLog(@"JLLog/info/ContactsViewController <查询用户=%@ logline=%d>",httpRequset,789);
                
                [[NSUserDefaults standardUserDefaults] setObject:tf.text forKey:@"txtid"];
                NSError *error;
                //加载一个NSURL对象
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                //将请求的url数据放到NSData对象中
                NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                if (response==nil) {
                    [DejalBezelActivityView removeViewAnimated:YES];
                    //网络未连接
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"contacts.addContacts.error",@"title") message:NSLocalizedString(@"contacts.addContacts.pleaseCheckTheNetwork",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"contacts.addContacts.ok",@"action") otherButtonTitles:nil, nil];
                    [alert show];
                    
                    
                }else{
                    
                    //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
                    NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
                    NSString *nameInfo = [weatherDic objectForKey:@"msg"];
                    //code=8 用户不存在
                    int code = [[weatherDic objectForKey:@"code"] intValue];
                    if (code==8) {
                        [DejalBezelActivityView removeViewAnimated:YES];
                        
                        UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"contacts.addContacts.prompt",@"title") message:nameInfo delegate:self cancelButtonTitle:NSLocalizedString(@"contacts.addContacts.ok",@"action") otherButtonTitles:nil, nil];
                        [alerView show];
                        return;
                    }else{
                        // XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",tf.text,OpenFireHostName]];
                        //    [[XMPPServer xmppRoster] acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
                        // [[XMPPServer xmppRoster]  subscribePresenceToUser:jid];
                        NSString * jid = [NSString stringWithFormat:@"%@@%@",tf.text,OpenFireHostName];
                        
                        NSLog(@"JLLog/info/ContactsViewController <friendjid=%@, logline=%d>",jid,823);
                        
                        [ChatInit queryContactsUserInfo:jid];
                    }
                }
            }else{
                UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"contacts.addContacts.prompt",@"title") message:NSLocalizedString(@"contacts.addContacts.accountNumberFormatError",@"message")delegate:self cancelButtonTitle:NSLocalizedString(@"contacts.addContacts.ok",@"action") otherButtonTitles:nil, nil];
                [alerView show];
            }
        }
        
    }else if(alertView.tag==30001){
        self.clickGroupFlag = @"contacts";
        if (buttonIndex==1) {
            [self createGroup];
            
        }else{
            return;
        }
    }else if(alertView.tag==30002){
        self.clickGroupFlag = @"qrcode";
        if (buttonIndex==1) {
            [self createGroup];
            
        }else{
            return;
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark xiong 通讯录
//跳转电话簿
-(void)addressBook{
    /*<iq type=”get”>----获取通讯录
     <query xmlns=”http://www.nihualao.com/xmpp/contacts”>
     <contact ver=”客户端当前缓存的版本号”/> </query>
     ￼￼￼￼￼￼</iq>*/
    AddressBookViewController *addressBook=[[AddressBookViewController alloc]init];
    [self.navigationController pushViewController:addressBook animated:YES];
    
}


//跳转填写手机号码
-(void)invitationFriends{
    //    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/contacts"];
    //    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    //    NSXMLElement *contact=[NSXMLElement elementWithName:@"contact"];
    //    [contact addAttributeWithName:@"ver" stringValue:@"2"];
    //    [iq addAttributeWithName:@"type" stringValue:@"get"];
    //    [iq addAttributeWithName:@"id" stringValue:@"accessAddressBook"];
    //    [queryElement addChild:contact];
    //    [iq addChild:queryElement];
    //    NSLog(@"组装后的xml:%@",iq);
    //    [[XMPPServer xmppStream] sendElement:iq];
    //InvitationFriendsViewController *invitationView=[[InvitationFriendsViewController alloc]init];
    //    InvitationFriendsViewControllerNew *invitationView=[[InvitationFriendsViewControllerNew alloc]init];
    //    invitationView.title = NSLocalizedString(@"contacts.inviteFridend.mobilePhoneNumberToInvite",@"title");
    //    invitationView.hidesBottomBarWhenPushed=YES;
    AddressBookViewController3* addressBookView=[[AddressBookViewController3 alloc]init];
    addressBookView.title = NSLocalizedString(@"public.text.select",@"title");
    addressBookView.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:addressBookView animated:YES];
}


//邀请朋友的网址
-(void)invitationURL{
    InvitationURLViewControllerNew *invitationURLView=[[InvitationURLViewControllerNew alloc]init];
    invitationURLView.hidesBottomBarWhenPushed=YES;
    invitationURLView.title =  NSLocalizedString(@"contacts.inviteFridend.urlToInvite",@"title");
    [self.navigationController pushViewController:invitationURLView animated:YES];
}


#pragma mark -
#pragma mark xiong actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            if (kIsPad) {
                UIAlertView *invitationAlert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.ipadMsg",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"contacts.addContacts.ok",@"action") otherButtonTitles:nil, nil];
                [invitationAlert show];
                return;
            }
            //填写手机号码
            [self invitationFriends];
            break;
        case 1:
            //邀请朋友的网址
            [self invitationURL];
            //手机通讯录
            //            [self addressBook];
            break;
        default:
            // NSLog(@"unknown： click at index %d", buttonIndex);
            [self.tableView reloadData];
            break;
    }
}




- (NSMutableArray *)getChineseStringArr:(NSMutableArray *)arrToSort {
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
        if(![_sectionHeadsKeys containsObject:[sr uppercaseString]])//here I'm checking whether the character already in the selection header keys or not
        {
            [_sectionHeadsKeys addObject:[sr uppercaseString]];
            TempArrForGrouping = [[NSMutableArray alloc] initWithObjects:nil];
            checkValueAtIndex = NO;
        }
        if([_sectionHeadsKeys containsObject:[sr uppercaseString]])
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
    [_sectionHeadsKeys insertObject:@"↑" atIndex:0];
    //tableview 第一行添加了“邀请朋友“和“圈子”，所以这添加两个空的数据对应
    
//    if (self.groupArray.count>0) {
//        for (int i=0; i<self.groupArray.count; i++) {
//            [_sectionHeadsKeys addObject:@""];
//        }
//        [_sectionHeadsKeys addObject:@""];
//    }else{
//        [_sectionHeadsKeys addObject:@""];
//        [_sectionHeadsKeys addObject:@""];
//    }
//    JLLog_I(@"section index=%@",self.sectionHeadsKeys);
    return arrayForArrays;
}


/*
 有时我们在NSMutableArray中存的是网络请求返回的数据，而每一个元素又是一个NSDictionary，如果这时候需要把数组中的元素按照每个元素字典中某一个key来排序，那么我们可以利用Objective C中的类：NSSortDescriptor来快速实现需求。
 */

-(void) changeArray:(NSMutableArray *)dicArray orderWithKey:(NSString *)key ascending:(BOOL)yesOrNo{
    NSSortDescriptor *distanceDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:yesOrNo];
    NSArray *descriptors = [NSArray arrayWithObjects:distanceDescriptor,nil];
    [dicArray sortUsingDescriptors:descriptors];
}



//- (NSMutableArray *)getChineseStringArr:(NSMutableArray *)arrToSort {
//    NSMutableArray *chineseStringsArray = [NSMutableArray array];
//    for(int i = 0; i < [arrToSort count]; i++) {
//        ChineseString *chineseString=[[ChineseString alloc]init];
//        chineseString.string=[NSString stringWithString:[arrToSort objectAtIndex:i]];
//
//        if(chineseString.string==nil){
//            chineseString.string=@"";
//        }
//
//        if(![chineseString.string isEqualToString:@""]){
//            //join the pinYin
//            NSString *pinYinResult = [NSString string];
//            for(int j = 0;j < chineseString.string.length; j++) {
//                NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c",
//                                                 pinyinFirstLetter([chineseString.string characterAtIndex:j])]uppercaseString];
//
//                pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
//            }
//            chineseString.pinYin = pinYinResult;
//        } else {
//            chineseString.pinYin = @"";
//        }
//        [chineseStringsArray addObject:chineseString];
//        [chineseString release];
//    }
//
//    //sort the ChineseStringArr by pinYin
//    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES]];
//    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
//
//
//    NSMutableArray *arrayForArrays = [NSMutableArray array];
//    BOOL checkValueAtIndex= NO;  //flag to check
//    NSMutableArray *TempArrForGrouping = nil;
//
//    for(int index = 0; index < [chineseStringsArray count]; index++)
//    {
//        ChineseString *chineseStr = (ChineseString *)[chineseStringsArray objectAtIndex:index];
//        NSMutableString *strchar= [NSMutableString stringWithString:chineseStr.pinYin];
//        NSString *sr= [strchar substringToIndex:1];
//        NSLog(@"%@",sr);        //sr containing here the first character of each string
//        if(![_sectionHeadsKeys containsObject:[sr uppercaseString]])//here I'm checking whether the character already in the selection header keys or not
//        {
//            [_sectionHeadsKeys addObject:[sr uppercaseString]];
//            TempArrForGrouping = [[[NSMutableArray alloc] initWithObjects:nil] autorelease];
//            checkValueAtIndex = NO;
//        }
//        if([_sectionHeadsKeys containsObject:[sr uppercaseString]])
//        {
//            [TempArrForGrouping addObject:[chineseStringsArray objectAtIndex:index]];
//            if(checkValueAtIndex == NO)
//            {
//                [arrayForArrays addObject:TempArrForGrouping];
//                checkValueAtIndex = YES;
//            }
//        }
//    }
//    return arrayForArrays;
//}



- (void)contactsLoadFinish{
    
    //[self initData];
    [self.tableView reloadData];
    
}

-(void)clickQRBtn{
    UIAlertView* qrAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")
                                                      message:NSLocalizedString(@"contacts.msg3",@"title")
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action")
                                            otherButtonTitles:NSLocalizedString(@"public.alert.ok",@"action"), nil];
    qrAlert.tag=30002;
    [qrAlert show];
}

-(void)clickQRBtn2:(UIButton *)btn{
    NSDictionary *groupDic = [self.groupArray objectAtIndex:btn.tag-1];
    
    NSString *groupJID = [groupDic objectForKey:@"groupJID"];
    NSString *groupNameStr = [groupDic objectForKey:@"groupName"];
    
    GroupQrCodeViewController *groupQrCode=[[GroupQrCodeViewController alloc]init];
    groupQrCode.groupJID=groupJID;
    groupQrCode.groupName=groupNameStr;
    groupQrCode.hidesBottomBarWhenPushed=YES;
    
    [self.navigationController pushViewController:groupQrCode animated:YES];
}

//-(void)createGroup{
//
//    //    <iq type=”set” to=”circle.nihualao.com”>
//    //    <query xmlns=”http://www.nihualao.com/xmpp/circle/create”>
//    //    <circle name=””> <members>
//    //    <member jid=”” role=”admin” nickname=”” phone=”如果没有开户
//    //    可用通讯录中的电话号码”/>
//    //    <member jid=”” role=”member” nickname=””/> </members>
//    //    </circle> </query>
//    //    </iq>
//
//    self.groupName =NSLocalizedString(@"contacts.msg2",@"title");
//
//    if ([GroupCRUD queryCountGroupByMyJID:MY_JID]>6) {
//        //圈子超出最大限制
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"circleUpdName.maxMsg",@"message") delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
//        [alert addButtonWithTitle:NSLocalizedString(@"public.alert.ok",@"message")];
//        [alert show];
//        //[alert release];
//
//        return;
//    }
//
//
//    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/create"];
//    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
//    NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
//    NSXMLElement *members = [NSXMLElement elementWithName:@"members"];
//
//
//    XMPPJID *myJID = [XMPPServer xmppStream].myJID;
//    NSString *jid = [NSString stringWithFormat:@"%@",myJID.bareJID];
//    // NSLog(@"*****%@",jid);
//
//
//    [iq addAttributeWithName:@"to" stringValue:GroupDomain];
//
//    [iq addAttributeWithName:@"type" stringValue:@"set"];
//
//    [circle addAttributeWithName:@"name" stringValue:self.groupName];
//
//    NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
//    [member addAttributeWithName:@"jid" stringValue:jid];
//    [member addAttributeWithName:@"role" stringValue:@"admin"];
//    [member addAttributeWithName:@"nickname" stringValue:@""];
//    [member addAttributeWithName:@"phone" stringValue:@""];
//    [members addChild:member];
//
//    [iq addChild:queryElement];
//    [queryElement addChild:circle];
//    [circle addChild:members];
//
//    //NSLog(@"组装后的xml:%@",iq);
//    [[XMPPServer xmppStream] sendElement:iq];
//
//    //加载动画效果
//    [DejalBezelActivityView activityViewForView:self.view];
//
//}

-(void)nextStepOrGroupQR:(NSNotification *)noti
{
    NSMutableArray *groupArray2 = [[NSMutableArray alloc]init];
    groupArray2 = [noti object];
    
    if ([self.clickGroupFlag isEqualToString:@"contacts"]) {
        [DejalBezelActivityView removeViewAnimated:YES];
        GroupAddContactsViewController *groupAddContactsVC = [[GroupAddContactsViewController alloc]init];
        
        for (ChatGroup* group in groupArray2) {
            groupAddContactsVC.groupJID = group.jid;
            //groupAddContactsVC.groupName = group.name;
        }
        groupAddContactsVC.groupName = self.groupName;
        if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
            //隐藏tabbar
            //groupDetailsVC.hidesBottomBarWhenPushed=YES;
            //self.tabBarController.tabBar.hidden = YES;
            
        }else{
            //隐藏tabbar
            groupAddContactsVC.hidesBottomBarWhenPushed=YES;
        }
        [self.navigationController pushViewController:groupAddContactsVC animated:YES];
        
    }else if([self.clickGroupFlag isEqualToString:@"qrcode"]){
        GroupQrCodeViewController *groupQrCode=[[GroupQrCodeViewController alloc]init];
        for (ChatGroup* group in groupArray2) {
            groupQrCode.groupJID=group.jid;
            groupQrCode.groupName=group.name;
        }
        
        [self.navigationController pushViewController:groupQrCode animated:YES];
    }
}

/*---视频语音start-----------------------------------------------------------------------------------*/
//打电话
-(void)playDial:(UIButton*)btn{
    //NSLog(@"开始拨打电话");
#if !TARGET_IPHONE_SIMULATOR
    NSString *jid =@"";
    NSString *name =@"";
    Contacts *contacts=nil;
    if (kIOS_VERSION>=7.0 && kIOS_VERSION<8.0) {
        UITableViewCell * cell = (UITableViewCell *)[[btn superview] superview];
        NSIndexPath * path = [self.tableView indexPathForCell:cell];
        NSArray *arr = [_sortedArrForArrays objectAtIndex:path.section-1];
        contacts = (Contacts *) [arr objectAtIndex:path.row];
        jid = contacts.jid;
        
        
        
    }else{
        UITableViewCell * cell = (UITableViewCell *)[btn superview];
        NSIndexPath * path = [self.tableView indexPathForCell:cell];
        NSArray *arr = [_sortedArrForArrays objectAtIndex:path.section-1];
        contacts = (Contacts *) [arr objectAtIndex:path.row];
        jid = contacts.jid;
        
    }
    if ([jid isEqualToString:@""]) {
        return;
    }
    
    
    XMPPJID *to = [XMPPJID jidWithString:jid resource:@"Hisuper"];
    NSString *toStrJID = [jid stringByAppendingFormat:@"%@",@"/Hisuper"];
    
    if (contacts.nickName==nil){
        name = to.user;
    }else{
        name = contacts.nickName;
    }
    
    
    NSString* sessionID = [XMPPStream generateUUID];
    if(YES)
    {
        APPRTCViewController *appView = [[APPRTCViewController alloc]init];
        appView.from = toStrJID;
        appView.isCaller = YES;
        appView.isVideo = NO;
        appView.msessionID = sessionID;
        
        appView.ivavatar.layer.masksToBounds = YES;
        appView.ivavatar.layer.cornerRadius = 3.0;
        appView.ivavatar.layer.borderWidth = 3.0;
        appView.ivavatar.backgroundColor = kMainColor4;
        appView.ivavatar.layer.borderColor = [[UIColor whiteColor]CGColor];
        
        [self.view.window.rootViewController presentViewController:appView animated:YES completion:^{
            
            //            CHAppDelegate *app = [UIApplication sharedApplication].delegate;
            [appView.lbname setText:name];
            
            
            NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [UserInfoCRUD queryUserInfoAvatar:jid]];
            
            UIImageView *headImageView = [[UIImageView alloc]init];
            headImageView.backgroundColor = [UIColor clearColor];
            
            [headImageView setImageWithURL:[NSURL URLWithString:avatarURL]
                          placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
            
            if(headImageView.image){
                [appView.ivavatar setImage:headImageView.image];
            }else{
                [appView.ivavatar setImage:[UIImage imageNamed:@"defaultUser.png"]];
            }
            appView.ivavatar.layer.masksToBounds = YES;
            appView.ivavatar.layer.cornerRadius = 3.0;
            appView.ivavatar.layer.borderWidth = 3.0;
            appView.ivavatar.backgroundColor = kMainColor4;
            appView.ivavatar.layer.borderColor = [[UIColor whiteColor]CGColor];
            
        }];
    }
    else
    {
        //[self showAlert:@"呼叫失败"];
        
        
    }
#endif
}

//开视频
-(void)contactsPlayVideo:(UIButton *)btn{
    //NSLog(@"开始语音视频");
#if !TARGET_IPHONE_SIMULATOR
    NSString *jid =@"";
    NSString *name =@"";
    Contacts *contacts=nil;
    if (kIOS_VERSION>=7.0 && kIOS_VERSION<8.0) {
        UITableViewCell * cell = (UITableViewCell *)[[btn superview] superview];
        NSIndexPath * path = [self.tableView indexPathForCell:cell];
        NSArray *arr = [_sortedArrForArrays objectAtIndex:path.section-1];
        contacts = (Contacts *) [arr objectAtIndex:path.row];
        jid = contacts.jid;
        
        
        
    }else{
        UITableViewCell * cell = (UITableViewCell *)[btn superview];
        NSIndexPath * path = [self.tableView indexPathForCell:cell];
        NSArray *arr = [_sortedArrForArrays objectAtIndex:path.section-1];
        contacts = (Contacts *) [arr objectAtIndex:path.row];
        jid = contacts.jid;
        
    }
    if ([jid isEqualToString:@""]) {
        return;
    }
    
    
    XMPPJID *to = [XMPPJID jidWithString:jid resource:@"Hisuper"];
    NSString *toStrJID = [jid stringByAppendingFormat:@"%@",@"/Hisuper"];
    
    if (contacts.nickName==nil){
        name = to.user;
    }else{
        name = contacts.nickName;
    }
    
    
    NSString* sessionID = [XMPPStream generateUUID];
    if(YES)
    {
        APPRTCViewController *appView = [[APPRTCViewController alloc]init];
        //NSLog(@"******%@",[to full]);
        appView.from = toStrJID;
        appView.isCaller = YES;
        appView.isVideo = YES;
        appView.msessionID = sessionID;
        
        [self.view.window.rootViewController presentViewController:appView animated:YES completion:^{
            //CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
            // appDelegate.tabBarBG.hidden = YES;
            
            [appView.lbname setText:to.user];
            
            
            NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [UserInfoCRUD queryUserInfoAvatar:jid]];
            
            UIImageView *headImageView = [[UIImageView alloc]init];
            headImageView.backgroundColor = [UIColor clearColor];
            
            [headImageView setImageWithURL:[NSURL URLWithString:avatarURL]
                          placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
            
            if(headImageView.image){
                [appView.ivavatar setImage:headImageView.image];
            }else{
                [appView.ivavatar setImage:[UIImage imageNamed:@"defaultUser.png"]];
            }
            appView.ivavatar.layer.masksToBounds = YES;
            appView.ivavatar.layer.cornerRadius = 3.0;
            appView.ivavatar.layer.borderWidth = 3.0;
            appView.ivavatar.backgroundColor = kMainColor4;
            appView.ivavatar.layer.borderColor = [[UIColor whiteColor]CGColor];
            
            
        }];
        
    }
    else
    {
        //呼叫失败
        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"public.callFailure",@"message") delegate:nil cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") otherButtonTitles:nil, nil];
        [errorAlert show];
        
    }
#endif
}

/*---快捷菜单start----------------------------------------------*/
- (void)showMenu:(UIBarButtonItem *)sender
{
    
    if (!mRightBarButtonSelected) {
        
        mRightBarButtonSelected = YES;
        
        NSArray *menuItems =
        @[
          
          
          [KxMenuItem menuItem:@"发起群聊"
                         image:[UIImage imageNamed:@"check_icon"]
                        target:self
                        action:@selector(createGroup)],
          
          [KxMenuItem menuItem:@"添加好友"
                         image:[UIImage imageNamed:@"action_icon"]
                        target:self
                        action:@selector(toAddFriendVC)],
          
          [KxMenuItem menuItem:@"扫一扫"
                         image:[UIImage imageNamed:@"reload"]
                        target:self
                        action:@selector(ScanQRCode:)]
          //      [KxMenuItem menuItem:@"听筒"
          //                     image:nil
          //                    target:self
          //                    action:nil]
          
          ];
        
        KxMenuItem *first = menuItems[0];
        first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
        first.alignment = NSTextAlignmentCenter;
        
        [KxMenu showMenuInView:self.navigationController.view
                      fromRect:CGRectMake(KCurrWidth-25, self.navigationController.navigationBar.frame.size.height+20, 0, 0)
                     menuItems:menuItems];
        
    }else {
        
        [self dismissMenu];
    }
}

//发起群聊
-(void)createGroup{
    //    if ([GroupCRUD queryCountGroupByMyJID:MY_JID]>10) {
    //        //圈子超出最大限制
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"circleUpdName.maxMsg",@"message") delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    //        [alert addButtonWithTitle:NSLocalizedString(@"public.alert.ok",@"message")];
    //        [alert show];
    //        //[alert release];
    //
    //        return;
    //    }
    
    [self dismissMenu];
    
    GroupCreateViewController *groupCreateVC=[[GroupCreateViewController alloc]init];
    groupCreateVC.hidesBottomBarWhenPushed=YES;
    groupCreateVC.title =  NSLocalizedString(@"contacts.inviteFridend.urlToInvite",@"title");
    [self.navigationController pushViewController:groupCreateVC animated:YES];
}



- (void) ScanQRCode:(id)sender
{
    //    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    //    {
    //
    //        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:@"请真机运行！！！" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    //        [myAlert addButtonWithTitle:NSLocalizedString(@"public.alert.ok",@"message")];
    //        [myAlert show];
    //
    //    }

    [self dismissMenu];
    
    ScanViewController *scanVC=[[ScanViewController alloc]init];
    scanVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:scanVC animated:YES];
    
}

-(void)receiveScanResult:(NSNotification *)notify{
    
    [MyServices receiveScanResult:notify target:self];
    
}

-(void)addFriendsSuccess:(NSNotification *)notify{
    //解决获取数据比入库的数据的老旧的问题
    [self performSelector:@selector(refreshTableViewWithResultData) withObject:nil afterDelay:0.5];
}
-(void)refreshTableViewWithResultData{
    [self initData];
    [self.tableView reloadData];
}

/*---快捷菜单end----------------------------------------------------------*/


//下拉刷新
-(void)handleData
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm:ss a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"refresh.text2",@"title"), [formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    // self.count++;
    //[self.countArr addObject:[NSString stringWithFormat:@"%d. %@, code4app.com",self.count,[formatter stringFromDate:[NSDate date]]]];
    [self dismissMenu];
    [self.refreshControl endRefreshing];
    [self initData];
    [self.tableView reloadData];
}

-(void)refreshView:(UIRefreshControl *)refresh
{
    if (refresh.refreshing) {
        refresh.attributedTitle = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"refresh.text",@"title")];
        [self performSelector:@selector(handleData) withObject:nil afterDelay:2];
    }
}




-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //设置通知中心，创建圈子
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextStepOrGroupQR:)
                                                 name:@"NNC_Received_GroupCreate" object:nil];
    
    
    [self setTabBarItemBadgeValue];
//////////////////////////////////////////////////////////////////////////////////////////////////////////
    [self handleData];
////////////////////////////////////////////////////////////////////////////////////////////////////////
}

- (void)viewWillDisappear:(BOOL)animated {
    [DejalBezelActivityView removeViewAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Received_GroupCreate" object:nil];
    [super viewWillDisappear:animated];
    
}

#pragma mark
#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    AISearchContactViewController *c = [[AISearchContactViewController alloc] init];
    UINavigationController *navigation = self.tabBarController.viewControllers[0];
    __weak typeof(self)wself = self;
    __weak typeof(navigation)wnavigation = navigation;
    c.completedBlock = ^(UIViewController *viewController) {
        wself.tabBarController.selectedIndex = 0;
        viewController.hidesBottomBarWhenPushed = YES;
        [wnavigation pushViewController:viewController animated:YES];
    };
    UINavigationController *aNavigation = [[UINavigationController alloc] initWithRootViewController:c];
    [self.navigationController presentViewController:aNavigation animated:YES completion:nil];
    return NO;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (!searchResults) {
        searchResults = [NSMutableArray array];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchResults removeAllObjects];
    searchResults = [NSMutableArray array];
}


- (void) searchBar:(UISearchBar *)searchBar
     textDidChange:(NSString *)searchText{
    
    [searchResults removeAllObjects];
    if (!searchText || [searchText isEqualToString:@""]) return;
    
    
    
//    NSString *searchFormat = [[searchText transformToPinyin] lowercaseString];
//    for (NSArray *contacts in self.sortedArrForArrays) {
//        for (Contacts *contact in contacts) {
//            NSString *format_01 = [[contact.remarkName transformToPinyin] lowercaseString];
//            NSString *format_02 = [[contact.nickName transformToPinyin] lowercaseString];
//            
//            if ([format_01 hasPrefix:searchFormat] || [format_02 hasPrefix:searchFormat]) {
//                [searchResults addObject:contact];
//            }
//        }
//    }
    [searchDisplayController.searchResultsTableView reloadData];
    
//    if(searchResults == nil){
//        searchResults = [[NSMutableArray alloc]init];
//    }else{
//        [searchResults removeAllObjects];
//    }
//    
//    if(searchBar.text == nil || [searchBar.text isEqualToString: @""] ){
//        return;
//    }
//    if (mySearchBar.text.length>0 && ![ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
//        for (int i=0; i<self.sortedArrForArrays.count; i++) {
//            for (int j = 0; j < [_sortedArrForArrays[i] count]; j++) {
//                Contacts* contact = (Contacts*)[self.sortedArrForArrays[i] objectAtIndex:j];
//                
//                if (contact.nickName == nil || [contact.nickName isEqualToString: @""]) {
//                    continue;
//                }
//                
//                // 匹配昵称跟备注
//                NSString *format_01 = contact.nickName;
//                NSString *format_02 = contact.remarkName;
//                
//                if ([ChineseInclude isIncludeChineseInString:format_01]) {
//                    NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:format_01];
//                    contact.pinYin = tempPinYinStr;
//                    NSRange titleResult=[tempPinYinStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
//                    
//                    if (titleResult.length>0) {
//                        // [searchResults addObject:searchName];
//                        
//                        [searchResults addObject:contact];
//                    }
//                    //                NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:searchName];
//                    //                NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
//                    //                if (titleHeadResult.length>0) {
//                    //                    [searchResults addObject:searchName];
//                    //                }
//                    
//                    else
//                    {
//                        if ([ChineseInclude isIncludeChineseInString:format_02]) {
//                            NSString *temp = [PinYinForObjc chineseConvertToPinYin:format_02];
//                            contact.pinYin = temp;
//                            NSRange res = [temp rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
//                            if (res.length > 0) {
//                                [searchResults addObject:contact];
//                            }
//                        }else {
//                            NSRange res = [format_02 rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
//                            contact.pinYin = format_02;
//                            if (res.length > 0) {
//                                [searchResults addObject:contact];
//                            }
//                        }
//                    }
//                }
//                else {
//                    NSRange titleResult=[format_01 rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
//                    contact.pinYin = format_01;
//                    if (titleResult.length>0) {
//                        //[searchResults addObject:searchName];
//                        [searchResults addObject:contact];
//                    }
//                }
//                
//            }
//        }
//    } else if (mySearchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
//        for (int i=0; i<self.sortedArrForArrays.count; i++) {
//            for (int j = 0; j < [_sortedArrForArrays[i] count]; j++) {
//                Contacts* contact = (Contacts*)[self.sortedArrForArrays[i] objectAtIndex:j];
//                
//                NSString *format_01 = contact.nickName;
//                NSString *format_02 = contact.remarkName;
//                
//                NSRange titleResult=[format_01 rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
//                //contact.pinYin = searchName;
//                if (titleResult.length>0) {
//                    //[searchResults addObject:searchName];
//                    [searchResults addObject:contact];
//                }
//                else {
//                    NSRange res = [format_02 rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
//                    if (res.length > 0) {
//                        [searchResults addObject:contact];
//                    }
//                }
//            }
//        }
//        
//    }
//    JLLog_I(@"(search result=%@)", searchResults);
//    [self.searchDisplayController.searchResultsTableView  reloadData];
    
    
}

//跳转到新增好友界面
-(void)toAddFriendVC{
    
    [self dismissMenu];
    
    AddFriendVCTableViewController* addFriendVC = [[AddFriendVCTableViewController alloc]init];
    //    UINavigationController* navigationVC = [[UINavigationController alloc]initWithRootViewController:addFriendVC];
    //    [self presentViewController:navigationVC animated:YES completion:nil];
    addFriendVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addFriendVC animated:YES];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self dismissMenu];
}

- (void)menuAutoRelease:(NSNotification *)n {
    
    mRightBarButtonSelected = NO;
}

- (void)dismissMenu {
    
    [KxMenu dismissMenu:YES complete:^{ mRightBarButtonSelected = NO; } ];

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
