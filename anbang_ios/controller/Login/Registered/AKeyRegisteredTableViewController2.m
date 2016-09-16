//
//  GroupNameTableViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 14-4-24.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "AKeyRegisteredTableViewController2.h"
#import "RegisteredViewController.h"
#import "LoadingViewController.h"
#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface AKeyRegisteredTableViewController2 ()

@end

@implementation AKeyRegisteredTableViewController2
@synthesize prompt = _prompt;
@synthesize userSource = _userSource;

- (void)viewDidLoad
{
    JLLog_D("%s",__FUNCTION__);
    
    [super viewDidLoad];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        //self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(load_next) name:@"NSN_Registered_Success" object:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"anonymouss" forKey:@"userName"];
    [defaults setObject:nil forKey:@"password"];
    [defaults synchronize];
    [[XMPPServer sharedServer]connect];
    
    textFieldName.delegate = self;
    
    [self.navigationItem setTitle:NSLocalizedString(@"aKeyRegistered.title",@"title")];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setExtraCellLineHidden:self.tableView];
    
    
    //UIBarButtonItem *btnLeft=[[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(clickLeftButton)];
   // [self.navigationItem setLeftBarButtonItem:btnLeft];
    
    //下一步
    UIBarButtonItem *nextStep = [[UIBarButtonItem alloc]
                                 initWithTitle:NSLocalizedString(@"aKeyRegistered.nextStep",@"action") style:UIBarButtonItemStyleBordered
                                 target:self action:@selector(clickRightButton)];
    [self.navigationItem setRightBarButtonItem:nextStep];
    
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}


- (void) textFieldDidChange:(UITextField *) TextField{
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        if (_prompt !=nil) {
        cell.textLabel.text = _prompt;
        }else{
            cell.textLabel.text = NSLocalizedString(@"aKeyRegistered.tableViewTitle",@"title");
        }
        
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.frame = CGRectMake(0 , 0, 300, 80);
        cell.textLabel.numberOfLines =0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];

    }else{
        textFieldName = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, KCurrWidth-35, 50)];
        
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        textFieldName.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textFieldName setPlaceholder:NSLocalizedString(@"aKeyRegistered.nickName",@"title")];
        //设置字体颜色
        textFieldName.textColor = [UIColor blueColor];
        textFieldName.font = [UIFont fontWithName:@"Helvetica" size:26.0f];
        
        [textFieldName becomeFirstResponder];
        [cell addSubview:textFieldName];
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

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 */




-(void)load_next{
    
    LoadingViewController *load=[[LoadingViewController alloc]init];
    [self presentViewController:load animated:YES completion:^{}];
}


-(void)clickLeftButton
{
    RegisteredViewController *registeredView=[[RegisteredViewController alloc]init];
    [self presentViewController:registeredView animated:NO completion:nil];
}

-(void)queryRosterRegister{
    /*
     <iq type=”set” id＝“1”>
     <query xmlns=”http://www.nihualao.com/xmpp/annoymous/register”>
     <name>昵称</name>
     <phone countryCode=”国家码”>绑定的手机号</phone>
     <validateCode>绑定手机号的验证码</validateCode> </query>
     </iq>
     <iq type="set"><query xmlns="http://www.nihualao.com/xmpp/anonymous/register"><name>111</name></query></iq>
     */
    //    NSLog(@"------                                   ------");
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/anonymous/register"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *name=[NSXMLElement elementWithName:@"name" stringValue:textFieldName.text];
    NSXMLElement *souce=[NSXMLElement elementWithName:@"source" stringValue:_userSource];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"aKey"];
    
    [queryElement addChild:name];
    [queryElement addChild:souce];
    [iq addChild:queryElement];
    //    NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
}

//进行注册
-(void)clickRightButton{
    [self queryRosterRegister];
}

- (IBAction)backgroundTop:(id)sender {
    [textFieldName resignFirstResponder];
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NSN_Registered_Success" object:nil];
}

@end
