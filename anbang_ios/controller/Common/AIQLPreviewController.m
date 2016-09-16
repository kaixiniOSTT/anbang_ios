//
//  AIUIDocumentInteractionController.m
//  anbang_ios
//
//  Created by Kim on 15/5/9.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIQLPreviewController.h"
#import <QuickLook/QuickLook.h>
#import "ASIHTTPRequest.h"

@interface AIQLPreviewController ()

@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation AIQLPreviewController
{
    NSArray *mDocuments;
    AIChatResourceCache *mCache;
}

- (id)initWithCache:(AIChatResourceCache *)aCache {
    self = [super init];
    if (self) {
        mCache = aCache;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDocuments = @[];
    
    if(self.documents){
        mDocuments = self.documents;
    } else {
        JLLog_I(@"<key=%@, type=%@>", self.docKey, self.docType);
        BOOL flag = [mCache isExistsDocumentForKey:self.docKey ofType:self.docType];
        if (!flag) {
//            [self download];
        }else {
            self.dataSource = self;
            AIQLPreviewItem *item = [[AIQLPreviewItem alloc] initWithCache:mCache];
            item.docName = self.docName;
            item.docKey = self.docKey;
            item.docType = self.docType;
            mDocuments = @[item];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    for (UIView *subview in self.view.subviews) {
        [subview removeFromSuperview];
    }
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self progressView];
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.frame = CGRectMake(15, 150, Screen_Width - 30, 2.0);
        [self.view addSubview:_progressView];
    }
    return _progressView;
}

- (void) download {
    // Create request object
    NSString *url_string = [NSString stringWithFormat:@"%@/%@", ResourcesURL, self.docKey];
    NSURL *url = [NSURL URLWithString:url_string];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    // Set file cache path
    NSString *path = [mCache pathWithKey:self.docKey ofType:self.docType];
    request.downloadDestinationPath = path;
    
    // Set progress delegate
    request.downloadProgressDelegate = self.progressView;
    
    // Start request
    [request startAsynchronous];
}


- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return mDocuments.count;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    return mDocuments[idx];
}

@end
