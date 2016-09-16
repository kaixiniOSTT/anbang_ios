//
//  MyDrawRectUtility.m
//  anbang_ios
//
//  Created by silenceSky  on 14-7-11.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "MyDrawRectUtility.h"

@implementation MyDrawRectUtility


+ (void)lineDrawRect:(CGRect)rect
{
    
    //获得处理的上下文
    
    CGContextRef
    context = UIGraphicsGetCurrentContext();
    
    //指定直线样式
    
    CGContextSetLineCap(context,
                        kCGLineCapSquare);
    
    //直线宽度
    
    CGContextSetLineWidth(context,
                          2.0);
    
    //设置颜色
    
    CGContextSetRGBStrokeColor(context,
                               0.314, 0.486, 0.859, 1.0);
    
    //开始绘制
    
    CGContextBeginPath(context);
    
    //画笔移动到点(31,170)
    
    CGContextMoveToPoint(context,
                         31, 70);
    
    //下一点
    
    CGContextAddLineToPoint(context,
                            129, 148);
    
    //下一点
    
    CGContextAddLineToPoint(context,
                            159, 148);
    
    //绘制完成
    
    CGContextStrokePath(context);
    
}

@end
