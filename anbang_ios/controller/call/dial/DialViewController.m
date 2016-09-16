//
//  DialViewController.m
//  anbang_ios
//
//  Created by seeko on 14-4-23.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "DialViewController.h"
#import "RoyaDialView.h"
#import "RoyaDialViewDelegate.h"
#import "APPRTCViewController.h"
#import "CHAppDelegate.h"
#import "InformationCell.h"
#import "ChatMessageCRUD.h"
#import "PublicCURD.h"
#import "UserCenterViewController.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface DialViewController ()
{
    NSMutableArray *arrBuddyList;
    //UITableView *tbBuddy;
    UILabel *labNum;
    UITextField *txtNum;
    RoyaDialView *royaDialView;
    BOOL isTxtNum;
    NSMutableArray *arrCallRecords;

}
@property (nonatomic, strong) NSMutableArray *suggestionsDictionary;
@property (nonatomic, strong) NSArray *suggestionOptions; // of selected NSStrings


@end

@implementation DialViewController
@synthesize suggestionsDictionary;
@synthesize suggestionOptions;
@synthesize tbBuddy;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
    }
    return self;
}

-(id)init
{
    self = [super init];
    if(self != nil)
    {
        
//        XMPPServer* server = [XMPPServer sharedServer];
//        _voipModule = [VoipModule shareVoipModule];
//        _voipModule.voipDelegate = self;
//        [_voipModule activate:server.xmppStream];
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    arrBuddyList=[NSMutableArray arrayWithObjects: nil];
    suggestionsDictionary=[NSMutableArray arrayWithObjects: nil];
    suggestionOptions=[NSMutableArray arrayWithObjects: nil];
    arrCallRecords=[[NSMutableArray alloc]init];
    
    [self ui];

//    [txtNum addTarget:self action:@selector(txtNum:) forControlEvents:UIControlEventEditingChanged];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self queryBuddyList:MY_JID];
    
    arrCallRecords=[ChatMessageCRUD selectChatMessageCallRecords];
    
    //CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
   // appDelegate.tabBarBG.hidden=NO;
    [tbBuddy reloadData];
}


-(void)ui{
   // int heightdvi;
    CGRect rect=[[UIScreen mainScreen]bounds];
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
    isTxtNum=NO;
    txtNum=[[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 48)];
    txtNum.borderStyle=UITextBorderStyleBezel;
//    [txtNum setKeyboardType:UIKeyboardTypeNumberPad];
//    [txtNum setKeyboardAppearance:UIKeyboardAppearanceAlert];
//    [txtNum becomeFirstResponder];
    txtNum.placeholder=@"拨打iCirCall电话";
    txtNum.textAlignment=NSTextAlignmentCenter;
//     [self.view addSubview:txtNum];
    txtNum.inputView=[[UIView alloc]initWithFrame:CGRectZero];
    
    
    
    
    [self.navigationItem setTitle:[NSString stringWithFormat:@"本机号码:%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"]]];
    tbBuddy=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, rect.size.height-144) style:UITableViewStylePlain];
    [self.view addSubview:tbBuddy];
    tbBuddy.delegate=self;
    tbBuddy.dataSource=self;

    
    royaDialView = [[RoyaDialView alloc]init];
    royaDialView.delegate=self;

    [royaDialView showInView:self.view];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -数据库操作－查询好友列表

-(void)queryBuddyList:(NSString *)myJID{
    
    [PublicCURD openDataBaseSQLite];
    
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select c.jid, c.remarkName,u.nickName,u.phone,u.avatar,c.addTime from Contacts c,UserInfo u where c.jid = u.jid and u.myJID = \"%@\" and c.myJID = \"%@\"",myJID,myJID];
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
//        NSLog(@"select ok.");
//        NSLog(@"%d",SQLITE_ROW);
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            NSString *jid=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
            NSString *num = [jid stringByReplacingOccurrencesOfString:@"@ab-insurance.com" withString:@""];
            NSString *remarkName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            
            NSString *nickName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
           // NSString *phone=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            
            NSString *avatar=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            

            [arrBuddyList addObject:[NSDictionary dictionaryWithObjectsAndKeys:num,@"num",remarkName, @"name",nickName,@"nickName",avatar,@"avatar", nil]];
            [self.suggestionsDictionary addObject:num];
        }
    }else{
        [self ErrorReport:selectSqlStr];
    }
    [PublicCURD closeDataBaseSQLite];
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
        sqlite3_free(errorMsg);
    }
}


#pragma mark -UItableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (txtNum.text.length>0) {
        return [suggestionOptions count];
    }else{
        return  [arrCallRecords count];
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"buddyCell";
     if (txtNum.text.length>0) {
    InformationCell *cell = [[InformationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
     //InformationCell *cell = (InformationCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[InformationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
    }
         
   
//        NSDictionary *buddyDic = [arrBuddyList objectAtIndex:[indexPath row]];
//        NSString *jidStr = [buddyDic objectForKey:@"num"];
//        NSString *name=[buddyDic objectForKey:@"name"];
//        NSString *nickName=[buddyDic objectForKey:@"nickName"];
        for (int i=0; i<[arrBuddyList count]; i++) {
            
            if ([[suggestionOptions objectAtIndex:indexPath.row] isEqualToString: [[arrBuddyList objectAtIndex:i]objectForKey:@"num"]]) {
                
                if ([@"(null)" isEqualToString:[[arrBuddyList objectAtIndex:i]objectForKey:@"name"]]||[@"" isEqualToString:[[arrBuddyList objectAtIndex:i]objectForKey:@"name"]] || [[arrBuddyList objectAtIndex:i]objectForKey:@"name"] == nil) {
                    if ([@"(null)" isEqualToString:[[arrBuddyList objectAtIndex:i]objectForKey:@"nickName"]]||[@"" isEqualToString:[[arrBuddyList objectAtIndex:i]objectForKey:@"nickName"]] || [[arrBuddyList objectAtIndex:i]objectForKey:@"nickName"] == nil) {
                        cell.LeftText=[[arrBuddyList objectAtIndex:i]objectForKey:@"num"];
                    }else{
                        cell.LeftText=[[arrBuddyList objectAtIndex:i]objectForKey:@"nickName"];
                    }
                }else{
                    cell.LeftText=[[arrBuddyList objectAtIndex:i]objectForKey:@"name"];
                }
                 break;
            }
        }

        cell.RigitText=[suggestionOptions objectAtIndex:indexPath.row];
         return cell;
    }
    else{
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            
        }
        
        if ([[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"sendUser"] isEqualToString:MY_USER_NAME]) {
            BOOL isBuddy=NO;
            for (int i=0; i<[arrBuddyList count]; i++) {
                NSLog(@"%@-%@",[[arrBuddyList objectAtIndex:i]objectForKey:@"num"],[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"receiveUser"]);
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
        UILabel *labRigitText=[[UILabel alloc]initWithFrame:CGRectMake(0,10, 310, 20)];
        labRigitText.textColor=[UIColor lightGrayColor];
        [labRigitText setBackgroundColor:[UIColor clearColor]];
        //        labRigitText.text=@"labRigitText";
        labRigitText.font=[UIFont boldSystemFontOfSize:14];
        labRigitText.textAlignment=UITextAlignmentRight;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        NSDate *localDate = [dateFormatter dateFromString:[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"sendTime"]];
        labRigitText.text= [self stringFromDate:[self getNowDateFromatAnDate:localDate]];
        [cell addSubview:labRigitText];
        return cell;
    }
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
    ;
    if (txtNum.text.length>0) {
        InformationCell *cell = (InformationCell *)[tableView cellForRowAtIndexPath:indexPath];
        [royaDialView showNum:cell.RigitText];
    }else{
//        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        if ([[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"sendUser"] isEqualToString:MY_USER_NAME]) {
            
        [royaDialView showNum:[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"receiveUser"]];
        UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"语音通话(免费)",@"视频通话(免费)", nil];
        [actionSheet showInView:self.view.window];
        }else{
            [royaDialView showNum:[[arrCallRecords objectAtIndex:indexPath.row]objectForKey:@"sendUser"]];
            UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"语音通话(免费)",@"视频通话(免费)", nil];
            [actionSheet showInView:self.view.window];
        }
    }
}


#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //语音通话
            [royaDialView playDial];
            break;
        case 1:
            //视频通话
            [royaDialView playVideo];
            break;
        default:
            
            break;
    }
}



#pragma mark RoyaDialViewDelegate
-(void)txtNum:(NSString *)num{
    txtNum.text=num;
    NSString *curString = num;
    
     if ([self substringIsInDictionary:curString])
    {
        [tbBuddy reloadData];
    }
    if ([num isEqualToString:@""]) {
        [tbBuddy reloadData];
    }
}


#pragma mark UITextFiled Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
}



#pragma mark - Logic staff
- (BOOL) substringIsInDictionary:(NSString *)subString
{
    NSMutableArray *tmpArray = [NSMutableArray array];
    NSRange range;
    
    for (NSString *tmpString in self.suggestionsDictionary)
    {
        range=[tmpString rangeOfString:subString];
        if (range.location != NSNotFound) {
            [tmpArray addObject:tmpString];
        }
    }
    if (txtNum.text.length>0)
    {
        suggestionOptions = tmpArray;
        return YES;
    }
    return NO;
}


@end
