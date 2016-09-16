//
//  KKMessageCell.h
//  anbang_ios
//
//  Created by silenceSky  on 14-3-25.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKMessageCell : UITableViewCell

@property(nonatomic, retain) UILabel *senderAndTimeLabel;
@property(nonatomic, retain) UITextView *messageContentView;
@property(nonatomic, retain) UIImageView *bgImageView;

@end
