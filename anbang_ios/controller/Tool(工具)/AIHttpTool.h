//
//  AIHttpTool.h
//  anbang_ios
//
//  Created by rooter on 15-3-20.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIHttpTool : NSObject

/**
 *  发送一个POST请求
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (void)postWithURL:(NSString *)url params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;

/**
 *  发送一个GET请求
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (void)getWithURL:(NSString *)url params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;

/**
 *  发送一个GET请求
 *
 *  @param url      请求路径
 *  @param contentType  请求内容类型
 *  @param params  请求参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (void)getWithURL:(NSString *)url contentType:(NSString*)contentType params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure;

/**
 *  上传文件请求
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @param data    图片数据
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (void)uploadImageWithURL:(NSString *)url data:(NSData *)data success:(void (^)(id))success failure:(void (^)(NSError *))failure;

@end
