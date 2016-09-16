//
//  AILoginAssitant.h
//  anbang_ios
//
//  Created by rooter on 15-3-20.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIBBIdAssitant : NSObject

+ (void)bbIdWithAccount:(NSString *)account
                success:(void(^)(NSString *bbId))success
                failure:(void(^)(NSError *error))failure;

@end
