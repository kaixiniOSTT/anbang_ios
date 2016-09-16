//
//  DataPlist.m
//  Weather
//
//  Created by he on 13-7-10.
//  Copyright (c) 2013年 CoreLo. All rights reserved.
//

#import "DataPlist.h"

@implementation DataPlist

//获取文件路径
+ (NSString *)getPlistPath:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:name];
    
    return filename;
}

//获取Document路径
+(NSString *)getDocument
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    return [paths objectAtIndex:0];
}

//把数组对象写入指定的文件
+ (void)writeToPlist:(NSMutableArray *)arr plistName:(NSString *)str
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:str];
    
    [arr writeToFile:filename atomically:YES];
}

+ (NSMutableArray *) readFromPlist:(NSString *) plistname
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:plistname];
    
    NSLog(@"--------filenamepath = %@",filename);
    
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if (![fileManage fileExistsAtPath:filename])
        [fileManage createFileAtPath:filename contents:nil attributes:nil];
    NSMutableArray *arr = [[[NSMutableArray alloc] initWithContentsOfFile:filename]autorelease] ;
    return arr;
}

+(void)setBGimage:(UIView *)view pName:(NSString *)pstr dBGimage:(NSString *)bgname;
{
    NSMutableArray *array = [DataPlist readFromPlist:pstr];
    NSString *sbiaoshi = (NSString *)[array objectAtIndex:1];
    if ([sbiaoshi isEqualToString:@"b"]) {
        NSData *imagedate = (NSData *)[array objectAtIndex:0];
        UIImage *aimage = [UIImage imageWithData: imagedate];
        view.backgroundColor = [[[UIColor alloc] initWithPatternImage:aimage]autorelease];
    }
    if ([sbiaoshi isEqualToString:@"a"]) {
        NSString * bgpath = (NSString *)[array objectAtIndex:0];
        view.backgroundColor = [[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:bgpath]]autorelease];
    }
    if (sbiaoshi == nil ) {
        view.backgroundColor = [[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:bgname]]autorelease];
    }
   }

@end
