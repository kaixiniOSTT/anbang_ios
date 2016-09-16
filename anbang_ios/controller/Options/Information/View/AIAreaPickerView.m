//
//  AIAreaPickerView.m
//  anbang_ios
//
//  Created by rooter on 15-7-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIAreaPickerView.h"
#import "AIAreaCRUD.h"

@interface AIAreaPickerView ()

@property (strong, nonatomic) UIPickerView   *pickView;
@property (strong, nonatomic) UIView         *spaceView;
@property (strong, nonatomic) UIButton       *cacelButton;
@property (strong, nonatomic) UIButton       *doneButton;
@property (strong, nonatomic) UIView         *animatedView;
@property (strong, nonatomic) NSArray        *areas;
@property (copy,   nonatomic) AIAreaPickerViewDoneSelectionBlock doneBlock;

@end

@implementation AIAreaPickerView {
    UIView *_superView;
}

- (NSArray *)areas {
    if (!_areas) {
        _areas = [AIAreaCRUD areas];
    }
    return _areas;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (UIView *)spaceView {
    if (!_spaceView) {
        _spaceView = [[UIView alloc] init];
        UITapGestureRecognizer *t =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [_spaceView addGestureRecognizer:t];
    }
    return _spaceView;
}

- (void) setupSubviews {
    UIButton *c = [UIButton buttonWithType:UIButtonTypeCustom];
    c.frame = CGRectMake(15, 0, Screen_Width / 2, 40);
    c.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;;
    [c setTitle:@"取消" forState:UIControlStateNormal];
    [c setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [c addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *d = [UIButton buttonWithType:UIButtonTypeCustom];
    d.frame = CGRectMake(Screen_Width / 2, 0, Screen_Width / 2 - 15, 40);
    d.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [d setTitle:@"完成" forState:UIControlStateNormal];
    [d setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [d addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    
    UIPickerView *p = [[UIPickerView alloc] init];
    p.frame = CGRectMake(0, 40, Screen_Width, 160);
    p.backgroundColor = AB_Color_ffffff;
    p.dataSource = self;
    p.delegate = self;
    [p selectRow:0 inComponent:0 animated:NO];
    
    UIView *animatedView = [[UIView alloc] init];
    animatedView.backgroundColor = [UIColor lightGrayColor];
    [animatedView addSubview:c];
    [animatedView addSubview:d];
    [animatedView addSubview:p];
    
    self.cacelButton = c;
    self.doneButton = d;
    self.pickView = p;
    self.animatedView = animatedView;
}

- (void) showInView:(UIView *)view
     completedBlock:(AIAreaPickerViewDoneSelectionBlock)block {
    self.doneBlock = block;
    _superView = view;
    CGRect frame = view.frame;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    self.spaceView.frame = (CGRect){CGPointZero, frame.size};
    [view addSubview:self.spaceView];
    
    self.animatedView.frame = CGRectMake(0, height, width, height);
    [view addSubview:self.animatedView];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.animatedView.frame = CGRectMake(0, height - 200, width, 200);
    }];
}

- (void) tap:(UIGestureRecognizer *)gesture {
    [self hide];
}

- (void) done:(UIButton *)sender {
    [self hide];
    AIArea *province = self.areas[_selectedArea.province];
    AIArea *city = province.subareas[_selectedArea.city];
    self.doneBlock(city.code);
}

- (void) cancel:(UIButton *)sender {
    [self hide];
}

- (void) hide {
    [self hideSpaceView];
    [self hideAnimatedView];
}

- (void) hideAnimatedView {
    __weak typeof(self)wself = self;
    CGSize size = _superView.frame.size;
    [UIView animateWithDuration:0.3 animations:^{
        wself.animatedView.frame = CGRectMake(0, size.height, size.width, 200);
    }];
}

- (void) hideSpaceView {
    [self.spaceView removeFromSuperview];
}

#pragma mark
#pragma mark UIPickerView Datasource & Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return self.areas.count;
            break;
            
        case 1: {
            AIArea *province = self.areas[_selectedArea.province];
            return province.subareas.count;
        }
            break;
            
        default:
            break;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0: {
            AIArea *province = self.areas[row];
            return province.name;
        }
            break;
            
        case 1: {
            AIArea *province = self.areas[_selectedArea.province];
            AIArea *city = province.subareas[row];
            return city.name;
        }
            break;
            
        default:
            break;
    }
    return nil;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:
            _selectedArea.province = row;
            _selectedArea.city = 0; // needed..
            [pickerView selectRow:0 inComponent:1 animated:NO];
            [pickerView reloadAllComponents];
            break;
            
        case 1:
            _selectedArea.city = row;
            break;
            
        default:
            break;
    }
}
@end
