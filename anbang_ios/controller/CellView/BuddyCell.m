//
//  BuddyCell.m
//  anbang_ios
//
//  Created by seeko on 14-3-18.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "BuddyCell.h"

@interface BuddyCell ()

@end

@implementation BuddyCell
@synthesize labName;
@synthesize labDescription;
@synthesize userHead;
@synthesize description,name;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setName:(NSString *)n{
    if (![n isEqualToString:name]) {
        name=[n copy];
        labName.text=name;
    }
}

-(void)dealloc{

}

@end
