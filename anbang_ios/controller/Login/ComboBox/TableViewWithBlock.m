//
//  TableViewWithBlock.m
//  ComboBox
//
//  Created by Eric Che on 7/17/13.
//  Copyright (c) 2013 Eric Che. All rights reserved.
//

#import "TableViewWithBlock.h"
#import "UITableView+DataSourceBlocks.h"
#import "UITableView+DelegateBlocks.h"
#import "SelectionCell.h"
#import "UserNameCRUD.h"
@implementation TableViewWithBlock
float cellHeight;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)initTableViewDataSourceAndDelegate:(UITableViewNumberOfRowsInSectionBlock)numOfRowsBlock setCellForIndexPathBlock:(UITableViewCellForRowAtIndexPathBlock)cellForIndexPathBlock setDidSelectRowBlock:(UITableViewDidSelectRowAtIndexPathBlock)didSelectRowBlock setHeightForRowAtIndexPathBlock:(UITableViewHeightForRowAtIndexPathBlock) heightForRowAtIndexPathBlock{
   
    self.numberOfRowsInSectionBlock=numOfRowsBlock;
    self.cellForRowAtIndexPath=cellForIndexPathBlock;
    self.didDeselectRowAtIndexPathBlock=didSelectRowBlock;
    self.heightForRowAtIndexPathBlock=heightForRowAtIndexPathBlock;
    self.dataSource=self;
    self.delegate=self;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.cellForRowAtIndexPath(tableView,indexPath);
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.numberOfRowsInSectionBlock(tableView,section);
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.didDeselectRowAtIndexPathBlock(tableView,indexPath);
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   // UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
//    if (cell) {
//        return cell.frame.size.height;
//    }
//    return 0;
    return self.heightForRowAtIndexPathBlock(tableView,indexPath);
}
//删除cell
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
    //NSLog(@"%@",cell.textLabel.text);
    [UserNameCRUD deleteUserName:cell.textLabel.text];
    tableView.tag = UITableViewCellEditingStyleNone;
    [tableView setEditing:!tableView.isEditing animated:YES];
    CGRect frame=tableView.frame;
    frame.size.height=0;
    [tableView setFrame:frame];
}

@end
