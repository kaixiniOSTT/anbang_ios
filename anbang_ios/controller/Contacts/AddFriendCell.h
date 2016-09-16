//
//  AddFriendCell.h
//  anbang_ios
//
//  Created by yangsai on 15/3/28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contacts.h"


@interface AddFriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *friendName;
@property (weak, nonatomic) IBOutlet UIImageView *friendImage;
@property (weak, nonatomic) IBOutlet UIImageView *adImage;
@property (weak,nonatomic)  IBOutlet UIButton *addFriendBtn;
@property (strong, nonatomic)Contacts* Contact;
@end
