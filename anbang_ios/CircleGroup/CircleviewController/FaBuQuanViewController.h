//
//  FaBuQuanViewController.h
//  FriendQuanPro
//
//  Created by MyLove on 15/7/10.
//  Copyright (c) 2015年 Double_yang. All rights reserved.
//

#import "BTNomalBaseViewController.h"
#import "ZYQAssetPickerController.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"

@interface FaBuQuanViewController : BTNomalBaseViewController<UITextViewDelegate,UIActionSheetDelegate,ZYQAssetPickerControllerDelegate,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UITextView *txtContent;
@property (nonatomic, strong) UILabel *lblNumber;

@property (nonatomic, strong) UIView *photoView;
@property (nonatomic, strong) UIButton *btnPhoto;

@end
