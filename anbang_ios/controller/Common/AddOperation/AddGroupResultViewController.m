//
//  AddGroupResultViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 14-10-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "AddGroupResultViewController.h"
#import "DejalActivityView.h"
#import "StrUtility.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

@interface AddGroupResultViewController ()

@end

@implementation AddGroupResultViewController
{
    NSString *_circleJID;
    NSString *_circleName;
    NSString *_size;
    BOOL _isFull;
    NSArray *_members;
}

- (void)setCircleInformation:(NSDictionary *)circleInformation {
    _circleInformation = circleInformation;
    _circleJID = circleInformation[@"jid"];
    _circleName = circleInformation[@"name"];
    _size = circleInformation[@"size"];
    _members = circleInformation[@"members"];
    _isFull = [circleInformation[@"isFull"] boolValue];
    _circleName = ![StrUtility isBlankString:_circleName] ? _circleName : @"群聊";
}

- (void)setupNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(joinGroupSucceed:)
                   name:@"NNC_Received_Group"
                 object:nil];
    [center addObserver:self
               selector:@selector(joinGroupError:)
                   name:@"AI_Joining_Group_Error"
                 object:nil];
}

- (UIView *)gIconView {
    UIView *v = [[UIView alloc] init];
    v.bounds = (CGRect){CGPointZero, CGSizeMake(92.5, 92.5)};
    v.backgroundColor = AB_Color_ffffff;
    
    CGFloat margin = 2;
    int numOfRow = 3;
    CGPoint original = CGPointMake(3, 3);
    CGFloat iv_wh = 82.5 / 3;
    for (int i = 0; i < _members.count; ++i) {
        
        if (i > 9) {
            
            break;
            
        }else {
        UIImageView *iv = [[UIImageView alloc] init];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        CGFloat x = original.x + (iv_wh + margin) * (i % numOfRow);
        CGFloat y = original.y + (iv_wh + margin) * (i / numOfRow);
        iv.frame = (CGRect){CGPointMake(x, y), CGSizeMake(iv_wh, iv_wh)};
        [v addSubview:iv];
        
        NSDictionary *d = _members[i];
        NSString *urlString = [NSString stringWithFormat:@"%@/%@", ResourcesURL, d[@"avatar"]];
        [iv setImageWithURL:[NSURL URLWithString:urlString]
           placeholderImage:[UIImage imageNamed:@"icon_defaultPic.png"]];
        }
    }
    return v;
}

- (void)setupInterface {
    // Icon view
    UIView *v = [self gIconView];
    CGFloat v_center_x = Screen_Width / 2;
    CGFloat v_center_y = 50 + 92.5 / 2;
    v.center = CGPointMake(v_center_x, v_center_y);
    
    // name(size) Label
    NSString *text = [NSString stringWithFormat:@"%@（%@人）", _circleName, _size];
    CGSize l_size = [text sizeWithFont:AB_FONT_16_B];
    CGFloat l_cneter_y = CGRectGetMaxY(v.frame) + 18 + l_size.height/2;
    UILabel *l = [[UILabel alloc] init];
    l.font = AB_FONT_16_B;
    l.text = text;
    l.backgroundColor = [UIColor clearColor];
    l.bounds = (CGRect){CGPointZero, l_size};
    l.center = CGPointMake(v_center_x, l_cneter_y);
    
    // join button
    CGSize b_size = CGSizeMake(Screen_Width - 60, 45);
    CGFloat b_center_y = CGRectGetMaxY(l.frame) + 33 + b_size.height / 2;
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.bounds = (CGRect){CGPointZero, b_size};
    b.center = CGPointMake(v_center_x, b_center_y);
    b.backgroundColor = AB_Color_e55a39;
    b.titleLabel.font = AB_FONT_16;
    b.layer.masksToBounds = YES;
    b.layer.cornerRadius = 3.0;
    [b setTitleColor:AB_Color_ffffff forState:UIControlStateNormal];
    [b setTitle:@"加入该群聊" forState:UIControlStateNormal];
    [b addTarget:self action:@selector(join:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:v];
    [self.view addSubview:l];
    [self.view addSubview:b];
    
    self.view.backgroundColor = AB_Color_f6f2ed;
}

- (void)setupNavigationItem {
    self.navigationItem.leftBarButtonItems = @[[[AIFlixBarButtonItem alloc] initWithWidth:-8.0],
                                               [[AIBackBarButtonItem alloc] initWithTitle:@"返回"
                                                                                   target:self
                                                                                   action:@selector(popToRootViewController)]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupNavigationItem];
    [self setupInterface];
    [self setupNotifications];
}

#pragma mark
#pragma mark (private)

- (void)join:(UIButton *)sender {
    [self addGroupMemberSendIQ];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)popToRootViewController {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)afterDelay {
    MBProgressHUD *hub = [MBProgressHUD HUDForView:self.view];
    if (hub) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [AIControllersTool tipViewShow:@"请求超时，请稍后重试"];
    }
}

- (void)joinGroupSucceed:(NSNotification *)n {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self popToRootViewController];
}

- (void)joinGroupError:(NSNotification *)n {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)addGroupMemberSendIQ{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/admin"];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
        NSXMLElement *members = [NSXMLElement elementWithName:@"members"];
        
        [iq addAttributeWithName:@"to" stringValue:GroupDomain];
        
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        
        [circle addAttributeWithName:@"jid" stringValue:_circleJID];
        [circle addAttributeWithName:@"name" stringValue:_circleInformation[@"name"]];
        
        NSString *memberName = @"";
        if ([[NSUserDefaults standardUserDefaults]stringForKey:@"name"].length > 0) {
            memberName=[[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
        }else{
            memberName =[[NSUserDefaults standardUserDefaults]stringForKey:@"userName"];
        }
        NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
        [member addAttributeWithName:@"jid" stringValue:MY_JID];
        [member addAttributeWithName:@"role" stringValue:@"member"];
        [member addAttributeWithName:@"nickname" stringValue:memberName];
        [members addChild:member];
        
        [iq addChild:queryElement];
        [queryElement addChild:circle];
        [circle addChild:members];
        
        [[XMPPServer xmppStream] sendElement:iq];
    });
}



//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//-(void)dealloc{
//    
//}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//
//    
//    self.title = NSLocalizedString(@"circleInfo.title",@"title");
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"public.back",@"title") style:UIBarButtonItemStyleBordered target:self action:@selector(popToRootView)];
//    
//    
//    int cutHeight=0;
//    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
//        cutHeight=64;
//    }else  {
//        cutHeight=64;
//    }
//    
//    
//    _tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-cutHeight) style:UITableViewStyleGrouped];
//    
//    // _myTableView.scrollEnabled = YES;
//    // 设置tableView的数据源
//    _tableView.dataSource = self;
//    // 设置tableView的委托
//    _tableView.delegate = self;
//    // 设置tableView的背景图
//    // tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
//    // self.myTableView = tableView;
//    [self.view addSubview:_tableView];
//    
//}



//#pragma mark -
//#pragma mark Table View Data Source Methods
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    //这个方法用来告诉表格有几个分组
//    return 4;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    //这个方法告诉表格第section个分组有多少行
//    int row=0;
//    if(section==0)
//        row=1;
//    else if(section==1){
//        row=1;
//    }
//    return row;
//}
//
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 1) {
//        return @"";
//    }
//    return @"";
//}
//
//
//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
//    if(section == 2){
//        
//        return @"";
//    }else
//        return @"";
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    //    //这个方法用来告诉某个分组的某一行是什么数据，返回一个UITableViewCell
//    NSUInteger section = [indexPath section];
//    NSUInteger row = [indexPath row];
//    static NSString *GroupedTableIdentifier = @"TableSampleIdentifier";
//    // UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GroupedTableIdentifier] autorelease];
//    
//    //这种为不复用
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GroupedTableIdentifier];
//    if (cell == nil) {
//        cell = cell;
//    }else{
//        
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GroupedTableIdentifier];
//    }
//    
//    
//    if(section==0&&row==0){
//        
//        cell.textLabel.text = @"";
//        cell.textLabel.frame = CGRectMake(0, 0, KCurrWidth, 80);
//        cell.textLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"circleInfo.circleName",@"title"),_groupName];
//        cell.textLabel.backgroundColor = [UIColor clearColor];
//        
//        
//    }else if(section==1 && row==0){
//        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, cell.frame.size.height)];
//        label.backgroundColor = [UIColor clearColor];
//        label.textColor = [UIColor whiteColor];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.text =NSLocalizedString(@"circle.joinCircle",@"title");
//        [cell addSubview:label];
//        cell.backgroundColor = kMainColor;
//        
//    }
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSUInteger section = [indexPath section];
//    NSInteger row = [indexPath row];
//    //NSLog(@"%d,%d",section,row);
//    if (section==0 && row==0) {
//        //跳转个人信息页
//        
//    }else if(section==1&&row==0){
//        [self addGroupMemberSendIQ];
//        
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    
//    return 10;
//}
//
//- (NSString *)stringFromDate:(NSDate *)date{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//    NSString *destDateString = [dateFormatter stringFromDate:date];
//    return destDateString;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSUInteger section = [indexPath section];
//    
//    if ([ indexPath indexAtPosition: 1 ] == 0 && section ==0)
//        return 80.0;
//    else
//        return 50.0;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
