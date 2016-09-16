//
//  AIABSearchResultViewController.h
//  anbang_ios
//
//  Created by rooter on 15-5-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AISearchAssistant;

@interface AIABSearchResultViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *mTableView;
}

@property (strong, nonatomic) NSArray *employees;
@property (nonatomic, strong) AISearchAssistant *assistant;

@end
