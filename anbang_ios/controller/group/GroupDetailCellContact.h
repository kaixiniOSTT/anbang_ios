//
//  GroupDetailContactCell.h
//  anbang_ios
//
//  Created by yangsai on 15/3/29.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupDetailCellContact;

@protocol GroupDetailCellContactDelegate <NSObject>

-(void)groupDetailCellContact:(GroupDetailCellContact*) cellContact deleMemberSuccess:(NSString* ) MemberJid;

-(void)groupDetailCellContact:(GroupDetailCellContact*) cellContact addMemberSuccess:(NSString* ) MemberJid;

-(void)groupMemberClicked:(NSString*)jid;

@end

@interface GroupDetailCellContact : UITableViewCell
@property (nonatomic, retain) NSMutableArray* contacts;
@property (nonatomic, assign) BOOL  isAdmin;
@property (nonatomic, assign) BOOL  isAB;
@property (nonatomic, retain) NSString*  groupJid;
@property (nonatomic, assign) BOOL isDele;
@property (nonatomic, assign) id<GroupDetailCellContactDelegate>delegate;
@property (nonatomic, assign) UIView *groupSettingView;
@end
