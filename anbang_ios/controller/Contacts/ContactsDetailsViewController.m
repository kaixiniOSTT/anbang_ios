//
//  ContactsDetailsViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 14-5-10.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "ContactsDetailsViewController.h"
#import "ASIHTTPRequest.h"
#import "CHAppDelegate.h"
#import "GBPathImageView.h"
#import "BlackListCRUD.h"
#import "ContactsCRUD.h"
#import "ChatViewController2.h"
#import "ContactsRemarkNameTableViewController.h"
#import "IdGenerator.h"
#import "UIButton+Bootstrap.h"
#import "ChatBuddyCRUD.h"
#import "ChatMessageCRUD.h"
#import "JSMessageSoundEffect.h"
#import "UIImageView+WebCache.h"

@interface ContactsDetailsViewController (){

}

@end

@implementation ContactsDetailsViewController
@synthesize tableView = _tableView;
@synthesize contactsUserName = _contactsUserName;
@synthesize contactsRemarkName = _contactsRemarkName;
@synthesize contactsNickName = _contactsNickName;
@synthesize contactsAvatarURL = _contactsAvatarURL;
@synthesize contactsJID = _contactsJID;
@synthesize blackListStatus = _blackListStatus;
@synthesize sourceFlag = _sourceFlag;

@synthesize fileName = _fileName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Blacklist" object:nil];
    // [_sourceFlag release];
    // [_contactsUserName release];
    // [_contactsAvatarURL release];
    // [_contactsJID release];
    // [_contactsRemarkName release];
    // [_blackListStatus release];
    // [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置通知中心，更新黑名单；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBlackListStatus)
                                                 name:@"NNC_Blacklist" object:nil];
    
    if ([_sourceFlag isEqualToString:@"addContactsResult"]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(popToRootView)];
        
    }
    
    _tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-Both_Bar_Height) style:UITableViewStyleGrouped];
    
    // _myTableView.scrollEnabled = YES;
    // 设置tableView的数据源
    _tableView.dataSource = self;
    // 设置tableView的委托
    _tableView.delegate = self;
    // 设置tableView的背景图
    // tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
    // self.myTableView = tableView;
    [self.view addSubview:_tableView];
    //_myTableView.hidden = YES;
    
    //    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
    //        self.edgesForExtendedLayout = UIRectEdgeNone;
    //        self.extendedLayoutIncludesOpaqueBars = NO;
    //        self.modalPresentationCapturesStatusBarAppearance = NO;
    //        //self.navigationController.navigationBar.translucent = NO;
    //        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    //    }
    
    [self.navigationItem setTitle:NSLocalizedString(@"ContactsDetails.title",@"title")];
    
}

//渐变 和 移动
- (UIGestureRecognizer *)createTapRecognizerWithSelector:(SEL)selector {
    return [[UITapGestureRecognizer alloc]initWithTarget:self action:selector];
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    return NO;
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //这个方法用来告诉表格有几个分组
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //这个方法告诉表格第section个分组有多少行
    int row=0;
    if(section==0)
        row=1;
    else if(section==1){
        row=2;
    } else if(section==2){
        row=2;
    }else if(section==3){
        row=2;
    }else if(section==4){
        row=1;
    }
    return row;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"";
    }
    return @"";
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if(section == 2){
        
        return @"";
    }else
        return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    //这个方法用来告诉某个分组的某一行是什么数据，返回一个UITableViewCell
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    static NSString *GroupedTableIdentifier = @"TableSampleIdentifier";
    // UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GroupedTableIdentifier] autorelease];
    
    //这种为不复用
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GroupedTableIdentifier];
    if (cell == nil) {
        cell = cell;
    }else{
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GroupedTableIdentifier];
    }
    
    
    if(section==0&&row==0){
        
        UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 50.0, 50.0)];
        [photoView setImageWithURL:[NSURL URLWithString:_contactsAvatarURL]
                  placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
        if (_contactsAvatarURL.length>0 ){
            //        GBPathImageView *squareImage = [[GBPathImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 60.0, 60.0) image:contactsAvatar pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor whiteColor] pathWidth:0.0];
            CGSize itemSize = CGSizeMake(45, 45);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [photoView.image drawInRect:imageRect];
            cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            //备注名不为空时显示备注名
            NSString *contactsName = @"";
            if ([_contactsRemarkName isEqualToString:@"(null)"]|| [_contactsRemarkName isEqualToString:@""] || _contactsRemarkName == NULL) {
                contactsName = _contactsNickName;
            }else{
                contactsName = _contactsRemarkName;
            }
            
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(65, 20, 180, 30)];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.text = contactsName;
            
            [cell.contentView addSubview:nameLabel];
            //cell.textLabel.text = contactsName;
            //cell.textLabel.backgroundColor = [UIColor clearColor];
            
        }else{
            UIImage *userImage =[UIImage imageNamed:@"defaultUser.png"];
            CGSize itemSize = CGSizeMake(45, 45);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [userImage drawInRect:imageRect];
            cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            
            //备注名不为空时显示备注名
            NSString *contactsName = @"";
            if ([_contactsRemarkName isEqualToString:@"(null)"]|| [_contactsRemarkName isEqualToString:@""] || _contactsRemarkName == NULL) {
                contactsName = _contactsNickName;
            }else{
                contactsName = _contactsRemarkName;
            }
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(65, 20, 180, 30)];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.text = contactsName;
            
            [cell.contentView addSubview:nameLabel];
            
            //            cell.textLabel.text = contactsName;
            //            cell.textLabel.backgroundColor = [UIColor clearColor];
        }
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if(section==1 && row==0){
        UILabel *label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor clearColor];
        label.frame = CGRectMake(KCurrWidth-220, 0,200, 40);
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = [UIColor grayColor];
        label.text = _contactsUserName;
        cell.textLabel.textColor=kMainColor;
        cell.textLabel.text = NSLocalizedString(@"public.appName",@"title");
        [cell addSubview:label];
        // cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", @"邦邦社区",_contactsUserName];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if(section==1&&row==1){
        UILabel *label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor clearColor];
        label.frame = CGRectMake(KCurrWidth-100, 0,200, 40);
        label.textColor = [UIColor grayColor];
        if ([_contactsRemarkName isEqualToString:@"(null)"]|| [_contactsRemarkName isEqualToString:@""] || _contactsRemarkName == NULL) {
            label.text = @"";
        }else{
            label.text = _contactsRemarkName;
        }
        //cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", @"修改备注",_contactsRemarkName];
        //cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.textColor=kMainColor;
        cell.textLabel.text = NSLocalizedString(@"ContactsDetails.modifyRemark",@"action");
        [cell addSubview:label];
        //cell.imageView.image = [UIImage imageNamed:@"setting_icon_account"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
   
        
    }else if(section==2&&row==0){
        cell.textLabel.text = NSLocalizedString(@"ContactsDetails.sendMessage",@"action");
        cell.textLabel.textColor = kMainColor;
        //cell.imageView.image = [UIImage imageNamed:@"setting_icon_clean"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if(section==2&&row==1){
        cell.textLabel.text = NSLocalizedString(@"ContactsDetails.voiceCall",@"action");
        cell.textLabel.textColor = kMainColor;
        // cell.imageView.image = [UIImage imageNamed:@"setting_icon_info"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
    }else if(section==3&&row==0){
        cell.textLabel.text =[NSString stringWithFormat:  @"%@",_blackListStatus];
        cell.textLabel.textColor = [UIColor redColor];
        //cell.imageView.image = [UIImage imageNamed:@"setting_icon_account"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if(section==3&&row==1){
        cell.textLabel.text = NSLocalizedString(@"ContactsDetails.deleteContact",@"action");
        cell.textLabel.textColor = [UIColor redColor];
        // cell.imageView.image = [UIImage imageNamed:@"setting_icon_info"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    //NSLog(@"%d,%d",section,row);
    if (section==0 && row==0) {
        //跳转个人信息页
        
    }else if(section==1&&row==1){
        ContactsRemarkNameTableViewController *contactsRemarkNameTVC = [[ContactsRemarkNameTableViewController alloc]init];
        contactsRemarkNameTVC.contactsJID = _contactsJID;
        [self.navigationController pushViewController:contactsRemarkNameTVC animated:YES];
        return;
        
    }else if(section==2&&row==0){
        //发送消息
        [self sendMsg];
    }else if(section==2&&row==1){
        //发送语音
        //[self playDial];
        
    }else if(section==3&&row==0){
        if([_blackListStatus isEqualToString:NSLocalizedString(@"ContactsDetails.addBlacklist",@"action")]){
            //加入黑名单
            [self addBlacklistActionSheet];
            
        }else{
            //解绑黑名单
            [self unbundlingBlacklistActionSheet];
            
        }
    }else if(section==3&&row==1){
        [self deleteContactsActionSheet];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10;
}

- (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    // [dateFormatter release];
    return destDateString;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    
    if ([ indexPath indexAtPosition: 1 ] == 0 && section ==0)
        return 80.0;
    else
        return 50.0;
}

//发送消息
-(void)sendMsg{
    ChatViewController2 * chatViewCtl=[[ChatViewController2 alloc]init];
    chatViewCtl.chatWithUser = _contactsUserName;
    chatViewCtl.chatWithNick = _contactsNickName;
    chatViewCtl.chatWithJID  = _contactsJID;
    // chatViewCtl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    chatViewCtl.title = _contactsNickName;
    chatViewCtl.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController :chatViewCtl animated:YES];
    
}

//确定加入黑名单提示
- (void)addBlacklistActionSheet
{
    //确定加入黑名单
    if (kIOS_VERSION>=8.0) {
        
        UIAlertController *otherLoginAlert = nil;
        if (kIsPad) {
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleAlert];
        }else{
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        }
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ContactsDetails.sureAddBlacklist",@"action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self addBlackList:_contactsJID];
                                                          }]];
        
        
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
        
        UIActionSheet *menu=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ContactsDetails.sureAddBlacklist",@"action"),nil];
        menu.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
        menu.tag=10000;
        [menu showInView:self.view.window];
    }
    
}

//解绑黑名单提示
- (void)unbundlingBlacklistActionSheet
{
    //确定解除黑名单
    if (kIOS_VERSION>=8.0) {
        
        UIAlertController *otherLoginAlert = nil;
        if (kIsPad) {
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleAlert];
        }else{
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        }
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ContactsDetails.sureRemoveBlacklist",@"action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self unbundlingBlackList:_contactsJID];                                                          }]];
        
        
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
        
        UIActionSheet *menu=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ContactsDetails.sureRemoveBlacklist",@"action"),nil];
        menu.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
        menu.tag=10001;
        [menu showInView:self.view.window];
    }
}

//确定删除联系人提示
- (void)deleteContactsActionSheet
{
    if (kIOS_VERSION>=8.0) {
        UIAlertController *otherLoginAlert = nil;
        
        if (kIsPad) {
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleAlert];
        }else{
            otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        }
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ContactsDetails.sureDeleteContact",@"action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self removeContacts:_contactsJID];
                                                              //跳转到联系人列表
                                                              [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];                                                         }]];
        
        
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
        
        UIActionSheet *menu=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ContactsDetails.sureDeleteContact",@"action"),nil];
        menu.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
        menu.tag=10002;
        [menu showInView:self.view.window];
    }
}

#pragma mark -
#pragma mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (actionSheet.tag==10000) {
        //加入黑名单
        switch (buttonIndex) {
            case 0:
                //NSLog(@"click at index %d，确定操作", buttonIndex);
                [self addBlackList:_contactsJID];
                break;
            case 1:
                //NSLog(@"click at index %d，取消操作", buttonIndex);
                break;
                
            default:
                //NSLog(@"unknown： click at index %d", buttonIndex);
                break;
        }
        
    }else if(actionSheet.tag==10001){
        //解绑黑名单
        switch (buttonIndex) {
            case 0:
                //NSLog(@"click at index %d，确定操作", buttonIndex);
                [self unbundlingBlackList:_contactsJID];
                break;
            case 1:
                //NSLog(@"click at index %d，取消操作", buttonIndex);
                break;
                
            default:
                //NSLog(@"unknown： click at index %d", buttonIndex);
                break;
        }
    }else if(actionSheet.tag==10002){
        //删除联系人
        switch (buttonIndex) {
            case 0:
                //NSLog(@"click at index %d，确定操作", buttonIndex);
                [self removeContacts:_contactsJID];
                //跳转到联系人列表
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
                
                break;
            case 1:
                //NSLog(@"click at index %d，取消操作", buttonIndex);
                break;
                
            default:
                //NSLog(@"unknown： click at index %d", buttonIndex);
                break;
        }
        
    }
}

//加入黑名单
-(void)addBlackList:(NSString *)contactsJID{
    if([_blackListStatus isEqualToString:NSLocalizedString(@"ContactsDetails.addBlacklist",@"title")] && [BlackListCRUD queryBlacklistTableCountId:_contactsUserName myUserName:MY_USER_NAME]==0){
        [BlackListCRUD insertBlackListTable:_contactsUserName myUserName:MY_USER_NAME];
    }
    NSString *myJID = [[NSString alloc] initWithFormat:@"%@", [XMPPServer xmppStream].myJID.bareJID];
    // NSMutableArray *contactsUserNameArray = [[[NSMutableArray alloc]init]autorelease];
    NSMutableArray *contactsUserNameArray = [BlackListCRUD queryMyBlackListByMyUserName:MY_USER_NAME];
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *list = [NSXMLElement elementWithName:@"list"];
    
    //id 随机生成（须确保无重复）
    // NSLog(@"*******%@",[IdGenerator next]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[IdGenerator next] forKey:@"IQ_Add_BlackList"];
    
    [iq addAttributeWithName:@"id" stringValue:[defaults stringForKey:@"IQ_Add_BlackList"]];
    
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"from" stringValue:myJID];
    [list addAttributeWithName:@"name" stringValue:@"BlackList"];
    //[myJID release];
    //遍历
    [contactsUserNameArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        // NSLog(@"遍历array：%zi-->%@",idx,obj);
        
        if(![[obj objectForKey:@"contactsUserName" ] isEqualToString:@""] || [obj objectForKey:@"contactsUserName" ] !=NULL){
            NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
            NSXMLElement *iq2 = [NSXMLElement elementWithName:@"iq"];
            NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
            [item addAttributeWithName:@"action" stringValue:@"deny"];
            [item addAttributeWithName:@"type" stringValue:@"jid"];
            [item addAttributeWithName:@"order" stringValue:@"1"];
            [item addAttributeWithName:@"value" stringValue:[NSString stringWithFormat:@"%@@%@",[obj objectForKey:@"contactsUserName" ], OpenFireHostName]];
            
            [item addChild:iq2];
            [item addChild:message];
            [list addChild:item];
            
        }
    }];
    [iq addChild:queryElement];
    [queryElement addChild:list];
    //NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    //指定默认黑名单列表
    [self sendDefaultBlacklistName];
    
}

//指定默认黑名单列表
-(void)sendDefaultBlacklistName{
    NSString *myJID = [[NSString alloc] initWithFormat:@"%@", [XMPPServer xmppStream].myJID.bareJID];
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *defaultBlackListName = [NSXMLElement elementWithName:@"default"];
    
    [iq addAttributeWithName:@"id" stringValue:@"1011"];
    
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"from" stringValue:myJID];
    [defaultBlackListName addAttributeWithName:@"name" stringValue:@"BlackList"];
    
    [iq addChild:queryElement];
    [queryElement addChild:defaultBlackListName];
    
    [[XMPPServer xmppStream] sendElement:iq];
    // [myJID release];
}

//黑名单解绑
-(void)unbundlingBlackList:(NSString *)contactsJID{
    //id 随机生成（须确保无重复）
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[IdGenerator next] forKey:@"IQ_Relieve_BlackList"];
    
    if ([_blackListStatus isEqualToString:NSLocalizedString(@"ContactsDetails.removeBlacklist",@"title")]) {
        [BlackListCRUD deleteBlackList:_contactsUserName myUserName: MY_USER_NAME];
    }else {
        return;
    }
    
    NSString *myJID = [[NSString alloc] initWithFormat:@"%@", [XMPPServer xmppStream].myJID.bareJID];
    
    // NSMutableArray *contactsUserNameArray = [[[NSMutableArray alloc]init]autorelease];
    NSMutableArray *contactsUserNameArray = [BlackListCRUD queryMyBlackListByMyUserName:MY_USER_NAME];
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *list = [NSXMLElement elementWithName:@"list"];
    NSXMLElement *iq2 = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    
    [iq addAttributeWithName:@"id" stringValue:[defaults stringForKey:@"IQ_Relieve_BlackList"]];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"from" stringValue:myJID];
    [list addAttributeWithName:@"name" stringValue:@"BlackList"];
    
    //遍历
    [contactsUserNameArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //NSLog(@"遍历array：%zi-->%@",idx,obj);
        if(![[obj objectForKey:@"contactsUserName" ] isEqualToString:@""] || [obj objectForKey:@"contactsUserName" ] !=NULL){
            NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
            [item addAttributeWithName:@"action" stringValue:@"deny"];
            [item addAttributeWithName:@"type" stringValue:@"jid"];
            [item addAttributeWithName:@"order" stringValue:@"1"];
            [item addAttributeWithName:@"value" stringValue:[NSString stringWithFormat:@"%@@%@",[obj objectForKey:@"contactsUserName" ], OpenFireHostName]];
            [item addChild:iq2];
            [item addChild:message];
            [list addChild:item];
            
        }
    }];
    [iq addChild:queryElement];
    [queryElement addChild:list];
    //NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    //[myJID release];
}

//更新黑名单状态
-(void)updateBlackListStatus{
    //查询黑名单列表是否已存在
    if ([BlackListCRUD queryBlacklistTableCountId:_contactsUserName myUserName:MY_USER_NAME]>0){
        _blackListStatus = NSLocalizedString(@"ContactsDetails.removeBlacklist",@"title");
        
    }else{
        _blackListStatus = NSLocalizedString(@"ContactsDetails.addBlacklist",@"title");
    }
    
    [_tableView reloadData];
    
}

//删除联系人
- (void)removeContacts:(NSString *)contactsUserName
{
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",contactsUserName]];
    [[XMPPServer xmppRoster] removeUser:jid];
    [ContactsCRUD deleteContactsByChatUserName:contactsUserName];
}

/*---视频语音start-----------------------------------------------------------------------------------*/
//打电话
-(void)playDial{
}

/*---视频语音end-----------------------------------------------------------------------------------*/





//发送文本消息
-(void)sendMassage:(NSString *)message
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
        [mes addAttributeWithName:@"to" stringValue:_contactsJID];
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
    //检测网络情况
    NSString *network = @"connection";
    NSString *sendTimeStr =[Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    NSString *sendUTCTimeStr = [Utility getUTCFormateLocalDate:sendTimeStr];
    //消息写入数据库
    //发送消息时 receiveTime 与 sendTime 一致
    [ChatMessageCRUD insertChatMessage:MY_USER_NAME msg:message receiveUser:_contactsUserName msgType:@"chat" subject:@"chat" sendTime:sendUTCTimeStr receiveTime:sendUTCTimeStr readMark:1 sendStatus:network msgRandomId:msgRandomId myJID:MY_JID];
 
    //查询聊天列表是否存在
    Contacts *contacts = nil;
    contacts = [ChatBuddyCRUD queryBuddyByJID:_contactsJID myJID:MY_JID];
    NSString *lastMsgTime = [Utility getCurrentTime:@"yyyy-MM-dd HH:mm:ss"];
    //查询聊天列表是否已存在
    if ([ChatBuddyCRUD queryChatBuddyTableCountId:_contactsUserName myUserName:MY_USER_NAME]==0){
        
        [ChatBuddyCRUD insertChatBuddyTable:_contactsUserName jid:contacts.jid name:contacts.remarkName nickName:contacts.nickName phone:contacts.phone avatar:contacts.avatar myUserName:MY_USER_NAME type:@"chat" lastMsg:message msgType:@"chat" msgSubject:@"chat" lastMsgTime:lastMsgTime tag:@""];
        
    }else{
        [ChatBuddyCRUD updateChatBuddy:_contactsUserName name:contacts.remarkName nickName:contacts.nickName lastMsg:message msgType:@"chat" msgSubject:@"chat" lastMsgTime:lastMsgTime];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //查询黑名单列表是否已存在
    if ([BlackListCRUD queryBlacklistTableCountId:_contactsUserName myUserName:MY_USER_NAME]>0){
        _blackListStatus = NSLocalizedString(@"ContactsDetails.removeBlacklist",@"title");
    }else{
        _blackListStatus = NSLocalizedString(@"ContactsDetails.addBlacklist",@"title");
    }
    [_tableView reloadData];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)popToRootView
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (BOOL)shouldAutorotate{
    return NO;
}

@end
