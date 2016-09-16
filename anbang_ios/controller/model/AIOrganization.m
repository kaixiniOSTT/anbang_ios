//
//  AIOrganization.m
//  anbang_ios
//
//  Created by rooter on 15-5-12.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIOrganization.h"

@implementation AIOrganization

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@, %p> {name=%@, code=%@, parent=%@, index_id=%@, pinyin=%@}",
            [self class], self, self.name, self.code, self.parentCode, self.indexId, self.pinyin];
}

@end
