//
//  SystemInformsViewController.m
//  anbang_ios
//
//  Created by seeko on 14-6-7.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "SystemMessageViewController.h"
#import "CHAppDelegate.h"
#import "SystemMessageCRUD.h"
#import "ChangePasswordViewController.h"
#import "Utility.h"
#import "AIUIWebViewController.h"
#import "RCLabel.h"

@implementation SystemMessageViewController
@synthesize sendName = _sendName;
@synthesize sendTitle = _sendTitle;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - life circle
-(void)loadView{
    [super loadView];
}

-(void)dealloc{

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if(![StrUtility isBlankString:_sendTitle]){
        self.title = _sendTitle;
    } else {
        self.title=NSLocalizedString(@"public.system.systemPrompt",@"title");
    }
    
    //设置信息代理
    [XMPPServer sharedServer].messageDelegate = self;
    
    systemMessageArr=[[NSMutableArray alloc]init];
    mHeightDictionary = [NSMutableDictionary  dictionary];
    mPageCount = 5;
    mTotal = 5;
    [self selectSystemFromStart:0 total:mTotal];
   // NSLog(@"****%d",systemMessageArr.count);
    [self updateSystem];
    self.tableView =[[UITableView alloc]init];
    self.tableView.frame=CGRectMake(0, 0, Screen_Width, KCurrHeight - Both_Bar_Height);
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.backgroundColor = Controller_View_Color;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 20)];
    
    
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[systemMessageArr count]-1 inSection:0]atScrollPosition: UITableViewScrollPositionBottom animated:YES];
    
    //下拉刷新
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor lightGrayColor];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"  "];
    [refresh addTarget:self action:@selector(loadDataUp:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)loadDataUp:(id)sender{
    mTotal += mPageCount;
    
    [self selectSystemFromStart:0 total:mTotal];
    
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

-(void)selectSystemFromStart:(int)start total:(int)total
{
    [systemMessageArr removeAllObjects];
    
    NSArray *datasource = [SystemMessageCRUD selectSytemMessage:_sendName myUserName:MY_USER_NAME start:start total:total];
    
    for(NSDictionary *dict in datasource){
        NSMutableDictionary *new = [NSMutableDictionary dictionaryWithDictionary:dict];

        [systemMessageArr insertObject:new atIndex:0];
    }
    
    //systemMessageArr = [SystemMessageCRUD selectSytemMessage:_sendName myUserName:MY_USER_NAME];
}


-(void)updateSystem{
    [SystemMessageCRUD updataSytemMessageSendName:_sendName myUserName:MY_USER_NAME readMark:@"1"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateSystem];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self updateSystem];
}


#pragma mark KKMessageDelegate
-(void)newMessageReceived:(NSDictionary *)messageCotent
{
    [self selectSystemFromStart:0 total:mTotal];

    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[systemMessageArr count]-1 inSection:0] atScrollPosition: UITableViewScrollPositionBottom animated:YES];
}


#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [systemMessageArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[systemMessageArr[indexPath.row] objectForKey:@"height"] floatValue] + 81;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
//    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    UITableViewCell *cell= [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    if ([systemMessageArr count]>0) {
        NSMutableDictionary *dicsyStemMessage=[systemMessageArr objectAtIndex:[indexPath row]];
        
        // Set up the cell...
        NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *sendTimeUtc = [Utility dateFromUtcString:dicsyStemMessage[@"time"]];
        NSDate * sendTime = [Utility getNowDateFromatAnDate:sendTimeUtc];
        NSString *sendTimeStr = [formatter stringFromDate:sendTime];
        NSString *timeString = [Utility friendlyTime: sendTimeStr];
        
        CGSize labTimeSize = [timeString sizeWithFont:AB_FONT_12 constrainedToSize:CGSizeMake(Screen_Width - 64, 21) lineBreakMode:NSLineBreakByCharWrapping];
        UILabel *labTimeSystemMessage=[[UILabel alloc]init];
        labTimeSystemMessage.frame=CGRectMake((Screen_Width - labTimeSize.width - 32)/2, 0, labTimeSize.width + 32, 21);
        labTimeSystemMessage.textAlignment=NSTextAlignmentCenter;
        labTimeSystemMessage.font = AB_FONT_12;
        labTimeSystemMessage.textColor= AB_Color_ffffff;
        labTimeSystemMessage.backgroundColor = AB_Color_d3d1cd;
        labTimeSystemMessage.layer.cornerRadius = 10.0f;
        labTimeSystemMessage.layer.masksToBounds = YES;

        
        labTimeSystemMessage.text= timeString;
        
        [cell addSubview:labTimeSystemMessage];
        
        NSString *msg = dicsyStemMessage[@"msg"];
        
        RCLabel *systemMessageLab=[[RCLabel alloc] initWithFrame:CGRectMake(0, 0, Screen_Width - 64, 1000000)];
        systemMessageLab.font = AB_FONT_15;
        systemMessageLab.delegate = self;
        systemMessageLab.textColor= AB_Color_5b5752;
        //systemMessageLab.layer.borderWidth = 1.0;
        //systemMessageLab.layer.borderColor = [[UIColor blackColor] CGColor];
        systemMessageLab.userInteractionEnabled = YES;
        
        systemMessageLab.componentsAndPlainText = [RCLabel extractTextStyle:msg];
        
        CGSize optimalSize = [systemMessageLab optimumSize];   //计算图文混排后的高度
        
        CGFloat height = optimalSize.height;
        dicsyStemMessage[@"height"] = [NSNumber numberWithFloat:height];
        JLLog_D(@"height = %f", height);
        
        [systemMessageLab setFrame:CGRectMake(32, 41, Screen_Width - 64, height)];
        
        UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bubble-flat-incoming" ofType:@"png"]];
        UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
        bubbleImageView.frame=CGRectMake(16, 31, Screen_Width - 32, height + 20);
        bubbleImageView.backgroundColor = AB_Color_ffffff;
        bubbleImageView.layer.cornerRadius = 3.0f;
        bubbleImageView.layer.borderColor = [AB_Color_e7e2dd CGColor];
        bubbleImageView.layer.borderWidth = 1.0f;
        [cell addSubview:bubbleImageView];
        [cell addSubview:systemMessageLab];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSString*)url
{
    AIUIWebViewController *controller = [[AIUIWebViewController alloc] init];
    controller.url = url;
    controller.usingToken = YES;
    controller.usingCache = NO;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}


- (NSString *)stringFromDate:(NSDate *)date
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
    
}


- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}

@end
