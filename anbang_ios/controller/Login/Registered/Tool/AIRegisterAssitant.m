//
//  AIRegisterAssitant.m
//  anbang_ios
//
//  Created by rooter on 15-3-25.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIRegisterAssitant.h"
#import "AIHttpTool.h"
#import "AIRegex.h"

@implementation AIRegisterAssitant

+ (void)checkEmail:(NSString *)email
             success:(void (^)(BOOL))success failure:(void (^)(NSError *))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@:9000/check-email?email=%@", Server_Host, email];
    [self requestWithURL:urlString params:nil success:^(BOOL used) {
        
        success(used);

    } failure:^(NSError *error) {
        
        failure(error);
    }];
}

+ (void)requestWithURL:(NSString *)urlString
                params:(id)paramas
               success:(void(^)(BOOL used))success
               failure:(void(^)(NSError *error))failure {
    
    [AIHttpTool getWithURL:urlString params:paramas success:^(id json) {
        
        NSDictionary * dict = (NSDictionary *)json;
        JLLog_I("<LoginJson=%@, url=%@>", dict, urlString);
        
        [dict[@"emailUsed"] intValue] == 1 ? success(YES) : success(NO);
        
    }failure:^(NSError *error) {
        
        failure(error);
    }];
}


@end
