//
//  AIItemModel.h
//  anbang_ios
//
//  Created by rooter on 15-4-30.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIExtraInfo.h"
#import "AICollection.h"
#import "Utility.h"

#define Margin_To_Left_Right 15.0
#define Margin_To_Top_Bottom  10.0
#define Document_Iocn_View_WH 50.0
#define Link_Icon_View_WH 40.0
#define Margin_To_Cell_Right 12.0
#define Margin_Between 6.0
#define Icon_View_WH 30.0
#define Content_Image_View_Max_Height 80.0

#define AICollectionNickFont [UIFont systemFontOfSize:15.0]
#define AICollectionContentFont [UIFont systemFontOfSize:12.0]
#define AICollectionTimeFont [UIFont systemFontOfSize:11.0]

@interface AIItemModel : NSObject

@property (nonatomic, strong) AICollection *collection;
@property (nonatomic, strong) AIExtraInfo *extraInfo;

// 通用的显示头像/昵称/时间的控件的Frame
@property (nonatomic, assign) CGRect iconViewF;
@property (nonatomic, assign) CGRect nickLabelF;
@property (nonatomic, assign) CGRect timeLabelF;

// 文本类型收藏的用于显示的Label的Frame
@property (nonatomic, assign) CGRect contentLabelF;

// 图片类型收藏用于显示的图片的Frame
@property (nonatomic, assign) CGRect contentImageViewF;

// 文档类型收藏的用于显示的view的Frame
// 方便管理，将image和Label方在一个View上
// 因为document类型的收藏frame是固定的
@property (nonatomic, assign) CGRect documentIconF;
@property (nonatomic, assign) CGRect documentLabelF;

// 连接类型收藏，类似文档类型，frame也是固定的
@property (nonatomic, assign) CGRect linkIconF;
@property (nonatomic, assign) CGRect linkLabelF;
@property (nonatomic, assign) CGRect LinkBackViewF;

// 每个收藏对应的cell的高度 根据以上Frame所算得
@property (nonatomic, assign) CGFloat cellHeight;

@end
