/*
 * libjingle
 * Copyright 2013, Google Inc.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

@class VideoView;
@class RTCMediaStream;
@class RTCVideoCapturer;
@class RTCVideoTrack;
@class RTCVideoSource;
@class HYActivityView;
@class VoipUtils;



//#import "GAEChannelClient.h"
//#import "APPRTCAppClient.h"
#import "RTCSessionDescriptonDelegate.h"
#import <AVFoundation/AVFoundation.h>

typedef enum VoipStatus
{
    //未接通
    STATE_NOTCONNECTION,
    //已接通
    STATE_CONNECTION,
    //已取消
    STATE_CANCEL,
    //已拒接
    STATE_REJECT
    
    
    
    
}VoipStatus;

@class RTCMediaConstraints;
// Used to send a message to an apprtc.appspot.com "room".
@protocol APPRTCSendMessage<NSObject>

- (void)sendData:(NSData *)data;
// Logging helper.
- (void)displayLogMessage:(NSString *)message;

-(void) enableSpeaker;
@end

// The view controller that is displayed when AppRTCDemo is loaded.
@interface APPRTCViewController : UIViewController<APPRTCSendMessage,RTCSessionDescriptonDelegate,UIActionSheetDelegate,AVAudioSessionDelegate>
{
    int current;
    //   BOOL isSpeakerEnable;
    NSTimer* mTimer;
    NSTimer* moverTimer;
    NSDate* startDate;
    VoipUtils* voipUtil;
    int flag;
    BOOL isVideoOpen;
    
    
}

@property (strong, nonatomic) IBOutlet UIView *blackView;

@property (nonatomic) BOOL isSpeakerEnable;
@property(nonatomic, strong) VideoView* remoteVideoView;
@property(nonatomic, strong) VideoView* localVideoView;
@property(nonatomic,retain)  NSMutableArray *ICEServers;
@property(nonatomic,strong) RTCMediaConstraints* videoConstraints;
//对话jid
@property(nonatomic,copy)NSString * from;

//是否是主叫方
@property(nonatomic)BOOL  isCaller;
//是否是视频
@property(nonatomic)BOOL  isVideo;
@property(nonatomic,assign)RTCVideoSource * videoSource;
@property(nonatomic,assign)RTCVideoCapturer *capturer;
@property(nonatomic,assign) RTCMediaStream *lms;
@property(nonatomic,assign)RTCVideoTrack * localVideoTrack;
@property(nonatomic,weak)UIImageView * ivavatar;
@property(nonatomic,weak)UIButton * buttonAccept;
@property(nonatomic,weak)UIButton * buttonCancel;
//名称显示
@property(nonatomic,weak)UILabel * lbname;
//状态和时间显示
@property(nonatomic,weak)UILabel * status;
@property(nonatomic,weak)UIView * viewCaller;
@property(nonatomic,weak)UIView * viewCallee;
@property(nonatomic,strong)HYActivityView *activityView;
@property(nonatomic,copy)NSString* msgID;
@property(nonatomic,copy)NSString* msessionID;

//通话时长
@property(nonatomic) int talkTime;

@property(nonatomic) VoipStatus voip_staus;

@property(nonatomic,strong)RTCMediaConstraints *constraints;


-(void)rtcNotifyAction:(NSNotification*)msg;



-(void)speakerAction;
- (void)resetUI;

- (IBAction)btnAction:(UIButton *)sender;
//设置显示名称
-(void)setName:(NSString*)_name;
//设置显示头像
-(void)setAvatar:(UIImage*)image;

-(void)changeCapture:(NSString *)capturer;
@end



// Used to send a message to an apprtc.appspot.com "room".
@protocol  APPRTCSendMessage<NSObject>

- (void)sendData:(NSData *)data;
// Logging helper.
- (void)displayLogMessage:(NSString *)message;
@end
