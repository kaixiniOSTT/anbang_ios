//
//  AIItemModel.m
//  anbang_ios
//
//  Created by rooter on 15-4-30.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIItemModel.h"
#import "AIMessageTool.h"

@implementation AIItemModel

- (instancetype)init
{
    if (self = [super init]) {
        // 初始化化一些不变的控件的frame
        CGFloat icon_wh = Icon_View_WH;
        _iconViewF = CGRectMake(Margin_To_Left_Right, Margin_To_Top_Bottom, icon_wh, icon_wh);
    }
    return self;
}

- (void)setCollection:(AICollection *)collection
{
    _collection = collection;
    
    NSString *tmp = [Utility UTCFormatToLocalFormat:collection.createDate];
    NSString *strTime = [Utility friendlyTime_03:tmp];
    CGSize time_lb_size = [strTime sizeWithAttributes:@{NSFontAttributeName:AICollectionTimeFont}];
    CGFloat time_lb_x = Screen_Width - Margin_To_Cell_Right - time_lb_size.width;
    _timeLabelF = CGRectMake(time_lb_x, Margin_To_Top_Bottom, time_lb_size.width, time_lb_size.height);
    
    //无论何种message都是“message”属性控制的，需在设置Frame时清空之前的Frame
    _contentImageViewF = CGRectZero;
    _contentLabelF = CGRectZero;
    _documentIconF = CGRectZero;
    _documentLabelF = CGRectZero;
    _LinkBackViewF = CGRectZero;
    _linkIconF =  CGRectZero;
    _linkLabelF = CGRectZero;
    
    CGFloat nick_lb_x = CGRectGetMaxX(_iconViewF) + Margin_To_Left_Right;
    CGFloat line_height = [strTime sizeWithAttributes:@{NSFontAttributeName:AICollectionContentFont}].height;
    
    switch (collection.messageType) {
        case AIMessageTypeText: {
            CGFloat content_lb_w = Screen_Width - nick_lb_x - Margin_To_Cell_Right;
            CGFloat content_lb_y = CGRectGetMaxY(_nickLabelF) + Margin_Between;
            CGSize content_lb_size = [collection.message sizeWithFont:AICollectionContentFont constrainedToSize:CGSizeMake(content_lb_w, MAXFLOAT)];
            if (content_lb_size.height > line_height * 3) {
                content_lb_size.height = 3 * line_height;
            }
            _contentLabelF = CGRectMake(nick_lb_x, content_lb_y, content_lb_size.width, content_lb_size.height);
            
            _cellHeight = CGRectGetMaxY(_contentLabelF) + Margin_To_Top_Bottom;
        }
            break;
        
        case AIMessageTypePicture: {
            CGFloat img_view_x = nick_lb_x;
            CGFloat img_view_y = CGRectGetMaxY(_nickLabelF) + Margin_Between;
            UIImage *image = [AIMessageTool messageToImage:collection.message];
            CGSize img_size = image.size;
            if (img_size.height > Content_Image_View_Max_Height) {
                CGFloat image_view_h = Content_Image_View_Max_Height;
                CGFloat img_view_w = (img_size.width * 1.0 / img_size.height ) * image_view_h;
                _contentImageViewF = CGRectMake(img_view_x, img_view_y, img_view_w, image_view_h);
            }else {
                _contentImageViewF = CGRectMake(img_view_x, img_view_y, img_size.width, img_size.height);
            }
            
            _cellHeight = CGRectGetMaxY(_contentImageViewF) + Margin_To_Top_Bottom;
        }
            break;
        case AIMessageTypeVoice: {
            
        }
            break;
            
        case AIMessageTypeDocument:{
            CGFloat y = CGRectGetMaxY(_nickLabelF) + Margin_Between;
            CGFloat w = Screen_Width - nick_lb_x - Margin_To_Cell_Right;
            _documentIconF = CGRectMake(nick_lb_x, y, Document_Iocn_View_WH, Document_Iocn_View_WH);
            _documentLabelF = CGRectMake(CGRectGetMaxX(_documentIconF) + 10, y, w - Document_Iocn_View_WH - 10, Document_Iocn_View_WH);
            
            _cellHeight = CGRectGetMaxY(_documentIconF) + Margin_To_Top_Bottom;
        }
            break;
            
        case AIMessageTypeArticle:{
            CGFloat y = CGRectGetMaxY(_nickLabelF) + Margin_Between;
            CGFloat w = Screen_Width - nick_lb_x - Margin_To_Cell_Right;
            _linkIconF = CGRectMake(8, 8, Link_Icon_View_WH, Link_Icon_View_WH);
            _linkLabelF = CGRectMake(CGRectGetMaxX(_linkIconF) + 8, 8, w - Link_Icon_View_WH - 16, Link_Icon_View_WH);
            _LinkBackViewF = CGRectMake(nick_lb_x, y, w, 56);
            
            _cellHeight = CGRectGetMaxY(_LinkBackViewF) + Margin_To_Top_Bottom;
        }
            
        default:
            break;
    }	
}

- (void)setExtraInfo:(AIExtraInfo *)extraInfo
{
    _extraInfo = extraInfo;
    
    CGFloat nick_lb_x = CGRectGetMaxX(_iconViewF) + Margin_To_Left_Right;
    CGSize nick_lb_size = [extraInfo.name sizeWithFont:AICollectionNickFont];
    _nickLabelF = CGRectMake(nick_lb_x, Margin_To_Top_Bottom, nick_lb_size.width, nick_lb_size.height);
}

@end
