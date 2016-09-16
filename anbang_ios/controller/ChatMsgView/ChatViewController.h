
#import <UIKit/UIKit.h>
#import "FaceViewController.h"
#import "sqlite3.h"
#import "WCChatSelectionView.h"
#import <AVFoundation/AVFoundation.h>
#import "F3BarGauge.h"
#import "PullingRefreshTableView.h"
#import "Utility.h"
#import "QBPopupMenu.h"





@interface ChatViewController : UIViewController<PullingRefreshTableViewDelegate, UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,KKMessageDelegate,WCShareMoreDelegate> {
	NSString                   *_titleString;
	NSMutableString            *_messageString;
	NSString                   *_phraseString;
	NSMutableArray		       *_chatArray;
    NSMutableArray		       *_tempChatArray;
    NSMutableArray		       *_beforeChatArray;

    
	
	PullingRefreshTableView                *_chatTableView;
	UITextField                *_messageTextField;
	BOOL                       _isFromNewSMS;
	FaceViewController      *_phraseViewController;
	//AsyncUdpSocket             *_udpSocket;
	NSDate                     *_lastTime;
    sqlite3 *database;
    WCChatSelectionView      *_shareMoreView;
    
    //语音模块
    
    AVAudioPlayer *audioPlayer;
    AVAudioRecorder *audioRecorder;
    int recordEncoding;
    enum
    {
        ENC_AAC = 1,
        ENC_ALAC = 2,
        ENC_IMA4 = 3,
        ENC_ILBC = 4,
        ENC_ULAW = 5,
        ENC_PCM = 6,
    } encodingTypes;
    
    float Pitch;
    NSTimer *timerForPitch;

}
@property (nonatomic, retain) IBOutlet NSString *myUserName;
@property (nonatomic, retain) IBOutlet FaceViewController   *phraseViewController;
//@property (nonatomic, retain) IBOutlet UITableView            *chatTableView;
@property (nonatomic, retain)  PullingRefreshTableView            *chatTableView;
@property (nonatomic) BOOL refreshing;
@property (assign,nonatomic) NSInteger pageSize;
@property (assign,nonatomic) NSInteger start;
@property (assign,nonatomic) NSInteger total;
@property (nonatomic, retain) NSMutableArray		 *msgButArray;


@property (nonatomic, retain) IBOutlet UITextField            *messageTextField;
@property (nonatomic, retain) IBOutlet UIToolbar            *messageToolbar;
@property (nonatomic, retain) IBOutlet UIToolbar            *voiceToolbar;
@property (nonatomic, retain) IBOutlet UITextField            *hideTextField;
@property (nonatomic, retain) NSString               *phraseString;
@property (nonatomic, retain) NSString               *titleString;
@property (nonatomic, retain) NSMutableString        *messageString;
@property (nonatomic, retain) NSMutableArray		 *chatArray;
@property (nonatomic, retain) NSMutableArray		 *tempChatArray;
@property (nonatomic, retain) NSMutableArray		 *beforeChatArray;

@property (nonatomic, retain) NSDate                 *lastTime;
//@property (nonatomic, retain) AsyncUdpSocket         *udpSocket;

@property(nonatomic, retain) NSString *chatWithUser;//用户号
@property(nonatomic, retain) NSString *chatWithJID;//用户号+域名（jid)
@property(nonatomic, retain) NSString *chatWithNick;//用户昵称
@property(nonatomic) BOOL chatBuddyFlag;//是否存在聊天列表



@property (retain, nonatomic) IBOutlet UITableView *tView;

@property(nonatomic,retain)NSMutableArray *messages;

@property (retain, nonatomic) UIImage *buddyPhoto;
@property (retain, nonatomic) UIImage *myPhoto;

@property (retain,nonatomic)NSString *messgaeFlag;//不在当前view 时取消更新消息为已读

-(IBAction)sendMessage_Click:(id)sender;
-(IBAction)showPhraseInfo:(id)sender;


-(void)openUDPServer;
-(void)sendMassage:(NSString *)message;
-(void)deleteContentFromTableView;

- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf type:(NSString*)type;

-(void)getImageRange:(NSString*)message : (NSMutableArray*)array;
-(UIView *)assembleMessageAtIndex : (NSString *) message from: (BOOL)fromself type:(NSString *)type;
- (IBAction)textFiledReturnEditing:(id)sender;


//语音模块
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIProgressView *progressView;
@property (retain, nonatomic) IBOutlet UIButton *touchbutton;
@property (retain, nonatomic) IBOutlet UIView *viewForWave;
@property (retain, nonatomic) IBOutlet UIView *viewForWave2;
@property (nonatomic) CFTimeInterval firstTimestamp;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet F3BarGauge *customRangeBar;
@property (nonatomic) NSUInteger loopCount;
-(IBAction) startRecording;
-(IBAction) stopRecording;
-(IBAction) playRecording;
-(IBAction) stopPlaying;



//弹出菜单
@property (nonatomic, retain) NSString *playMode;
@property (nonatomic, retain) QBPopupMenu *popupMenu;
@property (nonatomic, retain) QBPopupMenu *popupMenu2;
@property (nonatomic, retain) QBPopupMenu *popupMenu3;
@property (nonatomic, retain) NSIndexPath *deleteIndexPath;
-(IBAction)changeVoicePlayMode;
-(IBAction)changeVoicePlayMode2;
-(IBAction)deleteCellFromTableView:(NSIndexPath *)indexPath;
@end
