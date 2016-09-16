//
//  AIChatBuddyCell.h
//  anbang_ios
//
//  Created by rooter on 15-3-18.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSBadgeView;

@interface AIChatBuddyCell : UITableViewCell

@property (weak, nonatomic) UILabel *timeLabel;
@property (weak, nonatomic) UIImageView *abIcon;
@property (weak, nonatomic) UIImageView *dndIcon;
@property (weak, nonatomic) UIImageView *groupIconView;
@property (weak, nonatomic) JSBadgeView *badgeView;
@property (weak, nonatomic) UIImageView *dndPointView;
@property (weak, nonatomic) NSArray *groupMemebers;

+ (AIChatBuddyCell *)cellWithTableView:(UITableView *)tableView;

@end
