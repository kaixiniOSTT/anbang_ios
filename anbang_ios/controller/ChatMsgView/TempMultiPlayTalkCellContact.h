//
//  TempMultiPlayTalkCellContact.h
//  anbang_ios
//
//  Created by yangsai on 15/3/31.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TempMultiPlayTalkCellContact;


@protocol TempMultiPlayTalkCellContactDelegate <NSObject>

-(void)tempMultiPlayTalkCellContact:(TempMultiPlayTalkCellContact*) cellContact addMemberSuccess:(NSString* ) MemberJid;

-(void)showContactInfo:(TempMultiPlayTalkCellContact*) cellContact;

@end

@interface TempMultiPlayTalkCellContact : UITableViewCell
@property (nonatomic, retain) NSMutableArray* multiplayerTalkArray;

@property (nonatomic, assign) id<TempMultiPlayTalkCellContactDelegate>delegate;
@end
