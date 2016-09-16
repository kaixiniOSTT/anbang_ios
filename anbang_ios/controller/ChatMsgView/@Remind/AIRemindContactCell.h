//
//  AIRemindContactCell.h
//  anbang_ios
//
//  Created by rooter on 15-7-8.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIRemindContactCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *contact;

+ (AIRemindContactCell *)cellWithTableView:(UITableView *)tableView;

+ (CGFloat)cellHeight;

@end
