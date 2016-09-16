//
//  AINewFriendCell.h
//  anbang_ios
//
//  Created by rooter on 15-6-16.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AINewFriendRequestItem;
@class AINewFriendCell;

@protocol AINewFriendCellDelegate <NSObject>

- (void)accessoryButtonBeenTappedInCell:(AINewFriendCell *)newFriendCell;
- (void)iconViewBeenTappedInCell:(AINewFriendCell *)newFriendCell;

@end

@interface AINewFriendCell : UITableViewCell

@property (strong, nonatomic) AINewFriendRequestItem *item;
@property (strong, nonatomic) id<AINewFriendCellDelegate> delegate;

+ (AINewFriendCell *)cellForTableView:(UITableView *)tableView;

+ (CGFloat)cellHeight;

@end
