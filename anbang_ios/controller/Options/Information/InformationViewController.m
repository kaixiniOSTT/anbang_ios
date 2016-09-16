//
//  InformationViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "InformationViewController.h"
#import "InformationCell.h"
#import "CHAppDelegate.h"
#import "SettingNameController.h"
#import "QrCodeViewController.h"
#import "EmailViewController.h"
#import "PhoneNumViewController.h"
#import "GBPathImageView.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "QREncoder.h"
#import "DejalActivityView.h"
#import "UIImageView+WebCache.h"

#import "AISetBBIdViewController.h"
#import "AIUIWebViewController.h"
#import "ImageUtility.h"
#import "AISignatureViewController.h"
#import "AIAreaCRUD.h"
#import "MBProgressHUD.h"
#import "UserInfoCRUD.h"
#import "AIAreaPickerView.h"

#define tableViewFloatXY 10
#define tableViewWidth 300
#define tableViewHeight 300

#define TGender_Action_Sheet_Tag 1324

@interface InformationViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIImage *imagePic;
    UIImageView *imageView;
    BOOL isSetHead;
    //    GBPathImageView *squareImage;
    BOOL *isLoad;
    NSString *imageUrl;
    NSString *loadData;
    
    int genderSelect;
    MBProgressHUD *hub;
    
    NSString *_areaCode;
}

@property (strong, nonatomic) AIAreaPickerView *pickView;
@property (strong, nonatomic) NSArray *areas;

@end

@implementation InformationViewController
@synthesize delegate;
//-(CHAppDelegate *)appDelegate{
//    return  (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
//
//}

- (AIAreaPickerView *)pickView {
    if (!_pickView) {
        _pickView = [[AIAreaPickerView alloc] init];
    }
    return _pickView;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"NNC_PersonalInfomation_Loaded" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendsSuccess) name:@"bindingEmails_ok" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setGenderSuccess:) name:@"AI_Set_Gender_Succeed" object:nil];
    }
    return self;
}


- (void)dealloc{
    JLLog_D(@"<%@, %p> dealloc", [self class], self);
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NNC_PersonalInfomation_Loaded" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"bindingEmails_ok" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AI_Set_Gender_Succeed" object:nil];

    // Remove notifications
    [self removeNotifications];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setupNotifications {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(setAreaReturn:) name:@"AI_Set_Area_Return" object:nil];
    [defaultCenter addObserver:self selector:@selector(setAreaError:) name:@"AI_Set_Area_Error" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Add notifications
    [self setupNotifications];
    
    self.title = NSLocalizedString(@"personalInformation.title",@"title");
    self.view.backgroundColor= Controller_View_Color;
    
    isSetHead=NO;
    [self ui];
    self.areas = [AIAreaCRUD areas];
/////////////////////////////////////////////////////////////////////////////////////////////////////////
    self.userInfo = [UserInfo loadArchive];
/////////////////////////////////////////////////////////////////////////////////////////////////////////
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData{
    //    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"loaded" object:nil];
    //    NSLog(@"图片：%@",[[NSUserDefaults standardUserDefaults]stringForKey:@"headImage"]);
    
    self.userInfo = [UserInfo loadArchive];

    JLLog_I("<Userinfo=%@>", self.userInfo);
    [informationTableView reloadData];
}
- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)ui{
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"我"
                                                                                   target:self
                                                                                   action:@selector(pop)]];
    
    informationTableView.backgroundColor = Controller_View_Color;
    informationTableView.separatorColor = AB_Color_f4f0eb;
    //版本判断
    self.view.backgroundColor=[UIColor whiteColor];
    informationTableView.delegate=self;
    informationTableView.dataSource=self;
    //[informationTableView setAutoresizesSubviews:YES];
    [self.view bringSubviewToFront:informationTableView];
    [self.view addSubview:informationTableView];
    
    
    NSDictionary *row1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          NSLocalizedString(@"personalInformation.profilePhoto",@"action"), @"LiftText", @"", @"RightText", nil];
    
    NSDictionary *row2=[[NSDictionary alloc] initWithObjectsAndKeys: NSLocalizedString(@"personalInformation.nickName",@"action"),@"LiftText",nil];
    
    NSDictionary *row3=[[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"personalInformation.myQrCode",@"action"),@"LiftText",@"",@"" ,nil];
    
    NSDictionary *row4=[[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"personalInformation.icirCallID",@"action"),@"LiftText",@"",@"RightText",nil];
    
    NSDictionary *row5=[[NSDictionary alloc ]initWithObjectsAndKeys:NSLocalizedString(@"personalInformation.email",@"action"),@"LiftText",@"",@"RightText",nil];
    
    NSDictionary *row6=[[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"personalInformation.mobilePhoneNumber",@"action"),@"LiftText",@"",@"RightText",nil];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *array = [[NSArray alloc] initWithObjects:row1, row2,row3,row4,row5,row6, nil];
    self.informationList=array;
    
    //分辨率太大的重新上传头像
    NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL,[[NSUserDefaults standardUserDefaults]stringForKey:@"headImage"]];
    UIImageView *avatarImage = [[UIImageView alloc]init];
    [avatarImage setImageWithURL:[NSURL URLWithString:avatarURL]];
    
    [self reuploadAvatarImage:avatarImage.image];
}

//请求获取个人信息列表
-(void)sendIQInformationList{
    /*
     <iq type=”get”>
     <query xmlns=”http://www.icircall.com/xmpp/userinfo“ >
     <user jid=””/> </query>
     </iq>
     */
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *userJid=[NSXMLElement elementWithName:@"user"];
    //    NSLog(@"jid:%@",[[NSUserDefaults standardUserDefaults]stringForKey:@"jid"]);
    [userJid addAttributeWithName:@"jid" stringValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"jid"]];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"personalInformation"];
    [queryElement addChild:userJid];
    [iq addChild:queryElement];
    //    NSLog(@"%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
}
#pragma make - UITableView delegate


#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //这个方法用来告诉表格有几个分组
    
    if (self.userInfo.accountType == 2) {
        return 6;
    }else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int row=0;
    if(section==0)
        row=1;
    else if(section==1)
        row=4;
    else if(section==2)
        row=2;
    else if (section == 3)
        row = 7;
    else if (section == 4)
        row = 1;
    return row;
}



#pragma make -UITableView datasoure
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 15;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *nilView=[[UIView alloc]initWithFrame:CGRectZero];
    return nilView;
}


// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    InformationCell *cell = [[InformationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.textColor = AB_Color_403b36;
    cell.textLabel.font = AB_FONT_15;
    if (section==0 && row==0) {
        cell.textLabel.text =NSLocalizedString(@"personalInformation.profilePhoto",@"action");
        
        cell.layer.cornerRadius=2;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];
        cell.RigitText=@"";
        
        if ([[NSUserDefaults standardUserDefaults]stringForKey:@"headImage"].length>0 ){
            //            [self downloadImage];
            NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL,[[NSUserDefaults standardUserDefaults]stringForKey:@"headImage"]];
            
            [cell.headImage setImageWithURL:[NSURL URLWithString:avatarURL]
                           placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
            if (cell.headImage.image){
                
            }else{
                UIImage *userImage =[UIImage imageNamed:@"defaultUser.png"];
                cell.headImage.image=userImage;
            }
            
        }else{
            UIImage *userImage =[UIImage imageNamed:@"defaultUser.png"];
            cell.headImage.image=userImage;
        }
        

        
        if(isSetHead){
            cell.headImage.image = imagePic;
            [delegate setImage:imagePic];
        }
        //       squareImage = [[GBPathImageView alloc] initWithFrame:CGRectMake(240, 5, 50, 50) image:photoView.image pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor whiteColor] pathWidth:0.0];
        cell.headImage.layer.masksToBounds = YES;
        cell.headImage.layer.cornerRadius = 3.0;
        cell.headImage.layer.borderWidth = 0.0;
        cell.headImage.backgroundColor = kMainColor4;
        cell.headImage.layer.borderColor = [kMainColor4 CGColor];
        
    }
    else if (section ==1 && row==0) {
        cell.LeftText=NSLocalizedString(@"personalInformation.nickName",@"action");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];
//        if ([[NSUserDefaults standardUserDefaults]stringForKey:@"name"].length>0) {
//            cell.labRigitText.text=[[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
//        }else{
//            cell.labRigitText.text=[[NSUserDefaults standardUserDefaults]stringForKey:@"userName"];
//        }
         cell.RigitText = self.userInfo.nickName;
    }else if(section==1 && row==1) {
        cell.LeftText = @"性别";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];
        if (self.userInfo.myGender == 0) {
            cell.RigitText= @"未设置";
        }else {
            cell.RigitText = self.userInfo.myGender == 1 ? @"男" : @"女";
        }
        
    }else if (section==1 && row==2){
        cell.LeftText = @"社区ID";
        if (!self.userInfo.accountName) {
             cell.labRigitText.text = @"未设定";
        }else {
            cell.labRigitText.text = self.userInfo.accountName;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];
    }else if (section==1 && row==3){
        cell.LeftText = @"我的二维码";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];
        cell.codeImage.image = [UIImage imageNamed:@"icon_qrcode"];
        
    } else {
        switch (indexPath.section) {
            case 2:
                switch (indexPath.row) {
                    case 0:
                        cell.LeftText = @"地区";
                        cell.RigitText = [AIAreaCRUD selectNameForShowWithCode:self.userInfo.areaId];
                        break;
                    
                    case 1:
                        cell.LeftText = @"个性签名";
                        cell.RigitText = self.userInfo.signature;
                        cell.labRigitText.frame = CGRectMake(KCurrWidth/2-50-35, 2, KCurrWidth/2 + 50, 40);
                        cell.labRigitText.lineBreakMode = NSLineBreakByWordWrapping;
                        cell.labRigitText.numberOfLines = 2;
                        cell.labRigitText.adjustsFontSizeToFitWidth = NO;
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];
                        break;
                        
                    default:
                        break;
                }
                break;
            case 3:{
                CGRect rightFrame = cell.labRigitText.frame;
                if (Screen_Width >320)
                     rightFrame.origin.x += 15;
                else
                    rightFrame.origin.x += 20;
                
                cell.labRigitText.frame = rightFrame;
            }
                switch (indexPath.row) {
                    case 0:
                        cell.LeftText = @"姓名";
                        cell.RigitText = self.userInfo.employeeName;
                        break;
                    case 1:
                        cell.LeftText = @"工号";
                        cell.RigitText = self.userInfo.employeeCode;
                        break;
                    case 2:
                        cell.LeftText = @"个人电话";
                        cell.RigitText = self.userInfo.employeePhone;
                        break;
                        
                    case 3:
                        cell.LeftText = @"公共电话";
                        cell.RigitText = self.userInfo.publicPhone;
                        break;
                    case 4:
                        cell.LeftText = @"办公电话";
                        cell.RigitText = self.userInfo.officalPhone;
                        break;
                    case 5:
                        cell.LeftText = @"邮箱";
                        cell.RigitText = self.userInfo.email;
                        break;
                    case 6:
                        cell.LeftText = @"主体";
                        cell.RigitText = self.userInfo.bookName;
                        break;
                    case 7:
                        cell.LeftText = @"机构";
                        cell.RigitText = self.userInfo.agencyName;
                        break;
                    case 8:
                        cell.LeftText = @"部门";
                        cell.RigitText = self.userInfo.branchName;
                        break;
                    case 9:
                        cell.LeftText = @"事业部";
                        cell.RigitText = self.userInfo.departmentName;
                        break;
                        
                    default:
                        break;
                }
                break;
                
            case 4:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.text = @"查看我的安邦足迹";
                        cell.textLabel.textColor = AB_Blue_Color;
                        cell.textLabel.textAlignment = NSTextAlignmentCenter;
                        break;
                        
                    default:
                        break;
                }
                
            default:
                break;
        }
    }

    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
    
    return  cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (section==0 && row==0) {
        //头像
        if (kIOS_VERSION>=8.0) {
            UIAlertController *otherLoginAlert = nil;
            if (kIsPad) {
                otherLoginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:nil preferredStyle:UIAlertControllerStyleAlert];
            }else{
                otherLoginAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            }
            [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"personalInformation.profilePhoto.takingPictures",@"action")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [self takePhoto];                                                             }]];
            [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"personalInformation.profilePhoto.choosePhoto",@"action")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [self LocalPhoto];
                                                              }]];
            
            [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"public.alert.cancel",@"action")                                                               style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action) {
                                                                  
                                                              }]];
            
            UIPopoverPresentationController *popover = otherLoginAlert.popoverPresentationController;
            if (popover){
                popover.sourceView = self.view;
                popover.sourceRect = self.view.bounds;
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            
            [self presentViewController:otherLoginAlert animated:YES completion:nil];
            
        }else{
            
            UIActionSheet *setHeadPortrait=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"personalInformation.profilePhoto.cancel",@"action") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"personalInformation.profilePhoto.takingPictures",@"action"),NSLocalizedString(@"personalInformation.profilePhoto.choosePhoto",@"action"), nil];
            setHeadPortrait.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
            [setHeadPortrait showInView:self.view.window];
            //[setHeadPortrait release];
        }
    }else if (section==1 && row==0){
        //昵称
        SettingNameController *setName=[[SettingNameController alloc]init];
        [self.navigationController pushViewController:setName animated:YES];
        
        //[setName release];
    }else if (section==1 && row==1){
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"设置性别"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"男", @"女", nil];
        sheet.tag = TGender_Action_Sheet_Tag;
        sheet.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
        [sheet showInView:self.view.window];
        
    }else if (section==1 && row==2){
        
        if (self.userInfo.accountName.length <= 0 || !self.userInfo.accountName) {
            
            AISetBBIdViewController *controller = [[AISetBBIdViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }else if (section==1 && row==3){
        //二维码
        QrCodeViewController *qrCodeView=[[QrCodeViewController alloc]init];
        qrCodeView.inviteUrl = self.userInfo.inviteUrl;
        if ([[NSUserDefaults standardUserDefaults]stringForKey:@"name"].length>0){
            qrCodeView.labNmaetext =[[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
        }else{
            qrCodeView.labNmaetext=[[NSUserDefaults standardUserDefaults]stringForKey:@"userName"];
        }
        
        [self.navigationController pushViewController:qrCodeView animated:YES];
        
    }else if (section==1 && row==4){
    }else if (section==1 && row==5){
    }else if (section==2 && row==0){
        
        __weak typeof(self)wself = self;
        AIAreaPickerView *pickView = self.pickView;
        [pickView showInView:self.view completedBlock:^(NSString *code) {
            _areaCode = code;
            [wself sendAreaSettingIQ:code];
        }];
        
    }else if (section==2 && row==1){
        
        AISignatureViewController *controller = [[AISignatureViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        
    }else if (section==3 && row==0){
    }else if (section==4 && row==0){
        
        AIUIWebViewController *controller = [[AIUIWebViewController alloc] init];
        controller.url = [[NSUserDefaults standardUserDefaults]stringForKey:@"NSUD_FOOTPRINT_ADDRESS"];
        controller.usingToken = YES;
        controller.usingCache = NO;
        controller.params = @{@"abnumber":self.userInfo.employeeCode};
        //controller.usingPost = NO;
        controller.webViewTitle = @"安邦足迹";
        [self.navigationController pushViewController:controller animated:YES];
        
        
        //        if ([[NSUserDefaults standardUserDefaults]stringForKey:@"email" ].length>0) {
        //            if ([@"false" isEqualToString:[[NSUserDefaults standardUserDefaults]stringForKey:@"activated"]]) {
        //                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"personalInformation.emailBindingMsg",@"message") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"personalInformation.rebindEmail",@"action"),NSLocalizedString(@"public.alert.yes",@"action"),nil];
        //                alert.tag=1005;
        //                [alert show];
        //                //[alert release];
        //            }else{
        //                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"personalInformation.emailBindingMsg2",@"message") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"public.alert.no",@"action"),NSLocalizedString(@"public.alert.yes",@"action"),nil];
        //                alertView.tag=1003;
        //                [alertView show];
        //                // [alertView release];
        //            }
        //        }else{
        //            //Email
        //            EmailViewController *emailView=[[EmailViewController alloc]init];
        //            [self.navigationController pushViewController:emailView animated:YES];
        //            //[emailView release];
        //        }
    }else if(section==5 && row==0){
        //        if ([[NSUserDefaults standardUserDefaults]stringForKey:@"phone" ].length>0) {
        //            NSString *msg = [NSString stringWithFormat:@"%@%@%@%@",NSLocalizedString(@"personalInformation.phoneBindingMsg",@"message"),[[NSUserDefaults standardUserDefaults]stringForKey:@"phone" ],@",",NSLocalizedString(@"personalInformation.phoneBindingMsg2",@"message")];
        //            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"public.alert.no",@"action"),NSLocalizedString(@"public.alert.yes",@"action"),nil];
        //            alertView.tag=1004;
        //            [alertView show];
        //            //[alertView release];
        //        }else{
        //            //手机号码
        //            PhoneNumViewController *phoneNumView=[[PhoneNumViewController alloc]init];
        //            [self.navigationController pushViewController:phoneNumView animated:YES];
        //            // [phoneNumView release];
        //        }
    }
    
}

- (void) sendAreaSettingIQ:(NSString *)code {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        [iq addAttributeWithName:@"id" stringValue:@"AI_Set_Area"];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:kUserInfoNameSpace];
        NSXMLElement *name = [NSXMLElement elementWithName:@"areaId" stringValue:code];
        
        [query addChild:name];
        [iq addChild:query];
        
        JLLog_I(@"%@", iq);
        [[XMPPServer xmppStream] sendElement:iq];
    });
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self performSelector:@selector(afterDelay) withObject:nil afterDelay:30.0];
}

- (void) setAreaReturn:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    self.userInfo.areaId = _areaCode;
    [self.userInfo save];
    [UserInfoCRUD saveAreaId:_areaCode targetJID:MY_JID];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [informationTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void) setAreaError:(NSNotification *)notification {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [AIControllersTool tipViewShow:@"服务器出错，请稍后重试"];
}

- (void) afterDelay {
    MBProgressHUD *aHub = [MBProgressHUD HUDForView:self.view];
    if (aHub) {
        [aHub hide:YES];
        [AIControllersTool tipViewShow:@"请求超时，请稍后再试"];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    
    if (section == 0)
        return 68.0;
    return 44.0;
}


#pragma mark -UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1003&&buttonIndex==1) {
        EmailViewController *emailView=[[EmailViewController alloc]init];
        [self.navigationController pushViewController:emailView animated:YES];
        // [emailView release];
    }
    else if (alertView.tag==1004&&buttonIndex==1){
        PhoneNumViewController *phoneNumView=[[PhoneNumViewController alloc]init];
        [self.navigationController pushViewController:phoneNumView animated:YES];
        // [phoneNumView release];
    }else if (alertView.tag==1005&&buttonIndex==1){
        [self sendsRequset];
    }else if (alertView.tag==1005&&buttonIndex==0){
        EmailViewController *emailView=[[EmailViewController alloc]init];
        [self.navigationController pushViewController:emailView animated:YES];
        //[emailView release];
    }
}

-(void)sendsRequset{
    /*<iq type=”set”>
     <query xmlns=”http://www.nihualao.com/xmpp/bind”>
     <bind email=”需绑定的邮箱”/> </query>
     </iq>*/
    NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/bind"];
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    NSXMLElement *bind=[NSXMLElement elementWithName:@"bind"];
    [bind addAttributeWithName:@"email" stringValue:[[NSUserDefaults standardUserDefaults]stringForKey:@"email"]];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"bindingEmails"];
    [queryElement addChild:bind];
    [iq addChild:queryElement];
    //    NSLog(@"%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
}

- (void)setGender:(int)aGender {
    
    /**
     *   <iq type="set">
     *   <query xmlns="http://www.nihualao.com/xmpp/userinfo">
     *   <gender>性别</gender>
     *   </query>
     *   </iq>
     */
    
    NSString *stringValue = [NSString stringWithFormat:@"%d", aGender];
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
    NSXMLElement *gender = [NSXMLElement elementWithName:@"gender" stringValue:stringValue];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"AIuserinfo_setGender"];
    [queryElement addChild:gender];
    [iq addChild:queryElement];
    
    [[XMPPServer xmppStream] sendElement:iq];
    
}

-(void)sendsSuccess{
    
    //    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"bindingEmails_ok" object:nil];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"personalInformation.sendEmailMsg",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
    [alert show];
    //[alert release];
}

- (void)setGenderSuccess:(NSNotification *)note {
    
    [self loadViewHide];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    
    InformationCell *cell = (InformationCell *)[informationTableView cellForRowAtIndexPath:indexPath];
    cell.labRigitText.text = genderSelect == 1 ? @"男" : @"女";
    
    JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"修改性别成功"];
    [tipView showInView:self.view animated:YES];
}

#pragma mark UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    JLLog_I(@"<buttonIndex = %d>", buttonIndex);
    if (actionSheet.tag == TGender_Action_Sheet_Tag) {
        
        int gender = 0;
        switch (buttonIndex) {
            case 0:
                gender = 1;
                break;
                
            case 1:
                gender = 2;
                
                break;
                
            default:
                return;
        }
        
        genderSelect = gender;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self setGender:gender];
        });
        
        [self loadViewShow];
        
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            //            NSLog(@"拍照");
            [self takePhoto];
            break;
        case 1:
            //            NSLog(@"本地图片");
            [self LocalPhoto];
            break;
        default:
            //            NSLog(@"取消");
            break;
    }
}

//开始拍照
-(void)takePhoto{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        
        [self presentViewController:picker animated:YES completion:^{}];
        //        [self appDelegate].tabBarBG.hidden=YES;
        //[picker release];
    }else
    {
        //        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

//打开相册
-(void)LocalPhoto
{
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.delegate = self;
    picker.allowsEditing=YES;
    picker.sourceType=sourceType;
    [self presentViewController:picker animated:YES completion:^{}];
    //[picker release];
}

#pragma mark - UIImagePickerController Delegate  上传图片
//拍照完选择相片后
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    hub = [[MBProgressHUD alloc] initWithView:self.view];
    hub.labelText = @"正在上传";
    [picker.view addSubview:hub];
    [hub show:YES];
    [hub hide:YES afterDelay:120];
    
    isSetHead=YES;
    imagePic=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    //自动旋转图片
    imagePic = [ImageUtility fixOrientation:imagePic];

    CGRect rect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
    imagePic = [self clipImage:imagePic inRect:rect];

    //设置image的尺寸
    
    CGSize imagesize = imagePic.size;
    
    CGFloat x = 0;
    CGFloat y= 0;
    
    if(imagesize.height != imagesize.width){
        if(imagesize.height > imagesize.width){
            y = (imagesize.height - imagesize.width)/2;
            imagesize.height = imagesize.width;
        }
        
        if(imagesize.width > imagesize.height){
            x = (imagesize.width - imagesize.height)/2;
            imagesize.width = imagesize.height;
        }
        
        imagePic = [self clipImage:imagePic inRect:CGRectMake(x, y, imagesize.width, imagesize.height)];
    }
    
    imagePic = [self imageWithImageSimple:imagePic scaledToSize:CGSizeMake(512,512)];
    
    [self uploadAvatarImage];
}


- (void)uploadAvatarImage
{
    //上传图片
    NSString *strUrl = [[NSString alloc] initWithFormat:@"%@",ResourcesURL];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSData *data = UIImageJPEGRepresentation(imagePic, 0.5);//获取图片数据
    JLLog_D(@"jpeg with cq = %f nsdata length:%d", 0.5f, data.length);
    
    NSMutableData *imageData = [NSMutableData dataWithData:data];//ASIFormDataRequest 的setPostBody 方法需求的为NSMutableData类型
    ASIFormDataRequest *aRequest = [[ASIFormDataRequest alloc] initWithURL:url];
    [aRequest setDelegate:self];//代理
    [aRequest setRequestMethod:@"POST"];
    
    [aRequest setPostBody:imageData];
    [aRequest addRequestHeader:@"Content-Type" value:@"image/jpeg"];//这里的value值 需与服务器端 一致
    
    [aRequest startAsynchronous];//开始。异步
    [self performSelector:@selector(selectPic:) withObject:imagePic afterDelay:0];
    
    [aRequest setDidFinishSelector:@selector(headPortraitSuccess)];//当成功后会自动触发 headPortraitSuccess 方法
    [aRequest setDidFailSelector:@selector(headPortraitFail)];//如果失败会 自动触发 headPortraitFail 方法
}

- (void)reuploadAvatarImage:(UIImage*)image
{
    //头像小于512x512的不处理，超过的处理成512*512
    if(image.size.width <= 512 && image.size.height <= 512){
        JLLog_D(@"不处理512*512以下的头像");
        return;
    }
    
    isSetHead = YES;
    imagePic = [self imageWithImageSimple:image scaledToSize:CGSizeMake(512,512)];
    
    //上传图片
    NSString *strUrl = [[NSString alloc] initWithFormat:@"%@",ResourcesURL];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSData *data = UIImageJPEGRepresentation(imagePic, 0.5);//获取图片数据
    JLLog_D(@"jpeg with cq = %f nsdata length:%d", 0.5f, data.length);
    
    NSMutableData *imageData = [NSMutableData dataWithData:data];//ASIFormDataRequest 的setPostBody 方法需求的为NSMutableData类型
    ASIFormDataRequest *aRequest = [[ASIFormDataRequest alloc] initWithURL:url];
    [aRequest setDelegate:self];//代理
    [aRequest setRequestMethod:@"POST"];
    
    [aRequest setPostBody:imageData];
    [aRequest addRequestHeader:@"Content-Type" value:@"image/jpeg"];//这里的value值 需与服务器端 一致
    
    [aRequest startAsynchronous];//开始。异步
    [self performSelector:@selector(selectPic:) withObject:imagePic afterDelay:0];
    
    [aRequest setDidFinishSelector:@selector(sendIQInformationList)];//当成功后会自动触发 sendIQInformationList 方法
}




//返回data数据
- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data{
    NSError *error;
    NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSString *result=[weatherDic objectForKey:@"TFS_FILE_NAME"];
    //    NSLog(@"%@",result);
    //发送修改头像请求
    NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/userinfo"];
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    NSXMLElement *name=[NSXMLElement elementWithName:@"avatar" stringValue:result];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"setHearImage"];
    [queryElement addChild:name];
    [iq addChild:queryElement];
    //    NSLog(@"%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
}

-(void)headPortraitSuccess{
    if([hub isHidden]){
        [hub hide:YES];
    }
    [self performSelectorOnMainThread:@selector(backMain) withObject:nil waitUntilDone:NO];
}

-(void)backMain{
    [self dismissViewControllerAnimated:YES completion:^{
        [self sendIQInformationList];
    }];
}

-(void)headPortraitFail{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"public.alert.networkConnectionFailure",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
    [alert show];
    //[alert release];
    return;
}

- (void)selectPic:(UIImage*)image
{
    isSetHead=YES;
    imageView=[[UIImageView alloc]initWithImage:image];
}

//detect为自己定义的方法，编辑选取照片后要实现的效果

//对图片选择或取消调用
-(void)imagePickerControllerDIdCancel:(UIImagePickerController*)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //        [self sendIQInformationList];
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    //CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate hideTabBar:YES];
    
    self.userInfo = [UserInfo loadArchive];
    
    [self sendIQInformationList];
    [informationTableView reloadData];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    //[informationTableView reloadData];
}

//压缩图片
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

//截取图片的某一部分
- (UIImage *)clipImage:(UIImage*) image inRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *thumbScale = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return thumbScale;
}

- (void)upLoadSalesBigImage:(NSString *)bigImage MidImage:(NSString *)midImage SmallImage:(NSString *)smallImage{
    NSURL *url = [NSURL URLWithString:ResourcesURL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:@"photo" forKey:@"type"];
    [request setFile:bigImage forKey:@"file_pic_big"];
    [request buildPostBody];
    [request setDelegate:self];
    [request setTimeOutSeconds:1];
    [request startAsynchronous];
}

- (void)loadViewShow {
    
    [self.view endEditing:YES];
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)loadViewHide {
    
    [self.view endEditing:NO];
    [DejalBezelActivityView removeViewAnimated:YES];
}


@end
