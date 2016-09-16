//
//  BaiduMapViewController.h
//  BaiduMapSdkSrc
//
//  Created by BaiduMapAPI on 13-7-24.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>

@protocol BaiduMapViewControllerDelegate <NSObject>

-(void)sendLocationMessage:(NSDictionary *)locationInfo;

@end

@interface BaiduMapViewController :  UIViewController <BMKMapViewDelegate,BMKLocationServiceDelegate,
UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,BMKGeoCodeSearchDelegate>{
    BMKMapView *_mapView;
    BMKLocationService *_locService;
    UITableView *_tableView;
    NSMutableArray *_addressPointArray;
    NSMutableArray *_addressArray;
    int currentIndex;
    BOOL mReload;
    AITitleBarButtonItem *mSendItem;
}

@property (nonatomic, copy) NSString *addressName;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) BOOL showsUserLocation;
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;
@property (nonatomic, assign) id delegate;
@end