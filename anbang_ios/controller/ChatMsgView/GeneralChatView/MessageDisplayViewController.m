
#import "MessageDisplayViewController.h"
#import "ZBMessageManagerFaceView.h"


@interface MessageDisplayViewController (){
    double animationDuration;
    CGRect keyboardRect;
}

@end

@implementation MessageDisplayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark - Life circle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(zbkeyboardWillShow:)
                                                name:UIKeyboardWillShowNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(zbkeyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(zbkeyboardChange:)
                                                name:UIKeyboardDidChangeFrameNotification
                                              object:nil];
}

- (void)dealloc{
    self.messageToolView = nil;
    self.faceView = nil;
    self.shareMenuView = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

#pragma mark -keyboard
- (void)zbkeyboardWillHide:(NSNotification *)notification{
    
    keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
}

- (void)zbkeyboardWillShow:(NSNotification *)notification{
    keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    animationDuration= [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
}

- (void)zbkeyboardChange:(NSNotification *)notification{
    if ([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y<CGRectGetHeight(self.view.frame)) {
        [self messageViewAnimationWithMessageRect:[[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:0.3
                                         andState:ZBMessageViewStateShowNone];
    }
}

#pragma end

#pragma mark - messageView animation
- (void)messageViewAnimationWithMessageRect:(CGRect)rect  withMessageInputViewRect:(CGRect)inputViewRect andDuration:(double)duration andState:(ZBMessageViewState)state{
    [UIView animateWithDuration:duration animations:^{
        self.messageToolView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect)-CGRectGetHeight(inputViewRect),CGRectGetWidth(self.view.frame),CGRectGetHeight(inputViewRect));
        

        switch (state) {
            case ZBMessageViewStateShowFace:
            {
                self.faceView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect),CGRectGetWidth(self.view.frame),CGRectGetHeight(rect));
              
                self.shareMenuView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.shareMenuView.frame));
            }
                break;
            case ZBMessageViewStateShowNone:
            {
                self.faceView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.faceView.frame));
                
                self.shareMenuView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.shareMenuView.frame));
            }
                break;
            case ZBMessageViewStateShowShare:
            {
                self.shareMenuView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect),CGRectGetWidth(self.view.frame),CGRectGetHeight(rect));
                
                self.faceView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.faceView.frame));
            }
                break;

            default:
                break;
        }
        
   } completion:^(BOOL finished) {
        
}];
}
#pragma end

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initilzer];
    
    animationDuration = 0.25;
    
  
    
}
#pragma mark - 初始化
- (void)initilzer{
    
    CGFloat inputViewHeight;
    
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7) {
        inputViewHeight = 50.0f;
    }
    else{
        inputViewHeight = 40.0f;
    }
    self.messageToolView = [[ZBMessageInputView alloc]initWithFrame:CGRectMake(0.0f,
                                                                               self.view.frame.size.height - inputViewHeight,self.view.frame.size.width,inputViewHeight)];
    self.messageToolView.delegate = self;
    [self.view addSubview:self.messageToolView];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self shareFaceView];
    [self shareShareMeun];
    
}

- (void)shareFaceView{
    
    if (!self.faceView)
    {
        self.faceView = [[ZBMessageManagerFaceView alloc]initWithFrame:CGRectMake(0.0f,
                                                                                  CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 226)];
        self.faceView.delegate = self;
        [self.view addSubview:self.faceView];
        
    }
}

- (void)shareShareMeun
{
    if (!self.shareMenuView)
    {
        self.shareMenuView = [[ZBMessageShareMenuView alloc]initWithFrame:CGRectMake(0.0f,
                                                                                     CGRectGetHeight(self.view.frame),
                                                                                     CGRectGetWidth(self.view.frame), 276)];
        [self.view addSubview:self.shareMenuView];
        self.shareMenuView.delegate = self;
        
        
        
        ZBMessageShareMenuItem *sharePicItem = [[ZBMessageShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"chat_icon_pic"]
                                                                                                title:@"照片"];
        ZBMessageShareMenuItem *sharePhotoItem = [[ZBMessageShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"chat_icon_takepic"]
                                                                                                  title:@"拍摄"];
        ZBMessageShareMenuItem *shareVoipItem = [[ZBMessageShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"chat_icon_call"]
                                                                                                 title:@"网络通话"];
        ZBMessageShareMenuItem *shareLocItem = [[ZBMessageShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"chat_icon_position"]
                                                                                                title:@"地理位置"];
        ZBMessageShareMenuItem *shareCardItem = [[ZBMessageShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:@"chat_icon_card"]
                                                                                                  title:@"名片"];
        
        if([[[NSUserDefaults standardUserDefaults]stringForKey:@"NSUD_MultiMedia_Flag"] isEqualToString:@"group"]){
              self.shareMenuView.shareMenuItems = [NSArray arrayWithObjects:sharePicItem,sharePhotoItem,shareLocItem,shareCardItem, nil];
        }else{
              self.shareMenuView.shareMenuItems = [NSArray arrayWithObjects:sharePicItem,sharePhotoItem,shareVoipItem,shareLocItem,shareCardItem, nil];
        }
      
        [self.shareMenuView reloadData];
    
    }
}


//更多每个item 点击事件
-(void)didSelecteShareMenuItem:(NSInteger)index{
    
     [self didSelecteShareMenuItem:index];
    
}


#pragma mark - ZBMessageInputView Delegate
- (void)didSelectedMultipleMediaAction:(BOOL)changed{
    
    //silencesky upd
    [self didShareButton:changed];
    
    if (changed)
    {
         [self messageViewAnimationWithMessageRect:self.shareMenuView.frame
                          withMessageInputViewRect:self.messageToolView.frame
                                       andDuration:animationDuration
                                          andState:ZBMessageViewStateShowShare];
    }
    else{
         [self messageViewAnimationWithMessageRect:keyboardRect
                          withMessageInputViewRect:self.messageToolView.frame
                                       andDuration:animationDuration
                                          andState:ZBMessageViewStateShowNone];
    }
    
}

- (void)didSendFaceAction:(BOOL)sendFace{
    
    //silencesky upd
    [self didFaceButton:sendFace];
    
    if (sendFace) {
        
        //还原高度
        if (!self.previousTextViewContentHeight)
        {
            self.previousTextViewContentHeight = self.messageToolView.messageInputTextView.contentSize.height;
        }
        
        
        [self messageViewAnimationWithMessageRect:self.faceView.frame
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowFace];
    }
    else{
        [self messageViewAnimationWithMessageRect:keyboardRect
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
}

- (void)didChangeSendVoiceAction:(BOOL)changed{
    if (changed){
        [self messageViewAnimationWithMessageRect:keyboardRect
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
    else{
        [self messageViewAnimationWithMessageRect:CGRectZero
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
  
}

/*
 * 点击输入框代理方法
 */
- (void)inputTextViewWillBeginEditing:(ZBMessageTextView *)messageInputTextView{
    
}

- (void)inputTextViewDidBeginEditing:(ZBMessageTextView *)messageInputTextView
{
    [self messageViewAnimationWithMessageRect:keyboardRect
                     withMessageInputViewRect:self.messageToolView.frame
                                  andDuration:animationDuration
                                     andState:ZBMessageViewStateShowNone];
    
    if (!self.previousTextViewContentHeight)
    {
        self.previousTextViewContentHeight = messageInputTextView.contentSize.height;
    }
}

- (void)inputTextViewDidChange:(ZBMessageTextView *)messageInputTextView
{
    CGFloat maxHeight = [ZBMessageInputView maxHeight];
    
    NSLog(@"******%f",messageInputTextView.frame.size.height);
    
    CGSize size = [messageInputTextView sizeThatFits:CGSizeMake(CGRectGetWidth(messageInputTextView.frame), maxHeight)];
    CGFloat textViewContentHeight = size.height;
    
    // End of textView.contentSize replacement code
    BOOL isShrinking = textViewContentHeight < self.previousTextViewContentHeight;
    CGFloat changeInHeight = textViewContentHeight - self.previousTextViewContentHeight;
    
    if(!isShrinking && self.previousTextViewContentHeight == maxHeight) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
        NSLog(@"*****%f",changeInHeight);
    }
    
    if(changeInHeight != 0.0f) {
        
        [UIView animateWithDuration:0.01f
                         animations:^{
        
                             if(isShrinking) {
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self.messageToolView adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect inputViewFrame = self.messageToolView.frame;
                             self.messageToolView.frame = CGRectMake(0.0f,
                                                                      inputViewFrame.origin.y - changeInHeight,
                                                                      inputViewFrame.size.width,
                                                                      inputViewFrame.size.height + changeInHeight);
                             
                             if(!isShrinking) {
                                 [self.messageToolView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        
        self.previousTextViewContentHeight = MIN(textViewContentHeight, maxHeight);
    }
}
/*
 * 发送信息
 */
- (void)didSendTextAction:(ZBMessageTextView *)messageInputTextView{
    
    ZBMessage *message = [[ZBMessage alloc]initWithText:messageInputTextView.text sender:nil timestamp:[NSDate date]];
    [self sendMessage:message];
    
    [messageInputTextView setText:nil];
    [self inputTextViewDidChange:messageInputTextView];
}

- (void)didCallRemindViewControllerAction:(ZBMessageTextView *)messageInputTextView{
    [self callRemindViewController:messageInputTextView];
    [self inputTextViewDidChange:messageInputTextView];
}

-(void)didRemoveRemindBlockAction:(ZBMessageTextView*)messageInputTextView {
    [self removeRemindBlock:messageInputTextView];
}

- (void)sendMessage:(ZBMessage *)message{

}

- (void)callRemindViewController{
    
}

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction{
    [self didStartRecording];
}
- (void)didStartRecording{}

-(void)didCancelRecordingVoiceAction{
    [self didCancelRecording];
}
- (void)didCancelRecording{}

-(void)didFinishRecoingVoiceAction{
    [self didFinishRecoing];
}

- (void)didFinishRecoing{}


-(void)didCancelRecordingDragExitVoiceAction{
     [self didDragExitRecoing];
    
}

- (void)didDragExitRecoing{}


-(void)didCancelRecordingDragEnterVoiceAction{
    [self didDragEnterRecoing];
    
}

-(void)didDragEnterRecoing{
    
}

//点击分享
- (void)didShareButton:(BOOL)flag{}

//点击表情
-(void) didFaceButton:(BOOL)sendFace{}

#pragma end

#pragma mark - ZBMessageFaceViewDelegate
- (void)SendTheFaceStr:(NSString *)faceStr isDelete:(BOOL)dele
{
    if ([StrUtility isBlankString:faceStr]) {
        faceStr = @"";
    }
    
    if(dele){
        NSString *text = self.messageToolView.messageInputTextView.text;
        
        if(text != nil && ![text isEqualToString:@""]){
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(.*)\\[\\w{1,3}\\]$" options:NSRegularExpressionCaseInsensitive error:nil];
            NSString *replaced = [regex stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, [text length]) withTemplate:@"$1"];
            
            if ([text isEqualToString:replaced]) {
                self.messageToolView.messageInputTextView.text = [text substringToIndex:text.length -1];
                [self didRemoveRemindBlockAction:self.messageToolView.messageInputTextView];
            } else {
                self.messageToolView.messageInputTextView.text = replaced;
            }
        }
    }
   

    NSLog(@"*******%@",faceStr);
   // [self.messageToolView.messageInputTextView becomeFirstResponder];

    self.messageToolView.messageInputTextView.text = [self.messageToolView.messageInputTextView.text stringByAppendingString:faceStr];
    [self inputTextViewDidChange:self.messageToolView.messageInputTextView];
    
}
#pragma end


#pragma mark - ZBMessageFaceViewDelegate
- (void)SendFaceBtnAction
{
   
    [self didSendTextAction:self.messageToolView.messageInputTextView];
    //[self didSendFaceButton];
  
}
#pragma end



#pragma mark - ZBMessageShareMenuView Delegate
- (void)didSelecteShareMenuItem:(ZBMessageShareMenuItem *)shareMenuItem atIndex:(NSInteger)index{
    [self didSelecteShareMenuItem:index];
}
#pragma end







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
