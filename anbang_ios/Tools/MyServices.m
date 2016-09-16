//
//  MyServices.m
//  anbang_ios
//
//  Created by silenceSky  on 14-11-6.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "MyServices.h"
#import "JSONKit.h"
#import "AddGroupResultViewController.h"
#import "AddContactsResultViewController.h"
#import "APPRTCViewController.h"
#import "UIImageView+WebCache.h"
#import "ContactInfo.h"
#import "ContactsCRUD.h"

@implementation MyServices

//检测版本
+(void)onCheckVersion
{
    
    //TODO 先用企业版的更新
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.anbang.bbchat1"]) {
        //appstroe 更新
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
            //CFShow((__bridge CFTypeRef)(infoDic));
            NSString *currentVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
            NSLog(@"*******%@",currentVersion);
            //http://itunes.apple.com/cn/lookup?id=526657411
            NSString *URL = @"http://itunes.apple.com/lookup?id=921359047";
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:URL]];
            [request setHTTPMethod:@"POST"];
            
            NSHTTPURLResponse *urlResponse = nil;
            NSError *error = nil;
            NSData *recervedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
            
            NSString *results = [[NSString alloc] initWithBytes:[recervedData bytes] length:[recervedData length] encoding:NSUTF8StringEncoding];
            //  NSDictionary *dic = [results JSONValue];
            
            NSData* jsonData = [results dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [jsonData objectFromJSONData];
            
            NSArray *infoArray = [dic objectForKey:@"results"];
            if ([infoArray count]) {
                NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
                NSString *lastVersion = [releaseInfo objectForKey:@"version"];
                
                if (![lastVersion isEqualToString:currentVersion]) {
                    NSString* trackViewUrl = [releaseInfo objectForKey:@"trackViewUrl"];
                    //NSLog(@"******%@",trackViewUrl);
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:trackViewUrl forKey:@"NNUD_AppStoreURL"];
                    [defaults synchronize];
                    
                    //记录提示时间
                     NSDate *nowDate = [NSDate date];
                    [defaults setObject:nowDate forKey:@"NSUD_AppUpdatePromptTime"];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"checkVersion.message",@"message")delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"title") otherButtonTitles:NSLocalizedString(@"public.alert.ok",@"title"), nil];
                    alert.tag = 10001;
                    [alert show];
                }
                else
                {
                    //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"checkVersion.message2",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
                    //            alert.tag = 10002;
                    //            [alert show];
                    //            [alert release];
                }
            }
            
        });
    }else{        
        NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/check-update"];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"type" stringValue:@"get"];
        [iq addAttributeWithName:@"id" stringValue:@"check-update"];
        [iq addChild:queryElement];
        // NSLog(@"jid:%@",myJID);
        NSLog(@"组装后的xml:%@",iq);
        [[XMPPServer xmppStream] sendElement:iq];
        
    }
}


+(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==10001) {
        if (buttonIndex==1) {
            //NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com"];
            // NSLog(@"********%@",trackViewUrl);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

            NSURL *url = [NSURL URLWithString:[defaults objectForKey:@"NNUD_AppStoreURL"]];
            [[UIApplication sharedApplication]openURL:url];
            
        }
    }
}




//检查电话号码
+(BOOL)checkUSPhoneNumber:(NSString*)phoneNumber
{
    NSLog(@"phoneNumber--->%@",phoneNumber);
    if (phoneNumber == nil || [phoneNumber length]<1)
    {
        return NO;
    }
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:&error];
    NSRange inputRange = NSMakeRange(0, [phoneNumber length]);
    NSArray *matches = [detector matchesInString:phoneNumber options:0 range:inputRange];
    if ([matches count] == 0)
    {
        return NO;
    }
    NSTextCheckingResult *result = (NSTextCheckingResult *)[matches objectAtIndex:0];
    if ([result resultType] == NSTextCheckingTypePhoneNumber && result.range.location == inputRange.location && result.range.length == inputRange.length)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//扫瞄二维码结果
+(void)receiveScanResult:(NSNotification *) notify target:(UIViewController *)vc
{
    NSString *userName = @"";
    
    NSDictionary* dic = [notify object];
    
    JLLog_I(@"dic object=%@", dic);
    
    NSString *type = [dic objectForKey:@"type"];
    NSString *jid = [dic objectForKey:@"jid"];
    NSString *nickName = [dic objectForKey:@"nickName"];
    NSString *avatar = [dic objectForKey:@"avatar"];
    int gender = [[dic objectForKey:@"gender"] intValue];
    int accountType = [[dic objectForKey:@"accountType"] intValue];
    
    NSString*str_character = @"@";
    NSRange senderRange = [jid rangeOfString:str_character];
    if ([jid rangeOfString:str_character].location != NSNotFound) {
        userName = [jid substringToIndex:senderRange.location];
    }
    
    if ([type isEqualToString:@"circle"]) {
       // AddGroupResultViewController *addGroupResultVC=[[AddGroupResultViewController alloc] initWithNibName:@"AddGroupResultViewController" bundle:nil];
       // addGroupResultVC.groupName = nickName;
       // addGroupResultVC.groupJID = jid;
       // addGroupResultVC.hidesBottomBarWhenPushed=YES;
       // [vc.navigationController pushViewController:addGroupResultVC animated:YES];
        
        [self sendCircleDetailIQWithJID:jid];
        
    }else if([type isEqualToString:@"user"]){
        
        NSString *signature = dic[@"signature"];
        NSString *areaId = dic[@"areaId"];
        
        ContactInfo *contactInfo = [[ContactInfo alloc] init];
        contactInfo.jid = jid;
        UserInfo *userInfo = [[UserInfo alloc] init];
        userInfo.avatar = avatar;
        userInfo.jid = jid;
        userInfo.nickName = nickName;
        userInfo.gender = gender;
        userInfo.accountType = accountType;
        userInfo.signature = signature;
        userInfo.areaId = areaId;
        contactInfo.userinfo = userInfo;
        
        [vc.navigationController pushViewController:contactInfo animated:YES];
    }else{
        JLLog_I(@"Unknown situation");
    }
}

// Request circle detail
// <iq id="Oi13S-10" type="get" to="circle.ab-insurance.com">
// <query xmlns="http://www.nihualao.com/xmpp/circle/information">
// <circle jid="10300@circle.ab-insurance.com" />
// </query>
// </iq>
+ (void)sendCircleDetailIQWithJID:(NSString *)aJID {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"id" stringValue:@"AI_Circle_Detail_Request"];
        [iq addAttributeWithName:@"type" stringValue:@"get"];
        [iq addAttributeWithName:@"to" stringValue:@"circle.ab-insurance.com"];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:kCircleDetailNameSpace];
        NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
        [circle addAttributeWithName:@"jid" stringValue:aJID];
        
        [query addChild:circle];
        [iq addChild:query];
        JLLog_I(@"<circle request> %@", iq);
        [[XMPPServer xmppStream] sendElement:iq];
    });
}


//打电话
+(void)playDial:(NSString *)callJID name:(NSString *)name avatar:(NSString *)avatar target:(UIViewController *)target{
    // NSLog(@"开始拨打电话");
#if !TARGET_IPHONE_SIMULATOR
    XMPPJID *to = [XMPPJID jidWithString:callJID resource:@"Hisuper"];
    NSString* sessionID = [XMPPStream generateUUID];
    NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, avatar];
    if(![StrUtility isBlankString:callJID])
    {
        APPRTCViewController *appView = [[APPRTCViewController alloc]init];
        appView.from = [to full];
        appView.isCaller = YES;
        appView.isVideo = NO;
        appView.msessionID = sessionID;
        [target.navigationController presentViewController:appView animated:YES completion:^{
        NSString *remarkName = [ContactsCRUD queryContactsRemarkName:callJID];
       [appView.lbname setText:[StrUtility string:remarkName defaultValue:name]];
            //            NSString *photoImage=[[NSUserDefaults standardUserDefaults]objectForKey:@"phoneImage"];
            UIImage *image = [UIImage imageNamed:@"defaultUser.png"];
            if (![avatar isEqualToString:@""]) {
                //                NSString *photoImageUrl=[NSString stringWithFormat:@"%@/%@",ResourcesURL,_contactsAvatarURL];
                UIImageView *photoView=[[UIImageView alloc]initWithFrame:CGRectMake(240, 5, 50, 50)];
                
                [photoView setImageWithURL:[NSURL URLWithString:avatarURL]
                          placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
                if (photoView.image) {
                    [appView.ivavatar setImage:photoView.image];
                }else{
                    [appView.ivavatar setImage:image];
                }
            }else{
                [appView.ivavatar setImage:image];
                
            }
            appView.ivavatar.layer.masksToBounds = YES;
            appView.ivavatar.layer.cornerRadius = 3.0;
            appView.ivavatar.layer.borderWidth = 3.0;
            appView.ivavatar.backgroundColor = kMainColor4;
            appView.ivavatar.layer.borderColor = [[UIColor whiteColor]CGColor];
        }];
 
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"public.callFailure",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.cancel",@"action") otherButtonTitles:nil, nil];
        [alert show];
        
    }
#endif
}


@end
