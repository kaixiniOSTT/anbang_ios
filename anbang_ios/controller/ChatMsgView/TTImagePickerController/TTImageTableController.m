//
//  TTImageTableController.m
//  MultiImagePickerDemo
//
//  Created by Jason Lee on 12-11-1.
//  Copyright (c) 2012年 Jason Lee. All rights reserved.
//

#import "TTImageTableController.h"
#import "TTAsset.h"
#import "TTImageTableCell.h"
#import "DejalActivityView.h"

@interface TTImageTableController ()

@end

@implementation TTImageTableController

- (id)init
{
    self = [super init];
    if (self) {
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [_assetsLibrary release];
    [_assetsGroup release];
    [_assetsArray release];
    
    [_tableView release];
    [_bottomBar release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    //
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    self.title = @"加载中";
    
    // Translate EnGroupName into CnGroupName
    NSString *groupName = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    if ([groupName isEqualToString:@"Camera Roll"]) {
        groupName = @"相机胶卷";
    } else if ([groupName isEqualToString:@"My Photo Stream"]) {
        groupName = @"我的照片流";
    }
    
    cellHeight = (KCurrWidth-20)/4 + 4;
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonSystemItemDone target:self action:@selector(doneButtonDidClick:)] autorelease];
    
    if ([[UIDevice currentDevice].systemVersion doubleValue]>=7.0) {
        
        //NSLog(@"*******%f",KCurrHeight);
        
         _tableView = [[UITableView alloc] initWithFrame:(CGRect){0, 0, KCurrWidth, KCurrHeight-160} style:UITableViewStylePlain];
         _bottomBar = [[TTImagePickerBar alloc] initWithFrame:(CGRect){0, KCurrHeight-160, KCurrWidth, 96}];
    }else{
         _tableView = [[UITableView alloc] initWithFrame:(CGRect){0, 44, KCurrWidth, KCurrHeight-160} style:UITableViewStylePlain];
         _bottomBar = [[TTImagePickerBar alloc] initWithFrame:(CGRect){0, KCurrHeight-160, KCurrWidth, 96}];
    }
    _bottomBar.maxSelected = self.maxSelected;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
   
    [self.view addSubview:self.bottomBar];
    
    // You can show loading here...
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getImages];
        dispatch_async(dispatch_get_main_queue(), ^{
            // You can hide loading here...
            self.title = groupName;
            [_tableView reloadData];
        });
   // });
    
 
    [_tableView setContentOffset:CGPointMake(0, ceil([self.assetsGroup numberOfAssets] / 4.0)*cellHeight+10)];
    [_tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

- (void)applicationWillEnterForeground
{
    // reload table if needed.
}

- (void)getImages
{
    if (!self.assetsArray) {
        _assetsArray = [[NSMutableArray alloc] init];
    }
    
    if (!self.assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    @autoreleasepool {
        [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                TTAsset *ttAsset = [[TTAsset alloc] initWithAsset:result];
                ttAsset.delegate = self;
                ttAsset.maxSelected = self.maxSelected;
                [self.assetsArray addObject:ttAsset];
                [ttAsset release], ttAsset = nil;
            }
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ceil([self.assetsGroup numberOfAssets] / 4.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;   // The size of the thumbnail in iPhoto is (75, 75), with 4-pix margin to each other.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TTImageTableCell";
    TTImageTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[TTImageTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSInteger idx = indexPath.row * 4;
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:4];
    
    NSLog(@"**********%d",self.assetsArray.count);
    
    
    for (int i = idx; i < [self.assetsArray count] && i < idx + 4; ++i) {
        [array addObject:[self.assetsArray objectAtIndex:i]];
    }
    cell.assetsArray = array;
    cell.delegate = self;
    [array release], array = nil;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 

- (void)doneButtonDidClick:(id)sender
{
    if ([self.bottomBar.selectedAssets count] <= 0) {
        return ;
    }
    
    if (self.isUploading) {
        return ;
    }
    self.isUploading = YES;
    // You can show loading here...
    //加载动画效果
     [DejalBezelActivityView activityViewForView:self.view withLabel:@"加载中..." width:100];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *imageInfoArray = [[[NSMutableArray alloc] init] autorelease];
        
        @autoreleasepool {
            for (TTAsset *ttAsset in self.bottomBar.selectedAssets) {
                ALAsset *asset = ttAsset.asset;
                ALAssetRepresentation *repre = [asset defaultRepresentation];
//                NSMutableDictionary *workingDictionary = [[[NSMutableDictionary alloc] init] autorelease];
                
//                id propertyType = [asset valueForProperty:ALAssetPropertyType];
//                if (propertyType) {
//                    [workingDictionary setObject:propertyType forKey:@"UIImagePickerControllerMediaType"];
//                } else {
//                    continue;
//                }
//            
//
//                [workingDictionary setObject:repre forKey:@"ALAssetRepresentation"];
//
//                
//                id referenceURL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]];
//                if (referenceURL) {
//                    [workingDictionary setObject:referenceURL forKey:@"UIImagePickerControllerReferenceURL"];
//                } else {
//                    continue;
//                }
//                JLLog_D(@"%d", (UIImageOrientation)[repre orientation]);
//                
//                workingDictionary[@"orientation"] = [NSNumber numberWithInteger:[repre orientation]];
                
                [imageInfoArray addObject:repre];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // You can hide loading here...
            [DejalBezelActivityView
             removeView];
            
            if ([imageInfoArray count] <= 0) {
                [self.bottomBar.selectedAssets removeAllObjects];
                [self.bottomBar reloadData];
                return ;
            }

            if (self.delegate &&
                [self.delegate respondsToSelector:@selector(didFinishPickingImages:)])
            {
                [self.delegate performSelector:@selector(didFinishPickingImages:) withObject:imageInfoArray];
            }
            
            self.isUploading = NO;
        });
    });
}

- (void)thumbnailDidClick:(TTAsset *)ttAsset
{
    
    
    
    if (ttAsset.selected) {
        [self.bottomBar addAsset:ttAsset];
    } else {
        [self.bottomBar removeAsset:ttAsset];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
      
}


@end
