//
//  TempMultiPlayTalkCellSwitch.h
//  anbang_ios
//
//  Created by yangsai on 15/4/1.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TempMultiPlayTalkCellSwitch : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *tempSwitch;
@property (strong, nonatomic) NSString* jid;
@property (strong, nonatomic) NSString* opType;
@property (assign, nonatomic) BOOL isOn;
@end
