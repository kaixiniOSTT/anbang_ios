//
//  BTNomalBaseViewController.m
//  BTMoveWorkCompany
//
//  Created by baiteng06 on 14-8-8.
//  Copyright (c) 2014年 baiteng06. All rights reserved.
//

#import "BTNomalBaseViewController.h"

@interface BTNomalBaseViewController ()

@end

@implementation BTNomalBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//-(void)viewWillAppear:(BOOL)animated
//{
//    if (IS_iOS7) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
//    }
//}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)initCustomBar
{
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
    
    _customBar = [[UIImageView alloc] init];
    _customBar.frame = CGRectMake(0, 0, Screen_Width, IS_iOS7?64:44);
    _customBar.userInteractionEnabled = YES;
    _customBar.backgroundColor = RGBACOLOR(213, 85, 50, 1);
    [self.view addSubview:_customBar];
    
    _navLeft = [UIButton buttonWithType:0];
    _navLeft.frame = CGRectMake(5, IS_iOS7?20:0, 44, 44);
    [_navLeft setImage:[UIImage imageNamed:@"backImage.png"] forState:UIControlStateNormal];
    [_navLeft addTarget:self action:@selector(navLeftBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_customBar addSubview:_navLeft];
    
    _navRight = [UIButton buttonWithType:0];
    _navRight.frame = CGRectMake(Screen_Width-44-5, IS_iOS7?20:0, 44, 44);
    _navRight.titleLabel.font = [UIFont systemFontOfSize:14];
    [_navRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_navRight setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_navRight addTarget:self action:@selector(navRightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_customBar addSubview:_navRight];
    
    _rightTitle = [[UILabel alloc]initWithFrame:CGRectMake(-39, 0, 75, 44)];
    _rightTitle.backgroundColor = [UIColor clearColor];
    _rightTitle.font = [UIFont fontWithName:@"Verdana-Bold" size:16];
    _rightTitle.textColor = [UIColor whiteColor];
    _rightTitle.textAlignment = NSTextAlignmentRight;;
    [_navRight addSubview:_rightTitle];
    
    _navTitle = [[UILabel alloc] init];
    _navTitle.frame = CGRectMake(44, IS_iOS7?20:0, Screen_Width -88, 44);
    _navTitle.textColor = [UIColor whiteColor];
    _navTitle.text = self.title;
    _navTitle.textAlignment = NSTextAlignmentCenter;
    _navTitle.backgroundColor = [UIColor clearColor];
    _navTitle.font = [UIFont fontWithName:@"Verdana-Bold" size:18];
    [_customBar addSubview:_navTitle];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBACOLOR(243, 243, 243, 1);
    [self initCustomBar];
}

#pragma mark - Actions
- (void)navLeftBtnAction:(UIButton *)btn
{ [self.navigationController popViewControllerAnimated:YES]; }

- (void)navRightBtnAction:(UIButton *)btn
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
