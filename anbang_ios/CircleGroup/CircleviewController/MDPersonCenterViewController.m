//
//  MDPersonCenterViewController.m
//  FriendQuanPro
//
//  Created by MyLove on 15/7/14.
//  Copyright (c) 2015年 Double_yang. All rights reserved.
//

#import "MDPersonCenterViewController.h"
#import "AFNetworking.h"
#import "UserInfoCRUD.h"
#import "UserInfo.h"
#import "ContactsCRUD.h"
#import "QuanDetailViewController.h"
#import "MBProgressHUD.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"

@interface MDPersonCenterViewController ()
{
    NSMutableArray * userArray;
    int page;
    BOOL isFirst;
}
@property (nonatomic, retain) MBProgressHUD * hub;
@end

@implementation MDPersonCenterViewController
@synthesize trendsTab;

- (void)startLoading
{
    if (!self.hub) {
        MBProgressHUD *hub = [[MBProgressHUD alloc] initWithView:self.view];
        hub.labelText = @"正在加载";
        [self.view addSubview:hub];
        self.hub = hub;
    }
    
    [self.hub show:YES];
    [self.view bringSubviewToFront:self.hub];
}

- (void)finishLoading
{
    if (!self.hub.hidden) {
        [self.hub hide:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitle.text = @"用户昵称";
    isFirst = NO;
    
    //添加一个通用的只读存储路径
    NSString * bundlePath = [[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:@"CustomPathImages"];
    [[SDImageCache sharedImageCache]addReadOnlyCachePath:bundlePath];
    

    NSString * jid = [NSString stringWithFormat:@"%@%@",[self.userDic objectForKey:@"pubuserid"],@"@ab-insurance.com"];
    UserInfo *userInfo = [UserInfoCRUD queryUserInfo:jid myJID:MY_JID];
    NSString * oneName = userInfo.nickName;
    self.navTitle.text = oneName;
    
    page = 1;
    userArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, IS_iOS7?64:44, Screen_Width, Screen_Height-(IS_iOS7?64:44))];
    mainView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainView];
    
    UIView * oneView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 40)];
    oneView.backgroundColor = [UIColor whiteColor];
    [mainView addSubview:oneView];
    
    trendsTab = [[UITableView alloc] init];
    trendsTab.frame = CGRectMake(0, 0, Screen_Width, mainView.frame.size.height);
    trendsTab.dataSource = self;
    trendsTab.delegate = self;
    trendsTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [mainView addSubview:trendsTab];
    
    //下拉刷新
    _header = [MJRefreshHeaderView header];
    _header.scrollView = trendsTab;
    _header.delegate = self;
    //上拉刷新
    _footer = [MJRefreshFooterView footer];
    _footer.scrollView = trendsTab;
    _footer.beginRefreshingBlock = ^(MJRefreshBaseView * refreshView){
        page = page+1;
        NSString * newString = [NSString stringWithFormat:@"%d",page];
        [self receiveQuanData:newString pageNums:@"10"];
    };
    
    [self cancelTableLeft20px:trendsTab];
    [self setExtraCellLineHidden:trendsTab];
    //判断是否有缓存
    NSDictionary * dataDic;
    NSArray * allArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"All_data"];
    for (int i=0; i<allArray.count; i++) {
        NSDictionary * dic = [allArray objectAtIndex:i];
        if ([[dic objectForKey:@"User_id"] isEqualToString:[self.userDic objectForKey:@"pubuserid"]]) {
            dataDic = [NSJSONSerialization JSONObjectWithData:[dic objectForKey:@"User_data"] options:NSJSONReadingMutableLeaves error:nil];
        }
    }
    if (dataDic) {
        NSArray * array = [dataDic objectForKey:@"data"];
        [userArray addObjectsFromArray:array];
        [trendsTab reloadData];
        isFirst = YES;
    }
    else{
        [self receiveQuanData:@"1" pageNums:@"10"];
    }
}

//刷新代理事件
-(void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    page = 1;
    NSString * newString = [NSString stringWithFormat:@"%d",page];
    [self receiveQuanData:newString pageNums:@"10"];
}

//获取数据
-(void)receiveQuanData:(NSString *)pages pageNums:(NSString *)pageNum
{
    if (isFirst == NO) {
        [self startLoading];
        isFirst = YES;
    }
    NSString * string = [NSString stringWithFormat:@"http://104.238.236.144//cfapi/friend?userid=%@&pagenum=%@&pagesize=%@",[self.userDic objectForKey:@"pubuserid"],pages,pageNum];
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    [manager POST:string parameters:nil success:^(AFHTTPRequestOperation * operation, id responseObject){
        [self finishLoading];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSDictionary * resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if (page == 1) {
            [userArray removeAllObjects];
        }
        if (![[resultDic objectForKey:@"data"] isKindOfClass:[NSNull class]]) {
            NSArray * array = [resultDic objectForKey:@"data"];
            if (page == 1) {
                //添加缓存数据
                NSArray * allArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"All_data"];
                NSMutableArray * muDicArray = [[NSMutableArray alloc]initWithCapacity:0];
                [muDicArray addObjectsFromArray:allArray];
                
                NSMutableDictionary * muDic = [NSMutableDictionary dictionary];
                [muDic setObject:[self.userDic objectForKey:@"pubuserid"] forKey:@"User_id"];
                [muDic setObject:responseObject forKey:@"User_data"];
                
                //遍历缓存，替换缓存
                int num;
                for (int i=0; i<muDicArray.count; i++) {
                    NSDictionary * temDic = [muDicArray objectAtIndex:i];
                    if ([[temDic objectForKey:@"User_id"] isEqualToString:[self.userDic objectForKey:@"pubuserid"]]) {
                        num = i;
                    }
                }
                if (num) {
                    [muDicArray replaceObjectAtIndex:num withObject:muDic];
                }
                else{
                    [muDicArray addObject:muDic];
                }
                //添加缓存
                [[NSUserDefaults standardUserDefaults]setObject:muDicArray forKey:@"All_data"];
                [[NSUserDefaults standardUserDefaults]synchronize];
//                //先清缓存
//                [self cleanMemory];
//                
//                //图片缓存
//                [self doRegister];
//                
//                [self doOrder];
            }
            
            [userArray addObjectsFromArray:array];
            [trendsTab reloadData];
        }
        [self endResh];
    } failure:^(AFHTTPRequestOperation *operation,NSError * orrer){
        [self finishLoading];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

//-(void)cleanMemory
//{
//    [[[SDWebImageManager sharedManager] imageCache] clearDisk];
//    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
//}
//
//-(void)doRegister{
//    [SDWebImageManager sharedManager].imageDownloader.username = @"httpwatch";
//    [SDWebImageManager sharedManager].imageDownloader.password = @"httpwatch01";
//}
//
//-(void)doOrder{
//    [SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
//    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
//}


#pragma mark    - UITableView  Deletate和Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return userArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float height = 0.0;
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    height = cell.frame.size.height;
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *GroupedTableIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             GroupedTableIdentifier];
    while ([cell.contentView.subviews lastObject] != nil) {
        [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
    }
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GroupedTableIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.contentView.backgroundColor = [UIColor whiteColor];
    NSDictionary * dic = [userArray objectAtIndex:indexPath.row];
    float height = 0.0;
    //说说内容
    NSString *wcontent = [dic objectForKey:@"content"];
    NSString *contentString = [NSString stringWithFormat:@"%@",wcontent];

    UIFont *labelfont = [UIFont systemFontOfSize:15];;
    CGSize csize = [self sizeForString:contentString font:labelfont size:CGSizeMake(Screen_Width-86, 1000)];
    if ([[dic objectForKey:@"content"] isKindOfClass:[NSNull class]]) {
        csize.height = 0.0;
    }
    //说说图片
    NSString * imageString;
    NSArray * imageArray;
    if (![[dic objectForKey:@"photolist"] isKindOfClass:[NSNull class]]) {
        imageString = [dic objectForKey:@"photolist"];
        imageArray = [imageString componentsSeparatedByString:@","];
        int hangNum = (imageArray.count/5)+1;
        if (imageArray.count == 5) {
            hangNum = 1;
        }
        height = csize.height+hangNum*((Screen_Width-55-26))/5+26;
    }
    else{
        height = csize.height+26;
    }
    
    //用户界面
    UIView *userView = [[UIView alloc] initWithFrame:CGRectMake(60, 10, Screen_Width-70, height-10)];
    userView.backgroundColor = RGBACOLOR(246, 243, 238, 1);
    [userView.layer setMasksToBounds:YES];
    [userView.layer setCornerRadius:1.0];
    [cell.contentView addSubview:userView];
    
    //内容
    UILabel *lblContent = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, Screen_Width-86, csize.height)];
    lblContent.font = labelfont;
    lblContent.textColor = RGBACOLOR(112, 108, 108, 1);
    lblContent.text = contentString;
    lblContent.numberOfLines = 0;
    lblContent.backgroundColor = [UIColor clearColor];
    [userView addSubview:lblContent];
    float tempNum = ((Screen_Width-55-26))/5;
    //添加图片
    if (imageArray.count>0) {
        for (int i=0; i<imageArray.count; i++) {
            int hang = i%5;
            int lie = i/5;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8+tempNum*hang, lblContent.frame.size.height+13+tempNum*lie, tempNum-5, tempNum-5)];
            imageView.backgroundColor = RGBACOLOR(34, 34, 34, 1);
            [imageView setImageWithURL:[NSURL URLWithString:[imageArray objectAtIndex:i]] placeholderImage:nil];
//            [imageView setImageWithURL:[NSURL URLWithString:[imageArray objectAtIndex:i]] placeholderImage:nil options:indexPath.row ==0 ? SDWebImageRefreshCached:0 ];

            [userView addSubview:imageView];
        }
    }
    
    //时间
    UILabel *lblTime= [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 55, 20)];
    lblTime.textAlignment = NSTextAlignmentRight;
    lblTime.text = [dic objectForKey:@"pubtime"];
    lblTime.textColor = RGBACOLOR(151, 151, 151, 1);
    lblTime.font = [UIFont systemFontOfSize:13.0f];
    lblTime.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:lblTime];
    
    CGRect rect = cell.frame;
    rect.size.height = height;
    cell.frame = rect;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = [userArray objectAtIndex:indexPath.row];
    QuanDetailViewController * dvc = [[QuanDetailViewController alloc]init];
    dvc.detailDic = dic;
    [self.navigationController pushViewController:dvc animated:YES];
}


#pragma mark - 表格:UITableView
//覆盖列表多余行数
- (void)setExtraCellLineHidden: (UITableView *)tableView{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}

//消除表格左侧的20px
-(void)cancelTableLeft20px:(UITableView *)tableView{
    if(IS_iOS7){
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)])
            [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}

//表信息重载
-(void)tableViewOverLoad:(UITableViewCell *)cell{
    while (cell.contentView.subviews.lastObject)
        [cell.contentView.subviews.lastObject removeFromSuperview];
}

#pragma mark - 动态计算高度和宽度
-(CGSize)sizeForString:(NSString *)string font:(UIFont *)font size:(CGSize)size{
    CGSize newSize;
    if(IS_iOS7){
        CGRect newRect = [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil];
        newSize = newRect.size;
    }else{
        newSize = [string sizeWithFont:font constrainedToSize:size];
    }
    return newSize;
}

-(void)endResh
{
    [_header endRefreshing];
    [_footer endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
