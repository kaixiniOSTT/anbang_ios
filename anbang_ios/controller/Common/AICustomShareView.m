//
//  AICustomShareView.m
//  anbang_ios
//
//  Created by Kim on 15/7/28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AICustomShareView.h"
#import <ShareSDK/ShareSDK.h>
#import "AIShareButton.h"

@implementation AICustomShareView
{
    void(^_completedBlock)(AISharePlatform platform, NSDictionary *publicContent);
}

static NSDictionary *_publishContent;

-(void)shareWithContent:(NSDictionary*)publishContent complete:(void (^)(AISharePlatform plat, NSDictionary *d))completedBlock
{
    
    _publishContent = publishContent;
    _completedBlock = completedBlock;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    blackView.backgroundColor = ColorWithAlpha(@"#000000", 0.5);
    blackView.tag = 440;
    [window addSubview:blackView];
    
    CGFloat fontHeight = AB_FONT_12.lineHeight;
    CGFloat titleFontHeight = AB_FONT_15.lineHeight;
    CGFloat marginLeft = (Screen_Width - 4*45*kScreenScale)/10;
    CGFloat buttonWidth = 45*kScreenScale + 2*marginLeft;

    UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake(0, Screen_Height - 217*kScreenScale-titleFontHeight*2-fontHeight*2, Screen_Width, 217*kScreenScale+titleFontHeight*2+fontHeight*2)];
    shareView.backgroundColor = Color(@"#f6f6f6");
    shareView.tag = 441;
    [window addSubview:shareView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20*kScreenScale, shareView.frame.size.width, titleFontHeight)];
    titleLabel.text = @"分享到";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = AB_FONT_15;
    titleLabel.textColor = AB_Color_9c958a;
    [shareView addSubview:titleLabel];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(23*kScreenScale, titleLabel.frame.origin.y + titleFontHeight + 20*kScreenScale, Screen_Width - 23*kScreenScale*2, 1)];
    topLine.backgroundColor = Color(@"#e7e2dd");

    [shareView addSubview:topLine];
    
//    NSArray *btnImages = @[@"icon_bbfriend", @"icon_bbcircle", @"icon_wxfriend", @"icon_wxcircle", @"icon_qqfriend", @"icon_qqzone", @"icon_weibo", @"icon_browser"];
//    NSArray *btnTitles = @[@"邦邦好友", @"邦邦朋友圈",@"微信好友", @"微信朋友圈", @"QQ好友", @"QQ空间", @"新浪微博", @"浏览器打开"];
    NSArray *btnImages = @[@"icon_bbfriend", @"icon_bbcircle", @"icon_wxfriend", @"icon_wxcircle", @"icon_browser"];
    NSArray *btnTitles = @[@"邦邦好友", @"邦邦朋友圈",@"微信好友", @"微信朋友圈", @"浏览器打开"];
    for (NSInteger i=0; i<btnImages.count; i++) {
        CGFloat top = 0.0f;
        if (i<4) {
            top = 15*kScreenScale;
            
        }else{
            top = (15+45+15)*kScreenScale+fontHeight;
        }
        
        AIShareButton *button = [AIShareButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(marginLeft+(i%4)*buttonWidth,
                                  topLine.frame.origin.y + topLine.frame.size.height+top,
                                  buttonWidth,
                                  45*kScreenScale+fontHeight);
        button.titleLabel.font = AB_FONT_12;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setImage:[UIImage imageNamed:btnImages[i]] forState:UIControlStateNormal];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button setTitle:btnTitles[i] forState:UIControlStateNormal];
        [button setTitleColor:Color(@"2a2a2a") forState:UIControlStateNormal];
//        button.layer.borderColor = [UIColor blackColor].CGColor;
//        button.layer.borderWidth = 1;
        
        button.tag = 331+i;
        [button addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:button];
    }
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(23*kScreenScale, topLine.frame.origin.y + (45*2+15*3)*kScreenScale+fontHeight*2, Screen_Width-23*kScreenScale*2, 1)];
    bottomLine.backgroundColor = Color(@"#e7e2dd");
    
    [shareView addSubview:bottomLine];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBtn.frame = CGRectMake(0, bottomLine.frame.origin.y + 20*kScreenScale, shareView.frame.size.width, 15*kScreenScale);
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:AB_Color_9c958a forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = AB_FONT_15;
    cancleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    cancleBtn.tag = 339;
    [cancleBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:cancleBtn];
    
    //为了弹窗不那么生硬，这里加了个简单的动画
    shareView.transform = CGAffineTransformMakeScale(1/300.0f, 1/270.0f);
    blackView.alpha = 0;
    [UIView animateWithDuration:0.35f animations:^{
        shareView.transform = CGAffineTransformMakeScale(1, 1);
        blackView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)shareBtnClick:(UIButton *)btn
{
    JLLog_D(@"%@", _publishContent.description);
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *blackView = [window viewWithTag:440];
    UIView *shareView = [window viewWithTag:441];
    
    //为了弹窗不那么生硬，这里加了个简单的动画
    shareView.transform = CGAffineTransformMakeScale(1, 1);
    [UIView animateWithDuration:0.35f animations:^{
        shareView.transform = CGAffineTransformMakeScale(1/300.0f, 1/270.0f);
        blackView.alpha = 0;
    } completion:^(BOOL finished) {
        
        [shareView removeFromSuperview];
        [blackView removeFromSuperview];
    }];
    
    int shareType = 0;

    switch (btn.tag) {
        case 331:
        {
            //邦邦好友
            if (_completedBlock) {
                _completedBlock(AISharePlatformBBFriends, _publishContent);
            }

        }
            return;
            
        case 332:
        {
            //邦邦好友圈
        }
            return;
            
        case 333:
        {
            shareType = ShareTypeWeixiSession;
        }
            break;
            
        case 334:
        {
            shareType = ShareTypeWeixiTimeline;
        }
            break;
            
//        case 335:
//        {
//            shareType = ShareTypeQQ;
//        }
//            break;
//            
//        case 336:
//        {
//            shareType = ShareTypeQQSpace;
//        }
//            break;
//            
//        case 337:
//        {
//            shareType = ShareTypeSinaWeibo;
//        }
//            break;
            
        case 335:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_publishContent[@"url"]]];
        }
            return;
            
//        case 339:
//        {
//            
//        }
//            break;
            
        default:
            break;
    }
    
//    id<ISSContent> content = [ShareSDK content:_publishContent[@"content"]
//       defaultContent:@""
//                image:[ShareSDK jpegImageWithImage:_publishContent[@"image"] quality:0.5]
//                title:_publishContent[@"title"]
//                  url:_publishContent[@"url"]
//          description:_publishContent[@"description"]
//            mediaType:(SSPublishContentMediaType)_publishContent[@"mediaType"]];
//    
//    /*
//     调用shareSDK的无UI分享类型，
//     链接地址：http://bbs.mob.com/forum.php?mod=viewthread&tid=110&extra=page%3D1%26filter%3Dtypeid%26typeid%3D34
//     */
//    [ShareSDK showShareViewWithType:shareType container:nil content:content statusBarTips:YES authOptions:nil shareOptions:nil result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
//        if (state == SSResponseStateSuccess)
//        {
//            //            NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
//        }
//        else if (state == SSResponseStateFail)
//        {
//            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"未检测到客户端 分享失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//            //            NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
//        }
//    }];
    
    id<ISSContent> content = [ShareSDK content:_publishContent[@"title"]
                                defaultContent:@"来自邦邦社区客户端"
                                         image:[ShareSDK pngImageWithImage:_publishContent[@"image"]]
                                         title:_publishContent[@"title"]
                                           url:_publishContent[@"url"]
                                   description:nil
                                     mediaType:SSPublishContentMediaTypeApp
                            locationCoordinate:nil
                                       groupId:nil];
    
    [ShareSDK shareContent:content
                      type:shareType
               authOptions:nil
              shareOptions:nil
             statusBarTips:YES
                   targets:nil
                    result:^(ShareType type,
                             SSResponseState state,
                             id<ISSPlatformShareInfo> statusInfo,
                             id<ICMErrorInfo> error,
                             BOOL end) {
                        switch (state) {
                            case SSResponseStateSuccess:
                                JLLog_I(@"分享成功。");
                                break;
                            
                            case SSResponseStateFail:
                                JLLog_I(@"分享失败。");
                                break;
                            default:
                                break;
                        }
                    }];
}

@end
