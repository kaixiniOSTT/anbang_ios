//
//  ContactImage.m
//  anbang_ios
//
//  Created by appdor on 4/7/15.
//  Copyright (c) 2015 ch. All rights reserved.
//

#import "ContactImage.h"

@interface ContactImage ()
{
    IBOutlet UIImageView *imageView;
    IBOutlet NSLayoutConstraint *constrain;
}
@end

@implementation ContactImage


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    imageView.image = self.image;
    imageView.frame = self.originFrame;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [UIView animateWithDuration:0.4 animations:^(){
        self.navigationController.navigationBarHidden = YES;
        constrain.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)foregroundClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
