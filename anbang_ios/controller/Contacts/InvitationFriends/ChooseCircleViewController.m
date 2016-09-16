//
//  ChooseCircleViewController.m
//  anbang_ios
//
//  Created by seeko on 14-4-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "ChooseCircleViewController.h"
#import "GroupNameTableViewController.h"
#import "GroupCRUD.h"
#import "GroupQrCodeViewController.h"
#import "UIImageView+WebCache.h"
#import "ImageUtility.h"
#import "AsynImageView.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface ChooseCircleViewController ()
{
    NSMutableArray *arrCircleList;
    UITableView *tableViewCir;
}
@end

@implementation ChooseCircleViewController
@synthesize delegate;
@synthesize fromFlag = _fromFlag;


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
    arrCircleList=[[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(circleList) name:@"CNN_Group_Load_OK" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendSMS:)
												 name:@"NNC_Received_Group_InviteUrl" object:nil];
    //UIBarButtonItem *btnRight=[[UIBarButtonItem alloc]initWithTitle:@"创建圈子" style:UIBarButtonItemStylePlain target:self action:@selector(createCircle)];
    //[self.navigationItem setRightBarButtonItem:btnRight animated:YES];
    
    [self ui];
}




-(void)ui{
    tableViewCir = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-Both_Bar_Height) style:UITableViewStylePlain];
    [self.view addSubview:tableViewCir];
    tableViewCir.dataSource=self;
    tableViewCir.delegate=self;
}


-(void)obtainCirleList{ //获得圈子列表
    
   arrCircleList=[GroupCRUD queryAllChatGroupByMyJID:MY_JID];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self obtainCirleList];
}


-(void)circleList{
    [self obtainCirleList];
    [tableViewCir reloadData];
}


//创建圈子
-(void)createCircle{
    UIAlertView* groundAlert = [[UIAlertView alloc] initWithTitle:@"创建圈子"
                                                    message:@"圈子名称"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"创建", nil];
    groundAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [groundAlert show];
}


#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        UITextField *tf = [alertView textFieldAtIndex:0];
//        NSLog(@"%@",tf.text);
        //创建圈子
        NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/create"];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
//        NSXMLElement *members = [NSXMLElement elementWithName:@"members"];
        
        
      //  XMPPJID *myJID = [XMPPServer xmppStream].myJID;
//        NSString *jid = [NSString stringWithFormat:@"%@",myJID.bareJID];
//        NSLog(@"*****%@",jid);
        
        
        [iq addAttributeWithName:@"to" stringValue:GroupDomain];
        [iq addAttributeWithName:@"id" stringValue:@"createCircle"];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        
        [circle addAttributeWithName:@"name" stringValue:tf.text];
        
//        NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
//        [member addAttributeWithName:@"jid" stringValue:jid];
//        [member addAttributeWithName:@"role" stringValue:@"admin"];
//        [member addAttributeWithName:@"nickname" stringValue:@""];
//        [member addAttributeWithName:@"phone" stringValue:@""];
//        [members addChild:member];
        
        [iq addChild:queryElement];
        [queryElement addChild:circle];
//        [circle addChild:members];
        
//        NSLog(@"组装后的xml:%@",iq);
        [[XMPPServer xmppStream] sendElement:iq];
    }
}


#pragma mark UITableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrCircleList count];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor=[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1];

    NSDictionary *groupDic = [arrCircleList objectAtIndex:[indexPath row]];
    NSMutableArray *groupMembersArray = [groupDic objectForKey:@"groupMembersArray"];
    UIImage *avatarImage1 = [[UIImage alloc]init];
    UIImage *avatarImage2 = [[UIImage alloc]init];
    UIImage *avatarImage3 = [[UIImage alloc]init];
    UIImage *avatarImage4 = [[UIImage alloc]init];
    
    for (int i=0; i<groupMembersArray.count; i++) {
        
        // NSLog(@"######%@",[groupMembersArray objectAtIndex:i]);
        
        if (i==0) {
            AsynImageView*photoView  = [[AsynImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 30.0, 30.0)];
            
            if([[groupMembersArray objectAtIndex:i] isEqualToString:@""] || [groupMembersArray objectAtIndex:i]==nil){
                photoView.image = [UIImage imageNamed:@"defaultUser.png"];
                avatarImage1=photoView.image;
                continue;
            }
            // [photoView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]] ] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]options:indexPath.row == 0 ? SDWebImageRefreshCached : 0 ];
            //[photoView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]]]
            //          placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
            photoView.imageURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]];
            avatarImage1=photoView.image;
            
            
        }else if(i==1){
            AsynImageView*photoView  = [[AsynImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 30.0, 30.0)];
            
            if([[groupMembersArray objectAtIndex:i] isEqualToString:@""] || [groupMembersArray objectAtIndex:i]==nil){
                photoView.image = [UIImage imageNamed:@"defaultUser.png"];
                avatarImage2= photoView.image ;
                continue;
            }
            //  [photoView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]] ] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]options:indexPath.row == 0 ? SDWebImageRefreshCached : 0 ];
           // [photoView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]]]
           //           placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
            photoView.imageURL = [NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]];
            avatarImage2=photoView.image;
            
        }else if(i==2){
           AsynImageView*photoView  = [[AsynImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 30.0, 30.0)];
            if([[groupMembersArray objectAtIndex:i] isEqualToString:@""] || [groupMembersArray objectAtIndex:i]==nil){
                // photoView.image = [UIImage imageNamed:@"defaultUser.png"];
                avatarImage3=[UIImage imageNamed:@"defaultUser.png"];
                continue;
            }
            //[photoView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]] ] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
            photoView.imageURL = [NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]];
            avatarImage3=photoView.image;
            
        }else if(i==3){
            AsynImageView*photoView  = [[AsynImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 30.0, 30.0)];
            
            if([[groupMembersArray objectAtIndex:i] isEqualToString:@""] || [groupMembersArray objectAtIndex:i]==nil){
                photoView.image = [UIImage imageNamed:@"defaultUser.png"];
                avatarImage4=photoView.image;
                continue;
            }
          photoView.imageURL = [NSString stringWithFormat:@"%@/%@",ResourcesURL, [groupMembersArray objectAtIndex:i]];
            avatarImage4=photoView.image;
        }
    }
    
    if(groupMembersArray.count==2){
        UIImageView*photoView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 5.0, 30.0, 30.0)];
        photoView3.image = [UIImage imageNamed:@"placeholder.png"];
        avatarImage3=photoView3.image;
        
        UIImageView*photoView4 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 5.0, 30.0, 30.0)];
        photoView4.image = [UIImage imageNamed:@"placeholder.png"];
        avatarImage4=photoView4.image;
    }else if(groupMembersArray.count==3){
        
        UIImageView*photoView4 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 5.0, 30.0, 30.0)];
        photoView4.image = [UIImage imageNamed:@"placeholder.png"];
        avatarImage4=photoView4.image;
        
    }
    cell.imageView.image =[ImageUtility addImage:avatarImage1 toImage:avatarImage2 threeImage:avatarImage3 four:avatarImage4];
    cell.textLabel.text=[groupDic objectForKey:@"groupName"];
    
    CGSize itemSize = CGSizeMake(50, 50);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 3.0;
    cell.imageView.layer.borderWidth = 2.0;
    cell.imageView.backgroundColor = kMainColor4;
    cell.imageView.layer.borderColor = [kMainColor4 CGColor];


    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
     NSString *groupJID= [[arrCircleList objectAtIndex:[indexPath row]]objectForKey:@"groupJID"];
     NSString *groupName= [[arrCircleList objectAtIndex:[indexPath row]]objectForKey:@"groupName"];
    
    if ([_fromFlag isEqualToString:@"Qrcode"]) {
        GroupQrCodeViewController *groupQrCode=[[GroupQrCodeViewController alloc]init];
        groupQrCode.groupJID=groupJID;
        groupQrCode.groupName=groupName;
        
        [self.navigationController pushViewController:groupQrCode animated:YES];
    }else{
   
    [delegate setCellValue:cell.textLabel.text groundJID:groupJID];
    [self.navigationController popViewControllerAnimated:YES];
    }
}


//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 68;
    
}

//-(void)dealloc{
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CNN_Group_Load_OK" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Received_Group_InviteUrl" object:nil];
//    [_fromFlag release];
//    [arrCircleList release];
//    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"CNN_Group_Load_OK" object:nil];
//    [super dealloc];
//}
@end
