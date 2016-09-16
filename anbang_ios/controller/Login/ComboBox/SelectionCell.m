//
//  SelectionCell.m
//  ComboBox
//
//  Created by Eric Che on 7/17/13.
//  Copyright (c) 2013 Eric Che. All rights reserved.
//

#import "SelectionCell.h"

@implementation SelectionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    _lb.textAlignment=NSTextAlignmentLeft;
//    [_btn setBackgroundImage:[UIImage imageNamed:@"icon_edit_delete.png"] forState:UIControlStateNormal];
}

- (void)dealloc {
}
@end
