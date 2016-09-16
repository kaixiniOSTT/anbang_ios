//
//  AIFriendContactCell.h
//  anbang_ios
//
//  Created by rooter on 15-6-2.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contacts.h"

@interface AIFriendContactCell : UITableViewCell

@property (nonatomic, strong) Contacts *contact;

+ (AIFriendContactCell *)cellWithTableView:(UITableView *)tableView;

@end
