//
//  AddressBookViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 14-4-23.
//  Copyright (c) 2014年 ch. All rights reserved.
//
//  通讯录

#import "AddressBookViewController3.h"
#import "TKAddressBook.h"
#import "SendSMSViewController.h"
#import "AddressBookCRUD.h"
#import "PinYinForObjc.h"
#import "PublicCURD.h"
#import "APPRTCViewController.h"
#import "UIImageView+WebCache.h"
#import "pinyin.h"
#import "ChineseString.h"
#import "FriendNameViewController.h"
#import "InvitationURLViewControllerNew.h"
#import "QrCodeViewController.h"
#import "Utility.h"
#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface AddressBookViewController3 ()
{
    FMDatabase *db;
    UITableView *tb;
    NSMutableArray *addressBookTemp;
    TKAddressBook *addressBook;
    NSMutableArray *arrName;
    NSMutableArray *arrJIDArray;
    __block BOOL accessGranted;
    
    NSMutableArray *arrSqlAddress;
}
//@property(nonatomic, copy) NSArray *famousPersons;
@property(nonatomic, copy) NSArray *filteredPersons;
@property(nonatomic, copy) NSArray *sections;
@property(nonatomic, strong) UISearchDisplayController *strongSearchDisplayController;
@end

@implementation AddressBookViewController3

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectionVer) name:@"NNS_Detection_Ver" object:nil];
        
    }
    return self;
}

- (void)initData {
    _dataArr = nil;
    _sortedArrForArrays = nil;
    _sectionHeadsKeys = nil;
    _dataArr = [[NSMutableArray alloc] init];
    _sortedArrForArrays = [[NSMutableArray alloc] init];
    _sectionHeadsKeys = [[NSMutableArray alloc] init];
    _dataArr = [AddressBookCRUD queryAddressBook:MY_JID];
    _sortedArrForArrays = [self getChineseStringArr:_dataArr];
}


- (NSMutableArray *)getChineseStringArr:(NSMutableArray *)arrToSort {
    NSMutableArray *chineseStringsArray = [NSMutableArray array];
    for(int i = 0; i < [arrToSort count]; i++) {
        addressBook =[[TKAddressBook alloc]init];
        NSDictionary *sortDic = [arrToSort objectAtIndex:i];
        
        addressBook.string = [NSString stringWithString:[sortDic objectForKey:@"name"] ];
        addressBook.jid = [NSString stringWithString:[sortDic objectForKey:@"jid"] ];
        addressBook.name = [NSString stringWithString:[sortDic objectForKey:@"name"]];
        addressBook.tel = [NSString stringWithString:[sortDic objectForKey:@"phoneNum"]];
        
        if(addressBook.string.length==0){
            addressBook.string=addressBook.tel;
        }
        
        if(![addressBook.string isEqualToString:@""]){
            //join the pinYin
            NSString *pinYinResult = [NSString string];
            for(int j = 0;j < addressBook.string.length; j++) {
                NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c",
                                                 pinyinFirstLetter([addressBook.string characterAtIndex:j])]uppercaseString];
                
                pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
            }
            addressBook.pinYin = pinYinResult;
        } else {
            addressBook.pinYin = @"";
        }
        [chineseStringsArray addObject:addressBook];
        
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
    //tableview 第一行添加了“邀请朋友“和“圈子”，所以这添加两个空的数据对应
    //    [_sectionHeadsKeys addObject:@""];
    //    [_sectionHeadsKeys addObject:@""];
    return arrayForArrays;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //邀请
    self.title = NSLocalizedString(@"public.text.select",@"title");
    
    
    //    [self obtainAddressBook];
    //    //新建一个通讯录类
    //    addressBookTemp=[[NSMutableArray alloc]initWithObjects: nil];
    //    arrName=[[NSMutableArray alloc]initWithObjects: nil];
    
    ABAddressBookRef addressBooks = nil;
    accessGranted = NO;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBooks =  ABAddressBookCreateWithOptions(NULL, NULL);
        //获取通讯录权限
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error){
            dispatch_semaphore_signal(sema);
            accessGranted=granted;
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        //dispatch_release(sema);
        
    }
    else
    {
        addressBooks = ABAddressBookCreate();
        
    }
    
    
    [self initData];
    [self ui];
    
}



-(void)ui{
    UIBarButtonItem *qrBut=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"public.qr.name",@"action") style:UIBarButtonItemStylePlain target:self action:@selector(invitationURL)];
    [self.navigationItem setRightBarButtonItem:qrBut];
    
    [self.navigationItem setRightBarButtonItem:qrBut];
    
    
    //CGRect rect=[[UIScreen mainScreen]bounds];
    if (!accessGranted) {
        //应用权限限制,需要进入“系统设置->隐私->通讯录“开启通讯录权限许可后才能使用
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"addressBook.authorizedPromptMsg",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
    if(accessGranted) {
        tb=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-Both_Bar_Height)];
        [self.view addSubview:tb];
        tb.delegate=self;
        tb.dataSource=self;
        _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        //    [_searchBar setSearchBarStyle:UISearchBarStyleDefault];
        if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
            //            _searchBar.searchBarStyle=UISearchBarStyleDefault;
        }else{
            
        }
        //[tb addSubview:_searchBar];
        // tb.tableHeaderView=_searchBar;
        //_searchBar.delegate = self;
        
        //[_searchBar sizeToFit];
        
        _strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        self.searchDisplayController.searchResultsDataSource = self;
        self.searchDisplayController.searchResultsDelegate = self;
        self.searchDisplayController.delegate = self;
    }
    else{
        UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height/2, self.view.frame.size.width, 40)];
        lab.textAlignment=NSTextAlignmentCenter;
        //未获取通讯录权限,无法使用该功能
        lab.text=NSLocalizedString(@"addressBook.authorizedPromptMsg2",@"title");
        lab.textColor=[UIColor lightGrayColor];
        [self.view addSubview:lab];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    NSAssert(YES, @"This method should be handled by a subclass!");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return  [[self.sortedArrForArrays objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sortedArrForArrays count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if(_sectionHeadsKeys.count>0){
        return [_sectionHeadsKeys objectAtIndex:section];
    }
    
    return @"";
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    return self.sectionHeadsKeys;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//        return 5;
//}
//cell内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellId = @"CellId";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    if ([_sortedArrForArrays count] > indexPath.section) {
        NSArray *arr = [_sortedArrForArrays objectAtIndex:indexPath.section];
        if ([arr count] > indexPath.row) {
            TKAddressBook *str = (TKAddressBook *) [arr objectAtIndex:indexPath.row];
            cell.textLabel.text = str.string;
            //cell.detailTextLabel.text = str.tel;
            if (![str.jid isEqualToString:@""]) {
                UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(KCurrWidth-45, 15, 20, 20)];
                imageView.image=[UIImage imageNamed:@"Icon.png"];
                imageView.layer.masksToBounds = YES;
                imageView.layer.cornerRadius = 3.0;
                [cell addSubview:imageView];
                
            }
            
        } else {
            NSLog(@"arr out of range");
        }
    } else {
        NSLog(@"sortedArrForArrays out of range");
    }
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([self.sortedArrForArrays count] > 0) {
        NSArray *arr = [self.sortedArrForArrays objectAtIndex: indexPath.section];
        if ([arr count] > 0) {
            TKAddressBook *book = [arr objectAtIndex:indexPath.row];
            _receiveUserJID = book.jid;
            _receiveName = book.name;
            _phoneNum = book.tel;
        }
    }
    
    if ([_receiveUserJID isEqualToString:@""]) {
        if (![_phoneNum isEqualToString:@""]) {
            if(kIsPad){
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"addressBook.msg",@"title")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:NSLocalizedString(@"public.text.QRcodeInvitation",@"title"), nil];
                alert.tag = 20000;
                [alert show];
                return;
            }
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"contacts.inviteFridend.msg",@"title")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"title") otherButtonTitles:NSLocalizedString(@"public.text.invitation",@"title"), nil];
            alert.tag = 20001;
            [alert show];
            
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示:" message:@"手机号码错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            //[alert release];
        }
        return;
    }
    if (kIOS_VERSION>=8.0) {
        
        UIAlertController *otherLoginAlert = nil;
        if (kIsPad) {
            otherLoginAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        }else{
            otherLoginAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        }
        
        
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ContactsDetails.voiceCall",@"action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              //语音通话
                                                              [self playDial:_receiveUserJID];
                                                          }]];
//        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ContactsDetails.videoCall",@"action")
//                                                            style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction *action) {
//                                                              [self playVideo:_receiveUserJID];
//                                                          }]];
//        
        
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"public.alert.cancel",@"action")                                                               style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                              
                                                          }]];
        UIPopoverPresentationController *popover = otherLoginAlert.popoverPresentationController;
        if (popover){
            popover.sourceView = self.view;
            popover.sourceRect = self.view.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        
        [self presentViewController:otherLoginAlert animated:YES completion:nil];
        
    }else{

    UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"title") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ContactsDetails.voiceCall",@"title"), nil];
    
   // NSLog(@"*******%d",indexPath.row);
    actionSheet.tag = indexPath.row;
    [actionSheet showInView:self.view.window];
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}


#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"*****%d",actionSheet.tag);
    
    
    switch (buttonIndex) {
        case 0:
            //语音通话
            [self playDial:_receiveUserJID];
            break;
        case 1:
           // [self playVideo:_receiveUserJID];
            break;
            
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==20000) {
        if (buttonIndex==1) {
            //个人二维码
            QrCodeViewController *qrCodeView=[[QrCodeViewController alloc]init];
            qrCodeView.title=@"个人二维码";
            if ([[NSUserDefaults standardUserDefaults]stringForKey:@"name"].length>0){
                qrCodeView.labNmaetext =[[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
            }else{
                qrCodeView.labNmaetext=[[NSUserDefaults standardUserDefaults]stringForKey:@"userName"];
            }
            [self.navigationController pushViewController:qrCodeView animated:YES];
        }
    }else if(alertView.tag==20001){
        if (buttonIndex==1) {
            FriendNameViewController *friendName=[[FriendNameViewController alloc]init];
            friendName.nickName=_receiveName;
            friendName.phoneNum=_phoneNum;
            [self.navigationController pushViewController:friendName animated:YES];
        }

    }
    
}



#pragma mark - Search Delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.filteredPersons = arrName;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.filteredPersons = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.filteredPersons = arrName;
    NSString *search=[PinYinForObjc chineseConvertToPinYin:searchString];
    self.filteredPersons = [self.filteredPersons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", search]];
    return YES;
}

/*---视频语音start-----------------------------------------------------------------------------------*/
/*<iq type=”get”>
 <query xmlns=”http://www.nihualao.com/xmpp/userinfo“ >
 <user jid=””/>
 <user jid=””/> </query>
 </iq>*/
//获取用户信息，检测用户是否存在
-(void)userinfoRequest:(NSString *)userName{
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *userJid=[NSXMLElement elementWithName:@"user"];
    [userJid addAttributeWithName:@"jid" stringValue:userName];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"Is_Have_Userinfo"];
    [queryElement addChild:userJid];
    [iq addChild:queryElement];
    [[XMPPServer xmppStream] sendElement:iq];
}


//打电话
-(void)playDial:(NSString*)jid{
    NSLog(@"开始拨打电话");
    isVideo=NO;
    if (jid.length>0) {
        [self userinfoRequest:jid];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示:" message:@"手机号码错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        //[alert release];
    }
}

//开视频
-(void)playVideo:(NSString*)jid{
    NSLog(@"开始语音视频");
    isVideo=YES;
    if (jid.length>0) {
        [self userinfoRequest:jid];
        
    }else{
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示:" message:@"手机号码错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}



/*-(void)addressbookPhoneNum:(NSNotification *)phoneNum{
 txtPhoneNum.text=[NSString stringWithFormat:@"%@",[phoneNum object]];*/
-(void)playPhoneOrVideo:(NSNotification *)have{
    
    NSString *isHave=[NSString stringWithFormat:@"%@",[have object]];
    if (isHave!=nil&&![isHave isEqualToString:@"(null)"]) {
        XMPPJID *toJID = [XMPPJID jidWithString:_receiveUserJID resource:@"Hisuper"];
        NSLog(@"******%@,%@",_receiveUserJID, toJID);
        if (isVideo==NO) { //语音通话
#if !TARGET_IPHONE_SIMULATOR
            NSString* sessionID = [XMPPStream generateUUID];
            if(YES)
            {
                APPRTCViewController *appView = [[APPRTCViewController alloc]init];
                
                appView.from = toJID.full;
                appView.isCaller = YES;
                appView.isVideo = NO;
                appView.msessionID = sessionID;
                
                [self.view.window.rootViewController presentViewController:appView animated:YES completion:^{
                    //CHAppDelegate *app = [UIApplication sharedApplication].delegate;
                    
                    [appView.lbname setText:_receiveName];
                    appView.ivavatar.layer.masksToBounds = YES;
                    appView.ivavatar.layer.cornerRadius = 3.0;
                    appView.ivavatar.layer.borderWidth = 3.0;
                    appView.ivavatar.backgroundColor = kMainColor4;
                    appView.ivavatar.layer.borderColor = [[UIColor whiteColor]CGColor];
                    
                    NSString *photoImage=[[NSUserDefaults standardUserDefaults]objectForKey:@"NSUD_PhoneImage"];
                    UIImage *image = [UIImage imageNamed:@"defaultUser.png"];
                    if (![photoImage isEqualToString:@""]) {
                        NSString *photoImageUrl=[NSString stringWithFormat:@"%@/%@",ResourcesURL,photoImage];
                        UIImageView *photoView=[[UIImageView alloc]initWithFrame:CGRectMake(240, 5, 50, 50)];
                        [photoView setImageWithURL:[NSURL URLWithString:photoImageUrl]
                                  placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
                        if (photoView.image) {
                            [appView.ivavatar setImage:photoView.image];
                        }else{
                            [appView.ivavatar setImage:image];
                        }
                    }else{
                        [appView.ivavatar setImage:image];
                        
                    }
                }];
            }
            else
            {
                [self showAlert:@"呼叫失败"];
                
                
            }
            
#endif
        }else{  //视频通话
            
#if !TARGET_IPHONE_SIMULATOR
            
            NSString* sessionID = [XMPPStream generateUUID];
            if( [[VoipModule shareVoipModule]call:toJID isvideo:true sessionID:sessionID])
            {
                APPRTCViewController *appView = [[APPRTCViewController alloc]init];
                appView.from = toJID.full;
                appView.isCaller = YES;
                appView.isVideo = YES;
                appView.msessionID = sessionID;
                
                
                [self.view.window.rootViewController presentViewController:appView animated:YES completion:^{
                    
                    [appView.lbname setText:_receiveName];
                    
                    appView.ivavatar.layer.masksToBounds = YES;
                    appView.ivavatar.layer.cornerRadius = 3.0;
                    appView.ivavatar.layer.borderWidth = 3.0;
                    appView.ivavatar.backgroundColor = kMainColor4;
                    appView.ivavatar.layer.borderColor = [[UIColor whiteColor]CGColor];
                    
                    NSString *photoImage=[[NSUserDefaults standardUserDefaults]objectForKey:@"NSUD_PhoneImage"];
                    UIImage *image = [UIImage imageNamed:@"defaultUser.png"];
                    if (![photoImage isEqualToString:@""]) {
                        NSString *photoImageUrl=[NSString stringWithFormat:@"%@/%@",ResourcesURL,photoImage];
                        UIImageView *photoView=[[UIImageView alloc]initWithFrame:CGRectMake(240, 5, 50, 50)];
                        [photoView setImageWithURL:[NSURL URLWithString:photoImageUrl]
                                  placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
                        if (photoView.image) {
                            [appView.ivavatar setImage:photoView.image];
                        }else{
                            [appView.ivavatar setImage:image];
                        }
                    }else{
                        [appView.ivavatar setImage:image];
                        
                    }
                }];
            }
            else
            {
                
                [self showAlert:@"呼叫失败"];
            }
            
#endif
            
        }
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示" message:@"您拨打的邦邦社区号码不存在" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    
}

//邀请朋友的网址
-(void)invitationURL{
    InvitationURLViewControllerNew *invitationURLView=[[InvitationURLViewControllerNew alloc]init];
    invitationURLView.hidesBottomBarWhenPushed=YES;
    invitationURLView.title =  NSLocalizedString(@"contacts.inviteFridend.urlToInvite",@"title");
    [self.navigationController pushViewController:invitationURLView animated:YES];
}


-(void)showAlert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
}

/*---视频语音end-----------------------------------------------------------------------------------*/
-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playPhoneOrVideo:) name:@"NNC_Is_Have_Userinfo3" object:nil];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Is_Have_Userinfo" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Is_Have_Userinfo3" object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Is_Have_Userinfo3" object:nil];
}

@end
