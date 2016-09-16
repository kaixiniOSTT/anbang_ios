//
//  SettingNameController.m
//  anbang_ios
//
//  Created by seeko on 14-3-20.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "SettingNameController.h"
#import "InformationViewController.h"
#import "Utility.h"
#import "AIBaseViewController.h"
#import "UserInfo.h"
#import "DejalActivityView.h"

@interface SettingNameController ()

@end

@implementation SettingNameController
@synthesize tableView=_tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(success) name:@"setName_ok" object:nil];
    }
    return self;
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"setName_ok" object:nil];
    
    
}
- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=NSLocalizedString(@"personalInformation.nickName.title",@"title");
    self.view.backgroundColor = Controller_View_Color;
    //版本判断
    int height;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        height=64;
    }else{
        height=0;
    }
    
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"target:self action:@selector(pop)]];
    
    UIBarButtonItem *btnInput=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"public.nvaButton.save",@"action") style:UIBarButtonItemStylePlain target:self action:@selector(clickRightButton)];
    [self.navigationItem setRightBarButtonItem:btnInput animated:YES];
    UILabel *label1=[[UILabel alloc]initWithFrame:CGRectMake(0, height+10, KCurrWidth, 31)];
    [label1 setBackgroundColor:[UIColor blackColor]];
    //[self.view addSubview:label1];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, height+10, KCurrWidth, 30)];
    label.text = NSLocalizedString(@"personalInformation.nickName.promptMessage",@"title");
    [label setBackgroundColor:[UIColor whiteColor]];
    //[self.view addSubview:label];
    
    
    textFild=[[UITextField alloc]initWithFrame:CGRectMake(20, 20, KCurrWidth - 40, INPUT_TEXT_FIELD_HEIGHT)];
    textFild.borderStyle = UITextBorderStyleRoundedRect;
    NSString *myName = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
    if ([StrUtility isBlankString:myName]) {
        myName = MY_USER_NAME;
    }
    textFild.text=myName;
    textFild.font = kText_Font;
    textFild.backgroundColor = AB_White_Color;
    textFild.textColor = AB_Gray_Color;
    textFild.textAlignment = NSTextAlignmentLeft;
    textFild.layer.cornerRadius = 6.0;
    textFild.layer.borderWidth = 0.5;
    textFild.layer.borderColor = Normal_Border_Color.CGColor;
    textFild.leftViewMode = UITextFieldViewModeAlways;
    textFild.delegate=self;
    
    textFild.placeholder= @"我的昵称";
    [textFild becomeFirstResponder];
    
    [self.view addSubview:textFild];
    
    
    
    //[_tableView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [_tableView setSeparatorInset:(UIEdgeInsetsMake(0, 0, 0, 0))];
    }
    
    //删除多余线条
    [Utility setExtraCellLineHidden:_tableView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row==0) {
        cell.textLabel.text = NSLocalizedString(@"personalInformation.nickName.promptMessage",@"title");
        cell.textLabel.numberOfLines = 0;
    }else{
        textFild = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, KCurrWidth-40, 50)];
        
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        textFild.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textFild setPlaceholder:NSLocalizedString(@"personalInformation.nickName.nickName",@"message")];
        //设置字体颜色
        //text.textColor = [UIColor blueColor];
        [textFild becomeFirstResponder ];
        [cell addSubview:textFild];
    }
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 100;
    }else{
        return 55;
    }
}



//提交－－－上传服务器
-(void)clickRightButton{
    if (textFild.text.length>0) {
        [self sendIQsetingName];
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"personalInformation.nickName.pleaseEnterANickname",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action")  otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

-(void)success{
    [[NSUserDefaults standardUserDefaults] setObject:textFild.text forKey:@"name"];
    [[NSUserDefaults standardUserDefaults] synchronize];//保存
    
    //    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"personalInformation.nickName.modifySuccess",@"message") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles: nil];
    //    [alertView show];
    
    UserInfo *userInfo = [UserInfo loadArchive];
    userInfo.nickName = textFild.text;
    [userInfo save];
    
    [self loadViewHide];
    [self.navigationController popViewControllerAnimated:YES];
    
    JLTipsView *tipView = [[JLTipsView alloc] initWithTip:NSLocalizedString(@"personalInformation.nickName.modifySuccess",@"message") ];
    [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES autoRelease:YES];
    
}

-(void)sendIQsetingName{
    /*
     <iq type=”set”>
     <query xmlns=”http://www.nihualao.com/xmpp/userinfo“ >
     <name></name><!--设置名称-->
     <avatar>tfs ID</avatar><!--设置头像-->
     </query>
     </iq>  */
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"NSUD_language"] isEqualToString:@"en"]) {
        
        if (textFild.text.length>20) {
            
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"personalInformation.nickName.max",@"message") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles: nil];
            [alertView show];
            
            return;
        }
        
    }else{
        
        if (textFild.text.length>12) {
            
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"personalInformation.nickName.max",@"message") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles: nil];
            [alertView show];
            
            return;
            
        }
    }
    
    [self loadViewShow];
    
    NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    NSXMLElement *name=[NSXMLElement elementWithName:@"name" stringValue:textFild.text];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"setName"];
    [queryElement addChild:name];
    [iq addChild:queryElement];
    [[XMPPServer xmppStream] sendElement:iq];
}

//当用户按下return键或者按回车键，keyboard消失
//-(BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//    return YES;
//}
-(IBAction)backgroundTop:(id)sender{
    //    [textFild resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillDisappear:(BOOL)animated {
    
}


//请求获取个人信息列表
-(void)sendIQInformationList{
    /*
     <iq type=”get”>
     <query xmlns=”http://www.icircall.com/xmpp/userinfo“ >
     <user jid=””/> </query>
     </iq>
     */
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *userJid=[NSXMLElement elementWithName:@"user"];
    [userJid addAttributeWithName:@"jid" stringValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"jid"]];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"personalInformation"];
    [queryElement addChild:userJid];
    [iq addChild:queryElement];
    [[XMPPServer xmppStream] sendElement:iq];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadViewShow {
    
    [self.view endEditing:YES];
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)loadViewHide {
    
    [self.view endEditing:NO];
    [DejalBezelActivityView removeViewAnimated:YES];
}

@end
