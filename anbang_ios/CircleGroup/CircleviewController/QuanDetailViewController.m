//
//  QuanDetailViewController.m
//  FriendQuanPro
//
//  Created by MyLove on 15/7/16.
//  Copyright (c) 2015年 Double_yang. All rights reserved.
//

#import "QuanDetailViewController.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "UserInfoCRUD.h"
#import "UserInfo.h"
#import "ContactsCRUD.h"
#import "CHImageWithDataView.h"
#import "JSONKit.h"
#import "FaBuQuanViewController.h"

@interface QuanDetailViewController ()
{
    NSMutableArray * userArray;
    NSString * oneString;
    NSString * twoString;
    UIMenuController *_menuController;
    NSDictionary * curDic;
    NSDictionary * biaoJiDic;
    NSString * huiFuString;
    
    int currentNum;
    
    BOOL isChange;
}

@property (nonatomic, retain) NSArray * photos;
@property (nonatomic, retain) NSArray * thumbs;
@property (nonatomic, retain) DXMessageToolBar * toolBar;

@end

@implementation QuanDetailViewController
@synthesize trendsTab,toolBar;

//点击屏幕任何地方隐藏键盘实现
- (void)setUpForDismissKeyboard {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UITapGestureRecognizer *singleTapGR =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapAnywhereToDismissKeyboard:)];
    NSOperationQueue *mainQuene =[NSOperationQueue mainQueue];
    [nc addObserverForName:UIKeyboardWillShowNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [self.view addGestureRecognizer:singleTapGR];
                }];
    [nc addObserverForName:UIKeyboardWillHideNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [self.view removeGestureRecognizer:singleTapGR];
                }];
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    //此method会将self.view里所有的subview的first responder都resign掉
    [self keyBoardHidden];
    
    [self.view endEditing:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitle.text = @"用户昵称";
    NSString * jid;
    if ([self.comeStr isEqualToString:@"1"]) {
        jid = [NSString stringWithFormat:@"%@%@",[self.detailDic objectForKey:@"usersrc"],@"@ab-insurance.com"];
    }
    else{
        jid = [NSString stringWithFormat:@"%@%@",[self.detailDic objectForKey:@"userid"],@"@ab-insurance.com"];
    }
    UserInfo *userInfo = [UserInfoCRUD queryUserInfo:jid myJID:MY_JID];
    NSString * oneName = userInfo.nickName;
    self.navTitle.text = oneName;
    
    [self.navRight setImage:[UIImage imageNamed:@"header_button_camera.png"] forState:UIControlStateNormal];
    self.navRight.frame = CGRectMake(self.navRight.frame.origin.x+13, self.navRight.frame.origin.y+13, 24, 18);
    
    userArray = [[NSMutableArray alloc]initWithCapacity:0];
    isChange = NO;
    
    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, IS_iOS7?64:44, Screen_Width, Screen_Height-(IS_iOS7?64:44))];
    mainView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainView];
    
    UIView * oneView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 40)];
    oneView.backgroundColor = [UIColor whiteColor];
    [mainView addSubview:oneView];
    
    trendsTab = [[UITableView alloc] init];
    trendsTab.frame = CGRectMake(0, 0, Screen_Width, mainView.frame.size.height);
    trendsTab.dataSource = self;
    trendsTab.delegate = self;
    trendsTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [mainView addSubview:trendsTab];
    
    /*
     *  多功能键盘
     */
    toolBar = [[DXMessageToolBar alloc]initWithFrame:CGRectMake(0, Screen_Height, Screen_Width, [DXMessageToolBar defaultHeight])];
    //toolBar.isToalAction = @"1";
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    toolBar.delegate = self;
    toolBar.isToalAction = @"1";
    [self.view addSubview:toolBar];
    if ([toolBar.moreView isKindOfClass:[DXChatBarMoreView class]]) {
        [(DXChatBarMoreView *)toolBar.moreView setDelegate:self];
    }
    //请求说说详情
    [self receiveShuoData];
    
    [self setUpForDismissKeyboard];
}
//请求说说详情
-(void)receiveShuoData
{
    //提交操作
    NSString * string = @"http://104.238.236.144//cfapi/contdetail";
    NSMutableDictionary * paeaments = [NSMutableDictionary dictionary];
    [paeaments setObject:[self.detailDic objectForKey:@"textid"] forKey:@"textid"];
    [paeaments setObject:MY_USER_NAME forKey:@"userid"];
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    [manager POST:string parameters:paeaments success:^(AFHTTPRequestOperation * operation, id responseObject){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSDictionary * resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if ([[resultDic objectForKey:@"error"] isKindOfClass:[NSNull class]]) {
            self.detailDic = [[resultDic objectForKey:@"data"] objectAtIndex:0];
            [userArray addObject:self.detailDic];
            
            //拆分数组
            [self sonArrayData];
        }
    } failure:^(AFHTTPRequestOperation *operation,NSError * orrer){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

//拆分数组
-(void)sonArrayData
{
    //评论
    if (![[self.detailDic objectForKey:@"pldetails"] isKindOfClass:[NSNull class]]) {
        NSArray * pingArray = [self.detailDic objectForKey:@"pldetails"];
        if (pingArray.count>0) {
            twoString = @"1";
            [userArray addObjectsFromArray:pingArray];
        }
    }
    
    [trendsTab reloadData];
}

#pragma mark    - UITableView  Deletate和Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return userArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float height = 0.0;
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    height = cell.frame.size.height;
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
    if (indexPath.row == 0) {
        //用户界面
        UIView *userView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 35)];
        userView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:userView];
        
        //内容界面
        NSString *wcontent = [dic objectForKey:@"content"];
        NSString *content = [NSString stringWithFormat:@"%@",wcontent];
        UIFont *cfont = [UIFont systemFontOfSize:15];;
        CGSize csize = [self sizeForString:content font:cfont size:CGSizeMake(250, 1000)];
        if ([[dic objectForKey:@"content"] isKindOfClass:[NSNull class]]) {
            csize.height = 0.0;
        }
        UIView *contentview = [[UIView alloc] initWithFrame:CGRectMake(0, userView.frame.size.height, Screen_Width, csize.height)];
        contentview.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:contentview];
        
        //图片界面
        NSArray * picArray;
        if (![[dic objectForKey:@"photolist"] isKindOfClass:[NSNull class]]) {
            picArray =  [[dic objectForKey:@"photolist"] componentsSeparatedByString:@","];
        }
        float pictureHeight = 0;
        int picNum = 0;
        if (picArray.count>1) {
            picNum = picArray.count;
            int h = (picArray.count/3)+1;
            if (picArray.count == 9) {
                h = 3;
            }
            if (picArray.count == 3) {
                h=1;
            }
            if (picArray.count == 6) {
                h=2;
            }
            pictureHeight = 10+81*h;
        }
        else{
            pictureHeight = 0;
        }
        
        UIView *pictureView = [[UIView alloc] initWithFrame:CGRectMake(0, userView.frame.size.height+contentview.frame.size.height, Screen_Width, pictureHeight)];
        pictureView.backgroundColor = [UIColor whiteColor];
        if(pictureHeight>0)
            [cell.contentView addSubview:pictureView];
        NSString * jid = [NSString stringWithFormat:@"%@%@",[dic objectForKey:@"pubuserid"],@"@ab-insurance.com"];
        UserInfo *userInfo = [UserInfoCRUD queryUserInfo:jid myJID:MY_JID];
        NSString * name = userInfo.nickName;
        NSString * avatar = userInfo.avatar ? userInfo.avatar : @"";
        NSString * headUrl = [NSString stringWithFormat:@"http://183.136.198.235:7500/v1/tfs/%@",avatar];
        /*用户界面*/
        //用户头像
        UIImageView *userImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
        userImage.backgroundColor = RGBACOLOR(238, 238, 238, 1);
        [userImage.layer setCornerRadius:2];
        [userImage setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:nil];
        [userImage.layer setMasksToBounds:YES];
        userImage.userInteractionEnabled = YES;
        userImage.tag = indexPath.row;
        [cell.contentView addSubview:userImage];
        
        //昵称
        NSString *nick = @"用户昵称                        ";
        CGSize nsize = [self sizeForString:nick font:[UIFont systemFontOfSize:14] size:CGSizeMake(Screen_Width-120, 20)];
        UILabel *lblNick= [[UILabel alloc] initWithFrame:CGRectMake(60, 12, nsize.width, 20)];
        lblNick.textColor = RGBACOLOR(96, 116, 169, 1);
        lblNick.font = [UIFont systemFontOfSize:16.0f];
        lblNick.text = name;
        lblNick.backgroundColor = [UIColor clearColor];
        [userView addSubview:lblNick];
        
        /*内容界面*/
        //内容
        UILabel *lblContent = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 250, csize.height)];
        lblContent.font = cfont;
        lblContent.textColor = RGBACOLOR(34, 34, 34, 1);
        lblContent.text = content;
        lblContent.numberOfLines = 0;
        lblContent.backgroundColor = [UIColor clearColor];
        [contentview addSubview:lblContent];
        
        /*图片界面*/
        
        float ox=60,oy=10;
        for(int i=0;i<picNum;i++){
            CHImageWithDataView *imgPicture = [[CHImageWithDataView alloc] initWithFrame:CGRectMake(ox, oy, 71, 71)];
            ox += 81;
            if(ox>230){
                ox = 60;
                oy += 84;
            }
            imgPicture.userInteractionEnabled = YES;
            imgPicture.imgUrl = [picArray objectAtIndex:i];
            imgPicture.num = i;
            imgPicture.tag = indexPath.row;
            UITapGestureRecognizer *picTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(picSingleTap:)];
            [picTapGesture setNumberOfTapsRequired:1];
            [imgPicture addGestureRecognizer:picTapGesture];
            
            [imgPicture setImageWithURL:[NSURL URLWithString:[picArray objectAtIndex:i]] placeholderImage:nil];
            imgPicture.backgroundColor = RGBACOLOR(246, 243, 238, 1);
            [pictureView addSubview:imgPicture];
        }
        
        CGRect rect = cell.frame;
        rect.size.height = contentview.frame.origin.y+contentview.frame.size.height+pictureHeight+20+30;
        if (picArray.count == 1) {
            rect.size.height = contentview.frame.origin.y+contentview.frame.size.height+pictureHeight+20+30+163;
        }
        cell.frame = rect;
        
        if (picArray.count == 1) {
            CHImageWithDataView * oneImage = [[CHImageWithDataView alloc]initWithFrame:CGRectMake(60, cell.frame.size.height-205, 114, 153)];
            oneImage.imgUrl = [picArray objectAtIndex:0];
            oneImage.num = 1;
            oneImage.tag = indexPath.row;
            oneImage.userInteractionEnabled = YES;
            oneImage.backgroundColor = RGBACOLOR(246, 243, 238, 1);
            UITapGestureRecognizer *picTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(picSingleTap:)];
            [picTapGesture setNumberOfTapsRequired:1];
            [oneImage addGestureRecognizer:picTapGesture];
            [oneImage setImageWithURL:[NSURL URLWithString:[picArray objectAtIndex:0]] placeholderImage:nil];
            [cell.contentView addSubview:oneImage];
        }
        NSArray * pingArray;
        if (![[dic objectForKey:@"pldetails"] isKindOfClass:[NSNull class]]) {
            pingArray = [dic objectForKey:@"pldetails"];
        }
        NSArray * zanArray;
        if (![[dic objectForKey:@"zanlist"] isKindOfClass:[NSNull class]]) {
            zanArray = [dic objectForKey:@"zanlist"];
        }
        NSString * zanStr = [NSString stringWithFormat:@"%lu",(unsigned long)zanArray.count];
        NSString * pingStr = [NSString stringWithFormat:@"%lu",(unsigned long)pingArray.count];
        
        NSMutableArray * sonNameArray = [[NSMutableArray alloc]initWithCapacity:0];
        NSString * zanNameString;
        NSString * isMyZan;
        if (zanArray.count>0) {
            for (int i=0; i<zanArray.count; i++) {
                NSDictionary * sonDic = [zanArray objectAtIndex:i];
                NSString * sonjid = [NSString stringWithFormat:@"%@%@",[sonDic objectForKey:@"nick"],@"@ab-insurance.com"];
                UserInfo * sonuserInfo = [UserInfoCRUD queryUserInfo:sonjid myJID:MY_JID];
                NSString * sonname = sonuserInfo.nickName;
                [sonNameArray addObject:sonname];
                if ([[sonDic objectForKey:@"nick"] isEqualToString:MY_USER_NAME]) {
                    isMyZan = @"1";
                }
            }
            zanNameString = [sonNameArray componentsJoinedByString:@","];
        }
        
        //点赞
        FQButtonWithNum * zanBtn = [FQButtonWithNum buttonWithType:UIButtonTypeCustom];
        zanBtn.frame = CGRectMake(60, cell.frame.size.height-40, 72, 28);
        [zanBtn.layer setMasksToBounds:YES];
        [zanBtn.layer setCornerRadius:3.0];
        zanBtn.tag = indexPath.row;
        zanBtn.backgroundColor = RGBACOLOR(246, 243, 238, 1);
        UIImageView * zanImage = [[UIImageView alloc]initWithFrame:CGRectMake(25, 6, 18, 16)];
        zanImage.image = [UIImage imageNamed:@"icon_circle_like.png"];
        if ([isMyZan isEqualToString:@"1"]) {
            zanImage.image = [UIImage imageNamed:@"icon_circle_liked.png"];
        }
        [zanBtn addSubview:zanImage];
        zanBtn.numLabel = [[UILabel alloc]initWithFrame:CGRectMake(48, 4, 22, 20)];
        zanBtn.numLabel.backgroundColor = [UIColor clearColor];
        zanBtn.numLabel.font = [UIFont systemFontOfSize:14];
        zanBtn.numLabel.textColor = RGBACOLOR(191, 187, 178, 1);
        if (![zanStr isEqualToString:@"0"]) {
            zanBtn.numLabel.text = zanStr;
        }
        [zanBtn addSubview:zanBtn.numLabel];
        [zanBtn addTarget:self action:@selector(zanAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:zanBtn];
        //评论
        FQButtonWithNum * pingBtn = [FQButtonWithNum buttonWithType:UIButtonTypeCustom];
        pingBtn.frame = CGRectMake(152, cell.frame.size.height-40, 72, 28);
        [pingBtn.layer setMasksToBounds:YES];
        [pingBtn.layer setCornerRadius:3.0];
        pingBtn.tag = indexPath.row;
        pingBtn.backgroundColor = RGBACOLOR(246, 243, 238, 1);
        UIImageView * pingImage = [[UIImageView alloc]initWithFrame:CGRectMake(25, 6, 18, 16)];
        pingImage.image = [UIImage imageNamed:@"icon_circle_comment.png"];
        [pingBtn addSubview:pingImage];
        pingBtn.numLabel = [[UILabel alloc]initWithFrame:CGRectMake(48, 4, 22, 20)];
        pingBtn.numLabel.backgroundColor = [UIColor clearColor];
        pingBtn.numLabel.font = [UIFont systemFontOfSize:14];
        pingBtn.numLabel.textColor = RGBACOLOR(191, 187, 178, 1);
        if (![pingStr isEqualToString:@"0"]) {
            pingBtn.numLabel.text = pingStr;
        }
        [pingBtn addSubview:pingBtn.numLabel];
        [pingBtn addTarget:self action:@selector(pingAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:pingBtn];
        //删除
        UIButton * deleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleButton.frame = CGRectMake(244, cell.frame.size.height-40, 50, 28);
        UIImageView * deleImage = [[UIImageView alloc]initWithFrame:CGRectMake(17, 6, 16, 16)];
        deleImage.image = [UIImage imageNamed:@"my_icon_delete.png"];
        [deleButton addSubview:deleImage];
        deleButton.backgroundColor = RGBACOLOR(246, 243, 238, 1);
        deleButton.tag = indexPath.row;
        deleButton.hidden = YES;
        [deleButton addTarget:self action:@selector(deleAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleButton];
        if ([[dic objectForKey:@"pubuserid"] isEqualToString:MY_USER_NAME]) {
            deleButton.hidden = NO;
        }
        
        //赞的昵称显示
        if (zanNameString.length>0) {
            UIImageView * iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(60, rect.size.height+4, 12, 11)];
            iconImage.image = [UIImage imageNamed:@"icon_circle_like_s.png"];
            [cell.contentView addSubview:iconImage];
            
            UIFont *newfont = [UIFont systemFontOfSize:15];;
            CGSize newsize = [self sizeForString:zanNameString font:newfont size:CGSizeMake(230, 1000)];
            UILabel *newlblContent = [[UILabel alloc] initWithFrame:CGRectMake(80, rect.size.height, 230, newsize.height)];
            newlblContent.font = newfont;
            newlblContent.textColor = RGBACOLOR(96, 120, 166, 1);
            newlblContent.text = zanNameString;
            newlblContent.numberOfLines = 0;
            newlblContent.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:newlblContent];
            
            rect.size.height = rect.size.height + newsize.height + 10;
        }
        
        cell.frame = rect;
        
        //时间
        UILabel *lblTime= [[UILabel alloc] initWithFrame:CGRectMake(60, 14, Screen_Width-70, 20)];
        lblTime.textAlignment = NSTextAlignmentRight;
        lblTime.text = [dic objectForKey:@"pubtime"];
        lblTime.textColor = RGBACOLOR(151, 151, 151, 1);
        lblTime.font = [UIFont systemFontOfSize:13.0f];
        lblTime.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lblTime];

    }
    else{
        UIImageView * iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(60, 4, 12, 11)];
        iconImage.image = [UIImage imageNamed:@"icon_circle_comment_s.png"];
        iconImage.hidden = YES;
        if (indexPath.row == 1) {
            iconImage.hidden = NO;
        }
        [cell.contentView addSubview:iconImage];
        NSString * pingString;
        NSString * contentStr = [dic objectForKey:@"content"];
        contentStr = [self userTextMessage:contentStr];
        NSString * jid = [NSString stringWithFormat:@"%@%@",[dic objectForKey:@"usersrc"],@"@ab-insurance.com"];
        UserInfo *userInfo = [UserInfoCRUD queryUserInfo:jid myJID:MY_JID];
        NSString * oneName = userInfo.nickName;
        if ([[dic objectForKey:@"userdest"] isKindOfClass:[NSNull class]] || [[dic objectForKey:@"userdest"] isEqualToString:@"空"]) {
            //oneName
            pingString = [NSString stringWithFormat:@"%@:%@",oneName,contentStr];
        }
        else{
            //oneName [dic objectForKey:@"userdest"]
            NSString * jid = [NSString stringWithFormat:@"%@%@",[dic objectForKey:@"userdest"],@"@ab-insurance.com"];
            UserInfo *userInfo = [UserInfoCRUD queryUserInfo:jid myJID:MY_JID];
            NSString * twoName = userInfo.nickName;
            pingString = [NSString stringWithFormat:@"%@回复%@:%@",oneName,twoName,contentStr];
        }
        UIFont *cfont = [UIFont systemFontOfSize:15];;
        CGSize csize = [self sizeForString:pingString font:cfont size:CGSizeMake(Screen_Width-90, 1000)];
        UILabel *lblContent = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, Screen_Width-90, csize.height)];
        lblContent.font = cfont;
        lblContent.textColor = RGBACOLOR(34, 34, 34, 1);
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:pingString];
        if ([[dic objectForKey:@"userdest"] isKindOfClass:[NSNull class]] || [[dic objectForKey:@"userdest"] isEqualToString:@"空"]) {
            [str addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(96, 120, 166, 1) range:NSMakeRange(0, [oneName length]+1)];
        }else{
            [str addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(96, 120, 166, 1) range:NSMakeRange(0, [oneName length])];
            NSString *huifu = [NSString stringWithFormat:@"%@回复",oneName];
            NSString * jid = [NSString stringWithFormat:@"%@%@",[dic objectForKey:@"userdest"],@"@ab-insurance.com"];
            UserInfo *userInfo = [UserInfoCRUD queryUserInfo:jid myJID:MY_JID];
            NSString * twoName = userInfo.nickName;
            [str addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(96, 120, 166, 1) range:NSMakeRange([huifu length], [twoName length]+1)];
        }
        
        
        lblContent.attributedText = str;
        lblContent.numberOfLines = 0;
        lblContent.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lblContent];
        
        CGRect rect = cell.frame;
        rect.size.height = lblContent.frame.origin.y+lblContent.frame.size.height+5;
        cell.frame = rect;
        if (indexPath.row == 2) {
            if ([oneString isEqualToString:@"1"]) {
                iconImage.hidden = NO;
            }
        }
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row>0) {
        NSDictionary * dic = [userArray objectAtIndex:indexPath.row];
        biaoJiDic = dic;
        currentNum = indexPath.row;
        NSString * formID = [dic objectForKey:@"usersrc"];
        if (![formID isEqualToString:MY_USER_NAME]) {
            NSString * jid = [NSString stringWithFormat:@"%@%@",[dic objectForKey:@"usersrc"],@"@ab-insurance.com"];
            UserInfo *userInfo = [UserInfoCRUD queryUserInfo:jid myJID:MY_JID];
            NSString * twoName = userInfo.nickName;
            //回复评论
            huiFuString = @"1";
            toolBar.frame = CGRectMake(0, Screen_Height-[DXMessageToolBar defaultHeight], Screen_Width, [DXMessageToolBar defaultHeight]);
            trendsTab.frame = CGRectMake(0, 0, Screen_Width, mainView.frame.size.height-[DXMessageToolBar defaultHeight]);
            toolBar.inputTextView.placeHolder = [NSString stringWithFormat:@"回复%@",twoName];
        }
        else{
            UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"取消"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"删除",nil];
            menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [menu showInView:self.view];
        }
    }
}

//删除说说
-(void)deleAction:(UIButton *)button
{
    //提交操作
    NSString * string = @"http://104.238.236.144//cfapi/del";
    NSMutableDictionary * paeaments = [NSMutableDictionary dictionary];
    [paeaments setObject:@"1" forKey:@"type"];
    [paeaments setObject:[self.detailDic objectForKey:@"textid"] forKey:@"value"];
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    [manager POST:string parameters:paeaments success:^(AFHTTPRequestOperation * operation, id responseObject){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSDictionary * resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if ([[resultDic objectForKey:@"error"] isKindOfClass:[NSNull class]]) {
            [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d",self.curDicIndex] forKey:@"Dele_shuo"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation,NSError * orrer){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //删除评论
        [self deletePingData];
    }
}
//删除评论
-(void)deletePingData
{
    NSMutableArray * pingArray = [[NSMutableArray alloc]initWithCapacity:0];
    [pingArray addObjectsFromArray:[self.detailDic objectForKey:@"pldetails"]];
    //提交操作
    NSString * string = @"http://104.238.236.144//cfapi/del";
    NSMutableDictionary * paeaments = [NSMutableDictionary dictionary];
    [paeaments setObject:@"2" forKey:@"type"];
    [paeaments setObject:[biaoJiDic objectForKey:@"rpid"] forKey:@"value"];
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    [manager POST:string parameters:paeaments success:^(AFHTTPRequestOperation * operation, id responseObject){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSDictionary * resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if ([[resultDic objectForKey:@"error"] isKindOfClass:[NSNull class]]) {
            isChange = YES;
            [pingArray removeObject:biaoJiDic];
            //更新数据字典
            NSMutableDictionary * newDic = [NSMutableDictionary dictionaryWithDictionary:self.detailDic];
            [newDic setObject:pingArray forKey:@"pldetails"];
            self.detailDic = newDic;
            //刷新数据
            [userArray removeAllObjects];
            [userArray addObject:self.detailDic];
            [self sonArrayData];
            [trendsTab reloadData];
            NSIndexPath *indexPath_1=[NSIndexPath indexPathForRow:currentNum inSection:0];
            NSArray *indexArray=[NSArray arrayWithObject:indexPath_1];
            [trendsTab reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
        }
    } failure:^(AFHTTPRequestOperation *operation,NSError * orrer){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}


-(void)zanAction:(FQButtonWithNum *)btn
{
    NSString * zanType;
    NSDictionary * dic = [userArray objectAtIndex:btn.tag];
    NSMutableDictionary * muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    NSMutableArray * zanArray = [[NSMutableArray alloc]initWithCapacity:0];
    if (![[muDic objectForKey:@"zanlist"] isKindOfClass:[NSNull class]]) {
        [zanArray addObjectsFromArray:[muDic objectForKey:@"zanlist"]];
    }
    //判断是否点赞
    if (zanArray.count == 0) {
        zanType = @"0";
    }
    else{
        for (int i=0; i<zanArray.count; i++) {
            NSDictionary * useDic = [zanArray objectAtIndex:i];
            if ([[useDic objectForKey:@"nick"] isKindOfClass:[NSString class]]) {
                if ([[useDic objectForKey:@"nick"] isEqualToString:MY_USER_NAME]) {
                    zanType = @"1";
                }
                else{
                    zanType = @"0";
                }
            }
        }
    }
    //提交操作
    NSString * string = @"http://104.238.236.144//cfapi/claim";
    NSMutableDictionary * paeaments = [NSMutableDictionary dictionary];
    [paeaments setObject:zanType forKey:@"zantype"];
    [paeaments setObject:[dic objectForKey:@"textid"] forKey:@"textid"];
    [paeaments setObject:MY_USER_NAME forKey:@"usersrc"];
    [paeaments setObject:[dic objectForKey:@"pubuserid"] forKey:@"userdest"];
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    [manager POST:string parameters:paeaments success:^(AFHTTPRequestOperation * operation, id responseObject){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSDictionary * resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if ([[resultDic objectForKey:@"error"] isKindOfClass:[NSNull class]]) {
            isChange = YES;
            //点赞成功操作
            if ([zanType isEqualToString:@"0"]) {
                NSMutableDictionary * zanDic = [NSMutableDictionary dictionary];
                [zanDic setObject:MY_USER_NAME forKey:@"nick"];
                [zanArray addObject:zanDic];
                [muDic setObject:zanArray forKey:@"zanlist"];
                self.detailDic = muDic;
            }
            //取消点赞成功操作
            else{
                NSMutableDictionary * zanDic = [NSMutableDictionary dictionary];
                [zanDic setObject:MY_USER_NAME forKey:@"nick"];
                [zanArray removeObject:zanDic];
                [muDic setObject:zanArray forKey:@"zanlist"];
                self.detailDic = muDic;
            }
            //刷新数据
            [userArray removeAllObjects];
            [userArray addObject:self.detailDic];
            [self sonArrayData];
            [trendsTab reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation,NSError * orrer){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    
}
-(void)pingAction:(FQButtonWithNum *)btn
{
    toolBar.frame = CGRectMake(0, Screen_Height-[DXMessageToolBar defaultHeight], Screen_Width, [DXMessageToolBar defaultHeight]);
    trendsTab.frame = CGRectMake(0, 0, Screen_Width, mainView.frame.size.height-[DXMessageToolBar defaultHeight]);
}

#pragma mark --------DXMessageToolBarDelegate--------
-(void)inputTextViewDidBeginEditing:(XHMessageTextView *)messageInputTextView
{
    [_menuController setMenuItems:nil];
}

//发送文字
-(void)didSendText:(NSString *)text
{
    toolBar.faceView.frame = CGRectMake(0, Screen_Height-320, Screen_Width, 216) ;
    [UIView animateWithDuration:0.3 animations:^{
        toolBar.frame = CGRectMake(0, Screen_Height-[DXMessageToolBar defaultHeight], Screen_Width, [DXMessageToolBar defaultHeight]);
        toolBar.faceView.frame = CGRectMake(0, Screen_Height-216, Screen_Width, 216);
    }];
    if (text && text.length>0) {
        //发送文字做一级处理，如包含表情，则映射表情
        [self sendTextMeaasge:text];
    }
}
//处理文字表情映射
-(void)sendTextMeaasge:(NSString *)textMessage
{
    NSString *willSendText = [ConvertToCommonEmoticonsHelper convertToCommonEmoticons:textMessage];
    [self sendText:willSendText];
    
}
//表情逆映射
-(NSString *)userTextMessage:(NSString *)text
{
    NSString * willXianText = [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:text];
    return willXianText;
}

//发送文字
#pragma mark - send message
- (void)sendText:(NSString *)content
{
    NSMutableArray * pingArray = [[NSMutableArray alloc]initWithCapacity:0];
    if (![[self.detailDic objectForKey:@"pldetails"] isKindOfClass:[NSNull class]]) {
        [pingArray addObjectsFromArray:[self.detailDic objectForKey:@"pldetails"]];
    }
    //提交操作
    NSString * string = @"http://104.238.236.144//cfapi/comment";
    NSMutableDictionary * paeaments = [NSMutableDictionary dictionary];
    [paeaments setObject:@"0" forKey:@"commtype"];
    [paeaments setObject:[self.detailDic objectForKey:@"textid"] forKey:@"textid"];
    [paeaments setObject:content forKey:@"content"];
    [paeaments setObject:MY_USER_NAME forKey:@"usersrc"];
    [paeaments setObject:@"" forKey:@"userdest"];
    if ([huiFuString isEqualToString:@"1"]) {
        [paeaments setObject:[biaoJiDic objectForKey:@"usersrc"] forKey:@"userdest"];
        [paeaments setObject:@"1" forKey:@"commtype"];
    }
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    [manager POST:string parameters:paeaments success:^(AFHTTPRequestOperation * operation, id responseObject){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSDictionary * resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if ([[resultDic objectForKey:@"error"] isKindOfClass:[NSNull class]]) {
            isChange = YES;
            //拼接新字典
            NSMutableDictionary * muDic = [NSMutableDictionary dictionary];
            [muDic setObject:content forKey:@"content"];
            [muDic setObject:@"0" forKey:@"type"];
            [muDic setObject:MY_USER_NAME forKey:@"usersrc"];
            [muDic setObject:@"空" forKey:@"userdest"];
            [muDic setObject:[resultDic objectForKey:@"data"] forKey:@"rpid"];
            if ([huiFuString isEqualToString:@"1"]) {
                [muDic setObject:[biaoJiDic objectForKey:@"usersrc"] forKey:@"userdest"];
                [muDic setObject:@"1" forKey:@"type"];
            }
            
            [pingArray addObject:muDic];
            //更新数据字典
            NSMutableDictionary * newDic = [NSMutableDictionary dictionaryWithDictionary:self.detailDic];
            [newDic setObject:pingArray forKey:@"pldetails"];
            self.detailDic = newDic;
            //刷新数据
            [userArray removeAllObjects];
            [userArray addObject:self.detailDic];
            [self sonArrayData];
            [trendsTab reloadData];
            [trendsTab scrollToRowAtIndexPath:
             [NSIndexPath indexPathForRow:[userArray count]-1 inSection:0]
                                      atScrollPosition: UITableViewScrollPositionBottom
                                              animated:YES];
            
            huiFuString = @"2";
        }
    } failure:^(AFHTTPRequestOperation *operation,NSError * orrer){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
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

//图片点击事件
-(void)picSingleTap:(UIGestureRecognizer *)gesture
{
    CHImageWithDataView * imgView = (CHImageWithDataView *)gesture.view;
    
    // Browser
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    BOOL displayActionButton = NO;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = NO;
    BOOL startOnGrid = NO;
    // Photos
    NSDictionary * dic = [userArray objectAtIndex:gesture.view.tag];
    NSArray * picArray = [[dic objectForKey:@"photolist"] componentsSeparatedByString:@","];
    for (int i=0; i<picArray.count; i++) {
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:[picArray objectAtIndex:i]]];
        [photos addObject:photo];
        [thumbs addObject:photo];
    }
    // Options
    self.photos = photos;
    self.thumbs = thumbs;
    //
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;//分享按钮,默认是
    browser.displayNavArrows = displayNavArrows;//左右分页切换,默认否
    browser.displaySelectionButtons = displaySelectionButtons;//是否显示选择按钮在图片上,默认否
    browser.alwaysShowControls = displaySelectionButtons;//控制条件控件 是否显示,默认否
    browser.zoomPhotosToFill = NO;//是否全屏,默认是
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        browser.wantsFullScreenLayout = YES;//是否全屏
#endif
    browser.enableGrid = enableGrid;//是否允许用网格查看所有图片,默认是
    browser.startOnGrid = startOnGrid;//是否第一张,默认否
    browser.enableSwipeToDismiss = YES;
    [browser showNextPhotoAnimated:YES];
    [browser showPreviousPhotoAnimated:YES];
    [browser setCurrentPhotoIndex:imgView.num];
    //    [self presentViewController:browser animated:YES completion:nil];
    [self.navigationController pushViewController:browser animated:NO];
}

//图片浏览器
#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)navLeftBtnAction:(UIButton *)btn
{
//    if (isChange == YES) {
//        NSMutableDictionary * muDic = [NSMutableDictionary dictionary];
//        NSData * data = [self.detailDic JSONData];
//        [muDic setObject:@"1" forKey:@"isGengxin"];
//        [muDic setObject:[NSString stringWithFormat:@"%d",self.curDicIndex] forKey:@"curDic_index"];
//        [muDic setObject:data forKey:@"dic_data"];
//        
//        [[NSUserDefaults standardUserDefaults]setObject:muDic forKey:@"change_dic"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)navRightBtnAction:(UIButton *)btn
{
    FaBuQuanViewController * fvc = [[FaBuQuanViewController alloc]init];
    [self.navigationController pushViewController:fvc animated:YES];
}

// 点击背景隐藏
-(void)keyBoardHidden
{
    [toolBar endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
