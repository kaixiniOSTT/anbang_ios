//
//  BBTableViewCell.h
//  anbang_ios
//
//  Created by YAO on 15/7/19.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JSBadgeView;
@interface BBTableViewCell : UITableViewCell
@property (weak, nonatomic) UILabel *timeLabel;
@property (weak, nonatomic) UIImageView *abIcon;
@property (weak, nonatomic) UIImageView *dndIcon;
@property (weak, nonatomic) UIImageView *groupIconView;
@property (weak, nonatomic) JSBadgeView *badgeView;
@property (weak, nonatomic) NSArray *groupMemebers;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
