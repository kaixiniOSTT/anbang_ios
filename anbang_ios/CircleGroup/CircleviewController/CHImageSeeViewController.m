//
//  CHImageSeeViewController.m
//  anbang_ios
//
//  Created by MyLove on 15/7/22.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "CHImageSeeViewController.h"

@interface CHImageSeeViewController ()
{
    UIScrollView * contentScrollView;
    
    NSMutableArray * muImageArray;
    
    int curPage;
}
@end

@implementation CHImageSeeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitle.text = [NSString stringWithFormat:@"%@/%d",self.curString,self.imageDataArray.count];
    self.rightTitle.text = @"删除";
    muImageArray = [[NSMutableArray alloc]initWithCapacity:0];
    [muImageArray addObjectsFromArray:self.imageDataArray];
    
    contentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, IS_iOS7?64:44,320, Screen_Height-(IS_iOS7?64:44))];
    contentScrollView.backgroundColor = [UIColor clearColor];
    contentScrollView.pagingEnabled = YES;
    contentScrollView.scrollEnabled = YES;
    contentScrollView.bounces = NO;
    contentScrollView.delegate = self;
    contentScrollView.contentSize = CGSizeMake(320*self.imageDataArray.count, 0);
    contentScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:contentScrollView];
    
    for (int i=0; i<muImageArray.count; i++) {
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(320*i, 0, 320, contentScrollView.frame.size.height)];
        imageView.image = [UIImage imageWithData:[muImageArray objectAtIndex:i]];
        [contentScrollView addSubview:imageView];
    }
    int num = [self.curString intValue]-1;
    [contentScrollView setContentOffset:CGPointMake(320*num, 0)];
}

//列表俯视图滚动代理
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ((scrollView = contentScrollView)) {
        int pageNum = scrollView.contentOffset.x/320;
        curPage = pageNum;
        self.navTitle.text = [NSString stringWithFormat:@"%d/%d",pageNum+1,muImageArray.count];
    }
}

-(void)navRightBtnAction:(UIButton *)btn
{
    if (muImageArray.count>1) {
        NSData * data = [muImageArray objectAtIndex:curPage];
        [muImageArray removeObject:data];
        contentScrollView.contentSize = CGSizeMake(320*muImageArray.count, 0);
        
        [[NSUserDefaults standardUserDefaults]setObject:muImageArray forKey:@"mu_image"];
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"is_shanchu"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        for (UIView * view in contentScrollView.subviews) {
            [view removeFromSuperview];
            
        }
        
        for (int i=0; i<muImageArray.count; i++) {
            UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(320*i, 0, 320, contentScrollView.frame.size.height)];
            imageView.image = [UIImage imageWithData:[muImageArray objectAtIndex:i]];
            [contentScrollView addSubview:imageView];
        }
        self.navTitle.text = [NSString stringWithFormat:@"%d/%d",1,muImageArray.count];
    }
    else{
        [muImageArray removeAllObjects];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"mu_image"];
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"is_shanchu"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
