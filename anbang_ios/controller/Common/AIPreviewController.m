//
//  AIPreviewController.m
//  anbang_ios
//
//  Created by rooter on 15-7-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIPreviewController.h"
#import <QuickLook/QuickLook.h>
#import "ASIHTTPRequest.h"
#import "AIDocumentDownloadManager.h"

@interface AIPreviewController () <QLPreviewControllerDataSource>

@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UILabel *label;
@property (weak, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) QLPreviewController *previewController;
@property (strong, nonatomic) ASIHTTPRequest *request;

@end

@implementation AIPreviewController {
    NSArray *_documents;
    AIChatResourceCache *_cache;
    BOOL _straightDownload;
    NSString *_downloadKey;
}

- (void)dealloc {
    JLLog_I(@"<%@, %p> dealloc", [self class], self);
    //
    self.request.downloadProgressDelegate = nil;
}

- (id)initWithCache:(AIChatResourceCache *)aCache {
    self = [super init];
    if (self) {
        _cache = aCache;
    }
    return self;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        CGFloat y = CGRectGetMaxY(self.label.frame) + 40;
        CGFloat w = Screen_Width - 30;
        UIProgressView *progressView = [[UIProgressView alloc] init];
        progressView.frame = CGRectMake(15, y, w, 2.0);
        _progressView = progressView;
        [self.view addSubview:_progressView];
        _progressView = progressView;
    }
    return _progressView;
}

- (UIButton *)button {
    if (!_button) {
        CGFloat y = CGRectGetMaxY(self.label.frame) + 40;
        CGFloat w = Screen_Width - 30;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(15, y, w, 45);
        button.backgroundColor = AB_Color_e55a39;
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 3.0;
        [button setTitle:@"下载并查看" forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(toDownload:)
         forControlEvents:UIControlEventTouchUpInside];
        _button = button;
        [self.view addSubview:button];
    }
    return _button;
}

- (void) toDownload:(UIButton *)sender {
    [sender removeFromSuperview];
    [self progressView];
    [self download];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = AB_Color_ffffff;
    self.title = self.docName;
    _downloadKey = [NSString stringWithFormat:@"%@_%@", self.docKey, _cache.userName];
    
    if(self.documents) {
        _documents = self.documents;
    }
    else {
        BOOL flag = [_cache isExistsDocumentForKey:self.docKey ofType:self.docType];
        if (!flag) {
            [self setupDownloadUI];
        }else {
            [self preview];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_straightDownload) {
        [self download];
    }
}

- (void) setupDownloadUI {
    CGFloat whImageView = 120;
    NSString *icon_name = nil;
    if ([self.docType isEqualToString:@"pdf"]) {
        icon_name = @"icon_pdf";
    }else if ([self.docType isEqualToString:@"ppt"] || [self.docType isEqualToString:@"pptx"]) {
        icon_name = @"icon_ppt";
    }else if ([self.docType isEqualToString:@"doc"] || [self.docType isEqualToString:@"docx"]) {
        icon_name = @"icon_word";
    }else if ([self.docType isEqualToString:@"xls"] || [self.docType isEqualToString:@"xlsx"]) {
        icon_name = @"icon_excel";
    }
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.bounds = (CGRect){CGPointZero, CGSizeMake(whImageView, whImageView)};
    imageView.center = CGPointMake(Screen_Width / 2, whImageView / 2 + 40);
    imageView.image = [UIImage imageNamed:icon_name];
    [self.view addSubview:imageView];
    
    CGSize boundingSize = CGSizeMake(Screen_Width - 120, 50);
    CGRect rect = [self.docName boundingRectWithSize:boundingSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName : AB_FONT_17}
                                             context:nil];
    UILabel *label = [[UILabel alloc] init];
    label.bounds = (CGRect){CGPointZero, rect.size};
    label.font = AB_FONT_17;
    label.center = CGPointMake(Screen_Width / 2, CGRectGetMaxY(imageView.frame) + 15 + rect.size.height/2);
    label.text  = self.docName;
    label.textColor = AB_Color_403b36;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    self.label = label;
    
    _straightDownload = ([AIDocumentDownloadManager requestWithKey:_downloadKey] != nil);
    if (_straightDownload){
        [self progressView];
    }else {
        [self button];
    }
}

- (void) download {
    // Find the request if it exists
    ASIHTTPRequest *request = [AIDocumentDownloadManager requestWithKey:_downloadKey];
    if (!request) {
        // Create request object
        NSString *url_string = [NSString stringWithFormat:@"%@/%@", ResourcesURL, self.docKey];
        NSURL *url = [NSURL URLWithString:url_string];
        request = [ASIHTTPRequest requestWithURL:url];
        
        // Set file cache path
        NSString *path = [_cache pathWithKey:self.docKey ofType:self.docType];
        request.downloadDestinationPath = path;
        
        // Store request
        [AIDocumentDownloadManager setRequest:request forKey:_downloadKey];
        
        self.request = request;
    }
    
    // Set progress delegate
    request.downloadProgressDelegate = self.progressView;
    
    // Finish block
    __weak typeof(self)wself = self;
    request.completionBlock = ^() {
        [wself preview];
    };
    
    // Start request
    if (!_straightDownload) {
        // The same request can't startAsynchronous twice
        [request startAsynchronous];
    }
}

- (void) preview {
    [AIDocumentDownloadManager removeRequestForKey:_downloadKey];
    
    AIQLPreviewItem *item = [[AIQLPreviewItem alloc] initWithCache:_cache];
    item.docName = self.docName;
    item.docKey = self.docKey;
    item.docType = self.docType;
    _documents = @[item];
    
    _previewController = [[QLPreviewController alloc] init] ;
    _previewController.dataSource = self;
    _previewController.view.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
    _previewController.currentPreviewItemIndex = 0;
    [self.view addSubview:_previewController.view];
    [_previewController reloadData];
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return _documents.count;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)previewController
                    previewItemAtIndex:(NSInteger)idx {
    return _documents[idx];
}


@end
