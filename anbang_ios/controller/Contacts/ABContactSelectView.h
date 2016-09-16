//
//  ABContactSelectView.h
//  anbang_ios
//
//  Created by yangsai on 15/3/26.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>


#define imgW 10
#define imgH 10
#define tableH 150
#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)
#define kBorderColor [UIColor colorWithRed:219/255.0 green:217/255.0 blue:216/255.0 alpha:1]
#define kTextColor   [UIColor darkGrayColor]

@class  ABContactSelectView;

@protocol ABContactSelectDelegate <NSObject>

-(void)selectAtIndex:(int)index inCombox:(ABContactSelectView *) combox;

@end
@interface ABContactSelectView : UIView<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,assign)BOOL isOpen;
@property(nonatomic,strong)UITableView *listTable;
@property(nonatomic,strong)NSMutableArray *titlesList;
@property(nonatomic,assign)int defaultIndex;
@property(nonatomic,assign)float tableHeight;
@property(nonatomic,strong)UIImageView *arrow;
@property(nonatomic,copy)NSString *arrowImgName;//箭头图标名称
@property(nonatomic,assign)id<ABContactSelectDelegate>delegate;
@property(nonatomic,strong)UIView *supView;
@property(nonatomic,strong)UILabel *titleLabel;

-(void)defaultSettings;
-(void)reloadData;
-(void)closeOtherCombox;
-(void)tapAction;

@end
