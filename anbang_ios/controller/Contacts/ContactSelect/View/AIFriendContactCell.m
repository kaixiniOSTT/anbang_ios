//
//  AIFriendContactCell.m
//  anbang_ios
//
//  Created by rooter on 15-6-2.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIFriendContactCell.h"
#import "UIImageView+WebCache.h"

#define ImageView_WH 40

@interface AIFriendContactCell ()
@property (weak, nonatomic) UIImageView *abIcon;
@end

@implementation AIFriendContactCell

- (void)setupSubviews
{
    UIImageView *abIcon = [[UIImageView alloc] init];
    abIcon.frame = CGRectMake(ImageView_WH - 16, ImageView_WH - 11, 16, 11);
    abIcon.image = [UIImage imageNamed:@"icon_ab01"];
    [self.imageView addSubview:abIcon];
    self.abIcon = abIcon;
    
    self.imageView.layer.cornerRadius = 2.0;
    self.imageView.layer.masksToBounds = YES;
    self.textLabel.textColor = [UIColor colorFromHexString:@"#5b5752"];
    self.textLabel.font = [UIFont systemFontOfSize:15];
    
  
  
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return  self;
}

+ (AIFriendContactCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"friends_contact_cell";
    AIFriendContactCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[AIFriendContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (void)setContact:(Contacts *)contact
{
    NSString *urlString =[NSString stringWithFormat:@"%@/%@", ResourcesURL, contact.avatar];
    NSURL *url = [NSURL URLWithString:urlString];
    [self.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
    self.textLabel.text = [StrUtility isBlankString:contact.remarkName] ? contact.nickName : contact.remarkName;
    self.abIcon.hidden = contact.accountType == 2 ? NO : YES;
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(15, 5, ImageView_WH, ImageView_WH);
    CGRect textFrame = self.textLabel.frame;
    textFrame.origin.x = CGRectGetMaxX(self.imageView.frame) + 12;
    self.textLabel.frame = textFrame;
    
}

@end
