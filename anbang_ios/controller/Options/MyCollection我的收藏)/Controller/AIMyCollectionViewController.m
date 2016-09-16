//
//  AIMyCollectionViewContoroller.m
//  anbang_ios
//
//  Created by rooter on 15-4-30.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIMyCollectionViewController.h"
#import "AICollectionCRUD.h"
#import "AIItemModel.h"
#import "UserInfoCRUD.h"
#import "AICollection.h"
#import "AIExtraInfo.h"
#import "AIControllersTool.h"
#import "AINavigationController.h"
#import "AICollectionDetailController.h"
#import "AICollectionTool.h"
#import "AIChatResourceCache.h"
#import "AIPreviewController.h"
#import "AIDocument.h"
#import "AIArticle.h"
#import "AIUIWebViewController.h"

@implementation AIMyCollectionViewController
{
    NSNotificationCenter *center;
    
    NSMutableArray *mCollections;
    NSMutableArray *mSelectedCollections;
    
    UIButton *mEditButton;
    UITableView *mCollectionTableView;
    AIBottomView *mBottomView;
}

- (void)dealloc
{
    [AICollectionTool removeNotificationsInContorller:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self commonInit];
    [self setupNavigationItem];
    [self setupInterface];
    [self setupNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [AICollectionTool getCollectionList];
}

#pragma mark 
#pragma mark Initailizations

- (void)commonInit
{
    // setup controller
    [self initDatasource];
    self.view.backgroundColor = Controller_View_Color;
    center = [NSNotificationCenter defaultCenter];
}

- (void)initDatasource
{
    // setup members
    NSArray *collections = [AICollectionCRUD collections];

    if (!collections) {
        mCollections = [NSMutableArray array];
    }else {
        NSMutableArray *tmp = [NSMutableArray array];
        for (AICollection *collection in collections) {
            
            NSString *senderJID = [self jidWithUserName:collection.sender];
            UserInfo *user = [UserInfoCRUD queryUserInfo:senderJID myJID:MY_JID];
            
            AIExtraInfo *info = [[AIExtraInfo alloc] init];
            info.name = user.nickName;
            info.iconId = user.avatar;
            
            AIItemModel *item = [[AIItemModel alloc] init];
            item.extraInfo = info;
            item.collection = collection;
            
            [tmp addObject:item];
        }
        mCollections = tmp;
    }
}

- (NSString *)jidWithUserName:(NSString *)aUserName
{
    return [NSString stringWithFormat:@"%@@%@", aUserName, OpenFireHostName];
}

- (void)setupNavigationItem
{
    self.title = @"我的收藏";
    
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix, [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                         target:self
                                                                                         action:@selector(back)]];
    
    
    AITitleBarButtonItem *edit = [[AITitleBarButtonItem alloc]initWithTitle:@"编辑" target:self action:@selector(edit:)];
    
    mEditButton = edit.button;
    
    //right bar button
    self.navigationItem.rightBarButtonItems = @[edit, flix];
}

- (void)setupInterface
{
    CGRect rect = CGRectMake(0, 0, Screen_Width, Screen_Height - Both_Bar_Height);
    UITableView *tableView = [[UITableView alloc] init];
    tableView.frame = rect;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorColor = AB_Color_f4f0eb;
    tableView.backgroundColor = Controller_View_Color;
    UIView *footerView = [[UIView alloc] init];
    tableView.tableFooterView = footerView;
    [self.view addSubview:tableView];
    mCollectionTableView = tableView;
    
    // bottom view
    mBottomView = [AIBottomView bottomViewWithDelegete:self];
    [self.view addSubview:mBottomView];
}

- (void)setupNotifications
{
    [AICollectionTool registerNotificationsInController:self];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)edit:(UIButton *)sender
{
    mEditButton.selected = !mEditButton.selected;
    
    if (mEditButton.selected) {
        [mEditButton setTitle:@"取消" forState:UIControlStateNormal];
        [mBottomView show];
    }else {
        [mEditButton setTitle:@"编辑" forState:UIControlStateNormal];
        [mBottomView hide];
    }
    // editing
    [mCollectionTableView setEditing:sender.selected animated:YES];
}

#pragma mark
#pragma mark AIBottomViewDelegate

-       (void)bottomView:(AIBottomView *)bottomView
didSelectedButtonAtIndex:(NSInteger)index
                  button:(UIButton *)button
{
    [self edit:nil];
    if (mSelectedCollections.count == 0) return;
    switch (index) {
        case 0:
            [AICollectionTool retweet:mSelectedCollections presentDetailControllerWithController:self];
            break;
        
        case 1:
            [AICollectionTool trash:mSelectedCollections loadingInViewController:self];
            break;
            
        default:
            break;
    }
}

#pragma end


#pragma mark
#pragma mark UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    JLLog_I(@"mcollections=%d", mCollections.count);
    return mCollections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AICollectionCell *cell = [AICollectionCell cellWithTableView:tableView];
    cell.item = mCollections[indexPath.row];
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:60.0f];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AIItemModel *item = mCollections[indexPath.row];
    return item.cellHeight;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (mEditButton.selected) {
        if (!mSelectedCollections) {
            mSelectedCollections = [NSMutableArray array];
        }
        [mSelectedCollections addObject:mCollections[indexPath.row]];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        AIItemModel *model = mCollections[indexPath.row];
        if (model.collection.messageType == AIMessageTypeDocument) {
            AIChatResourceCache *cache = [AIChatResourceCache cacheWithUserName:@"collection"];
            AIPreviewController *c = [[AIPreviewController alloc] initWithCache:cache];
            AIDocument *document = [AIDocument documentWithJson:model.collection.message];
            c.docKey = document.link;
            c.docName = document.fileName;
            c.docType = document.fileType;
            [self.navigationController pushViewController:c animated:YES];
        }else if (model.collection.messageType == AIMessageTypeArticle) {
            AIArticle *artile = [AIArticle articleWithJson:model.collection.message];
            AIUIWebViewController *controller = [[AIUIWebViewController alloc]init];
            controller.url = artile.src;
            controller.usingCache = NO;
            controller.mode = AIUIWebViewModePresent;
            AINavigationController *nav = [[AINavigationController alloc]initWithRootViewController:controller];
            [self presentViewController:nav animated:YES completion:nil];
        }
        else{
            AICollectionDetailController *detail = [[AICollectionDetailController alloc] init];
            detail.model = mCollections[indexPath.row];
            [self.navigationController pushViewController:detail animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AIItemModel *model = mCollections[indexPath.row];
    NSString *store_id = model.collection.serviceId;
    if (mEditButton.selected) {
        for (AIItemModel *item in mSelectedCollections) {
            if ([store_id isEqualToString:item.collection.serviceId]) {
                [mSelectedCollections removeObject:item];
                break;
            }
        }
    }
}

#pragma end

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:AB_Color_c3bdb4 title:@"转发"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:AB_Color_e55a39 title:@"删除"];
    
    return rightUtilityButtons;
}

#pragma mark
#pragma mark SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [mCollectionTableView indexPathForCell:cell];
    switch (index) {
        case 0:
        {
            // Retweet button
            AIItemModel *model = mCollections[indexPath.row];
            NSArray *collections = [NSArray arrayWithObject:model];
            [AICollectionTool retweet:collections presentDetailControllerWithController:self];
        }
            break;
        case 1:
        {
            // Delete button
            AIItemModel *model = mCollections[indexPath.row];
            NSArray *models = [NSArray arrayWithObject:model];
            [AICollectionTool trash:models loadingInViewController:self];
        }
            break;
            
        default:
            break;
    }
}

#pragma end

#pragma mark
#pragma mark notification response

- (void)deleteCollectionSucceed:(NSNotification *)n
{
    [AIControllersTool loadingVieHide:self];
    
    NSDictionary *dict = [n object];
    NSString *success = dict[@"success"];
    
    if ([@"true" isEqualToString:success])
    {
        [AIControllersTool tipViewShow:@"删除成功"];
        [AICollectionCRUD deleteCollection:dict[@"id"]];
        [self initDatasource];
        [mCollectionTableView reloadData];
    }
    else
    {
        [AIControllersTool tipViewShow:@"删除失败，请稍后重试"];
    }
}

- (void)deleteCollectionError:(NSNotification *)n
{
    [AIControllersTool loadingVieHide:self];
    [AIControllersTool tipViewShow:@"服务器出错，请稍后重试"];
}

- (void)deleteCollectionsSucceed:(NSNotification *)n
{
    [AIControllersTool loadingVieHide:self];
    NSArray *resultset = [n object];
    NSMutableArray *fails = [NSMutableArray array];
    
    for (NSDictionary *item in resultset)
    {
        NSString *success = item[@"success"];
        NSString *id = item[@"id"];
        if ([success isEqualToString:@"true"]) {
            [AICollectionCRUD deleteCollection:id];
        }else {
            [fails addObject:item];
        }
    }
    
    NSString *tip =  fails.count > 0 ? @"删除失败" : @"删除成功";
    [mSelectedCollections removeAllObjects];
    [AIControllersTool tipViewShow:tip];
    [self initDatasource];
    [mCollectionTableView reloadData];
}

- (void)deleteCollectionsError:(NSNotification *)n
{
    [mSelectedCollections removeAllObjects];
    [AIControllersTool loadingVieHide:self];
    [AIControllersTool tipViewShow:@"服务器出错，请稍后重试"];
}

- (void)getCollectionReturn:(NSNotification *)n
{
    [self initDatasource];
    [mCollectionTableView reloadData];
}

- (void)getCollectionError:(NSNotification *)n
{
    [AIControllersTool tipViewShow:@"服务器错误，更新失败"];
}

/**
- (void)sendDeleteIQRequest:(NSString *)id
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        [iq addAttributeWithName:@"id" stringValue:@"AI_Collection_Delete"];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:kStoreupNameSpace];
        
        NSXMLElement *storeup = [NSXMLElement elementWithName:@"storeUp"];
        [storeup addAttributeWithName:@"id" stringValue:id];
        [storeup addAttributeWithName:@"do" stringValue:@"delete"];
        
        [query addChild:storeup];
        [iq addChild:query];
        
        [[XMPPServer xmppStream] sendElement:iq];
        
        JLLog_I(@"collection delete (iq=%@)", iq);
    });
}
 */

@end
