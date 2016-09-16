//
//  VoipUtils.m
//  anbang_ios
//
//  Created by fighting on 14-4-16.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "VoipUtils.h"
#import <AudioToolbox/AudioToolbox.h>
static SystemSoundID shake_sound_male_id = 0;

@implementation VoipUtils
{
    AVAudioPlayer * player;
}



-(void)startRing
{
    //player.delegate = self;
    NSError* err;
    player = [[AVAudioPlayer alloc]
              initWithContentsOfURL:[NSURL fileURLWithPath:
                                     [[NSBundle mainBundle]pathForResource:
                                      @"app_ring" ofType:@"wav"
                                                               inDirectory:@"/"]]
              error:&err ];
    player.volume=0.5;//0.0~1.0之间
    [player setNumberOfLoops:15];
    [ player  prepareToPlay];
   // player.meteringEnabled = YES;
    //[player updateMeters];
    [player  play];
    
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"app_ring" ofType:@"wav"];
//    if (path) {
//        //注册声音到系统
//        AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
//        AudioServicesPlaySystemSound(shake_sound_male_id);
//        //        AudioServicesPlaySystemSound(shake_sound_male_id);//如果无法再下面播放，可以尝试在此播放
//    }
//    
//    AudioServicesPlaySystemSound(shake_sound_male_id);   //播放注册的声音，（此句代码，可以在本类中的任意位置调用，不限于本方法中）
//
//    
   
    
}


-(void)stopRing
{
    
//    AudioServicesDisposeSystemSoundID(shake_sound_male_id);
//    AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
    if (player && player.playing) {
        [player stop];
    }
}
@end
