//
//  AIChatBuddyCell.m
//  anbang_ios
//
//  Created by rooter on 15-3-18.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIChatBuddyCell.h"
#import "UIImageView+WebCache.h"
#import "JSBadgeView.h"

#define Margin_To_Top_Bottom  12.5
#define Margin_To_Left 15.0

@interface AIChatBuddyCell()

@end

@implementation AIChatBuddyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupMe];
        [self setupSubviews];
    }
    return self;
}

+ (AIChatBuddyCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"AI_Chat_Buddy_Cell";
    AIChatBuddyCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[AIChatBuddyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.groupIconView.hidden = YES;
    cell.contentView.backgroundColor = AB_Color_ffffff;
    cell.imageView.image = [UIImage imageNamed:@"chat_group_back"];
    [cell.badgeView removeFromSuperview];
    return cell;
}

- (void)setupMe
{
    if (IS_iOS7) {
        self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    }
}

- (void)setupSubviews
{
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(KCurrWidth-110, 15, 100, 15);
    label.font = [UIFont systemFontOfSize:11];
    label.textColor = AB_Gray_Color;
    label.textAlignment = NSTextAlignmentRight;
    label.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:label];
    
    UIImageView *view = [[UIImageView alloc] init];
    view.backgroundColor = AB_Color_e7e2dd;
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 3.0;
    for (int i = 0; i < 9; ++i) {
        UIImageView *iconView = [[UIImageView alloc] init];
        [view addSubview:iconView];
    }
    [self.imageView addSubview:view];
    
    UIImageView *abIconView = [[UIImageView alloc] init];
    abIconView.frame = CGRectMake(29, 34, 16, 11);
    abIconView.image = [UIImage imageNamed:@"icon_ab01"];
    [self.imageView addSubview:abIconView];
    
    UIImageView* dndIconView = [[UIImageView alloc] init];
    dndIconView.frame =  CGRectMake(KCurrWidth - 24, 39, 14, 14);;
    dndIconView.image = [UIImage imageNamed:@"chat_button_nodis"];
    [self.contentView addSubview:dndIconView];
    
    UIImageView *dndPointView = [[UIImageView alloc] initWithFrame:CGRectMake(45 - 6, -6, 12, 12)];
    dndPointView.layer.cornerRadius = 6;
    dndPointView.layer.masksToBounds = YES;
    dndPointView.backgroundColor = AB_Color_fe0000;
    dndPointView.hidden = YES;
    [self.imageView addSubview:dndPointView];

    
    self.timeLabel = label;
    self.groupIconView = view;
    self.abIcon = abIconView;
    self.dndIcon = dndIconView;
    self.dndPointView = dndPointView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(Margin_To_Left, Margin_To_Top_Bottom, 45, 45);
    self.groupIconView.frame = self.imageView.bounds;
    
    NSString *detail = self.detailTextLabel.text;
    if (detail && ![detail isEqualToString:@""])
    {
        CGRect rect = self.textLabel.frame;
        rect.origin.x = CGRectGetMaxX(self.imageView.frame) + Margin_To_Left;
        rect.origin.y = Margin_To_Top_Bottom + 2;
        self.textLabel.frame = rect;
        
        rect = self.detailTextLabel.frame;
        rect.origin.x = self.textLabel.frame.origin.x;
        rect.origin.y += 2;
        self.detailTextLabel.frame = rect;
    }
    else
    {
        CGRect rect = self.textLabel.frame;
        rect.origin.x = CGRectGetMaxX(self.imageView.frame) + Margin_To_Left;
        self.textLabel.frame = rect;
    }

    CGFloat wh = self.groupIconView.frame.size.width;
    int numInRow = 3;
    CGFloat margin = 2.0;
    CGFloat sub_wh = (wh - margin * 2) / numInRow;
    
    UIImageView *iconView = nil;
    for (int i = 0; i < 9; ++i) {
        iconView = (UIImageView *)self.groupIconView.subviews[i];
        iconView.frame = CGRectMake((sub_wh + margin)*(i%numInRow), (sub_wh + margin)*((int)i/numInRow), sub_wh, sub_wh);
    }
}

- (void)setGroupMemebers:(NSArray *)groupMemebers {
    self.groupIconView.hidden = NO;
    [self sodokuHeaderIconWithMemebers:groupMemebers];
}

- (void)sodokuHeaderIconWithMemebers:(NSArray *)members {
    for (int i = 0; i < (members.count <= 9 ? members.count : 9); ++i) {
        NSString *avatar = nil;
        if([members[i] isKindOfClass: [NSDictionary class]]){
            avatar = [members[i] objectForKey:@"avatar"];
        } else if([members[i] isKindOfClass: [NSString class]]){
            avatar = members[i];
        }
        NSURL *url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", ResourcesURL, avatar]];
        UIImageView *iconView = self.groupIconView.subviews[i];
        [iconView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
    }
    
    if (members.count < 9) {  //如果群成员不够九人，将多出来的iconView的image置为空
        int extra = 9 - members.count;
        for (int i = 0, j = 8; i < extra; ++i, --j) {
            UIImageView *iconView = self.groupIconView.subviews[j];
            iconView.image = nil;
        }
    }
}

@end
