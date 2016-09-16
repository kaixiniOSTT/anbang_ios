//
//  NewsCell.m
//  anbang_ios
//
//  Created by seeko on 14-5-14.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "NewsCell.h"

@implementation NewsCell
@synthesize image,title,news,time,labNews;
@synthesize picView;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {


        UIView *view=[[UIView alloc]initWithFrame:CGRectMake(20, 1, 270, 300)];
        [view setBackgroundColor:[UIColor whiteColor]];
        
        [self.contentView addSubview:view];
        labTitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 270, 40)];
        //        labTitle.backgroundColor=[UIColor redColor];
        labTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        [view addSubview:labTitle];
        
        picView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 40, 280, 140)];
        //        picView.backgroundColor=[UIColor blueColor];
        [view addSubview:picView];
        

    }
    return self;
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    
}
//重新set方法
-(void)setTitle:(NSString *)t{
    if (![t isEqualToString:title]) {
        title=[t copy];
        labTitle.text=title;
    }
}

-(void)setNews:(NSString *)n{
    if (![n isEqualToString:news]) {
        news=[n copy];
        labNews.text=news;
    }
}
-(void)setTime:(NSString *)t{
    if (![t isEqualToString:time]) {
        time=[t copy];
        labTime.text=time;
    }
}
//-(void)setImage:(UIImage *)i{
//    if (image != nil) {
//        [image release];
//    }
//    image = [i copy];
//}


@end
