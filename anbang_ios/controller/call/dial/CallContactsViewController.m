//
//  CallContactsViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 14-11-20.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "CallContactsViewController.h"
#import "ContactsCRUD.h"
#import "UIImageView+WebCache.h"
#import "APPRTCViewController.h"
#import "UserInfoCRUD.h"
#import "VoipModule.h"
#import "ASIHTTPRequest.h"
#import "CHAppDelegate.h"
#import "GBPathImageView.h"
#import "BlackListCRUD.h"
#import "ContactsCRUD.h"
#import "ChatViewController2.h"
#import "APPRTCViewController.h"
#import "ContactsRemarkNameTableViewController.h"
#import "IdGenerator.h"
#import "UIButton+Bootstrap.h"
#import "ChatBuddyCRUD.h"
#import "ChatMessageCRUD.h"
#import "JSMessageSoundEffect.h"
#import "UIImageView+WebCache.h"


#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif
@interface CallContactsViewController ()

@end

@implementation CallContactsViewController
@synthesize callContactsArray;
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
    int cutHeight=0;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
        self.navigationController.navigationBar.translucent = NO;
        
        cutHeight=44;
        
    }else  {
        cutHeight=113;
    }

    
    callContactsArray = [ContactsCRUD queryContactsList:MY_JID];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-65-cutHeight) style:UITableViewStylePlain];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
   // _tableView.allowsMultipleSelection = NO;
    //[_tableView setEditing:!self.tableView.isEditing animated:YES];
    //self.tableView.tag = UITableViewCellAccessoryCheckmark ;
    
    [self.view addSubview:_tableView];

    self.view.frame =CGRectMake(0, 0, KCurrWidth, KCurrHeight);
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
               return callContactsArray.count;
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    static NSString *CellIdentifier = @"Cell";
    //    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //
    NSString *cellId = @"CellId";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }

    
    NSDictionary *buddyDic = [self.callContactsArray objectAtIndex:[indexPath row]];
    
    NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [buddyDic objectForKey:@"avatar"]];
    
    [cell.imageView  setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
  
        CGRect rect = [cell.textLabel textRectForBounds:cell.textLabel.frame limitedToNumberOfLines:0];
        // 設置顯示榘形大小
        
        CGSize itemSize = CGSizeMake(45, 45);
        
        rect.size =itemSize;
        // 重置列文本區域
        cell.textLabel.frame = CGRectMake(0, 0, KCurrWidth-100, cell.frame.size.height);
        // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 3.0;
        cell.imageView.layer.borderWidth = 0.0;
        [cell.imageView setFrame:CGRectMake(10, 10,35,35)];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIGraphicsBeginImageContext(itemSize);
    
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.imageView.layer.borderColor = [kMainColor4 CGColor];
    
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 15, 150, 30)];
    nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [nameLabel setText:[buddyDic objectForKey:@"nickName"]];
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.backgroundColor = [UIColor clearColor];
    
    [cell.contentView addSubview:nameLabel];

    //cell.textLabel.text = [buddyDic objectForKey:@"nickName"];
    
    UIImage *sendBtnBackground = [UIImage imageNamed:@"user_call"];
    UIButton* callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    callBtn.frame = CGRectMake(KCurrWidth - 45, 10, 28, 28);
    [callBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    [callBtn addTarget:self action:@selector(contactsPlayDial:) forControlEvents:UIControlEventTouchUpInside];
    [callBtn setImage:sendBtnBackground forState:UIControlStateNormal];
    [callBtn setTintColor:[UIColor grayColor]];
    callBtn.backgroundColor = [UIColor clearColor];
    //[callBtn.layer setCornerRadius:5.0];
    callBtn.tag = indexPath.row;
    
    UIImage *sendVideoBtnBackground = [UIImage imageNamed:@"user_video"];
    UIButton* videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    videoBtn.frame = CGRectMake(KCurrWidth - 100, 10, 28, 28);
    [videoBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    [videoBtn addTarget:self action:@selector(contactsPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    [videoBtn setImage:sendVideoBtnBackground forState:UIControlStateNormal];
    [videoBtn setTintColor:[UIColor grayColor]];
    videoBtn.backgroundColor = [UIColor clearColor];
    //[videoBtn.layer setCornerRadius:5.0];
    videoBtn.tag = indexPath.row;
    [cell addSubview:callBtn];
    [cell addSubview:videoBtn];
     cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}




#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //start a Chat
  }



//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


/*---视频语音start-----------------------------------------------------------------------------------*/
//打电话
-(void)contactsPlayDial:(UIButton*)btn{
    //NSLog(@"开始拨打电话");
#if !TARGET_IPHONE_SIMULATOR
    NSDictionary *buddyDic = [self.callContactsArray objectAtIndex:btn.tag];
    NSString *jid = [buddyDic objectForKey:@"userName"];
    //NSLog(@"****%@",jid);
    if ([StrUtility isBlankString:jid]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邦邦社区提示" message:@"请输入邦邦社区号码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
  
    XMPPJID *to = [XMPPJID jidWithString:jid resource:@"Hisuper"];
    NSString *toStrJID = [jid stringByAppendingFormat:@"%@",@"/Hisuper"];
    NSString* sessionID = [XMPPStream generateUUID];
    if(YES)
    {
        APPRTCViewController *appView = [[APPRTCViewController alloc]init];
        //NSLog(@"******%@",[to full]);
        appView.from = toStrJID;
        appView.isCaller = YES;
        appView.isVideo = NO;
        appView.msessionID = sessionID;
        
        appView.ivavatar.layer.masksToBounds = YES;
        appView.ivavatar.layer.cornerRadius = 3.0;
        appView.ivavatar.layer.borderWidth = 3.0;
        appView.ivavatar.backgroundColor = kMainColor4;
        appView.ivavatar.layer.borderColor = [[UIColor whiteColor]CGColor];

        [self.view.window.rootViewController presentViewController:appView animated:YES completion:^{
            
            //            CHAppDelegate *app = [UIApplication sharedApplication].delegate;
            [appView.lbname setText:to.user];
            
            
            NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [UserInfoCRUD queryUserInfoAvatar:jid]];
            
            UIImageView *headImageView = [[UIImageView alloc]init];
            headImageView.backgroundColor = [UIColor clearColor];
            
            [headImageView setImageWithURL:[NSURL URLWithString:avatarURL]
                          placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
            
            if(headImageView.image){
                [appView.ivavatar setImage:headImageView.image];
            }else{
                [appView.ivavatar setImage:[UIImage imageNamed:@"defaultUser.png"]];
            }
            appView.ivavatar.layer.masksToBounds = YES;
            appView.ivavatar.layer.cornerRadius = 3.0;
            appView.ivavatar.layer.borderWidth = 3.0;
            appView.ivavatar.backgroundColor = kMainColor4;
            appView.ivavatar.layer.borderColor = [[UIColor whiteColor]CGColor];
            
        }];
    }
    else
    {
        //[self showAlert:@"呼叫失败"];
        
        
    }
#endif
}

//开视频
-(void)contactsPlayVideo:(UIButton *)btn{
    //NSLog(@"开始语音视频");
#if !TARGET_IPHONE_SIMULATOR
    NSDictionary *buddyDic = [self.callContactsArray objectAtIndex:btn.tag];
    NSString *jid = [buddyDic objectForKey:@"userName"];
    XMPPJID *to = [XMPPJID jidWithString:jid resource:@"Hisuper"];
    NSString *toStrJID = [jid stringByAppendingFormat:@"%@",@"/Hisuper"];
    NSString* sessionID = [XMPPStream generateUUID];
    if(YES)
    {
        APPRTCViewController *appView = [[APPRTCViewController alloc]init];
        //NSLog(@"******%@",[to full]);
        appView.from = toStrJID;
        appView.isCaller = YES;
        appView.isVideo = YES;
        appView.msessionID = sessionID;

        [self.view.window.rootViewController presentViewController:appView animated:YES completion:^{
            //CHAppDelegate *appDelegate = (CHAppDelegate *)[[UIApplication sharedApplication] delegate];
            // appDelegate.tabBarBG.hidden = YES;
            
            [appView.lbname setText:to.user];
            
            
            NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [UserInfoCRUD queryUserInfoAvatar:jid]];
            
            UIImageView *headImageView = [[UIImageView alloc]init];
            headImageView.backgroundColor = [UIColor clearColor];
            
            [headImageView setImageWithURL:[NSURL URLWithString:avatarURL]
                          placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
            
            if(headImageView.image){
                [appView.ivavatar setImage:headImageView.image];
            }else{
                [appView.ivavatar setImage:[UIImage imageNamed:@"defaultUser.png"]];
            }
            appView.ivavatar.layer.masksToBounds = YES;
            appView.ivavatar.layer.cornerRadius = 3.0;
            appView.ivavatar.layer.borderWidth = 3.0;
            appView.ivavatar.backgroundColor = kMainColor4;
            appView.ivavatar.layer.borderColor = [[UIColor whiteColor]CGColor];
            

        }];
        
    }
    else
    {
        //呼叫失败
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"public.callFailure",@"message") delegate:nil cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") otherButtonTitles:nil, nil];
        [alert show];
        
    }
#endif
}
/*---视频语音end-----------------------------------------------------------------------------------*/

@end
