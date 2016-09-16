

#import "ZBFaceView.h"

#define NumPerLine 7
#define Lines    3
#define FaceSize  32
/*
** 两边边缘间隔
 */
#define EdgeDistance 20
/*
 ** 上下边缘间隔
 */
#define EdgeInterVal 5

@implementation ZBFaceView
{
    NSDictionary *mPlistDic;
}

- (id)initWithFrame:(CGRect)frame forIndexPath:(NSInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        // 水平间隔
        CGFloat horizontalInterval = (CGRectGetWidth(self.bounds)-NumPerLine*FaceSize -2*EdgeDistance)/(NumPerLine-1);
        // 上下垂直间隔
        CGFloat verticalInterval = (CGRectGetHeight(self.bounds)-2*EdgeInterVal -Lines*FaceSize)/(Lines-1);
        
        NSLog(@"%f,%f",verticalInterval,CGRectGetHeight(self.bounds));
        
        NSString *plistStr = [[NSBundle mainBundle]pathForResource:@"expression" ofType:@"plist"];
        mPlistDic = [[NSDictionary  alloc]initWithContentsOfFile:plistStr];
        
        for (int i = 0; i<Lines; i++)
        {
            for (int x = 0;x<NumPerLine;x++)
            {
                UIButton *expressionButton =[UIButton buttonWithType:UIButtonTypeCustom];
                
                [self addSubview:expressionButton];
                [expressionButton setFrame:CGRectMake(x*FaceSize+EdgeDistance+x*horizontalInterval,
                                                      i*FaceSize+i*verticalInterval+EdgeInterVal,
                                                      FaceSize,
                                                      FaceSize)];
                
                if (i*7+x+1 == 21) {
                    [expressionButton setBackgroundImage:[UIImage imageNamed:@"icon_delete"]
                                                forState:UIControlStateNormal];
                    expressionButton.tag = 0;
        
                }else if(index*20+i*7+x < mPlistDic.allKeys.count) {
                    NSString *key = [[mPlistDic allKeys]objectAtIndex:index*20+i*7+x];
                    NSString *imageStr = [mPlistDic objectForKey:key];
                    [expressionButton setBackgroundImage:[UIImage imageNamed:imageStr]
                                                forState:UIControlStateNormal];
                    expressionButton.tag = 20*index+i*7+x+1;
                }
                [expressionButton addTarget:self
                                     action:@selector(faceClick:)
                           forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        
    }
    return self;
}

- (void)faceClick:(UIButton *)button{
    
    NSString *faceName;
    BOOL isDelete = NO;
    if (button.tag ==0){
        faceName = nil;
        isDelete = YES;
    }else{
        faceName = [[mPlistDic allKeys]objectAtIndex:button.tag-1];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelecteFace:andIsSelecteDelete:)]) {
        [self.delegate didSelecteFace:faceName andIsSelecteDelete:isDelete];
    }
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
