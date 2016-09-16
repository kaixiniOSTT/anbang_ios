//
//  AIHeaderIconView.m
//  anbang_ios
//
//  Created by rooter on 15-4-29.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIHeaderIconView.h"
#import "UIImageView+WebCache.h"

@interface AIHeaderIconView()
@property (nonatomic, strong) UIImageView *pieceIconView;
@property (nonatomic, strong) UIImageView *groupIconsView;
@end

@implementation AIHeaderIconView
{
    UIImage *placeHolderImage;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    //common init
    [self commonInit];
    
    //group
    [self createSodokuInView:self];
    
    //piece
    [self createPieceIconView:self];
}

- (void)commonInit
{
    self.backgroundColor = AB_Color_e7e2dd;
    self.layer.cornerRadius = 3.0;
    self.layer.masksToBounds = YES;
    placeHolderImage = [UIImage imageNamed:@"defaultUser.png"];
}

- (void)createSodokuInView:(UIView *)view
{
    int numInRow = 3;
    CGFloat margin = 1.0;
    CGRect bounds = view.bounds;
    CGFloat view_wh = bounds.size.width;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = bounds;
    self.groupIconsView = imageView;
    
//    CGFloat sub_wh = (view_wh - 2 * margin) / numInRow;
//    for (int i = 0; i < numInRow; ++i) {
//        for (int j = 0; j < numInRow; ++j)
//        {
//            CGRect sub_frame = CGRectMake((sub_wh + margin) * j, (sub_wh + margin) * i, sub_wh, sub_wh);
//            UIImageView *imageView = [[UIImageView alloc] initWithFrame:sub_frame];
//            imageView.image = placeHolderImage;
//            [self.groupIconsView addSubview:imageView];
//        }
//    }
    
    CGFloat sub_wh = (bounds.size.width - 2 * margin - 6) / numInRow;
    UIImageView *iconView = nil;
    for (int i = 0; i < 9; ++i) {
        iconView = [[UIImageView alloc] init];
        CGFloat icon_x = 3 + (sub_wh + margin)*(i%numInRow);
        CGFloat icon_y = 3 + (sub_wh + margin)*((int)i/numInRow);
        iconView.frame = CGRectMake(icon_x, icon_y, sub_wh, sub_wh);
        [self.groupIconsView addSubview:iconView];
    }
    [self addSubview:self.groupIconsView];
}

- (void)createPieceIconView:(UIView *)view
{
    CGRect bounds = view.bounds;
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = bounds;
    self.pieceIconView = imageView;
    
    [self addSubview:self.pieceIconView];
}

- (void)setIcon:(id)icon
{
    BOOL isArray = [icon isKindOfClass:[NSArray class]];
    if (isArray) {
        self.pieceIconView.hidden = YES;
        self.groupIconsView.hidden = NO;
        NSArray *icons = (NSArray *)icon;
        for (int i = 0; i < icons.count; ++i)
        {
            if (i == 9) break;
            
            UIImageView *iconView = self.groupIconsView.subviews[i];
            NSString *urlString =[NSString stringWithFormat:@"%@/%@", ResourcesURL, icon[i]];
            NSURL *url = [NSURL URLWithString:urlString];
            [iconView setImageWithURL:url placeholderImage:placeHolderImage];
        }
        
        if (icons.count < 9) {  
            int extra = 9 - icons.count;
            for (int i = 0, j = 8; i < extra; ++i, --j) {
                UIImageView *iconView = self.groupIconsView.subviews[j];
                iconView.image = nil;
            }
        }
        
    }else {
        self.groupIconsView.hidden = YES;
        self.pieceIconView.hidden = NO;
        NSString *iconID = (NSString *)icon;

        NSString *urlString =[NSString stringWithFormat:@"%@/%@", ResourcesURL, iconID];
        NSURL *url = [NSURL URLWithString:urlString];
        [self.pieceIconView setImageWithURL:url placeholderImage:placeHolderImage];
    }
}

@end
