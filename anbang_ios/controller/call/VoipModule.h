//
//  VoipModule.h
//  anbang_ios
//
//  Created by fighting on 14-4-7.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "XMPPModule.h"
#import "XMPPFramework.h"

@protocol VoipDelegate;

@interface VoipModule : XMPPModule
{
    __strong id <VoipDelegate> voipDelegate;
}

-(void) sendData:(XMPPJID *) to json:(NSString *)msg sessionID:(NSString *)sessionID;
-(BOOL) call:(XMPPJID *)to isvideo:(BOOL) video sessionID:(NSString *)sessionID;
-(BOOL) recall:(XMPPJID *)to isvideo:(BOOL) video msgID:(NSString*)mid sessionID:(NSString *)sessionID;
+(id) shareVoipModule;
@property (nonatomic,retain)id<VoipDelegate> voipDelegate;
@end


#pragma mark --VoipDelegate
@protocol VoipDelegate <NSObject>
@required

-(void) voipJson:(NSString *) from json:(NSString*) msg sessionID:(NSString*)sessionID;

-(void) error:(NSString *)from error:(XMPPIQ *)iq;

-(void)sendOnline:(XMPPJID *)to isvideo:(BOOL) video msgID:(NSString*) mid ;


@end