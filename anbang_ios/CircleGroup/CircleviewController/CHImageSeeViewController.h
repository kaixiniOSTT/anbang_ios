//
//  CHImageSeeViewController.h
//  anbang_ios
//
//  Created by MyLove on 15/7/22.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "BTNomalBaseViewController.h"

@interface CHImageSeeViewController : BTNomalBaseViewController<UIScrollViewDelegate>

@property (nonatomic, retain) NSArray * imageDataArray;
@property (nonatomic, retain) NSString * curString;

@end
