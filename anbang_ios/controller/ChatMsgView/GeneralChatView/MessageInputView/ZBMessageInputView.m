//
//  ZBMessageInputView.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-10.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import "ZBMessageInputView.h"
#import "NSString+Message.h"
#import <AVFoundation/AVFoundation.h>
#import "CHAppDelegate.h"

@interface ZBMessageInputView()<UITextViewDelegate>


@property (nonatomic, copy) NSString *inputedText;

@end

@implementation ZBMessageInputView

- (void)dealloc{
    _messageInputTextView.delegate = nil;
    _messageInputTextView = nil;
    
    _voiceChangeButton = nil;
    _multiMediaSendButton = nil;
    _faceSendButton = nil;
    _holdDownButton = nil;

}

#pragma mark - Action

- (void)messageStyleButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
        {
            self.faceSendButton.selected = NO;
            self.multiMediaSendButton.selected = NO;
            sender.selected = !sender.selected;
            
            if (sender.selected){
                NSLog(@"声音被点击的");
                [self.messageInputTextView becomeFirstResponder];
                
            }else{
                NSLog(@"声音被点击结束");
                [self.messageInputTextView resignFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.holdDownButton.hidden = sender.selected;
                self.messageInputTextView.hidden = !sender.selected;
           } completion:^(BOOL finished) {
                
           }];
            
            if ([self.delegate respondsToSelector:@selector(didChangeSendVoiceAction:)]) {
                [self.delegate didChangeSendVoiceAction:sender.selected];
            }
        }
            break;
        case 1:
        {
            self.multiMediaSendButton.selected = NO;
            self.voiceChangeButton.selected = YES;
            
            sender.selected = !sender.selected;
            if (sender.selected) {
                NSLog(@"表情被点击");
                [self.messageInputTextView resignFirstResponder];
            }else{
                NSLog(@"表情没被点击");
                [self.messageInputTextView becomeFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.holdDownButton.hidden = YES;
                self.messageInputTextView.hidden = NO;
           } completion:^(BOOL finished) {
                
           }];
            
            if ([self.delegate respondsToSelector:@selector(didSendFaceAction:)]) {
                [self.delegate didSendFaceAction:sender.selected];
            }
        }
            break;
        case 2:
        {
            self.voiceChangeButton.selected = YES;
            self.faceSendButton.selected = NO;
            
            sender.selected = !sender.selected;
            if (sender.selected) {
                NSLog(@"分享被点击");
                [self.messageInputTextView resignFirstResponder];
            }else{
                NSLog(@"分享没被点击");
                [self.messageInputTextView becomeFirstResponder];
            }

           // [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.holdDownButton.hidden = YES;
                self.messageInputTextView.hidden = NO;
           // } completion:^(BOOL finished) {
                
           // }];
            
            if ([self.delegate respondsToSelector:@selector(didSelectedMultipleMediaAction:)]) {
                [self.delegate didSelectedMultipleMediaAction:sender.selected];
            }
        }
            break;
        default:
            break;
    }
}




#pragma mark -语音功能
- (void)holdDownButtonTouchDown {
    
    NSLog(@"开始语音消息...");
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            if ([self.delegate respondsToSelector:@selector(didStartRecordingVoiceAction)]) {
                [self.delegate didStartRecordingVoiceAction];
            }
        } else {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请打开麦克风的隐私设置!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [((CHAppDelegate*)[UIApplication sharedApplication].delegate).viewController.view addSubview:alertView];
            [alertView show];
            
        } 
    }];
    
    
    
}

- (void)holdDownButtonTouchUpOutside {
    NSLog(@"按下语音消息...");
    if ([self.delegate respondsToSelector:@selector(didCancelRecordingVoiceAction)]) {
        [self.delegate didCancelRecordingVoiceAction];
    }
}

- (void)holdDownButtonTouchDragExit {
    NSLog(@"向上滑动语音消息...");
    if ([self.delegate respondsToSelector:@selector(didCancelRecordingDragExitVoiceAction)]) {
        [self.delegate didCancelRecordingDragExitVoiceAction];
    }
}

- (void)holdDownButtonTouchDragEnter {
    NSLog(@"向上滑动语音消息...");
    if ([self.delegate respondsToSelector:@selector(didCancelRecordingDragEnterVoiceAction)]) {
        [self.delegate didCancelRecordingDragEnterVoiceAction];
    }
}

- (void)holdDownButtonTouchUpInside {
    NSLog(@"松开语音消息...");
    if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction)]) {
        [self.delegate didFinishRecoingVoiceAction];
    }
}

#pragma end

#pragma mark - 添加控件
- (void)setupMessageInputViewBarWithStyle:(ZBMessageInputViewStyle )style{
    // 配置输入工具条的样式和布局
    
    // 水平间隔
    CGFloat horizontalPadding = 8;
    
    // 垂直间隔
    CGFloat verticalPadding = 5;
    
    // 按钮长,宽
    CGFloat buttonSize = [ZBMessageInputView textViewLineHeight];
    
    // 发送语音
    self.voiceChangeButton = [self createButtonWithImage:[UIImage imageNamed:@"chat_button_text"]
                                                 HLImage:nil];
    [self.voiceChangeButton setImage:[UIImage imageNamed:@"chat_button_mic"]
                            forState:UIControlStateSelected];
    [self.voiceChangeButton addTarget:self
                               action:@selector(messageStyleButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    self.voiceChangeButton.tag = 0;
    
    self.voiceChangeButton.frame = CGRectMake(horizontalPadding,verticalPadding,buttonSize,buttonSize);
    
    [self addSubview:self.voiceChangeButton];

    
    
    // 允许发送多媒体消息，为什么不是先放表情按钮呢？因为布局的需要！
    self.multiMediaSendButton = [self createButtonWithImage:[UIImage imageNamed:@"chat_button_add"]
                                                    HLImage:nil];
    [self.multiMediaSendButton addTarget:self
                                  action:@selector(messageStyleButtonClicked:)
                        forControlEvents:UIControlEventTouchUpInside];
    self.multiMediaSendButton.tag = 2;
    [self addSubview:self.multiMediaSendButton];
    self.multiMediaSendButton.frame = CGRectMake(self.frame.size.width - horizontalPadding - buttonSize,
                                                 verticalPadding,
                                                 buttonSize,
                                                 buttonSize);
    
    // 发送表情
    self.faceSendButton = [self createButtonWithImage:[UIImage imageNamed:@"chat_button_face"]
                                              HLImage:nil];
   
    [self.faceSendButton setImage:[UIImage imageNamed:@"chat_button_text"]
                         forState:UIControlStateSelected];
    [self.faceSendButton addTarget:self
                            action:@selector(messageStyleButtonClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
    self.faceSendButton.tag = 1;
    [self addSubview:self.faceSendButton];
    self.faceSendButton.frame = CGRectMake(self.frame.size.width - 2*buttonSize- horizontalPadding - 5 ,verticalPadding,buttonSize,buttonSize);
    
    
    // 如果是可以发送语言的，那就需要一个按钮录音的按钮，事件可以在外部添加
   // self.holdDownButton = [self createButtonWithImage:[UIImage imageNamed:@"holdDownButton"] HLImage:nil];
    
    self.holdDownButton = [UIButton buttonWithType:UIButtonTypeCustom];

    self.holdDownButton.frame = CGRectMake(65, 6, KCurrWidth-135, 38);
    [self.holdDownButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    //[btn setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[btn setTitleShadowOffset:CGSizeMake(1, 1)];
    [self.holdDownButton.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
    [self.holdDownButton.layer setBorderWidth:1.0]; //边框
    //[btn.layer setBorderColor:[[UIColor colorWithRed:0.200 green:0.6 blue:1 alpha:1]CGColor] ];
    [self.holdDownButton.layer setBorderColor:[kMainColor7_2 CGColor] ];
    
    [self.holdDownButton setTitle:NSLocalizedString(@"chatviewPublic.holdToTalk",@"action") forState:UIControlStateNormal];
    [self.holdDownButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    self.holdDownButton.backgroundColor = AB_Color_efe8df;
    
    [self.holdDownButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    
     [self.holdDownButton setTintColor:[UIColor grayColor]];
    
    [self.holdDownButton setTitle:NSLocalizedString(@"chatviewPublic.holdToTalk",@"action") forState:UIControlStateNormal];
    [self.holdDownButton setTitle:NSLocalizedString(@"chatviewPublic.releaseToSend",@"action") forState:UIControlStateHighlighted];
    

    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchDragExit) forControlEvents:UIControlEventTouchDragExit];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchDragEnter) forControlEvents:UIControlEventTouchDragEnter];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.holdDownButton];
    //self.holdDownButton.selected =YES;
    
    
    // 初始化输入框
   _messageInputTextView = [[ZBMessageTextView alloc] initWithFrame:CGRectZero];
  //    self.messageInputTextView.keyboardAppearance = UIReturnKeySend;
    self.messageInputTextView.keyboardType = UIKeyboardTypeDefault;
    self.messageInputTextView.returnKeyType=UIReturnKeySend;
   // _messageInputTextView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    _messageInputTextView.placeHolder = @"输入内容";
    _messageInputTextView.delegate = self;
    [self addSubview:_messageInputTextView];
    
	//self.messageInputTextView = textView;
    self.messageInputTextView.hidden = !self.voiceChangeButton.selected;
    
    
    // 配置不同iOS SDK版本的样式
    switch (style)
    {
        case ZBMessageInputViewStyleQuasiphysical:
        {
            self.holdDownButton.frame = CGRectMake(horizontalPadding + buttonSize +5.0f,
                                                     3.0f,
                                                     CGRectGetWidth(self.bounds)- 3*buttonSize -2*horizontalPadding- 15.0f,
                                                     buttonSize);
            _messageInputTextView.backgroundColor = AB_White_Color;
            
            break;
        }
        case ZBMessageInputViewStyleDefault:
        {
            self.holdDownButton.frame = CGRectMake(horizontalPadding + buttonSize +5.0f,4.5f,CGRectGetWidth(self.bounds)- 3*buttonSize -2*horizontalPadding- 15.0f,buttonSize);
            _messageInputTextView.backgroundColor = AB_White_Color;
            _messageInputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
            _messageInputTextView.layer.borderWidth = 0.65f;
            _messageInputTextView.layer.cornerRadius = 6.0f;
    
            break;
        }
        default:
            break;
    }
    
    self.messageInputTextView.frame = self.holdDownButton.frame;

    //默认输入文字

    self.voiceChangeButton.selected = !self.voiceChangeButton.selected;
    
  
    //[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.holdDownButton.hidden = self.voiceChangeButton.selected;
        self.messageInputTextView.hidden = NO;
        // [self.messageInputTextView resignFirstResponder];
   // } completion:^(BOOL finished) {
        
   // }];
    

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - layout subViews UI
- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (image)
        [button setImage:image forState:UIControlStateNormal];
    if (hlImage)
        [button setImage:hlImage forState:UIControlStateHighlighted];
    return button;
}
#pragma end

#pragma mark - Message input view

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight {
    // 动态改变自身的高度和输入框的高度
    
    NSLog(@"****%f",changeInHeight);
    CGRect prevFrame = self.messageInputTextView.frame;
    
    NSLog(@"******%f",self.messageInputTextView.frame.size.height);
    
    NSUInteger numLines = MAX([self.messageInputTextView numberOfLinesOfText],
                              [self.messageInputTextView.text numberOfLines]);
    
    self.messageInputTextView.frame = CGRectMake(prevFrame.origin.x,
                                          prevFrame.origin.y,
                                          prevFrame.size.width,
                                          prevFrame.size.height + changeInHeight);
    
    
    self.messageInputTextView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                       0.0f,
                                                       (numLines >= 6 ? 4.0f : 0.0f),
                                                       0.0f);
    
    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
    self.messageInputTextView.scrollEnabled = YES;
    
    if (numLines >= 6) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.messageInputTextView.contentSize.height - self.messageInputTextView.bounds.size.height);
        [self.messageInputTextView setContentOffset:bottomOffset animated:YES];
        [self.messageInputTextView scrollRangeToVisible:NSMakeRange(self.messageInputTextView.text.length - 2, 1)];
    }
}

+ (CGFloat)textViewLineHeight{
    return 36.0f ;// 字体大小为16
}

+ (CGFloat)maxHeight{
    return ([ZBMessageInputView maxLines] + 1.0f) * [ZBMessageInputView textViewLineHeight];
}

+ (CGFloat)maxLines{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 3.0f : 8.0f;
}
#pragma end

- (void)setup {
    
    CGFloat w = self.frame.size.width;
//    UIView *view = [[UIView alloc] init];
//    view.frame = CGRectMake(0, 0, w, 0.5);
//    view.backgroundColor = AB_Input_Field_Top_Separator_Color;
//    [self addSubview:view];
    self.layer.borderColor = [AB_Input_Field_Top_Separator_Color CGColor];
    self.layer.borderWidth = 0.5;
    
    // 配置自适应
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    // 由于继承UIImageView，所以需要这个属性设置
    self.userInteractionEnabled = YES;
    
    _messageInputViewStyle = ZBMessageInputViewStyleDefault;
//        self.image = [[UIImage imageNamed:@"input-bar-flat"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)
//                                                                            resizingMode:UIImageResizingModeStretch];

    self.backgroundColor = AB_Input_Field_Back_Color;
    [self setupMessageInputViewBarWithStyle:_messageInputViewStyle];
}

#pragma mark - textViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
   
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)])
    {
        [self.delegate inputTextViewWillBeginEditing:self.messageInputTextView];
    }
    self.faceSendButton.selected = NO;
    self.multiMediaSendButton.selected = NO;
   
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    if ([self.delegate respondsToSelector:@selector(didRemoveRemindBlockAction:)]) {
        [self.delegate didRemoveRemindBlockAction:self.messageInputTextView];
    }
    
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidChange:)]) {
        [self.delegate inputTextViewDidChange:self.messageInputTextView];
        return;
    }
    

}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [textView becomeFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.messageInputTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if (range.location > 5000) { // length limit
        textView.text = [textView.text substringToIndex:5000];
        return NO;
    }
    
    if([text isEqualToString:@""] && textView.text.length > 0)
    {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(.*)\\[\\w{1,3}\\]$"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSString *replaced = [regex stringByReplacingMatchesInString:textView.text
                                                             options:0
                                                               range:NSMakeRange(0, [textView.text length])
                                                        withTemplate:@"$1"];
        if([textView.text isEqualToString:replaced]){
            return YES;
        }
        textView.text = replaced;
        return NO;
    }
    
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendTextAction:)]) {
            [self.delegate didSendTextAction:self.messageInputTextView];
        }
        return NO;
    }

    
    if ([text isEqualToString:@"@"]) {
        if ([self.delegate respondsToSelector:@selector(didCallRemindViewControllerAction:)]) {
            [self.delegate didCallRemindViewControllerAction:self.messageInputTextView];
        }
        return YES;
    }
    
    return YES;
}
#pragma end

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
