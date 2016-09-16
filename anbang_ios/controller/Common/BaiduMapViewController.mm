//
//  BaiduMapViewController.mm
//  BaiduMapSdkSrc
//
//  Created by BaiduMapAPI on 13-7-24.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import "BaiduMapViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import "ChatViewController2.h"
#import "GroupChatViewController2.h"
#import "Photo.h"
#import "ImageUtility.h"
#import "StrUtility.h"

@implementation BaiduMapViewController

@synthesize delegate;

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.showsUserLocation = NO;
    currentIndex = -1;
    mReload = YES;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigationItem];
    
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, self.showsUserLocation?Screen_Width*108/172:Screen_Height-Both_Bar_Height)];
    [_mapView setZoomLevel:17];
    [self.view addSubview:_mapView];
    
    if(self.showsUserLocation){
        UIImageView *centerImage = [[UIImageView alloc] initWithFrame:CGRectMake(_mapView.center.x - 10 , _mapView.center.y - 28, 20, 28)];
        centerImage.image = [UIImage imageNamed:@"chat_icon_position_01"];
        [self.view addSubview:centerImage];
        [self.view bringSubviewToFront:centerImage];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _mapView.frame.size.height, Screen_Width, Screen_Height - _mapView.frame.size.height - Both_Bar_Height)];
        _tableView.backgroundColor = AB_Color_f6f2ed;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.scrollsToTop = YES;
        
        _addressArray = [NSMutableArray array];
        _addressPointArray = [NSMutableArray array];
        
        [self.view addSubview:_tableView];
    }
//
//    //适配ios7
//    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
//    {
////        self.edgesForExtendedLayout=UIRectEdgeNone;
//        self.navigationController.navigationBar.translucent = NO;
//    }
    //[self addCustomGestures];//添加自定义的手势

    if(self.showsUserLocation){
        //初始化BMKLocationService
        _locService = [[BMKLocationService alloc]init];
    }
}

- (void)setupNavigationItem
{
    
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AITitleBarButtonItem alloc]initWithTitle:@"取消" target:self action:@selector(back)]];
    
    self.navigationItem.title = @"位置信息";
    
    if(self.showsUserLocation){
        mSendItem =[[AITitleBarButtonItem alloc]initWithTitle:@"发送" target:self action:@selector(sendLocation)];
        mSendItem.button.hidden = YES;
        self.navigationItem.rightBarButtonItems = @[mSendItem, flix];
    }
    

}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendLocation
{
    if([StrUtility isBlankString:_addressName]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"未定位到位置，无法发送"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    
    UIImage *snapshotImage = [_mapView takeSnapshot];
    snapshotImage = [ImageUtility imageWithImageSimple:snapshotImage scaledToSize:CGSizeMake(688, 432)];
    NSString *coverString = [Photo image2String2:snapshotImage withCompressionQuality:0.3];
    JLLog_D(@"coverString.length=%d",coverString.length);
    NSDictionary *locationDictionary = @{@"cover":coverString,
                                         @"locationName":_addressName,
                                         @"address":_address,
                                         @"latitude":[NSNumber numberWithDouble: _latitude],
                                         @"longitude":[NSNumber numberWithDouble: _longitude]};
    
    if([delegate respondsToSelector:@selector(sendLocationMessage:)]){
        [delegate sendLocationMessage:locationDictionary];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    if(self.showsUserLocation){
        
        if ([XMPPServer sharedServer].loginFlag != 2) {
            return;
        }
        
        //设置定位精确度，默认：kCLLocationAccuracyBest
        [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyBest];
        //指定最小距离更新(米)，默认：kCLDistanceFilterNone
        [BMKLocationService setLocationDistanceFilter:100.0];

        _locService.delegate = self;
        [_locService startUserLocationService];
        _mapView.showsUserLocation = YES;
        _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    } else {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(_latitude, _longitude);
        _mapView.centerCoordinate = coordinate;
        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
        annotation.coordinate = coordinate;
        annotation.title = _addressName;
        annotation.subtitle = [StrUtility string:_address];
        [_mapView addAnnotation:annotation];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
}

- (void)searchNearby:(CLLocationCoordinate2D)coordinate
{
    BMKGeoCodeSearch *geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
    geoCodeSearch.delegate = self;
    //初始化逆地理编码类
    BMKReverseGeoCodeOption *reverseGeoCodeOption= [[BMKReverseGeoCodeOption alloc] init];
    //需要逆地理编码的坐标位置
    reverseGeoCodeOption.reverseGeoPoint = coordinate;
    [geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
}

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if(result){
        float latitude = result.location.latitude;
        float longitude = result.location.longitude;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];

        NSMutableArray *tempAddressArray = [NSMutableArray array];
        
        [tempAddressArray addObject:@{@"name": result.address,
                                   @"displayName": @"[位置]",
                                   @"address": result.address,
                                   @"distance": @0,
                                   @"latitude": [NSNumber numberWithFloat:latitude],
                                   @"longitude": [NSNumber numberWithFloat:longitude]}];
        
        NSArray *poiList = result.poiList;
        for(BMKPoiInfo *poi in poiList){
            float latitude = poi.pt.latitude;
            float longitude = poi.pt.longitude;
            
            CLLocationDistance meters=[location distanceFromLocation:[[CLLocation alloc] initWithLatitude:latitude longitude:longitude]];
            
            [tempAddressArray addObject:@{@"name": poi.name,
                                          @"displayName": poi.name,
                                          @"address": poi.address,
                                          @"latitude": [NSNumber numberWithFloat:latitude],
                                          @"longitude": [NSNumber numberWithFloat:longitude],
                                          @"distance": [NSNumber numberWithInt:meters]}];
            
            
            //[self searchNearby:poi.pt];
        }
        
        _addressArray = [[tempAddressArray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *address1, NSDictionary *addrees2) {
            double dist1 = [address1[@"distance"] floatValue];
            double dist2 = [addrees2[@"distance"] floatValue];
            if(dist1 < dist2){
                return NSOrderedAscending;
            }
            if(dist1 > dist2){
                return NSOrderedDescending;
            }
            
            return NSOrderedSame;
        }] mutableCopy];
        
        [_tableView reloadData];

        [self tableView:_tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKAnnotationView *newAnnotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.image = [UIImage imageNamed:@"chat_icon_position_01"];
        newAnnotationView.centerOffset = CGPointMake(0, -19);
        //newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    _latitude = userLocation.location.coordinate.latitude;
    _longitude = userLocation.location.coordinate.longitude;
    NSLog(@"didUpdateUserLocation lat %lf,long %lf", _latitude, _longitude);
    
    [_mapView updateLocationData:userLocation];
    
    [self searchNearby:userLocation.location.coordinate];
    
    mSendItem.button.hidden = NO;
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
    mSendItem.button.hidden = YES;
}


- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
    
    _locService = nil;
    _addressArray = nil;
    _addressPointArray = nil;
    _addressName = nil;
    _tableView = nil;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


#pragma mark - BMKMapViewDelegate

- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"BMKMapView控件初始化完成" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
//    [alert show];
//    alert = nil;
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    NSLog(@"map view: click blank");
}

- (void)mapview:(BMKMapView *)mapView onDoubleClick:(CLLocationCoordinate2D)coordinate {
    NSLog(@"map view: double click");
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if(self.showsUserLocation && mReload) {
        CLLocationCoordinate2D center = _mapView.region.center;
        JLLog_D(@"current center _latitude = %lf, longitude = %lf", center.latitude, center.longitude);
        [self searchNearby:center];
    }
    
    mReload = YES;
}

#pragma mark - 添加自定义的手势（若不自定义手势，不需要下面的代码）

- (void)addCustomGestures {
    /*
     *注意：
     *添加自定义手势时，必须设置UIGestureRecognizer的属性cancelsTouchesInView 和 delaysTouchesEnded 为NO,
     *否则影响地图内部的手势处理
     */
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.delegate = self;
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.cancelsTouchesInView = NO;
    doubleTap.delaysTouchesEnded = NO;
    
    [self.view addGestureRecognizer:doubleTap];
    
    /*
     *注意：
     *添加自定义手势时，必须设置UIGestureRecognizer的属性cancelsTouchesInView 和 delaysTouchesEnded 为NO,
     *否则影响地图内部的手势处理
     */
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.delegate = self;
    singleTap.cancelsTouchesInView = NO;
    singleTap.delaysTouchesEnded = NO;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.view addGestureRecognizer:singleTap];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)theSingleTap {
    /*
     *do something
     */
    NSLog(@"my handleSingleTap");
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)theDoubleTap {
    /*
     *do something
     */
    NSLog(@"my handleDoubleTap");
}

#pragma mark -
#pragma mark Table View DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _addressArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identity = @"AddressCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identity];
    }
    NSDictionary *addressDict = [_addressArray objectAtIndex:indexPath.row];
    cell.textLabel.text = addressDict[@"displayName"];
    cell.detailTextLabel.text = addressDict[@"address"];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}


#pragma mark -
#pragma mark Table View Delegate Methods

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==currentIndex){
        return UITableViewCellAccessoryCheckmark;
    }
    else{
        return UITableViewCellAccessoryNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row==currentIndex){
        return;
    }
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:currentIndex
                                                   inSection:0];
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
    currentIndex=indexPath.row;
    
    NSDictionary *address = [_addressArray objectAtIndex:indexPath.row];
    _latitude = [address[@"latitude"] floatValue];
    _longitude = [address[@"longitude"] floatValue];
    _addressName = address[@"name"];
    _address = address[@"address"];
    mReload = NO;
    _mapView.centerCoordinate = CLLocationCoordinate2DMake(_latitude, _longitude);
}

@end
