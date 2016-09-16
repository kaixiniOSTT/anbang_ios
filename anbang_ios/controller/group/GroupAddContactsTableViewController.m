//
//  ChatCustomerViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 14-3-25.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "GroupAddContactsTableViewController.h"
#import "PullingRefreshTableView.h"
#import "XMPPHelper.h"
#import "sqlite3.h"
#import <AudioToolbox/AudioToolbox.h>
#import "GBPathImageView.h"
#import "UserCenterViewController.h"
#import "Utility.h"
#import "ChatBuddyCRUD.h"
#import "PublicCURD.h"
#import "CHAppDelegate.h"
#import "ChatViewController2.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "UIImageView+WebCache.h"


@interface GroupAddContactsTableViewController(){
    
    NSString *chatUserName;
    NSString *chatNickName;
}


@property(nonatomic,retain) NSMutableArray *contactsArray;
@property(nonatomic,retain) NSMutableArray *subscriptionUserInfo;
@property(nonatomic,retain) NSMutableArray *buddyNickNameArray;
@property(nonatomic,retain) NSMutableArray *buddyNumberArray;
@property(nonatomic,retain) NSMutableArray *userInfoNickNameArray;
@property(nonatomic,retain) NSMutableArray *userInfoAvtarArray;


@end

@implementation GroupAddContactsTableViewController
@synthesize contactsArray;
@synthesize subscriptionUserInfo;
@synthesize buddyNickNameArray;

@synthesize avtarURL = _avtarURL;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"添加联系人到圈子";
    selectedResults = [[NSMutableArray alloc]init];
    
    mySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    mySearchBar.delegate = self;
    [mySearchBar setPlaceholder:@"搜索列表"];
    
    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:mySearchBar contentsController:self];
    searchDisplayController.active = NO;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    CGRect bounds = self.view.bounds;
    bounds.size.height -= 90.f;
    bounds.origin.y = 0.f;
    
    self.tableView .tableHeaderView = mySearchBar;
    //self.tableView .allowsMultipleSelection = YES;
    [self.tableView  setEditing:!self.tableView.isEditing animated:YES];
    self.tableView.tag = UITableViewCellAccessoryCheckmark ;
    
    
    self.contactsArray = [NSMutableArray array];
    self.buddyNickNameArray = [NSMutableArray array];
    //NSString * myJID = [[NSString alloc] initWithFormat:@"%@", [XMPPServer xmppStream].myJID.bareJID];
    [self queryBuddyList:MY_JID];
    [self.tableView  reloadData];
    //添加工具栏
    [self addToolbar];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        self.searchDisplayController.searchResultsTableView.allowsMultipleSelection = YES;
        [self.searchDisplayController.searchResultsTableView setEditing:YES];
        return searchResults.count;
    }
    else {
        return self.contactsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSDictionary *contactsDic = [searchResults objectAtIndex:[indexPath row]];
        //cell.textLabel.text = searchResults[indexPath.row];
        cell.textLabel.text = [contactsDic objectForKey:@"searchName"];
        
    }
    else {
        
        // cell.textLabel.text = dataArray[indexPath.row];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 230, 55)];
        [cell removeFromSuperview];
        lbl.text = nil;
        
        //接收到数据，用泡泡VIEW显示出来
        //发送者
        
        NSString *userName = nil;
        
        NSDictionary *buddyDic = [self.contactsArray objectAtIndex:[indexPath row]];
        NSString *jidStr = [buddyDic objectForKey:@"jid"];
        NSString*str_character = @"@";
        NSRange jidRange = [jidStr rangeOfString:str_character];
        
        if ([jidStr rangeOfString:str_character].location != NSNotFound) {
            userName = [jidStr substringToIndex:jidRange.location];
        }
        
        if (indexPath.section ==0) {
            
            // cell.textLabel.text = [self.onlineUsers objectAtIndex:[indexPath row]];
            
            NSLog(@"name%@",[buddyDic objectForKey:@"name"]);
            NSLog(@"nickName%@",[buddyDic objectForKey:@"nickName"]);
            
            if ([buddyDic objectForKey:@"name"]!=NULL && ![[buddyDic objectForKey:@"name"] isEqualToString:@""]) {
                cell.textLabel.text = [buddyDic objectForKey:@"name"];
                cell.detailTextLabel.text = userName;
            }else if ([buddyDic objectForKey:@"nickName"]!=NULL && ![[buddyDic objectForKey:@"nickName"] isEqualToString:@""]) {
                cell.textLabel.text = [buddyDic objectForKey:@"nickName"];
                cell.detailTextLabel.text = userName;
            }else{
                cell.textLabel.text = userName;
            }
        }
        
        
        UIImageView*photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 50.0, 50.0)];
        
        if ([buddyDic objectForKey:@"avatar"]!=NULL && ![[buddyDic objectForKey:@"avatar"] isEqualToString:@""]) {
            NSString *avatarURL =[NSString stringWithFormat:@"%@/%@",ResourcesURL, [buddyDic objectForKey:@"avatar"]];
            [photoView setImageWithURL:[NSURL URLWithString:avatarURL]
                      placeholderImage:[UIImage imageNamed:@"defaultUser.png"]];
        }
        
        if (photoView.image){
            NSLog(@"recevice message!");
            GBPathImageView *squareImage = [[GBPathImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 50.0, 50.0) image:photoView.image pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor whiteColor] pathWidth:0.0];
            
            cell.imageView.image=squareImage.image;
            
        }else{
            UIImage *userImage =[UIImage imageNamed:@"defaultUser.png"];
            GBPathImageView *squareImage = [[GBPathImageView alloc] initWithFrame:CGRectMake(0.0, 3.0, 50.0, 50.0) image:userImage pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor whiteColor] pathWidth:0.0];
            cell.imageView.image = squareImage.image;
        }
        NSLog(@"**********%d",selectedResults.count);
        
        //是否选中
        [selectedResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            // NSLog(@"遍历array：%zi-->%@",idx,obj);
            if([jidStr isEqualToString:obj]){
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
            }
        }];
    }
    return cell;
}


//选中一行数据
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"选中搜索好友");
        NSDictionary *contactsDic = [searchResults objectAtIndex:[indexPath row]];
        [selectedResults addObject:[contactsDic objectForKey:@"jid"]];
        
    }else{
        NSLog(@"选中好友");
        NSDictionary *contactsDic = [self.contactsArray objectAtIndex:[indexPath row]];
        [selectedResults addObject:[contactsDic objectForKey:@"jid"]];
        NSLog(@"$$$$$$$%d",selectedResults.count);
        
    }
}

//取消选中
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"取消选中搜索好友");
        NSDictionary *contactsDic = [searchResults objectAtIndex:[indexPath row]];
        [selectedResults removeObject:[contactsDic objectForKey:@"jid"]];
    }else{
        NSLog(@"取消选中好友");
        NSDictionary *contactsDic = [self.contactsArray objectAtIndex:[indexPath row]];
        [selectedResults removeObject:[contactsDic objectForKey:@"jid"]];
        
    }
}


//tableView的编辑模式中当提交一个编辑操作时候调用：比如删除，添加等
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"——————————");
    
}

//每次设置为编辑模式之前，都会访问这个方法：
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"＊＊＊＊＊");
    
    return self.tableView.tag;
}



//编辑模式的时候，拖动的时候会调用这个方法：
//-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
//    //TODO
//}


//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}


-(void)addToolbar
{
//    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]
//                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//                                  target:nil action:nil];
    //    UIBarButtonItem *customItem1 = [[UIBarButtonItem alloc]
    //                                    initWithTitle:@"Tool1" style:UIBarButtonItemStyleBordered
    //                                    target:self action:@selector(toolBarItem1:)];
    //    UIBarButtonItem *customItem2 = [[UIBarButtonItem alloc]
    //                                    initWithTitle:@"Tool2" style:UIBarButtonItemStyleDone
    //                                    target:self action:@selector(toolBarItem2:)];
    //
    //删除好友
//    UIBarButtonItem *deleteBuddyItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(toDeleteButty)];
    // [self.navigationItem setLeftBarButtonItem:deleteBuddyItem];
    
    
    //添加好友
//    UIBarButtonItem *addBuddyItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toAddButty)];
    //  [self.navigationItem setRightBarButtonItem:addBuddyItem];
    
    
//    NSArray *toolbarItems = [NSArray arrayWithObjects:
//                             deleteBuddyItem,spaceItem, addBuddyItem, nil];
//    UIToolbar *toolbar = [[UIToolbar alloc] init];
//    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
//        toolbar = [[UIToolbar alloc]initWithFrame:
//                   CGRectMake(0, 366+70, 320, 50)];
//    }else{
//        toolbar = [[UIToolbar alloc]initWithFrame:
//                   CGRectMake(0, 366+50, 320, 50)];
//    }
//    [toolbar setBarStyle:UIBarStyleBlackOpaque];
//    [self.view addSubview:toolbar];
//    [toolbar setItems:toolbarItems];
    //[toolbarItems release];
    // [addBuddyItem release];
    // [deleteBuddyItem release];
    // [toolbar release];
}


#pragma UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    searchResults = [[NSMutableArray alloc]init];
    if (mySearchBar.text.length>0&&![ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
        for (int i=0; i<self.contactsArray.count; i++) {
            NSDictionary *searchBuddyDic = [self.contactsArray objectAtIndex:i];
            NSString *userName = nil;
            
            NSString *jidStr = [searchBuddyDic objectForKey:@"jid"];
            NSString*str_character = @"@";
            NSRange jidRange = [jidStr rangeOfString:str_character];
            
            if ([jidStr rangeOfString:str_character].location != NSNotFound) {
                userName = [jidStr substringToIndex:jidRange.location];
            }
            
            NSString *searchName = @"";
            if ([searchBuddyDic objectForKey:@"name"]!=NULL && ![[searchBuddyDic objectForKey:@"name"] isEqualToString:@""]) {
                searchName = [searchBuddyDic objectForKey:@"name"];
            }else if ([searchBuddyDic objectForKey:@"nickName"]!=NULL && ![[searchBuddyDic objectForKey:@"nickName"] isEqualToString:@""]) {
                searchName= [searchBuddyDic objectForKey:@"nickName"];
                
            }else{
                searchName = userName;
            }
            
            if ([ChineseInclude isIncludeChineseInString:searchName]) {
                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:searchName];
                NSRange titleResult=[tempPinYinStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    // [searchResults addObject:searchName];
                    [searchResults addObject:[NSDictionary dictionaryWithObjectsAndKeys:jidStr,@"jid",searchName, @"searchName",nil]];
                }
                //                NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:searchName];
                //                NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                //                if (titleHeadResult.length>0) {
                //                    [searchResults addObject:searchName];
                //                }
            }
            else {
                NSRange titleResult=[searchName rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    //[searchResults addObject:searchName];
                    [searchResults addObject:[NSDictionary dictionaryWithObjectsAndKeys:jidStr,@"jid",searchName, @"searchName",nil]];
                }
            }
        }
    } else if (mySearchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
        
        
        for (NSDictionary *tempDic in self.contactsArray) {
            NSString *tempStr = @"";
            NSString *userName = @"";
            
            NSString *jidStr = [tempDic objectForKey:@"jid"];
            NSString*str_character = @"@";
            NSRange jidRange = [jidStr rangeOfString:str_character];
            
            if ([jidStr rangeOfString:str_character].location != NSNotFound) {
                userName = [jidStr substringToIndex:jidRange.location];
            }
            
            if ([tempDic objectForKey:@"name"]!=NULL && ![[tempDic objectForKey:@"name"] isEqualToString:@""]) {
                tempStr = [tempDic objectForKey:@"name"];
            }else if ([tempDic objectForKey:@"nickName"]!=NULL && ![[tempDic objectForKey:@"nickName"] isEqualToString:@""]) {
                tempStr= [tempDic objectForKey:@"nickName"];
                
            }else{
                tempStr = userName;
            }
            
            
            NSRange titleResult=[tempStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
            if (titleResult.length>0) {
                //[searchResults addObject:tempStr];
                [searchResults addObject:[NSDictionary dictionaryWithObjectsAndKeys:jidStr,@"jid",tempStr, @"searchName",nil]];
            }
        }
    }
    
    [self.tableView  reloadData];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.frame = CGRectMake(-320, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    [UIView animateWithDuration:0.7 animations:^{
        cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    } completion:^(BOOL finished) {
        ;
    }];
}


-(void)queryBuddyList:(NSString *)myJID{
    [PublicCURD openDataBaseSQLite];
    [self.contactsArray removeAllObjects];
    
    NSString *selectSqlStr=[NSString stringWithFormat:@"select id,jid,name,nickName,phone,avatar,addTime from BuddyList where myJID = \"%@\"",myJID];
    
    const char *selectSql = [selectSqlStr UTF8String];
    sqlite3_stmt *statement;
    
    
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK)
    {
        NSLog(@"select ok.");
        
        while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
        {
            
            // int _id=sqlite3_column_int(statement, 0);
            
            NSString *jid=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
            
            NSString *name=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
            
            NSString *nickName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3) encoding:NSUTF8StringEncoding];
            
            NSString *phone=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 4) encoding:NSUTF8StringEncoding];
            
            NSString *avatar=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 5) encoding:NSUTF8StringEncoding];
            
            NSString *addTime=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 6) encoding:NSUTF8StringEncoding];
            
            NSLog(@"%@,%@,%@",nickName,phone,avatar);
            [self.contactsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:jid,@"jid",name, @"name",nickName,@"nickName",phone,@"phone",avatar,@"avatar", addTime, @"addTime", nil]];
            
            
        }
        
    }
    [PublicCURD closeDataBaseSQLite];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

@end
