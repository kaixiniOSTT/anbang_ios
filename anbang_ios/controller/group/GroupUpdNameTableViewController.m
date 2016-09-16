//
//  GroupUpdNameTableViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 14-5-26.
//  Copyright (c) 2014年 ch. All rights reserved.
//
//  修改圈子名称

#import "GroupUpdNameTableViewController.h"
#import "GroupAddContactsViewController.h"
#import "GroupCRUD.h"

@interface GroupUpdNameTableViewController ()

@end

@implementation GroupUpdNameTableViewController
@synthesize groupName = _groupName;
@synthesize groupJID = _groupJID;


-(void)dealloc{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //修改群组名称后跳转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoVC) name:@"CNN_Group_Upd_Name" object:nil];
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        //self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    groupNameText.delegate = self;
    //修改圈子名称
    [self.navigationItem setTitle: NSLocalizedString(@"circleUpdName.title",@"title")];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setExtraCellLineHidden:self.tableView];
    
    //下一步
    UIBarButtonItem *nextStep = [[UIBarButtonItem alloc]
                                 initWithTitle: NSLocalizedString(@"public.alert.ok",@"title") style:UIBarButtonItemStyleBordered
                                 target:self action:@selector(nextStep)];
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
        //修改圈子名称
        cell.textLabel.text = NSLocalizedString(@"circleUpdName.tableViewTitle",@"title");
    }else{
        groupNameText = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, KCurrWidth-40, 50)];
        
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        groupNameText.clearButtonMode = UITextFieldViewModeWhileEditing;
        //圈子名称
        [groupNameText setPlaceholder:NSLocalizedString(@"circleUpdName.title",@"title")];
        //设置字体颜色
        //text.textColor = [UIColor blueColor];
        groupNameText.text = _groupName;
        [groupNameText becomeFirstResponder ];
        [cell addSubview:groupNameText];
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

-(void)nextStep
{
    /*
     <iq id="1DDsY-263" to="circle.ab-insurance.com" type="set"><query xmlns="http://www.nihualao.com/xmpp/circle/admin"><circle jid="10005@circle.ab-insurance.com" name="要是e"/></query></iq>
     */
    groupNameText.text =  [groupNameText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([groupNameText.text isEqualToString:@""]) {
        //圈子名称不能为空
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"circleUpdName.nameNotEmpty",@"message") delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        // optional - add more buttons:
        [alert addButtonWithTitle:NSLocalizedString(@"public.alert.ok",@"message")];
        [alert show];
        return;
        
    }
    
    /*
     <iq id="1DDsY-263" to="circle.ab-insurance.com" type="set"><query xmlns="http://www.nihualao.com/xmpp/circle/admin"><circle jid="10005@circle.ab-insurance.com" name="要是e"/></query></iq>
     */
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/admin"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
    
    [iq addAttributeWithName:@"id" stringValue:IQID_Group_Upd_Name];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:GroupDomain];
    [circle addAttributeWithName:@"jid" stringValue:_groupJID];
    [circle addAttributeWithName:@"name" stringValue:groupNameText.text];
    
    [iq addChild:queryElement];
    [queryElement addChild:circle];
    
    // NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
}


//等待服务器返回结果在调用
-(void)gotoVC{
    //更新客户端圈子名称
    //跳转到圈子列表,修改圈子名称时，通过返回的notify 修改本地圈子名称
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}



@end
