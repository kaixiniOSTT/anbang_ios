//
//  AIAreaPickerView.h
//  anbang_ios
//
//  Created by rooter on 15-7-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AIAreaPickerViewDoneSelectionBlock)(NSString *code);

typedef struct {
    int province;
    int city;
}PickerIndex;

@interface AIAreaPickerView : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>
{
    PickerIndex _selectedArea;
}

- (void) showInView:(UIView *)view completedBlock:(AIAreaPickerViewDoneSelectionBlock)block;

@end
