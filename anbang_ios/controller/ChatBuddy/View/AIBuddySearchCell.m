//
//  AIBuddySearchCell.m
//  anbang_ios
//
//  Created by rooter on 15-5-23.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBuddySearchCell.h"
#import "AISodokuIconView.h"
#import "StrUtility.h"
#import "UIImageView+WebCache.h"

@interface AIBuddySearchCell ()
@property (weak, nonatomic) UIView *groupIconBackground;
@property (weak, nonatomic) AISodokuIconView *iconView;
@property (weak, nonatomic) UIImageView *abIcon;
@end

@implementation AIBuddySearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupMe];
        [self setupSubviews];
    }
    return self;
}

+ (AIBuddySearchCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"AI_Chat_Buddy_Search_Cell";
    AIBuddySearchCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[AIBuddySearchCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.groupIconBackground.hidden = YES;
    cell.abIcon.hidden = YES;
    return cell;
}

- (void)setupMe {
    self.contentView.backgroundColor = AB_Color_ffffff;
    self.separatorInset = UIEdgeInsetsMake(0, 8, 0, 0);
}

- (void)setupSubviews {
    
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 3.0;
    
    self.textLabel.font = AB_FONT_16;
    self.textLabel.textColor = AB_Color_5b5752;
    
    UIView *ground = [[UIView alloc] init];
    ground.frame = CGRectMake(8, 9, 50, 50);
    ground.layer.masksToBounds = YES;
    ground.layer.cornerRadius = 3.0;
    ground.backgroundColor = AB_Color_e7e2dd;
    
    AISodokuIconView *iconView = [[AISodokuIconView alloc] init];
    iconView.frame = CGRectMake(3, 3, 44, 44);
    
    UIImageView *abIconView = [[UIImageView alloc] init];
    abIconView.frame = CGRectMake(42, 48, 16, 11);
    abIconView.image = [UIImage imageNamed:@"icon_ab01"];
    
    [ground addSubview:iconView];
    [self.contentView addSubview:ground];
    [self.contentView addSubview:abIconView];
    
    self.groupIconBackground = ground;
    self.iconView = iconView;
    self.abIcon = abIconView;
}

- (void)setContact:(NSDictionary *)contact {
    
    NSString *type = contact[@"type"];
    NSString *name = contact[@"name"];
    NSString *nickName = contact[@"nickName"];
    
    if ([type isEqualToString:@"system_ab_workbench"]) {
        self.imageView.image = [UIImage imageNamed:@"icon_abWorkTable"];
        self.textLabel.text = name;
    }else if ([type isEqualToString:@"groupchat"]) {
        self.groupIconBackground.hidden = NO;
        self.abIcon.hidden = [@"department" isEqualToString:contact[@"groupType"]] ? NO : YES;
        NSString *groupTempName = contact[@"groupTempName"];
        self.iconView.members = contact[@"groupMembersArray"];
        self.textLabel.text = [StrUtility string:name defaultValue:nickName];
        self.textLabel.text = [StrUtility string:self.textLabel.text defaultValue:groupTempName];
    }else {
        self.groupIconBackground.hidden = YES;
        self.abIcon.hidden = [contact[@"accountType"] intValue] == 2 ? NO : YES;
        self.textLabel.text = ![name isEqualToString:nickName] ? [NSString stringWithFormat:@"%@(%@)", name, nickName] : nickName;
        NSString *avatar = contact[@"avatar"];
        NSURL *url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", ResourcesURL, avatar]];
        [self.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(8, 9, 50, 50);
    self.textLabel.frame = CGRectMake(78, 0, Screen_Width - 100, self.frame.size.height);
}

@end
