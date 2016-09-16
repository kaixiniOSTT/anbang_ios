//
//  AIPreviewController.h
//  anbang_ios
//
//  Created by rooter on 15-7-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIQLPreviewItem.h"

@interface AIPreviewController : UIViewController

@property (nonatomic, strong) NSString *docKey;
@property (nonatomic, strong) NSString *docName;
@property (nonatomic, strong) NSString *docType;
@property (nonatomic, retain) NSArray *documents;

- (id)initWithCache:(AIChatResourceCache *)aCache;

@end
