//
//  AISodokuIconView.m
//  anbang_ios
//
//  Created by rooter on 15-5-22.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AISodokuIconView.h"
#import "UIImageView+WebCache.h"

#define Subview_Margin 1.0
#define Row_Piece_Count 3

@implementation AISodokuIconView

- (id)init {
    self = [super init];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    for (int i = 0; i < 9; ++i) {
        UIImageView *iconView = [[UIImageView alloc] init];
        [self addSubview:iconView];
    }
}

- (void)setMembers:(NSArray *)members
{
    for (int i = 0; i < (members.count <= 9 ? members.count : 9); ++i) {
        NSString *avatar = nil;
        if([members[i] isKindOfClass: [NSDictionary class]]){
            avatar = [members[i] objectForKey:@"avatar"];
        } else if([members[i] isKindOfClass: [NSString class]]){
            avatar = members[i];
        }
        NSURL *url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", ResourcesURL, avatar]];
        UIImageView *iconView = self.subviews[i];
        [iconView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
    }
    
    if (members.count < 9) {  //如果群成员不够九人，将多出来的iconView的image置为空
        int extra = 9 - members.count;
        for (int i = 0, j = 8; i < extra; ++i, --j) {
            UIImageView *iconView = self.subviews[j];
            iconView.image = nil;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat sub_wh = (self.frame.size.width - 2 * Subview_Margin) / Row_Piece_Count;
    UIImageView *iconView = nil;
    for (int i = 0; i < 9; ++i) {
        iconView = (UIImageView *)self.subviews[i];
        CGFloat icon_x = (sub_wh + Subview_Margin)*(i%Row_Piece_Count);
        CGFloat icon_y = (sub_wh + Subview_Margin)*((int)i/Row_Piece_Count);
        iconView.frame = CGRectMake(icon_x, icon_y, sub_wh, sub_wh);
    }
}

@end
