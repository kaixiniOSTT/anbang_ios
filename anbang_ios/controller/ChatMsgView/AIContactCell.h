//
//  AIContactCell.h
//  anbang_ios
//
//  Created by rooter on 15-4-28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AIHeaderIconView;

@interface AIContactCell : UITableViewCell

@property (nonatomic, weak) AIHeaderIconView *headerView;
@property (nonatomic, weak) UILabel *nickNameLabel;
@property (nonatomic, weak) UIImageView *abIcon;

@property (nonatomic, strong) NSDictionary *contact;

+ (CGFloat)cellHeight;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
