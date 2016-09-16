//
//  AICollectionCell.h
//  anbang_ios
//
//  Created by rooter on 15-5-4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "SWTableViewCell.h"

@class AIItemModel;

@interface AICollectionCell : SWTableViewCell

@property (nonatomic, strong) AIItemModel *item;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
