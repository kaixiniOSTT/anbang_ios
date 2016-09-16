//
//  GroupDetailCellCollection.m
//  anbang_ios
//
//  Created by yangsai on 15/3/29.
//  Copyright (c) 2015年 ch. All rights reserved.
//


#import "GroupDetailCellCollection.h"
#import "UIImageView+WebCache.h"
@interface GroupDetailCellCollection ()

@property UILabel* label;
@property (weak, nonatomic) UIImageView *abIcon;

@end

@implementation GroupDetailCellCollection

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"defaultUser.png"]];
        _imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.width);
        [_imageView.layer setMasksToBounds:YES];
        [_imageView.layer setCornerRadius:4.0];
        _imageView.hidden = NO;
        [self addSubview:_imageView];
        
        CGFloat frame_wh = frame.size.width;
        UIImageView *abIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_ab01"]];
        abIcon.frame = CGRectMake(frame_wh - 16, frame_wh - 11, 16, 11);
        [self addSubview:abIcon];
        self.abIcon = abIcon;
        
        _label = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.width + 6, frame.size.width, frame.size.height - frame.size.width - 6)];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:12.0];
        _label.textColor = UIColorFromRGB(0x9c958a);
         _label.hidden = NO;
        [self addSubview:_label];
        
        
        _deleImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chat_btn_delete"]];
        _deleImage.frame = CGRectMake(frame.size.width - 12, -3, 16, 16);
        _deleImage.hidden = YES;
        [self addSubview:_deleImage];

    }
    
    return self;
    
}
-(void)setAvatar:(NSString *)avatar{
    _avatar = [avatar copy];
    NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, _avatar];
    [_imageView  setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
}

- (void)setAccountType:(NSInteger)accountType {
    _accountType = accountType;
    self.abIcon.hidden = accountType == 2 ? NO : YES;
}

-(void)setNickName:(NSString *)nickName{
    _nickName = nickName;
    _label.text = nickName;
}

-(void)setAddDelect:(NSInteger)addDelect{
    _addDelect = addDelect;
    NSString* imageStr = @"";
    if (_addDelect == 0) {
        imageStr = @"chat_icon_plus";
    }else{
        imageStr = @"chat_btn_remove";
    }
    [_imageView setImage:[UIImage imageNamed:imageStr]];
    self.abIcon.hidden = YES;
}



@end
