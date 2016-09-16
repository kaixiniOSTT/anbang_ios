//
//  DialViewController.m
//  anbang_ios
//
//  Created by seeko on 14-4-23.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "CallRecordsViewController.h"
#import "RoyaDialViewDelegate.h"
#import "APPRTCViewController.h"
#import "InformationCell.h"
#import "ChatMessageCRUD.h"
#import "PublicCURD.h"
#import "UserCenterViewController.h"
#import "UIImageView+WebCache.h"
#import "UserInfoCRUD.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface CallRecordsViewController ()
{
    NSMutableArray *arrCallRecords;
    NSMutableArray *arrBuddyList;
    FMDatabase *db;
    
}
@property (nonatomic, strong) NSMutableArray *suggestionsDictionary;
@property (nonatomic, strong) NSArray *suggestionOptions; // of selected NSStrings


@end

@implementation CallRecordsViewController
@synthesize suggestionsDictionary;
@synthesize suggestionOptions;
@synthesize tbBuddy=_tbBuddy;
@synthesize receiveUserJID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    suggestionsDictionary=[NSMutableArray arrayWithObjects: nil];
    suggestionOptions=[NSMutableArray arrayWithObjects: nil];
    arrCallRecords=[[NSMutableArray alloc]init];
    
    [self ui];
    
    receiveUserJID = @"";
    //    [txtNum addTarget:self action:@selector(txtNum:) forControlEvents:UIControlEventEditingChanged];
    [self queryBuddyList:MY_JID];
    arrCallRecords=[ChatMessageCRUD selectChatMessageCallRecords];
    [_tbBuddy reloadData];
    self.view.frame =CGRectMake(0, 0, KCurrWidth, KCurrHeight);
}


-(void)refreshData{
    [self queryBuddyList:MY_JID];
    arrCallRecords=[ChatMessageCRUD selectChatMessageCallRecords];
    [_tbBuddy reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDial2:) name:@"NNC_Is_Have_Userinfo" object:nil];
    
    [self queryBuddyList:MY_JID];
    
    arrCallRecords=[ChatMessageCRUD selectChatMessageCallRecords];
    
    //CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
    // appDelegate.tabBarBG.hidden=NO;
    [_tbBuddy reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (void)dealloc{
    
}

-(void)ui{
    // int heightdvi;
    // CGRect rect=[[UIScreen mainScreen]bounds];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        //self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
        //  heightdvi=0;
    }else{
        //  heightdvi=0;
    }
    
    int cutHeight=113;
    
    _tbBuddy=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-cutHeight) style:UITableViewStylePlain];
    _tbBuddy.delegate=self;
    _tbBuddy.dataSource=self;
    
    [self.view addSubview:_tbBuddy];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -数据库操作－查询好友列表


-(void)queryBuddyList:(NSString *)myJID{
    arrBuddyList=[NSMutableArray arrayWithObjects: nil];
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select c.jid, c.remarkName,u.nickName,u.phone,u.avatar,c.addTime from Contacts c,UserInfo u where c.jid = u.jid and u.myJID = \"%@\" and c.myJID = \"%@\"",myJID,myJID];
        
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            NSString *jid=[rs stringForColumn:@"jid"];
            NSString *num = [jid stringByReplacingOccurrencesOfString:@"@ab-insurance.com" withString:@""];
            NSString *remarkName = [rs stringForColumn:@"remarkName"];
            NSString *nickName = [rs stringForColumn:@"nickName"];
            NSString *avatar = [rs stringForColumn:@"avatar"];
            [arrBuddyList addObject:[NSDictionary dictionaryWithObjectsAndKeys:num,@"num",remarkName, @"name",nickName,@"nickName",avatar,@"avatar", nil]];
            [self.suggestionsDictionary addObject:num];
        }
        
        [rs close];
    }
    
    [db close];
}


//error
- (void)ErrorReport: (NSString *)item
{
    
    char *errorMsg;
    const char *itemChar = [item UTF8String];
    if (sqlite3_exec(database, (const char *)itemChar, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"%@ ok.",item);
    }
    else
    {
        NSLog(@"error: %s",errorMsg);
        //sqlite3_free(errorMsg);
    }
}


#pragma mark -UItableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return  [arrCallRecords count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"buddyCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
    }
    
    if ([[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"sendUser"] isEqualToString:MY_USER_NAME]) {
        BOOL isBuddy=NO;
        for (int i=0; i<[arrBuddyList count]; i++) {
            //NSLog(@"%@-%@",[[arrBuddyList objectAtIndex:i]objectForKey:@"num"],[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"receiveUser"]);
            if([[[arrBuddyList objectAtIndex:i]objectForKey:@"num"] isEqualToString:[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"receiveUser"]]){
                isBuddy=YES;
                if ([@"(null)" isEqualToString:[[arrBuddyList objectAtIndex:i]objectForKey:@"name"]]||[@"" isEqualToString:[[arrBuddyList objectAtIndex:i]objectForKey:@"name"]]) {
                    if ([@"(null)" isEqualToString:[[arrBuddyList objectAtIndex:i]objectForKey:@"nickName"]]||[@"" isEqualToString:[[arrBuddyList objectAtIndex:i]objectForKey:@"nickName"]]) {
                        cell.textLabel.text=[[arrBuddyList objectAtIndex:i]objectForKey:@"num"];
                    }else{
                        cell.textLabel.text=[[arrBuddyList objectAtIndex:i]objectForKey:@"nickName"];
                    }
                }else{
                    cell.textLabel.text=[[arrBuddyList objectAtIndex:i]objectForKey:@"name"];
                }
            }
            if(isBuddy==NO){
                cell.textLabel.text=[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"receiveUser"];
            }
        }
    }else{
        BOOL isBuddy=NO;
        for (int i=0; i<[arrBuddyList count]; i++) {
            if([[[arrBuddyList objectAtIndex:i]objectForKey:@"num"] isEqualToString:[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"sendUser"]]){
                isBuddy=YES;
                if ([@"(null)" isEqualToString:[[arrBuddyList objectAtIndex:i]objectForKey:@"name"]]||[@"" isEqualToString:[[arrBuddyList objectAtIndex:i]objectForKey:@"name"]]) {
                    if ([@"(null)" isEqualToString:[[arrBuddyList objectAtIndex:i]objectForKey:@"nickName"]]||[@"" isEqualToString:[[arrBuddyList objectAtIndex:i]objectForKey:@"nickName"]]) {
                        cell.textLabel.text=[[arrBuddyList objectAtIndex:i]objectForKey:@"num"];
                    }else{
                        cell.textLabel.text=[[arrBuddyList objectAtIndex:i]objectForKey:@"nickName"];
                    }
                }else{
                    cell.textLabel.text=[[arrBuddyList objectAtIndex:i]objectForKey:@"name"];
                }
            }
            if (isBuddy==NO) {
                cell.textLabel.text=[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"sendUser"];
            }
        }
    }
    cell.detailTextLabel.text=[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"message"];
    UILabel *labRigitText=[[UILabel alloc]initWithFrame:CGRectMake(0,35, 310, 20)];
    labRigitText.textColor=[UIColor lightGrayColor];
    [labRigitText setBackgroundColor:[UIColor clearColor]];
    //        labRigitText.text=@"labRigitText";
    labRigitText.font=[UIFont boldSystemFontOfSize:14];
    labRigitText.textAlignment=NSTextAlignmentRight;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *localDate = [dateFormatter dateFromString:[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"sendTime"]];
    labRigitText.text= [self stringFromDate:[self getNowDateFromatAnDate:localDate]];
    [cell addSubview:labRigitText];
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 60;
}


- (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
    
}


- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
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
                                                              //语音通话
                                                              if ([[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"sendUser"] isEqualToString:MY_USER_NAME]) {
                                                                  // NSLog(@"*******%@",[[arrCallRecords objectAtIndex:actionSheet.tag]objectForKey:@"receiveUser"]);
                                                                  [self playDial:[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"receiveUser"]];
                                                              }else{
                                                                  // NSLog(@"*******%@",[[arrCallRecords objectAtIndex:actionSheet.tag]objectForKey:@"receiveUser"]);
                                                                  [self playDial:[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"sendUser"]];
                                                              }
                                                          }]];
        [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ContactsDetails.videoCall",@"action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              //视频通话
                                                              if ([[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"sendUser"] isEqualToString:MY_USER_NAME]) {
                                                                  [self playVideo:[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"receiveUser"]];
                                                              }else{
                                                                  [self playVideo:[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"sendUser"]];
                                                              }
                                                              
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
        
        UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"title") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ContactsDetails.voiceCall",@"title"),NSLocalizedString(@"ContactsDetails.videoCall",@"title"), nil];
        actionSheet.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
        actionSheet.tag = indexPath.row;
        [actionSheet showInView:self.view.window];
    }
}



//点击删除按钮后, 会触发如下事件. 在该事件中做响应动作就可以了
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle  forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete){
        
        NSString *msgId = [[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"msgRandomId"];
        
        [ChatMessageCRUD deleteChatMessage:msgId];
        
        arrCallRecords=[ChatMessageCRUD selectChatMessageCallRecords];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
        [_tbBuddy reloadData];
        });

    
        
    }
    
}


#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    switch (buttonIndex) {
        case 0:
            //语音通话
            if ([[[arrCallRecords objectAtIndex:actionSheet.tag]objectForKey:@"sendUser"] isEqualToString:MY_USER_NAME]) {
                // NSLog(@"*******%@",[[arrCallRecords objectAtIndex:actionSheet.tag]objectForKey:@"receiveUser"]);
                [self playDial:[[arrCallRecords objectAtIndex:actionSheet.tag]objectForKey:@"receiveUser"]];
            }else{
                // NSLog(@"*******%@",[[arrCallRecords objectAtIndex:actionSheet.tag]objectForKey:@"receiveUser"]);
                [self playDial:[[arrCallRecords objectAtIndex:actionSheet.tag]objectForKey:@"sendUser"]];
            }
            break;
        case 1:
            //视频通话
            if ([[[arrCallRecords objectAtIndex:actionSheet.tag]objectForKey:@"sendUser"] isEqualToString:MY_USER_NAME]) {
                [self playVideo:[[arrCallRecords objectAtIndex:actionSheet.tag]objectForKey:@"receiveUser"]];
            }else{
                [self playVideo:[[arrCallRecords objectAtIndex:actionSheet.tag]objectForKey:@"sendUser"]];
            }
            break;
            
        default:
            break;
    }
}


/*---视频语音start-----------------------------------------------------------------------------------*/
//打电话
-(void)playDial:(NSString*)receiveUser{
    //NSLog(@"开始拨打电话");
#if !TARGET_IPHONE_SIMULATOR
    NSString *callJID;
    if (receiveUser.length>0) {
        callJID= [receiveUser stringByAppendingFormat:@"@%@",OpenFireHostName];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示" message:@"请输入邦邦社区号码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
    XMPPJID *to = [XMPPJID jidWithString:callJID resource:@"Hisuper"];
    NSString *toStrJID = [callJID stringByAppendingFormat:@"%@",@"/Hisuper"];
    
    NSString* sessionID = [XMPPStream generateUUID];
    NSLog(@"******%@",sessionID);
    if(YES)
    {
        APPRTCViewController *appView = [[APPRTCViewController alloc]init];
       // NSLog(@"******%@",[to full]);
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
            [appView.lbname setText:to.user];
            
            
            NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [UserInfoCRUD queryUserInfoAvatar:callJID]];
            
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
-(void)playVideo:(NSString*)receiveUser{
    //NSLog(@"开始语音视频");
#if !TARGET_IPHONE_SIMULATOR
    NSString *callJID;
    if (![StrUtility isBlankString:receiveUser]) {
        callJID= [receiveUser stringByAppendingFormat:@"@%@",OpenFireHostName];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示" message:@"请输入邦邦社区号码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    XMPPJID *to = [XMPPJID jidWithString:callJID resource:@"Hisuper"];
    NSString *toStrJID = [callJID stringByAppendingFormat:@"%@",@"/Hisuper"];
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
            [appView.lbname setText:to.user];
            NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [UserInfoCRUD queryUserInfoAvatar:callJID]];
            
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
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"public.callFailure",@"message") delegate:nil cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") otherButtonTitles:nil, nil];
        [alert show];
        
    }
#endif
}
/*---视频语音end-----------------------------------------------------------------------------------*/


-(void)showAlert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
}

/*---视频语音end-----------------------------------------------------------------------------------*/


@end
