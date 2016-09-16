
#import <UIKit/UIKit.h>
#import "ZBMessageInputView.h"
#import "ZBMessageShareMenuView.h"
#import "ZBMessageManagerFaceView.h"
#import "ZBMessage.h"

typedef NS_ENUM(NSInteger,ZBMessageViewState) {
    ZBMessageViewStateShowFace,
    ZBMessageViewStateShowShare,
    ZBMessageViewStateShowNone,
};



@interface MessageDisplayViewController : UIViewController<ZBMessageInputViewDelegate,ZBMessageShareMenuViewDelegate,ZBMessageManagerFaceViewDelegate>



@property (nonatomic,strong) ZBMessageInputView *messageToolView;

@property (nonatomic,strong) ZBMessageManagerFaceView *faceView;

@property (nonatomic,strong) ZBMessageShareMenuView *shareMenuView;

@property (nonatomic,assign) CGFloat previousTextViewContentHeight;

//文本消息
- (void)sendMessage:(ZBMessage *)message;
//移除@提醒块
- (void)removeRemindBlock:(ZBMessageTextView*)messageInputTextView;
//弹出提醒选人视图
- (void)callRemindViewController:(ZBMessageTextView*)messageInputTextView;

//语音消息
- (void)didStartRecording;
- (void)didCancelRecording;
- (void)didDragExitRecording;
- (void)didDragEnterRecording;
- (void)didFinishRecoing;
//更多
-(void)didSelecteShareMenuItem:(NSInteger)index;

- (void)messageViewAnimationWithMessageRect:(CGRect)rect  withMessageInputViewRect:(CGRect)inputViewRect andDuration:(double)duration andState:(ZBMessageViewState)state;

//点击分享
- (void)didShareButton:(BOOL)flag;

//点击表情
-(void) didFaceButton:(BOOL)sendFace;

//点击表情发送
-(void) didSendFaceButton;

@end
