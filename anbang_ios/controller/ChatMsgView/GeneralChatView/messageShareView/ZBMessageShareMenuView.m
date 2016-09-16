//
//  ZBShareMenuView.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-13.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import "ZBMessageShareMenuView.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define RGBACOLOR(r,g,b,a)       [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
// 每行有4个
#define kZBMessageShareMenuPerRowItemCount 4
#define kZBMessageShareMenuPerColum 2

#define kZBShareMenuItemIconSize 54
#define KZBShareMenuItemHeight 80

@interface ZBMessageShareMenuItemView : UIView

@property (nonatomic, weak) UIButton *shareMenuItemButton;
@property (nonatomic, weak) UILabel *shareMenuItemTitleLabel;

@end

@implementation ZBMessageShareMenuItemView

- (void)setup {
    self.backgroundColor = UIColorFromRGB(0xefe8df);
    if (!_shareMenuItemButton) {
        UIButton *shareMenuItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareMenuItemButton.frame = CGRectMake(0, 0,kZBShareMenuItemIconSize, kZBShareMenuItemIconSize);
        shareMenuItemButton.backgroundColor = UIColorFromRGB(0xeae2d8);
        shareMenuItemButton.layer.cornerRadius = 4;
        shareMenuItemButton.layer.borderColor = [UIColorFromRGB(0xc3bdb4) CGColor];
        shareMenuItemButton.layer.borderWidth = 1;
        [self addSubview:shareMenuItemButton];
        
        self.shareMenuItemButton = shareMenuItemButton;
    }
    
    if (!_shareMenuItemTitleLabel) {
        UILabel *shareMenuItemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.shareMenuItemButton.frame), kZBShareMenuItemIconSize, KZBShareMenuItemHeight - kZBShareMenuItemIconSize)];
        shareMenuItemTitleLabel.backgroundColor = [UIColor clearColor];
        shareMenuItemTitleLabel.textColor = AB_Gray_Color;
        shareMenuItemTitleLabel.font = [UIFont boldSystemFontOfSize:12];
        shareMenuItemTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:shareMenuItemTitleLabel];
        
        
        self.shareMenuItemTitleLabel = shareMenuItemTitleLabel;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

@end

@interface ZBMessageShareMenuView ()<UIScrollViewDelegate>

/**
 *  这是背景滚动视图
 */
@property (nonatomic, weak) UIScrollView *shareMenuScrollView;
@property (nonatomic, weak) UIPageControl *shareMenuPageControl;

@end

@implementation ZBMessageShareMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)shareMenuItemButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelecteShareMenuItem:atIndex:)]) {
        NSInteger index = sender.tag;
        if (index < self.shareMenuItems.count) {
            [self.delegate didSelecteShareMenuItem:[self.shareMenuItems objectAtIndex:index] atIndex:index];
        }
    }
}

- (void)setup{
    self.backgroundColor = Controller_View_Color;
    
    if (!_shareMenuScrollView) {
        self.backgroundColor = UIColorFromRGB(0xefe8df);
        
         UIScrollView *shareMenuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kZBMessageShareMenuPageControlHeight)];
        shareMenuScrollView.delegate = self;
        shareMenuScrollView.canCancelContentTouches = NO;
        shareMenuScrollView.delaysContentTouches = YES;
        shareMenuScrollView.backgroundColor = UIColorFromRGB(0xefe8df);
        
        shareMenuScrollView.showsHorizontalScrollIndicator = NO;
        shareMenuScrollView.showsVerticalScrollIndicator = NO;
        [shareMenuScrollView setScrollsToTop:NO];
        shareMenuScrollView.pagingEnabled = YES;
        [self addSubview:shareMenuScrollView];
        
        self.shareMenuScrollView = shareMenuScrollView;
    }
    
    if (!_shareMenuPageControl) {
        UIPageControl *shareMenuPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.shareMenuScrollView.frame), CGRectGetWidth(self.bounds), kZBMessageShareMenuPageControlHeight)];
        shareMenuPageControl.backgroundColor = UIColorFromRGB(0xefe8df);
        shareMenuPageControl.hidesForSinglePage = YES;
        shareMenuPageControl.defersCurrentPageDisplay = YES;
        [self addSubview:shareMenuPageControl];
        
        self.shareMenuPageControl = shareMenuPageControl;
    }
    [self reloadData];
}

- (void)reloadData {
    if (!_shareMenuItems.count)
        return;
    
    [self.shareMenuScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat paddingX =(self.frame.size.width - 54*4)/5;
    CGFloat paddingY = 20;
    for (ZBMessageShareMenuItem *shareMenuItem in self.shareMenuItems) {
        NSInteger index = [self.shareMenuItems indexOfObject:shareMenuItem];
        NSInteger page = index / (kZBMessageShareMenuPerRowItemCount * 2);
        CGRect shareMenuItemViewFrame = CGRectMake((index % kZBMessageShareMenuPerRowItemCount) * (kZBShareMenuItemIconSize + paddingX) + paddingX + (page * CGRectGetWidth(self.bounds)), ((index / kZBMessageShareMenuPerRowItemCount) - kZBMessageShareMenuPerColum * page) * (KZBShareMenuItemHeight + paddingY) + paddingY, kZBShareMenuItemIconSize, KZBShareMenuItemHeight);
        ZBMessageShareMenuItemView *shareMenuItemView = [[ZBMessageShareMenuItemView alloc] initWithFrame:shareMenuItemViewFrame];
        
        shareMenuItemView.shareMenuItemButton.tag = index;
        [shareMenuItemView.shareMenuItemButton addTarget:self action:@selector(shareMenuItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [shareMenuItemView.shareMenuItemButton setImage:shareMenuItem.normalIconImage forState:UIControlStateNormal];
        shareMenuItemView.shareMenuItemTitleLabel.text = shareMenuItem.title;
        
        
        [self.shareMenuScrollView addSubview:shareMenuItemView];
    }
    
    self.shareMenuPageControl.numberOfPages = (self.shareMenuItems.count / (kZBMessageShareMenuPerRowItemCount * 2) + (self.shareMenuItems.count % (kZBMessageShareMenuPerRowItemCount * 2) ? 1 : 0));
    [self.shareMenuScrollView setContentSize:CGSizeMake(((self.shareMenuItems.count / (kZBMessageShareMenuPerRowItemCount * 2) + (self.shareMenuItems.count % (kZBMessageShareMenuPerRowItemCount * 2) ? 1 : 0)) * CGRectGetWidth(self.bounds)), CGRectGetHeight(self.shareMenuScrollView.bounds))];
    
//    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 0.5)];
//    line.backgroundColor = UIColorFromRGB(0xcac6c0);
//    [ self.shareMenuScrollView addSubview:line];
}

- (void)dealloc {
    self.shareMenuItems = nil;
    self.shareMenuScrollView.delegate = self;
    self.shareMenuScrollView = nil;
    self.shareMenuPageControl = nil;
}


#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    [self.shareMenuPageControl setCurrentPage:currentPage];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
