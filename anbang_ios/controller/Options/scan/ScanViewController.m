//
//  ChatCustomerViewController.h
//  BaseProject
//
//  Created by silenceSky  on 13-11-13.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "ScanViewController.h"
#import "ASIFormDataRequest.h"
#import "ChatInit.h"
#import "XMPPStream.h"
#import "XMPPServer+Add.h"
#import "QrCodeViewController.h"
#import "AddGroupResultViewController.h"
#import "MyServices.h"
#import "AIControllersTool.h"
#import "GroupCRUD.h"
#import "GroupDetailViewController2.h"

@interface ScanViewController ()<UIAlertViewDelegate> {
    NSString *fromFlag;
}

@end

@implementation ScanViewController
@synthesize personalData=_personalData;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    JLLog_I(@"scan dealloc");
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    //设置通知中心，二维码扫瞄结果
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNS_Receive_ScanResult" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveScanResult:)
                                                 name:@"NNS_Receive_ScanResult" object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self
                                              selector:@selector(circleDetailReturn:)
                                                  name:@"AI_Circle_Detail_Return"
                                                object:nil];

    [[NSNotificationCenter defaultCenter]  addObserver:self
                                              selector:@selector(circleDetailError:)
                                                  name:@"AI_Circle_Detail_Error"
                                                object:nil];
    
    [self ui];
    
#pragma mark 
#pragma mark camera configure

    NSString *mediaType = AVMediaTypeVideo;// Or AVMediaTypeAudio
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    NSLog(@"---cui--authStatus--------%d",authStatus);
    // This status is normally not visible—the AVCaptureDevice class methods for discovering devices do not return devices the user is restricted from accessing.
    if(authStatus ==AVAuthorizationStatusRestricted){
        NSLog(@"Restricted");
    }else if(authStatus == AVAuthorizationStatusDenied){
        // The user has explicitly denied permission for media capture.
        NSLog(@"Denied");     //应该是这个，如果不允许的话
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请在\"设置/隐私/相机\"中允许社区访问相机。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        alert.tag = 1251;
        [alert show];
        return;
    }
    else if(authStatus == AVAuthorizationStatusAuthorized){//允许访问
        // The user has explicitly granted permission for media capture, or explicit user permission is not necessary for the media type in question.
        [self setupCamera];
        
    }else if(authStatus == AVAuthorizationStatusNotDetermined){
        // Explicit user permission is required for media capture, but the user has not yet granted or denied such permission.
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(granted){//点击允许访问时调用
                //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
            }
            else {
                NSLog(@"Not granted access to %@", mediaType);
            }
            
        }];
    }else {
        NSLog(@"Unknown authorization status");
    }
    
#pragma mark end
    
    //AVCaptureDevice代表抽象的硬件设备
    // 找到一个合适的AVCaptureDevice
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![device hasTorch]) {//判断是否有闪光灯
        //        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:@"提示" message:@"当前设备没有闪光灯，不能提供手电筒功能" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        //        [alter show];
        // [alter release];
    }
    
    isLightOn = NO;
}
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)ui{
    self.title = NSLocalizedString(@"settings.scan",@"title");
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
        //self.navigationController.navigationBar.translucent = NO;
        
        cutHeight=113;
        
    }else  {
        cutHeight=113;
    }
    
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(back)]];
    
    
    self.view.backgroundColor = [UIColor blackColor];
    UIButton * scanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [scanButton setTitle:NSLocalizedString(@"scan.light",@"title") forState:UIControlStateNormal];
    
    scanButton.frame = CGRectMake(KCurrWidth/2-50, KCurrHeight/2+80, 100, 35);
    scanButton.titleLabel.textColor = [UIColor whiteColor];
    [scanButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    int scanHeight = 0;
    if (!kIsPad) {
        [self.view addSubview:scanButton];
    }else{
        scanHeight = 100;
    }
    
    UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake(KCurrWidth/2-50, scanHeight, 290, 30)];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.numberOfLines=2;
    labIntroudction.textColor=[UIColor whiteColor];
    labIntroudction.text=@"轻轻松松扫一扫";
    //[self.view addSubview:labIntroudction];
    
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(KCurrWidth/2-130, KCurrHeight/2-210, 20, 20)];
    UIImageView * imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(KCurrWidth/2+110, KCurrHeight/2-210, 20, 20)];
    UIImageView * imageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(KCurrWidth/2-130, KCurrHeight/2+40, 20, 20)];
    UIImageView * imageView4 = [[UIImageView alloc]initWithFrame:CGRectMake(KCurrWidth/2+110, KCurrHeight/2+40, 20, 20)];
    imageView.image = [UIImage imageNamed:@"Scan_QR01"];
    imageView2.image = [UIImage imageNamed:@"Scan_QR02"];
    imageView3.image = [UIImage imageNamed:@"Scan_QR03"];
    imageView4.image = [UIImage imageNamed:@"Scan_QR04"];
    
    [self.view addSubview:imageView];
    [self.view addSubview:imageView2];
    [self.view addSubview:imageView3];
    [self.view addSubview:imageView4];
    
    [self addToolbar];
    
    //加载旋转的风火轮
    self.activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleWhite];
    self.activityIndicator.frame = CGRectMake(KCurrWidth/2-40, KCurrHeight/2-85, 80, 80);
    //self.activityIndicator.center =self.view.center;
    self.activityIndicator.hidden =NO;
    //开始转动
    [self.activityIndicator startAnimating];
    [self.view addSubview: self.activityIndicator];
    
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(KCurrWidth/2-90, KCurrHeight/2-210, 220, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [self.view addSubview:_line];
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
}


-(void)animation1
{
    
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(KCurrWidth/2-110,
                                 KCurrHeight/2-210+2*num, 230, 2);
        if (2*num == 260) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(KCurrWidth/2-110, KCurrHeight/2-205+2*num, 230, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}

-(void)backAction
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        [timer invalidate];
    }];
}

- (void)setupCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    //真机运行
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    _preview =nil;
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =CGRectMake(0,0,KCurrWidth,KCurrHeight);
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    // Start
    [_session startRunning];
    
}


#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue=@"";
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [_session stopRunning];
    [self dismissViewControllerAnimated:YES completion:^
     {
         [timer invalidate];
         NSLog(@"%@",stringValue);
     }];
    [self addSalesMan:stringValue];
    stringValue = nil;
    metadataObjects = nil;
    
}

- (void)addSalesMan:(NSString *)url
{
    JLLog_I(@"URL=%@",url);
    if (url==nil) {
        //请重新选取二维码
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"scan.msg",@"title") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"public.alert.ok",@"title"),nil];
        [alter show];
        //[alter release];
        timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
        return;
    }
    scanURL = url;
    NSArray *urlArray = nil;
//    NSString *exec = @"";
//    JLLog_I(@"<openfire url=%@>", OpenFireUrl);
//    if (![OpenFireUrl isEqualToString:@"ab-insurance.com"]) {
//        urlArray = [scanURL componentsSeparatedByString:[NSString stringWithFormat:@"%@/",kShortUrlPort]];
//        
//        if(urlArray.count==0 ||![[urlArray objectAtIndex:0] isEqualToString:[NSString stringWithFormat:@"http://%@:",Server_Host]]){
//            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:scanURL delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"title") otherButtonTitles:NSLocalizedString(@"public.alert.ok",@"title"),nil];
//            [alter show];
//            alter.tag=10001;
//            // [alter release];
//            return;
//        }
//    }
//    exec =  [urlArray objectAtIndex:1];
    NSString *exec = [url lastPathComponent];
    JLLog_I(@"exec=%@", exec);
    
    if (exec.length>0) {
        /* <iqtype=”get” id=”xxx”><queryxmlns=”http://www.nihualao.com/xmpp/check-qr”><qr>http://icicl.net/adfadf</qr><!--二维码解析出来的串--></query></iq>
         
         响应
         
         <iqtype=”result” ><queryxmlns=”http://www.nihualao.com/xmpp/check-qr”><qrtype=”user/circle”><userjid=””><!--参考userinfo协议--></user><circlejid=”” ver=”” name=”” createDate=””modificationDate=”” creator=”创建者的JID”inviteUrl=””/></qr></query></iq>
         */
        
        //        NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/task"];
        //        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        //        NSXMLElement *execELe = [NSXMLElement elementWithName:@"exec"];
        //        [iq addAttributeWithName:@"type" stringValue:@"set"];
        //        [execELe addAttributeWithName:@"task" stringValue:exec];
        //        [iq addChild:queryElement];
        //        [queryElement addChild:execELe];
        //        [[XMPPServer xmppStream] sendElement:iq];
        //        [self addFinished];
        
        //id=@"scanAddContacts"
        NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/check-qr"];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        NSXMLElement *qr = [NSXMLElement elementWithName:@"qr"];
        [iq addAttributeWithName:@"type" stringValue:@"get"];
        [iq addAttributeWithName:@"id" stringValue:@"scanAddContacts"];
        [qr setStringValue:url];
        [iq addChild:queryElement];
        [queryElement addChild:qr];
        [[XMPPServer xmppStream] sendElement:iq];
        [self addFinished];
        [AIControllersTool loadingViewShow:self];
        
        
    }else{
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:scanURL delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        [alter show];
        alter.tag=10001;
        //[alter release];
    }
}

//更新回调方法
- (void)addFinished
{
    fromFlag = @"addContactsResult";
    //   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //清除roster版本号
    //    [defaults removeObjectForKey:@"Ver_Query_Roster"];
    //更新联系人
    //    [ChatInit queryRoster];
    //
    //            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    //            [alter show];
    //             alter.tag=10000;
    //            [alter release];
}

#pragma mark
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==10000) {
        if (buttonIndex==0) {
            self.view.backgroundColor = [UIColor blackColor];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }else if (alertView.tag==10001) {
        if (buttonIndex==1) {
            //self.view.backgroundColor = [UIColor blackColor];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scanURL]];
            
        }
    }else if (alertView.tag == 1251) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma end

-(void)addToolbar
{
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                  target:nil action:nil];
    
    UIBarButtonItem *cancelBuddyItem = [[UIBarButtonItem alloc]
                                        initWithTitle:NSLocalizedString(@"scan.photoAlbum",@"title") style:UIBarButtonItemStyleBordered
                                        target:self action:@selector(selectQRPicture)];
    cancelBuddyItem.width = 150;
    cancelBuddyItem.tintColor = [UIColor whiteColor];
    
    
    UIBarButtonItem *saveBuddyItem;
    //区分来源
    
    
    saveBuddyItem = [[UIBarButtonItem alloc]
                     initWithTitle:NSLocalizedString(@"scan.myQrCode",@"title") style:UIBarButtonItemStyleDone
                     target:self action:@selector(myQR)];
    saveBuddyItem.width = 150;
    saveBuddyItem.tintColor = [UIColor whiteColor];
    
    NSArray *toolbarItems = [NSArray arrayWithObjects:
                             cancelBuddyItem,spaceItem, saveBuddyItem, nil];
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
        
        toolbar.frame = CGRectMake(0, KCurrHeight-110, KCurrWidth, 50);
    }else{
        toolbar.frame = CGRectMake(0, KCurrHeight-110, KCurrWidth, 50);
    }
    
    [toolbar setBarStyle:UIBarStyleBlack];
    toolbar.backgroundColor = [UIColor blackColor];
    [self.view addSubview:toolbar];
    [toolbar setItems:toolbarItems];
    // [toolbar release];
}

-(void)selectQRPicture{
    //打开照片库
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    //imagePicker.allowsImageEditing = YES;    //图片可以编辑
    //需要添加委托
    [self presentModalViewController:imagePicker animated:YES];
    //[imagePicker release];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* chosedImage=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    NSLog(@"*******%@",chosedImage);
    //    NSLog(@"info-%@",info);
    //    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    //
    //
    //        NSLog(@"results-%@",results);
    //    ZBarSymbol *symbol = nil;
    //    for (symbol in results) {
    //        break;
    //        [self addSalesMan:symbol.data];
    //    }
    //
    //    [self dismissViewControllerAnimated:YES completion:^{
    //        [self sendImage:chosedImage];
    //
    //    }];
    [self dismissViewControllerAnimated:YES completion:^{
        [self sendImage:chosedImage];
        
    }];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}


//扫瞄相册中的二维码图片
-(void)sendImage:(UIImage *)image{
    NSLog(@"****%@",image);
#if !TARGET_IPHONE_SIMULATOR
    ZBarReaderController *reader =[ZBarReaderController new];
    CGImageRef cgimage = image.CGImage;
    ZBarSymbol *symbol = nil;
    for (symbol in [reader scanImage:cgimage])
        break;
    
    NSLog(@"*****%@",symbol.data);
    [self addSalesMan:symbol.data];
    //[reader release];
#endif
}

-(void)myQR{
    QrCodeViewController *qrVC=[[QrCodeViewController alloc]init];
    qrVC.labNmaetext =[[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
    qrVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:qrVC animated:YES];
    //[qrVC release];
    
}

/***************************/
-(void)btnClicked:(UIButton *)btn
{
    isLightOn = 1-isLightOn;
    if (isLightOn) {
        [self turnOnLed:YES];
        btn.titleLabel.text= @"关 闭";
    }else{
        [self turnOffLed:YES];
        btn.titleLabel.text = @"照 明";
    }
}



//打开手电筒
-(void) turnOnLed:(bool)update
{
    [device lockForConfiguration:nil];
    [device setTorchMode:AVCaptureTorchModeOn];
    [device unlockForConfiguration];
}

//关闭手电筒
-(void) turnOffLed:(bool)update
{
    [device lockForConfiguration:nil];
    [device setTorchMode: AVCaptureTorchModeOff];
    [device unlockForConfiguration];
}

/***********************************/


//扫瞄二维码结果
-(void)receiveScanResult:(NSNotification *)notify{
    
    [MyServices receiveScanResult:notify target:self];
    
}

- (void)circleDetailReturn:(NSNotification *)n {
    [AIControllersTool loadingVieHide:self];
    
    NSDictionary *d = n.userInfo;
    int count = [GroupCRUD queryChatRoomTableCountId:d[@"jid"] myJID:MY_JID];
    if ( count > 0) {
        ChatGroup *chatGroup = [[ChatGroup alloc]init];
        chatGroup = [GroupCRUD queryOneMyChatGroup2:d[@"jid"] myJID:MY_JID];
        GroupDetailViewController2*  groupDetailsVC = [[GroupDetailViewController2 alloc]init];
        groupDetailsVC.group = chatGroup;
//        groupDetailsVC.delegate = self;
        groupDetailsVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:groupDetailsVC animated:YES];
        
        UIViewController *rooter = self.navigationController.viewControllers[0];
        [self.navigationController setViewControllers:@[rooter, groupDetailsVC] animated:NO];
        
    }else {
        AddGroupResultViewController *controller = [[AddGroupResultViewController alloc] init];
        controller.circleInformation = n.userInfo;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)circleDetailError:(NSNotification *)n {
    [AIControllersTool loadingVieHide:self];
    [AIControllersTool tipViewShow:@"请求超时，请稍后再试"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [timer invalidate];
    timer=nil;
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // [self setupCamera];
    //停止动画
    [_activityIndicator stopAnimating];
    
    
    
}



@end
