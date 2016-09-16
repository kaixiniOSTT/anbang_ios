//
//  ABContactSelectedVC.m
//  anbang_ios
//
//  Created by yangsai on 15/3/26.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "ABContactSelectedVC.h"
#import "Contacts.h"
#import "MBProgressHUD.h"
#import "ABSelectedResultVC.h"
#import "UserInfo.h"
#import "AIOrganization.h"
#import "AIOrganizationCRUD.h"
#import "AIControllersTool.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "AIABSearchResultViewController.h"
#import "AISearchAssistant.h"

#define kDropDownListTag 100000

#define MARGIN_LEFT_RIGHT  15
#define MARGIN_TOP_BOTTOM  20
#define INPUT_TEXT_FIELD_HEIGHT   40
#define ROW_HEIGHT (INPUT_TEXT_FIELD_HEIGHT + MARGIN_TOP_BOTTOM * 1.0)

@interface ABContactSelectedVC ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateLeftAlignedLayout, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableDictionary *addressDict;   //地址选择字典
@property (nonatomic, strong)NSDictionary *selectDic;
@property (nonatomic, strong)NSArray *company;
@property (nonatomic, strong)NSArray *channel;
@property (nonatomic, strong)NSArray *department;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, copy)NSString *selectedCompany;
@property (nonatomic, copy)NSString *selectedChannel;
@property (nonatomic, copy)NSString *selectedDepartment;
@property (nonatomic, strong)UITextField* textField;
@property (nonatomic, strong)MBProgressHUD* progress;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) UIButton *rightBarButton;
@property (nonatomic, strong) AISearchAssistant *assistant;

@property (nonatomic, strong)UITextField* textFieldDepartment;
@end

@implementation ABContactSelectedVC
{
    NSArray *mBooks;
    NSArray *mAgencys;
    NSArray *mBranches;
}
- (void)pop
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)back:(UIButton *)sender
{
    if ([self.assistant canGoback]) {
        [self.assistant goBack:^(NSInteger lever) {
           
            switch (lever)
            {
                case AIOrganizationLavelBook:
                    self.collectionView.hidden = NO;
                    self.rightBarButton.hidden = YES;
                    [self.tableview removeFromSuperview];
                    break;
                
                case AIOrganizationLavelAgency:
                case AIOrganizationLavelBranch:
                    [self.tableview reloadData];
                    break;
                    
                default:
                    break;
            }
        }];
    }
}

- (void)setupNavigationItem
{
    self.title = @"安邦通讯录";
    
    AIFlixBarButtonItem *flix = [[AIFlixBarButtonItem alloc] initWithWidth:-8.0];
    self.navigationItem.leftBarButtonItems = @[flix,
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"通讯录"
                                                                                   target:self
                                                                                   action:@selector(pop)]];
    
    
//    UIBarButtonItem *flix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    flix.width = -8;
    
    UIButton *other = [UIButton buttonWithType:UIButtonTypeCustom];
    other.frame = CGRectMake(0, 0, 50, 30);
    other.titleLabel.font = AB_FONT_16;
    [other setTitle:@"上一级" forState:UIControlStateNormal];
    [other addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * right = [[UIBarButtonItem alloc] initWithCustomView:other];
    self.navigationItem.rightBarButtonItems = @[right, flix];
    self.rightBarButton = other;
    self.rightBarButton.hidden = YES;
}

- (void)setupController
{
    // common init
    self.view.backgroundColor = AB_Color_f6f2ed;
    self.tableview.backgroundColor = AB_Color_f6f2ed;
    // members
    self.searchResults = [NSMutableArray array];
    mBooks = [AIOrganizationCRUD queryBooks];
    
    self.assistant = [[AISearchAssistant alloc] init];
    self.assistant.lavel = AIOrganizationLavelBook;
}

- (void)setupNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(showContactInfo:) name:@"NNS_ContactInfo_Search" object:nil];
    [center addObserver:self selector:@selector(abContactReturn:) name:@"AI_AB_Contact_Search_Return" object:nil];
    [center addObserver:self selector:@selector(abContactReturnError:) name:@"AI_AB_Contact_Search_Error" object:nil];
}

- (void)setupInterface
{
    // UIButton (search)
    CGFloat btn_w = 70;
    CGFloat btn_x = Screen_Width - MARGIN_LEFT_RIGHT - btn_w;
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearch.frame = CGRectMake(btn_x, MARGIN_TOP_BOTTOM, btn_w, INPUT_TEXT_FIELD_HEIGHT);
    btnSearch.titleLabel.textColor = AB_Color_ffffff;
    btnSearch.titleLabel.font = AB_FONT_16;
    btnSearch.layer.cornerRadius = 6.0;
    btnSearch.layer.backgroundColor = AB_Red_Color.CGColor;
    [btnSearch setTitle:@"搜索" forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSearch];
    
    // UITextField
    CGFloat tf_w = CGRectGetMinX(btnSearch.frame) - MARGIN_LEFT_RIGHT * 2;
    UITextField *textField = [[UITextField alloc] init];
    textField.frame = CGRectMake(MARGIN_LEFT_RIGHT, MARGIN_TOP_BOTTOM, tf_w, INPUT_TEXT_FIELD_HEIGHT);
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.layer.borderColor = Normal_Border_Color.CGColor;
    textField.layer.cornerRadius = 6.0;
    textField.layer.borderWidth = 0.5;
    textField.font = AB_FONT_16;
    textField.backgroundColor = AB_Color_ffffff;
    [textField setCustomPlaceholder:@"姓名/工号/电话/事业部"];
    [self.view addSubview:textField];
    
    // UICollectionView
    UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    CGFloat colletion_y = CGRectGetMaxY(textField.frame) + MARGIN_TOP_BOTTOM + 10;
    CGRect rect = CGRectMake(MARGIN_LEFT_RIGHT, colletion_y, Screen_Width - 2 *MARGIN_LEFT_RIGHT, Screen_Height - colletion_y - Both_Bar_Height);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"_organization_collection_view_cell"];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
    
    // UITableView (For select organizations)
    CGFloat table_y = CGRectGetMaxY(textField.frame) + MARGIN_TOP_BOTTOM;
    CGFloat table_h = Screen_Height - Both_Bar_Height - table_y;
    CGRect table_frame= CGRectMake(0, table_y, Screen_Width, table_h);
    UITableView *tableView = [[UITableView alloc] initWithFrame:table_frame];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 1)];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorColor = AB_Color_f4f0eb;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    self.textField = textField;
    self.collectionView = collectionView;
    self.tableview = tableView;
}

- (void)search
{
    [self sendSearchIQ];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavigationItem];
    [self setupController];
    [self setupInterface];
    
/*
    // Do any additional setup after loading the view.
    //解析全国省市区信息
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"SelectInfo" ofType:@"plist"];
//    _selectDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
//    NSArray *components = [_selectDic allKeys];
//    NSArray *sortedArray = [components sortedArrayUsingComparator: ^(id obj1, id obj2) {
//        
//        if ([obj1 integerValue] > [obj2 integerValue]) {
//            return (NSComparisonResult)NSOrderedDescending;
//        }
//        
//        if ([obj1 integerValue] < [obj2 integerValue]) {
//            return (NSComparisonResult)NSOrderedAscending;
//        }
//        return (NSComparisonResult)NSOrderedSame;
//    }];
//    
//    NSMutableArray *companyTmp = [NSMutableArray array];
//    for (int i=0; i<[sortedArray count]; i++) {
//        NSString *index = [sortedArray objectAtIndex:i];
//        NSArray *tmp = [[_selectDic objectForKey: index] allKeys];
//        [companyTmp addObject: [tmp objectAtIndex:0]];
//    }
//    
//    _company = [NSArray arrayWithArray:companyTmp];
//    
//    NSString *index = [sortedArray objectAtIndex:0];
//    NSString *selected = [_company objectAtIndex:0];
//    NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [[_selectDic objectForKey:index]objectForKey:selected]];
//    
//    NSArray *channelArray = [dic allKeys];
//    NSDictionary *channelDic = [NSDictionary dictionaryWithDictionary: [dic objectForKey: [channelArray objectAtIndex:0]]];
//    _channel = [NSArray arrayWithArray:[channelDic allKeys]];
//    
//    _selectedChannel = [_channel objectAtIndex:0];
//    _department = [NSArray arrayWithArray:[channelDic objectForKey:_selectedChannel]];
//    
//    _addressDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                   _company,@"company",
//                   _channel,@"channel",
//                   _department,@"department",nil];
//    
//    _selectedCompany = [_company objectAtIndex:0];
//    _selectedChannel = [_channel objectAtIndex:0];
//    _selectedDepartment = [_department objectAtIndex:0];
    
    
//    bgScrollView = [[LMContainsLMComboxScrollView alloc]initWithFrame:CGRectMake(0, 70, 320, 400)];
//    bgScrollView.backgroundColor = [UIColor clearColor];
//    bgScrollView.showsVerticalScrollIndicator = NO;
//    bgScrollView.showsHorizontalScrollIndicator = NO;
//    [self.view addSubview:bgScrollView];
    */
//    [self setUpBgScrollView];
  
}

#pragma mark
#pragma mark UICollectionView Datasource & Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return mBooks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"_organization_collection_view_cell" forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1324];
    if (!label) {
        label = [[UILabel alloc] init];
        label.font = AB_FONT_16;
        label.textColor = AB_Color_e55a39;
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = 3.0;
        label.layer.borderColor = AB_Color_e55a39.CGColor;
        label.layer.borderWidth = 0.5;
        label.tag = 1324;
        label.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:label];
    }
    
    AIOrganization *organization = mBooks[indexPath.row];
    label.frame = cell.bounds;
    label.text = organization.name;

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AIOrganization *organization = mBooks[indexPath.row];
    NSString *string = organization.name;
    CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:15.0]];
    return CGSizeMake(size.width + 24, 35);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 5, 0, 5);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AIOrganization *organization = mBooks[indexPath.row];
    self.assistant.selectedBook = organization.code;
    self.assistant.lavel = AIOrganizationLavelAgency;
    mAgencys = [AIOrganizationCRUD queryAgencysWithBookCode:organization.code];
    
    [self.tableview reloadData];
    [self.tableview setContentOffset:CGPointMake(0, 0)];
    [self.view addSubview:self.tableview];
    self.collectionView.hidden = YES;
    self.rightBarButton.hidden = NO;
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
    switch (self.assistant.lavel) {
            
        case AIOrganizationLavelAgency:
            return mAgencys.count;
            
        case AIOrganizationLavelBranch:
            return mBranches.count;
            
        default:
            return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"_organization_table_view_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_arrowR"]];
        cell.textLabel.font = AB_FONT_17;
    }

    AIOrganization *organization = nil;
    switch (self.assistant.lavel)
    {
        case AIOrganizationLavelAgency:
            organization = mAgencys[indexPath.row];
            break;
            
        case AIOrganizationLavelBranch:
            organization = mBranches[indexPath.row];
            break;
            
        default:
            break;
    }
    cell.textLabel.text = organization.name;
    cell.textLabel.textColor = AB_Color_5b5752;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AIOrganization *organization = nil;
    switch (self.assistant.lavel)
    {
        case AIOrganizationLavelAgency:
            organization = mAgencys[indexPath.row];
            break;
            
        case AIOrganizationLavelBranch:
            organization = mBranches[indexPath.row];
            break;
            
        default:
            break;
    }
    if ([self.assistant canGoForward]) {
        self.assistant.selectedAgency = organization.code;
        self.assistant.lavel = AIOrganizationLavelBranch;
        mBranches = [AIOrganizationCRUD querybranchsWithAgencyCode:organization.code];
        [tableView reloadData];
        [self.tableview setContentOffset:CGPointMake(0, 0)];
    }else {
        self.assistant.selectedBranch = organization.code;
        [self sendSearchIQ];
    }
}

#pragma end

- (void)sendSearchIQ
{
    self.assistant.searchKey = self.textField.text;
    if ([self.assistant canSendSearchIQ]) {
        [self.assistant sendSearchIQ];
        [AIControllersTool loadingViewShow:self];
    }else {
        [AIControllersTool tipViewShow:@"请输入搜索条件"];
    }
}

- (void)abContactReturn:(NSNotification *)notify
{
    [AIControllersTool loadingVieHide:self];
    NSDictionary *userInfo = [notify userInfo];
    AIABSearchResultViewController *controller = [[AIABSearchResultViewController alloc] init];
    controller.employees = userInfo[@"result"];
    controller.assistant = self.assistant;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)abContactReturnError:(NSNotification *)notify
{
    [AIControllersTool loadingVieHide:self];
    [AIControllersTool tipViewShow:@"服务器出错，请稍后重试"];
}

-(void)setUpBgScrollView
{
    self.view.backgroundColor = Controller_View_Color;
    
    _textField = [[UITextField alloc]initWithFrame:CGRectMake(15, 15, self.view.bounds.size.width - 30, 40)];
    
    [_textField setCustomPlaceholder:@"姓名/工号/电话/事业部"];
    _textField.font = [UIFont systemFontOfSize:14.5];
    _textField.textColor = AB_Gray_Color;
    _textField.layer.cornerRadius = 6.0;
    _textField.layer.masksToBounds=YES;
    _textField.layer.borderColor = Normal_Border_Color.CGColor;
    _textField.layer.borderWidth= 0.5f;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 12, 40)];
    view.backgroundColor = [UIColor clearColor];
    _textField.leftView = view;
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.backgroundColor = AB_White_Color;
    [self.view addSubview:_textField];
    
    
    _textFieldDepartment = [[UITextField alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(_textField.frame) + 15, self.view.bounds.size.width - 30, 40)];
    
    [_textFieldDepartment setCustomPlaceholder:@"公司/渠道/部门"];
    _textFieldDepartment.font = [UIFont systemFontOfSize:14.5];
    _textFieldDepartment.textColor = AB_Gray_Color;
    _textFieldDepartment.layer.borderColor = Normal_Border_Color.CGColor;
    _textFieldDepartment.layer.borderWidth= 0.5f;
    _textFieldDepartment.leftViewMode = UITextFieldViewModeAlways;
    _textFieldDepartment.backgroundColor = AB_White_Color;
    [self.view addSubview:_textFieldDepartment];
    
  
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button.layer setCornerRadius:6.0];
    button.frame = CGRectMake(15, CGRectGetMaxY(_textFieldDepartment.frame) + 15, self.view.bounds.size.width - 30, 40);
    button.titleLabel.font = [UIFont systemFontOfSize:17.0];
    button.backgroundColor = AB_Red_Color;
    button.tintColor = AB_White_Color;
    
    [button setTitle:@"搜索" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectContactInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
//下拉菜单
//    NSArray *keys = [NSArray arrayWithObjects:@"company",@"channel",@"department", nil];
//    for(NSInteger i=0;i<3;i++)
//    {
//        ABContactSelectView *comBox = [[ABContactSelectView alloc]initWithFrame:CGRectMake(15, 106+42*i, self.view.bounds.size.width - 30, 30)];
//        comBox.backgroundColor = [UIColor whiteColor];
//        comBox.arrowImgName = @"down_dark0.png";
//        NSMutableArray *itemsArray = [NSMutableArray arrayWithArray:[_addressDict objectForKey:[keys objectAtIndex:i]]];
//        comBox.titlesList = itemsArray;
//        comBox.delegate = self;
//        comBox.supView = self.view;
//        [comBox defaultSettings];
//        comBox.tag = kDropDownListTag + i;
//        [self.view addSubview:comBox];
//    }
    
    
}

#pragma mark -LMComBoxViewDelegate
-(void)selectAtIndex:(int)index inCombox:(ABContactSelectView *)_combox
{
    NSInteger tag = _combox.tag - kDropDownListTag;
    switch (tag) {
        case 0:
        {
            _selectedCompany =  [[_addressDict objectForKey:@"company"]objectAtIndex:index];
            //字典操作
            NSDictionary *tmp = [NSDictionary dictionaryWithDictionary: [_selectDic objectForKey: [NSString stringWithFormat:@"%d", index]]];
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [tmp objectForKey: _selectedCompany]];
            NSArray *channelArray = [dic allKeys];
            NSArray *sortedArray = [channelArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
                
                if ([obj1 integerValue] > [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;//递减
                }
                
                if ([obj1 integerValue] < [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;//上升
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i=0; i<[sortedArray count]; i++) {
                NSString *index = [sortedArray objectAtIndex:i];
                NSArray *temp = [[dic objectForKey: index] allKeys];
                [array addObject: [temp objectAtIndex:0]];
            }
            _channel = [NSArray arrayWithArray:array];
        
            NSDictionary *departmentDic = [dic objectForKey: [sortedArray objectAtIndex: 0]];
            _department = [NSArray arrayWithArray:[departmentDic objectForKey:[_channel objectAtIndex:0]]];
            //刷新市、区
            _addressDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           _company,@"company",
                           _channel,@"channel",
                           _department,@"department",nil];
            ABContactSelectView *channelCombox = (ABContactSelectView *)[self.view viewWithTag:tag + 1 + kDropDownListTag];
            channelCombox.titlesList = [NSMutableArray arrayWithArray:[_addressDict objectForKey:@"channel"]];
            [channelCombox reloadData];
            ABContactSelectView *departmentCombox = (ABContactSelectView *)[self.view viewWithTag:tag + 2 + kDropDownListTag];
            departmentCombox.titlesList = [NSMutableArray arrayWithArray:[_addressDict objectForKey:@"department"]];
            [departmentCombox reloadData];
            
            _selectedChannel = [_channel objectAtIndex:0];
            _selectedDepartment = [_department objectAtIndex:0];
            break;
        }
        case 1:
        {
            _selectedChannel = [[_addressDict objectForKey:@"channel"]objectAtIndex:index];
            
            NSString *companyIndex = [NSString stringWithFormat: @"%d", [_company indexOfObject: _selectedCompany]];
            NSDictionary *tmp = [NSDictionary dictionaryWithDictionary: [_selectDic objectForKey: companyIndex]];
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [tmp objectForKey: _selectedCompany]];
            NSArray *dicKeyArray = [dic allKeys];
            NSArray *sortedArray = [dicKeyArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
                
                if ([obj1 integerValue] > [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                if ([obj1 integerValue] < [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            NSDictionary *channelDic = [NSDictionary dictionaryWithDictionary: [dic objectForKey: [sortedArray objectAtIndex: index]]];
            NSArray *channelKeyArray = [channelDic allKeys];
            _department = [NSArray arrayWithArray:[channelDic objectForKey:[channelKeyArray objectAtIndex:0]]];
            //刷新区
            _addressDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           _company,@"company",
                           _channel,@"channel",
                           _department,@"department",nil];
            ABContactSelectView *departmentCombox = (ABContactSelectView *)[self.view viewWithTag:tag + 1 + kDropDownListTag];
            departmentCombox.titlesList = [NSMutableArray arrayWithArray:[_addressDict objectForKey:@"department"]];
            [departmentCombox reloadData];
            
            _selectedDepartment = [_department objectAtIndex:0];
            break;
        }
        case 2:
        {
            _selectedDepartment = [[_addressDict objectForKey:@"department"]objectAtIndex:index];
            break;
        }
        default:
            break;
    }
    
}

-(void)closeAllTheComBoxView
{
    for(UIView *subView in self.view.subviews)
    {
        if([subView isKindOfClass:[ABContactSelectView class]])
        {
            ABContactSelectView *combox = (ABContactSelectView *)subView;
            if(combox.isOpen)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    CGRect frame = combox.listTable.frame;
                    frame.size.height = 0;
                    [combox.listTable setFrame:frame];
                } completion:^(BOOL finished){
                    [combox.listTable removeFromSuperview];
                    combox.isOpen = NO;
                    combox.arrow.transform = CGAffineTransformRotate(combox.arrow.transform, DEGREES_TO_RADIANS(180));
                }];
            }
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_textField resignFirstResponder];
    [_textFieldDepartment resignFirstResponder];
    [self closeAllTheComBoxView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)selectContactInfo{
    //查询信息
    if (_textField.text == nil || [_textField.text isEqualToString:@""])
    {
        if (_textFieldDepartment.text == nil || [_textFieldDepartment.text isEqualToString:@""])
        {
            JLTipsView *tipView = [[JLTipsView alloc] initWithTip:@"请输入搜索关键字" ];
            [tipView showInView:[[UIApplication sharedApplication] keyWindow] animated:YES autoRelease:YES];
        }
    }
    else
    {
        self.progress = [[MBProgressHUD alloc]init];
        _progress.labelText = @"正在搜索...";
        _progress.dimBackground = YES;
        [_progress show:YES];
        [self.view addSubview:_progress];
        
        NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/search"];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        NSXMLElement *keytype=[NSXMLElement elementWithName:@"keytype" stringValue:@"ABSearch"];
        // NSLog(@"jid:%@",[[NSUserDefaults standardUserDefaults]stringForKey:@"jid"]);
        
        //id 随机生成（须确保无重复）
        // NSLog(@"*******%@",[IdGenerator next]);
        //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //    [defaults setObject:[IdGenerator next] forKey:@"IQ_Add_Roster"];
        
        
        [iq addAttributeWithName:@"type" stringValue:@"get"];
        [iq addAttributeWithName:@"id" stringValue:@"getContactInfoWithSearch"];
        
        NSXMLElement *key=[NSXMLElement elementWithName:@"key" stringValue:_textField.text ];
        NSXMLElement *book=[NSXMLElement elementWithName:@"book" ];
        NSXMLElement *agency=[NSXMLElement elementWithName:@"agency" ];
        NSXMLElement *branch=[NSXMLElement elementWithName:@"branch"];
        NSXMLElement *orgname=[NSXMLElement elementWithName:@"orgname" stringValue:_textFieldDepartment.text];
        //
        [queryElement addChild:keytype];
        [queryElement addChild:key];
        [queryElement addChild:book];
        [queryElement addChild:agency];
        [queryElement addChild:branch];
        [queryElement addChild:orgname];
        [iq addChild:queryElement];
        JLLog_I(@"search contact (iq=%@)", iq);
        [[XMPPServer xmppStream] sendElement:iq];
    }
   
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)showContactInfo:(NSNotificationCenter*) notify{
    
    NSDictionary* contactsDic = [notify valueForKey:@"object"];
    
    NSArray* allkeys = [contactsDic allKeys];
    
    NSArray* sortedArray = [allkeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        if ([(NSString*)obj1 intValue] > [(NSString*)obj2 intValue]) {
            return  NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    [_searchResults removeAllObjects];
    
    for (NSString* key in sortedArray) {
        UserInfo* contact = [[UserInfo alloc]init];
        [contact setValuesForKeysWithDictionary:contactsDic[key]];
        [_searchResults addObject:contact];
    }
    
    self.progress.hidden = YES;
    
    ABSelectedResultVC* resultVC = [[ABSelectedResultVC alloc]init];
    resultVC.resultArr = _searchResults;
    [self.navigationController pushViewController:resultVC animated:YES];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupNotifications];
}

- (void)tearNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:@"NNS_ContactInfo_Search" object:nil];
    [center removeObserver:self name:@"AI_AB_Contact_Search_Return" object:nil];
    [center removeObserver:self name:@"AI_AB_Contact_Search_Error" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self tearNotifications];
}
@end
