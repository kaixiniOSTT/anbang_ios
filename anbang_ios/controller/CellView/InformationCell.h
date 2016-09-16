//
//  InformationCell.h
//  anbang_ios
//
//  Created by seeko on 14-3-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InformationCell : UITableViewCell
@property(strong,nonatomic) UILabel *labLeftText;
@property(strong ,nonatomic) UILabel *labRigitText;
@property(strong ,nonatomic) UIImageView *headImage;
@property(strong ,nonatomic) UIImageView *codeImage;
@property(retain,nonatomic)NSString *LeftText;
@property(retain,nonatomic)NSString *RigitText;
@end
