//
//  AIQLPreviewItem.m
//  anbang_ios
//
//  Created by Kim on 15/5/9.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIQLPreviewItem.h"
#import "ASIFormDataRequest.h"

@implementation AIQLPreviewItem {
    AIChatResourceCache *mCache;
}

- (id)initWithCache:(AIChatResourceCache *)aCache {
    if (self = [super init]) {
        mCache = aCache;
    }
    return self;
}

- (NSURL *)previewItemURL {
    return [self loadFile:ResourcesURL fileName:self.docKey fileType:self.docType];
}

-(NSURL*)loadFile:(NSString*)fileUrl fileName:(NSString*)fileNameStr fileType:(NSString*)fileType
{
    // fileUrl = [NSString stringWithFormat:@"%@/%@",fileUrl,fileNameStr ];
    
    // BOOL flag = [mCache isExistsDocumentForKey:fileNameStr ofType:fileType];
    // if (!flag) {
    //    NSURL *url = [NSURL URLWithString:fileUrl];
    //    NSData *data = [NSData dataWithContentsOfURL:url];
    //    [mCache storeDocument:data type:fileType forKey:fileNameStr];
    // }
    return [NSURL fileURLWithPath:[mCache pathWithKey:fileNameStr ofType:fileType]];
}

- (NSString *)previewItemTitle {
    return self.docName;
}

@end
