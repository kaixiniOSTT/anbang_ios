//
//  GroupQrCodeViewController.m
//  anbang_ios
//
//  Created by seeko on 14-5-29.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "GroupQrCodeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "NSString+Helper.h"
#import "CHAppDelegate.h"
#import "SelectionCell.h"
#import "UITableView+DataSourceBlocks.h"
#import "TableViewWithBlock.h"
#import "GroupCRUD.h"
#import "CHAppDelegate.h"
#import "ImageUtility.h"
//#import "QREncoder.h"
#import "QRCodeGenerator.h"
#import <ShareSDK/ShareSDK.h>

#import "AICustomShareView.h"
#import "Photo.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "AICurrentContactController.h"
#import "AINavigationController.h"
#import "MBProgressHUD.h"

#define Group_WiressSDKDemoAppKey     @"801500977"
#define Group_WiressSDKDemoAppSecret  @"17451664cf27b9dfe5726de3da894978"
#define Group_REDIRECTURI             @"http://user.qzone.qq.com/348931837/myhome"
//#import "TCWBEngine.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface GroupQrCodeViewController ()
{
    BOOL isOpened;
    UIBarButtonItem *btnShare;
    UIImage* image;
    NSString *groupInviteUrl;
}
@property(nonatomic ,retain)NSString *groupInviteUrl;
@property (strong, nonatomic) AICustomShareView *shareView;

@end

@implementation GroupQrCodeViewController
@synthesize groupJID = _groupJID;
@synthesize groupInviteUrl;
@synthesize groupName;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)dealloc{
    //    [_groupJID release];
    //    [headImage release];
    //    [labName release];
    //    [QrCoedeImage release];
    //    [btnShare release];
    //    [groupInviteUrl release];
#if !TARGET_IPHONE_SIMULATOR
    // [_tencentOAuth release];
#endif
    
    //   [super dealloc];
}

- (AICustomShareView *)shareView
{
    if (!_shareView) {
        _shareView = [[AICustomShareView alloc] init];
    }
    return _shareView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(pop)]];
    
    //CGRect rect=[[UIScreen mainScreen]bounds];
    
    isOpened=NO;
    //分享
    btnShare=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"circleQrCode.share",@"action") style:UIBarButtonItemStylePlain target:self action:@selector(actionSheet)];
    
    
    
    [self.navigationItem setRightBarButtonItem:btnShare];
    //圈子二维码
    self.title=NSLocalizedString(@"circleQrCode.title",@"title");
    [self.view setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]];
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0,0, KCurrWidth, KCurrHeight)];
    [view setBackgroundColor:AB_Color_f6f2ed];
    [self.view addSubview:view];
    
    groupInviteUrl=[[GroupCRUD queryOneMyChatGroup:_groupJID myJID:MY_JID]objectForKey:@"inviteUrl"];
    
    QrCoedeImage = [[UIImageView alloc] initWithFrame:CGRectMake((KCurrWidth-180)/2, 80, 180, 180)];
    QrCoedeImage.image = [QRCodeGenerator qrImageForString:groupInviteUrl imageSize:170];
    
    UIImageView *photoView=[[UIImageView alloc]initWithFrame:CGRectMake((180 - 40)/2, (180 - 40)/2, 40, 40)];
    photoView.image = [UIImage imageNamed:@"AppIcon40x40"];
    photoView.layer.masksToBounds = YES;
    photoView.layer.cornerRadius = 5.0;
    photoView.layer.borderWidth = 2.0;
    photoView.backgroundColor = [UIColor whiteColor];
    photoView.layer.borderColor = [[UIColor whiteColor]CGColor];
    QrCoedeImage.layer.masksToBounds = YES;
    QrCoedeImage.layer.cornerRadius = 5.0;
    QrCoedeImage.backgroundColor = [UIColor whiteColor];
    
    [QrCoedeImage addSubview:photoView];
    [view addSubview:QrCoedeImage];
    
    UILabel *nicknameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, QrCoedeImage.frame.origin.y+QrCoedeImage.frame.size.height+15, KCurrWidth, 20)];
    nicknameLabel.text= [StrUtility string:groupName defaultValue:@"群聊"];
    [nicknameLabel setTextColor:AB_Color_403b36];
    nicknameLabel.font=[UIFont boldSystemFontOfSize:15];
    nicknameLabel.textAlignment=NSTextAlignmentCenter;
    [view addSubview:nicknameLabel];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, nicknameLabel.frame.origin.y+nicknameLabel.frame.size.height+15, KCurrWidth, 20)];
    label.text=@"扫描上方二维码图案，加入本群";
    [label setTextColor:AB_Color_9c958a];
    label.font=[UIFont boldSystemFontOfSize:15];
    label.textAlignment=NSTextAlignmentCenter;
    [view addSubview:label];
    
    //实例化长按手势监听
//    UILongPressGestureRecognizer *longPress =
//    [[UILongPressGestureRecognizer alloc] initWithTarget:self
//                                                  action:@selector(handleTableviewCellLongPressed:)];
//    //代理
//    longPress.delegate = self;
//    longPress.minimumPressDuration = 1.0;
//    //将长按手势添加到需要实现长按操作的视图里
//    [self.view addGestureRecognizer:longPress];
    //[longPress release];
    
}


- (void)pop
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


//长按事件的实现方法
//- (void) handleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
//    if (gestureRecognizer.state ==
//        UIGestureRecognizerStateBegan) {
//        NSLog(@"UIGestureRecognizerStateBegan");
//        
//        if (kIOS_VERSION>=8.0) {
//            
//            UIAlertController *otherLoginAlert = nil;
//            if (kIsPad) {
//                otherLoginAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
//            }else{
//                otherLoginAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//            }
//            [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"personalInformation.myQrCode.message2",@"action")
//                                                                style:UIAlertActionStyleDefault
//                                                              handler:^(UIAlertAction *action) {
//                                                                  [self saveImageToPhotos:QrCoedeImage.image];                                                              }]];
//            
//            
//            [otherLoginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"public.alert.cancel",@"action")                                                               style:UIAlertActionStyleCancel
//                                                              handler:^(UIAlertAction *action) {
//                                                                  
//                                                              }]];
//            
//            UIPopoverPresentationController *popover = otherLoginAlert.popoverPresentationController;
//            if (popover){
//                popover.sourceView = self.view;
//                popover.sourceRect = self.view.bounds;
//                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
//            }
//            
//            [self presentViewController:otherLoginAlert animated:YES completion:nil];
//            
//        }else{
//            
//            UIActionSheet *actionSheet = [[UIActionSheet alloc]
//                                          initWithTitle:@""
//                                          delegate:self
//                                          cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"title")
//                                          destructiveButtonTitle:nil
//                                          otherButtonTitles:NSLocalizedString(@"personalInformation.myQrCode.message2",@"title"),nil];
//            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
//            [actionSheet showInView:self.view];
//        }
//        
//    }
//    if (gestureRecognizer.state ==
//        UIGestureRecognizerStateChanged) {
//        NSLog(@"UIGestureRecognizerStateChanged");
//    }
//    
//    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
//        NSLog(@"UIGestureRecognizerStateEnded");
//    }
//    
//}
//
//
//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 0) {
//        // UIImageWriteToSavedPhotosAlbum(QrCoedeImage.image, nil, nil,nil);
//        [self saveImageToPhotos:QrCoedeImage.image];
//    }else if (buttonIndex == 1) {
//        
//    }else if(buttonIndex == 2) {
//    }else if(buttonIndex == 3) {
//    }
//    
//}
//
//- (void)saveImageToPhotos:(UIImage*)savedImage
//{
//    
//    QrCoedeImage = [[UIImageView alloc] initWithFrame:CGRectMake((KCurrWidth-260)/2, 80, 260, 260)];
//    QrCoedeImage.image = [QRCodeGenerator qrImageForString:groupInviteUrl imageSize:150];
//    
//    UIImageWriteToSavedPhotosAlbum(QrCoedeImage.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//    
//}
//
//// 指定回调方法
//- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
//    
//    NSString *msg = nil ;
//    
//    if(error != NULL){
//        
//        msg = NSLocalizedString(@"circleQrCode.message2",@"message") ;
//        
//    }else{
//        
//        msg = NSLocalizedString(@"circleQrCode.message3",@"message") ;
//        
//    }
//    
//    saveAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")
//                                           message:msg
//                 
//                                          delegate:self
//                 
//                                 cancelButtonTitle:nil
//                 
//                                 otherButtonTitles:nil];
//    
//    [saveAlert show];
//    
//    [self performSelector:@selector(hiddenAlert) withObject:@"1" afterDelay:1];//1秒后执行
//    
//    
//}
//
//-(void)hiddenAlert{
//    [saveAlert dismissWithClickedButtonIndex:0 animated:YES];
//    
//}



#pragma mark-分享
-(void)actionSheet{
    UIImage *qrcodeImage = [Photo getImageFromView:QrCoedeImage];
    id<ISSContent> publishContent = [ShareSDK content:@"邦邦社区二维码"
                                       defaultContent:@""
                                                image:[ShareSDK pngImageWithImage:qrcodeImage]
                                                title:@"快来扫我的二维码"
                                                  url:nil
                                          description:@"快来加我好友吧"
                                            mediaType:SSPublishContentMediaTypeImage];
    
 
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败");
                                }
                            }];
     
    
}

- (void)shareToBBFriends:(NSDictionary *)publishContent
{
    // Waiting..
    // until finish uploading
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *imageString = publishContent[@"image"];
    UIImage *aImage = [Photo string2Image:imageString];
    NSData *imageData = UIImageJPEGRepresentation(aImage, 0.5);
    
    // Prepare URL
    
    NSURL *url = [NSURL URLWithString:ResourcesURL];
    
    // Create request
    // and set the request delegate 'self'
    // type of method 'POST'
    
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"image/jpg"];
    
    // Post data
    
    [request setPostBody:[imageData mutableCopy]];
    
    // When finish uploading..
    // using block instead of delegate
    
    __weak typeof(request)wobject = request;
    [request setCompletionBlock:^{
        
        // Stop loading view
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        // Get the tfs link
        
        NSData *jsonData =[wobject responseData];
        NSDictionary *d = [jsonData objectFromJSONData];
        NSString *tfsLink = [d objectForKey:@"TFS_FILE_NAME"];
        
        // Prepare chat content
        NSString *text = [NSString stringWithFormat:@"%@%@%@%@%@",
                          @"{\"data\":\"",
                          imageString,
                          @"\",\"src\":\"\",\"link\":\"",
                          tfsLink,
                          @"\"}"];
        // Controller push
        NSArray *messages = @[@{@"text" : text, @"subject" : @"image"}];
        
        AICurrentContactController *controller = [[AICurrentContactController alloc] init];
        controller.messages = messages;
        AINavigationController *navigation = [[AINavigationController alloc]
                                              initWithRootViewController:controller];
        
        [self.navigationController presentViewController:navigation
                                                animated:YES
                                              completion:nil];
    }];
    
    // Start request
    [request startAsynchronous];
}

@end
