//
//  ContactsRemarkNameTableViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 14-5-13.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "ContactsRemarkNameTableViewController.h"
#import "GroupAddContactsViewController.h"
#import "ContactsCRUD.h"
#import "ChatBuddyCRUD.h"

@interface ContactsRemarkNameTableViewController ()

@end

@implementation ContactsRemarkNameTableViewController
@synthesize contactsJID = _contactsJID;
- (void)viewDidLoad
{
    [super viewDidLoad];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        //self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    text.delegate = self;
    
    [self.navigationItem setTitle: NSLocalizedString(@"ContactsDetails.remark.title",@"title")];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setExtraCellLineHidden:self.tableView];
    
    //下一步
    UIBarButtonItem *nextStep = [[UIBarButtonItem alloc]
                                 initWithTitle:NSLocalizedString(@"public.nvaButton.save",@"action") style:UIBarButtonItemStyleBordered
                                 target:self action:@selector(saveRemarkName)];
    [self.navigationItem setRightBarButtonItem:nextStep];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [text resignFirstResponder];
}

-(void)dealloc {

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
        cell.textLabel.text = NSLocalizedString(@"ContactsDetails.remark.tableTitle",@"title");
    }else{
        text = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, 280, 50)];
        
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        text.clearButtonMode = UITextFieldViewModeWhileEditing;
        [text setPlaceholder:NSLocalizedString(@"ContactsDetails.remark.remark",@"title")];
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

-(void)saveRemarkName
{
    if ([text.text isEqualToString:@""]) {
        return;
    }
    
    //NSString *myJID = [[NSString alloc] initWithFormat:@"%@", [XMPPServer xmppStream].myJID.bareJID];
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    NSXMLElement *group = [NSXMLElement elementWithName:@"group"];
    [iq addAttributeWithName:@"id" stringValue:@"1012"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"from" stringValue:MY_JID];
    [item addAttributeWithName:@"jid" stringValue:_contactsJID];
    [item addAttributeWithName:@"name" stringValue:text.text];
    [item addChild:group];
    [iq addChild:queryElement];
    [queryElement addChild:item];
    
    [[XMPPServer xmppStream] sendElement:iq];
    //修改本地备注名称
    [ContactsCRUD updateContactsRemarkName:_contactsJID remarkName:text.text myJID:MY_JID];
    
    //修改对话列表里的备注名称
    NSString *chatUserName = [_contactsJID componentsSeparatedByString:@"@"][0];
    [ChatBuddyCRUD updateChatBuddyName:text.text chatUserName:chatUserName];
    
    //跳转到详细资料
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}

@end
