//
//  GroupDetailUpdateGroupNameVC.m
//  anbang_ios
//
//  Created by yangsai on 15/3/30.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "GroupDetailUpdateGroupNameVC.h"
#import "MBProgressHUD.h"
#import "ChatBuddyCRUD.h"
#import "BBTextField.h"

@interface GroupDetailUpdateGroupNameVC ()

@property (nonatomic,strong)BBTextField* groupNameTF;
@property (nonatomic, strong)MBProgressHUD* hub;
@end

@implementation GroupDetailUpdateGroupNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavigationItem];
    [self setContentView];
    _hub = [[MBProgressHUD alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    _hub.labelText = @"正在更新,请稍等!";
    _hub.dimBackground = YES;
    self.view.backgroundColor = UIColorFromRGB(0xf6f2ed);
}

- (void)pop
{
    [self.navigationController popViewControllerAnimated:YES];
}
    
- (void)setupNavigationItem
{
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"对话"
                                                                                   target:self
                                                                                   action:@selector(pop)]];

    self.navigationItem.title = @"群聊名称";

    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(updateNameMethod)], flix];
    
}

- (void)setContentView{
    self.view.backgroundColor = [UIColor whiteColor];
    _groupNameTF = [[BBTextField alloc]initWithFrame:CGRectMake(15, 15, self.view.bounds.size.width - 30, 45)];
    _groupNameTF.text = [StrUtility isBlankString:_groupName] ? @"" : _groupName;
    _groupNameTF.backgroundColor = AB_White_Color;
    _groupNameTF.font = [UIFont systemFontOfSize:15];
   // _groupNameTF.placeholder = @"输入群聊名称";
    [_groupNameTF setCustomPlaceholder:@"输入群聊名称"];
    _groupNameTF.textColor = AB_Gray_Color;
    _groupNameTF.layer.cornerRadius = 3.0;
    _groupNameTF.layer.borderWidth = 0.5;
    _groupNameTF.layer.borderColor = Normal_Border_Color.CGColor;
    [self.view addSubview:_groupNameTF];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateNameMethod{
    [_groupNameTF resignFirstResponder];
   
    _groupName =  [_groupNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([StrUtility isBlankString:_groupName]) {
        //圈子名称不能为空
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"circleUpdName.nameNotEmpty",@"message") delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        // optional - add more buttons:
        [alert addButtonWithTitle:NSLocalizedString(@"public.alert.ok",@"message")];
        [alert show];
        return;
        
    }
    if ( _groupName.length > 40  ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"circleUpdName.tooLong",@"title") delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        // optional - add more buttons:
        [alert addButtonWithTitle:NSLocalizedString(@"public.button.ok",@"title")];
        [alert show];
        return;
    }
 
    NSString *regex = @"^[\\w-,、，.。·:|~`！!\\?？]{1,40}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![predicate evaluateWithObject:_groupName]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"circleUpdName.invalid",@"title") delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        // optional - add more buttons:
        [alert addButtonWithTitle:NSLocalizedString(@"public.button.ok",@"title")];
        [alert show];
        return;
    }
    
     [_hub show:YES];
    /*
     <iq id="1DDsY-263" to="circle.ab-insurance.com" type="set"><query xmlns="http://www.nihualao.com/xmpp/circle/admin"><circle jid="10005@circle.ab-insurance.com" name="要是e"/></query></iq>
     */
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/admin"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
    
    [iq addAttributeWithName:@"id" stringValue:IQID_Group_Upd_Name];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:GroupDomain];
    [circle addAttributeWithName:@"jid" stringValue:_groupJid];
    [circle addAttributeWithName:@"name" stringValue:_groupName];
    
    [iq addChild:queryElement];
    [queryElement addChild:circle];
    
    // NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoVC) name:@"CNN_Group_Upd_Name" object:nil];
}


-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CNN_Group_Upd_Name" object:nil];
    [super viewWillDisappear:animated];
}

//等待服务器返回结果在调用
-(void)gotoVC{
    if([_delegate respondsToSelector:@selector(groupDetailUpdateNameVC:UpdateSuccess:)]){
        [_delegate groupDetailUpdateNameVC:self UpdateSuccess:_groupName];
    }
    
    //修改对话列表里的备注名称
    [ChatBuddyCRUD updateChatBuddyName:_groupName chatUserName:_groupMucId];
    _hub.hidden = YES;
    //更新客户端圈子名称
    // [GroupMembersCRUD updateGroupMemberName:_groupMemberJID nickName:groupMemberNameText.text groupJID:_groupJID];
    //跳转到圈子列表
    [self.navigationController popViewControllerAnimated:YES];
}


@end
