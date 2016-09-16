//
//  AKeyRegisteredTableViewController2.h
//  anbang_ios
//
//  Created by silenceSky  on 14-7-11.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AKeyRegisteredTableViewController2 : UITableViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
        UITextField *textFieldName;
}
@property(nonatomic,retain)NSString * prompt;
@property(nonatomic,retain)NSString * userSource;
@end
