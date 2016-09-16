//
//  QrCodeViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-20.
//  Copyright (c) 2014年 ch. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "NSString+Helper.h"
#import "QrCodeViewController.h"
#import "CHAppDelegate.h"
#import "QREncoder.h"
#import "UITableView+DataSourceBlocks.h"
#import "TableViewWithBlock.h"
#import "QRCodeGenerator.h"
#import "UIImageView+WebCache.h"
#import "ImageUtility.h"
#import <ShareSDK/ShareSDK.h>
#import "AICustomShareView.h"
#import "Photo.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "AICurrentContactController.h"
#import "AINavigationController.h"
#import "MBProgressHUD.h"


//#import "SinaWeb/SinaWeibo/SinaWeibo.h"

#define Code_img_Y  80

//#import "TCWBEngine.h"
@interface QrCodeViewController ()
{
    UIBarButtonItem *btnShare;
    UIImage* image;
}

@property (strong, nonatomic) AICustomShareView *shareView;

@end

@implementation QrCodeViewController
//@synthesize wbapi;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (AICustomShareView *)shareView
{
    if (!_shareView) {
        _shareView = [[AICustomShareView alloc] init];
    }
    return _shareView;
}

-(void)dealloc{
    
}
- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = Controller_View_Color;
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"target:self action:@selector(pop)]];
    btnShare=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"personalInformation.myQrCode.share",@"action") style:UIBarButtonItemStylePlain target:self action:@selector(actionSheet)];
    [self.navigationItem setRightBarButtonItem:btnShare];
    self.title=NSLocalizedString(@"personalInformation.myQrCode.title",@"title");
    [self.view setBackgroundColor:Controller_View_Color];
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight)];
    [view setBackgroundColor:Controller_View_Color];
    [self.view addSubview:view];
    
    
    NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL,[[NSUserDefaults standardUserDefaults]stringForKey:@"headImage"]];
    
    CGFloat code_Img_w = 180;
    CGFloat code_Bg_w = code_Img_w - 10;

    QrCoedeImage = [[UIImageView alloc] initWithFrame:CGRectMake((KCurrWidth-code_Img_w)/2, 80, code_Img_w, code_Img_w)];
    QrCoedeImage.image = [QRCodeGenerator qrImageForString:[[NSUserDefaults standardUserDefaults]objectForKey:@"inviteUrl"] imageSize:code_Bg_w];
    photoView=[[UIImageView alloc]initWithFrame:CGRectMake((code_Img_w - 40)/2,(code_Img_w - 40)/2, 40, 40)];
    photoView.layer.borderWidth = 1;
    [photoView setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
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
    nicknameLabel.text= [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
    [nicknameLabel setTextColor:AB_Color_403b36];
    nicknameLabel.font=[UIFont boldSystemFontOfSize:15];
    nicknameLabel.textAlignment=NSTextAlignmentCenter;
    [view addSubview:nicknameLabel];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, nicknameLabel.frame.origin.y+nicknameLabel.frame.size.height+15, KCurrWidth, 20)];
    label.text=@"扫描上方二维码图案，加我好友";
    [label setTextColor:AB_Color_9c958a];
    label.font=[UIFont boldSystemFontOfSize:15];
    label.textAlignment=NSTextAlignmentCenter;
    [view addSubview:label];
}


- (void)saveImageToPhotos:(UIImage*)savedImage
{
    QrCoedeImage = [[UIImageView alloc] initWithFrame:CGRectMake((KCurrWidth-260)/2, 80, 260, 260)];
    QrCoedeImage.image = [QRCodeGenerator qrImageForString:[[NSUserDefaults standardUserDefaults]objectForKey:@"inviteUrl"] imageSize:150];
    
    UIImageWriteToSavedPhotosAlbum(QrCoedeImage.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    
    NSString *msg = nil ;
    
    if(error != NULL){
        msg = NSLocalizedString(@"circleQrCode.message2",@"message");
    }else{
        msg = NSLocalizedString(@"circleQrCode.message3",@"message");
    }
    
    saveAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")
                                           message:msg
                 
                                          delegate:self
                 
                                 cancelButtonTitle:nil
                 
                                 otherButtonTitles:nil];
    
    [saveAlert show];
    
    [self performSelector:@selector(hiddenAlert) withObject:@"1" afterDelay:1];//1秒后执行
    
    
}


-(void)hiddenAlert{
    [saveAlert dismissWithClickedButtonIndex:0 animated:YES];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

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
