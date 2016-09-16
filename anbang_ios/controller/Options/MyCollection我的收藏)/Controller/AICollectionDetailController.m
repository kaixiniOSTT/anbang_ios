//
//  AICollectionDetailController.m
//  anbang_ios
//
//  Created by rooter on 15-5-4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AICollectionDetailController.h"
#import "AICollectionCell.h"
#import "AIItemModel.h"
#import "AIMessageTool.h"
#import "UIImageView+WebCache.h"
#import "AIBottomView.h"
#import "AICollectionTool.h"
#import "AIChatResourceCache.h"

// import "SDWebImageManager.h" to control image cache path
#import "SDWebImageManager.h"


@interface AICollectionDetailController ()<UITableViewDataSource, UITableViewDelegate, AIBottomViewDelegate>
@property (strong, nonatomic) AIBottomView *bottomView;
@property (strong, nonatomic) UIButton *rightBarButton;
@end

@implementation AICollectionDetailController
{
    NSNotificationCenter *center;
    AIChatResourceCache *mResourceCache;
}

- (void)dealloc
{
    [center removeObserver:self name:@"AI_Collections_Delete_Return" object:nil];
    [center removeObserver:self name:@"AI_Collections_Delete_Error" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self commonInit];
    [self setupNavigationItem];
    [self setupInterface];
    [self setupNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    manager.imageCache = nil; // Then manager.imageCache will be it's default cache.
}

#pragma mark
#pragma mark Initailization
- (void)commonInit
{
    self.view.backgroundColor = AB_White_Color;
    center = [NSNotificationCenter defaultCenter];
    mResourceCache = [AIChatResourceCache cacheWithUserName:@"collection"];
    
}

- (void)setupNavigationItem
{
    self.title = @"我的收藏";
    
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix, [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                         target:self
                                                                                         action:@selector(back)]];
    
    UIButton *other = [UIButton buttonWithType:UIButtonTypeCustom];
    
    other.frame = CGRectMake(0, 0, 40, 30);
    other.titleLabel.font = [UIFont systemFontOfSize:16];
    
    [other setTitle:@"编辑" forState:UIControlStateNormal];
    other.titleLabel.font = [UIFont systemFontOfSize:18];
    [other addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    
    AITitleBarButtonItem *edit = [[AITitleBarButtonItem alloc]initWithTitle:@"编辑" target:self action:@selector(edit:)];
    
    self.rightBarButton = edit.button;
    
    //right bar button
    self.navigationItem.rightBarButtonItems = @[edit, flix];
}

- (void)setupInterface
{
    CGFloat h = Screen_Height - Both_Bar_Height;
    UITableView *tableView = [[UITableView alloc] init];
    tableView.frame = CGRectMake(0, 0, Screen_Width, h);
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    self.bottomView = [AIBottomView bottomViewWithDelegete:self];
    
    [self.view addSubview:tableView];
    [self.view addSubview:self.bottomView];
}

- (void)setupNotifications
{
    [center addObserver:self selector:@selector(deleteCollectionsSucceed:) name:@"AI_Collections_Delete_Return" object:nil];
    [center addObserver:self selector:@selector(deleteCollectionsError:) name:@"AI_Collections_Delete_Error" object:nil];
}

#pragma end

#pragma mark
#pragma mark button action

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)edit:(UIButton *)sender
{
    sender.selected = !sender.selected;
    sender.selected ? [self.bottomView show] : [self.bottomView hide];
    NSString *title = sender.selected ? @"取消" : @"编辑";
    [sender setTitle:title forState:UIControlStateNormal];
}

#pragma end

#pragma mark
#pragma mark UITableView datasource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AICollectionCell *cell = [AICollectionCell cellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0:{
            self.model.contentImageViewF = CGRectZero;
            self.model.contentLabelF = CGRectZero;
            cell.item = self.model;
        }
            break;
        
        case 1: {
            for (UIView *view in cell.contentView.subviews) {
                [view removeFromSuperview];
            }
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, Screen_Width);
            NSString *message = self.model.collection.message;
            CGFloat w = Screen_Width - 2 * Margin_To_Left_Right;

            switch (self.model.collection.messageType) {
                case AIMessageTypeText:
                {
                    UIFont *font = [UIFont systemFontOfSize:15.0];
                    CGSize size = [message sizeWithFont:font constrainedToSize:CGSizeMake(w, CGFLOAT_MAX)];
                    CGRect frame = CGRectMake(Margin_To_Left_Right, Margin_To_Top_Bottom, w, size.height);
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:frame];
                    label.numberOfLines = 0;
                    label.font = font;
                    label.text = message;
                    label.textColor = AB_Color_403b36;
                    [cell.contentView addSubview:label];
                }
                    break;
                
                case AIMessageTypePicture:
                {
                    CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
                    CGRect frame = CGRectMake(Margin_To_Left_Right, Margin_To_Top_Bottom, w, rect.size.height);
                    UIImageView *imageview = [[UIImageView alloc] init];
                    imageview.frame = frame;
                    imageview.contentMode = UIViewContentModeScaleAspectFit;
                    
                    NSString *link = [AIMessageTool HDImageLinkWithMessage:message];
                    UIImage *image =  [mResourceCache imageForKey:link];
                    if (image) {
                        imageview.image = image;
                    }else {
                        SDWebImageManager *manager = [SDWebImageManager sharedManager];
                        manager.imageCache = mResourceCache.imageCache;   // we need to set nil when view did disappear.
                        NSURL *url = [NSURL URLWithString:[AIMessageTool HDImageLinkWithMessage:message]];
                        [imageview setImageWithURL:url placeholderImage:nil];
                    }
                    [cell.contentView addSubview:imageview];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0.0;
    switch (indexPath.row) {
        case 0:
            cellHeight = CGRectGetMaxY(self.model.iconViewF) + Margin_To_Top_Bottom;
            break;
        
        case 1: {
            switch (self.model.collection.messageType) {
                case AIMessageTypeText:
                {
                    UIFont *font = [UIFont systemFontOfSize:15.0];
                    CGFloat w = Screen_Width - 2 * Margin_To_Left_Right;
                    CGSize size = [self.model.collection.message sizeWithFont:font
                                                            constrainedToSize:CGSizeMake(w, CGFLOAT_MAX)];
                    
                    cellHeight = size.height + Margin_To_Top_Bottom * 2;
                }
                    break;
                    
                case AIMessageTypePicture: {
                    cellHeight = tableView.frame.size.height - (CGRectGetMaxY(self.model.iconViewF) + Margin_To_Top_Bottom);
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    return cellHeight;
}

#pragma end


#pragma mark
#pragma mark AIBottomViewDelegate

- (void)bottomView:(AIBottomView *)bottomView didSelectedButtonAtIndex:(NSInteger)index button:(UIButton *)button
{
    [self edit:self.rightBarButton];
    NSArray *models = [NSArray arrayWithObject:self.model];
    switch (index) {
        case 0: {
            [AICollectionTool retweet:models presentDetailControllerWithController:self];
            break;
            
        case 1:
            [AICollectionTool trash:models loadingInViewController:self];
            break;
            
        default:
            break;
        }
    }
}

#pragma end

- (void)deleteCollectionsSucceed:(NSNotification *)n
{
    [AIControllersTool loadingVieHide:self];
    NSArray *resultset = [n object];
    NSMutableArray *fails = [NSMutableArray array];
    
    for (NSDictionary *item in resultset)
    {
        NSString *success = item[@"success"];
        if ([success isEqualToString:@"true"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    NSString *tip =  fails.count > 0 ? @"删除失败" : @"删除成功";
    [AIControllersTool tipViewShow:tip];
}

- (void)deleteCollectionsError:(NSNotification *)n
{
    [AIControllersTool loadingVieHide:self];
    [AIControllersTool tipViewShow:@"服务器出错，请稍后重试"];
}

@end

