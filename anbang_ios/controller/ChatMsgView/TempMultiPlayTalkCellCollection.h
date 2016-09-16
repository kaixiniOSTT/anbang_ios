//
//  TempMultiPlayTalkCellCollection.h
//  anbang_ios
//
//  Created by yangsai on 15/3/31.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TempMultiPlayTalkCellCollection : UICollectionViewCell
@property (copy, nonatomic) NSString *nickName;
@property (copy, nonatomic) NSString *avatar;
@property (assign, nonatomic) NSInteger addDelect;
@property (retain, nonatomic) UIImageView* deleImage;
@property (copy, nonatomic) NSString* groupJid;
@property (copy, nonatomic) NSString* MemJid;
@property (assign, nonatomic) NSInteger accountType;
@property UIImageView* imageView;
@end
