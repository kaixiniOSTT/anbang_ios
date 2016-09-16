//
//  SuggestionViewController.m
//  anbang_ios
//
//  Created by appdor on 4/2/15.
//  Copyright (c) 2015 ch. All rights reserved.
//

#import "SuggestionViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TTAlbumTableController.h"
#import "ASIFormDataRequest.h"
#import "TTImagePickerController.h"
#import "MBProgressHUD.h"

@interface SuggestionViewController ()<TTImagePickerControllerDelegate, ASIHTTPRequestDelegate>
{
    UITextView *textView;
    UIBarButtonItem *sendBtn;
    UIButton *addPicture;
    NSMutableArray* imageArray;
    CGFloat xImage;
    CGFloat yImage;
    MBProgressHUD* hub ;
    BOOL sendOK;
}
@property (nonatomic, strong)NSMutableArray* imageKeyArray;
@property (nonatomic, copy)NSString* imageKey;
@end

@implementation SuggestionViewController
- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(pop)]];
    
    sendOK = NO;
    self.view.backgroundColor = Controller_View_Color ;
    textView.textColor = AB_Color_c3bdb4;
    textView.font = AB_FONT_14;
    self.imageKeyArray = [NSMutableArray array];
    self.imageKey = @"";
    // Do any additional setup after loading the view from its nib.
    sendBtn = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(send:)];
    sendBtn.enabled = NO;
    [self.navigationItem setRightBarButtonItem:sendBtn];
    textView = [[UITextView alloc]initWithFrame:CGRectMake(15, 15, Screen_Width -30, Screen_Height - 421)];
    textView.delegate = self;
    [textView becomeFirstResponder];
    [self.view addSubview:textView];
 
    textView.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"aboutMessage"];
    
    [addPicture addTarget:self action:@selector(addPicture:) forControlEvents:UIControlEventTouchUpInside];
    imageArray = [NSMutableArray array];
    
    xImage = 15;
    yImage = CGRectGetMaxY(textView.frame) + 10;
    
    
    NSString* num =  [[NSUserDefaults standardUserDefaults]valueForKey:@"aboutPicNum"];
    
    if(num == nil || [num isEqualToString:@""]){
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"aboutPicNum"];
    }
    
    [self initImage];
    
    [self addObserver:self forKeyPath:@"imageKey" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)addPicture:(UIButton*) btn{
    
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    
    
    if (author == ALAuthorizationStatusDenied || author == ALAuthorizationStatusRestricted)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请在\"设置/隐私/相册\"中允许社区访问相册。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
        TTAlbumTableController *albumTable = [[TTAlbumTableController alloc] init];
        TTImagePickerController *imagePicker = [[TTImagePickerController alloc] initWithRootViewController:albumTable];
        albumTable.maxSelected = 3 - imageArray.count;
        albumTable.delegate = imagePicker;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        imagePicker.delegate = self;
    }
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)send:(UIBarButtonItem *)sender
{
//    if ([textView.text isEqualToString:@""])
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入意见" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
    
    if (textView.text.length > 800)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"意见最多800个字符" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [textView resignFirstResponder];
    hub = [[MBProgressHUD alloc] init];
    hub.labelText = @"正在发送";
    hub.dimBackground = YES;
    [[UIApplication sharedApplication].delegate.window addSubview:hub];
    [hub show:YES];

    
    
    if (imageArray.count == 0) {
        [self sendMsg];
    }else{
        for (NSDictionary* dic in imageArray) {
            [self updateImage:[dic valueForKey:@"data"]];
        }
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToRootViewControllerAnimated:YES];    
}
- (void)alertViewCancel:(UIAlertView *)alertView
{
}

- (void)textViewDidBeginEditing:(UITextView *)aTextView
{
    aTextView.text = @"";
    aTextView.textColor = AB_Color_c3bdb4;
    sendBtn.enabled = YES;
}

-(void)textViewDidChange:(UITextView *)atextView{
    if(atextView.text != nil && ![atextView.text isEqualToString:@""]){
        
        sendBtn.enabled = YES;;
    }
}




- (void)ttImagePickerController:(TTImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
    
    NSString *pngDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *fileDir = [NSString stringWithFormat:@"%@/aboutPic", pngDir];
    
    NSError* error = nil;
    if (![fileMgr fileExistsAtPath:fileDir]) {
        [fileMgr createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    NSInteger picNum = ((NSString*)[[NSUserDefaults standardUserDefaults]valueForKey:@"aboutPicNum"]).integerValue;
    for (ALAssetRepresentation *rep in info) {
        picNum++;
        NSInteger num = imageArray.count;
        UIImage* image = [UIImage imageWithCGImage:[rep fullResolutionImage]];
        NSString* name = [NSString stringWithFormat:@"%u.jpg", picNum];
        NSString* path = [NSString stringWithFormat:@"%@/%@",fileDir, name];
        
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:path options:NSAtomicWrite error:nil];
        
        NSDictionary* imageDic = @{@"data":UIImageJPEGRepresentation(image, 0.5)  , @"path":path , @"name":name, @"tag":[NSString stringWithFormat:@"%u", 300+picNum]};
        
        [imageArray addObject:imageDic];
       
        UIImageView* imageView = [[UIImageView alloc]initWithImage:image];
        imageView.frame = CGRectMake(xImage + num * 75, yImage, 70, 70);
        imageView.userInteractionEnabled = YES;
        imageView.tag = 300+picNum;
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleImage:)];
        [imageView addGestureRecognizer:tap];
        [self.view addSubview:imageView];
        
        UIImageView* deleImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chat_btn_delete"]];
        deleImage.frame = CGRectMake(imageView.frame.size.width - 14, -3, 16, 16);
        [imageView addSubview:deleImage];
        
        
        num++;
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%u", picNum]  forKey:@"aboutPicNum"];
    
    CGRect frame = addPicture.frame;
    frame.origin.x += 75 * info.count;
    addPicture.frame = frame;
    
    if(imageArray.count == 3){
        addPicture.hidden = YES;
    }
 
    
}


-(void)ttImagePickerControllerDidCancel:(TTImagePickerController *)picker{
    
}


- (void)deleImage:(UITapGestureRecognizer*)tap{
    [[self.view viewWithTag:tap.view.tag] removeFromSuperview];
     NSInteger picNum = ((NSString*)[[NSUserDefaults standardUserDefaults]valueForKey:@"aboutPicNum"]).integerValue;
   
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError* error = nil;
    
    
    for(int i = 0; i < imageArray.count; i++){
        NSString* tag = [imageArray[i]valueForKey:@"tag"];
        if(tap.view.tag == tag.intValue){
            [fileMgr removeItemAtPath:[imageArray[i]valueForKey:@"path"] error:&error];
            [imageArray removeObjectAtIndex:i];
        }
    }
    
    if(imageArray.count == 2){
        for(int i= 1; i <= picNum + 300 - tap.view.tag; i++){
            CGRect frame = [self.view viewWithTag:tap.view.tag + i].frame;
            frame.origin.x -= 75;
            [self.view viewWithTag:tap.view.tag + i].frame = frame;
        }
        CGRect frame = addPicture.frame;
        frame.origin.x -= 75;
        addPicture.frame = frame;
        addPicture.hidden = NO;
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            
            for(int i= 1; i <= picNum + 300 - tap.view.tag; i++){
                CGRect frame = [self.view viewWithTag:tap.view.tag + i].frame;
                frame.origin.x -= 75;
                [self.view viewWithTag:tap.view.tag + i].frame = frame;
            }
            CGRect frame = addPicture.frame;
            frame.origin.x -= 75;
            addPicture.frame = frame;
        } completion:^(BOOL finished) {
            
        }];

    }

}

-(void) initImage{
    
    
    NSString *pngDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *fileDir = [NSString stringWithFormat:@"%@/aboutPic", pngDir];

    NSError* error = nil;
    NSArray* imagePathArr = [fileMgr contentsOfDirectoryAtPath:fileDir error:&error];
    [imageArray removeAllObjects];
    int num = 0;
    for (int i= 0; i< imagePathArr.count; i++) {
        
        
        if([[imagePathArr[i] componentsSeparatedByString:@"."][1] isEqualToString:@"jpg"]){
            NSString* path = [fileDir stringByAppendingPathComponent:imagePathArr[i]];
            UIImage* image = [[UIImage alloc]initWithContentsOfFile:path];
            NSString* tag = [imagePathArr[i] componentsSeparatedByString:@"."][0];
            NSDictionary* imageDic = @{@"data":UIImageJPEGRepresentation(image, 1.0)  , @"path":path , @"name":imagePathArr[i], @"tag":[NSString stringWithFormat:@"%u", 300+tag.intValue]};
            [imageArray addObject:imageDic];
            
            UIImageView* imageView = [[UIImageView alloc]initWithImage:image];
            imageView.frame = CGRectMake(xImage + num * 75, yImage, 70, 70);
            imageView.userInteractionEnabled = YES;
            imageView.tag = 300+tag.intValue;
            
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleImage:)];
            [imageView addGestureRecognizer:tap];
            [self.view addSubview:imageView];
            
            UIImageView* deleImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chat_btn_delete"]];
            deleImage.frame = CGRectMake(imageView.frame.size.width - 14, -3, 16, 16);
            [imageView addSubview:deleImage];
            
            num++;
        }
        if (num == 3) {
            break;
        }
        
    }
    
    addPicture = [UIButton buttonWithType:UIButtonTypeCustom];
    addPicture.frame = CGRectMake(15 + 75 * imageArray.count, yImage, 70, 70);
    [addPicture setBackgroundImage:[UIImage imageNamed:@"about_addPic"] forState:UIControlStateNormal];
    [addPicture addTarget:self action:@selector(addPicture:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addPicture];
    if(imageArray.count == 3){
        addPicture.hidden = YES;
    }
    
}


-(void)updateImage:(NSData*) imagePicData{
    //上传图片
    NSString *strUrl = [[NSString alloc] initWithFormat:@"%@",ResourcesURL];
    
    NSURL *url = [NSURL URLWithString:strUrl];
    // [strUrl release];
    strUrl = Nil;
    
    //    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    NSData *data = imagePicData;
    JLLog_D(@"jpeg with cq = %f nsdata length:%d", 0.3f, data.length);
    
    NSMutableData *imageData = [NSMutableData dataWithData:data];//ASIFormDataRequest 的setPostBody 方法需求的为NSMutableData类型
    ASIFormDataRequest *aRequest = [[ASIFormDataRequest alloc] initWithURL:url];
    [aRequest setDelegate:self];//代理
    [aRequest setRequestMethod:@"POST"];
    
    [aRequest setPostBody:imageData];
    [aRequest addRequestHeader:@"Content-Type" value:@"image/jpeg"];//这里的value值 需与服务器端 一致
    
    [aRequest startAsynchronous];//开始。异步
//    [self performSelector:@selector(selectPic:) withObject:imagePic afterDelay:0];
//    
//    [aRequest setDidFinishSelector:@selector(headPortraitSuccess)];//当成功后会自动触发 headPortraitSuccess 方法
//    [aRequest setDidFailSelector:@selector(headPortraitFail)];//如果失败会 自动触发 headPortraitFail 方法
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data{
    NSError *error;
    NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSString *result=[weatherDic objectForKey:@"TFS_FILE_NAME"];
    
    if(self.imageKeyArray == nil){
        self.imageKeyArray  = [NSMutableArray  array];
    }
     [self.imageKeyArray addObject:result];
    self.imageKey = result;
   
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(self.imageKeyArray.count == imageArray.count){
        [self sendMsg];
        
    }
}


-(void)sendMsg{
    
    NSXMLElement *content = [NSXMLElement elementWithName:@"content" stringValue:textView.text];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/feedback"];
    [query addChild:content];
    
    if (imageArray.count != 0) {
        NSXMLElement *imgs = [NSXMLElement elementWithName:@"imgs"];
        for (NSString* key in self.imageKeyArray) {
            NSXMLElement *item = [NSXMLElement elementWithName:@"item" stringValue:key];
            [imgs addChild:item];
            
        }
        
        [query addChild:imgs];
    }
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"abfea"];
    [iq addChild:query];
    
    NSLog(@"Suggestion xml:%@", iq);
    [[XMPPServer xmppStream] sendElement:iq];
    
    [imageArray removeAllObjects];
    NSString *pngDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *fileDir = [NSString stringWithFormat:@"%@/aboutPic", pngDir];
    
    NSError* error = nil;
    if ([fileMgr fileExistsAtPath:fileDir]) {
        [fileMgr removeItemAtPath:fileDir error:&error];
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"aboutMessage"];
    
    [hub hide:YES];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"提交成功，感谢您的反馈。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    sendOK = YES;
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    if(textView.text != nil && ![textView.text isEqualToString:@"" ] && !sendOK){
      
        [[NSUserDefaults standardUserDefaults]setObject:textView.text forKey:@"aboutMessage"];
    }else{
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"aboutMessage"];
    }
    [super viewDidDisappear:animated];
}


-(void)dealloc{
    [self removeObserver:self forKeyPath:@"imageKey"];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [textView resignFirstResponder];
}
@end
