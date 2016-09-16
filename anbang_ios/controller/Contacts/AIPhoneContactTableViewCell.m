//
//  AIPhoneContactTableViewCell.m
//  anbang_ios
//
//  Created by Kim on 15/5/4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIPhoneContactTableViewCell.h"

@implementation AIPhoneContactTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    self.imageView.frame = CGRectMake(15, 9, 29, 29);
    
    CGFloat lx = CGRectGetMaxX(self.imageView.frame) + 15;
    CGFloat lw = Screen_Width - 85 - lx;
    self.textLabel.frame = CGRectMake(lx, 9, lw, 17);
    
    CGFloat dl_y = CGRectGetMaxY(self.textLabel.frame);
    self.detailTextLabel.frame = CGRectMake(lx, dl_y, lw, 12);
}

@end
