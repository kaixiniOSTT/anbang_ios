//
//  ChUITabBarView.h


#import <UIKit/UIKit.h>

/*当tabBar上的的按钮点击改变时 */
// 1：protocol 
@protocol ChUITabBarViewDelegate <NSObject>

-(void)chUITabBarViewItemSelectedChangeWithNewItemIndex:(NSInteger)index oldSelectedIndex:(NSInteger)old;

@end

// 2：interface ChUITabBarView

@class ChUITabBarItemButton;

@interface ChUITabBarView : UIView

@property(nonatomic,assign)NSArray *tabBarItems;//tabBar的按钮信息集合
@property(nonatomic,assign)ChUITabBarItemButton *selectedBtn;//选中的btn
@property(nonatomic,assign)UIImageView *selectedBtnBgImageView;//选中的btn的背景图片view
@property(nonatomic,assign) id<ChUITabBarViewDelegate> delegate;//代理

- (id)initWithFrame:(CGRect)frame tabBarItems:(NSArray *)tabBarItems;
-(void)selectBtnAtIndex:(NSInteger) index;

@end
