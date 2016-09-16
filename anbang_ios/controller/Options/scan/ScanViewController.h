//
//  ChatCustomerViewController.h
//  BaseProject
//
//  Created by silenceSky  on 13-11-13.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#if !TARGET_IPHONE_SIMULATOR
#import "ZBarSDK.h"
#endif
@interface ScanViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate
#if !TARGET_IPHONE_SIMULATOR
,ZBarCaptureDelegate
#endif
>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    int cutHeight;
    NSString *scanURL;
    
    //手电筒
    BOOL isLightOn;
    AVCaptureDevice *device;
}
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, retain) UIImageView * line;
@property (retain,nonatomic) UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) NSMutableDictionary *personalData;

@property BOOL isLightOn;
@end
