//
//  ViewController.h
//  StrapButton
//
//  Created by Oskur on 2013-09-29.
//  Copyright (c) 2013 Oskar Groth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

#import "CallRecordsViewController.h"
#import "CallContactsViewController.h"



@interface DialViewController2 : UIViewController<UITextFieldDelegate>{
    UITextField *numText;
    UISegmentedControl *segmentedControl;
    CallRecordsViewController *callRecordsVC;
    CallContactsViewController *callContactsVC;
     BOOL isPhone;
}
@property (strong, nonatomic) IBOutlet UIButton *defaultButton;
@property (strong, nonatomic) IBOutlet UIButton *defaultButton2;
@property (strong, nonatomic) IBOutlet UIButton *defaultButton3;
@property (strong, nonatomic) IBOutlet UIButton *defaultButton4;
@property (strong, nonatomic) IBOutlet UIButton *defaultButton5;
@property (strong, nonatomic) IBOutlet UIButton *defaultButton6;
@property (strong, nonatomic) IBOutlet UIButton *defaultButton7;
@property (strong, nonatomic) IBOutlet UIButton *defaultButton8;
@property (strong, nonatomic) IBOutlet UIButton *defaultButton9;
@property (strong, nonatomic) IBOutlet UIButton *defaultButton0;

@property (strong, nonatomic) IBOutlet UIButton *deleteBut;

@property (strong, nonatomic) IBOutlet UIButton *primaryButton;
@property (strong, nonatomic) IBOutlet UIButton *successButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *warningButton;
@property (strong, nonatomic) IBOutlet UIButton *dangerButton;
@property (strong, nonatomic) IBOutlet UIButton *bookmarkButton;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIButton *downloadButton;
@property (strong, nonatomic) IBOutlet UIButton *calendarButton;
@property (strong, nonatomic) IBOutlet UIButton *favoriteButton;



@end
