//
//  NewsCell.h
//  anbang_ios
//
//  Created by seeko on 14-5-14.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface NewsCell : UITableViewCell
{
    UILabel *labTitle;
    UILabel *labNews;
    UILabel *labReading;
    UILabel *labTime;
}
@property (strong, nonatomic)  UIImageView 	*picView;
@property(nonatomic,assign)UILabel *labNews;
@property(nonatomic,copy)UIImage *image;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *news;
@property(nonatomic,copy)NSString *time;
@end
