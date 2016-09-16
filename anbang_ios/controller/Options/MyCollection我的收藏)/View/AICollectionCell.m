//
//  AICollectionCell.m
//  anbang_ios
//
//  Created by rooter on 15-5-4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AICollectionCell.h"
#import "AIItemModel.h"
#import "UIImageView+WebCache.h"
#import "AIMessageTool.h"
#import "AIDocument.h"
#import "AIArticle.h"
#import "Photo.h"

@implementation AICollectionCell
{
    UIImageView *mIconView;
    UIImageView *mContentImageView;
    UILabel     *mNickLabel;
    UILabel     *mContentLabel;
    UILabel     *mTimeLabel;
    
    UIImageView *mDocIcon;
    UILabel     *mDocLabel;
    
    UIView      *mLinkBackView;
    UIImageView *mLinkIcon;
    UILabel     *mLinkLabel;
    
    
    UIButton    *mMultiSelectButton;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"me_collection_cell";
    AICollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[AICollectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupMe];
        [self setupSubviews];
    }
    return self;
}

- (void)setupMe
{
    self.contentView.backgroundColor = AB_Color_ffffff;
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
    
    UIImage *image = [UIImage imageNamed:@"icon_unselected"];
    mMultiSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mMultiSelectButton.backgroundColor = AB_Color_ffffff;
    [mMultiSelectButton setImage:image forState:UIControlStateNormal];
}

- (void)setItem:(AIItemModel *)item
{
    // set up subviews frames
    mTimeLabel.frame = item.timeLabelF;
    mIconView.frame = item.iconViewF;
    mNickLabel.frame = item.nickLabelF;
    mContentLabel.frame = item.contentLabelF;
    mContentImageView.frame = item.contentImageViewF;
    mDocIcon.frame = item.documentIconF;
    mDocLabel.frame = item.documentLabelF;
    mLinkBackView.frame = item.LinkBackViewF;
    mLinkIcon.frame = item.linkIconF;
    mLinkLabel.frame = item.linkLabelF;
    
    // set up contents
    // header icon view
    UIImage *placeHolderImage = [UIImage imageNamed:@"defaultUser.png"];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", ResourcesURL, item.extraInfo.iconId];
    NSURL *url = [NSURL URLWithString:urlString];
    [mIconView setImageWithURL:url placeholderImage:placeHolderImage];
    
    // nick name
    mNickLabel.text = item.extraInfo.name;
    
    // time
    NSString *tmp = [Utility UTCFormatToLocalFormat:item.collection.createDate];
    NSString *strTime = [Utility friendlyTime_03:tmp];
    mTimeLabel.text = strTime;
    
    NSString *message = item.collection.message;
    switch (item.collection.messageType) {
        case AIMessageTypeText:
            // text message
            mContentLabel.text = message;
            break;
        
        case AIMessageTypePicture:
            // picture message
            mContentImageView.image = [AIMessageTool messageToImage:message];
            break;
            
        case AIMessageTypeVoice:
            // voice message
            break;
            
        case AIMessageTypeDocument: {
            AIDocument *document = [AIDocument documentWithJson:message];
            mDocIcon.image = [AIMessageTool DocumentIconWithType:document.fileType];
            mDocLabel.text = document.fileName;
        }
            break;
            
        case AIMessageTypeArticle: {
            AIArticle *article = [AIArticle articleWithJson:message];
            mLinkIcon.image = [Photo string2Image:article.cover];
            mLinkLabel.text = article.abstract;
        }
            break;
            
        default:
            break;
    }
    
    mIconView.layer.masksToBounds = YES;
    mIconView.layer.cornerRadius = 2;
}

- (void)setupSubviews
{
    // header icon
    UIImageView *iconView = [[UIImageView alloc] init];
    [self.contentView addSubview:iconView];
    
    // nick name label
    UILabel *nickLabel = [[UILabel alloc] init];
    nickLabel.font = AICollectionNickFont;
    nickLabel.textColor = AB_Color_5b5752;
    [self.contentView addSubview:nickLabel];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.font = AICollectionTimeFont;
    timeLabel.textColor = AB_Color_9c958a;
    [self.contentView addSubview:timeLabel];
    
    //content label
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.numberOfLines = 3;
    contentLabel.font = AICollectionContentFont;
    contentLabel.textColor = Color(@"#222222");
    [self.contentView addSubview:contentLabel];
    
    // content image view (for voice & content picture)
    UIImageView *contentImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:contentImageView];
    
    // Document (both image * label)
    UIImageView *docIcon = [[UIImageView alloc] init];
    [self.contentView addSubview:docIcon];
    
    UILabel *docLabel = [[UILabel alloc] init];
    docLabel.numberOfLines = 3;
    docLabel.font = AB_FONT_12;
    docLabel.textColor = AB_Color_222222;
    [self.contentView addSubview:docLabel];
    
    // Link
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = AB_Color_f6f2ed;
    [self.contentView addSubview:backView];
    
    UIImageView *linkIcon = [[UIImageView alloc] init];
    [backView addSubview:linkIcon];
    
    UILabel *linkLabel = [[UILabel alloc] init];
    linkLabel.numberOfLines = 3;
    linkLabel.font = AB_FONT_12;
    linkLabel.textColor = AB_Color_222222;
    [backView addSubview:linkLabel];
    
    mIconView = iconView;
    mNickLabel = nickLabel;
    mContentImageView = contentImageView;
    mContentLabel = contentLabel;
    mTimeLabel = timeLabel;
    
    mDocIcon = docIcon;
    mDocLabel = docLabel;
    
    mLinkBackView = backView;
    mLinkIcon = linkIcon;
    mLinkLabel = linkLabel;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSArray *subviews = [self subviews];
    UIView *control = nil;
    
    for (UIView *view in subviews) {
        //NSLog(@"subViews = %@",NSStringFromClass(view.class));
        if ([NSStringFromClass(view.class) isEqualToString:@"UITableViewCellEditControl"]) {
            control = view;
        }
    }
    if (!control) return;
    
    if (self.selected) {
        UIView *view = self.subviews[0];
        view.backgroundColor = [UIColor clearColor];
        
        mMultiSelectButton.hidden = NO;
        [mMultiSelectButton setImage:[UIImage imageNamed:@"icon_selected"] forState:UIControlStateNormal];
    }else {
        mMultiSelectButton.hidden = YES;
        [mMultiSelectButton setImage:[UIImage imageNamed:@"icon_unselected"] forState:UIControlStateNormal];
    }
    mMultiSelectButton.frame = control.bounds;
    [control.superview addSubview:mMultiSelectButton];
}

- (void)logSubviews:(UIView *)view
{
    for (UIView *subview in view.subviews) {
        JLLog_I(@"view=<%@, %p>, subview=<%@, %p>", view.class, view, subview.class, subview);
        [self logSubviews:subview];
    }
}


@end
