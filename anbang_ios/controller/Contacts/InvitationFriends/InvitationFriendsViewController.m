//
//  InvitationFriendsViewController.m
//  anbang_ios
//
//  Created by seeko on 14-4-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "InvitationFriendsViewController.h"
#import "FKRHeaderSearchBarTableViewController.h"
#import "CHAppDelegate.h"
#import "ChooseCircleViewController.h"
#import "FriendNameViewController.h"
#import "AddressBookViewController.h"
@interface InvitationFriendsViewController ()
{
    UIView *codeView;
    UIButton *btnCode;
    UIButton *btnCountries;
    UITextField *txtName;
    UITextField *txtPhoneNum;
    UILabel *circleName;
    
    NSString *strGroupJID;
}
@end

@implementation InvitationFriendsViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressbookPhoneNum:) name:@"NNC_AddressBook_PhoneNum" object:nil];

    [self ui];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
   // appDelegate.tabBarBG.hidden=YES;
}
-(void)ui{
    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(invitationRequset)];
    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];
    
    codeView=[[UIView alloc]initWithFrame:CGRectMake(20, Both_Bar_Height+20, 280, 30)];
    [codeView setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:codeView];
    //********************************************************************
    btnCode=[UIButton buttonWithType:UIButtonTypeCustom];
    btnCode.frame=CGRectMake(1, 1, 80, 28);
    btnCode.backgroundColor=[UIColor whiteColor];
    [btnCode addTarget:self action:@selector(clickCodeButton) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(arraycode:) name:@"arraycode" object:nil];
    [btnCode setTitle:[NSString stringWithFormat:@"86"]forState:UIControlStateNormal];
    [btnCode setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1] forState:UIControlStateNormal];
    [codeView addSubview:btnCode];
    btnCountries=[UIButton buttonWithType:UIButtonTypeCustom];
    btnCountries.frame=CGRectMake(82, 1, 197, 28);
    btnCountries.backgroundColor=[UIColor whiteColor];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(arrayname:) name:@"arrayname" object:nil];
    [btnCountries setTitle:@"中国" forState:UIControlStateNormal];
    [btnCountries setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1] forState:UIControlStateNormal];
    [btnCountries addTarget:self action:@selector(clickCodeButton) forControlEvents:UIControlEventTouchUpInside];
    [codeView addSubview:btnCountries];

    txtPhoneNum=[[UITextField alloc]initWithFrame:CGRectMake(20, Both_Bar_Height+65, 280, 35)];
    txtPhoneNum.borderStyle=UITextBorderStyleRoundedRect;
    [txtPhoneNum setKeyboardType:UIKeyboardTypeNumberPad];
    [txtPhoneNum becomeFirstResponder];
    txtPhoneNum.placeholder=@"输入手机号码";
    [self.view addSubview:txtPhoneNum];
    //通讯录按钮
    UIButton *btnABImage=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnABImage addTarget:self action:@selector(chooseAddressBook) forControlEvents:UIControlEventTouchUpInside];
    btnABImage.frame=CGRectMake(250, Both_Bar_Height+60, 40, 45);
    [btnABImage setBackgroundImage:[UIImage imageNamed:@"dial_homepage.png"] forState:UIControlStateNormal];
    [self.view addSubview:btnABImage];
    //选择圈子
    UIButton *btnCircle=[UIButton buttonWithType:UIButtonTypeCustom];
    btnCircle.frame=CGRectMake(20, Both_Bar_Height+120, 280, 35);
    [btnCircle setBackgroundImage:[UIImage imageNamed:@"v2_btn_more_pressed.9.png"] forState:UIControlStateNormal];
    btnCircle.contentHorizontalAlignment=1;
    [btnCircle setTitle:@"选择圈子" forState:UIControlStateNormal];
    [btnCircle setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1] forState:UIControlStateNormal];
    [btnCircle setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.5] forState:UIControlStateHighlighted];
    [btnCircle addTarget:self action:@selector(joinCircle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCircle];
    
    circleName=[[UILabel alloc]initWithFrame:CGRectMake(150, 0, 100, 35)];
    //    [circleName setBackgroundColor:[UIColor redColor]];
    circleName.text=@"(直接加好友)";
    [circleName setTextColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1]];
    //    [btnCircle.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    //    [btnCircle.layer setBorderWidth:1.0]; //边框宽度
    [btnCircle addSubview:circleName];
    UIImageView *image=[[UIImageView alloc]initWithFrame:CGRectMake(275, 10, 5, 15)];
    image.image=[UIImage imageNamed:@"tm_profile_popup_ico_m.png"];
    [btnCircle addSubview:image];
}
//跳转通讯录
-(void)chooseAddressBook{
    NSLog(@"通讯录");
    AddressBookViewController *addressBookView=[[AddressBookViewController alloc]init];
    [self.navigationController pushViewController:addressBookView animated:YES];
//    [addressBookView release];
}
-(void)addressbookPhoneNum:(NSNotification *)phoneNum{
    txtPhoneNum.text=[NSString stringWithFormat:@"%@",[phoneNum object]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//填写手机号加入圈子
-(void)joinCircle{
//    NSLog(@"加入圈子");
    ChooseCircleViewController *chooseCircleView=[[ChooseCircleViewController alloc]init];
    chooseCircleView.delegate=self;
    [self.navigationController pushViewController:chooseCircleView animated:YES];
}



#pragma mark-ChooseCircleViewDelegate
-(void)setCellValue:(NSString *)string groundJID:(NSString *)groundJID{
    circleName.text=string;
    strGroupJID=groundJID;
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
            friendName.circleName=circleName.text;
            friendName.groupJID=strGroupJID;
            friendName.phoneCode=btnCode.titleLabel.text;
            friendName.phoneNum=txtPhoneNum.text;
            [self.navigationController pushViewController:friendName animated:YES];
        }else{
            if ([self isMobileNumber:txtPhoneNum.text]) {
                FriendNameViewController *friendName=[[FriendNameViewController alloc]init];
                friendName.circleName=circleName.text;
                friendName.groupJID=strGroupJID;
                friendName.phoneCode=btnCode.titleLabel.text;
                friendName.phoneNum=txtPhoneNum.text;
                [self.navigationController pushViewController:friendName animated:YES];
            }else{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示:" message:@"手机号码输入错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
//                [alert release];
            }
        }
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示:" message:@"请输入手机号码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
//        [alert release];
    }
   
}
//手机号格式验证
- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


//跳转国际区号表
-(void)clickCodeButton{
    FKRHeaderSearchBarTableViewController *tableViewController = [[FKRHeaderSearchBarTableViewController alloc] initWithSectionIndexes:YES];
    [self.navigationController pushViewController:tableViewController animated:YES];
}

-(IBAction)backgroundTop:(id)sender{
//    [txtPhoneNum resignFirstResponder];
//    [txtName resignFirstResponder];
}

#pragma mark - NSNotificationCenter
- (void)arraycode:(NSNotification *)message{
    [btnCode setTitle:[NSString stringWithFormat:@"%@",[message object]]forState:UIControlStateNormal];
    [[NSNotificationCenter
      defaultCenter] removeObserver:self name:@"back"
     
     object:nil];
    
}
- (void)arrayname:(NSNotification *)message{
    [btnCountries setTitle:[message object] forState:UIControlStateNormal];
    [[NSNotificationCenter
      defaultCenter] removeObserver:self name:@"back"
     
     object:nil];
}

-(void)dealloc{
//    NSLog(@"%d%d%d%d%d",[btnCode retainCount],[btnCountries retainCount],[circleName retainCount],[txtPhoneNum retainCount],[codeView retainCount]);
}
@end
