//
//  AIShareView.m
//  anbang_ios
//
//  Created by rooter on 15-8-4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIShareView.h"
#import "AIShareButton.h"

#define kMarginLeft (Screen_Width - 4*45)/10

@implementation AIShareView
{
    NSArray *_images;
    NSArray *_titles;
    
    UIView *_view;
}

- (void)dealloc
{
    JLLog_I(@"<Class=%@, object=%p> dealloc", [self class], self);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (id)shareViewWithImages:(NSArray *)images titles:(NSArray *)titles
{
    AIShareView *shareView = [[AIShareView alloc] initWithImages:images
                                                          titles:titles];
    return shareView;
}

- (id)initWithImages:(NSArray *)images titles:(NSArray *)titles
{
    CGFloat height = 270.0f;
    CGRect rect = CGRectMake(0, Screen_Height, Screen_Width, height);
    self = [super initWithFrame:rect];
    
    if (self) {
        
        _images = images;
        _titles = titles;
        
        self.backgroundColor = AB_Color_ffffff;
        
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    UILabel *titleLabel = [[UILabel alloc]
                           initWithFrame:CGRectMake(0, 20, Screen_Width, 15)];
    titleLabel.text = @"分享到";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = AB_Color_9c958a;
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(23,
                                                               CGRectGetMaxY(titleLabel.frame) + 20,
                                                               Screen_Width - 23*2,
                                                               1)];
    topLine.backgroundColor = Color(@"#e7e2dd");
    
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(23,
                                                                  topLine.frame.origin.y + 159,
                                                                  Screen_Width - 23*2,
                                                                  1)];
    bottomLine.backgroundColor = Color(@"#e7e2dd");
    
    
    // Add share buttons
    
    CGFloat buttonWidth = 45 + 2*kMarginLeft;
    for (NSInteger i=0; i<_images.count; i++) {
        CGFloat top = 0.0f;
        if (i<4) {
            top = 10;
            
        }else{
            top = 85;
        }
        
        AIShareButton *button = [AIShareButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(kMarginLeft+(i%4)*buttonWidth,
                                  topLine.frame.origin.y + topLine.frame.size.height+top,
                                  buttonWidth,
                                  buttonWidth);
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setImage:[UIImage imageNamed:_images[i]] forState:UIControlStateNormal];
        [button setTitle:_titles[i] forState:UIControlStateNormal];
        [button setTitleColor:Color(@"2a2a2a") forState:UIControlStateNormal];
        
        button.tag = 331+i;
        [button addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBtn.frame = CGRectMake(0, bottomLine.frame.origin.y + 20, Screen_Width, 15);
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:AB_Color_9c958a forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = AB_FONT_15;
    cancleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    cancleBtn.tag = 339;
    [cancleBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:topLine];
    [self addSubview:titleLabel];
    [self addSubview:bottomLine];
    [self addSubview:cancleBtn];
}

- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    _view = [[UIView alloc] initWithFrame:keyWindow.bounds];
    [_view addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                 initWithTarget:self
                                 action:@selector(hide)]];
    [keyWindow addSubview:_view];
    [keyWindow addSubview:self];
    
    CGRect rect = self.frame;
    rect.origin.y = Screen_Height - rect.size.height;
    [UIView animateWithDuration:0.35f animations:^{
        self.frame = rect;
    }];
}

- (void)hide
{
    CGRect rect = self.frame;
    rect.origin.y = Screen_Height + rect.size.height;
    [UIView animateWithDuration:0.35f animations:^{
        self.frame = rect;
    } completion:^(BOOL finished) {
        [_view removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)shareBtnClick:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareView:didClickedButtonAtIndex:)]) {
        [self.delegate shareView:self didClickedButtonAtIndex:sender.tag];
    }
}

@end
