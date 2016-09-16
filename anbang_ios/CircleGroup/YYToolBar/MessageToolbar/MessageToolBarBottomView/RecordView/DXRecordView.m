/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "DXRecordView.h"

@interface DXRecordView ()
{
    NSTimer *_timer;
    // 显示动画的ImageView
    UIImageView *_recordAnimationView;
    // 提示文字
    UILabel *_textLabel;
    
    AVAudioRecorder *recorder;
    NSString *recordfilepath;   //录音文件路径
    NSString *recordname;       //录音文件名
    CGFloat curCount;           //当前计数,初始为0
}

@end

@implementation DXRecordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
        bgView.backgroundColor = [UIColor grayColor];
        bgView.layer.cornerRadius = 5;
        bgView.layer.masksToBounds = YES;
        bgView.alpha = 0.6;
        [self addSubview:bgView];
        
        [self audio];
        
        _recordAnimationView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width - 20, self.bounds.size.height - 10)];
        _recordAnimationView.image = [UIImage imageNamed:@"VoiceSearchFeedback001"];
        [self addSubview:_recordAnimationView];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,
                                                               self.bounds.size.height - 30,
                                                               self.bounds.size.width - 10,
                                                               25)];
        
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.text = @" 手指上滑，取消发送 ";
        [self addSubview:_textLabel];
        _textLabel.font = [UIFont systemFontOfSize:13];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.layer.cornerRadius = 5;
        _textLabel.layer.borderColor = [[UIColor redColor] colorWithAlphaComponent:0.5].CGColor;
        _textLabel.layer.masksToBounds = YES;
    }
    return self;
}

// 录音按钮按下
-(void)recordButtonTouchDown
{
    //创建录音文件，准备录音
    [self beginrecord];
    
    // 需要根据声音大小切换recordView动画
    _textLabel.text = @" 手指上滑，取消发送 ";
    _textLabel.backgroundColor = [UIColor clearColor];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                              target:self
                                            selector:@selector(setVoiceImage)
                                            userInfo:nil
                                             repeats:YES];
    
}
- (void)beginrecord
{
    recordname = [CommFunction GetTempName];
    recordfilepath = [VoiceRecorderBaseVC getPathByFileName:recordname ofType:@"aac"];
    //初始化录音
    recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:recordfilepath]
                                           settings:[VoiceRecorderBaseVC getAudioRecorderSettingDict]
                                              error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder peakPowerForChannel:0];
    [recorder prepareToRecord];
    
    //还原计数
    curCount = 0;
    
    //开始录音
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [recorder record];
    
    //启动计时器
    [self startTimer];
}
#pragma mark - 更新音频峰值
- (void)updateMeters{
    if (recorder.isRecording){
        //更新峰值
        [recorder updateMeters];
        curCount += 0.1f;
    }
}

#pragma mark - AVAudioRecorder Delegate Methods
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"录音停止");
    [self stopTimer];
    curCount = 0;
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    NSLog(@"录音开始");
    [self stopTimer];
    curCount = 0;
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags{
    NSLog(@"录音中断");
    [self stopTimer];
    curCount = 0;
}

#pragma mark - 启动定时器
- (void)startTimer{
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}

#pragma mark - 停止定时器
- (void)stopTimer{
    //停止动画
    if (_timer && _timer.isValid){
        [_timer invalidate];
        _timer = nil;
    }
}


// 手指在录音按钮内部时离开，发送语音
-(void)recordButtonTouchUpInside
{
    [_timer invalidate];
    
    [self stopTimer];
    if (recorder.isRecording)
        [recorder stop];
    AVAudioPlayer *play = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:recordfilepath] error:nil];
        NSString *amrfilePath = [NSString stringWithFormat:@"%@/%@", [VoiceRecorderBaseVC getCacheDirectory], [recordname stringByAppendingPathExtension:@"aac"]];
        
//    //转格式 wav2amr
//    [VoiceConverter wavToAmr:recordfilepath amrSavePath:amrfilePath];
    self.vedioUrl = amrfilePath;
    self.interNum = play.duration;
    curCount = 0;
}

// 手指在录音按钮外部时离开
-(void)recordButtonTouchUpOutside
{
    [_timer invalidate];
}
// 手指移动到录音按钮内部
-(void)recordButtonDragInside
{
    _textLabel.text = @" 手指上滑，取消发送 ";
    _textLabel.backgroundColor = [UIColor clearColor];
}

// 手指移动到录音按钮外部
-(void)recordButtonDragOutside
{
    _textLabel.text = @" 松开手指，取消发送 ";
    _textLabel.backgroundColor = [UIColor redColor];
}

-(void)setVoiceImage {
    _recordAnimationView.image = [UIImage imageNamed:@"VoiceSearchFeedback001"];
    [recorder updateMeters];
    
    double voiceSound = pow(10, (0.05*[recorder peakPowerForChannel:0]));
    if (0 < voiceSound <= 0.05) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback001"]];
    }else if (0.05<voiceSound<=0.10) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback002"]];
    }else if (0.10<voiceSound<=0.15) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback003"]];
    }else if (0.15<voiceSound<=0.20) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback004"]];
    }else if (0.20<voiceSound<=0.25) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback005"]];
    }else if (0.25<voiceSound<=0.30) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback006"]];
    }else if (0.30<voiceSound<=0.35) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback007"]];
    }else if (0.35<voiceSound<=0.40) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback008"]];
    }else if (0.40<voiceSound<=0.45) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback009"]];
    }else if (0.45<voiceSound<=0.50) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback010"]];
    }else if (0.50<voiceSound<=0.55) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback011"]];
    }else if (0.55<voiceSound<=0.60) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback012"]];
    }else if (0.60<voiceSound<=0.65) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback013"]];
    }else if (0.65<voiceSound<=0.70) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback014"]];
    }else if (0.70<voiceSound<=0.75) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback015"]];
    }else if (0.75<voiceSound<=0.80) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback016"]];
    }else if (0.80<voiceSound<=0.85) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback017"]];
    }else if (0.85<voiceSound<=0.90) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback018"]];
    }else if (0.90<voiceSound<=0.95) {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback019"]];
    }else {
        [_recordAnimationView setImage:[UIImage imageNamed:@"VoiceSearchFeedback020"]];
    }
}

- (void)audio
{
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/lll.aac", strUrl]];
    
    NSError *error;
    //初始化
    recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
    //开启音量检测
    recorder.meteringEnabled = YES;
    recorder.delegate = self;
}

@end
