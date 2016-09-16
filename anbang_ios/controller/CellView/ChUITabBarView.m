//
//  ChUITabBarView.m


#import "ChUITabBarView.h"
#import "ChTabBarItem.h"
#import "ChUITabBarItemButton.h"

@implementation ChUITabBarView


- (id)initWithFrame:(CGRect)frame tabBarItems:(NSArray *)tabBarItems
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbar_background.png"]];
        [self initTabBarButtonsByItems:tabBarItems];
    }
    return self;
}

#pragma mark 根据传入的tabBarItems初始化按钮到底部tabBarView
-(void)initTabBarButtonsByItems:(NSArray *)tabBarItems{
    NSInteger itemsCount = tabBarItems.count;
    
    //按钮的长和宽
    NSInteger btnWidth = self.frame.size.width / itemsCount;
    NSInteger btnHeight =self.frame.size.height;
    
    //初始化选中按钮的背景图片：使用一张，动态改变其位置，默认隐藏
    [self initSelectedBgImageWithBtnWidth:btnWidth btnHeight:btnHeight];
    
    for (int i=0; i<itemsCount; i++) {
        ChTabBarItem *item = tabBarItems[i];
        CGRect rect = CGRectMake(btnWidth * i, 0, btnWidth, btnHeight);
        
        ChUITabBarItemButton *tabBarBtn = [[ChUITabBarItemButton alloc]initWithFrame:rect item:item];   
        tabBarBtn.tag = 100 + i;//tag值传递按钮索引，对100取模获取索引值
        
        [tabBarBtn addTarget:self action:@selector(tabBarBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:tabBarBtn];
    }
}

#pragma mark 按钮点击:选中该按钮时高亮，取消上一次的高亮
-(void)tabBarBtnClick:(ChUITabBarItemButton *) clickBtn{
    //获取索引
    NSInteger newIndex = clickBtn.tag % 100;
    NSInteger oldIndex = self.selectedBtn.tag % 100;
    
    if (self.selectedBtn == clickBtn) {
        return;
    }
    //前一个按钮设置
    self.selectedBtn.userInteractionEnabled = YES;
    self.selectedBtn.selected = NO;
    
    //当前点击的按钮设置
    self.selectedBtn = clickBtn;
    self.selectedBtn.userInteractionEnabled = NO;
    self.selectedBtn.selected = YES;
    
    //点击按钮时，设置背景图片显示
    [UIView beginAnimations:nil context:nil];
    
    self.selectedBtnBgImageView.hidden = NO;
    CGRect rect = self.selectedBtnBgImageView.frame;
    rect.origin.x = self.selectedBtn.frame.origin.x;
    self.selectedBtnBgImageView.frame = rect;
    
    [UIView commitAnimations];
    
    //代理方法的调用：切换控制器，传入旧索引和新索引
    if ([self.delegate respondsToSelector:@selector(chUITabBarViewItemSelectedChangeWithNewItemIndex:oldSelectedIndex:)]) {
        [self.delegate chUITabBarViewItemSelectedChangeWithNewItemIndex:newIndex oldSelectedIndex:oldIndex];
    }
}

#pragma mark - ChUITabBarViewDelegate implement
#pragma mark 根据按钮的宽高设置初始化其背景图片
-(void)initSelectedBgImageWithBtnWidth:(NSInteger)btnWidth btnHeight:(NSInteger)btnHeight{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar_slider.png"]];
    imageView.frame = CGRectMake(0, 0, btnWidth, btnHeight);
    imageView.hidden = YES;
    self.selectedBtnBgImageView = imageView;
    [self addSubview:imageView];
}

#pragma mark 根据index选中tabbar上对应的按钮
-(void)selectBtnAtIndex:(NSInteger) index{
    NSInteger tag = 100 + index;//tab与index的规则
    ChUITabBarItemButton *btn = (ChUITabBarItemButton *)[self viewWithTag:tag];
    if (btn) {
        [self tabBarBtnClick:btn];
    }
}

-(BOOL)isSetHidesBottomBarWhenPushed{
    
}

@end
