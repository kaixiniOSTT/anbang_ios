//
//  ZBMessageInputView.h
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-10.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBMessageTextView.h"

typedef enum
{
  ZBMessageInputViewStyleDefault, // ios7 样式
  ZBMessageInputViewStyleQuasiphysical
} ZBMessageInputViewStyle;

@protocol ZBMessageInputViewDelegate <NSObject>

@required

/**
 *  输入框刚好开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewDidBeginEditing:(ZBMessageTextView *)messageInputTextView;

/**
 *  输入框将要开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewWillBeginEditing:(ZBMessageTextView *)messageInputTextView;

/**
 *  输入框输入时候
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewDidChange:(ZBMessageTextView *)messageInputTextView;

@optional

/**
 *  点击语音按钮Action
 */
- (void)didChangeSendVoiceAction:(BOOL)changed;

/**
 *  发送文本消息，包括系统的表情
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)didSendTextAction:(ZBMessageTextView *)messageInputTextView;

/**
 *  输入@符号时，弹出群成员列表
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)didCallRemindViewControllerAction:(ZBMessageTextView *)messageInputTextView;

/**
 *  删除@提醒块后面的空格时，自动删除整块
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)didRemoveRemindBlockAction:(ZBMessageTextView *)messageInputTextView;

/**
 *  点击+号按钮Action
 */
- (void)didSelectedMultipleMediaAction:(BOOL)changed;

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction;

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction;

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction;

/**
 *  滑动取消录音
 */
-(void)didCancelRecordingDragExitVoiceAction;

/**
 *  继续录音
 */
-(void)didCancelRecordingDragEnterVoiceAction;

/**
 *  发送第三方表情
 */
- (void)didSendFaceAction:(BOOL)sendFace;

@end

@interface ZBMessageInputView : UIImageView



@property (nonatomic,weak) id<ZBMessageInputViewDelegate> delegate;

/**
 *  用于输入文本消息的输入框
 */
@property (nonatomic,strong) ZBMessageTextView *messageInputTextView;

/**
 *  当前输入工具条的样式
 */
@property (nonatomic, assign) ZBMessageInputViewStyle messageInputViewStyle;

/**
 *  切换文本和语音的按钮
 */
@property (nonatomic, strong) UIButton *voiceChangeButton;

/**
 *  +号按钮
 */
@property (nonatomic, strong) UIButton *multiMediaSendButton;

/**
 *  第三方表情按钮
 */
@property (nonatomic, strong) UIButton *faceSendButton;

/**
 *  语音录制按钮
 */
@property (nonatomic, strong) UIButton *holdDownButton;

#pragma mark methods
/**
 *  动态改变高度
 *
 *  @param changeInHeight 目标变化的高度
 */
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

/**
 *  获取输入框内容字体行高
 *
 *  @return 返回行高
 */
+ (CGFloat)textViewLineHeight;

/**
 *  获取最大行数
 *
 *  @return 返回最大行数
 */
+ (CGFloat)maxLines;

/**
 *  获取根据最大行数和每行高度计算出来的最大显示高度
 *
 *  @return 返回最大显示高度
 */
+ (CGFloat)maxHeight;

#pragma end

@end
