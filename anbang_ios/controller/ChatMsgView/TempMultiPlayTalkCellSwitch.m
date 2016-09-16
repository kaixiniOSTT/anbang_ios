//
//  TempMultiPlayTalkCellSwitch.m
//  anbang_ios
//
//  Created by yangsai on 15/4/1.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "TempMultiPlayTalkCellSwitch.h"
#import "UserInfoCRUD.h"

@implementation TempMultiPlayTalkCellSwitch

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    UISwitch *aSwitch = [[UISwitch alloc] init];
    aSwitch.frame = CGRectMake(Screen_Width - 15 - 50, 7, 50, 30);
    [aSwitch addTarget:self action:@selector(doSwitchChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:aSwitch];
    self.tempSwitch = aSwitch;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self.tempSwitch setOn:_isOn];
    // Configure the view for the selected state
}
- (IBAction)doSwitchChangeValue:(id)sender {
    UISwitch* switchTmp = (UISwitch*)sender;
    if([_opType isEqualToString:@"消息免打扰"])
    {
        //        <iq type="set">
        //        <query xmlns="http://www.nihualao.com/xmpp/dnd">
        //        <item jid=""/><!—添加一条—>
        //        <item jid="" remove="true"/><!—删除一条—>
        //        </query>
        //        </iq>
        
        NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/dnd"];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
        [item addAttributeWithName:@"jid" stringValue:_jid];
        if (!switchTmp.isOn) {
            [item addAttributeWithName:@"remove" stringValue:@"true"];
        }
        
        [iq addChild:queryElement];
        [queryElement addChild:item];
        
        //  NSLog(@"组装后的xml:%@",iq);
        [[XMPPServer xmppStream] sendElement:iq];
    }else if ([_opType isEqualToString:@"置顶聊天"])
    {
        NSString *timesp = nil;
        if (switchTmp.isOn) {
            NSDate *now = [NSDate date];
            timesp = [NSString stringWithFormat:@"%ld", (long)[now timeIntervalSince1970]];
        }else {
            timesp = @"0";
        }
        [UserInfoCRUD addStickieTime:timesp withJID:_jid];
    }
}

@end
