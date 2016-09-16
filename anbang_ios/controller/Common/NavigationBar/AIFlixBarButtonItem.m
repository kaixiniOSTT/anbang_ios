//
//  AIBarButtonFlixItem.m
//  anbang_ios
//
//  Created by Kim on 15/8/3.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIFlixBarButtonItem.h"

@implementation AIFlixBarButtonItem

- (id)initWithWidth:(CGFloat)width
{
    self = [[super init] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.title = @"";
    self.width = width;
    return self;
}

@end
