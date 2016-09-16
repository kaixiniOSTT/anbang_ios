//
//  SystemInformsViewController.h
//  anbang_ios
//
//  Created by seeko on 14-6-7.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCLabel.h"

@interface SystemMessageViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate,KKMessageDelegate,RTLabelDelegate>{
    NSMutableArray *systemMessageArr;
    NSMutableDictionary *mHeightDictionary;
    int mPageCount;
    int mTotal;
}
@property (nonatomic, retain)NSString *sendName;
@property (nonatomic, retain)NSString *sendTitle;
@end
