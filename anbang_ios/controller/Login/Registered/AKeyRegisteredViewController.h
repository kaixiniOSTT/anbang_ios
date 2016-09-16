//
//  AKeyRegisteredViewController.h
//  anbang_ios
//
//  Created by seeko on 14-3-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AKeyRegisteredViewController : UIViewController<XMPPStreamDelegate,XMPPServerDelegate>
{
    XMPPStream *xmppStream;
    XMPPServer *xmppServer;
}

@property(nonatomic,retain)NSString * prompt;
@property(nonatomic,retain)NSString * userSource;

@end
