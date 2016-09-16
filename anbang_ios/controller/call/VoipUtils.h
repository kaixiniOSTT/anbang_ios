//
//  VoipUtils.h
//  anbang_ios
//
//  Created by fighting on 14-4-16.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface VoipUtils : NSObject<AVAudioPlayerDelegate>
-(void)startRing:(int)callerFlag;

-(void)stopRing;


@end
