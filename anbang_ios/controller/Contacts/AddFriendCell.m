//
//  AddFriendCell.m
//  anbang_ios
//
//  Created by yangsai on 15/3/28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AddFriendCell.h"
#import "MBProgressHUD.h"
#import "ChatInit.h"
@interface AddFriendCell ()
@property (strong, nonatomic) MBProgressHUD* progress;
@end


@implementation AddFriendCell
@synthesize addFriendBtn = _addFriendBtn;
- (IBAction)addBt:(id)sender {
    self.progress = [[MBProgressHUD alloc]init];
    _progress.labelText = @"正在添加好友...";
    _progress.dimBackground = YES;
    [_progress show:YES];
    [self.superview.superview.superview.superview.superview addSubview:_progress];
   
    [ChatInit queryContactsUserInfo:self.Contact.jid];
}

- (void)awakeFromNib {
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
