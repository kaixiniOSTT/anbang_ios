//
//  AILoginAssitant.m
//  anbang_ios
//
//  Created by rooter on 15-3-20.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AIBBIdAssitant.h"
#import "AIHttpTool.h"
#import "AIRegex.h"

@implementation AIBBIdAssitant

+ (void)bbIdWithAccount:(NSString *)account
                success:(void (^)(NSString *))success
                failure:(void (^)(NSError *))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@:9000/get-username?username=%@&countryCode=86", Server_Host, account];
    
    [self requestWithURL:urlString params:nil success:^(NSString *bbId) {
        
        success(bbId);
        
    } failure:^(NSError *error) {
        
        failure(error);
    }];
}

+ (void)requestWithURL:(NSString *)urlString
                params:(id)paramas
               success:(void (^)(NSString *bbId))success
               failure:(void (^)(NSError * error))failure {
    
    [AIHttpTool getWithURL:urlString params:paramas success:^(id json) {
        
        NSDictionary * dict = (NSDictionary *)json;
        JLLog_I("<LoginJson=%@>", dict);
        
        if (1 == [dict[@"exists"] intValue]) {
            
            success(dict[@"username"]);
        }else {
            
            success(nil);
        }
        
    }failure:^(NSError *error) {
        
        failure(error);
    }];
}

@end
