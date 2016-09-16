
#import <UIKit/UIKit.h>
#import "FaceViewController.h"
#import "sqlite3.h"
#import "WCChatSelectionView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>
#import "F3BarGauge.h"
#import "PullingRefreshTableView.h"
#import "Utility.h"
#import "QBPopupMenu.h"
#import "HPGrowingTextView.h"




@interface GroupChatViewController : UIViewController<PullingRefreshTableViewDelegate, UITableViewDataSource,UITableViewDelegate,WCShareMoreDelegate,HPGrowingTextViewDelegate,UIActionSheetDelegate> {
    
    UIView *containerView;
    UIView *voiceView;
    HPGrowingTextView *textView;
    
    
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
 
    BOOL recording;
    NSTimer *peakTimer;
    //    AVAudioSession *audioSession;
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    NSURL *pathURL;
    UIView* talkView;
    NSString* _lastRecordFile;
    NSString* _lastPlayerFile;
    NSTimeInterval _lastPlayerTime;
    int _lastIndex;
    
    double lowPassResults;
    NSTimeInterval _timeLen;
    int _refreshCount;

    NSString * voiceLink;
    
    IBOutlet UIButton* _recordBtn;
    
 
}

@property (nonatomic, retain)  UIView *containerView;


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
@property(nonatomic, retain) NSString *roomName;                    //房间标识名称
@property(nonatomic, retain) NSString *roomNickName;                    //房间昵称

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

//图片模块

@property (nonatomic, retain) UIImage *tempSendImage;//临时图片
@property (nonatomic, retain) NSMutableArray*tempSendImageArray;




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
