//
//  BuddyCell.h
//  anbang_ios
//
//  Created by seeko on 14-3-18.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuddyCell : UITableViewCell

@property(retain,nonatomic)IBOutlet UIImageView *userHead;
@property(retain,nonatomic)IBOutlet UILabel *labName;
@property(retain,nonatomic)IBOutlet UILabel *labDescription;
@property(copy,nonatomic)NSString *name;
@property(copy,nonatomic)NSString *description;
@end
