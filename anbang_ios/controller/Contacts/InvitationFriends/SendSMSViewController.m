//
//  SendSMSViewController.m
//  anbang_ios
//
//  Created by seeko on 14-4-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "SendSMSViewController.h"
#import "ChooseCircleViewController.h"
@interface SendSMSViewController ()
{
    UILabel *labcircleName;
    UILabel *labNum;
    UILabel *labName;
    NSString *strGroupJID;
}
@property(nonatomic,copy) NSString *circleName;
@end

@implementation SendSMSViewController
@synthesize name,phoneNum;
@synthesize circleName;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendSMS) name:@"smContent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displaySMSComposerSheet:)
                                                 name:@"NNC_Invitation_Friend_Circle" object:nil];
    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:@"邀请" style:UIBarButtonItemStylePlain target:self action:@selector(invitationNew)];
    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];
    
    int height;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        height=64;
    }else{
        height=0;
    }
    circleName=[[NSString alloc]init];
    labName=[[UILabel alloc]initWithFrame:CGRectMake(20, height+20, 300, 20)];
    labName.textColor=[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1];
    if (name.length<1) {
        labName.text=phoneNum;
    }else{
        labName.text=name;
    }
    [self.view addSubview:labName];
    
    UIButton *btnPhoneNum=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnPhoneNum setBackgroundImage:[UIImage imageNamed:@"v2_btn_more_pressed.9.png"] forState:UIControlStateNormal];
    [btnPhoneNum setBackgroundImage:[UIImage imageNamed:@"v2_btn_more_pressed.9.png"] forState:UIControlStateHighlighted];
    btnPhoneNum.frame=CGRectMake(10, height+40, 300, 35);
    btnPhoneNum.contentHorizontalAlignment=1;
    [btnPhoneNum setTitle:@"手机号:" forState:UIControlStateNormal];
    [btnPhoneNum setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1] forState:UIControlStateNormal];
    //    [btnPhoneNum setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.5] forState:UIControlStateHighlighted];
    //    [btnPhoneNum.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    //    [btnPhoneNum.layer setBorderWidth:1.0]; //边框宽度
    [self.view addSubview:btnPhoneNum];
    labNum=[[UILabel alloc]initWithFrame:CGRectMake(120, 0, 180, 35)];
    labNum.text=phoneNum;
    [labNum setTextColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1]];
    
    [btnPhoneNum addSubview:labNum];
    
    UIButton *btnCircle=[UIButton buttonWithType:UIButtonTypeCustom];
    btnCircle.frame=CGRectMake(10, height+100, 300, 35);
    [btnCircle setBackgroundImage:[UIImage imageNamed:@"v2_btn_more_pressed.9.png"] forState:UIControlStateNormal];
    btnCircle.contentHorizontalAlignment=1;
    [btnCircle setTitle:@"选择圈子" forState:UIControlStateNormal];
    [btnCircle setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1] forState:UIControlStateNormal];
    [btnCircle setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.5] forState:UIControlStateHighlighted];
    [btnCircle addTarget:self action:@selector(joinCircle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCircle];
    labcircleName=[[UILabel alloc]initWithFrame:CGRectMake(150, 0, 100, 35)];
    //    [circleName setBackgroundColor:[UIColor redColor]];
    labcircleName.text=@"(直接加好友)";
    [labcircleName setTextColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1]];
    //    [btnCircle.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    //    [btnCircle.layer setBorderWidth:1.0]; //边框宽度
    [btnCircle addSubview:labcircleName];
    UIImageView *image=[[UIImageView alloc]initWithFrame:CGRectMake(275, 10, 5, 15)];
    image.image=[UIImage imageNamed:@"tm_profile_popup_ico_m.png"];
    
    [btnCircle addSubview:image];
}
-(void)viewWillAppear:(BOOL)animated{
    //    if (circleName.length>0) {
    
    //    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//加入圈子
-(void)joinCircle{
    ChooseCircleViewController *chooseCirceleView=[[ChooseCircleViewController alloc]init];
    chooseCirceleView.delegate=self;
    [self.navigationController pushViewController:chooseCirceleView animated:YES];
}
//邀请加入我们:注册
-(void)invitationNew{
    /*<iq type=”set”>
     <query xmlns=”http://www.nihualao.com/xmpp/invite”>
     ￼￼殊-->
     <account>
     <!--直接通过手机号邀请开户-->
     <phone countryCode=”国家码”name=”用户名称”>手机号</phone> <!--通过 JID 重复邀请-->
     <jid></jid>
     <!--如果是邀请某个圈子内的成员,需指定圈子的 JID,因为短信内容特
     <circle>圈子的 JID</circle> </account>
     </query> </iq>*/
    if([labcircleName.text isEqualToString:@"(直接加好友)"]){
        
        NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/invite"];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        NSXMLElement *acc=[NSXMLElement elementWithName:@"account"];
        NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:labNum.text];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        [iq addAttributeWithName:@"id" stringValue:@"invitationNewFriend"];
        [phone addAttributeWithName:@"countryCode" stringValue:@"+86"];
        [phone addAttributeWithName:@"name" stringValue:labName.text];
        [acc addChild:phone];
        [queryElement addChild:acc];
        [iq addChild:queryElement];
        NSLog(@"%@",iq);
        [[XMPPServer xmppStream] sendElement:iq];
    }else{
        NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/admin"];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
        NSXMLElement *members = [NSXMLElement elementWithName:@"members"];
        [iq addAttributeWithName:@"to" stringValue:GroupDomain];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        [iq addAttributeWithName:@"id" stringValue:@"ID_Invitation_Friend"];
        [circle addAttributeWithName:@"name" stringValue:labcircleName.text];
        [circle addAttributeWithName:@"jid" stringValue:strGroupJID];
        [circle addAttributeWithName:@"remove" stringValue:@"false"];
        NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
        [member addAttributeWithName:@"phone" stringValue:phoneNum];
        [members addChild:member];
        
        [iq addChild:queryElement];
        [queryElement addChild:circle];
        [circle addChild:members];
        
        NSLog(@"组装后的xml:%@",iq);
        [[XMPPServer xmppStream] sendElement:iq];
        
    }
}
//短信
-(void)sendSMS{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"smContent" object:nil];
    
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    NSArray *array = [NSArray arrayWithObject:labNum.text];
    picker.recipients = array;
    picker.body = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"smContent"]];
    //    [self presentModalViewController:picker animated:NO];
    [self presentViewController:picker animated:NO completion:nil];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"smContent"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
}
-(void)displaySMSComposerSheet:(NSNotification *) noti
{
    
    NSString *invitationURL = nil;
    invitationURL = [noti object];
    if (invitationURL==nil) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示" message:@"邀请成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.tag=1040;
        [alert show];
        
    }else{
        [[NSNotificationCenter defaultCenter]removeObserver:self name:@"smContent" object:nil];
        
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        NSArray *array = [NSArray arrayWithObject:phoneNum];
        picker.recipients = array;
        picker.body = [NSString stringWithFormat:@"%@",invitationURL];
        //    [self presentModalViewController:picker animated:NO];
        //    [self presentViewController:picker animated:NO];
        //    [self presentModalViewController:picker animated:NO];
        [self presentViewController:picker animated:NO completion:^(){}];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"smContent"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}
#pragma mark -短信
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    
    switch (result)
    {
        case MessageComposeResultCancelled:
            //            LOG_EXPR(@"Result: SMS sending canceled");
            //            NSLog(@"发送取消");
            break;
        case MessageComposeResultSent:
            //            LOG_EXPR(@"Result: SMS sent");
            //            NSLog(@"发送成功");
            break;
        case MessageComposeResultFailed:
            //            [UIAlertView quickAlertWithTitle:@"短信发送失败" messageTitle:nil dismissTitle:@"关闭"];
            //            NSLog(@"发送失败");
            break;
        default:
            //            LOG_EXPR(@"Result: SMS not sent");
            //            NSLog(@"其它");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if (result==MessageComposeResultCancelled) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示" message:@"取消发送" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag=1041;
            [alert show];
        }else if (result==MessageComposeResultSent){
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示" message:@"发送成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag=1042;
            [alert show];
        }else if (result==MessageComposeResultFailed){
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示" message:@"发送失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag=1043;
            [alert show];
        }
    }];
}
#pragma mark -UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1040) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    }else if (alertView.tag==1041) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    }else if (alertView.tag==1042) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    }else if (alertView.tag==1043) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    }
}
#pragma mark ChooseCircleViewDelegate
-(void)setCellValue:(NSString *)string groundJID:(NSString *)groundJID{
    circleName=[NSString stringWithString:string];
    labcircleName.text=circleName;
    strGroupJID=groundJID;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NNC_Invitation_Friend_Circle" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"smContent" object:nil];
}
@end
