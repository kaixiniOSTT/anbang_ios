//
//  AIUIDocumentInteractionController.h
//  anbang_ios
//
//  Created by Kim on 15/5/9.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "AIQLPreviewItem.h"

@interface AIQLPreviewController : QLPreviewController<QLPreviewControllerDataSource>
@property (nonatomic, strong) NSString *docKey;
@property (nonatomic, strong) NSString *docName;
@property (nonatomic, strong) NSString *docType;
@property (nonatomic, retain) NSArray *documents;

- (id)initWithCache:(AIChatResourceCache *)aCache;

@end
