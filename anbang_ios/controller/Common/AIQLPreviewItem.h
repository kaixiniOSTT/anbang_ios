//
//  AIQLPreviewItem.h
//  anbang_ios
//
//  Created by Kim on 15/5/9.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>
#import "AIChatResourceCache.h"

@interface AIQLPreviewItem : NSObject<QLPreviewItem>
@property (nonatomic, strong) NSString *docKey;
@property (nonatomic, strong) NSString *docName;
@property (nonatomic, strong) NSString *docType;

- (id)initWithCache:(AIChatResourceCache *)aCache;

@end
