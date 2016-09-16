//
//  AIGroupCell.m
//  anbang_ios
//
//  Created by rooter on 15-5-22.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIGroupCell.h"
#import "AISodokuIconView.h"
#import "StrUtility.h"

@interface AIGroupCell ()
@property (strong, nonatomic) UIView *iconGround;
@property (strong, nonatomic) AISodokuIconView *iconView;
@property (strong, nonatomic) UIImageView *abIconView;
//@property (strong, nonatomic) UILabel *nameLabel;
@end

@implementation AIGroupCell

- (void)setupSubviews {
    
    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(8, 69.5, Screen_Width - 8, 0.5f)];
    viewLine.backgroundColor = AB_Color_e7e2dd;
    [self.contentView addSubview:viewLine];
    
    UIView *ground = [[UIView alloc] init];
    ground.frame = CGRectMake(8, 10, 50, 50);
    ground.layer.masksToBounds = YES;
    ground.layer.cornerRadius = 3.0;
    ground.backgroundColor = AB_Color_e7e2dd;
    
    AISodokuIconView *iconView = [[AISodokuIconView alloc] init];
    iconView.frame = CGRectMake(3, 3, 44, 44);
    
    UIImageView *abIconView = [[UIImageView alloc] init];
    abIconView.frame = CGRectMake(34, 39, 16, 11);
    abIconView.image = [UIImage imageNamed:@"icon_ab01"];
    
//    UILabel *label = [[UILabel alloc] init];
//    label.frame = CGRectMake(78, 0, Screen_Width - 78, [[self class] cellHeight]);
//    label.font = AB_FONT_16;
//    label.textColor = AB_Color_5b5752;
    
    [ground addSubview:iconView];
    [ground addSubview:abIconView];
    [self.contentView addSubview:ground];
//    [self.contentView addSubview:label];
    
    self.iconGround = ground;
    self.iconView = iconView;
    self.abIconView = abIconView;
    
    self.textLabel.textColor = AB_Color_5b5752;
//    self.nameLabel = label;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

+ (AIGroupCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"AI_My_Group_Cell";
    AIGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[AIGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = Table_View_Cell_Selection_Color;
        cell.contentView.backgroundColor = AB_Color_ffffff;
    }
    return cell;
}

- (void)setGroup:(NSDictionary *)group {
    if (![StrUtility isBlankString:group[@"groupName"]]) {
        self.textLabel.text = group[@"groupName"];
    }else {
        self.textLabel.text = group[@"groupTempName"];
    }
    self.iconView.members = group[@"groupMembersArray"];
    self.abIconView.hidden = [group[@"groupType"] isEqualToString:@"department"] ? NO : YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.textLabel.frame;
    frame.origin.x = CGRectGetMaxX(self.iconGround.frame) + 15;
    frame.size.width = Screen_Width - 78 - 8;
    self.textLabel.frame = frame;
}

+ (CGFloat)cellHeight {
    return 70.0;
}

@end
