//
//  AIAreaCRUD.h
//  anbang_ios
//
//  Created by rooter on 15-7-10.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIArea : NSObject
@property (copy, nonatomic) NSString *code;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *pcode;
@property (copy, nonatomic) NSString *rowId;
@property (copy, nonatomic) NSArray  *subareas;
@end

@interface AIAreaCRUD : NSObject

+ (void) prepareDatabaseInSandBox;
+ (NSArray *) areas;
+ (NSString *) selectNameForShowWithCode:(NSString *)code;

@end
