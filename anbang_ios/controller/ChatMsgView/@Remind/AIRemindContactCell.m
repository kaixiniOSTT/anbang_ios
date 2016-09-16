//
//  AIRemindContactCell.m
//  anbang_ios
//
//  Created by rooter on 15-7-8.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIRemindContactCell.h"
#import "UIImageView+WebCache.h"

#define Cell_Height 43
#define Image_View_WH 29

@interface AIRemindContactCell ()
@property (weak, nonatomic) UIImageView *abIcon;
@end

@implementation AIRemindContactCell

+ (AIRemindContactCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *reuseIdentifer = @"AIRemind";
    AIRemindContactCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifer];
    if (!cell) {
        cell = [[AIRemindContactCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:reuseIdentifer];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    UIImageView *abIcon = [[UIImageView alloc] init];
    abIcon.contentMode = UIViewContentModeScaleAspectFit;
    abIcon.image = [UIImage imageNamed:@"icon_ab01"];
    [self.imageView addSubview:abIcon];
    self.abIcon = abIcon;
    
    self.textLabel.font = [UIFont systemFontOfSize:15];
}

+ (CGFloat)cellHeight {
    return 43;
}

- (void)setContact:(NSDictionary *)contact {
    _contact = contact;
    self.textLabel.text = [contact objectForKey:@"nickName"];
    NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",
                          ResourcesURL, [contact objectForKey:@"avatar"]];
    [self.imageView setImageWithURL:[NSURL URLWithString:avatarURL]
                   placeholderImage:[UIImage imageNamed:@"icon_defaultPic.png"]];
    self.abIcon.hidden = !([contact[@"accountType"] intValue] == 2);
}

- (void)layoutSubviews {
    self.imageView.frame = CGRectMake(15, 7, Image_View_WH, Image_View_WH);
    self.abIcon.frame = CGRectMake(Image_View_WH-16, Image_View_WH-11, 16, 11);
    CGFloat textLabel_x = CGRectGetMaxX(self.imageView.frame) + 15;
    self.textLabel.frame = CGRectMake(textLabel_x, 7, Screen_Width - textLabel_x, Image_View_WH);
}

@end
