

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <BaiduMapAPI/BMapKit.h>

#if !TARGET_IPHONE_SIMULATOR
#import "VoipModule.h"
#endif

#import "WXApi.h"
#import "AGViewDelegate.h"

@class MainViewController;

@interface CHAppDelegate : UIResponder <UINavigationControllerDelegate,WXApiDelegate,UIApplicationDelegate,UITabBarControllerDelegate,AVAudioSessionDelegate
#if !TARGET_IPHONE_SIMULATOR
,VoipDelegate
#endif
>{
    XMPPServer *xmppServer;
    UIImageView *_selectView;
 

    UIView *startView;//startView
    UIView *rView;//动画的UIView
    
     UIBackgroundTaskIdentifier backgroundTask; //用来保存后台运行任务的标示符
    BMKMapManager* _mapManager;

}


@property (retain,nonatomic) UIImageView *tabBarBG;

@property (retain, nonatomic) UIWindow *window;

@property (retain, nonatomic) UIViewController *viewController;

@property (nonatomic,retain) XMPPServer *xmppServer;

@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong,nonatomic) UINavigationController *navController;

@property (strong,nonatomic) UIButton *selectedBtn;
#if !TARGET_IPHONE_SIMULATOR
@property(nonatomic,retain) VoipModule* voipModule;
#endif

@property (nonatomic,readonly) AGViewDelegate *viewDelegate;

- (void)loadAppConfiguration;
- (void)loadCustomTabBarView;
- (void)setTimer;
- (void)ui;
- (void)hideTabBar:(BOOL) hidden;
@end
