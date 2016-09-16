//
//  InvitationFriendsViewControllerNew.m
//  anbang_ios
//
//  Created by silenceSky  on 14-8-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "InvitationFriendsViewControllerNew.h"
#import "FKRHeaderSearchBarTableViewController.h"
#import "AddressBookViewController.h"
#import "ChooseCircleViewController.h"
#import "FriendNameViewController.h"
#import "Utility.h"

@interface InvitationFriendsViewControllerNew (){
    
    UITextField *txtPhoneNum;
    NSString *strGroupJID;
    UILabel *groupLabel ;
}

@end

@implementation InvitationFriendsViewControllerNew
@synthesize tableView=_tableView;
@synthesize countryCode=_countryCode;
@synthesize countryName=_countryName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Country_Code" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Country_Name" object:nil];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressbookPhoneNum:) name:@"NNC_AddressBook_PhoneNum" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countryName:) name:@"NNC_Country_Name" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countryCode:) name:@"NNC_Country_Code" object:nil];
    
    // Do any additional setup after loading the view from its nib.
    _tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollsToTop = YES;
    [self.view addSubview:_tableView];
    //[_tableView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
    [self setExtraCellLineHidden:_tableView];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [_tableView setSeparatorInset:(UIEdgeInsetsMake(0, 0, 0, 0))];
    }
    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.nextStep",@"action") style:UIBarButtonItemStylePlain target:self action:@selector(invitationRequset)];
    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];
    
    _countryCode = @"86";
    _countryName = NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.china",@"message");
    
    
    txtPhoneNum = [[UITextField alloc]initWithFrame:CGRectMake(20, 0, 280, 50)];
    
    //[_tableView reloadData];
    
    groupLabel = [[UILabel alloc]initWithFrame:CGRectMake(KCurrWidth-220, 0, 200, 55)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ([cell viewWithTag:10001]) {
        [[cell viewWithTag:10001] removeFromSuperview];
    }
    
    if (indexPath.row==0) {
        
        cell.textLabel.text = NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.tableViewTitle",@"title");
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.frame = CGRectMake(0 , 0, 300, 50);
        cell.textLabel.numberOfLines =0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        
        
        
    }else if(indexPath.row==1){
        //NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.countryCode",@"action");
        cell.textLabel.text=[NSString stringWithFormat:@"%@%@",@"+",_countryCode];
        UILabel *countryLabel = [[UILabel alloc]initWithFrame:CGRectMake(KCurrWidth-220, 0, 200, 55)];
        countryLabel.text= _countryName;
        countryLabel.textAlignment = NSTextAlignmentCenter;
        countryLabel.tag= 10001;
        [cell addSubview:countryLabel];
        [[NSUserDefaults standardUserDefaults]setObject:_countryCode forKey:@"countryCode"];
        //        cell.detailTextLabel.text = @"国家和地区区号";
        //        cell.detailTextLabel.textColor = [UIColor blackColor];
        //        cell.detailTextLabel.frame = CGRectMake(KCurrWidth-150, 5, 150, cell.frame.size.height);
        //        cell.detailTextLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
    }else if(indexPath.row==2){
        if (groupLabel.text==nil) {
            cell.textLabel.text=NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.selectCircle",@"action");
        }else{
            cell.textLabel.text= nil;
        }
        
        //groupLabel.text= [NSString stringWithFormat:@"+%@ %@",_countryCode,_countryName];
        groupLabel.textAlignment = NSTextAlignmentCenter;
        groupLabel.tag= 10001;
        [cell addSubview:groupLabel];
        [[NSUserDefaults standardUserDefaults]setObject:_countryCode forKey:@"countryCode"];
        //        cell.detailTextLabel.text = @"国家和地区区号";
        //        cell.detailTextLabel.textColor = [UIColor blackColor];
        //        cell.detailTextLabel.frame = CGRectMake(KCurrWidth-150, 5, 150, cell.frame.size.height);
        //        cell.detailTextLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
    }else if(indexPath.row==3){
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        [txtPhoneNum setKeyboardType:UIKeyboardTypeNumberPad];
        txtPhoneNum.clearButtonMode = UITextFieldViewModeWhileEditing;
        [txtPhoneNum setPlaceholder:NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.mobilePhoneNumber",@"message")];
        //设置字体颜色
        txtPhoneNum.textColor = [UIColor blueColor];
        txtPhoneNum.font = [UIFont fontWithName:@"Helvetica" size:22.0f];
        [txtPhoneNum becomeFirstResponder ];
        
        //通讯录按钮
        UIButton *btnABImage=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnABImage addTarget:self action:@selector(chooseAddressBook) forControlEvents:UIControlEventTouchUpInside];
        btnABImage.frame=CGRectMake(KCurrWidth-50, 0, 40, 45);
        [btnABImage setBackgroundImage:[UIImage imageNamed:@"dial_homepage.png"] forState:UIControlStateNormal];
        [cell addSubview:txtPhoneNum];
        [cell addSubview:btnABImage];
        cell.layer.borderWidth = 0;
        
    }else if(indexPath.row==4){
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        
    }else{
        
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSUInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    if (section==0 && row==1) {
        [self clickCodeButton];
    }else if (section==0 && row==2) {
        [self joinCircle];
    }
}


//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 30;
    }else if (indexPath.row==3) {
        return 40;
    }else if(indexPath.row==4){
        return 40;
    }else{
        return 50;
    }
}


//跳转国际手机区号
-(void)clickCodeButton{
    FKRHeaderSearchBarTableViewController *tableViewController = [[FKRHeaderSearchBarTableViewController alloc] initWithSectionIndexes:YES];
    [self.navigationController pushViewController:tableViewController animated:YES];
}


//跳转通讯录
-(void)chooseAddressBook{
    NSLog(@"通讯录");
    AddressBookViewController *addressBookView=[[AddressBookViewController alloc]init];
    [self.navigationController pushViewController:addressBookView animated:YES];
}


//填写手机号加入圈子
-(void)joinCircle{
    //    NSLog(@"加入圈子");
    ChooseCircleViewController *chooseCircleView=[[ChooseCircleViewController alloc]init];
    chooseCircleView.delegate=self;
    [self.navigationController pushViewController:chooseCircleView animated:YES];
}


-(void)addressbookPhoneNum:(NSNotification *)phoneNum{
    txtPhoneNum.text=[NSString stringWithFormat:@"%@",[phoneNum object]];
}

#pragma mark-ChooseCircleViewDelegate
-(void)setCellValue:(NSString *)string groundJID:(NSString *)groundJID{
    groupLabel.text=string;
    strGroupJID= groundJID;
    [_tableView reloadData];
}



//通知调用方法
- (void)countryCode:(NSNotification *)message{
    _countryCode= [message object];
    [_tableView reloadData];
}
- (void)countryName:(NSNotification *)message{
    _countryName= [message object];
    [_tableView reloadData];
}

/*
 <iq type=”set”>
 <query xmlns=”http://www.nihualao.com/xmpp/invite”>
 ￼￼殊-->
 <account>
 <!--直接通过手机号邀请开户-->
 <phone countryCode=”国家码”name=”用户名称”>手机号</phone> <!--通过 JID 重复邀请-->
 <jid></jid>
 <!--如果是邀请某个圈子内的成员,需指定圈子的 JID,因为短信内容特
 <circle>圈子的 JID</circle> </account>
 </query> </iq>
 */
//邀请请求
-(void)invitationRequset{
    //    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/invite"];
    //    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    //    NSXMLElement *acc=[NSXMLElement elementWithName:@"account"];
    //    NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:txtPhoneNum.text];
    //    [iq addAttributeWithName:@"type" stringValue:@"set"];
    //    [iq addAttributeWithName:@"id" stringValue:@"invitationNewFriend"];
    //    [phone addAttributeWithName:@"countryCode" stringValue:btnCode.titleLabel.text];
    //    [phone addAttributeWithName:@"name" stringValue:txtName.text];
    //    if(![circleName.text isEqualToString:@"(直接加好友)"]){
    //        NSXMLElement *circle=[NSXMLElement elementWithName:@"circle" stringValue:strGroupJID];
    //        [acc addChild:circle];
    //    }
    //    [acc addChild:phone];
    //    [queryElement addChild:acc];
    //    [iq addChild:queryElement];
    //    NSLog(@"组装后的xml:%@",iq);
    //    [[XMPPServer xmppStream] sendElement:iq];
    //    [self invitationNew];
    
    
    if (txtPhoneNum.text!=nil && ![txtPhoneNum.text isEqualToString:@""]) {
        NSString *phone=[txtPhoneNum.text substringToIndex:1];
        if ([phone isEqualToString:@"+"]) {
            FriendNameViewController *friendName=[[FriendNameViewController alloc]init];
            friendName.circleName=groupLabel.text;
            friendName.groupJID=strGroupJID;
            friendName.phoneCode=_countryCode;
            friendName.phoneNum=txtPhoneNum.text;
            [self.navigationController pushViewController:friendName animated:YES];
        }else{
            //if ([Utility isMobileNumber:txtPhoneNum.text]) {
            FriendNameViewController *friendName=[[FriendNameViewController alloc]init];
            friendName.circleName=groupLabel.text;
            friendName.groupJID=strGroupJID;
            friendName.phoneCode=_countryCode;
            friendName.phoneNum=txtPhoneNum.text;
            [self.navigationController pushViewController:friendName animated:YES];
            //            }else{
            //                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.mobilePhoneNumberInputErrors",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action")  otherButtonTitles:nil, nil];
            //                [alert show];
            //                //                [alert release];
            //            }
        }
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.enterPhoneNumber",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
        [alert show];
        //        [alert release];
    }
    
}



@end
