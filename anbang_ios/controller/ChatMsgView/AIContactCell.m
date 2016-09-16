//
//  AIContactCell.m
//  anbang_ios
//
//  Created by rooter on 15-4-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIContactCell.h"
#import "UIImageView+WebCache.h"
#import "AIHeaderIconView.h"

@interface AIContactCell()

@end

@implementation AIContactCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"retweet_selection_cell";
    AIContactCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[AIContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    //header view
    CGRect rect_01 = CGRectMake(15, 7, 46, 46);
    AIHeaderIconView *view = [[AIHeaderIconView alloc] initWithFrame:rect_01];
    [self.contentView addSubview:view];
    
    UIImageView *abIconView = [[UIImageView alloc] init];
    abIconView.frame = CGRectMake(30, 35, 16, 11);
    abIconView.image = [UIImage imageNamed:@"icon_ab01"];
    [view addSubview:abIconView];
    
    //nick name label
    CGFloat x = CGRectGetMaxX(view.frame) + 8;
    CGFloat y = view.frame.origin.y;
    CGFloat w = self.frame.size.width - 15 - 46 - 8;
    CGFloat h = view.frame.size.height;
    CGRect rect_02 = CGRectMake(x, y, w, h);
    UILabel *label = [[UILabel alloc] init];
    label.frame = rect_02;
    label.font = [UIFont systemFontOfSize:18];
    [self.contentView addSubview:label];
    
    self.headerView = view;
    self.nickNameLabel = label;
    self.abIcon = abIconView;
}

- (void)setContact:(NSDictionary *)contact
{
    if (contact[@"groupName"]) // group
    {
        NSString *groupType = contact[@"groupType"];
        NSString * groupName = contact[@"groupName"];
        NSArray *members = contact[@"groupMembersArray"];
        
        if ([StrUtility isBlankString:groupName])
        {
            NSMutableString *tmp = [NSMutableString string];
            
            for (int i = 0; i < members.count; ++i)
            {
                NSDictionary *member = members[i];
                [tmp appendString:member[@"nickName"]];
                if (i <= member.count - 1) {
                    [tmp appendString:@","];
                }
            }
            groupName = tmp;
        }
        
        NSMutableArray *iconsURLStrings = [NSMutableArray array];
        for (NSDictionary *member in members) {
            [iconsURLStrings addObject:member[@"avatar"]];
        }
        
        self.nickNameLabel.text = groupName;
        self.headerView.icon = iconsURLStrings;
        self.abIcon.hidden = [groupType isEqualToString:@"department"] ? NO : YES;
    }
    else // friend
    {
        self.abIcon.hidden = [contact[@"accountType"] integerValue] == 2 ? NO : YES;
        self.headerView.icon = contact[@"avatar"];
        NSString *name = contact[@"name"];
        if ([StrUtility isBlankString:name]) {
            self.nickNameLabel.text = contact[@"nickName"];
        }else {
            self.nickNameLabel.text = name;
        }
    }
}

+ (CGFloat)cellHeight
{
    return 60;
}

@end
