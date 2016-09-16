//
//  GroupNameTableViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 14-4-24.
//  Copyright (c) 2014年 ch. All rights reserved.
//
//  创建圈子

#import "GroupNameTableViewController.h"
#import "GroupAddContactsViewController.h"
#import "DejalActivityView.h"
#import "GroupCRUD.h"
#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface GroupNameTableViewController ()

@end

@implementation GroupNameTableViewController
@synthesize groupName = _groupName;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextStep:)
                                                 name:@"NNC_Received_GroupCreate" object:nil];
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        //self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    text.delegate = self;
    
    //创建圈子
    [self.navigationItem setTitle:NSLocalizedString(@"circleCreate.title",@"title")];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setExtraCellLineHidden:self.tableView];
    
    //下一步
    UIBarButtonItem *nextStep = [[UIBarButtonItem alloc]
                                 initWithTitle:NSLocalizedString(@"circleCreate.nextStep",@"action") style:UIBarButtonItemStyleBordered
                                 target:self action:@selector(createGroup)];
    [self.navigationItem setRightBarButtonItem:nextStep];
    
    text.text = _groupName;
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    //[view release];
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
        //输入圈子名称
        cell.textLabel.text = NSLocalizedString(@"circleCreate.tableViewTitle",@"title");
    }else{
        text = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, 280, 50)];
        
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        text.clearButtonMode = UITextFieldViewModeWhileEditing;
        //圈子名称
        [text setPlaceholder:NSLocalizedString(@"circleCreate.circleName",@"title")];
        //设置字体颜色
        text.textColor = [UIColor blueColor];
        
        [text becomeFirstResponder ];
        [cell addSubview:text];
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

-(void)nextStep:(NSNotification *)noti
{
    NSMutableArray *groupArray = [[NSMutableArray alloc]init];
    groupArray = [noti object];
    
    [DejalBezelActivityView removeViewAnimated:YES];
    GroupAddContactsViewController *groupAddContactsVC = [[GroupAddContactsViewController alloc]init];
    
    for (ChatGroup* group in groupArray) {
        groupAddContactsVC.groupJID = group.jid;
        //groupAddContactsVC.groupName = group.name;
    }
    groupAddContactsVC.groupName = text.text;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
        //隐藏tabbar
        //groupDetailsVC.hidesBottomBarWhenPushed=YES;
        self.tabBarController.tabBar.hidden = YES;
        
    }else{
        //隐藏tabbar
        groupAddContactsVC.hidesBottomBarWhenPushed=YES;
    }
    [self.navigationController pushViewController:groupAddContactsVC animated:YES];
}


-(void)createGroup{
    
    //    <iq type=”set” to=”circle.nihualao.com”>
    //    <query xmlns=”http://www.nihualao.com/xmpp/circle/create”>
    //    <circle name=””> <members>
    //    <member jid=”” role=”admin” nickname=”” phone=”如果没有开户
    //    可用通讯录中的电话号码”/>
    //    <member jid=”” role=”member” nickname=””/> </members>
    //    </circle> </query>
    //    </iq>
    
    text.text = [text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([text.text isEqualToString:@""]) {
        //圈子名称不能为空
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"circleUpdName.nameNotEmpty",@"message") delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        // optional - add more buttons:
        [alert addButtonWithTitle:NSLocalizedString(@"public.alert.ok",@"message")];
        [alert show];
        //[alert release];
        
        return;
    }
    
    if ([GroupCRUD queryCountGroupByMyJID:MY_JID]>6) {
        //圈子超出最大限制
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"circleUpdName.maxMsg",@"message") delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert addButtonWithTitle:NSLocalizedString(@"public.alert.ok",@"message")];
        [alert show];
        //[alert release];
        
        return;
        
    }
    
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/create"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
    NSXMLElement *members = [NSXMLElement elementWithName:@"members"];
    
    
    XMPPJID *myJID = [XMPPServer xmppStream].myJID;
    NSString *jid = [NSString stringWithFormat:@"%@",myJID.bareJID];
    // NSLog(@"*****%@",jid);
    
    
    [iq addAttributeWithName:@"to" stringValue:GroupDomain];
    
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    
    [circle addAttributeWithName:@"name" stringValue:text.text];
    
    NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
    [member addAttributeWithName:@"jid" stringValue:jid];
    [member addAttributeWithName:@"role" stringValue:@"admin"];
    [member addAttributeWithName:@"nickname" stringValue:@""];
    [member addAttributeWithName:@"phone" stringValue:@""];
    [members addChild:member];
    
    
    [iq addChild:queryElement];
    [queryElement addChild:circle];
    [circle addChild:members];
    
    NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
    //加载动画效果
    [DejalBezelActivityView activityViewForView:self.view];
    
}


@end
