//
//  MessageListViewController.m
//  FriendQuanPro
//
//  Created by MyLove on 15/7/10.
//  Copyright (c) 2015年 Double_yang. All rights reserved.
//

#import "MessageListViewController.h"
#import "UserInfoCRUD.h"
#import "UserInfo.h"
#import "ContactsCRUD.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "QuanDetailViewController.h"

@interface MessageListViewController ()

@end

@implementation MessageListViewController
@synthesize userArray,userTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitle.text = @"消息列表";
    
    //创建列表
    userTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, IS_iOS7?64:44, Screen_Width, Screen_Height-(IS_iOS7?64:44))];
    userTableView.dataSource = self;
    userTableView.delegate = self;
    userTableView.backgroundColor = [UIColor clearColor];
    userTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:userTableView];
}

#pragma mark  -------列表代理事件-------
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return userArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0.0;
    NSDictionary * dic = [userArray objectAtIndex:indexPath.row];
    NSString *wcontent = [dic objectForKey:@"content"];
    NSString *content = [NSString stringWithFormat:@"%@",wcontent];
    UIFont *cfont = [UIFont systemFontOfSize:15];;
    CGSize csize = [self sizeForString:content font:cfont size:CGSizeMake(Screen_Width-70, 1000)];
    if ([[dic objectForKey:@"newtype"] isEqualToString:@"1"]) {
        height = 60;
    }
    else{
        float newHeight = 36+csize.height+10;
        if (newHeight>60) {
            height = newHeight;
        }
        else{
            height = 60;
        }
    }
    return height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *GroupedTableIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             GroupedTableIdentifier];
    while ([cell.contentView.subviews lastObject] != nil) {
        [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
    }
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GroupedTableIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    NSDictionary * dic = [userArray objectAtIndex:indexPath.row];
    NSString * jid = [NSString stringWithFormat:@"%@%@",[dic objectForKey:@"usersrc"],@"@ab-insurance.com"];
    UserInfo *userInfo = [UserInfoCRUD queryUserInfo:jid myJID:MY_JID];
    NSString * name = userInfo.nickName;
    NSString * avatar = userInfo.avatar ? userInfo.avatar : @"";
    NSString * headUrl = [NSString stringWithFormat:@"http://183.136.198.235:7500/v1/tfs/%@",avatar];
    
    //图像
    UIImageView * userImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10 , 40, 40)];
    userImage.contentMode = UIViewContentModeScaleAspectFill;
    userImage.backgroundColor = RGBACOLOR(238, 238, 238, 1);
    [userImage.layer setMasksToBounds:YES];
    [userImage setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:nil];
    [userImage.layer setCornerRadius:3.0];
    [cell.contentView addSubview:userImage];
    
    //用户
    UILabel * infolabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, 200, 20)];
    infolabel.backgroundColor = [UIColor clearColor];
    infolabel.font = [UIFont systemFontOfSize:15];
    infolabel.text = name;
    infolabel.textColor = RGBACOLOR(96, 116, 169, 1);
    [cell.contentView addSubview:infolabel];
    
    //内容
    NSString *wcontent = [dic objectForKey:@"content"];
    NSString *content = [NSString stringWithFormat:@"%@",wcontent];
    UIFont *cfont = [UIFont systemFontOfSize:15];;
    CGSize csize = [self sizeForString:content font:cfont size:CGSizeMake(Screen_Width-70, 1000)];
    
    UILabel * conlabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 36, Screen_Width-70, csize.height)];
    conlabel.backgroundColor = [UIColor clearColor];
    conlabel.font = [UIFont systemFontOfSize:15];
    conlabel.text = content;
    conlabel.numberOfLines = 0;
    conlabel.textColor = RGBACOLOR(34, 34, 34, 1);
    [cell.contentView addSubview:conlabel];
    
    UIImageView * zanImage = [[UIImageView alloc]initWithFrame:CGRectMake(60, 38, 18, 16)];
    zanImage.image = [UIImage imageNamed:@"icon_circle_like.png"];
    [cell.contentView addSubview:zanImage];
    
    if ([[dic objectForKey:@"newtype"] isEqualToString:@"0"]) {
        zanImage.hidden = YES;
    }
    else{
        conlabel.hidden = YES;
    }
    
    //时间
    float w = 60 + name.length * 16;
    UILabel * timelabel = [[UILabel alloc]initWithFrame:CGRectMake(w, 13, Screen_Width-60, 20)];
    timelabel.backgroundColor = [UIColor clearColor];
    timelabel.font = [UIFont systemFontOfSize:12];
    timelabel.text = [dic objectForKey:@"newtime"];
    timelabel.textColor = RGBACOLOR(151, 151, 151, 1);
    [cell.contentView addSubview:timelabel];
    
    float height = 0.0;
    if ([[dic objectForKey:@"newtype"] isEqualToString:@"1"]) {
        height = 60;
    }
    else{
        float newHeight = 36+csize.height+10;
        if (newHeight>60) {
            height = newHeight;
        }
        else{
            height = 60;
        }
    }
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, height-1, 320, 1)];
    lineView.backgroundColor = RGBACOLOR(247, 247, 247, 1);
    [cell.contentView addSubview:lineView];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = [userArray objectAtIndex:indexPath.row];
    QuanDetailViewController * dvc = [[QuanDetailViewController alloc]init];
    dvc.detailDic = dic;
    dvc.comeStr = @"1";
    [self.navigationController pushViewController:dvc animated:YES];
}

#pragma mark - 动态计算高度和宽度
-(CGSize)sizeForString:(NSString *)string font:(UIFont *)font size:(CGSize)size{
    CGSize newSize;
    if(IS_iOS7){
        CGRect newRect = [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil];
        newSize = newRect.size;
    }else{
        newSize = [string sizeWithFont:font constrainedToSize:size];
    }
    return newSize;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
