//
//  FKRSearchBarTableViewController.m
//  TableViewSearchBar
//
//  Created by Fabian Kreiser on 10.02.13.
//  Copyright (c) 2013 Fabian Kreiser. All rights reserved.
//

#import "FKRSearchBarTableViewController.h"
#import "PhoneNumRegisteredViewController.h"


static NSString * const kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier = @"kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier";

@interface FKRSearchBarTableViewController () {
    NSArray *array;             //code＋name＋spelling
    NSMutableArray *arrayName;
    NSMutableArray *arrayCode;
    NSMutableArray *arraySpelling;
}

@property(nonatomic, copy) NSArray *filteredPersons;
@property(nonatomic, copy) NSArray *sections;

@property(nonatomic, strong, readwrite) UITableView *tableView;
@property(nonatomic, strong, readwrite) UISearchBar *searchBar;

@property(nonatomic, strong) UISearchDisplayController *strongSearchDisplayController;
@end

@implementation FKRSearchBarTableViewController

#pragma mark - Initializer

//读取XML文件
-(void)loadingChineseInternationCode{
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"NSUD_language"] isEqualToString:@"en"]) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"english_international_code" ofType:@"xml"];
        NSString *xmlPath = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        // NSString *string=[xmlPath stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *strOneController=[xmlPath stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        array=[strOneController componentsSeparatedByString:@","];
        [self loadEnCode];
        [self loadEnName];
        [self loadEnSpelling];
        
    }else{
        NSString * path = [[NSBundle mainBundle] pathForResource:@"chinese_international_code" ofType:@"xml"];
        NSString *xmlPath = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSString *string=[xmlPath stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *strOneController=[string stringByReplacingOccurrencesOfString:@":" withString:@""];
        array=[strOneController componentsSeparatedByString:@","];
        [self loadingCode];
        [self loadingName];
        [self loadingSpelling];
        
    }
    
}
//读取国际手机区号
-(void)loadingCode{
    arrayCode=[[NSMutableArray alloc]initWithObjects:@"", nil];
    for (int i=1; i<[array count]; i++) {
        
        NSString *_str=[array objectAtIndex:i];
        //中文
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *aarray =    nil;
        aarray = [regex matchesInString:_str options:0 range:NSMakeRange(0, [_str length])];
        //*****************************************
        NSString *str1 =@"";
        NSString *aasd=@"";
        NSString *aaaa=@"";
        for (NSTextCheckingResult* b in aarray)
        {
            aasd=[aasd stringByAppendingString:str1];
            str1 = [_str substringWithRange:b.range];
            aaaa=[aasd stringByAppendingString:str1];
        }
        [arrayCode addObject:aaaa];
    }
    //    NSLog(@"%@",arrayCode);
}

//读取国际手机区号
-(void)loadEnCode{
    
    arrayCode=[[NSMutableArray alloc]initWithObjects:@"", nil];
    for (int i=1; i<[array count]; i++) {
        NSString *_str=[array objectAtIndex:i];
        NSArray *countryNameArray = [_str componentsSeparatedByString:@":"];
        [arrayCode addObject:[countryNameArray objectAtIndex:0]];
    }
}


//读取国家名
-(void)loadingName{
    arrayName=[[NSMutableArray alloc]initWithObjects:@"", nil];
    for (int i=1; i<[array count]; i++) {
        NSString *_str=[array objectAtIndex:i];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^x00-xff]" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *aarray =    nil;
        aarray = [regex matchesInString:_str options:0 range:NSMakeRange(0, [_str length])];
        //*****************************************
        NSString *str1 =@"";
        NSString *aasd=@"";
        NSString *aaaa=@"";
        for (NSTextCheckingResult* b in aarray)
        {
            aasd=[aasd stringByAppendingString:str1];
            str1 = [_str substringWithRange:b.range];
            aaaa=[aasd stringByAppendingString:str1];
        }
        [arrayName addObject:aaaa];
    }
    //    NSLog(@"%@",arrayName);
    
}

//读取英文国家名
-(void)loadEnName{
    arrayName=[[NSMutableArray alloc]initWithObjects:@"", nil];
    for (int i=1; i<[array count]; i++) {
        NSString *_str=[array objectAtIndex:i];
        NSArray *countryNameArray = [_str componentsSeparatedByString:@":"];
        NSLog(@"****%@",[countryNameArray objectAtIndex:1]);
        [arrayName addObject:[countryNameArray objectAtIndex:1]];
    }
}

//读取国家拼音字母
-(void)loadingSpelling{
    arraySpelling= [NSMutableArray array];
    for (int i=1; i<[array count]; i++) {
        NSString *_str=[array objectAtIndex:i];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[A-Z]" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *aarray =nil;
        aarray = [regex matchesInString:_str options:0 range:NSMakeRange(0, [_str length])];
        //*****************************************
        NSString *str1 =@"";
        NSString *aasd=@"";
        NSString *aaaa=@"";
        for (NSTextCheckingResult* b in aarray)
        {
            aasd=[aasd stringByAppendingString:str1];
            str1 = [_str substringWithRange:b.range];
            aaaa=[aasd stringByAppendingString:str1];
        }
        [arraySpelling addObject:aaaa];
    }
    //    NSLog(@"%@",arraySpelling);
    
}


//读取国家英文字母
-(void)loadEnSpelling{
    
    arraySpelling=[[NSMutableArray alloc]initWithObjects:@"", nil];
    for (int i=1; i<[array count]; i++) {
        NSString *_str=[array objectAtIndex:i];
        NSLog(@"*******%@",_str);
        NSArray *countryNameArray = [_str componentsSeparatedByString:@":"];
        
        NSLog(@"string:%@", [countryNameArray objectAtIndex:1]);
        
        [arraySpelling addObject:[countryNameArray objectAtIndex:1]];
    }
    
    
}


- (id)initWithSectionIndexes:(BOOL)showSectionIndexes
{
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.title = @"Search Bar";
        
        _showSectionIndexes = showSectionIndexes;
        
        //        NSString *path = [[NSBundle mainBundle] pathForResource:@"Top100FamousPersons" ofType:@"plist"];
        //        _famousPersons = [[NSArray alloc] initWithContentsOfFile:path];
        [self loadingChineseInternationCode];
        if (showSectionIndexes) {
            UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
            
            NSMutableArray *unsortedSections = [[NSMutableArray alloc] initWithCapacity:[[collation sectionTitles] count]];
            for (NSUInteger i = 0; i < [[collation sectionTitles] count]; i++) {
                [unsortedSections addObject:[NSMutableArray array]];
            }
            
            for (NSString *personName in arrayName) {
                NSInteger index = [collation sectionForObject:personName collationStringSelector:@selector(description)];
                [[unsortedSections objectAtIndex:index] addObject:personName];
            }
            
            NSMutableArray *sortedSections = [[NSMutableArray alloc] initWithCapacity:unsortedSections.count];
            for (NSMutableArray *section in unsortedSections) {
                [sortedSections addObject:[collation sortedArrayFromArray:section collationStringSelector:@selector(description)]];
            }
            
            self.sections = sortedSections;
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    //    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    //    [self.searchBar setBackgroundColor:[UIColor blackColor]];
    [self.searchBar setSearchBarStyle:UISearchBarStyleDefault];
    self.searchBar.placeholder = @"Search";
    self.searchBar.delegate = self;
    
    [self.searchBar sizeToFit];
    
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (animated) {
        [self.tableView flashScrollIndicators];
    }
}

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    NSAssert(YES, @"This method should be handled by a subclass!");
}

#pragma mark - TableView Delegate and DataSource

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.tableView && self.showSectionIndexes) {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    } else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView && self.showSectionIndexes) {
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
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index] - 1; // -1 because we add the search symbol
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        if (self.showSectionIndexes) {
            return self.sections.count;
        } else {
            return 1;
        }
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (self.showSectionIndexes) {
            return [[self.sections objectAtIndex:section] count];
        } else {
            return arrayName.count;
        }
    } else {
        return self.filteredPersons.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier];
    }
    
    if (tableView == self.tableView) {
        if (self.showSectionIndexes) {
            cell.textLabel.text =[[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",[arrayName objectAtIndex:[indexPath row]]];
            
        }
    } else {
        cell.textLabel.text = [self.filteredPersons objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //    NSLog(@"%d",[arrayName count]);
    //    NSLog(@"第一个%@",[arrayName objectAtIndex:1]);
    //    NSLog(@"最后一个%@",[arrayName objectAtIndex:228]);
    //    NSLog(@"%d",[indexPath row]);
    
    
    NSLog(@"*****%@",[[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]);
    
    for (int i=0; i<arrayName.count; i++) {
        NSLog(@"*****%@",[arrayName objectAtIndex:i]);
        if ([[arrayName objectAtIndex:i] isEqual:[[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]) {
            NSLog(@"+ %@",[arrayName objectAtIndex:i]);
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NNC_Country_Code"object:[arrayCode objectAtIndex:i]];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NNC_Country_Name"object:[[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Search Delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.filteredPersons = arrayName;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.filteredPersons = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.filteredPersons = [self.filteredPersons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchString]];
    
    return YES;
}

-(void)dealloc{
}

@end