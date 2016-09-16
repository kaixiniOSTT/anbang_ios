//
//  AIImageBarButtonItem.m
//  anbang_ios
//
//  Created by Kim on 15/8/4.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIImageBarButtonItem.h"

@implementation AIImageBarButtonItem

- (id)initWithImageNamed:(NSString*)name target:(id)target action:(SEL)action
{
    return [[super init] initWithImage:[UIImage imageNamed:name] style:UIBarButtonItemStyleDone target:target action:action];
}

@end
