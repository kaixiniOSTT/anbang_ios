//
//  AIBuddySearchCell.h
//  anbang_ios
//
//  Created by rooter on 15-5-23.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIBuddySearchCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *contact;

+ (AIBuddySearchCell *)cellWithTableView:(UITableView *)tableView;

@end
