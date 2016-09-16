//
//  SettingCell.m
//  anbang_ios
//
//  Created by seeko on 14-3-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "SettingCell.h"
// Example Cell
#define defaultPadding 2.5
#define sizeCellWidth 310
#define sizeCellHeight 40
#define sizePicture 34
#define sizeTitleWidth 200
#define sizeTitleheight 20
@implementation SettingCell
@synthesize title;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(defaultPadding, defaultPadding,
                                                                  sizeCellWidth, sizeCellHeight)];
        bgView.backgroundColor = [UIColor whiteColor];
        
        UIView *picture = [[UIView alloc] initWithFrame:CGRectMake(defaultPadding, defaultPadding, sizePicture, sizePicture)];
        picture.backgroundColor = [UIColor redColor];
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(picture.frame.origin.x + picture.frame.size.width + defaultPadding*4, defaultPadding*3, sizeTitleWidth, sizeTitleheight)];
//        title.text = @"Title";
        
        [self.contentView addSubview:bgView];
        [bgView addSubview:title];
        [bgView addSubview:picture];

    }
    return self;
}

//-(void)setName:(NSString *)n{
//    if (![n isEqualToString:_cellTitle]) {
//        _cellTitle=[n copy];
//        title.text=_cellTitle;
//    }
//}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
