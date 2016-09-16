//
//  AIABSearchContactCell.m
//  anbang_ios
//
//  Created by rooter on 15-5-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIABSearchContactCell.h"
#import "AIABSearchContact.h"
#import "UIImageView+WebCache.h"

@interface AIABSearchContactCell()

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *branchLabel;
@property (strong, nonatomic) UIImageView *arrowView;
@property (strong, nonatomic) UILabel *accessLabel;

@end

#define Cell_Height 60.0

@implementation AIABSearchContactCell

+ (id)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"ab_search_contact_cell";
    AIABSearchContactCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[AIABSearchContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
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
}

- (void)setupSubviews
{
    CGFloat margin_to_top = 10;
    CGFloat margin_to_left = 15;
    
    CGFloat icon_wh = 40;
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.frame = CGRectMake(margin_to_left, margin_to_top, icon_wh, icon_wh);
    iconView.layer.cornerRadius = 3.0;
    [self.contentView addSubview:iconView];
    
    UIImageView *abIcon = [[UIImageView alloc] init];
    abIcon.frame = CGRectMake(CGRectGetMaxX(iconView.frame)-16-15, CGRectGetHeight(iconView.frame)-11, 16, 11);
    abIcon.image = [UIImage imageNamed:@"icon_ab01"];
    [iconView addSubview:abIcon];
    
    CGFloat name_lb_x = CGRectGetMaxX(iconView.frame) + margin_to_left;
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(name_lb_x, margin_to_top, Screen_Width - name_lb_x - 50, 16);
    nameLabel.font = AB_FONT_17;
    nameLabel.textColor = AB_Color_5b5752;
    [self.contentView addSubview:nameLabel];
    
    CGFloat branch_lb_y = CGRectGetMaxY(iconView.frame) - 17;
    UILabel *branchLabel = [[UILabel alloc] init];
    branchLabel.frame = CGRectMake(name_lb_x, branch_lb_y, Screen_Width - name_lb_x - 50, 17);
    branchLabel.font = AB_FONT_13;
    branchLabel.textColor = AB_Color_9c958a;
    [self.contentView addSubview:branchLabel];
    
    CGFloat accessory_x = Screen_Width - margin_to_left - 16;
    CGFloat accessory_y = (Cell_Height - 15) / 2.0;
    UIImageView *arrowView = [[UIImageView alloc] init];
    arrowView.frame = CGRectMake(accessory_x, accessory_y, 8, 15);
    arrowView.image = [UIImage imageNamed:@"icon_arrowR"];
    [self.contentView addSubview:arrowView];
    
    NSString *string = @"未开通";
    CGSize size = [string sizeWithFont:AB_FONT_13];
    
    CGFloat access_x = Screen_Width - margin_to_left - size.width;
    CGFloat access_y = (Cell_Height - size.height) / 2.0;
    UILabel *accessLabel = [[UILabel alloc] init];
    accessLabel.frame = CGRectMake(access_x, access_y, size.width, size.height);
    accessLabel.textColor = AB_Color_9c958a;
    accessLabel.text = string;
    accessLabel.font = AB_FONT_13;
    [self.contentView addSubview:accessLabel];
    
    self.iconView = iconView;
    self.nameLabel = nameLabel;
    self.branchLabel = branchLabel;
    self.accessLabel = accessLabel;
    self.arrowView = arrowView;
}

- (void)setContact:(AIABSearchContact *)contact
{
    UIImage *placeHolderImage = [UIImage imageNamed:@"defaultUser.png"];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", ResourcesURL, contact.avartar];
    NSURL *url = [NSURL URLWithString:urlString];
    [self.iconView setImageWithURL:url placeholderImage:placeHolderImage];
    
    self.nameLabel.text = contact.employeeName;
    self.branchLabel.text = contact.branch;
    
    self.arrowView.hidden = contact.userName ? NO : YES;
    self.canSelected = !self.arrowView.hidden;
    self.accessLabel.hidden = !self.arrowView.hidden;
}

+ (CGFloat)cellHeight
{
    return Cell_Height;
}

@end
