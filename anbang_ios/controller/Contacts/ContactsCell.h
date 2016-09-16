//
//  contactsCell.h
//  anbang_ios
//
//  Created by yangsai on 15/5/15.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ContactsCell : UITableViewCell

@property (nonatomic, retain) UIImageView* pictureImage;
@property (nonatomic, retain) UILabel* lableName;
+ (CGFloat)cellHeight;
@end
