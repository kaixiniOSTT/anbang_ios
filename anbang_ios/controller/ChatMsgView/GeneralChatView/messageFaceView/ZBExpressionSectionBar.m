
#import "ZBExpressionSectionBar.h"

@implementation ZBExpressionSectionBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xefe8df);
        [self sendUI];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) sendUI{
  
    UIImage *sendBtnBackground = [UIImage imageNamed:@"chat_button_send"];
    UIButton* sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(KCurrWidth-55, 0, 30, 30);
    [sendBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendFaceAction) forControlEvents:UIControlEventTouchUpInside];
    [sendBtn setImage:sendBtnBackground forState:UIControlStateNormal];
    [sendBtn setTintColor:[UIColor grayColor]];
    sendBtn.backgroundColor = UIColorFromRGB(0xefe8df);
    [sendBtn.layer setCornerRadius:5.0];

    
    [self addSubview:sendBtn];
}

-(void)sendFaceAction{

   
        [self.delegate didSendBtnFace];

    
}
@end
