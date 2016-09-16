//
//  EmailViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-20.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "EmailViewController.h"
#import "CHAppDelegate.h"
#import "Utility.h"
@interface EmailViewController ()
{
    UITextField *txtEmail;
}
@end

@implementation EmailViewController
@synthesize tableView=_tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindingSuccess) name:@"bindingEmail_ok" object:nil];
    }
    return self;
}
-(void)dealloc{

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=NSLocalizedString(@"personalInformation.rebindEmail.title",@"title");
    //[self ui];
    UIBarButtonItem *rightBut=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"public.alert.ok",@"action") style:UIBarButtonItemStylePlain target:self action:@selector(sendBindingEmail)];
    [self.navigationItem setRightBarButtonItem:rightBut];

    _tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollsToTop = YES;
    [self.view addSubview:_tableView];
    //[_tableView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [_tableView setSeparatorInset:(UIEdgeInsetsMake(0, 0, 0, 0))];
    }
    
    //删除多余线条
    [Utility setExtraCellLineHidden:_tableView];
}

-(void)ui{
    UIBarButtonItem *rightBut=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"public.alert.ok",@"action") style:UIBarButtonItemStylePlain target:self action:@selector(sendBindingEmail)];
    [self.navigationItem setRightBarButtonItem:rightBut];
    
    txtEmail=[[UITextField alloc]initWithFrame:CGRectMake(10, Both_Bar_Height+10, 300, 35)];
    txtEmail.borderStyle=UITextBorderStyleRoundedRect;
    txtEmail.placeholder=NSLocalizedString(@"personalInformation.rebindEmail.emailAddress",@"title");
    [txtEmail setKeyboardType:UIKeyboardTypeEmailAddress];
    [txtEmail becomeFirstResponder];
    [self.view addSubview:txtEmail];

    UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(10, Both_Bar_Height+50, 300, 50)];
    lab.lineBreakMode = NSLineBreakByCharWrapping;
    lab.numberOfLines = 0;
    lab.text=NSLocalizedString(@"personalInformation.rebindEmail.message",@"message");
    [lab setTextColor:[UIColor lightGrayColor]];
    lab.font=[UIFont boldSystemFontOfSize:15];
    lab.textAlignment=1;
    lab.textColor=[UIColor lightGrayColor];
    [self.view addSubview:lab];
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
        cell.textLabel.text = NSLocalizedString(@"personalInformation.rebindEmail.message",@"message");
        cell.textLabel.numberOfLines = 0;
    }else{
        txtEmail = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, KCurrWidth-40, 50)];
        
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        txtEmail.clearButtonMode = UITextFieldViewModeWhileEditing;
        [txtEmail setPlaceholder:NSLocalizedString(@"personalInformation.rebindEmail.emailAddress",@"title")];
        //设置字体颜色
        //text.textColor = [UIColor blueColor];
        [txtEmail becomeFirstResponder ];
        [cell addSubview:txtEmail];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 100;
    }else{
        return 55;
    }
}


-(void)sendBindingEmail{
    if (txtEmail.text.length>0) {
        if ([self isEmail:txtEmail.text]) {
            [self sendRequset];
        }else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"personalInformation.rebindEmail.emailFormatError",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"personalInformation.rebindEmail.enterEmail",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
        [alertView show];
    }
}

//绑定邮箱请求
-(void)sendRequset{
    /*<iq type=”set”>
     <query xmlns=”http://www.nihualao.com/xmpp/bind”>
     <bind email=”需绑定的邮箱”/> </query>
     </iq>*/
    NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/bind"];
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    NSXMLElement *bind=[NSXMLElement elementWithName:@"bind"];
    [bind addAttributeWithName:@"email" stringValue:txtEmail.text];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"bindingEmail"];
    [queryElement addChild:bind];
    [iq addChild:queryElement];
    //     NSLog(@"%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
}

//邮箱格式检测
- (BOOL) isEmail: (NSString *) candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

-(void)bindingSuccess{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"bindingEmail_ok" object:nil];
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"personalInformation.sendEmailMsg",@"message") message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    alertView.tag=1021;
    [alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backgroundTop:(id)sender{
    [txtEmail resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1021) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
