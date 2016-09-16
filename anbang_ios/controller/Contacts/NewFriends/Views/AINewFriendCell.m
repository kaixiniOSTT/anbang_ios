//
//  AINewFriendCell.m
//  anbang_ios
//
//  Created by rooter on 15-6-16.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AINewFriendCell.h"
#import "UIImageView+WebCache.h"
#import "AINewFriendsCRUD.h"
#import "AIUIButton.h"

#define Icon_View_WH (kIsiPhone6p ?  50: 30)
#define Margin_To_Left 15
#define Cell_Height  (kIsiPhone6p ?  70: 50)

#define Margin_To_Top 10//( Cell_Height - Icon_View_WH ) / 2


@interface AINewFriendCell ()
@property (assign, nonatomic) BOOL status;
@property (weak, nonatomic) UIImageView *iconView;
@property (weak, nonatomic) UILabel *nickNameLabel;
@property (weak, nonatomic) UILabel *detailLabel;
@property (weak, nonatomic) UIImageView *abIcon;
@property (weak, nonatomic) AIUIButton *statusButton;
@end

@implementation AINewFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = AB_Color_ffffff;
        [self setupMe];
        [self setupSubviews];
    }
    return self;
}

+ (AINewFriendCell *)cellForTableView:(UITableView *)tableView {
    static NSString *ID = @"New_Friends_Request_Cell";
    AINewFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[AINewFriendCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:ID];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
        cell.contentView.backgroundColor = AB_Color_ffffff;
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 8);
    }
    return cell;
}

- (void)setupMe {
    self.backgroundColor = AB_Color_ffffff;
    self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
}

- (void)tap:(UIGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(iconViewBeenTappedInCell:)]) {
        [self.delegate iconViewBeenTappedInCell:self];
    }
}

- (void)setupSubviews {
    // AB Icon
    UIImageView *abIcon = [[UIImageView alloc] init];
    abIcon.frame = CGRectMake(Icon_View_WH - 16, Icon_View_WH - 11, 16, 11);
    abIcon.image = [UIImage imageNamed:@"icon_ab01"];
    // status button
    AIUIButton *button = [AIUIButton buttonWithType:UIButtonTypeCustom];
    CGFloat flo = Cell_Height;
    button.frame = CGRectMake(Screen_Width - 85, (flo - 30)/2, 70, 30);
    button.titleLabel.font = AB_FONT_14;
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 3.0;
    [button addTarget:self
               action:@selector(toAccept)
     forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.frame = CGRectMake(Margin_To_Left, Margin_To_Top, Icon_View_WH, Icon_View_WH);
    iconView.layer.cornerRadius = 3.0f;
    iconView.clipsToBounds = YES;
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.userInteractionEnabled = YES;
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [iconView addGestureRecognizer:tap];
    
    CGFloat lx = CGRectGetMaxX(iconView.frame) + Margin_To_Left;
    CGFloat lw = Screen_Width - lx - 85;
    UILabel *nickNameLabel = [[UILabel alloc] init];
    nickNameLabel.frame = (CGRect){CGPointMake(lx, Margin_To_Top-2), CGSizeMake(lw, Icon_View_WH * 2.0 / 3.0)};
    nickNameLabel.font = AB_FONT_15;
    nickNameLabel.textColor = AB_Color_5b5752;
    
    CGFloat ly = CGRectGetMaxY(nickNameLabel.frame);
    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.frame = (CGRect){CGPointMake(lx, ly), CGSizeMake(lw, Icon_View_WH * 1.0 / 3.0 + 2)};
    detailLabel.font = AB_FONT_12;
    detailLabel.textColor = AB_Color_9c958a;
    
    [iconView addSubview:abIcon];
    [self.contentView addSubview:button];
    [self.contentView addSubview:nickNameLabel];
    [self.contentView addSubview:detailLabel];
    [self.contentView addSubview:iconView];

    self.statusButton = button;
    self.abIcon = abIcon;
    self.nickNameLabel = nickNameLabel;
    self.detailLabel = detailLabel;
    self.iconView = iconView;
    
//    self.textLabel.font = AB_FONT_15;
//    self.detailTextLabel.font = AB_FONT_12;
//    self.textLabel.textColor = AB_Color_5b5752;
//    self.detailTextLabel.textColor = AB_Color_9c958a;
}

- (void)setItem:(AINewFriendRequestItem *)item {
    _item = item;
    // icon
    NSString *avatarURLString = [ResourcesURL stringByAppendingPathComponent:item.avatar];
    [self.iconView setImageWithURL:[NSURL URLWithString:avatarURLString]
                   placeholderImage:[UIImage imageNamed:@"icon_defaultPic.png"]];
    // name
    self.nickNameLabel.text = item.name;
    // validate info
    self.detailLabel.text = item.validateInfo;
    // status '1' is accessable to accept
    self.status = item.status.intValue;
    // account type
    int accountType = item.accountType.intValue;
    self.abIcon.hidden = !(accountType == 2);
}

- (void)setStatus:(BOOL)status {
    self.statusButton.userInteractionEnabled = status;
    if (status) {
        self.statusButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self.statusButton setTitleColor:AB_Color_ffffff
                                forState:UIControlStateNormal];
        [self.statusButton setBackgroundColor:AB_Color_7ac141
                                     forState:UIControlStateNormal];
        [self.statusButton setBackgroundColor:AB_Color_68af2f
                                     forState:UIControlStateHighlighted];
        [self.statusButton setTitle:@"接受"
                           forState:UIControlStateNormal];
    }else {
        self.statusButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.statusButton setTitleColor:AB_Color_9c958a
                                forState:UIControlStateNormal];
        self.statusButton.backgroundColor = AB_Color_ffffff;
        [self.statusButton setTitle:@"已接受"
                           forState:UIControlStateNormal];
    }
}

+ (CGFloat)cellHeight {
    return Cell_Height;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //    float cellH = kIsiPhone6p ? 70 : 50;
//    NSLog(@"Icon_View_WH = %d",Icon_View_WH);
//    //self.imageView.frame = CGRectMake(Margin_To_Left, Margin_To_Top, Icon_View_WH, Icon_View_WH);
//    CGFloat lx = CGRectGetMaxX(self.iconView.frame) + Margin_To_Left;
//    //    CGSize ls = [self.item.name sizeWithFont:AB_FONT_16];
//    CGFloat lw = Screen_Width - lx - 85;
//    self.textLabel.frame = (CGRect){CGPointMake(lx, Margin_To_Top-2), CGSizeMake(lw, 17)};
//    CGFloat imgW = Icon_View_WH;
//    CGFloat ly =  kIsiPhone6p ? CGRectGetMaxY(self.iconView.frame) -22: (Margin_To_Top + imgW - 15);//
//    self.detailTextLabel.frame = (CGRect){CGPointMake(lx, ly), CGSizeMake(lw, 17)};
}

- (void)toAccept {
    if (self.delegate && [self.delegate respondsToSelector:@selector(accessoryButtonBeenTappedInCell:)]) {
        [self.delegate accessoryButtonBeenTappedInCell:self];
    }
}

@end
