//
//  ABSelectedResultVC.m
//  anbang_ios
//
//  Created by yangsai on 15/3/28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "ABSelectedResultVC.h"
#import "UserInfo.h"
#import "ContactsDetailsViewController.h"
#import "UIImageView+WebCache.h"
#import "ContactInfo.h"

#define AB_Icon_Tag 5343

@interface ABSelectedResultVC ()
{
    NSString* contactsJID;
    NSString* contactsUserName;
    NSString* contactsRemarkName;
    NSString* contactsNickName;
    NSString* contactsAvatarURL;
}
@end

@implementation ABSelectedResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"abselectedResultCell"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"安邦通讯录";
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.view.backgroundColor = Controller_View_Color;
    
    if (_resultArr.count == 0) {
        UIAlertView* alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:@"没有符合查询的记录!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [self.view addSubview:alertV];
        [alertV show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    // Return the number of rows in the section.
    return [_resultArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"abselectedResultCell" forIndexPath:indexPath];
    
    UserInfo *str = (UserInfo *) [_resultArr objectAtIndex:indexPath.row];
    //cell.textLabel.text = str.string;
    NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, str.avatar];
    [cell.imageView  setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    CGSize itemSize = CGSizeMake(50, 50);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIImageView *icon = (UIImageView *)[cell.imageView viewWithTag:AB_Icon_Tag];
    if (!icon) {
        UIImageView *abIcon = [[UIImageView alloc] init];
        abIcon.frame = CGRectMake(29, 34, 16, 11);
        abIcon.image = [UIImage imageNamed:@"icon_ab01"];
        abIcon.tag = AB_Icon_Tag;
        [cell.imageView addSubview:abIcon];
    }
    
    // [cell.contentView addSubview:nameLabel];
    cell.textLabel.text =  str.employeeName;
    

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UserInfo *userinfo =  [_resultArr objectAtIndex:indexPath.row];
    
//    contactsJID = contacts.jid;
//    contactsUserName = contacts.jid;
//    contactsRemarkName = contacts.remarkName;
//    contactsNickName = contacts.nickName;
//    
//    if (contacts.avatar!=NULL && ![contacts.avatar isEqualToString:@""]) {
//        contactsAvatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, contacts.avatar];
//    }
//    
//    
//    NSString*str_character = @"@";
//    NSRange senderRange = [contactsUserName rangeOfString:str_character];
//    
//    if ([contactsUserName rangeOfString:str_character].location != NSNotFound) {
//        contactsUserName = [contactsUserName substringToIndex:senderRange.location];
//    }
//    
//    
//    ContactsDetailsViewController *contactsDetailsVC=[[ContactsDetailsViewController alloc] initWithNibName:@"ContactsDetailsViewController" bundle:nil];
//    contactsDetailsVC.contactsJID = contactsJID;
//    contactsDetailsVC.contactsUserName = contactsUserName;
//    contactsDetailsVC.contactsRemarkName = contactsRemarkName;
//    contactsDetailsVC.contactsNickName = contactsNickName;;
//    contactsDetailsVC.contactsAvatarURL = contactsAvatarURL;
    
    
    //修改后走得新的通讯录名片界面
    ContactInfo* contactinfoVC = [[ContactInfo alloc]init];
    contactinfoVC.jid = userinfo.jid;
    contactinfoVC.userinfo = userinfo;
    //隐藏tabbar
    contactinfoVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController :contactinfoVC animated:YES];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68.0;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
