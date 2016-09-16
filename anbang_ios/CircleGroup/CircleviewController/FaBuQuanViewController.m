//
//  FaBuQuanViewController.m
//  FriendQuanPro
//
//  Created by MyLove on 15/7/10.
//  Copyright (c) 2015年 Double_yang. All rights reserved.
//

#import "FaBuQuanViewController.h"
#import "AFNetworking.h"
#import "CHImageSeeViewController.h"
#import "MBProgressHUD.h"

@interface FaBuQuanViewController ()
{
    
    NSMutableArray      *_imageArray;   // 存放图片
    UIImage             *_tempImage;    // 当前图片
    int           _imageIndex;    // 纪录添加到第几张了
    float infoHeight;   //活动详情高度
    UILabel *dianJiChaRu;//点击插入图片文字
    NSMutableArray *delImageArrary;
    NSMutableArray *chaRuImageArray;
    NSMutableArray *chaRuImageViewArray;
    UIButton *delChaRuBtn;//删除插入图片
    
    
    UIView *lineview2;
    UILabel *lblTishi;
    
    UILabel * uilabel;
    
    NSMutableArray * codeArray;
    
    NSMutableArray * allViewArray;
}
@property (nonatomic, retain) MBProgressHUD * hub;
@end

@implementation FaBuQuanViewController
@synthesize txtContent,lblNumber;
@synthesize photoView,btnPhoto;

- (void)startLoading
{
    if (!self.hub) {
        MBProgressHUD *hub = [[MBProgressHUD alloc] initWithView:self.view];
        hub.labelText = @"正在发布";
        [self.view addSubview:hub];
        self.hub = hub;
    }
    
    [self.hub show:YES];
    [self.view bringSubviewToFront:self.hub];
}

- (void)finishLoading
{
    if (!self.hub.hidden) {
        [self.hub hide:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _imageArray = [NSMutableArray arrayWithCapacity:0];
    chaRuImageArray = [NSMutableArray array];
    chaRuImageViewArray = [NSMutableArray array];
    delImageArrary = [NSMutableArray array];
    codeArray = [[NSMutableArray alloc]initWithCapacity:0];
    allViewArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    self.navTitle.text = @"朋友圈";
    self.rightTitle.text = @"发布";
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, IS_iOS7?64:44, Screen_Width, Screen_Height-64)];
    mainView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mainView];
    
    [self setUpForDismissKeyboard];
    
    //说明
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 150)];
    contentView.backgroundColor = [UIColor whiteColor];
    [mainView addSubview:contentView];
    
    txtContent = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, Screen_Width-20, 120)];
    txtContent.backgroundColor = [UIColor clearColor];
    txtContent.textColor = RGBACOLOR(61, 61, 61, 1);
    txtContent.font = [UIFont systemFontOfSize:15.0f];
    txtContent.delegate = self;
    [contentView addSubview:txtContent];
    
    uilabel = [[UILabel alloc] init];
    uilabel.frame =CGRectMake(15, 12, 100, 20);
    uilabel.text = @"说点什么吧~";
    uilabel.font = [UIFont systemFontOfSize:15.0f];
    uilabel.enabled = NO;//lable必须设置为不可用
    uilabel.backgroundColor = [UIColor clearColor];
    [contentView addSubview:uilabel];
    
    //分隔线
    UIView *lineview = [[UIView alloc] initWithFrame:CGRectMake(0, 149.5, Screen_Width, 0.5)];
    lineview.backgroundColor = RGBACOLOR(216, 216, 216, 1);
    [contentView addSubview:lineview];
    
    //计数
    lblNumber = [[UILabel alloc] initWithFrame:CGRectMake(10, 130, Screen_Width-20, 20)];
    lblNumber.text = @"1/150";
    lblNumber.textColor = RGBACOLOR(161, 161, 161, 1);
    lblNumber.font = [UIFont systemFontOfSize:15.0f];
    lblNumber.textAlignment = 2;
    lblNumber.backgroundColor = [UIColor clearColor];
    [contentView addSubview:lblNumber];
    
    //添加照片
    photoView = [[UIView alloc] initWithFrame:CGRectMake(0, 150, Screen_Width, 110)];
    photoView.backgroundColor = [UIColor whiteColor];
    [mainView addSubview:photoView];
    
    
    btnPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPhoto.frame = CGRectMake(8, 8, 70, 70);
    [btnPhoto setBackgroundImage:LOAD_IMAGE(@"event_012") forState:UIControlStateNormal];
    [btnPhoto addTarget:self action:@selector(addPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    [photoView addSubview:btnPhoto];
}

#pragma mark    - 动态计算高度和宽度
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

-(void)textViewDidChange:(UITextView *)textView{
    int txtLength = [txtContent.text length];
    if(txtLength<150){
        lblNumber.text = [NSString stringWithFormat:@"%d/150",txtLength];
    }else{
        [txtContent resignFirstResponder];
    }
    
    if (textView.text.length == 0) {
        uilabel.text = @"说点什么吧~!";
    }else{
        uilabel.text = @"";
    }
    
}

-(void)addPhotoAction:(UIButton *)sender{
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"添加图片"
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"本地图片",@"相机拍照",nil];
    menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [menu showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if  (buttonIndex == 0) {
        [self pickImage];//本地
    }
    else if(buttonIndex == 1) {
        [self snapImage];//拍照
    }
    
}

#pragma mark -------------上传图片---------------
- (void)snapImage
{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    ipc.delegate = self;
    ipc.allowsEditing = NO;
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)pickImage
{
    // 多选
    ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
    picker.maximumNumberOfSelection = 9;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showEmptyGroups=NO;
    picker.delegate=self;
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
            NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
            return duration >= 9;
        } else {
            return YES;
        }
    }];
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}



-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *) info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil);
    }
    
    UIImage *newImg = [self imageWithImageSimple:image scaledToSize:CGSizeMake(320, self.view.frame.size.height)];
    NSData *imageData = UIImageJPEGRepresentation(newImg, 0.5);
    [_imageArray addObject:imageData];

    [self dismissViewControllerAnimated:YES completion:nil];
    [self creatImageViews];
}

//图片尺寸
- (UIImage *)imageWithImageSimple:(UIImage *)image scaledToSize:(CGSize)newSize
{
    newSize.height = image.size.height*(newSize.width/image.size.width);
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  newImage;
}

#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_imageArray.count<9) {
            for (int i=0; i<assets.count; i++) {
                ALAsset *asset = assets[i];
                UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                CGSize size = CGSizeMake(image.size.width, image.size.height);
                UIGraphicsBeginImageContext(size);
                [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
                if (_imageArray.count<9) {
                    [_imageArray addObject:imageData];
                    [delImageArrary addObject:imageData];
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self creatImageViews];
            });
        }
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    NSString * isGengxin = [[NSUserDefaults standardUserDefaults]objectForKey:@"is_shanchu"];
    if ([isGengxin isEqualToString:@"1"]) {
        NSArray * array = [[NSUserDefaults standardUserDefaults]objectForKey:@"mu_image"];
        [_imageArray removeAllObjects];
        [_imageArray addObjectsFromArray:array];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"2" forKey:@"is_shanchu"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [self creatImageViews];
    }
}

- (void)creatImageViews
{
    for (int i=0; i<allViewArray.count; i++) {
        UIImageView * allView = (UIImageView *)[allViewArray objectAtIndex:i];
        [allView removeFromSuperview];
    }
    [allViewArray removeAllObjects];
    
    if (_imageArray.count<9) {
        for (int i=0; i<_imageArray.count; i++) {
            int w = i%4;
            int h = i/4;
            UIImageView * imageView = [[UIImageView alloc]init];
            imageView.frame = CGRectMake(8+78*w, 8+78*h, 70, 70);
            imageView.userInteractionEnabled = NO;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.backgroundColor = [UIColor clearColor];
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *picTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(picSingleTap:)];
            [picTapGesture setNumberOfTapsRequired:1];
            [imageView addGestureRecognizer:picTapGesture];
            imageView.image = [UIImage imageWithData:_imageArray[i]];
            [photoView addSubview:imageView];
            [allViewArray addObject:imageView];
        }
        btnPhoto.hidden = NO;
        btnPhoto.frame = CGRectMake(8+78*((_imageArray.count)%4), 8+78*((_imageArray.count)/4), 70, 70);
    }
    else{
        btnPhoto.hidden = YES;
        for (int i=0; i<_imageArray.count; i++) {
            int w = i%4;
            int h = i/4;
            UIImageView * imageView = [[UIImageView alloc]init];
            imageView.frame = CGRectMake(8+78*w, 8+78*h, 70, 70);
            imageView.userInteractionEnabled = NO;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.backgroundColor = [UIColor clearColor];
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *picTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(picSingleTap:)];
            [picTapGesture setNumberOfTapsRequired:1];
            [imageView addGestureRecognizer:picTapGesture];
            imageView.image = [UIImage imageWithData:_imageArray[i]];
            [photoView addSubview:imageView];
            [allViewArray addObject:imageView];
        }
    }
    photoView.frame = CGRectMake(0, 150, Screen_Width, 50+((_imageArray.count+1)/4*78)+((_imageArray.count+1)%5>0?78:0));
}

-(void)picSingleTap:(UITapGestureRecognizer *)tap
{
    CHImageSeeViewController * svc = [[CHImageSeeViewController alloc]init];
    svc.imageDataArray = _imageArray;
    svc.curString = [NSString stringWithFormat:@"%d",tap.view.tag+1];
    [self.navigationController pushViewController:svc animated:YES];
}

-(void)imageTap:(UITapGestureRecognizer *)tap
{
    
    for (UIImageView *imageV in chaRuImageArray) {
        if (imageV.tag == tap.view.tag) {
            [chaRuImageViewArray removeObject:imageV];
            [imageV removeFromSuperview];
        }
    }
    NSData *delImageData = delImageArrary[tap.view.tag];
    [_imageArray removeObject:delImageData];
    
    NSUInteger withCount = _imageArray.count;
    
    if (_imageArray.count == 0) {
        
        [chaRuImageViewArray removeAllObjects];
        [chaRuImageArray removeAllObjects];
        [_imageArray removeAllObjects];
        [delImageArrary removeAllObjects];
        
        btnPhoto.frame = CGRectMake(5+withCount%4*78, withCount/4*78+10, 68, 68);
        btnPhoto.hidden = NO;
        dianJiChaRu.hidden = NO; //文字隐藏
        btnPhoto.userInteractionEnabled = YES;
        delChaRuBtn.hidden = YES;//隐藏删除按钮
    }else{
        btnPhoto.frame = CGRectMake(5+withCount%4*78, withCount/4*32+10, 32, 32);
        
        [btnPhoto setImage:LOAD_IMAGE(@"work_add_01") forState:UIControlStateNormal];
        
        btnPhoto.hidden = NO;
        
        delChaRuBtn.frame = CGRectMake(btnPhoto.frame.origin.x,btnPhoto.frame.origin.y+5+32, 32, 32);
        for (int i = 0 ; i <_imageArray.count; i++) {
            UIImageView *aView = chaRuImageViewArray[i];
            aView.frame = CGRectMake(5+i%4*78, i/4*78+10, 68, 68);
        }
    }
    
}
#pragma mark - 点击任意处，收回键盘
//回收小键盘
- (void)setUpForDismissKeyboard{
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

-(void)viewWillDisappear:(BOOL)animated
{
    [txtContent resignFirstResponder];
}
- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    //此method会将self.view里所有的subview的first responder都resign掉
    
    [self.view endEditing:YES];
}

-(void)navLeftBtnAction:(UIButton *)btn
{
    [txtContent resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)navRightBtnAction:(UIButton *)btn
{
    if (txtContent.text.length>0 || _imageArray.count>0) {
        [self startLoading];
        if (_imageArray.count>0) {
            //有图发布
            for (int i=0; i<_imageArray.count; i++) {
                [self upLoadImageData:[_imageArray objectAtIndex:i]];
            }
        }
        else{
            //无图发布
            [self sendQuanData:txtContent.text];
        }
    }
}

//上传图片
-(void) upLoadImageData:(NSData *)imageData
{
    NSString *urlstr = ResourcesURL;
    NSURL *myurl = [NSURL URLWithString:urlstr];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:myurl];
    request.delegate = self;
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"image/png"];//这里的value值 需与服务器端 一致
    //设置表单提交项
    [request setPostBody:imageData];
    [request setUploadProgressDelegate:self];
    request.showAccurateProgress = YES;
    [request buildRequestHeaders];
    [request setTimeOutSeconds:120];
    
    //使用block 否则退出再进入时会造成崩溃
    [request setCompletionBlock:^{
        NSData *jsonData =[request responseData];
        //输出接收到的字符串
        NSDictionary *d = [jsonData objectFromJSONData];
        NSString * codeStr = [d objectForKey:@"TFS_FILE_NAME"];
        NSString * newString = [NSString stringWithFormat:@"http://183.136.198.235:7500/v1/tfs/%@",codeStr];
        [codeArray addObject:newString];
        
        if (codeArray.count == _imageArray.count) {
            NSString * imgStr = [codeArray componentsJoinedByString:@","];
            //发布
            [self sendQuanData:txtContent.text withImageStr:imgStr];
        }
    }];
    
    [request setFailedBlock:^{
    }];
    
    
    [request startAsynchronous];
    // [request setShouldContinueWhenAppEntersBackground:YES];
    
}

//有图发布
-(void)sendQuanData:(NSString *)conString withImageStr:(NSString *)imgStr
{
    NSString * string = @"http://104.238.236.144//cfapi/pubcontent";
    NSMutableDictionary * paeaments = [NSMutableDictionary dictionary];
    [paeaments setObject:conString forKey:@"content"];
    [paeaments setObject:imgStr forKey:@"photolist"];
    [paeaments setObject:MY_USER_NAME forKey:@"userid"];
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    [manager POST:string parameters:paeaments success:^(AFHTTPRequestOperation * operation, id responseObject){
        [self finishLoading];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSDictionary * resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if ([[resultDic objectForKey:@"error"] isKindOfClass:[NSNull class]]) {
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"Fa_bu"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [txtContent resignFirstResponder];
            if (self.navigationController.viewControllers.count == 5) {
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
            }
            else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation,NSError * orrer){
        [self finishLoading];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

//无图发布
-(void)sendQuanData:(NSString *)conString
{
    NSString * string = @"http://104.238.236.144//cfapi/pubcontent";
    NSMutableDictionary * paeaments = [NSMutableDictionary dictionary];
    [paeaments setObject:conString forKey:@"content"];
    [paeaments setObject:@"" forKey:@"photolist"];
    [paeaments setObject:MY_USER_NAME forKey:@"userid"];
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    [manager POST:string parameters:paeaments success:^(AFHTTPRequestOperation * operation, id responseObject){
        [self finishLoading];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSDictionary * resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if ([[resultDic objectForKey:@"error"] isKindOfClass:[NSNull class]]) {
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"Fa_bu"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [txtContent resignFirstResponder];
            if (self.navigationController.viewControllers.count == 5) {
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
            }
            else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation,NSError * orrer){
        [self finishLoading];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
