//
//  ContactInfo.m
//  anbang_ios
//
//  Created by appdor on 3/26/15.
//  Copyright (c) 2015 ch. All rights reserved.
//

#import "ContactInfo.h"
#import "AIPerssionSettingViewController.h"
#import "UIImageView+WebCache.h"
#import "UserInfoCRUD.h"
#import "UserInfo.h"
#import "ChatViewController2.h"
#import "ContactsCRUD.h"
#import "MyServices.h"
#import "ChatInit.h"
#import "ContactImage.h"
#import "Contacts.h"
#import "AINavigationController.h"
#import "AIUIWebViewController.h"
#import "AIFriendProvingViewController.h"
#import "AIAreaCRUD.h"
#import "AIHttpTool.h"
#import "UIImageView+WebCache.h"
#import "AIFriendPrivilegeCRUD.h"

@interface ContactInfo () <UINavigationControllerDelegate>
{
    IBOutlet UIScrollView *sclView;
    IBOutlet UITableView *tableView;
    
    UIImage *placeHolderImage;
    IBOutlet UIImageView *photoView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UIImageView *genderView;
    IBOutlet UIImageView *isEmployeeView;
    IBOutlet UILabel *nickNameLabel;
    IBOutlet UILabel *communityIdLabel;
    IBOutlet UIButton *sendMsg;
    IBOutlet UIButton *call;
    IBOutlet UIButton *makeFriend;
    IBOutlet UIActivityIndicatorView *indecator;
    
    IBOutlet UIButton *showTrace;
    
    UserInfo *contact;
    UserInfo *me;
    BOOL isFriend;
    
    CGFloat _cell_H; // 个人资料中cell的高
    enum
    {
        Normal = 1,
        Employee = 2
    } AccountType;
    
    enum
    {
        NotDefined,
        Male,
        Female
    } Gender;
    

}
@end

@implementation ContactInfo

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    JLLog_I(@"<class=%@, object=%p> dealloc", [self class], self);
}

- (void)setJid:(NSString *)aId
{
    _jid = aId; //useful
    contact = [UserInfoCRUD queryUserInfo:aId myJID:MY_JID];
    me = [UserInfo loadArchive];
    isFriend = [aId isEqualToString:MY_JID] ? YES : ([ContactsCRUD queryContactsCountId:aId myJID:MY_JID] == 1);
}
- (void)render
{
    [photoView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ResourcesURL,contact.avatar]] placeholderImage:placeHolderImage];
    
    nameLabel.textColor = AB_Color_403b36;
    nameLabel.text = ![StrUtility isBlankString:contact.remarkName] ? contact.remarkName : contact.nickName;
    if (contact.gender == Male) {
        [genderView setImage:[UIImage imageNamed:@"icon_sex_male"]];
    } else if (contact.gender == Female){
        [genderView setImage:[UIImage imageNamed:@"icon_sex_female"]];
    } else {
        [genderView removeFromSuperview];
    }
    if (contact.accountType == Employee) {
        [isEmployeeView setImage:[UIImage imageNamed:@"icon_ab01"]];
    } else {
        [isEmployeeView removeFromSuperview];
    }
    
    nickNameLabel.text = [NSString stringWithFormat:@"昵称: %@", contact.nickName];
    nickNameLabel.hidden = [StrUtility isBlankString:contact.remarkName];
    
    communityIdLabel.text = [NSString stringWithFormat:@"社区ID: %@", contact.accountName];
    communityIdLabel.hidden = (![self beAbleToSeeJid] || [StrUtility isBlankString:contact.accountName]);
    
    if (![self needToShowEmployeeInfo]) {
        //        [tableView removeFromSuperview];
        //height.constant = 88 ;
        
        NSLog(@"height.constant = %f",height.constant);
    }
    

    
    sendMsg.layer.cornerRadius = 6.0f;
    call.layer.cornerRadius = 6.0f;
    call.layer.borderWidth = 0.5;
    call.layer.borderColor = Normal_Border_Color.CGColor;
    makeFriend.layer.cornerRadius = 6.0f;
    [makeFriend setBackgroundColor:AB_Color_e55a39];
    
    if (![self beAbleToSendMsg]) {
        [sendMsg removeFromSuperview];
        [call removeFromSuperview];
    }
    
    if (isFriend) {
        [makeFriend removeFromSuperview];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"NNC_UpdateContact" object:nil];
    
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"通讯录"
                                                                                   target:self
                                                                                   action:@selector(pop)]];
    
    
    [self reloadData];
}

- (void) reloadData
{
    if(_userinfo != nil){
        contact = _userinfo;
        me = [UserInfo loadArchive];
        isFriend = [contact.jid isEqualToString:MY_JID] ? YES : ([ContactsCRUD queryContactsCountId:contact.jid myJID:MY_JID] == 1);
        
    }
    contact.remarkName = [ContactsCRUD queryContactsRemarkName:contact.jid];
    // Do any additional setup after loading the view from its nib.
    if(isFriend) {
        [self setupNavigationItem];
    }
    placeHolderImage = [UIImage imageNamed:@"defaultUser.png"];
    
    tableView.separatorColor = AB_Color_f4f0eb;
    
    //设置发消息和打电话按钮图片及位置
    [sendMsg setImage:[UIImage imageNamed:@"chat_data_icon_mes"] forState:UIControlStateNormal];
    [sendMsg setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
    [sendMsg setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    
    [call setTitleColor:AB_Color_9c958a forState:UIControlStateNormal];
    [call setImage:[UIImage imageNamed:@"chat_data_icon_call"] forState:UIControlStateNormal];
    [call setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
    [call setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    
    
    [self render];
}

- (void)setupNavigationItem
{
    if (!self.rightBarButtonHidden) {
        AIImageBarButtonItem *item = [[AIImageBarButtonItem alloc] initWithImageNamed:@"header_button_set"
                                                                               target:self
                                                                               action:@selector(push)];
        self.navigationItem.rightBarButtonItem = item;
    }
}

- (void)push
{
    AIPerssionSettingViewController *controller = [[AIPerssionSettingViewController alloc] init];
    controller.jid = self.jid;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)pop
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMsg:(id)sender
{
    ChatViewController2 * chatViewCtl=[[ChatViewController2 alloc]init];
    chatViewCtl.chatWithUser = [StrUtility subJIDStr:contact.jid];
    chatViewCtl.chatWithNick = contact.nickName;
    chatViewCtl.chatWithJID  = contact.jid;
    chatViewCtl.remarkName = nameLabel.text;
    chatViewCtl.title = nameLabel.text;
    
#pragma mark
#pragma mark start transition
    
    AINavigationController *controller = self.tabBarController.viewControllers[0];
    if (self.navigationController != controller) {
        
        ChatViewController2 *chatViewCtl_02 = [[ChatViewController2 alloc] init];
        chatViewCtl_02.chatWithUser = chatViewCtl.chatWithUser;
        chatViewCtl_02.chatWithNick = chatViewCtl.chatWithNick;
        chatViewCtl_02.chatWithJID = chatViewCtl.chatWithJID;
        chatViewCtl_02.remarkName = chatViewCtl.remarkName;
        chatViewCtl_02.title = chatViewCtl.title;
        
        chatViewCtl_02.hidesBottomBarWhenPushed = YES;
        chatViewCtl.hidesBottomBarWhenPushed = YES;
        
        self.navigationController.delegate = self;
        [controller pushViewController :chatViewCtl_02 animated:YES];
    }
    [self.navigationController pushViewController:chatViewCtl animated:YES];
    
#pragma mark end
}

#pragma mark
#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    self.navigationController.delegate = NULL;
    self.tabBarController.selectedIndex = 0;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark end


- (void)rebone
{
    UINavigationController *nav = self.navigationController;
    [nav popViewControllerAnimated:NO];

    ContactInfo *newContactInfo = [[ContactInfo alloc] initWithNibName:@"ContactInfo" bundle:nil];
    newContactInfo.jid = contact.jid;
    newContactInfo.userinfo = contact;
    newContactInfo.hidesBottomBarWhenPushed = YES;
    
    [nav pushViewController:newContactInfo animated:NO];
}

- (IBAction)dial:(id)sender{
#if TARGET_IPHONE_SIMULATOR
    UINavigationController *nav = self.navigationController;
    [nav popViewControllerAnimated:NO];
    
    ContactInfo *newContactInfo = [[ContactInfo alloc] initWithNibName:@"ContactInfo" bundle:nil];
    newContactInfo.jid = contact.jid;
    static int i = 0;
    switch (i++%4) {
        case 0:
            newContactInfo->contact.gender = NotDefined;
            newContactInfo->contact.accountType = Normal;
            newContactInfo->me.accountType = Employee;
            break;
        case 1:
            newContactInfo->contact.gender = Female;
            newContactInfo->contact.accountType = Employee;
            newContactInfo->me.accountType = Employee;
            break;
        case 2:
            newContactInfo->contact.gender = Female;
            newContactInfo->contact.accountType = Normal;
            newContactInfo->me.accountType = Normal;
            break;
        case 3:
            newContactInfo->contact.gender = NotDefined;
            newContactInfo->contact.accountType = Employee;
            newContactInfo->me.accountType = Normal;
            break;
        default:
            break;
    }
    
    newContactInfo.hidesBottomBarWhenPushed = YES;
    [nav pushViewController:newContactInfo animated:NO];
#else
    [MyServices playDial:contact.jid name:contact.nickName avatar:contact.avatar target:self];
#endif
}

- (IBAction)makeFriend{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(rebone)
//                                                 name:@"ContactInserted"
//                                               object:nil];
//    [ChatInit queryContactsUserInfo:contact.jid];
//    [indecator startAnimating];
//    makeFriend.enabled = NO;
    AIFriendProvingViewController *controller = [[AIFriendProvingViewController alloc] init];
    controller.jid = self.jid;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)proving {
    AIFriendProvingViewController *controller = [[AIFriendProvingViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            
        case 1:
            return 10;
            
        case 2:
            return 1;
            
        default:
            return 0;
    }
}

- (void)syncPrivilegeView
{
    NSString *urlString = ({
        NSString *usersrc = [self.jid componentsSeparatedByString:@"@"][0];
        [NSString stringWithFormat:@"%@?usersrc=%@&userdest=%@",
         AIFriendCirclePrivilegeViewURLString,
         MY_USER_NAME,
         usersrc];
    });
    
    [AIHttpTool getWithURL:urlString
                    params:nil success:^(id json) {
                        NSDictionary *data = (NSDictionary *)json;
                        NSString *view1 = data[@"view1"];
                        NSString *view2 = data[@"view2"];
                    
                        [AIFriendPrivilegeCRUD setValue:view1 withColumnKey:kPrivilegeColoumnHisCircleMark whose:self.jid];
                        [AIFriendPrivilegeCRUD setValue:view2 withColumnKey:kPrivilegeColumnMyCircleLock whose:MY_JID];
                        
                    } failure:^(NSError *error) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                            message:error.localizedDescription
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"知道了"
                                                                  otherButtonTitles:nil, nil];
                        [alertView show];
                    }];
}


- (void)setPhotoLibraryAsserts:(NSArray *)imageViews
{
    [self syncPrivilegeView];
    
    NSString *friendCircle = [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUD_FRIENDCIRCLE_ADDRESS"];
    NSString *urlString = ({
        NSString *usersrc = [self.jid componentsSeparatedByString:@"@"][0];
        [NSString stringWithFormat:@"%@viewphotos?usersrc=%@&userid=%@",
                                     friendCircle,
                                     usersrc,
                                     MY_USER_NAME];
    });

    [AIHttpTool getWithURL:urlString
                    params:nil success:^(id json) {
                        NSArray *photoes = [self pickPhotoes:json];
                        if (photoes.count) {
                            NSInteger i = 0;
                            for (UIImageView *imageView in imageViews) {
                                [imageView setImageWithURL:[NSURL URLWithString:photoes[i]]];
                                ++i;
                            }
                        }
                    } failure:^(NSError *error) {
                        JLLog_I(@"Photoes asserts request failed.");
                    }];
}

- (NSArray *)pickPhotoes:(NSDictionary *)dictioary
{
    NSArray *subArray = dictioary[@"data"];
    if ([subArray isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    NSMutableArray *photoes = [@[] mutableCopy];
    for (NSString *string in subArray) {
        NSString *urlstring = ({
            NSRange range = [string rangeOfString:@"http:"];
            [string substringFromIndex:range.location];
        });
        [photoes addObject:urlstring];
    }
    return photoes;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ID = @"ContactInfo";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:ID];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.textColor = [UIColor colorFromHexString:@"#9c958a"];
        cell.textLabel.font = AB_FONT_15;
        
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        cell.detailTextLabel.textColor = [UIColor colorFromHexString:@"#403b36"];
        cell.detailTextLabel.font = AB_FONT_15;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        
        //这里重新定义一个可以改变frame 坐标的labbel
        if (indexPath.section ==0 && indexPath.row == 2) {
            UILabel *labText = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 80, 20)];
            labText.textColor = AB_Color_9c958a;
            labText.font = AB_FONT_15;
            labText.text =  @"个性签名";
            labText.tag = 33;
            labText.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:labText];
            
        }
        
        if (indexPath.section == 0 && indexPath.row == 1) {
            NSMutableArray *imageViews = [@[] mutableCopy];
            for (NSInteger count = 0; count < 4; ++count) {
                UIImageView *photo = [[UIImageView alloc] init];
                photo.frame = CGRectMake(70 + (count * 55), 14, 50, 50);
                [imageViews addObject:photo];
                [cell.contentView addSubview:photo];
            }
            [self setPhotoLibraryAsserts:imageViews];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
//        cell.detailTextLabel.userInteractionEnabled = YES;
        
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTaped:)];
//        tapGesture.numberOfTapsRequired = 2;
//        [cell.detailTextLabel addGestureRecognizer:tapGesture];
//        
//        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressed:)];
//        longPress.minimumPressDuration = 1.0;
//        [cell.detailTextLabel addGestureRecognizer:longPress];
    }

    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"地区";
                    //TODO
                    cell.detailTextLabel.text = [AIAreaCRUD selectNameForShowWithCode:contact.areaId];
                    break;
                
                case 1:
                    cell.textLabel.text = @"相册";
                    break;
                
                case 2:
                {
                    //原本的textLabel 复制，留够占位空间
                    cell.textLabel.text =  @"个性签名";
                    cell.textLabel.hidden = YES;
                    
                    UILabel *labT = (UILabel *)[cell viewWithTag:33];
                    labT.text =  @"个性签名";
                    CGRect rect = labT.frame ;
                    rect.origin.y = ( _cell_H - 20 ) / 2;
                    labT.frame = rect;
                    
                    
                    cell.detailTextLabel.text = contact.signature ? contact.signature : @"";
                    cell.detailTextLabel.numberOfLines = 2;
                }
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"姓名";
                    cell.detailTextLabel.text = contact.employeeName;
                    break;
                case 1:
                    cell.textLabel.text = @"工号";
                    cell.detailTextLabel.text = contact.employeeCode;
                    break;
                case 2:
                    cell.textLabel.text = @"个人电话";
                    cell.detailTextLabel.text = contact.employeePhone;
                    break;
                case 3:
                    cell.textLabel.text = @"公共电话";
                    cell.detailTextLabel.text = contact.publicPhone;
                    break;
                case 4:
                    cell.textLabel.text = @"办公电话";
                    cell.detailTextLabel.text = contact.officalPhone;
                    break;
                case 5:
                    cell.textLabel.text = @"邮箱";
                    cell.detailTextLabel.text = contact.email;
                    break;
                case 6:
                    cell.textLabel.text = @"主体";
                    cell.detailTextLabel.text = contact.bookName;
                    break;
                case 7:
                    cell.textLabel.text = @"机构";
                    cell.detailTextLabel.text = contact.agencyName;
                    break;
                case 8:
                    cell.textLabel.text = @"部门";
                    cell.detailTextLabel.text = contact.branchName;
                    break;
                case 9:
                    cell.textLabel.text = @"事业部";
                    cell.detailTextLabel.text = contact.departmentName;
                    break;
                    
                default:
                    break;
            }
            break;
        case 2:{
            CGRect rect = showTrace.frame;
            rect.size.width = Screen_Width;
            showTrace.frame = rect;
            [showTrace setTitleColor:AB_Color_1774e6 forState:UIControlStateNormal];
            showTrace.titleLabel.font = AB_FONT_15;
            [cell.contentView addSubview:showTrace];
            break;
        }

            
        default:
            break;
    }

    return cell;
}
- (CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section ==0 && indexPath.row == 2 ) {
        CGRect rect = [contact.signature
                       boundingRectWithSize:CGSizeMake(200, 700)
                        options:NSStringDrawingUsesLineFragmentOrigin
                    attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:15]}
                    context:nil];
        
        //计算文字的高度，如果不到20，让其为44（最小高度为44），如果大于20，在加上上下边距估值为20
        _cell_H = rect.size.height < 20 ? 44 : rect.size.height + 20;

        //没有下面详细信息的情况
        if (![self needToShowEmployeeInfo]) {
            //手动改变tableView的constant 值，该cell高 + 两个headview 的高22 *2 + 7（向下延长7个单位高度）
            height.constant = _cell_H + 44 + 7 + 78.0;
        }else{
            //有详细信息的情况：
            //一共12个cell，每个高为 44 + 一个headView 高 44 + 文字修改的高度_cell_H + 7 留白高度
            CGFloat tabFlo = 44 * 13 + _cell_H + 7 + 78.0;
            height.constant = tabFlo;
        }
        return _cell_H;
    }
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        return 78.0;
    }
    
    return 44;
}
//-(void) doubleTaped:(UITapGestureRecognizer*)recognizer
//{
//    [recognizer.view becomeFirstResponder];
//    UIMenuItem *copyLink = [[UIMenuItem alloc] initWithTitle:@"复制"
//                             
//                                                      action:@selector(copy:)];
//    
//    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:copyLink, nil]];
//    
//    [[UIMenuController sharedMenuController] setTargetRect:recognizer.view.frame inView:self.view];
//    
//    [[UIMenuController sharedMenuController] setMenuVisible:YES animated: YES];
//}
//
//-(void) longPressed:(UILongPressGestureRecognizer*)recognizer
//{
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        [recognizer.view becomeFirstResponder];
//        UIMenuItem *copyLink = [[UIMenuItem alloc] initWithTitle:@"复制"
//                                
//                                                          action:@selector(copy:)];
//        
//        [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:copyLink, nil]];
//        
//        [[UIMenuController sharedMenuController] setTargetRect:recognizer.view.frame inView:self.view];
//        
//        [[UIMenuController sharedMenuController] setMenuVisible:YES animated: YES];
//    }
//}

//针对于响应方法的实现

-(void)copy:(id)sender

{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    
    pboard.string = @"1234";
}

- (BOOL)needToShowEmployeeInfo
{
//    if (isFriend && contact.accountType == Employee){
//        return YES;
//    }
//    
    if (contact.accountType == Employee && me.accountType == Employee) {
        return YES;
    }
    
    return NO;
}

- (BOOL)beAbleToSendMsg
{
    return isFriend || (contact.accountType == Employee && me.accountType == Employee);
}

- (BOOL)beAbleToSeeJid
{
    return isFriend || me.accountType == Employee;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self needToShowEmployeeInfo] ? 3 : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        return @" ";
    }
    
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}

- (IBAction)imageClicked:(id)sender
{
    ContactImage *bigImge = [[ContactImage alloc] initWithNibName:@"ContactImage" bundle:nil];
    bigImge.image = photoView.image;
    bigImge.originFrame = photoView.frame;

    [self.navigationController pushViewController:bigImge animated:NO];
}

- (IBAction)showTrace:(id)sender
{
    AIUIWebViewController *controller = [[AIUIWebViewController alloc] init];
    controller.url = [[NSUserDefaults standardUserDefaults]stringForKey:@"NSUD_FOOTPRINT_ADDRESS"];
    controller.usingToken = YES;
    controller.usingCache = NO;
    controller.usingPost = NO;
    //controller.usingJSLocation = YES;
    controller.params = @{@"abnumber":contact.employeeCode};
    controller.webViewTitle = @"安邦足迹";
    [self.navigationController pushViewController:controller animated:YES];
}

@end
