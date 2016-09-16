//
//  InvitationURLViewController.m
//  anbang_ios
//
//  Created by seeko on 14-5-30.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "InvitationURLViewController.h"
#import "ChooseCircleViewController.h"
#import "CHAppDelegate.h"
#import "QrCodeViewController.h"
#import "GroupQrCodeViewController.h"
@interface InvitationURLViewController ()
{
    UILabel *labcircleName;
}
@end

@implementation InvitationURLViewController
@synthesize strGroupJID = _strGroupJID;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"邀请好友";
    UIBarButtonItem *rightBar=[[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sendInvitation)];
    [self.navigationItem setRightBarButtonItem:rightBar];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(10, Both_Bar_Height+20, 300, 50)];
    label.text=@"你想让朋友通过网址下载安装下后加入哪个圈子？";
    label.numberOfLines = 0;
    [label setTextColor:[UIColor lightGrayColor]];
    label.font=[UIFont boldSystemFontOfSize:16];
    label.textAlignment=1;
    label.textColor=[UIColor lightGrayColor];
    [self.view addSubview:label];
    
    UIButton *btnCircle=[UIButton buttonWithType:UIButtonTypeCustom];
    btnCircle.frame=CGRectMake(10, Both_Bar_Height+80, 300, 35);
    [btnCircle setBackgroundImage:[UIImage imageNamed:@"v2_btn_more_pressed.9.png"] forState:UIControlStateNormal];
    btnCircle.contentHorizontalAlignment=1;
    [btnCircle setTitle:@"选择圈子" forState:UIControlStateNormal];
    [btnCircle setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1] forState:UIControlStateNormal];
    [btnCircle setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.5] forState:UIControlStateHighlighted];
    [btnCircle addTarget:self action:@selector(joinCircle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCircle];
    labcircleName=[[UILabel alloc]initWithFrame:CGRectMake(150, 0, 100, 35)];
    //    [circleName setBackgroundColor:[UIColor redColor]];
    labcircleName.text=@"(直接加好友)";
    [labcircleName setTextColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1]];
    //    [btnCircle.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    //    [btnCircle.layer setBorderWidth:1.0]; //边框宽度
    [btnCircle addSubview:labcircleName];
    UIImageView *image=[[UIImageView alloc]initWithFrame:CGRectMake(275, 10, 5, 15)];
    image.image=[UIImage imageNamed:@"tm_profile_popup_ico_m.png"];
    
    [btnCircle addSubview:image];
    
}


-(void)viewWillAppear:(BOOL)animated{
    CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.tabBarBG.hidden=YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)sendInvitation{
    if ([labcircleName.text isEqualToString:@"(直接加好友)"]) {
        //个人二维码
        QrCodeViewController *qrCodeView=[[QrCodeViewController alloc]init];
        qrCodeView.title=@"个人二维码";
        if ([[NSUserDefaults standardUserDefaults]stringForKey:@"name"].length>0){
            qrCodeView.labNmaetext =[[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
        }else{
            qrCodeView.labNmaetext=[[NSUserDefaults standardUserDefaults]stringForKey:@"userName"];
        }
        [self.navigationController pushViewController:qrCodeView animated:YES];
    }else{
        //圈子二维码
        
        //NSLog(@"*******%@",_strGroupJID);
        
        GroupQrCodeViewController *groupQrCode=[[GroupQrCodeViewController alloc]init];
        groupQrCode.groupJID=_strGroupJID;
        groupQrCode.groupName=labcircleName.text;
        
        [self.navigationController pushViewController:groupQrCode animated:YES];
    }
}
-(void)joinCircle{
    
    ChooseCircleViewController *chooseCirceleView=[[ChooseCircleViewController alloc]init];
    chooseCirceleView.delegate=self;
    [self.navigationController pushViewController:chooseCirceleView animated:YES];
    
}
#pragma mark ChooseCircleViewDelegate
-(void)setCellValue:(NSString *)string groundJID:(NSString *)groundJID{
    //    circleName=[NSString stringWithString:string];
    NSLog(@"*******%@",groundJID);
    labcircleName.text=string;
    _strGroupJID=groundJID;
    
    // NSLog(@"***********%@",_strGroupJID);
}



-(void)dealloc{
    
}

@end
