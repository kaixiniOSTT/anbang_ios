//
//  InvitationURLViewController2.m
//  anbang_ios
//
//  Created by silenceSky  on 14-8-18.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "InvitationURLViewControllerNew.h"
#import "ChooseCircleViewController.h"
#import "QrCodeViewController.h"

@interface InvitationURLViewControllerNew ()

@end

@implementation InvitationURLViewControllerNew
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Country_Code" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Country_Name" object:nil];
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressbookPhoneNum:) name:@"NNC_AddressBook_PhoneNum" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countryName:) name:@"NNC_Country_Name" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countryCode:) name:@"NNC_Country_Code" object:nil];
    
    // Do any additional setup after loading the view from its nib.
    _tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollsToTop = YES;
    [self.view addSubview:_tableView];
    //[_tableView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
    [self setExtraCellLineHidden:_tableView];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [_tableView setSeparatorInset:(UIEdgeInsetsMake(0, 0, 0, 0))];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ([cell viewWithTag:10001]) {
        [[cell viewWithTag:10001] removeFromSuperview];
    }
    
    if (indexPath.row==0) {
        
        cell.textLabel.text = NSLocalizedString(@"contacts.urlToInvite.tableViewTitle",@"title");
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.frame = CGRectMake(0 , 0, 300, 50);
        cell.textLabel.numberOfLines =0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        
    }else if(indexPath.row==1){
        cell.textLabel.text= NSLocalizedString(@"contacts.urlToInvite.circleQrCode",@"action");
        UILabel *countryLabel = [[UILabel alloc]initWithFrame:CGRectMake(KCurrWidth-220, 0, 200, 55)];
        countryLabel.textAlignment = NSTextAlignmentCenter;
        countryLabel.tag= 10001;
        [cell addSubview:countryLabel];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if(indexPath.row==2){
        cell.textLabel.text= NSLocalizedString(@"contacts.urlToInvite.myQrCode",@"action");
        UILabel*groupLabel = [[UILabel alloc]initWithFrame:CGRectMake(KCurrWidth-220, 0, 200, 55)];
        
        //groupLabel.text= [NSString stringWithFormat:@"+%@ %@",_countryCode,_countryName];
        groupLabel.textAlignment = NSTextAlignmentCenter;
        groupLabel.tag= 10001;
        [cell addSubview:groupLabel];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
    }else if(indexPath.row==3){
        
    }else if(indexPath.row==4){
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        
    }else{
        
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSUInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    if (section==0 && row==1) {
        [self joinCircle];
    }else if (section==0 && row==2) {
        [self myQrcode];
    }
}



//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
    
}



-(void)joinCircle{
    
    ChooseCircleViewController *chooseCirceleView=[[ChooseCircleViewController alloc]init];
    chooseCirceleView.fromFlag = @"Qrcode";
    chooseCirceleView.delegate=self;
    [self.navigationController pushViewController:chooseCirceleView animated:YES];
}

#pragma mark ChooseCircleViewDelegate
-(void)setCellValue:(NSString *)string groundJID:(NSString *)groundJID{
    
}



-(void)myQrcode{
    
    //个人二维码
    QrCodeViewController *qrCodeView=[[QrCodeViewController alloc]init];
    qrCodeView.title=NSLocalizedString(@"contacts.urlToInvite.myQrCode",@"title");
    if ([[NSUserDefaults standardUserDefaults]stringForKey:@"name"].length>0){
        qrCodeView.labNmaetext =[[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
    }else{
        qrCodeView.labNmaetext=[[NSUserDefaults standardUserDefaults]stringForKey:@"userName"];
    }
    [self.navigationController pushViewController:qrCodeView animated:YES];
}

@end
