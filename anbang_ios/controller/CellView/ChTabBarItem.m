//
//  ChTabBarItem.m


#import "ChTabBarItem.h"

@implementation ChTabBarItem

#pragma mark 根据标题、普通图片、高亮图片初始化按钮所用信息的类方法
+(id)tabBarItemWithTitle:(NSString*)title normalImage:(NSString*)normalImage highlightedImage:(NSString*)highlightedImage{
    ChTabBarItem *item = [[ChTabBarItem alloc] init];
    item.title = title;
    item.normalImage = normalImage;
    item.highlightedImage = highlightedImage;
    return item;
}

-(void)dealloc{
}
@end
