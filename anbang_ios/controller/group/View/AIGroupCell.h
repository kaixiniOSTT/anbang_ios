//
//  AIGroupCell.h
//  anbang_ios
//
//  Created by rooter on 15-5-22.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIGroupCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *group;

+ (AIGroupCell *)cellWithTableView:(UITableView *)tableView;
+ (CGFloat)cellHeight;

@end
