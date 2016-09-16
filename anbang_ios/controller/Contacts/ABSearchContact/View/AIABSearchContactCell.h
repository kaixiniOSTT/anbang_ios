//
//  AIABSearchContactCell.h
//  anbang_ios
//
//  Created by rooter on 15-5-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AIABSearchContact;

@interface AIABSearchContactCell : UITableViewCell

@property (strong, nonatomic) AIABSearchContact *contact;

@property (assign, nonatomic) BOOL canSelected;

+ (id)cellWithTableView:(UITableView *)tableView;
+ (CGFloat)cellHeight;

@end
