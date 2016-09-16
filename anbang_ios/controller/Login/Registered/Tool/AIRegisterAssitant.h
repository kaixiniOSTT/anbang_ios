//
//  AIRegisterAssitant.h
//  anbang_ios
//
//  Created by rooter on 15-3-25.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIRegisterAssitant : NSObject

+ (void)checkEmail:(NSString *)email success:(void(^)(BOOL used))success failure:(void(^)(NSError *error))failure;

@end
