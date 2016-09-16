//
//  AINewFriendViewController.m
//  anbang_ios
//
//  Created by rooter on 15-6-16.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AINewFriendViewController.h"
#import "AINewFriendsCRUD.h"

@interface AINewFriendViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) UITableView *tableView;
@end

@implementation AINewFriendViewController {
    NSArray *_newFriends;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationItem];
    [self setupInterface];
    [self setupDatasource];
}

- (void)setupNavigationItem {
    
}

- (void)setupInterface {
    UITableView *t = [[UITableView alloc] init];
    t.frame = (CGRect){CGPointZero, CGSizeMake(Screen_Width, Screen_Height - Both_Bar_Height)};
    t.dataSource = self;
    t.delegate = self;
    [self.view addSubview:t];
    self.tableView = t;
}

- (void)setupDatasource {
    _newFriends = [AINewFriendsCRUD requestItems];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _newFriends.count;
}



@end
