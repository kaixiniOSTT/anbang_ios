//
//  ChTabBarItem.h


#import <UIKit/UIKit.h>

@interface ChTabBarItem : NSObject

@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* normalImage;
@property(nonatomic,copy) NSString* highlightedImage;
+(id)tabBarItemWithTitle:(NSString*)title normalImage:(NSString*)normalImage highlightedImage:(NSString*)highlightedImage;

@end
