//
//  ZBMessageBubble.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-19.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import "ZBMessageBubble.h"
#import "NSAttributedString+Attributes.h"
#import "ZBMessageVoiceFactory.h"

@implementation ZBMessageBubble

- (UIImageView*)getBubbleViewByMessage:(ZBMessage *)message{
    
    UIImageView *bubbleView = [[UIImageView alloc]init];
    bubbleView.image = [ZBMessageBubbleFactory bubbleImageViewForType:message.bubbleType
                                                            meidaType:message.messageType];
    
    switch (message.messageType)
    {
        case ZBBubbleMessageFace:
        {
        
        }
            break;
        case ZBBubbleMessageVideo:
        {
        
        }
            break;
        case ZBBubbleMessageVoice:
        {
            UIImageView *voiceImageView = [ZBMessageVoiceFactory messageVoiceAnimationImageViewWithBubbleMessageType:message.bubbleType];
            bubbleView.frame = CGRectMake(0.0f, 0.0f, 60, 30);
            
            [bubbleView addSubview:voiceImageView];
            
        }
            break;
        case ZBBubbleMessagePhoto:
        {
            UIImage *photo = [UIImage imageWithContentsOfFile:message.thumbnailUrl];
            UIImageView *photoImageView = [[UIImageView alloc]initWithImage:photo];
            
            photoImageView.frame = CGRectMake(10.0f, 10.0f,photo.size.width,photo.size.height);
            bubbleView.frame = CGRectMake(0.0f, 0.0f, photo.size.width +20.0f,photo.size.height+20.0f);
            
            [bubbleView addSubview:photoImageView];
        
        }
            break;
        case ZBBubbleMessageLocalPosition:
        {
            UIImageView *localPositionImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"map_located@2x.png"]];
            bubbleView.frame = CGRectMake(0.0f, 0.0f,139.0f,139.0f);
            
            localPositionImageView.frame = CGRectMake(10.0f,10.0f, 119.0f, 119.0f);
            [bubbleView addSubview:localPositionImageView];
            
            //UILabel *addressInfo = [UILabel alloc]initWithFrame:CGRectMake(, , , );
        }
            break;
        case ZBBubbleMessageText:
        {
            OHAttributedLabel *messageLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectZero];
            [self creatAttributedLabel:message.text Label:messageLabel];
            [CustomMethod drawImage:messageLabel];
            
            bubbleView.frame = CGRectMake(0.0f,0.0f,CGRectGetWidth(messageLabel.frame)+20.0f,CGRectGetHeight(messageLabel.frame)+12.0f);
            messageLabel.frame = CGRectMake(5.0f,6.0f,CGRectGetWidth(messageLabel.frame),CGRectGetHeight(messageLabel.frame));
            [bubbleView addSubview:messageLabel];
        }
            break;
        default:
            break;
    }
    
    return bubbleView;
}

-(void)creatAttributedLabel:(NSString *)text Label:(OHAttributedLabel *)label{
    [label setNeedsDisplay];
    
    NSMutableArray *httpArr = [CustomMethod addHttpArr:text];
    NSMutableArray *phoneNumArr = [CustomMethod addPhoneNumArr:text];
    NSMutableArray *emailArr = [CustomMethod addEmailArr:text];
    
    NSString *expressionPlistPath = [[NSBundle mainBundle]pathForResource:@"expression" ofType:@"plist"];
    NSDictionary *expressionDic   = [[NSDictionary alloc]initWithContentsOfFile:expressionPlistPath];
    
    NSString *o_text = [CustomMethod transformString:text emojiDic:expressionDic];
   // o_text = [NSString stringWithFormat:@"<font color='black' strokeColor='gray' face='Palatino-Roman'>%@",o_text];
    
    MarkupParser *wk_markupParser = [[MarkupParser alloc] init];
    NSMutableAttributedString* attString = [wk_markupParser attrStringFromMarkup:o_text];
    [attString setFont:[UIFont systemFontOfSize:16]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setAttString:attString withImages:wk_markupParser.images];
    
    NSString *string = attString.string;
    
    if ([emailArr count])
    {
        for (NSString *emailStr in emailArr)
        {
            [label addCustomLink:[NSURL URLWithString:emailStr] inRange:[string rangeOfString:emailStr]];
        }
    }
    
    if ([phoneNumArr count])
    {
        for (NSString *phoneNum in phoneNumArr)
        {
            [label addCustomLink:[NSURL URLWithString:phoneNum] inRange:[string rangeOfString:phoneNum]];
        }
    }
    if ([httpArr count])
    {
        for (NSString *httpStr in httpArr)
        {
            [label addCustomLink:[NSURL URLWithString:httpStr] inRange:[string rangeOfString:httpStr]];
        }
    }
    label.delegate = self;
    
    CGRect labelRect = label.frame;
    labelRect.size.width = [label sizeThatFits:CGSizeMake(200, CGFLOAT_MAX)].width;
    labelRect.size.height = [label sizeThatFits:CGSizeMake(200, CGFLOAT_MAX)].height;
    
    label.frame = labelRect;
    
    label.underlineLinks = NO;
    [label.layer display];
}

-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo{
    return YES;
}


@end
