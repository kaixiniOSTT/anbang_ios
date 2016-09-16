//
//  GroupDetailCellSwitch.h
//  anbang_ios
//
//  Created by yangsai on 15/3/29.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupDetailCellSwitch : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *groupSwitch;

@property (strong, nonatomic) NSString* jid;
@property (strong, nonatomic) NSString* opType;
@property (assign, nonatomic) BOOL isOn;
- (IBAction)doSwitchChangeValue:(id)sender;
@end
