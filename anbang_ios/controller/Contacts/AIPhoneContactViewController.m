//
//  AIPhoneContactViewController.m
//  anbang_ios
//
//  Created by Kim on 15/4/21.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIPhoneContactViewController.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "GroupChatViewController2.h"
#import "ContactsCRUD.h"
#import "Contacts.h"
#import "ChineseString.h"
#import "ChineseInclude.h"
#import "pinyin.h"
#import "PinYinForObjc.h"
#import "PublicCURD.h"
#import "AddressBookCRUD.h"
#import "ContactsCRUD.h"
#import "AIPhoneContactTableViewCell.h"
#import "ContactInfo.h"
#import "AIRegex.h"
#import "AIUIButton.h"
#import "UserInfoCRUD.h"
#import "AIControllersTool.h"

@interface AIPhoneContactViewController ()
{
    NSMutableArray *uploadingAddressBooks;
    NSMutableArray *mAddressBooks;
    NSMutableArray *mGroupAddressBooks;
    __block BOOL accessGranted;
    NSString *mPhoneNum;
}
@property (strong, nonatomic) MBProgressHUD *hub;

@end

@implementation AIPhoneContactViewController
@synthesize sectionHeadsKeys = _sectionHeadsKeys;

- (void)viewWillDisappear:(BOOL)animated {
    [self removeNotifications];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mAddressBooks = [NSMutableArray array];
    mGroupAddressBooks = [NSMutableArray array];
    _sectionHeadsKeys = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAddressBook:)
                                                 name:@"NCC_AddressBooK_Success" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendSMS:)
                                                 name:@"smContent" object:nil];

    [self setupNotifications];
    [self setNavigationBar];
    
    //下拉刷新
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor lightGrayColor];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"  "];
    [refresh addTarget:self action:@selector(reloadTableView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    
    self.view.backgroundColor = AB_Color_f6f3ee;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = AB_Gray_Color;
    [self.tableView setSeparatorColor:AB_Color_f4f0eb];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 17)];
    }
    
    [self startLoading];
    [self loadAddressBookPermission];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)popVC{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setNavigationBar{
    self.navigationItem.title =@"手机通讯录";
    
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"添加好友"
                                                                                   target:self
                                                                                   action:@selector(popVC)]];
}


#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionHeadsKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return mGroupAddressBooks.count > 0 ? [[mGroupAddressBooks objectAtIndex:section] count] : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _sectionHeadsKeys.count == 0 ? 0.0 : 21.0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionHeadsKeys;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_sectionHeadsKeys.count > 0) {
                
        CGRect rect = CGRectMake(0, 0, Screen_Width, 30);
        UIView *view = [[UIView alloc] initWithFrame:rect];
        
        UILabel *extralLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 21)];
        extralLabel.backgroundColor = AB_Color_f6f2ed;
        [view addSubview:extralLabel];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, Screen_Width - 15, 21)];
        label.font = AB_FONT_12;
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = AB_Color_f6f2ed;
        label.textColor = AB_Color_9c958a;
        label.text = [_sectionHeadsKeys objectAtIndex:section];
        [view addSubview:label];
        [view sendSubviewToBack:label];
        
        return view;
    }
    
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AIPhoneContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressBook"];
    
    if (cell == nil) {
        cell = [[AIPhoneContactTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:@"addressBook"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
        
        cell.textLabel.font = AB_FONT_15;
        cell.textLabel.textColor = Notice_Font_Color;
        
        cell.detailTextLabel.font = AB_FONT_12;
        cell.detailTextLabel.textColor = AB_Color_9c958a;
 
        AIUIButton *addButton = [AIUIButton buttonWithType:UIButtonTypeCustom];
        addButton.frame = CGRectMake(Screen_Width - 85, 8.5, 70, 30);
        addButton.titleLabel.font = AB_FONT_14;
        addButton.tag = 10000;
        [cell.contentView addSubview:addButton];
    }
    

    if(mAddressBooks.count == 0){
        cell.textLabel.text = @"您手机还没有任何联系人";
    }else{
        TKAddressBook *item = [[mGroupAddressBooks objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.addressBook = item;
        cell.textLabel.text = item.string;

        cell.detailTextLabel.text = item.nickname?[NSString stringWithFormat:@"社区昵称：%@", item.nickname]:@" ";
        
        NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, item.avatar];
        [cell.imageView setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserProfile:)];
        [cell.imageView addGestureRecognizer:tapGesture];
        cell.imageView.userInteractionEnabled = YES;
//        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        CGSize itemSize = CGSizeMake(29, 29);
//        UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
//        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
//        [cell.imageView.image drawInRect:imageRect];
//        cell.imageView.layer.masksToBounds = YES;
//        cell.imageView.layer.cornerRadius = 2.0;
//        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
 
        AIUIButton *addButton = (AIUIButton*)[cell.contentView viewWithTag:10000];
        
        if(item.isMyFriend){
            [addButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            [addButton setTitle:@"已添加" forState:UIControlStateNormal];
            [addButton setTitleColor:AB_Color_9c958a forState:UIControlStateNormal];
            addButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            addButton.userInteractionEnabled = NO;
            [addButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];

        } else {
            [addButton setTitle:item.registered?@"添加":@"邀请" forState:UIControlStateNormal];
            addButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            addButton.titleLabel.textColor = AB_Color_ffffff;
            if (item.registered) {
                [addButton setBackgroundColor:AB_Color_7ac141 forState:UIControlStateNormal];
                [addButton setBackgroundColor:AB_Color_68af2f forState:UIControlStateHighlighted];
            }else{
                [addButton setBackgroundColor:AB_Color_e55a39 forState:UIControlStateNormal];
                [addButton setBackgroundColor:AB_Color_c6502c forState:UIControlStateHighlighted];
            }
            addButton.layer.cornerRadius = 3.0f;
            [addButton addTarget:self action:@selector(addFriend:event:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    return cell;
}

- (void)showUserProfile:(id)sender{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer*) sender;
    CGPoint currentTouchPosition = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    TKAddressBook *book = [[mGroupAddressBooks objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if(book.jid == nil || [@"" isEqualToString:book.jid]){
        return;
    }
    
    int count = [UserInfoCRUD queryUserInfoTableCountId:book.jid myJID:MY_JID];
    if (count > 0) {
//        UserInfo *userInfo = [[UserInfo alloc] init];
//        userInfo.jid = book.jid;
//        userInfo.nickName = book.nickname;
//        userInfo.remarkName = book.remarkName;
//        userInfo.avatar = book.avatar;
//        userInfo.gender = book.gender;
//        userInfo.accountType = book.accountType;
        UserInfo *userInfo = [UserInfoCRUD queryUserInfo:book.jid myJID:MY_JID];
        ContactInfo *contactInfo = [[ContactInfo alloc] initWithNibName:@"ContactInfo" bundle:nil];
        contactInfo.jid = book.jid;
        contactInfo.userinfo = userInfo;
        
        contactInfo.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:contactInfo animated:YES];
    }else {
        [self sendUserInfoIQWithJID:book.jid];
    }
}

- (void)setupNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(contactInfoReturn:)
                   name:@"AI_Contact_Info_Return"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(contactInfoError:)
                   name:@"AI_Contact_Info_Error"
                 object:nil];
}

- (void)removeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:@"AI_Contact_Info_Return"
                    object:nil];
    [center removeObserver:self
                      name:@"AI_Contact_Info_Error"
                    object:nil];
    
}

- (void) sendUserInfoIQWithJID:(NSString *)aJID {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"id"
                     stringValue:@"AI_Contact_Info"];
        [iq addAttributeWithName:@"type"
                     stringValue:@"get"];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query"
                                                      xmlns:kUserInfoNameSpace];
        NSXMLElement *user = [NSXMLElement elementWithName:@"user"];
        [user addAttributeWithName:@"jid"
                       stringValue:aJID];
        
        [query addChild:user];
        [iq addChild:query];
        
        JLLog_I(@"Contact info=%@", iq);
        [[XMPPServer xmppStream] sendElement:iq];
    });
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self performSelector:@selector(afterDelay) withObject:nil afterDelay:60.0];
}


- (void)afterDelay {
    MBProgressHUD *progress = [MBProgressHUD HUDForView:self.view];
    if (progress) {
        [progress hide:YES];
        [AIControllersTool tipViewShow:@"请求超时，请稍后重试"];
    }
}
- (void)contactInfoReturn:(NSNotification *)notification {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSDictionary *dict = notification.userInfo;
    UserInfo *userinfo = dict[@"result"];
    ContactInfo* contactinfoVC = [[ContactInfo alloc] initWithNibName:@"ContactInfo" bundle:nil];
    contactinfoVC.jid = userinfo.jid;
    contactinfoVC.userinfo = userinfo;
    contactinfoVC.rightBarButtonHidden = YES;
    [self.navigationController pushViewController:contactinfoVC animated:YES];
}

- (void)contactInfoError:(NSNotification *)notification {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [AIControllersTool tipViewShow:@"服务器出错"];
}

-(void) addFriend:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    
    TKAddressBook *book = [[mGroupAddressBooks objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if(book.registered){
        UserInfo *userInfo = [[UserInfo alloc] init];
        userInfo.jid = book.jid;
        userInfo.nickName = book.nickname;
        userInfo.remarkName = book.remarkName;
        userInfo.avatar = book.avatar;
        userInfo.gender = book.gender;
        userInfo.accountType = book.accountType;
        
        ContactInfo *contactInfo = [[ContactInfo alloc]init];
        contactInfo.jid = book.jid;
        contactInfo.userinfo = userInfo;
        contactInfo.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:contactInfo animated:YES];
    } else {
        [self startLoading];
        mPhoneNum = book.tel;
        [self getInviteCodeWithPhoneNum:mPhoneNum name:book.name];
    }
}

- (void) getInviteCodeWithPhoneNum:(NSString*)phoneNum name:(NSString*)name
{
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/invite"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *acc=[NSXMLElement elementWithName:@"account"];
    NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:phoneNum];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"invitationNewFriend"];
    [phone addAttributeWithName:@"countryCode" stringValue:@"+86"];
    [phone addAttributeWithName:@"name" stringValue:name];
    [acc addChild:phone];
    [queryElement addChild:acc];
    [iq addChild:queryElement];
    //NSLog(@"组装后的xml:%@",iq);
    if ([[XMPPServer xmppStream] isConnected]) {
        [[XMPPServer xmppStream] sendElement:iq];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //网络已断开
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:NSLocalizedString(@"public.alert.networkConnectionFailure",@"message")  delegate:nil cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title")  otherButtonTitles:nil, nil];
            [alertView show];
            //[alertView release];
        });
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 47;
}


#pragma mark-发送短信

- (void)sendSMS:(NSNotification*)sender
{
    [self finishLoading];
    NSString *content = [[NSUserDefaults standardUserDefaults] objectForKey:@"smContent"];
    if(content != nil && ![@"" isEqualToString:content]){
        [self sendSMSToPhone:@[mPhoneNum] content:content];
    } else {
        //网络已断开
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:NSLocalizedString(@"public.alert.networkConnectionFailure",@"message")  delegate:nil cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title")  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)sendSMSToPhone:(NSArray*)phones content:(NSString*)content
{
    BOOL canSendSMS = [MFMessageComposeViewController canSendText];
    if (canSendSMS) {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.title = @"邀请注册";
        picker.messageComposeDelegate = self;
        picker.body = content;
        picker.recipients = phones;
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-上传通讯录

- (NSMutableArray *)getChineseStringArr:(NSMutableArray *)arrToSort {
    _sectionHeadsKeys = [NSMutableArray array];
    NSMutableArray *chineseStringsArray = [NSMutableArray array];
    for(int i = 0; i < [arrToSort count]; i++) {
        TKAddressBook *addressBook = [arrToSort objectAtIndex:i];
        
        addressBook.string = addressBook.name;
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
    return arrayForArrays;
}


//获取手机通讯录权限
- (void)loadAddressBookPermission {


    //----------------xiong 访问通讯录------------------------
    ABAddressBookRef addressBooks = ABAddressBookCreateWithOptions(NULL, NULL);
    //获取通讯录权限
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error) {
        accessGranted = granted;
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    //dispatch_release(sema);

    if (accessGranted == YES) {
            //获取通讯录中的所有人
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
            //通讯录中人数
            CFIndex nPeople = ABAddressBookGetPersonCount(addressBooks);
            
            NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:
                                                      
                                                      @"\\(|\\)|-|\\s|(\\+86)" options:0 error:nil];
            
            //循环，获取每个人的个人信息
            for (NSInteger i = 0; i < nPeople; i++) {
                //新建一个addressBook model类
                TKAddressBook *addressBook = [[TKAddressBook alloc] init];
                //获取个人
                ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
                //获取个人名字
                CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
                CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
                CFStringRef abFullName = ABRecordCopyCompositeName(person);
                NSString *nameString = (__bridge NSString *) abName;
                NSString *lastNameString = (__bridge NSString *) abLastName;
                if ((__bridge id) abFullName != nil) {
                    nameString = (__bridge NSString *) abFullName;
                } else {
                    if ((__bridge id) abLastName != nil) {
                        nameString = [NSString stringWithFormat:@"%@%@", nameString, lastNameString];
                    }
                }
                if ((__bridge id) abFullName == nil && (__bridge id) abLastName == nil) {
                    nameString = @"";
                }
                addressBook.name = nameString;
                //通讯录中文名字转拼音
                NSString *outputPinyin = [PinYinForObjc chineseConvertToPinYin:nameString];
                addressBook.sortKey = outputPinyin;
                addressBook.recordID = (int) ABRecordGetRecordID(person);;
                ABPropertyID multiProperties[] = {
                    kABPersonPhoneProperty,
                    kABPersonEmailProperty
                };
                NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
                for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
                    ABPropertyID property = multiProperties[j];
                    ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
                    NSInteger valuesCount = 0;
                    if (valuesRef != nil) valuesCount = ABMultiValueGetCount(valuesRef);
                    
                    if (valuesCount == 0) {
                        if (valuesRef != nil)
                            CFRelease(valuesRef);
                        continue;
                    }
                    //获取电话号码和email
                    for (NSInteger k = 0; k < valuesCount; k++) {
                        CFTypeRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                        switch (j) {
                            case 0: {// Phone number
                                addressBook.tel = (__bridge NSString *) value;
                                //NSLog(@"addressBook.tel before %@", addressBook.tel);
                                addressBook.tel  = [regularExpression stringByReplacingMatchesInString:addressBook.tel options:0 range:NSMakeRange(0, addressBook.tel.length) withTemplate:@""];
                                //NSLog(@"addressBook.tel after %@", addressBook.tel);
                                break;
                            }
                        }
                        CFRelease(value);
                    }

                    
                    CFRelease(valuesRef);
                }
                
                if (abName) CFRelease(abName);
                if (abLastName) CFRelease(abLastName);
                if (abFullName) CFRelease(abFullName);

                if(![AIRegex isPhoneNumberFromat:addressBook.tel]){
                    continue;
                }
                
                [mAddressBooks addObject:addressBook];
            }
            
            //silencesky upd
            if (allPeople) {
                CFRelease(allPeople);
            }
        
        [self uploadAddressBook]; //上传通讯录
    } else {
        [self finishLoading];
    }
    
    //silencesky upd
    if (addressBooks)
        CFRelease(addressBooks);
}


//上传通讯录
/*
 <iq type=”set”>
 <query xmlns=”http://www.nihualao.com/xmpp/contacts”>
    <phones>13812345678,13812345679</phones>
 </query>
 </iq>
 */
- (void)uploadAddressBook
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray *contacts = [ContactsCRUD queryContactsListTwo:MY_JID];
        
        NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/contacts"];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        NSXMLElement *phones = [NSXMLElement elementWithName:@"phones"];

        NSString *phonesStr = @"";
        
        for (int i = 0; i < [mAddressBooks count]; i++) {
            TKAddressBook *addressBook = [mAddressBooks objectAtIndex:i];
            
            BOOL hasMatched = NO;
            for(NSDictionary *contact in contacts){
                if(contact[@"phone"] && [contact[@"phone"] isEqualToString: [NSString stringWithFormat:@"+86%@", addressBook.tel]]){
                    addressBook.jid = contact[@"userName"];
                    addressBook.isMyFriend = YES;
                    addressBook.registered = YES;
                    addressBook.avatar = contact[@"avatar"];
                    addressBook.nickname = contact[@"nickName"];
                    addressBook.remarkName = contact[@"name"];
                    hasMatched = YES;
                    break;
                }
            }
            
            if(!hasMatched){
                addressBook.isMyFriend = NO;
                addressBook.remarkName = nil;
                phonesStr = (i == 0 ? addressBook.tel: [NSString stringWithFormat:@"%@,%@", phonesStr, addressBook.tel]);
            }
        }
        
        [phones setStringValue:phonesStr];
        [queryElement addChild:phones];

        [iq addAttributeWithName:@"id" stringValue:@"getAccontByPhones"];
        [iq addAttributeWithName:@"type" stringValue:@"get"];
        [iq addChild:queryElement];
        [[XMPPServer xmppStream] sendElement:iq];
    });
}

- (void) reloadTableView:(id)sender
{
    [self uploadAddressBook];
}

//通知刷新通讯录
- (void)loadAddressBook:(NSNotification*)sender
{
    NSDictionary *phoneDictionary = sender.userInfo ;
    
    for(TKAddressBook *book in mAddressBooks){
        NSDictionary *phone = phoneDictionary[[NSString stringWithFormat:@"+86%@", book.tel]];
        if (phone && phone.count > 0) {
            book.jid = [NSString stringWithFormat:@"%@@%@",phone[@"username"],OpenFireHostName];
            book.avatar =  phone[@"avatar"];
            book.registered = YES;
            book.accountType = [phone[@"accountType"] intValue];
            book.gender = [phone[@"gender"] intValue];
            book.nickname = phone[@"nickname"];
        }
    }
    
    mGroupAddressBooks = [self getChineseStringArr:mAddressBooks];
    [self.tableView reloadData];
    
    [self finishLoading];
    [self.refreshControl endRefreshing];
}

- (void)startLoading
{
    if (!self.hub) {
        MBProgressHUD *hub = [[MBProgressHUD alloc] initWithView:self.tableView];
        hub.labelText = @"正在加载";
        [self.view addSubview:hub];
        self.hub = hub;
    }
    
    [self.hub show:YES];
    [self.view bringSubviewToFront:self.hub];
    [self.hub hide:YES afterDelay:10];
}

- (void)finishLoading
{
    if (!self.hub.hidden) {
        [self.hub hide:YES];
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:@"NCC_AddressBooK_Success"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"smContent"];
}

@end
