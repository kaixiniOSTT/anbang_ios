//
//  contactsCell.m
//  anbang_ios
//
//  Created by yangsai on 15/5/15.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "ContactsCell.h"

#define Cell_Height  (kIsiPhone6p ? 65 : 43)
#define Picture_W  (kIsiPhone6p ?  44 : 29)

#define Picture_X 15
#define Picture_Y (kIsiPhone6p ? 11 : 7)


@implementation ContactsCell

- (void)awakeFromNib {
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(instancetype)init{
    self = [super init];
    if(self){
        self.pictureImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, self.center.y - 21 * 0.5, 21, 21)];

        
        [self addSubview:self.pictureImage];
        self.lableName = [[UILabel alloc]initWithFrame:CGRectMake( CGRectGetMaxX(_pictureImage.frame) + 12 , self.center.y - 15, 30, 30)];
        self.lableName.font = [UIFont systemFontOfSize:17];
        [self addSubview:_lableName];
    
    }
    return self;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.pictureImage = [[UIImageView alloc]init];
        [self.contentView addSubview:self.pictureImage];
        self.lableName = [[UILabel alloc] init];
        self.lableName.font = [UIFont systemFontOfSize:15];
        self.lableName.textColor = AB_Color_5b5752;
        [self.contentView addSubview:_lableName];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = self.contentView.frame.size.height + 0.5;
    self.pictureImage.frame = CGRectMake(15, (height - 29) * 0.5, 29, 29);
    CGFloat ln_x = CGRectGetMaxX(self.pictureImage.frame) + 15;
    self.lableName.frame = CGRectMake(ln_x, self.pictureImage.frame.origin.y, Screen_Width - 15, 29);
}
@end
