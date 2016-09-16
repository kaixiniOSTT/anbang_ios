//
//  AddressBookViewController.m
//  anbang_ios
//
//  Created by seeko on 14-4-21.
//  Copyright (c) 2014年 ch. All rights reserved.
//
//  通讯录

#import "AddressBookViewController.h"
#import "TKAddressBook.h"
#import "SendSMSViewController.h"
#import "AddressBookCRUD.h"
#import "PinYinForObjc.h"
#import "PublicCURD.h"


@interface AddressBookViewController ()
{
    FMDatabase *db;
    UITableView *tb;
    NSMutableArray *addressBookTemp;
    TKAddressBook *addressBook;
    NSMutableArray *arrName;
    __block BOOL accessGranted;
    
    NSMutableArray *arrSqlAddress;
}
//@property(nonatomic, copy) NSArray *famousPersons;
@property(nonatomic, copy) NSArray *filteredPersons;
@property(nonatomic, copy) NSArray *sections;
@property(nonatomic, strong) UISearchDisplayController *strongSearchDisplayController;
@end

@implementation AddressBookViewController
@synthesize sectionsArray,collation;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectionVer) name:@"NNS_Detection_Ver" object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //通讯录
    self.title = NSLocalizedString(@"addressBook.title",@"title");
    
    //    [self obtainAddressBook];
    //    //新建一个通讯录类
    //    addressBookTemp=[[NSMutableArray alloc]initWithObjects: nil];
    //    arrName=[[NSMutableArray alloc]initWithObjects: nil];
    
    ABAddressBookRef addressBooks = nil;
    accessGranted = NO;

    addressBooks =  ABAddressBookCreateWithOptions(NULL, NULL);
    //获取通讯录权限
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error){
        dispatch_semaphore_signal(sema);
        accessGranted=granted;
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    //dispatch_release(sema);
        
    
    
    
    //        else{
    //            //获取通讯录中的所有人
    //            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    //            //通讯录中人数
    //            CFIndex nPeople = ABAddressBookGetPersonCount(addressBooks);
    //
    //            //循环，获取每个人的个人信息
    //            for (NSInteger i = 0; i < nPeople; i++)
    //            {
    //                //新建一个addressBook model类
    //                addressBook = [[TKAddressBook alloc] init];
    //                //获取个人
    //                ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
    //                //获取个人名字
    //                CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    //                CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
    //                CFStringRef abFullName = ABRecordCopyCompositeName(person);
    //                NSString *nameString = (__bridge NSString *)abName;
    //                NSString *lastNameString = (__bridge NSString *)abLastName;
    //                if ((__bridge id)abFullName != nil) {
    //                    nameString = (__bridge NSString *)abFullName;
    //                } else {
    //                    if ((__bridge id)abLastName != nil)
    //                    {
    //                        nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastNameString];
    //                    }
    //                }
    //                if ((__bridge id)abFullName == nil&&(__bridge id)abLastName == nil) {
    //                    nameString=@"未备注";
    //                }
    //                addressBook.name = nameString;
    //                addressBook.recordID = (int)ABRecordGetRecordID(person);;
    //                ABPropertyID multiProperties[] = {
    //                    kABPersonPhoneProperty,
    //                    kABPersonEmailProperty
    //                };
    //                NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
    //                for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
    //                    ABPropertyID property = multiProperties[j];
    //                    ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
    //                    NSInteger valuesCount = 0;
    //                    if (valuesRef != nil) valuesCount = ABMultiValueGetCount(valuesRef);
    //
    //                    if (valuesCount == 0) {
    //                        CFRelease(valuesRef);
    //                        continue;
    //                    }
    //                    //获取电话号码和email
    //                    for (NSInteger k = 0; k < valuesCount; k++) {
    //                        CFTypeRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
    //                        switch (j) {
    //                            case 0: {// Phone number
    //                                addressBook.tel = (__bridge NSString*)value;
    //                                break;
    //                            }
    //                            case 1: {// Email
    //                                addressBook.email = (__bridge NSString*)value;
    //                                break;
    //                            }
    //                        }
    //                        CFRelease(value);
    //                    }
    //                    CFRelease(valuesRef);
    //                }
    //                //将个人信息添加到数组中，循环完成后addressBookTemp中包含所有联系人的信息
    //                [addressBookTemp addObject:addressBook];
    //                [arrName addObject:addressBook.name];
    //                if (abName) CFRelease(abName);
    //                if (abLastName) CFRelease(abLastName);
    //                if (abFullName) CFRelease(abFullName);
    //
    //            }
    //        }
    
    [self selectAddressBook];
    
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSMutableArray *unsortedSections = [[NSMutableArray alloc] initWithCapacity:[[collation sectionTitles] count]];
    for (NSUInteger i = 0; i < [[collation sectionTitles] count]; i++) {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    for (NSString *personName in arrName) {
        NSInteger index = [collation sectionForObject:personName collationStringSelector:@selector(description)];
        [[unsortedSections objectAtIndex:index] addObject:personName];
    }
    
    NSMutableArray *sortedSections = [[NSMutableArray alloc] initWithCapacity:unsortedSections.count];
    for (NSMutableArray *section in unsortedSections) {
        [sortedSections addObject:[collation sortedArrayFromArray:section collationStringSelector:@selector(description)]];
    }
    
    self.sections = sortedSections;
    //CFRelease(addressBook);
    
    [self ui];
    
}


-(void)selectAddressBook{
    
    addressBookTemp=[[NSMutableArray alloc]init];
    arrName=[[NSMutableArray alloc]init];
    //NSString *myjid=[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    //silencesky 修改
    
    NSString *database_path = [[NSUserDefaults standardUserDefaults]objectForKey:SQLITE_DB_PATH];
    db =  [FMDatabase databaseWithPath:database_path];
    
    if ([db open]) {
        NSString *selectSqlStr=[NSString stringWithFormat:@"select name,phoneNum,jid from AddressBook where myjid=\"%@\"",MY_JID];
        FMResultSet * rs = [db executeQuery:selectSqlStr];
        while ([rs next]) {
            
            NSString *name=[rs stringForColumn:@"name"];
            NSString *phoneNum=[rs stringForColumn:@"phoneNum"];
            NSString *jid=[rs stringForColumn:@"jid"];
            
            addressBook =[[TKAddressBook alloc]init];
            addressBook.name=name;
            addressBook.tel=phoneNum;
            addressBook.jid=jid;
            [addressBookTemp addObject:addressBook];
            //[addressBook release];
            //            [addressBookTemp addObject:[NSDictionary dictionaryWithObjectsAndKeys:name,@"name",phoneNum, @"phoneNum",jid,@"jid", nil]];
            [arrName addObject:name];
            
        }
        [rs close];
    }
    [db close];
}

-(void)ui{
    //CGRect rect=[[UIScreen mainScreen]bounds];
    if (!accessGranted) {
        //应用权限限制,需要进入“系统设置->隐私->通讯录“开启通讯录权限许可后才能使用
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"addressBook.authorizedPromptMsg",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"action") otherButtonTitles:nil, nil];
        [alert show];
    }
    
    if(accessGranted) {
        tb=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight-Both_Bar_Height)];
        [self.view addSubview:tb];
        tb.delegate=self;
        tb.dataSource=self;
        _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        //    [_searchBar setSearchBarStyle:UISearchBarStyleDefault];
        if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
            //            _searchBar.searchBarStyle=UISearchBarStyleDefault;
        }else{
            
        }
        //[tb addSubview:_searchBar];
        // tb.tableHeaderView=_searchBar;
        //_searchBar.delegate = self;
        
        //[_searchBar sizeToFit];
        
        _strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        self.searchDisplayController.searchResultsDataSource = self;
        self.searchDisplayController.searchResultsDelegate = self;
        self.searchDisplayController.delegate = self;
    }
    else{
        UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height/2, self.view.frame.size.width, 40)];
        lab.textAlignment=NSTextAlignmentCenter;
        //未获取通讯录权限,无法使用该功能
        lab.text=NSLocalizedString(@"addressBook.authorizedPromptMsg2",@"title");
        lab.textColor=[UIColor lightGrayColor];
        [self.view addSubview:lab];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    NSAssert(YES, @"This method should be handled by a subclass!");
}

#pragma mark - TableView Delegate and DataSource
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == tb) {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    } else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == tb) {
        if ([[self.sections objectAtIndex:section] count] > 0) {
            return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString:UITableViewIndexSearch]) {
        [self scrollTableViewToSearchBarAnimated:NO];
        return NSNotFound;
    } else {
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index]-1; // -1 because we add the search symbol
    }
}

//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView ==tb) {
        return self.sections.count;
        
    } else {
        return 1;
    }
}

//列数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == tb) {
        return [[self.sections objectAtIndex:section] count];
    } else {
        return self.filteredPersons.count;
    }
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//        return 5;
//}
//cell内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"ContactCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor=[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1];
    
    if (tableView==tb) {
        for (int i=0; i<[addressBookTemp count]; i++) {
            TKAddressBook *book = [addressBookTemp objectAtIndex:i];
            if(book.name!=nil){
                //                NSLog(@"book:%@",book.name);
                //                NSLog(@"name:%@",[[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]);
                if([[[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isEqualToString: book.name])
                {
                    cell.textLabel.text = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.detailTextLabel.text = book.tel;
                    //                    NSLog(@"%@%@",book.name,book.jid);
                    if ([book.jid isEqualToString:@""]) {
                        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(240, 10, 20, 20)];
                        //                        imageView.image=[UIImage imageNamed:@"logo.png"];
                        [imageView setBackgroundColor:[UIColor whiteColor]];
                        [cell addSubview:imageView];
                    }else{
                        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(240, 10, 20, 20)];
                        imageView.image=[UIImage imageNamed:@"Icon.png"];
                        [cell addSubview:imageView];
                    }
                    
                }
            }else{
                cell.textLabel.text=book.tel;
            }
            
        }
        
    }else{
        cell.textLabel.text=[self.filteredPersons objectAtIndex:indexPath.row];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //    SendSMSViewController *sendSMS=[[SendSMSViewController alloc]init];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    for (int i=0; i<[addressBookTemp count]; i++) {
        TKAddressBook *book = [addressBookTemp objectAtIndex:i];
        if([cell.textLabel.text isEqualToString: book.name])
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NNC_AddressBook_PhoneNum"object:book.tel];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    //    [self.navigationController pushViewController:sendSMS animated:YES];
    //    [sendSMS release];
}
#pragma mark - Search Delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.filteredPersons = arrName;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.filteredPersons = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.filteredPersons = arrName;
    NSString *search=[PinYinForObjc chineseConvertToPinYin:searchString];
    self.filteredPersons = [self.filteredPersons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", search]];
    return YES;
}

-(void)dealloc{
    
}
@end
