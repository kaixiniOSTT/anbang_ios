//
//  RoyaDialView.h
//  anbang_ios
//
//  Created by seeko on 14-4-23.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoyaDialViewDelegate.h"
//@protocol RoyaDialViewDelegate;

@interface RoyaDialView : UIView<UITextFieldDelegate>{
    
    BOOL  mIsLayOn;
//    id<RoyaDialViewDelegate> delegate;
    int height;
    int height2;
    BOOL isPhone;
    
}


@property(nonatomic,assign) id<RoyaDialViewDelegate> delegate;

@property(strong,nonatomic) UIButton *btnOffOn;

@property(strong,nonatomic) UITextField *txtNumber;

@property(strong,nonatomic) UIButton *btn0;

@property(strong,nonatomic) UIButton *btn1;

@property(strong,nonatomic) UIButton *btn2;

@property(strong,nonatomic) UIButton *btn3;

@property(strong,nonatomic) UIButton *btn4;

@property(strong,nonatomic) UIButton *btn5;

@property(strong,nonatomic) UIButton *btn6;

@property(strong,nonatomic) UIButton *btn7;

@property(strong,nonatomic) UIButton *btn8;

@property(strong,nonatomic) UIButton *btn9;

@property(strong,nonatomic) UIButton *btnDial;

@property(strong,nonatomic) UIButton *btnUndo;

@property(strong,nonatomic) UIButton *btn_; //#号
@property(strong,nonatomic) UIButton *btnVideo; //视频
@property(strong,nonatomic) UIButton *btnDown;
-(IBAction)onKeyPressed:(id)sender;

-(IBAction)onButtonOnOffPressed:(id)sender;

-(void)showInView:(UIView *)view;
-(void)showNum:(NSString *)num;
-(void)playVideo;
-(void)playDial;

@end
