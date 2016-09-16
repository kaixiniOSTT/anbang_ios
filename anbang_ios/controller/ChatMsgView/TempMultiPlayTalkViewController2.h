//
//  TempMultiPlayTalkViewController2.h
//  anbang_ios
//
//  Created by yangsai on 15/3/31.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TempMultiPlayTalkViewController2;

@protocol TempMultiPlayTalkVCDelegate <NSObject>

-(void)tempMultiPlayTalkViewController:(TempMultiPlayTalkViewController2*)ControllerView SuccessWithDeleteChatMsg:(NSString*) success;

@end

@interface TempMultiPlayTalkViewController2 : UITableViewController
@property (nonatomic, copy)NSString* memberJID;
@property (nonatomic, copy)NSString* memberName;
@property (nonatomic, assign) id<TempMultiPlayTalkVCDelegate>delegate;

@end
