
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "sqlite3.h"
#import "WCChatSelectionView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>
#import "F3BarGauge.h"
#import "PullingRefreshTableView.h"
#import "Utility.h"
#import "QBPopupMenu.h"
#import "HPGrowingTextView.h"
#import "TTImagePickerController.h"
#import "TTAlbumTableController.h"
#import "MWPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FaceBoard.h"
#import "PPLabel.h"
#import <AddressBookUI/AddressBookUI.h>
#import "YLImageView.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "MessageDisplayViewController.h"
#import "AIMessageSendAssisstantDelegate.h"
#import "BaiduMapViewController.h"

@interface ChatViewController2 : MessageDisplayViewController<PullingRefreshTableViewDelegate, UITableViewDataSource,UITableViewDelegate,KKMessageDelegate,WCShareMoreDelegate,TTImagePickerControllerDelegate,UIActionSheetDelegate,UITextViewDelegate,PPLabelDelegate,UIGestureRecognizerDelegate,ABNewPersonViewControllerDelegate,ABPeoplePickerNavigationControllerDelegate,ZBMessageInputViewDelegate,ZBMessageShareMenuViewDelegate,ZBMessageManagerFaceViewDelegate,AVAudioRecorderDelegate,UIImagePickerControllerDelegate,MWPhotoBrowserDelegate,UITextFieldDelegate, AIMessageSendAssisstantDelegate, UIAlertViewDelegate, UIScrollViewDelegate, BaiduMapViewControllerDelegate> {
    

    
    UIView *containerView;
    UIView *voiceView;
    UITextView *textView;
    UIView *underlineView;
    UIButton *sendBtn;
    UIButton *moreBtn;
    
    
    //默认头像
    NSString *avatarDefaultPath;
    
    //对方头像
    NSString *avatarURL;
    NSString *avatar;
    UIImageView *friendAvatarImageView;
    //自己头像
    NSString *myAvatarURL;
    UIImageView *myAvatarImageView;
    
    
    //表情
    BOOL isFaceButtonClicked;
    UIButton *faceBtn;
    BOOL isKeyBoardHide;
    
    NSString                   *_titleString;
    NSMutableString            *_messageString;
    NSString                   *_phraseString;
    NSMutableArray		       *_chatArray;
    NSMutableArray		       *_tempChatArray;
    NSMutableArray		       *_beforeChatArray;
    
    UITextField                *_messageTextField;
    BOOL                       _isFromNewSMS;
    //AsyncUdpSocket             *_udpSocket;
    NSDate                     *_lastTime;
    sqlite3 *database;
    WCChatSelectionView      *_shareMoreView;
    
    
    
    //消息提示音控制
    BOOL msgSoundReminder;
    BOOL msgVibrateReminder;
    
    
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
    
    int isSelfFlag;
    
    //图片浏览器
    UISegmentedControl *_segmentedControl;
    NSMutableArray *_selections;
    

    //发送图片相关
    ASINetworkQueue *myImageQueue;
    UIProgressView *myProgressIndicator;
    
    int imageMsgId;
    NSString *photographURL;
    
    //分页
    int beforeChatArrayCount;
    int loadingRow;
    
    
}

//新ui
@property (nonatomic,strong) UITableView *messageDisplayView;

@property (nonatomic,strong)  PPLabel *ppLabel;
@property(nonatomic, strong) NSArray* matches;
@property(nonatomic, strong) NSArray* matches2;
@property(nonatomic, strong) NSArray* matches3;

@property(nonatomic, strong) NSString* phoneNum;

@property(nonatomic, strong)  ABNewPersonViewController *picker;


@property (nonatomic,strong)ABPeoplePickerNavigationController *phonePicker;

//loading
@property (nonatomic,strong)YLImageView *ylImageview;

//图片浏览器
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic, strong) NSMutableArray *assets;

- (void)loadAssets;


//语音消息随机ID
@property (nonatomic, retain) NSString *voiceMsgRandomId;



@property (retain,nonatomic) UITableView *chatTableView;


@property (nonatomic, retain)  UIView *containerView;


//@property (nonatomic, retain) IBOutlet UITableView            *chatTableView;
@property (nonatomic) BOOL refreshing;
@property (assign,nonatomic) NSInteger pageSize;
@property (assign,nonatomic) NSInteger pageTotal;
@property (assign,nonatomic) NSInteger currentPage;
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
//是否是客服消息
@property(nonatomic) BOOL isCSMsg;
@property(nonatomic, retain) NSString *chatWithUser;//用户号
@property(nonatomic, retain) NSString *chatWithJID;//用户号+域名（jid)
@property(nonatomic, retain) NSString *chatWithNick;//用户昵称
@property (nonatomic, copy) NSString *remarkName;
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
@property (nonatomic, retain) NSString *imgMsgRandomId;//随机ID
@property (nonatomic, retain) UIImage *tempSendImage;//临时图片
@property (nonatomic, retain) NSMutableArray*tempSendImageArray; //选取的图片
@property (nonatomic, retain) NSMutableArray*sendImageArray;//将要发送的图片
@property (nonatomic, retain) NSMutableArray*tempImgMsgRandomIdArray; //图片Id

//弹出菜单
@property (nonatomic, retain) NSString *playMode;
@property (nonatomic, retain) QBPopupMenu *popupMenu;
@property (nonatomic, retain) QBPopupMenu *popupMenu2;
@property (nonatomic, retain) QBPopupMenu *popupMenu3;
@property (nonatomic, retain) NSIndexPath *menuIndexPath;

-(IBAction)changeVoicePlayMode;
-(IBAction)changeVoicePlayMode2;
-(IBAction)deleteCellFromTableView:(NSIndexPath *)indexPath;
@end
