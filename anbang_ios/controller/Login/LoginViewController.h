

#import <UIKit/UIKit.h>
#import "CHAppDelegate.h"
#import "NIDropDown.h"
#import "sqlite3.h"
#import "BBTextField.h"



@interface LoginViewController : UIViewController<XMPPStreamDelegate,UITextFieldDelegate>
{
    UIButton *btnLab;
    XMPPStream *xmppStream;
    BBTextField *userTextField;
    UIButton *btnLogin;
    BBTextField *passTextField;
    
    UIImageView *logoView;
     NIDropDown *dropDown;
    sqlite3 *database;
}

/*- (IBAction)LoginButton:(id)sender;*/
- (IBAction)clickLab:(id)sender;
@end
