//
//  FriendNameViewController.m
//  anbang_ios
//
//  Created by seeko on 14-5-29.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "FriendNameViewController.h"
#import "DejalActivityView.h"
#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif
@interface FriendNameViewController ()
{
    UITextField *txtName;
    
}
@end

@implementation FriendNameViewController
@synthesize circleName,groupJID,phoneCode,phoneNum;
@synthesize tableView=_tableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendSMS) name:@"smContent" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displaySMSComposerSheet:)
												 name:@"NNC_Invitation_Friend_Circle" object:nil];
    
    //邀请
    self.title = NSLocalizedString(@"public.text.invitation",@"title");

    //邀请
    UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"public.nav.ok",@"title")  style:UIBarButtonItemStylePlain target:self action:@selector(invitationRequset)];
    [self.navigationItem setRightBarButtonItem:btnRight animated:YES];

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
    _tableView.backgroundColor = [UIColor whiteColor];
    [_tableView reloadData];
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
    return 3;
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
        //输入你绑定的邮箱
        cell.textLabel.text = NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.nameMsg",@"title");
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.frame = CGRectMake(0 , 0, 300, 50);
        cell.textLabel.numberOfLines =0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        
    }else if(indexPath.row==1){
        txtName = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, KCurrWidth, 50)];
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        [txtName setKeyboardType:UIKeyboardTypeEmailAddress];
        txtName.clearButtonMode = UITextFieldViewModeWhileEditing;
        //设置字体颜色
        txtName.textColor = [UIColor blueColor];
        txtName.font = [UIFont fontWithName:@"Helvetica" size:22.0f];
        [txtName becomeFirstResponder ];
        //昵称
        if (![_nickName isEqualToString:@""]) {
            txtName.text = _nickName;
        }else{
            txtName.placeholder=NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.name",@"title");
            
        }

        [cell addSubview:txtName];
         cell.layer.borderWidth = 0;
        
    }else if(indexPath.row==2){
        UIWebView *annotationTextView = [[UIWebView alloc] initWithFrame:CGRectMake(0 , 0, KCurrWidth, 300)];
        NSString *htmlStr = @"<font color='grayColor'><br/>注：<br/>1.你设置名称后，被短信邀请者在安装时就不用再设置名称了。<br/><br/>2. 收到你邀请短信的对方只须简单点击下载安装，不必注册、登录、加好友，就可以直接在好友列表上看到你。<br/><br/>3.对方使用通知：对方一旦开始使用，系统将即时发信息告诉你对方开机的消息，你可以即刻打免费网话给对方。</font>";
        
        [annotationTextView loadHTMLString:htmlStr baseURL:nil];
        
        [cell addSubview:annotationTextView];
       
        
    }else if(indexPath.row==3){
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        
    }else{
        
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}


//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 45;
    }else if(indexPath.row==1){
        return 50;
    }else
    {
        return 500;
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)invitationRequset{
    
    //NSLog(@"*********%d",txtName.text.length);
    
    //加载动画效果
    [DejalBezelActivityView activityViewForView:self.view];
    
    if (txtName.text.length>0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __block  UIAlertView *alert;
            dispatch_async(dispatch_get_main_queue(), ^{
                //请稍等...
//                alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.alertMsg",@"title") delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
//                [alert show];
                
                //加载动画效果
                [DejalBezelActivityView activityViewForView:self.view];
                
            });
            
            if(circleName==nil){
                
                NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/invite"];
                NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
                NSXMLElement *acc=[NSXMLElement elementWithName:@"account"];
                NSXMLElement *phone=[NSXMLElement elementWithName:@"phone" stringValue:phoneNum];
                [iq addAttributeWithName:@"type" stringValue:@"set"];
                [iq addAttributeWithName:@"id" stringValue:@"invitationNewFriend"];
                [phone addAttributeWithName:@"countryCode" stringValue:phoneCode];
                [phone addAttributeWithName:@"name" stringValue:txtName.text];
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
                
            }else{
                NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/admin"];
                NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
                NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
                NSXMLElement *members = [NSXMLElement elementWithName:@"members"];
                [iq addAttributeWithName:@"to" stringValue:GroupDomain];
                [iq addAttributeWithName:@"type" stringValue:@"set"];
                [iq addAttributeWithName:@"id" stringValue:@"ID_Invitation_Friend"];
                [circle addAttributeWithName:@"name" stringValue:circleName];
                [circle addAttributeWithName:@"jid" stringValue:groupJID];
                [circle addAttributeWithName:@"remove" stringValue:@"false"];
                NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
                NSString *phone = [phoneNum substringToIndex:1];
                if ([phone isEqualToString:@"+"]) {
                    [member addAttributeWithName:@"phone" stringValue:phoneNum];
                }else{
                    NSString *phoneCodeNum=[NSString stringWithFormat:@"+%@%@",phoneCode,phoneNum];
                    [member addAttributeWithName:@"phone" stringValue:phoneCodeNum];
                }
                [members addChild:member];
                
                [iq addChild:queryElement];
                [queryElement addChild:circle];
                [circle addChild:members];
                
                // NSLog(@"组装后的xml:%@",iq);
                if ([[XMPPServer xmppStream] isConnected]) {
                    [[XMPPServer xmppStream] sendElement:iq];
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //网络已断开
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"public.alert.networkConnectionFailure",@"message") delegate:nil cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
                        [alertView show];
                        //[alertView release];
                    });
                }
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert dismissWithClickedButtonIndex:0 animated:YES];
                //[alert release];
            });
            
        });
    }else{
        //输入好友名字
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.alertMsg2",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
        [alert show];
        //[alert release];
    }
}


-(void)displaySMSComposerSheet:(NSNotification *) noti
{
    
    NSString *invitationURL = nil;
    invitationURL = [noti object];
    if (invitationURL==nil) {
        //邀请成功
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.alertMsg3",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
        alert.tag=1040;
        [alert show];
        //[alert release];
    }else{
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
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


//短信
-(void)sendSMS{

    [DejalBezelActivityView removeViewAnimated:YES];
    
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    NSArray *array = [NSArray arrayWithObject:phoneNum];
    picker.recipients = array;
    picker.body = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"smContent"]];
    //    [self presentModalViewController:picker animated:NO];
    [self presentViewController:picker animated:NO completion:nil];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"smContent"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
    
}

#pragma mark -短信
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    switch (result)
    {
            //            int result=0;
        case MessageComposeResultCancelled:
            //            LOG_EXPR(@"Result: SMS sending canceled");
            //            NSLog(@"发送取消");
            //            result=1;
            break;
        case MessageComposeResultSent:
            //            LOG_EXPR(@"Result: SMS sent");
            //            NSLog(@"发送成功");
            //            result=2;
            break;
        case MessageComposeResultFailed:
            //            [UIAlertView quickAlertWithTitle:@"短信发送失败" messageTitle:nil dismissTitle:@"关闭"];
            //            NSLog(@"发送失败");
            //            result=3;
            break;
        default:
            //            LOG_EXPR(@"Result: SMS not sent");
            //            NSLog(@"其它");
            break;
    }
	[self dismissViewControllerAnimated:YES completion:^{
        if (result==MessageComposeResultCancelled) {
            //取消发送
           // UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.alertMsg4",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
           // alert.tag=1041;
           // [alert show];
            //[alert release];
        }else if (result==MessageComposeResultSent){
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"smContent" object:nil];
            //发送成功
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.alertMsg5",@"message")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title")  otherButtonTitles:nil, nil];
            alert.tag=1042;
            [alert show];
            //[alert release];
        }else if (result==MessageComposeResultFailed){
            //发送失败
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"contacts.mobilePhoneNumberToInvite.alertMsg6",@"message")  delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title")  otherButtonTitles:nil, nil];
            alert.tag=1043;
            [alert show];
            //[alert release];
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

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NNC_Invitation_Friend_Circle" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"smContent" object:nil];
    
    //[txtName release];
    //[super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
    [DejalBezelActivityView removeViewAnimated:YES];
    
}
@end
