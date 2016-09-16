//
//  NSString+Helper.h
//  QRCode
//
//  Created by apple on 13-12-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)


/**
 * 返回当前字符串对应的二维码图像
 *
 * 二维码的实现是将字符串传递给滤镜，滤镜直接转换生成二维码图片
 */
- (UIImage *)createRRcode;
@end
