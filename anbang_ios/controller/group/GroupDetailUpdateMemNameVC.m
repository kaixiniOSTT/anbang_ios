//
//  GroupDetailUpdateMemNameVC.m
//  anbang_ios
//
//  Created by yangsai on 15/3/30.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "GroupDetailUpdateMemNameVC.h"
#import "MBProgressHUD.h"
#import "UserInfo.h"
#import "GroupMembersCRUD.h"
#import "BBTextField.h"
#import "AIFlixBarButtonItem.h"

@interface GroupDetailUpdateMemNameVC ()
@property (nonatomic,strong)BBTextField* groupMembNameTF;
@property (nonatomic, strong)MBProgressHUD* hub;
@end

@implementation GroupDetailUpdateMemNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorFromHexString:@"#f6f2ed"];
 
    [self setupNavigationItem];
    [self setContentView];
    _hub = [[MBProgressHUD alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    _hub.labelText = @"正在更新,请稍等!";
    _hub.dimBackground = YES;
    
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

    self.navigationItem.title = @"我在本群的昵称";
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStyleDone target:self action:@selector(updateNameMethod)], flix];
    
}

- (void)setContentView{
  
    _groupMembNameTF = [[BBTextField alloc]initWithFrame:CGRectMake(15, 15, self.view.bounds.size.width - 30, 45)];
    _groupMembNameTF.text = _groupMembName;
   // _groupMembNameTF.borderStyle = UITextBorderStyleRoundedRect;
    
    _groupMembNameTF.backgroundColor = AB_White_Color;
    _groupMembNameTF.font = [UIFont systemFontOfSize:15];
    // _groupNameTF.placeholder = @"输入群聊名称";
    [_groupMembNameTF setCustomPlaceholder:@"输入昵称"];
    _groupMembNameTF.textColor = AB_Gray_Color;
    _groupMembNameTF.layer.cornerRadius = 3.0;
    _groupMembNameTF.layer.borderWidth = 0.5;
    _groupMembNameTF.layer.borderColor = Normal_Border_Color.CGColor;
    
    
    [self.view addSubview:_groupMembNameTF];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateNameMethod{
    [_groupMembNameTF resignFirstResponder];
    
      _groupMembName =  [_groupMembNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
   
    
    if ([StrUtility isBlankString:_groupMembName]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")
                                                        message:NSLocalizedString(@"circleMemberInfo.nickName.updMsg",@"title")
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
        [alert addButtonWithTitle:NSLocalizedString(@"public.button.ok",@"title")];
        [alert show];
        return;
    }
    
    if ( _groupMembName.length > 40  ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"circleMemberInfo.nickName.updMsg.tooLong",@"title") delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert addButtonWithTitle:NSLocalizedString(@"public.button.ok",@"title")];
        [alert show];
        return;
    }
    
    NSString *regex = @"^[\\w-,、，.。·:|~`！!\\?？]{1,40}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![predicate evaluateWithObject:_groupMembName]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"circleMemberInfo.nickName.updMsg.invalid",@"title") delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        // optional - add more buttons:
        [alert addButtonWithTitle:NSLocalizedString(@"public.button.ok",@"title")];
        [alert show];
        return;
    }
    
    [_hub show:YES];
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/admin"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
    NSXMLElement *members = [NSXMLElement elementWithName:@"members"];
    NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
    
    [iq addAttributeWithName:@"id" stringValue:IQID_GroupMember_Upd_Name];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:GroupDomain];
    [circle addAttributeWithName:@"jid" stringValue:_groupJid];
    
    [member addAttributeWithName:@"jid" stringValue:_groupMembJid];
    [member addAttributeWithName:@"nickname" stringValue:_groupMembName];
    [member addAttributeWithName:@"role" stringValue:@"member"];
    
    [iq addChild:queryElement];
    [queryElement addChild:circle];
    [circle addChild:members];
    [members addChild:member];
    
    NSLog(@"组装后的xml:%@",iq);
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoVC) name:@"CNN_GroupMember_Upd_Name" object:nil];
}


-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:@"CNN_GroupMember_Upd_Name" object:nil];
    [super viewWillDisappear:animated];
}

//等待服务器返回结果在调用
-(void)gotoVC{
    if([_delegate respondsToSelector:@selector(groupDetailUpdateMemNameVC:UpdateSuccess:)]){
        [_delegate groupDetailUpdateMemNameVC:self UpdateSuccess:_groupMembNameTF.text];
    }
    
    _hub.hidden = YES;
    //更新客户端圈子名称
    //[GroupMembersCRUD updateGroupMemberName:_groupMembJid nickName:_groupMembNameTF.text groupJID:_groupJid];
    //跳转到圈子列表
    [self.navigationController popViewControllerAnimated:YES];
}





@end
